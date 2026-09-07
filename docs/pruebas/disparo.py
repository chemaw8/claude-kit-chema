#!/usr/bin/env python3
"""Gate de disparo (docs/pruebas/RUNBOOK.md): un juez Sonnet con contexto fresco recibe SOLO los pares
nombre+description de las skills y UNA petición del banco, y dice qué skill cargaría (o 'ninguna').
Uso: python3 docs/pruebas/disparo.py [--banco docs/pruebas/banco/disparo.md] [--paralelo 6] [--modelo sonnet]
Criterio: ≥ 19/21 del núcleo y cero confusiones nuevas en las fronteras (ver RUNBOOK). Gasta cuota (~29 llamadas cortas)."""
import concurrent.futures, json, os, re, subprocess, sys, tempfile
AQUI = os.path.dirname(os.path.abspath(__file__)); KIT = os.path.dirname(os.path.dirname(AQUI))
a = sys.argv[1:]
def opt(n, d=None): return a[a.index(n) + 1] if n in a and a.index(n) + 1 < len(a) else d
banco, paralelo, modelo = opt("--banco", os.path.join(AQUI, "banco", "disparo.md")), int(opt("--paralelo", 6)), opt("--modelo", "sonnet")
skills = {}
for d in sorted(os.listdir(os.path.join(KIT, "skills"))):
    p = os.path.join(KIT, "skills", d, "SKILL.md")
    if os.path.isfile(p):
        m = re.search(r"^description:\s*(.*)$", open(p, encoding="utf-8").read(), re.M)
        if m: skills[d] = m.group(1).strip().strip("'\"")
filas = []
for l in open(banco, encoding="utf-8"):
    c = [x.strip() for x in l.strip().strip("|").split("|")]
    if len(c) >= 4 and c[0].isdigit(): filas.append({"n": int(c[0]), "peticion": c[1], "esperada": c[2], "frontera": c[3]})
sistema = ("Eres el enrutador de skills de Claude Code. Te doy las skills instaladas (nombre: description) y una petición del usuario. "
           "Responde ÚNICAMENTE con el nombre exacto de la skill que cargarías, o la palabra ninguna. Sin explicaciones.\n\n" +
           "\n".join(f"- {k}: {v}" for k, v in skills.items()))
tmp = tempfile.mkdtemp(prefix="disparo-"); mcp = os.path.join(tmp, "mcp.json"); open(mcp, "w").write('{"mcpServers":{}}')
def juez(f):
    argv = ["claude", "-p", "--model", modelo, "--tools", "", "--output-format", "json", "--no-session-persistence", "--setting-sources", "",
            "--strict-mcp-config", "--mcp-config", mcp, "--system-prompt", sistema]
    try:
        r = subprocess.run(argv, input=f"Petición: {f['peticion']}", capture_output=True, text=True, timeout=120, cwd=tmp)
        res = json.loads(r.stdout).get("result", "") if r.returncode == 0 else f"error rc {r.returncode}"
    except Exception as e: res = f"error {type(e).__name__}"
    m = re.search(r"kit-[a-z]+(?:-[a-z]+)*|ninguna", str(res)); return {**f, "juez": m.group(0) if m else str(res)[:40]}
with concurrent.futures.ThreadPoolExecutor(paralelo) as ex: res = list(ex.map(juez, filas))
nucleo = [r for r in res if r["n"] <= 21]; ok_n = sum(1 for r in nucleo if r["juez"] == r["esperada"])
front = [r for r in res if r["frontera"].startswith("sí") or r["n"] > 21]
conf = [r for r in front if r["juez"] != r["esperada"] and not r["frontera"].endswith("benigna)")]
print(f"juez {modelo} · {len(skills)} skills · {len(filas)} peticiones")
print(f"| # | petición | esperada | juez | frontera? |\n|---|---|---|---|---|")
for r in res: print(f"| {r['n']} | {r['peticion'][:70]} | {r['esperada']} | {'✓ ' if r['juez']==r['esperada'] else '✗ '}{r['juez']} | {r['frontera']} |")
print(f"\nnúcleo: {ok_n}/{len(nucleo)} (criterio ≥ 19/21) · confusiones de frontera no benignas: {len(conf)}")
for r in conf: print(f"  ✗ #{r['n']} esperaba {r['esperada']}, el juez dijo {r['juez']}")
pasa = ok_n >= 19 and not conf
print("GATE DE DISPARO:", "PASA" if pasa else "FALLA"); sys.exit(0 if pasa else 1)
