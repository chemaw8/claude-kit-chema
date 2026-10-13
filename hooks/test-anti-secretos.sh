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

# 4b. un archivo binario nuevo no debe cegar el escaneo del resto
nuevo_repo; printf 'k=%s\n' "$SECRETO" > "$t/r/nuevo.txt"; printf 'a\0b\0c' > "$t/r/img.bin"
espera 2 "git add -A && git commit -m x" "un binario sin rastrear no debe ocultar el secreto de otro archivo"

# 4c. `git -C <ruta> commit -a` y `git -c x=y commit -a`: el repo es el de -C, no el directorio actual
nuevo_repo; mkdir -p "$t/r/sub"; git -C "$t/r/sub" init -q; printf 'x=1\n' > "$t/r/sub/a.txt"
git -C "$t/r/sub" add -A; git -C "$t/r/sub" commit -qm base; printf 'k=%s\n' "$SECRETO" >> "$t/r/sub/a.txt"
espera 2 "git -C sub commit -am x" "git -C ruta commit -am"
nuevo_repo; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"
espera 2 "git -c user.name=x commit -a -m x" "git -c x=y commit -a"
# 4e. `git -C ~/…`: se expande; una ruta que no existe bloquea en vez de escanear otro repo
mkdir -p "$t/home"; rm -rf "$t/home/r"; cp -r "$t/r" "$t/home/r"
rc=$(cd / && printf '%s' '{"tool_input":{"command":"git -C ~/r commit -am x"}}' | HOME="$t/home" bash "$HOOK" >/dev/null 2>&1; echo $?)
[ "$rc" = 2 ] || fallo "git -C ~/ruta commit -am con secreto (esperaba 2, dio $rc)"
git -C "$t/home/r" checkout -q -- . 2>/dev/null   # el mismo repo limpio: si ~ se expande, el hook lo encuentra y deja pasar
rc=$(cd / && printf '%s' '{"tool_input":{"command":"git -C ~/r commit -am x"}}' | HOME="$t/home" bash "$HOOK" >/dev/null 2>&1; echo $?)
[ "$rc" = 0 ] || fallo "git -C ~/ruta limpio debe pasar: ~ se expande al repo (dio $rc)"
espera 2 "git -C /no/existe commit -m x" "git -C con ruta inexistente debe bloquear"

# 4e-bis. --git-dir / --work-tree: no se sabe qué repo revisar → bloquea
espera 2 "git --git-dir=/otro/.git commit -am x" "git --git-dir= debe bloquear"
espera 2 "git --work-tree /otro commit -m x" "git --work-tree debe bloquear"

# 4f. un archivo nuevo grande con el secreto al final (antes solo se leían 2 MB)
nuevo_repo; { seq 1 600000; printf 'k=%s\n' "$SECRETO"; } > "$t/r/grande.log"
espera 2 "git add -A && git commit -m x" "secreto al final de un archivo nuevo de más de 2 MB"

# 4d. el hook corre en una subcarpeta y el archivo nuevo está en la raíz
nuevo_repo; mkdir -p "$t/r/sub"; : > "$t/r/sub/.keep"; printf 'k=%s\n' "$SECRETO" > "$t/r/x.txt"
rc=$(cd "$t/r/sub" && printf '%s' '{"tool_input":{"command":"git add -A && git commit -m x"}}' | bash "$HOOK" >/dev/null 2>&1; echo $?)
[ "$rc" = 2 ] || fallo "desde una subcarpeta, un archivo nuevo en la raíz con secreto (esperaba 2, dio $rc)"

# 4g. un enlace roto sin rastrear no debe apagar el escaneo de los archivos nuevos (grep rc 2, xargs rc 123)
nuevo_repo; printf 'k=%s\n' "$SECRETO" > "$t/r/nuevo.txt"; ln -s /no/existe "$t/r/roto"
espera 2 "git add -A && git commit -m x" "un enlace roto no debe ocultar el secreto de un archivo nuevo"

# 4g-bis. `cd <repo> && git commit -am`: el repo es el del cd, no el directorio del hook
nuevo_repo; mkdir -p "$t/otro"; rm -rf "$t/otro/r"; cp -r "$t/r" "$t/otro/r"; printf 'k=%s\n' "$SECRETO" >> "$t/otro/r/a.txt"
espera 2 "cd $t/otro/r && git commit -am x" "cd <repo> && git commit -am con secreto"

# 4g-ter. `cd` sin argumento va a HOME (no toma «&&» como carpeta); un HOME limpio deja pasar
nuevo_repo; mkdir -p "$t/home"; rm -rf "$t/home/.git"; git -C "$t/home" init -q
rc=$(cd "$t/r" && printf '%s' '{"tool_input":{"command":"cd && git commit -m x"}}' | HOME="$t/home" bash "$HOOK" >/dev/null 2>&1; echo $?)
[ "$rc" = 0 ] || fallo "cd sin argumento a un HOME limpio debe pasar (dio $rc)"
rm -rf "$t/home/.git"

# 4g-cuater. separadores pegados, subshell y GIT_DIR=
nuevo_repo; mkdir -p "$t/p"; rm -rf "$t/p/r"; cp -r "$t/r" "$t/p/r"
rc=$(cd "$t/p" && printf '%s' '{"tool_input":{"command":"cd r; git commit -m x"}}' | bash "$HOOK" >/dev/null 2>&1; echo $?)
[ "$rc" = 0 ] || fallo "cd r; git commit (separador pegado) a un repo limpio debe pasar (dio $rc)"
printf 'k=%s\n' "$SECRETO" >> "$t/p/r/a.txt"
espera 2 "(cd $t/p/r && git commit -am x)" "subshell (cd X && git commit -am) con secreto"
espera 2 "GIT_DIR=/otro/.git git commit -m x" "GIT_DIR= debe bloquear"
nuevo_repo
espera 2 "GIT_DIR=/otro/.git git -C $t/r commit -m x" "GIT_DIR= no se borra con un -C absoluto posterior"
espera 2 "git --git-dir=/otro/.git -C $t/r commit -m x" "--git-dir no se borra con un -C absoluto posterior"

# 4g-quinto. el cd de una subshell no sale de ella; el mensaje de bloqueo no ejecuta nada
nuevo_repo; mkdir -p "$t/limpio"; git -C "$t/limpio" init -q; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"; git -C "$t/r" add a.txt
espera 2 "(cd $t/limpio && true) && git commit -m x" "(cd otro && …) && git commit: el commit es en el actual"
msg=$(cd "$t/r" && printf '%s' '{"tool_input":{"command":"cd - && git commit -m x"}}' | bash "$HOOK" 2>&1 >/dev/null)
case "$msg" in *"command not found"*|*"orden no encontrada"*) fallo "el mensaje de bloqueo ejecutó una sustitución de comando";; esac
case "$msg" in *'cd $(…)'*) ;; *) fallo "el mensaje de bloqueo debe mostrar «cd \$(…)» literal";; esac

# 4g-sexto. `git -C $(…)` sin comillas: repo incierto → bloquea; el mensaje con heredoc entre comillas sí pasa
nuevo_repo
espera 2 'git -C $(git rev-parse --show-toplevel) commit -am x' "git -C \$(…) sin comillas debe bloquear"
espera 0 "git commit -m \"\$(cat <<'EOF'
mensaje largo
EOF
)\"" "mensaje con heredoc entre comillas en un repo limpio debe pasar"

# 4g-séptimo. pushd como cd; --git-dir sin commit no bloquea
nuevo_repo; rm -rf "$t/pp"; cp -r "$t/r" "$t/pp"; printf 'k=%s\n' "$SECRETO" >> "$t/pp/a.txt"
espera 2 "pushd $t/pp && git commit -am x" "pushd X && git commit -am con secreto"
espera 0 "git --git-dir=/x/.git cat-file commit HEAD" "--git-dir sin git commit no debe bloquear"

# 4h. commit con rutas explícitas: toma esas rutas del árbol de trabajo, no del índice
nuevo_repo; printf 'k=%s\n' "$SECRETO" >> "$t/r/a.txt"
espera 2 "git commit a.txt -m x" "git commit <ruta> con secreto sin preparar"
espera 2 "git commit -m x -- a.txt" "git commit -- <ruta> con secreto sin preparar"

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
