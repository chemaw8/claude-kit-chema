#!/usr/bin/env bash
# Prueba de hooks/sello-push.sh (gate de push, spec 002 de claude-entorno).
# Uso: bash hooks/test-sello-push.sh [ruta-al-hook]
# Repo git temporal con remoto bare local, un segundo remoto, un worktree enlazado y
# sellos escritos a mano. El ledger va a un archivo temporal (KIT_GATE_LEDGER): la
# prueba NUNCA toca ~/.claude/kit-chema/gate.jsonl.
HOOK="${1:-$(dirname "${BASH_SOURCE[0]}")/sello-push.sh}"
[ -f "$HOOK" ] || { echo "FALLA: hook inexistente ($HOOK)"; exit 1; }
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t HOME_REAL="$HOME"
T=$(mktemp -d); fallos=0; export LEDGER="$T/ledger.jsonl"
g() { git -C "$T/repo" "$@"; }
# remoto bare + repo con main empujado (A) y un commit local sin empujar (B)
git init -q --bare "$T/remoto.git"; git init -q --bare "$T/fork.git"
git init -q -b main "$T/repo"; echo a > "$T/repo/a"; g add a; g commit -q -m A; A=$(g rev-parse HEAD)
g remote add origin "$T/remoto.git"; g remote add fork "$T/fork.git"; g push -q -u origin main 2>/dev/null
echo b >> "$T/repo/a"; g commit -q -am B; B=$(g rev-parse HEAD)
g config kit-chema.gate true
g branch otra; git -C "$T/repo" checkout -q otra; echo o > "$T/repo/o"; g add o; g commit -q -m O; O=$(g rev-parse HEAD); g checkout -q main
g branch ya "$B"; g push -q origin ya 2>/dev/null                      # sha ya presente en el remoto
g branch tagged; g checkout -q tagged; echo c > "$T/repo/c"; g add c; g commit -q -m C; C=$(g rev-parse HEAD); g checkout -q main
g tag v-nueva "$C"; g tag v-vieja "$A"
g worktree add -q -b wt "$T/repo-wt" "$B" 2>/dev/null; WT=$(git -C "$T/repo-wt" rev-parse HEAD)
git init -q -b main "$T/libre"; echo x > "$T/libre/x"; git -C "$T/libre" add x; git -C "$T/libre" commit -q -m X; git -C "$T/libre" remote add origin "$T/remoto.git"
SELLOS="$(g rev-parse --path-format=absolute --git-common-dir)/kit-chema/sellos"; mkdir -p "$SELLOS"
sello() { printf 'head=%s\nrama=%s\nfecha=2026-09-06T00:00:00\nveredicto=%s\nbloquea=%s\navisos=0\nsaltados=%s\nsin_evidencia=0\npruebas=ok\nficha=repo\nmodelo=test\nprompt_sha=x\nhallazgos=[]\n' "$1" "${4:-main}" "$([ "$2" -gt 0 ] && echo con-hallazgos || echo aprobado)" "$2" "$3" > "$SELLOS/$1"; }
sin_sello() { rm -f "$SELLOS/$1"; }
ev() { python3 -c 'import json,sys
ti={"command":sys.argv[2]}
if len(sys.argv)>3 and sys.argv[3]: ti["timeout"]=int(sys.argv[3])
if len(sys.argv)>4 and sys.argv[4]=="bg": ti["run_in_background"]=True
print(json.dumps({"session_id":"s1","transcript_path":"/x","cwd":sys.argv[1],"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":ti}))' "$1" "$2" "${3:-}" "${4:-}"; }
corre() { : ; err=$(KIT_GATE_LEDGER="$LEDGER" bash "$HOOK" <<<"$(ev "$1" "$2" "${3:-}" "${4:-}")" 2>&1 >/dev/null); rc=$?; }
ok()    { echo "  ok    $1"; }
falla() { echo "  FALLA $1 → rc=$rc: $(printf '%s' "$err" | head -c 300)"; fallos=$((fallos+1)); }
pasa()    { corre "$2" "$3" "${4:-}" "${5:-}"; [ $rc -eq 0 ] && ok "$1" || falla "$1"; }
bloquea() { corre "$2" "$3" "${4:-}" "${5:-}"; if [ $rc -eq 2 ] && printf '%s' "$err" | grep -q "Kit Chema"; then ok "$1"; else falla "$1"; fi; }
cita()    { printf '%s' "$err" | grep -q -- "$2" && ok "$1" || { echo "  FALLA $1 → el mensaje no trae [$2]: $(printf '%s' "$err" | head -c 300)"; fallos=$((fallos+1)); }; }
ledger()  { grep -q "\"evento\": *\"$2\"" "$LEDGER" 2>/dev/null && ok "$1" || { echo "  FALLA $1 → ledger: $(tail -1 "$LEDGER" 2>/dev/null)"; fallos=$((fallos+1)); }; }
R="$T/repo"; b7=${B:0:7}; o7=${O:0:7}

echo "RF-1 · detección, segmentos y alcance:"
pasa "comando sin push → 0" "$R" "ls -la && git status"
[ -s "$LEDGER" ] && { echo "  FALLA un comando sin push escribió en el ledger"; fallos=$((fallos+1)); } || ok "sin push no toca el ledger"
pasa "push en repo sin gate → 0" "$T/libre" "git push origin main"
bloquea "git -C repo push sin sello → 2" "$T" "git -C $R push origin main"; cita "el mensaje cita el sha empujado" "$b7"; cita "el mensaje da el camino /revisar-antes-de-subir" "revisar-antes-de-subir"; cita "y el escape del usuario" "KIT_SELLO=omitir"
bloquea "cd repo && git push resuelve el repo → 2" "$T" "cd $R && git push origin main"
pasa "'push' dentro de una cadena no cuenta" "$R" "git commit --allow-empty -m 'explica git push' --dry-run"
pasa "'git push' dentro de un heredoc no cuenta" "$R" $'cat > /dev/null <<\'EOF\'\ngit push origin main\nEOF'
t0=$(date +%s%N); corre "$R" "ls"; t1=$(( ($(date +%s%N)-t0)/1000000 )); echo "  info  comando sin push: ${t1} ms (informativo; meta <50)"

echo "RF-2 · sha del ref empujado y sello por common-dir:"
sello "$B" 0 0; pasa "sello válido → 0" "$R" "git push origin main"; ledger "ledger: permitido" permitido
sello "$B" 2 1; bloquea "2 bloquea + 1 saltado → 2" "$R" "git push origin main"; cita "dice cuántos pendientes" "1 pendiente"; ledger "ledger: bloqueo" bloqueo
sello "$B" 2 2; pasa "2 bloquea + 2 saltados → 0" "$R" "git push origin main"
sin_sello "$O"; bloquea "push fork otra: compara contra el sha de otra, no HEAD" "$R" "git push fork otra"; cita "cita el sha de otra" "$o7"
sello "$O" 0 0 otra; pasa "otra sellada → 0 aunque HEAD no lo esté" "$R" "git push fork otra"
sello "$B" 0 0; pasa "opción con argumento (-o) no se confunde con el remoto" "$R" "git push -o ci.skip origin main"
pasa "push sin argumentos usa el upstream (HEAD sellado)" "$R" "git push"
sin_sello "$B"; bloquea "push sin argumentos sin sello → 2" "$R" "git push"
sello "$B" 0 0; pasa "HEAD:refs/heads/x → sha de HEAD" "$R" "git push origin HEAD:refs/heads/x"
pasa "+main quita el + (force) y sigue por sha" "$R" "git push origin +main"
sello "$WT" 0 0 wt; pasa "sello escrito desde el árbol principal vale en un worktree enlazado" "$T/repo-wt" "git push origin wt"

echo "RF-3 · comandos compuestos que mueven HEAD:"
sello "$B" 0 0
bloquea "git commit && git push (HEAD sellado) → 2" "$R" "git commit -m x && git push origin main"; cita "pide el push en un comando aparte" "comando aparte"
bloquea "git rebase main; git push → 2" "$R" "git rebase main; git push origin main"
bloquea "--all → 2 (una rama a la vez)" "$R" "git push --all origin"; cita "dice una rama a la vez" "una rama a la vez"
bloquea "--mirror → 2" "$R" "git push --mirror origin"
grep -q '"motivo": "varias-ramas"' "$LEDGER" && grep -q '"motivo": "mueve-head"' "$LEDGER" && ok "los bloqueos por --all y por mover HEAD dejan fila en el ledger" || { echo "  FALLA bloqueos sin fila en el ledger"; fallos=$((fallos+1)); }
printf 'head=%s\nrama=main\nbloquea=x\n' "$B" > "$SELLOS/$B"; bloquea "sello corrupto (bloquea= no numérico) → 2, nunca deja pasar" "$R" "git push origin main"; sello "$B" 0 0

echo "RF-4 · pases sin sello:"
sin_sello "$B"
pasa "--dry-run → 0" "$R" "git push --dry-run origin main"
pasa "--delete → 0" "$R" "git push origin --delete main"
pasa ":rama → 0" "$R" "git push origin :main"
pasa "sha ya contenido en el remoto (rama ya) → 0" "$R" "git push origin ya"
bloquea "tag a un commit que no está en el remoto ni sellado → 2" "$R" "git push origin v-nueva"; cita "explica que el tag empuja su commit" "tag"
pasa "tag a un commit ya en el remoto → 0" "$R" "git push origin v-vieja"

echo "RF-5 · escape explícito del usuario:"
pasa "KIT_SELLO=omitir git push → 0" "$R" "KIT_SELLO=omitir git push origin main"; ledger "ledger: omitido" omitido
bloquea "el escape solo vale como prefijo del push: en un comentario no cuenta → 2" "$R" "git push origin main # KIT_SELLO=omitir"
bloquea "ni en otro segmento (export …; git push) → 2" "$R" "export KIT_SELLO=omitir; git push origin main"

echo "RF-6 · falla abierto:"
err=$(printf 'no es json' | KIT_GATE_LEDGER="$LEDGER" bash "$HOOK" 2>&1 >/dev/null); rc=$?; [ $rc -eq 0 ] && ok "JSON roto → 0" || falla "JSON roto"
pasa "cwd fuera de un repo → 0" "$T" "git push origin main"
sello "$B" 0 0; err=$(KIT_GATE_LEDGER=/proc/no-se-puede/x bash "$HOOK" <<<"$(ev "$R" "git push origin main")" 2>&1 >/dev/null); rc=$?; [ $rc -eq 0 ] && ok "ledger no escribible + sello válido → 0" || falla "ledger no escribible + sello"
sin_sello "$B"; err=$(KIT_GATE_LEDGER=/proc/no-se-puede/x bash "$HOOK" <<<"$(ev "$R" "git push origin main")" 2>&1 >/dev/null); rc=$?; [ $rc -eq 2 ] && ok "ledger no escribible + sin sello → 2 (la decisión no cambia)" || falla "ledger no escribible sin sello"
err=$(printf '{"session_id":"s1","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"%s/notas-git-push.md"}}' "$R" "$R" | KIT_GATE_LEDGER="$LEDGER" bash "$HOOK" 2>&1 >/dev/null); rc=$?; [ $rc -eq 0 ] && ok "otra herramienta (Read) con 'git push' en el texto → 0" || falla "otra herramienta con git push en el texto"

echo "RF-7 · revisar exige timeout suficiente:"
bloquea "sello-push.sh revisar sin timeout → 2" "$R" "bash ~/.claude/scripts/sello-push.sh revisar"; cita "pide timeout 600000" "600000"
bloquea "con timeout 120000 → 2" "$R" "bash ~/.claude/scripts/sello-push.sh revisar" 120000
pasa "con timeout 600000 → 0" "$R" "bash ~/.claude/scripts/sello-push.sh revisar" 600000
pasa "run_in_background → 0" "$R" "bash ~/.claude/scripts/sello-push.sh revisar" "" bg
bloquea "forma con variable y default literal, sin timeout → 2" "$R" 'bash "${SELLO:-$HOME/.claude/scripts/sello-push.sh}" revisar'
pasa "otros subcomandos del helper no exigen timeout" "$R" "bash ~/.claude/scripts/sello-push.sh estado"
pasa "revisar sin timeout en un repo SIN gate → 0 (sin la llave el hook no toca nada)" "$T/libre" "bash ~/.claude/scripts/sello-push.sh revisar"

echo "RF-17 · sin nombres propios ni rutas de una máquina:"
[ "$(grep -ciE 'josé|jose' "$HOOK")" = 0 ] && ok "sin el nombre del dueño" || { echo "  FALLA nombre propio en el hook"; fallos=$((fallos+1)); }
[ "$(grep -c '/home/' "$HOOK")" = 0 ] && ok "sin rutas /home/" || { echo "  FALLA ruta de máquina en el hook"; fallos=$((fallos+1)); }
python3 -c 'import json,sys; [json.loads(l) for l in open(sys.argv[1])]' "$LEDGER" && ok "todas las líneas del ledger parsean" || { echo "  FALLA ledger con líneas ilegibles"; fallos=$((fallos+1)); }
g worktree remove --force "$T/repo-wt" 2>/dev/null; rm -rf "$T"; echo; [ $fallos -eq 0 ] && echo "TODO OK" || { echo "$fallos fallos"; exit 1; }
