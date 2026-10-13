#!/usr/bin/env bash
# Hook PreToolUse (Bash) del Kit Chema: bloquea git commit si el diff
# staged contiene patrones de credenciales. Exit 2 = bloquear (stderr al modelo).
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")
# Si python3 falla o no está disponible, usar el JSON crudo como comando: esto cierra el fallo-abierto (mejor un falso positivo que dejar de escanear).
if [ -z "$cmd" ] && [ -n "$input" ]; then
  cmd="$input"
fi
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac
patron='(api[_-]?key|secret|token|passw(or)?d)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_/+.-]{12,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
# ¿El commit incluye más que lo ya preparado? `-a`/`--all` (también en grupos como `-am`) o un `git add`
# en el mismo comando: el hook corre ANTES del comando, así que eso todavía no está en el índice.
# Si python3 falla, se asume que sí (escanear de más antes que dejar pasar).
amplio=$(printf '%s' "$cmd" | python3 -c '
import re, shlex, sys
c = sys.stdin.read()
try: toks = shlex.split(c, posix=True)
except ValueError: toks = c.split()
if re.search(r"\bgit\s+add\b", c): print(1); sys.exit()
con_arg = set("mFCct")
for i, t in enumerate(toks):
    if t != "commit" or i == 0 or toks[i-1] != "git": continue
    salta = False
    for x in toks[i+1:]:
        if salta: salta = False; continue
        if x in (";", "&&", "||", "|"): break
        if x == "--all": print(1); sys.exit()
        if x in ("--message", "--file", "--author", "--date", "--template", "--reuse-message", "--reedit-message"): salta = True; continue
        if re.fullmatch(r"-[A-Za-z]+", x):
            for j, ch in enumerate(x[1:]):
                if ch == "a": print(1); sys.exit()
                if ch in con_arg:
                    salta = (j == len(x) - 2); break
print(0)' 2>/dev/null || echo 1)
# Se escanea a archivo y sin `grep -q`: con pipefail, un grep que cierra temprano deja al productor en
# SIGPIPE (141) y el `if` sale falso justo con los diffs grandes.
diff=$(mktemp); trap 'rm -f "$diff"' EXIT
git diff --cached 2>/dev/null > "$diff"
if [ "$amplio" != 0 ]; then
  git diff 2>/dev/null >> "$diff"
  git ls-files -z --others --exclude-standard 2>/dev/null | while IFS= read -r -d '' nuevo; do
    [ -f "$nuevo" ] && head -c 2000000 -- "$nuevo" 2>/dev/null | sed 's/^/+/' >> "$diff"
  done
fi
if grep -E '^\+' -- "$diff" | grep -iE "$patron" >/dev/null; then
  echo "Kit Chema: el diff del commit parece contener credenciales (clave API, token o llave privada). Revísalo y quítalas antes de commitear; si es un falso positivo, dilo y commitea con el hook desactivado." >&2
  exit 2
fi
exit 0
