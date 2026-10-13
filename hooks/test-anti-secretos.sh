#!/usr/bin/env bash
# Prueba de hooks/anti-secretos.sh con secretos SINTÉTICOS en un repo temporal.
# Cubre: diff chico y grande (SIGPIPE con pipefail), commit -a / -am, `git add … && git commit`,
# archivos nuevos sin rastrear, falsos positivos evitables y comandos que no son commit.
set -uo pipefail
HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/anti-secretos.sh"
t="$(mktemp -d)"; trap 'rm -rf "$t"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
SECRETO="AKIA""IOSFODNN7EXAMPLE"   # partido para que el propio repo no lo contenga literal
f=0
fallo() { echo "FALLA $*"; f=1; }
nuevo_repo() { rm -rf "$t/r"; git init -q "$t/r"; printf 'x=1\n' > "$t/r/a.txt"; git -C "$t/r" add -A; git -C "$t/r" commit -qm base; }
correr() { # correr <comando> → imprime el código de salida del hook
  local json; json=$(python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$1")
  (cd "$t/r" && printf '%s' "$json" | bash "$HOOK" >/dev/null 2>&1); echo $?
}
espera() { local rc; rc=$(correr "$2"); [ "$rc" = "$1" ] || fallo "$3 (esperaba $1, dio $rc)"; }

# 1. secreto staged, diff chico → bloquea
nuevo_repo; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"; git -C "$t/r" add a.txt
espera 2 "git commit -m x" "secreto staged en diff chico"

# 2. secreto staged al inicio de un diff grande → bloquea (antes: SIGPIPE + pipefail lo dejaba pasar)
nuevo_repo; { printf 'k=%s\n' "$SECRETO"; seq 1 30000; } > "$t/r/grande.txt"; git -C "$t/r" add grande.txt
espera 2 "git commit -m x" "secreto al inicio de un diff de 30 000 líneas"

# 3. commit -am con el secreto solo en el árbol de trabajo → bloquea
nuevo_repo; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"
espera 2 "git commit -am x" "commit -am con secreto sin preparar"
espera 2 "git commit --all -m x" "commit --all con secreto sin preparar"
espera 2 "git commit -a -m x" "commit -a -m con secreto sin preparar"

# 4. `git add -A && git commit` con un archivo nuevo → bloquea
nuevo_repo; printf 'k=%s\n' "$SECRETO" > "$t/r/nuevo.txt"
espera 2 "git add -A && git commit -m x" "git add && commit con secreto en archivo nuevo"

# 5. el secreto solo está sin preparar y el commit no lo incluye → no bloquea
nuevo_repo; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"; printf 'y=2\n' > "$t/r/b.txt"; git -C "$t/r" add b.txt
espera 0 "git commit -m 'usa la bandera -a luego'" "commit sin -a no debe escanear lo no preparado"

# 6. un -m con una «a» en el mensaje no es -a
espera 0 "git commit -m a" "-m a no es commit -a"

# 7. diff limpio, y comando que no es commit
nuevo_repo; printf 'y=2\n' >> "$t/r/a.txt"; git -C "$t/r" add a.txt
espera 0 "git commit -m x" "diff limpio"
nuevo_repo; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"; git -C "$t/r" add a.txt
espera 0 "git status" "un comando que no es commit"

[ "$f" -eq 0 ] && echo "TODO OK"
exit "$f"
