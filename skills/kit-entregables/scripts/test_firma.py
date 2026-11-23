"""kit-entregables: verificador determinista. Textos INVENTADOS aquí, no entregables de clientes."""
import sys, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent)); sys.dont_write_bytecode = True
import firma as F

BUENA = [
    {"titulo": "Cerrar la tienda X ahorra $1.2 M al año sin perder clientes", "cuerpo": "La tienda X pierde $100 mil al mes. El 80 % de sus clientes compra también en la tienda Y, a 2 km."},
    {"titulo": "Cuatro datos deciden si el caso se sostiene", "cuerpo": "Costo de cierre. Contrato de renta. Traspaso de clientes. Plantilla."},
    {"titulo": "Pedimos aprobar el cierre el 15 de enero y medir el traspaso 3 meses", "cuerpo": "Responsable: Operaciones. Fecha: 2027-01-15."},
    {"titulo": "De dónde sale cada cifra", "cuerpo": "$100 mil al mes: estado de resultados 2026. 80 %: base de clientes."},
]


class Presentacion(unittest.TestCase):
    def test_buena_pasa(self):
        r = F.revisar_presentacion(BUENA)
        self.assertEqual([x for x in r if x["gravedad"] == "alta"], [], r)

    def test_titulo_tema_falla(self):
        r = F.revisar_presentacion([{"titulo": "Contexto", "cuerpo": "x"}] + BUENA[1:])
        self.assertIn("titulo_conclusion", [x["regla"] for x in r])

    def test_lamina_cargada_falla(self):
        r = F.revisar_presentacion([{"titulo": BUENA[0]["titulo"], "cuerpo": "palabra " * 90}] + BUENA[1:])
        self.assertIn("una_idea", [x["regla"] for x in r])

    def test_sin_origen_de_cifras_ni_peticion(self):
        reglas = [x["regla"] for x in F.revisar_presentacion(BUENA[:2])]
        self.assertIn("origen_cifras", reglas); self.assertIn("peticion", reglas)

    def test_casos_del_sello(self):
        self.assertIsNotNone(F.titulo_ok("Visión general de la empresa"))
        r = F.revisar_presentacion([{"titulo": "Las fuentes de ingreso caen 20 %", "cuerpo": "p " * 200}])
        self.assertIn("una_idea", [x["regla"] for x in r]); self.assertIn("origen_cifras", [x["regla"] for x in r])
        r = F.revisar_presentacion(BUENA[:2] + [{"titulo": "Pasos que siguen el próximo trimestre", "cuerpo": "Responsable: por definir"}] + BUENA[3:])
        self.assertIn("peticion", [x["regla"] for x in r])

    def test_mas_casos_del_sello(self):
        self.assertIsNotNone(F.titulo_ok("Ingeniería de datos del área"))
        F.revisar_presentacion([{"titulo": None, "cuerpo": None}])   # no revienta
        import io, json, contextlib
        for fmt, rc in (("presentación", 0), ("documento", 0), ("otra", 1)):
            sys.stdin = io.StringIO(json.dumps({"formato": fmt, "laminas": [], "texto": ""}))
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(F.main(), rc, fmt)
        sys.stdin = sys.__stdin__

    def test_etiqueta_mas_subtitulo_conclusion(self):
        self.assertIsNone(F.titulo_ok(F.titulo_efectivo("Quiénes somos", "Operamos 8 años y duplicamos la base de clientes")))
        self.assertIsNotNone(F.titulo_ok(F.titulo_efectivo("Quiénes somos", "Nuestra historia")))

    def test_ingles(self):
        deck = [{"titulo": "Base case: ~$107M a year in revenue", "cuerpo": "x"},
                {"titulo": "Four facts decide whether the case holds", "cuerpo": "x"},
                {"titulo": "Start with phase 1; decide on phase 2 by March 15", "cuerpo": "We ask to approve the pilot. Responsible: Ops."},
                {"titulo": "Every figure, where it comes from", "cuerpo": "x"}]
        self.assertEqual([x for x in F.revisar_presentacion(deck) if x["gravedad"] == "alta"], [])
        self.assertIsNotNone(F.titulo_ok("Overview"))
        self.assertIsNone(F.titulo_ok("Margin grows next year"))   # 4 palabras: pasa por el verbo inglés
        self.assertTrue(F.FECHA.search("decide by 15 March"))
        self.assertTrue(F.relleno("It is important to note that this plays a key role and is a game-changer."))

    def test_muletillas_de_relleno(self):
        r = F.revisar_presentacion([{"titulo": BUENA[0]["titulo"], "cuerpo": "Es importante destacar que juega un papel clave. En resumen, es fundamental y crucial."}] + BUENA[1:])
        self.assertIn("relleno", [x["regla"] for x in r])


DOC_BUENO = """# Cerrar la tienda X ahorra $1.2 M al año

**Recomendación:** cerrar la tienda X el 2027-01-15; Operaciones mide el traspaso de clientes durante 3 meses.

## Por qué
La tienda X pierde $100 mil al mes desde marzo. El 80 % de sus clientes compra también en la tienda Y.

## Supuestos y alternativas
Usé el estado de resultados 2026; con el presupuesto la pérdida sería $80 mil al mes.

## Lo que no se puede concluir
Con seis meses de datos no se sabe si la caída es de temporada.

## De dónde sale cada cifra
$100 mil: estado de resultados 2026. 80 %: base de clientes.
"""


class Documento(unittest.TestCase):
    def test_bueno_pasa(self):
        self.assertEqual([x for x in F.revisar_documento(DOC_BUENO) if x["gravedad"] == "alta"], [])

    def test_sin_conclusion_arriba(self):
        r = F.revisar_documento("# Análisis\n\nEn este documento se presenta el contexto del proyecto.\n\n" + DOC_BUENO)
        self.assertIn("conclusion_primero", [x["regla"] for x in r])

    def test_sin_secciones_obligatorias(self):
        reglas = [x["regla"] for x in F.revisar_documento("# Cerrar X ahorra $1 M\n\n**Recomendación:** cerrar X el 2027-01-15.\n")]
        self.assertIn("supuestos", reglas); self.assertIn("no_concluir", reglas); self.assertIn("origen_cifras", reglas)

    def test_largo(self):
        self.assertIn("largo", [x["regla"] for x in F.revisar_documento(DOC_BUENO + ("palabra " * 3500))])



class Estructuras(unittest.TestCase):
    def test_catalogo_cargado(self):
        self.assertGreaterEqual(len(F.ESTRUCTURAS), 9)

    def test_orden_correcto_pasa_y_desordenado_falla(self):
        bien = "# Cerrar X ahorra $1 M\n\n## Problema\nx\n## Costo de no actuar\nx\n## Solución\nx\n## Prueba\nx\n## Inversión\n$1 M\n## Siguiente paso\nOps, 2027-01-15\n"
        self.assertEqual(F.revisar_estructura(bien, "propuesta-b2b"), [])
        mal = bien.replace("## Solución\nx\n", "").replace("## Problema", "## Solución\nx\n## Problema")
        self.assertIn("orden", [x["regla"] for x in F.revisar_estructura(mal, "propuesta-b2b")])

    def test_falta_seccion(self):
        r = F.revisar_estructura("# T\n\n## Problema\nx\n", "propuesta-b2b")
        self.assertIn("seccion_faltante", [x["regla"] for x in r])

    def test_challenger_no_muestra_el_producto_antes(self):
        t = "# T\n## Lo que sabemos de su industria\n## Nuestra solución\n## El problema visto de otra forma\n## Lo que cuesta\n## Lo que significa para alguien como usted\n## Una forma nueva\n"
        self.assertIn("orden", [x["regla"] for x in F.revisar_estructura(t, "propuesta-challenger")])

    def test_estatus_con_cifras_no_exige_seccion_de_origen(self):
        t = "# Vamos al 80 % del plan\n\n## Conclusión\nRecomendación: seguir; pedimos aprobar el presupuesto el 2027-01-15.\n## Semáforo\nverde\n## Logros\n3 de 4 frentes\n## Riesgos\nninguno\n## Decisiones pedidas\naprobar presupuesto\n## Siguientes pasos\nOps 2027-01-15\n"
        import io, json, contextlib
        sys.stdin = io.StringIO(json.dumps({"estructura": "estatus", "texto": t})); buf = io.StringIO()
        with contextlib.redirect_stdout(buf): F.main()
        sys.stdin = sys.__stdin__
        self.assertNotIn("origen_cifras", buf.getvalue())

    def test_conclusion_en_la_plantilla_y_cli_con_archivo(self):
        import tempfile, io, json, contextlib
        base = F.plantilla("informe-decision")
        marca = "{{Qué hacer, quién y para cuándo. Una o dos oraciones.}}"
        self.assertIn(marca, base)
        # positivo: la recomendación pegada a su encabezado SÍ cuenta (antes se saltaba el bloque)
        bueno = base.replace(marca, "Recomendamos cerrar la tienda X el 2027-01-15; responsable Operaciones.")
        self.assertNotIn("conclusion_primero", [x["regla"] for x in F.revisar_documento(bueno)])
        t = base.replace(marca, "El mercado se mueve rápido.")
        self.assertIn("conclusion_primero", [x["regla"] for x in F.revisar_documento(t)])
        d = tempfile.TemporaryDirectory(); self.addCleanup(d.cleanup)
        ruta = d.name + "/e.md"
        with open(ruta, "w") as f: f.write(t)
        f = type("F", (), {"name": ruta})
        viejo = sys.argv; sys.argv = ["firma.py", "--estructura", "informe-decision", f.name]; buf = io.StringIO()
        try:
            with contextlib.redirect_stdout(buf): self.assertEqual(F.main(), 0)
        finally: sys.argv = viejo; sys.stdin = sys.__stdin__
        self.assertIn("conclusion_primero", buf.getvalue())

    def test_academico_no_exige_recomendacion_arriba(self):
        import io, json, contextlib
        t = F.plantilla("academico").replace("{{Pregunta, método, resultado y conclusión.}}", "Medimos X en 40 muestras; Y aumentó 12 %.")
        sys.stdin = io.StringIO(json.dumps({"estructura": "academico", "texto": t})); buf = io.StringIO()
        with contextlib.redirect_stdout(buf): F.main()
        sys.stdin = sys.__stdin__
        self.assertNotIn("conclusion_primero", buf.getvalue())

    def test_brief_con_referencias_y_mensajes_descriptivos(self):
        import io, json, contextlib
        t = ("# La tasa de abandono cayó 12 % en 2026\n\n## Mensajes clave\nLa tasa cayó 12 % en el año.\n## Problema\nx\n## Hallazgos\nx\n"
             "## Opciones\nx\n## Recomendaciones\nOps, 2027-01-15\n## Referencias\nEncuesta 2026.\n")
        sys.stdin = io.StringIO(json.dumps({"estructura": "brief", "texto": t})); buf = io.StringIO()
        with contextlib.redirect_stdout(buf): F.main()
        sys.stdin = sys.__stdin__
        self.assertNotIn("origen_cifras", buf.getvalue()); self.assertNotIn("conclusion_primero", buf.getvalue())

    def test_estatus_con_su_propia_guia(self):
        t = F.plantilla("estatus").replace("{{En una o dos oraciones: cómo va y qué se pide.}}", "Vamos en verde; se pide ampliar el plazo al 2027-01-15.")
        self.assertNotIn("conclusion_primero", [x["regla"] for x in F.revisar_documento(t)])

    def test_council_texto_tecnico_legitimo_no_es_relleno(self):
        t = "Es fundamental medir el costo integral del canal; el dato crucial es la conversión, no los riesgos."
        self.assertEqual(F.relleno(t), [])

    def test_council_seccion_faltante_no_bloquea_salvo_la_primera(self):
        r = F.revisar_estructura("# Vamos en verde\n\n## Conclusión\nVamos en verde.\n## Semáforo\nverde\n## Logros\nx\n## Siguientes pasos\nOps\n", "estatus")
        self.assertTrue(r and all(x["gravedad"] == "media" for x in r if x["regla"] == "seccion_faltante"))
        r = F.revisar_estructura("# T\n\n## Semáforo\nverde\n", "estatus")
        self.assertIn(("seccion_faltante", "alta"), [(x["regla"], x["gravedad"]) for x in r])

    def test_plantilla_generada_pasa_su_estructura(self):
        for k in F.ESTRUCTURAS:
            with self.subTest(k):
                self.assertEqual([x for x in F.revisar_estructura(F.plantilla(k), k) if x["regla"] in ("orden", "seccion_faltante")], [])


if __name__ == "__main__":
    unittest.main()
