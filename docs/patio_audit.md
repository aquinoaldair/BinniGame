# Auditoría del patio antes del rediseño

La revisión se hizo sobre el commit `80ba55f`. El escenario ya era jugable y compartía `scenes/main.tscn` con la calle. Se sustituyó únicamente su presentación.

## Nodos y responsables originales

`Patio` (`Node2D`, `world.gd`) contiene Nisa, Gela y `PatioStory`. Al iniciar, agrega cinco cuerpos estáticos, los controles/HUD, `PatioPresentation`, `PatioCamera`, `PatioUI` y el menú/guardado cuando está habilitado.

- **TileMap/TileMapLayer:** ninguno en el patio original.
- **Procedural:** `patio_ground.gd` dibujaba césped, caminos, losetas y sombras; `patio_prop.gd` dibujaba casas, árboles, macetas, banco, muros, portón, cuaderno y ropa. `patio_presentation.gd` redibujaba mariposas/hojas cada fotograma.
- **Sprites:** Nisa, Bixhozegola y Gela ya usaban atlas PNG y `AnimatedSprite2D`. Sus sombras se dibujaban separadamente. La calle conservaba los dibujos de `world.gd` y `patio_story.gd`.
- **Narrativa:** `patio_story.gd` decide interacciones, diálogos, progreso y aparición de Gela. `save_session.gd`/`save_store.gd` gestionan menú y persistencia.

## Coordenadas que se preservan

| Elemento | Posición o rectángulo en unidades del mundo |
| --- | --- |
| Nisa, partida nueva | `(184, 208)` |
| Bixhozegola/interacción | `(328, 156)` |
| Aparición de Gela | `(66, 151)`, después de entregar el cuaderno |
| Cuaderno | `(398, 188)` |
| Interacción del portón | `(123, 65)` |
| Casa principal, colisión | `Rect2(212, 54, 232, 76)` |
| Casa pequeña, colisión | `Rect2(128, 216, 112, 36)` |
| Límites caminables | `Rect2(34, 59, 411, 186)` |
| Bases de los árboles | `(62, 132)`, `(67, 205)`, `(415, 242)` |

Los otros tres cuerpos estáticos pertenecen a las casas y fuente de la calle y se desactivan en el patio. Los árboles, muros, macetas y banco no tenían colisiones. Los nuevos props tampoco añaden obstáculos. El radio de Nisa sigue en 6.5 y el de Gela en 4. Los caminos se calculan en `AStarGrid2D`, con celdas de seis unidades y margen alrededor de los edificios.

## Profundidad y cámara

El mundo y `PatioPresentation` activan Y-Sorting en el patio. Los props tienen su origen en el suelo, los personajes en sus pies y el suelo usa `z_index = -10`. La cámara conserva zoom 1.12, seguimiento suavizado a velocidad 5, desplazamiento vertical de -18 y límites `(0, -24)`–`(480, 270)`. Al salir a la calle recupera zoom uno y encuadre anterior. La luz combina un `CanvasModulate`, un `PointLight2D` y oclusores de los edificios.

## Alcance del cambio

Se reemplazaron las superficies y dibujos de props por materiales de tiles y piezas ilustradas reutilizables. Las fachadas, techos, aberturas, vegetación, sombras y ambiente son visuales. Se conservaron cámara, posiciones, colisiones, navegación, controles, interacción, textos, guardado y atlas de personajes. Las nuevas copas evitan ocultar el cuaderno/Gela; el techo pequeño deja libres los pies de Nisa al iniciar.
