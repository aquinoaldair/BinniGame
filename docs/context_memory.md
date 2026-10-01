# El cuento alrededor de la palabra

Continuación jugable de la misión de Jacinto. Él sí recupera la palabra dentro de la historia; `[PENDIENTE_DE_VERIFICACION]` sigue siendo el marcador de desarrollo para no inventar una traducción. Bixhozegola no la reconoce aislada y necesita escuchar el fragmento que la acompañaba.

## Recorrido

1. Compartir con la abuela la palabra de Jacinto. Si esa conversación ya estaba completada en una partida anterior, el nuevo objetivo aparece al continuar.
2. Hablar con la vecina del pozo. Ella reconoce dos dibujos del cuaderno y pide compararlos con el lugar.
3. Acercarse al banco a la derecha del pozo y al árbol de la entrada, a la izquierda. Los pequeños indicadores de página señalan las dos observaciones; desaparecen al completarlas. Se pueden revisar en cualquier orden con E o el botón táctil.
4. Volver con la vecina. Los márgenes y su recuerdo reconstruyen: «Si una voz se pierde, busca a quien todavía la guarda. Nadie recuerda el camino a solas».
5. Llevar ese fragmento a Bixhozegola. Ella reconoce la parte del relato que conduce hacia Lidxi Gula. Esta etapa termina con esa pista; el recorrido hacia ese lugar todavía no está implementado.

La página y el relato son ficción original. No se atribuyen estos versos ni el misterio a una tradición regional documentada. El término pendiente y los nombres en diidxazá deben revisarse con hablantes o fuentes de la región.

## Estado y guardado

`ContextProgress` tiene NONE, SEARCH, FRAGMENT y SHARED. `context_clues` usa el bit 0 para el banco y el bit 1 para el árbol. Los dos campos son opcionales en el guardado versión 2; las partidas anteriores comienzan esta etapa en NONE. Solo pueden avanzar después de compartir con la abuela el recuerdo de Jacinto. Cada diálogo confirma sus cambios al cerrarse; una interrupción conserva el estado anterior y permite repetirlo.

Se reutilizan el pozo, banco, árbol, vecina, abuela y las tres zonas actuales. No se cambian movimiento, colisiones, transiciones, seguimiento de Gela ni la posibilidad de repetir la resortera.

## Verificación

`godot --headless --path . --script res://tests/test_context_memory.gd` verifica activación, ambos órdenes, observaciones interrumpidas, guardado compatible, requisitos del fragmento y entrega final. Ejecutar también las pruebas de Jacinto, calle, guardado, siguiente pista, presentación y arte de calle. Comprobar manualmente la legibilidad de los indicadores y botones en móvil.
