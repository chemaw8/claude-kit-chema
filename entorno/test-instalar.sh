#!/usr/bin/env bash
# Pruebas aisladas: HOME temporal, PATH cerrado, sin red ni sudo real.
# Uso: bash entorno/test-instalar.sh
set -euo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 - "$RAIZ" <<'PY'
import json
import os
from pathlib import Path
import pty
import select
import shutil
import subprocess
import sys
import tempfile
import time
import unittest

RAIZ = Path(sys.argv[1])
ASISTENTE = RAIZ / "entorno/instalar.sh"
BASH = shutil.which("bash")

# Solo estos comandos del sistema son accesibles; los que instalan o usan la red
# se sustituyen incluso si existen en la máquina que corre la prueba.
MODELO = r'''import json, os, shutil, subprocess, sys
from pathlib import Path
nombre = Path(sys.argv[0]).name
a = sys.argv[1:]
home = Path(os.environ["HOME"])
with open(os.environ["TEST_LOG"], "a") as f:
    f.write(json.dumps([nombre, a]) + "\n")
fallo = os.environ.get("TEST_FALLO", "")
if fallo == nombre:
    sys.exit(9)
def instalar(comando):
    destino = home / ".local/bin" / comando
    destino.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(Path(os.environ["TEST_BIN"]) / "modelo", destino)
    destino.chmod(0o755)
def clonar(repo, destino, privado=False):
    destino = Path(destino)
    destino.mkdir(parents=True)
    (destino / ".git").mkdir()
    (destino / ".git/origin").write_text(repo)
    if privado:
        if fallo != "asistente-ausente":
            (destino / "asistente.sh").write_text(
                '#!/bin/bash\nprintf "%s\\n" "$$" > "$HOME/delegado-pid"\n'
                'printf "%s\\0" "$@" > "$HOME/delegado-args"\n'
                'exit "${TEST_PRIVADO_RC:-0}"\n')
    else:
        fuente = Path(os.environ["TEST_FUENTE"])
        for nombre in ("instalar.sh", "CHANGELOG.md", "nucleo", "skills", "agents",
                       "commands", "scripts", "hooks", "contexto"):
            origen = fuente / nombre
            if origen.is_dir(): shutil.copytree(origen, destino / nombre)
            else: shutil.copyfile(origen, destino / nombre)
        if fallo == "kit":
            (destino / "instalar.sh").write_text("exit 8\n")
if nombre == "sudo":
    if a and a[0] == "-n": a = a[1:]
    if not a or a[0] not in ("pacman", "apt-get", "dnf"):
        sys.exit(88)
    sys.exit(subprocess.run(a, stdin=subprocess.DEVNULL).returncode)
elif nombre in ("pacman", "apt-get", "dnf"):
    pass
elif nombre == "curl":
    destino = Path(a[a.index("-o") + 1])
    destino.write_text('cp "$TEST_BIN/modelo" "$UV_INSTALL_DIR/uv"\n'
                       'chmod +x "$UV_INSTALL_DIR/uv"\n')
    if fallo == "descarga-parcial":
        destino.write_text('touch "$HOME/descarga-ejecutada"\n')
        sys.exit(22)
elif nombre == "node":
    print(os.environ.get("TEST_NODE", "22"))
elif nombre == "npm":
    if a == ["--version"]: print("10.0.0")
    elif "@anthropic-ai/claude-code" in a: instalar("claude")
    elif "@earendil-works/pi-coding-agent@0.87.0" in a:
        if "--ignore-scripts" not in a: sys.exit(87)
        instalar("pi")
    else: sys.exit(86)
elif nombre == "uv":
    print("uv 0.8.0")
elif nombre == "pi":
    print("0.87.0")
elif nombre == "claude":
    if a == ["--version"]: print("2.0.0 (Claude Code)")
    elif a[:2] == ["auth", "status"]:
        bien = os.environ.get("TEST_CLAUDE_AUTH", "si") == "si" or (home / ".claude-login").exists()
        print(json.dumps({"loggedIn": bien}))
        sys.exit(0 if bien else 1)
    elif a[:2] == ["auth", "login"]: (home / ".claude-login").touch()
    else: sys.exit(85)
elif nombre == "git":
    if a[0] == "clone": clonar(a[-2], a[-1])
    elif a[0] == "-C":
        destino = Path(a[1])
        if not (destino / ".git/origin").is_file(): sys.exit(1)
        if a[2:] == ["rev-parse", "--show-toplevel"]: print(destino.resolve())
        elif a[2:] == ["remote", "get-url", "origin"]: print((destino / ".git/origin").read_text())
        else: sys.exit(84)
    else: sys.exit(83)
elif nombre == "gh":
    if a[:2] == ["auth", "status"]:
        print("MARCA_QUE_NO_DEBE_SALIR")
        sys.exit(0 if os.environ.get("TEST_GH_AUTH", "si") == "si" or (home / ".gh-login").exists() else 1)
    elif a[:2] == ["auth", "login"]: (home / ".gh-login").touch()
    elif a[:2] == ["repo", "clone"]:
        if os.environ.get("GH_PROMPT_DISABLED") != "1": sys.exit(80)
        clonar(a[2], a[3], True)
    else: sys.exit(82)
else:
    sys.exit(81)
'''

class Instalador(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix=".prueba-", dir=RAIZ / "entorno")
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.home = self.base / "casa con espacios"
        self.home.mkdir()
        self.bin = self.base / "bin"
        self.bin.mkdir()
        for cmd in ("bash", "sh", "python3", "mkdir", "mktemp", "rm", "chmod", "cp", "mv",
                    "dirname", "basename", "grep", "cut", "head", "tail", "awk", "tr", "sort", "cat", "seq"):
            (self.bin / cmd).symlink_to(shutil.which(cmd))
        modelo = self.bin / "modelo"
        modelo.write_text(f"#!{sys.executable}\n" + MODELO)
        modelo.chmod(0o755)
        for cmd in ("sudo", "apt-get", "curl", "git", "node", "npm", "gh"):
            (self.bin / cmd).symlink_to(modelo)
        self.log = self.base / "llamadas.jsonl"
        self.env = {"HOME": str(self.home), "PATH": str(self.bin), "SHELL": "/bin/bash",
                    "LC_ALL": "C.UTF-8", "TMPDIR": str(self.base), "TEST_BIN": str(self.bin),
                    "TEST_LOG": str(self.log), "TEST_FUENTE": str(RAIZ)}

    def corre(self, *args, rc=0):
        proceso = subprocess.Popen([BASH, str(ASISTENTE), *args], env=self.env,
                                   stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, start_new_session=True, text=True)
        try:
            salida, _ = proceso.communicate(timeout=30)
        except subprocess.TimeoutExpired:
            os.killpg(proceso.pid, 9)
            salida, _ = proceso.communicate()
            self.fail("El asistente no terminó en 30 segundos: " + salida)
        self.assertEqual(proceso.returncode, rc, salida)
        self.assertNotIn("MARCA_QUE_NO_DEBE_SALIR", salida)
        for linea in salida.splitlines():
            if linea.startswith("✗"):
                self.assertRegex(linea, r" \| Arreglo: \S+")
        self.salida = salida
        self.pid = proceso.pid
        return salida

    def llamadas(self, comando=None):
        filas = [json.loads(s) for s in self.log.read_text().splitlines()] if self.log.exists() else []
        return [a for n, a in filas if n == comando] if comando else filas

    def test_01_falta_tty(self):
        """Sin TTY aborta antes de modificar nada y explica --si."""
        self.assertIn("--si", self.corre(rc=2))
        self.assertIn("--si", self.corre("--dry-run", rc=2))
        self.assertEqual(list(self.home.iterdir()), [])
        self.assertEqual(self.llamadas(), [])

    def test_02_argumentos(self):
        """Rechaza flags, perfiles y repos inválidos sin instalar."""
        for args in (("--desconocido",), ("--perfil",), ("--perfil", "otro"), ("--perfil", ""),
                     ("--perfil", "completo"), ("--entorno", "ejemplo/repo"), ("--con-proyectos",),
                     ("--perfil", "completo", "--entorno", "ejemplo/.."),
                     ("--perfil", "completo", "--entorno", "https://github.com/ejemplo/repo"),
                     ("--perfil", "completo", "--entorno", "../repo")):
            self.corre("--si", *args, rc=2)
        self.assertEqual(self.llamadas(), [])
        self.assertEqual(list(self.home.iterdir()), [])

    def test_03_simulacro(self):
        """El simulacro completo no ejecuta comandos ni escribe HOME."""
        salida = self.corre("--si", "--dry-run", "--perfil", "completo", "--entorno", "ejemplo/repo")
        for texto in ("sudo", "uv", "@anthropic-ai/claude-code", "claude-entorno/asistente.sh", "--dry-run"):
            self.assertIn(texto, salida)
        self.assertEqual(self.llamadas(), [])
        self.assertEqual(list(self.home.iterdir()), [])

    def test_04_deteccion(self):
        """Detecta pacman, apt y dnf; rechaza un sistema desconocido."""
        (self.bin / "apt-get").unlink()
        self.corre("--si", "--dry-run", rc=2)
        for gestor, paquete in (("pacman", "github-cli"), ("apt-get", "python3"), ("dnf", "gh")):
            (self.bin / gestor).symlink_to(self.bin / "modelo")
            salida = self.corre("--si", "--dry-run")
            self.assertIn(gestor, salida)
            self.assertIn(paquete, salida)
            (self.bin / gestor).unlink()
        self.assertEqual(self.llamadas(), [])

    def test_05_colega_repetible(self):
        """Instala el kit real, conserva contexto y no duplica PATH ni clones."""
        self.corre("--si", "--perfil", "colega")
        self.assertNotIn("✗", self.salida)
        contexto = self.home / ".claude/contexto/CONTEXTO-EMPRESA.md"
        contexto.write_text("contexto de prueba que se conserva\n")
        ajustes = (self.home / ".claude/settings.json").read_bytes()
        perfil = (self.home / ".profile").read_bytes()
        self.corre("--si", "--perfil", "colega")
        self.assertEqual(contexto.read_text(), "contexto de prueba que se conserva\n")
        self.assertEqual(ajustes, (self.home / ".claude/settings.json").read_bytes())
        self.assertEqual(perfil, (self.home / ".profile").read_bytes())
        self.assertEqual(len([a for a in self.llamadas("git") if a[0] == "clone"]), 1)
        self.assertEqual(len(self.llamadas("curl")), 1)
        self.assertEqual(len([a for a in self.llamadas("npm") if a[0] == "i"]), 1)
        self.assertTrue((self.home / ".claude/commands/cierre.md").is_file())
        for a in self.llamadas("sudo"):
            self.assertIn(a[0], ("-n", "apt-get"))
            self.assertIn("apt-get", a)
        self.assertFalse((self.home / ".local/bin/pi").exists())

    def test_06_fallas_instalacion(self):
        """Una falla de paquetes, descarga, npm, git o kit corta la cadena."""
        for fallo in ("sudo", "apt-get", "descarga-parcial", "npm", "git", "kit"):
            with self.subTest(fallo=fallo):
                self.env["TEST_FALLO"] = fallo
                self.corre("--si", "--perfil", "completo", "--entorno", "ejemplo/repo", rc=1)
                self.assertIn("✗", self.salida)
                self.assertIn("Arreglo", self.salida)
                self.assertFalse((self.home / "descarga-ejecutada").exists())
                self.assertFalse((self.home / "delegado-args").exists())
                self.assertFalse(any(a[:2] == ["repo", "clone"] for a in self.llamadas("gh")))
                if fallo in ("sudo", "apt-get"):
                    self.assertEqual(self.llamadas("curl"), [])
                if fallo in ("sudo", "apt-get", "descarga-parcial", "npm"):
                    self.assertEqual(self.llamadas("git"), [])
                self.assertEqual(list(self.base.glob("tmp.*")), [])
                shutil.rmtree(self.home)
                self.home.mkdir()
                self.log.unlink(missing_ok=True)

    def test_07_destino_ajeno(self):
        """No ejecuta ni sobrescribe una carpeta ajena al kit."""
        destino = self.home / "Trabajo/proyectos/claude-kit-chema"
        destino.mkdir(parents=True)
        propio = destino / "instalar.sh"
        propio.write_text('touch "$HOME/no-debe-ejecutarse"\n')
        self.corre("--si", rc=1)
        self.assertIn("✗", self.salida)
        self.assertFalse((self.home / "no-debe-ejecutarse").exists())
        self.assertEqual(propio.read_text(), 'touch "$HOME/no-debe-ejecutarse"\n')

    def test_08_login_pendiente(self):
        """--si no abre logins y devuelve el arreglo del login pendiente."""
        self.env["TEST_CLAUDE_AUTH"] = "no"
        self.corre("--si", rc=1)
        self.assertIn("claude auth login", self.salida)
        self.assertNotIn(["auth", "login"], self.llamadas("claude"))

    def test_09_completo(self):
        """Completo delega con exec, la carpeta fija y los mismos flags."""
        args = ("--si", "--perfil", "completo", "--entorno", "ejemplo/repo", "--con-proyectos")
        self.env["TEST_PRIVADO_RC"] = "7"
        self.corre(*args, rc=7)
        self.assertEqual(int((self.home / "delegado-pid").read_text()), self.pid)
        recibidos = (self.home / "delegado-args").read_bytes().decode().split("\0")[:-1]
        self.assertEqual(recibidos, list(args))
        self.assertTrue((self.home / "Trabajo/proyectos/claude-entorno/asistente.sh").is_file())
        self.assertTrue(any(a[:3] == ["repo", "clone", "https://github.com/ejemplo/repo.git"] for a in self.llamadas("gh")))

    def test_10_github_sin_login(self):
        """Sin autenticación de GitHub no clona ni delega el perfil completo."""
        self.env["TEST_GH_AUTH"] = "no"
        self.corre("--si", "--perfil", "completo", "--entorno", "ejemplo/repo", rc=1)
        self.assertIn("gh auth login", self.salida)
        self.assertFalse((self.home / "delegado-args").exists())
        self.assertFalse(any(a[:2] == ["repo", "clone"] for a in self.llamadas("gh")))
        self.assertFalse(any(a[:2] == ["auth", "login"] for a in self.llamadas("gh")))

    def test_11_privado_incompleto(self):
        """Un clon privado sin asistente no pasa como instalación correcta."""
        self.env["TEST_FALLO"] = "asistente-ausente"
        self.corre("--si", "--perfil", "completo", "--entorno", "ejemplo/repo", rc=1)
        self.assertIn("✗", self.salida)
        self.assertIn("Arreglo", self.salida)
        self.assertFalse((self.home / "delegado-args").exists())

    def corre_tty(self, respuestas, *args, rc=0):
        pid, fd = pty.fork()
        if pid == 0:
            # El script entra por stdin; las respuestas solo existen en el TTY.
            orden = '"$TEST_PYTHON" -c \'import pathlib,sys; sys.stdout.write(pathlib.Path(sys.argv[1]).read_text())\' "$1" | bash -s -- "${@:2}"'
            env = dict(self.env, TEST_PYTHON=sys.executable)
            os.execve(BASH, [BASH, "-c", orden, "prueba", str(ASISTENTE), *args], env)
        salida = b""
        pendientes = [(p.encode(), (r + "\n").encode()) for p, r in respuestas]
        limite = time.monotonic() + 30
        estado = None
        recogido = False
        try:
            while time.monotonic() < limite:
                if select.select([fd], [], [], 0.1)[0]:
                    try: bloque = os.read(fd, 65536)
                    except OSError: break
                    if not bloque: break
                    salida += bloque
                    if pendientes and pendientes[0][0] in salida:
                        os.write(fd, pendientes.pop(0)[1])
                terminado, estado = os.waitpid(pid, os.WNOHANG)
                if terminado:
                    recogido = True
                    break
            else:
                os.killpg(pid, 9)
                self.fail("El asistente se bloqueó leyendo stdin o esperando una pregunta")
        finally:
            os.close(fd)
            if not recogido:
                _, estado = os.waitpid(pid, 0)
        texto = salida.decode(errors="replace")
        self.assertEqual(os.waitstatus_to_exitcode(estado), rc, texto)
        self.assertEqual(pendientes, [], texto)
        self.assertNotIn("MARCA_QUE_NO_DEBE_SALIR", texto)
        return texto

    def test_12_tty_y_pi(self):
        """Lee /dev/tty bajo una tubería e instala pi solo al aceptarlo."""
        self.corre_tty([("Perfil", "colega"), ("pi opcional", "s"), ("Continuar", "s")])
        self.assertTrue((self.home / ".local/bin/pi").is_file())
        self.assertTrue(any("--ignore-scripts" in a for a in self.llamadas("npm")))

    def test_13_cancelacion(self):
        """Cancelar desde el TTY no deja archivos ni llama instaladores."""
        salida = self.corre_tty([("Perfil", ""), ("pi opcional", "n"), ("Continuar", "n")])
        self.assertIn("Cancelado sin cambios", salida)
        self.assertEqual(self.llamadas(), [])
        self.assertEqual(list(self.home.iterdir()), [])

    def test_14_logins_guiados(self):
        """Guía ambos logins por TTY y transmite el repo respondido."""
        self.env.update(TEST_CLAUDE_AUTH="no", TEST_GH_AUTH="no")
        salida = self.corre_tty([("Perfil", "completo"), ("Repositorio", "ejemplo/.entorno"),
                                ("pi opcional", "n"), ("Continuar", "s"),
                                ("¿Abrir el login de Claude", "s"), ("¿Abrir el login de GitHub", "s")])
        self.assertNotIn("✗", salida)
        recibidos = (self.home / "delegado-args").read_bytes().decode().split("\0")[:-1]
        self.assertEqual(recibidos, ["--perfil", "completo", "--entorno", "ejemplo/.entorno"])
        self.assertTrue((self.home / ".claude-login").is_file())
        self.assertTrue((self.home / ".gh-login").is_file())

    def test_15_repositorio_incorrecto(self):
        """Rechaza un origin distinto aunque la carpeta tenga instalador."""
        self.corre("--si")
        origen = self.home / "Trabajo/proyectos/claude-kit-chema/.git/origin"
        origen.write_text("https://github.com/ejemplo/otro.git")
        self.log.unlink()
        self.corre("--si", rc=1)
        self.assertIn("origin del clon no corresponde", self.salida)
        self.assertIn("respaldo=$(mktemp", self.salida)
        self.assertNotIn("núcleo:", self.salida)
        self.assertEqual(origen.read_text(), "https://github.com/ejemplo/otro.git")

    def test_16_completo_repetible(self):
        """Reutiliza el clon privado y permite al asistente privado guiar Claude."""
        args = ("--si", "--perfil", "completo", "--entorno", "ejemplo/repo")
        self.corre(*args)
        self.env["TEST_CLAUDE_AUTH"] = "no"
        self.corre(*args)
        self.assertIn("✗ | Login de Claude Code | Arreglo: claude auth login", self.salida)
        self.assertTrue((self.home / "delegado-args").is_file())
        self.assertEqual(len([a for a in self.llamadas("gh") if a[:2] == ["repo", "clone"]]), 1)
        self.assertEqual(int((self.home / "delegado-pid").read_text()), self.pid)

    def test_17_node_insuficiente(self):
        """Node incompatible se reporta antes de instalar paquetes npm."""
        self.env["TEST_NODE"] = "16"
        self.corre("--si", rc=1)
        self.assertIn("node@22", self.salida)
        self.assertEqual(self.llamadas("npm"), [])

    def test_18_path_otras_shells(self):
        """Persiste PATH en fish y zsh sin duplicar ni borrar contenido."""
        for shell, ruta in (("fish", ".config/fish/conf.d/kit-chema-entorno.fish"), ("zsh", ".zshrc")):
            self.env["SHELL"] = "/bin/" + shell
            archivo = self.home / ruta
            archivo.parent.mkdir(parents=True, exist_ok=True)
            archivo.write_text("# contenido propio\n")
            self.corre("--si")
            primero = archivo.read_text()
            self.corre("--si")
            self.assertEqual(archivo.read_text(), primero)
            self.assertIn("# contenido propio\n", primero)
            self.assertIn(".local/bin", primero)

    def test_19_paquetes_otras_distros(self):
        """Las instalaciones con pacman y dnf también llegan al semáforo verde."""
        (self.bin / "apt-get").unlink()
        for gestor in ("pacman", "dnf"):
            (self.bin / gestor).symlink_to(self.bin / "modelo")
            self.corre("--si")
            self.assertNotIn("✗", self.salida)
            self.assertTrue(self.llamadas(gestor))
            (self.bin / gestor).unlink()

    def test_20_sudo_ausente(self):
        """Si falta sudo, muestra el comando para instalarlo como administrador."""
        (self.bin / "sudo").unlink()
        self.corre("--si", rc=1)
        self.assertIn("su -c", self.salida)
        self.assertEqual(self.llamadas(), [])
        self.assertEqual(list(self.home.iterdir()), [])

suite = unittest.defaultTestLoader.loadTestsFromTestCase(Instalador)
resultado = unittest.TextTestRunner(verbosity=2).run(suite)
print("Pruebas entorno: todo en verde" if resultado.wasSuccessful() else "Pruebas entorno: hay fallas")
sys.exit(0 if resultado.wasSuccessful() else 1)
PY
