#!/usr/bin/env python3
"""Ficha de economía por unidad, revisada por código (kit-modelo-negocio).

Lee un JSON con el precio y los costos de UNA unidad (cliente, línea, bici…) y calcula, sin redondeos intermedios:
precio sin impuesto, contribución por unidad, precio de equilibrio por unidad y, si hay churn, valor de vida (CLTV) y
meses para recuperar el costo de adquisición. Falla (código 1) en los errores que más se repitieron en los casos
dorados:

  E1  el precio no dice si trae IVA («iva_incluido» obligatorio: true/false)
  E2  una comisión sin «recurrente» declarado (true = cada cobro; false = solo el alta)
  E3  un costo sin «fuente» (de dónde sale)
  E4  merma, robo o pérdida declarada en el insumo y no incluida como costo («merma_pct» sin usar)
  E5  contribución negativa presentada como viable («viable»: true con contribución ≤ 0)

Uso: python3 economia_unitaria.py ficha.json [--json]
Formato (pesos; los costos van SIN IVA):
{
  "unidad": "bici activa al mes",
  "precio": 799, "iva_incluido": true, "iva": 0.16,
  "costos": [{"concepto": "depreciación", "monto": 604.17, "fuente": "costos-operacion.md"}],
  "comisiones": [{"concepto": "plataforma", "pct": 0.12, "recurrente": true, "fuente": "contrato §2"}],
  "merma_pct": 0.015, "valor_unidad": 14500,                  (opcional: pérdida mensual sobre el valor del activo)
  "churn_mensual": 0.082, "cac": 900,                          (opcional: CLTV y recuperación)
  "viable": false                                              (opcional: lo que el entregable afirma)
}
"""
import argparse
import json
import sys


def revisar(f):
    errores, avisos = [], []
    if "iva_incluido" not in f or not isinstance(f.get("iva_incluido"), bool):
        errores.append(("E1", "el precio no dice si trae IVA: pon \"iva_incluido\": true o false"))
    iva = f.get("iva", 0.16)
    precio = float(f.get("precio", 0))
    neto = precio / (1 + iva) if f.get("iva_incluido") else precio
    costos = 0.0
    for c in f.get("costos", []):
        if not c.get("fuente"):
            errores.append(("E3", f"el costo «{c.get('concepto')}» no dice de dónde sale («fuente»)"))
        costos += float(c.get("monto", 0))
    pct_com, pct_alta = 0.0, 0.0
    for c in f.get("comisiones", []):
        if not isinstance(c.get("recurrente"), bool):
            errores.append(("E2", f"la comisión «{c.get('concepto')}» no dice si se cobra en cada cobro o solo en el alta"))
        if not c.get("fuente"):
            errores.append(("E3", f"la comisión «{c.get('concepto')}» no dice de dónde sale («fuente»)"))
        if c.get("recurrente") is True:
            pct_com += float(c.get("pct", 0))
        elif c.get("recurrente") is False:
            pct_alta += float(c.get("pct", 0))
    merma = 0.0
    if f.get("merma_pct") is not None:
        if f.get("valor_unidad") is None:
            errores.append(("E4", "hay «merma_pct» pero falta «valor_unidad»: la pérdida no entra al costo"))
        else:
            merma = float(f["merma_pct"]) * float(f["valor_unidad"])
    comision = pct_com * neto
    contribucion = neto - comision - costos - merma
    # equilibrio por unidad (sin fijos): neto × (1 − pct_com) = costos + merma
    eq_neto = (costos + merma) / (1 - pct_com) if pct_com < 1 else float("inf")
    eq_publico = eq_neto * (1 + iva) if f.get("iva_incluido") else eq_neto
    r = {"unidad": f.get("unidad"), "precio_sin_iva": round(neto, 2), "comision_recurrente": round(comision, 2),
         "costos": round(costos, 2), "merma": round(merma, 2), "contribucion": round(contribucion, 2),
         "precio_equilibrio": round(eq_publico, 2), "precio_equilibrio_con_iva": bool(f.get("iva_incluido")),
         "comision_alta": round(pct_alta * neto, 2)}
    ch = f.get("churn_mensual")
    if ch:
        r["cltv"] = round(contribucion / float(ch), 2)
    if f.get("cac") or pct_alta:
        cac = float(f.get("cac") or 0) + pct_alta * neto              # la comisión de alta se suma al costo de adquirir
        r["cac_total"] = round(cac, 2)
        r["meses_recuperar_cac"] = round(cac / contribucion, 1) if contribucion > 0 else None
        if contribucion <= 0:
            avisos.append(("A1", "con contribución ≤ 0 el costo de adquisición nunca se recupera"))
    if f.get("viable") is True and contribucion <= 0:
        errores.append(("E5", f"se presenta como viable con contribución de {contribucion:,.2f} por {f.get('unidad') or 'unidad'}"))
    return r, errores, avisos


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("ficha")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args(argv)
    try:
        f = json.loads(open(a.ficha, encoding="utf-8").read())
    except (OSError, ValueError) as e:
        print(f"no se pudo leer la ficha: {e}")
        return 2
    r, errores, avisos = revisar(f)
    if a.json:
        print(json.dumps({**r, "errores": errores, "avisos": avisos}, ensure_ascii=False, indent=1))
    else:
        print(f"{r['unidad'] or 'unidad'}: precio sin IVA ${r['precio_sin_iva']:,.2f} · contribución ${r['contribucion']:,.2f} · "
              f"equilibrio ${r['precio_equilibrio']:,.2f} {'con IVA' if r['precio_equilibrio_con_iva'] else 'sin IVA'}"
              + (f" · CLTV ${r['cltv']:,.2f}" if "cltv" in r else "")
              + (f" · CAC ${r['cac_total']:,.2f} (comisión de alta ${r['comision_alta']:,.2f})" if "cac_total" in r else "")
              + (f" · recupera en {r['meses_recuperar_cac']} meses" if r.get("meses_recuperar_cac") else ""))
        for c, m in errores:
            print(f"  ✗ {c} {m}")
        for c, m in avisos:
            print(f"  ! {c} {m}")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
