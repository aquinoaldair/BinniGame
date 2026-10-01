# Repository Guidelines

## Proyecto BINNI

Estamos creando un juego de aventura 2D para móviles con Godot 4 y GDScript. La historia ocurre en un pueblo ficticio inspirado en el Istmo de Tehuantepec.

Nisa explora el pueblo con Gela, una iguana compañera. El conflicto central es que se olvidan palabras, relatos y lugares en zapoteco, y con esa pérdida se debilita el mundo antiguo de Lidxi Gula. El tema principal es la memoria y la transmisión de la lengua entre generaciones.

El primer prototipo es un patio donde Nisa puede caminar. Desarrolla el juego poco a poco, con pasos pequeños y jugables. Explica los cambios en español.

Este `AGENTS.md` es la fuente de verdad para futuras tareas del proyecto. Antes de crear una zona, personaje o sistema visual, consultar estas reglas y los recursos existentes; no reinterpretar la dirección del proyecto desde cero. Los documentos de diseño citados complementan estas reglas con detalles de implementación.

La inspiración cultural debe distinguir entre elementos culturales reales, elementos inspirados y ficción propia del videojuego. Lidxi Gula, los fenómenos de memoria, el cielo, el viento y los elementos sobrenaturales narrativos no deben presentarse como tradiciones zapotecas verificadas. Los nombres y términos en diidxazá son provisionales; cuando no exista una fuente fiable, señalar que requieren verificación con hablantes o fuentes de la región. No inventar traducciones ni significados culturales o lingüísticos y presentarlos como reales.

## Project Structure & Module Organization

This repository contains **BINNI: El corazón del viento**, a Godot 4.7 prototype written in GDScript. Use the standard Godot edition; .NET is unnecessary.

- `project.godot`: engine configuration, main scene, display settings, and input actions.
- `scenes/main.tscn`: courtyard scene that instances the player.
- `scenes/player.tscn`: player body and collision shape.
- `scripts/player.gd`: movement, room bounds, and the visual attachment; preserve `_physics_process` for artistic changes.
- `scripts/presentation/nisa_art.gd` and `assets/characters/nisa/`: illustrated atlas, SpriteFrames, and a presentation-only selector. Nisa keeps the same design in both zones.
- `scripts/presentation/bixhozegola_art.gd` and `assets/characters/bixhozegola/`: illustrated grandmother, frontal idle and speaking animations; see `docs/bixhozegola_design.md`.
- `scripts/world.gd`: courtyard drawing and HUD creation.
- `scripts/touch_controls.gd`: touch input and directional controls.
- `scripts/presentation/`: courtyard art, character poses, Y-sorting, camera, lighting, and contextual UI; see `docs/patio_visual.md`. Street art remains in the existing scripts.
- `assets/patio/` and `scenes/props/`: painted terrain TileSet, illustrated prop atlases, and house/prop templates. `patio_ground.gd` builds static TileMapLayer surfaces; `patio_house.gd` separates facade/openings/supports/roof; `patio_ambience.gd` limits wind, cloth and leaf transforms to 12 Hz.
- `scenes/gela.tscn` and `scripts/gela.gd`: companion collision and following; `world.gd` provides courtyard paths.
- `scripts/presentation/gela_art.gd` and `assets/characters/gela/`: illustrated companion atlas and eight animations; see `docs/gela_design.md`.
- `scripts/patio_story.gd`: conversations, companion encounter, and notebook objective.
- `scripts/presentation/patio_sky.gd`: fictional strange sky; presentation reads committed story progress to restore a little color and wind. See `docs/story_opening.md`.
- `tests/test_companion.gd`: headless integration checks.
- `scripts/save_session.gd`: start menu and autosave; `scripts/save_store.gd`: validated JSON storage and backup recovery.
- `tests/test_save.gd`: save and menu integration checks with isolated files.
- `tests/test_street.gd`: courtyard/street transitions, story progression, and save migration. Both locations share `scenes/main.tscn`; `world.gd` selects drawings, collisions, and paths by zone.

The courtyard uses painted TileMapLayer surfaces and illustrated props; the street reuses the same kit through `street_presentation.gd`; see `docs/fountain_visual.md`. Nisa, Bixhozegola, and Gela use illustrated PNG atlases. Nisa has eight directional animations; see `docs/nisa_design.md`. Treat `.godot/` as generated editor data, not source.

## Dirección artística oficial

Toda nueva escena, personaje, prop o elemento visual debe pertenecer al mismo universo artístico: una aventura narrativa indie moderna con ilustración 2D, perspectiva top-down / 3/4, acabado cálido y ligeramente pintado, formas orgánicas, sombreado suave, texturas sutiles y colores cálidos y naturales. Priorizar buena legibilidad a escala de gameplay.

No utilizar como dirección principal pixel art retro, estética RPG Maker, tiles extremadamente evidentes, personajes hechos con primitivas geométricas, hiperrealismo, anime genérico, chibi extremo, estética medieval europea ni fantasía genérica.

### Referencias de personajes

Los personajes principales existentes establecen la referencia visual; consultar sus assets y documentos de diseño antes de crear o modificar personajes.

- **Nisa:** niña protagonista ilustrada, blusa de inspiración regional del Istmo, falda coral, morral turquesa característico, cabello oscuro y silueta claramente reconocible.
- **Bixhozegola:** abuela de Nisa, mujer zapoteca adulta mayor, cabello canoso recogido, blusa/huipil oscuro con flores grandes y coloridas, falda larga clara y apariencia cotidiana, estilizada pero no chibi.
- **Gela:** iguana ilustrada coherente con los personajes; debe seguir pareciendo una iguana. Expresar personalidad mediante movimiento y expresividad sin humanización excesiva.

Los nuevos NPC deben compartir el estilo sin parecer variaciones directas de Nisa o Bixhozegola. Cada NPC importante debe tener silueta, edad reconocible, colores, peinado, vestimenta e identidad visual propios. La inspiración de vestimenta y motivos sigue sujeta a las reglas de verificación cultural anteriores.

### Sprites y separación de responsabilidades

Para personajes animados, preferir `CharacterBody2D` / `Node2D` con `AnimatedSprite2D` y `SpriteFrames`. Separar lógica, físicas, colisiones y presentación visual. No dibujar personajes complejos continuamente mediante `_draw()` salvo una razón técnica concreta.

Mantener escala visual, proporciones, colores y diseño entre frames. Alinear el punto de apoyo con el suelo entre los pies para evitar jitter; para Gela usar el origen de suelo del tronco establecido en su diseño. Respetar los metadatos de atlas y las escalas físicas existentes indicadas en las pruebas.

Cuando corresponda, las animaciones base recomendadas son `idle_down`, `idle_up`, `idle_left`, `idle_right`, `walk_down`, `walk_up`, `walk_left` y `walk_right`. Añadir otras solo cuando el gameplay o la narrativa las necesiten; no exigir ocho direcciones a personajes cuyo papel no las requiere.

## Environment Kit - Pueblo y reutilización

Los assets del patio de Bixhozegola constituyen el primer **Environment Kit - Pueblo**. `assets/patio/`, `scenes/props/` y los scripts de presentación asociados son la fuente principal para construir futuras zonas.

Antes de generar o crear un asset:

1. Inspeccionar los assets existentes y buscar un equivalente.
2. Reutilizarlo si encaja visualmente.
3. Considerar una variante solo cuando exista una necesidad real.
4. Crear un asset completamente nuevo únicamente para algo que todavía no exista y sea necesario.

No volver a generar árboles, macetas, flores, paredes, tejas, césped, puertas, ventanas, bancas ni props comunes si ya existe una versión apropiada. La orientación para futuras escenas es aproximadamente 80% de assets existentes y 20% específicos de la zona; no es una obligación matemática y una escena puede reutilizar el 100%.

Reutilizar materiales, tejas, texturas de paredes, árboles, vegetación, tipos de suelo, arquitectura base y props entre mapas. Diferenciar las zonas mediante distribución, combinación de assets, elementos narrativos, landmarks, pequeños props específicos, variaciones de vegetación y actividad de NPC. No reinventar el estilo por mapa.

Cada zona importante puede tener uno o pocos landmarks que justifiquen assets exclusivos: una fuente, árbol particular, mercado, iglesia, cancha, puente, casa importante o estructura comunitaria. Son posibilidades de diseño, no afirmaciones culturales; el resto del escenario debe construirse principalmente con el kit.

Cuando varios mapas utilicen un elemento, preferir una escena reutilizable en lugar de reconstruir sus nodos manualmente. Encapsular sprite, sombra, colisión y comportamiento cuando correspondan; por ejemplo, `tree_01.tscn`, `bench_01.tscn`, `flower_pot_01.tscn`, `house_base_01.tscn` o `fountain_01.tscn`, siguiendo `snake_case` y reutilizando primero las plantillas existentes.

## Arquitectura visual de escenarios

No convertir mapas completos en imágenes gigantes. Utilizar un enfoque híbrido:

- **TileMapLayer / TileMap:** césped, tierra, caminos, pisos, superficies grandes y algunas paredes; preferir las superficies `TileMapLayer` ya establecidas en el proyecto.
- **Sprites reutilizables:** árboles, arbustos, flores, macetas, muebles, bancas, puertas, ventanas, objetos cotidianos y props.
- **Estructuras por capas:** paredes, fachada, techo, puertas, ventanas y elementos de primer plano.
- **AnimatedSprite2D:** solo para elementos que realmente necesiten animación.

La calle reutiliza el kit mediante `street_ground.gd`, `street_presentation.gd`, `street_well.gd` y `vecina_art.gd`. Sus dibujos anteriores permanecen como alternativa con `modern_street_enabled = false`. Ejecutar `tests/test_street_art.gd` para comprobar terreno sin obstáculos, capas de profundidad, rutas y pozo estático.

### Suelo y vegetación

Los tiles no deben mostrar una cuadrícula evidente ni grandes patrones repetitivos. Usar variaciones sutiles, bordes orgánicos, pequeñas piedras, hierbas, hojas, tierra, grietas y cambios suaves de tono. No crear un tile único enorme cuando la superficie pueda construirse con recursos reutilizables.

Árboles y plantas deben compartir el acabado ilustrado. Los árboles deben tener tronco visible, copa irregular, grupos de hojas, diferentes valores de verde y volumen mediante luz y sombra; evitar construirlos únicamente con círculos geométricos. Cuando la profundidad lo requiera, separar la base y la copa en capas o nodos (`Base` / `Canopy`) para permitir el paso visual delante y detrás.

### Profundidad y colisiones

Configurar de forma coherente `y_sort_enabled`, `z_index` y las capas. El punto de ordenación debe corresponder normalmente a la base o pies; no usar el centro completo del sprite cuando produzca errores de profundidad. Los personajes deben poder caminar naturalmente alrededor de árboles, casas, muebles, macetas, props y estructuras.

Las colisiones deben representar la parte física que bloquea, sin seguir necesariamente todo el sprite: tronco y no copa de un árbol, parte de una mesa que impide el paso y estructura coherente de una casa. Evitar formas innecesariamente complejas. Esta regla no autoriza añadir obstáculos a tiles o props decorativos del patio: conservar las colisiones, coordenadas y rutas auditadas salvo un cambio de gameplay explícitamente solicitado.

### Sombras, iluminación y ambiente

Integrar personajes y objetos con sombras suaves y una dirección de luz coherente. La iluminación cotidiana del pueblo debe sentirse cálida y natural. Evitar sombras negras duras, demasiadas luces individuales, shaders caros sin justificación e iluminación excesivamente dramática en escenas cotidianas. El cielo extraño y su recuperación narrativa conservan las reglas de progreso confirmado descritas en las pruebas; la calidez del estilo no debe anticipar esa recuperación.

Añadir movimiento ambiental moderado en hojas, ropa, flores, pequeños animales, agua, polvo o mariposas ocasionales. Debe reforzar un pueblo vivo sin distraer del gameplay ni saturar las escenas con partículas. Mantener la limitación existente a 12 Hz del ambiente del patio y su pausa fuera de esa zona.

## Rendimiento visual

El juego debe mantenerse ligero para móviles y hardware modesto. Evitar `queue_redraw()` constante sin necesidad, cálculos pesados en `_process()`, creación continua de recursos durante gameplay, shaders caros innecesarios, luces o partículas excesivas, texturas enormes para objetos pequeños, duplicación de assets y scripts por frame que puedan reaccionar a eventos.

Preferir recursos y escenas reutilizables, props estáticos, atlases cuando convengan, señales/eventos y animaciones simples y eficientes. No activar procesamiento por frame en props estáticos; conservar la separación entre presentación y lógica.

## Proceso para nuevas zonas y assets

Antes de crear o modificar una zona:

1. Inspeccionar la escena existente y el Environment Kit disponible.
2. Identificar recursos reutilizables y únicamente los assets específicos que realmente falten.
3. Conservar lógica y colisiones funcionales siempre que sea posible, respetando las restricciones del patio y del progreso narrativo.
4. Construir la escena reutilizando recursos existentes; no comenzar generando assets.
5. Comprobar Y-sorting, colisiones, coherencia artística y rendimiento, con las pruebas aplicables indicadas abajo y revisión visual a escala de gameplay.

Si un asset nuevo es necesario, debe seguir la dirección artística existente y tener perspectiva y escala compatibles, fondo transparente cuando corresponda, dimensiones razonables y poco espacio transparente sobrante. Diseñarlo para reutilización cuando tenga sentido. Antes de aceptarlo, comprobar visualmente que combina con los assets existentes.

La prioridad es construir un lenguaje visual coherente y reutilizable. Cada mapa debe sentirse como una nueva combinación del mismo mundo. Preguntarse primero: «¿Esto ya existe en el kit del proyecto?». Si existe, reutilizar; si casi encaja, considerar una variante; si falta y es importante, crear un nuevo asset reutilizable.

## Build, Test, and Development Commands

Run commands from the repository root with the Godot 4.7 executable on `PATH`:

- `godot --editor --path .`: open the project for development.
- `godot --path .`: run the configured main scene.
- `godot --headless --path . --editor --quit`: import resources and check editor startup; inspect output for script errors.

In the editor, **F5** runs the project; **F6** runs the current scene. No export presets or separate build scripts are provided.

## Coding Style & Naming Conventions

Use tabs for GDScript indentation, `snake_case` for files, functions, and variables, and `UPPER_SNAKE_CASE` for numeric constants. Preserve PascalCase resource aliases such as `TouchControls`. Follow existing typed function signatures and use `:=` when the type is inferable. Separate functions with two blank lines.

Use `res://` resource paths and existing `move_left`, `move_right`, `move_up`, and `move_down` actions. Prefer the editor for configuration changes. No formatter or linter is configured. Preserve Spanish player-facing text.

## Testing Guidelines

Run `godot --headless --path . --script res://tests/test_companion.gd` for companion and story integration checks. No external testing framework or coverage threshold exists. Manually verify WASD, arrow keys, diagonal movement, stopping animation, and courtyard bounds. For touch changes, check pressing, dragging, releasing, and multiple fingers on a touch-capable device. Check HUD readability at the 480×270 viewport and inspect debugger errors.

Run `godot --headless --path . --script res://tests/test_save.gd` for persistence changes. Keep test saves separate from `user://partida.json`. Preserve the versioned format and the rule that Gela appears only after notebook delivery. New objectives must save only committed progress so interrupted dialogues can be replayed.

Run `godot --headless --path . --script res://tests/test_street.gd` for zone or story changes. Save version 2 migrates version 1 without losing the notebook or Gela. The gate requires notebook delivery and Gela's greeting. If the drawing clue is still missing, read it at the gate and exit when that dialogue closes; another conversation with the grandmother is optional.

Run `godot --headless --path . --script res://tests/test_next_clue.gd` for the follow-up clue. `next_clue_received` commits only when the grandmother conversation closes, requires `street_progress == 3`, and defaults to false in older version 2 saves. Don Jacinto and his zone are planned, not yet playable; see `docs/next_memory.md`.

Run `godot --headless --path . --script res://tests/test_story_opening.gd` for narrative opening changes. Nisa asks about the strange sky; the notebook holds an incomplete fictional story. Restore a gentle breeze only after sharing the neighbor's fragment (`street_progress == 3`), never during an unfinished dialogue. Keep save version 2 and replay the brief opening only while the first conversation remains incomplete. Do not invent the missing diidxazá word or attribute the sky story to verified Zapotec beliefs.

Run `godot --headless --path . --script res://tests/test_presentation.gd` for presentation changes. Keep visual scale separate from collision bodies, preserve dialogue/state logic in `patio_story.gd`, and verify camera bounds, occlusion, contextual prompts, and the street fallback. Validate touch and performance on a real mobile device.

Run `godot --headless --path . --script res://tests/test_patio_art.gd` for terrain/prop changes. Preserve the coordinate audit in `docs/patio_audit.md`, existing building collisions, and companion paths. Terrain tiles and decorative props must not add physics/navigation obstacles. Keep tree bases at their original coordinates and leave the notebook and Gela encounter visible. Static props do not process each frame; environmental animation pauses outside the courtyard.

Run `godot --headless --path . --script res://tests/test_nisa_art.gd` for Nisa artwork changes. Keep the actor scale at one and collision radius at 6.5; align atlas frames at their feet and keep the satchel on the same anatomical side. Lateral walks use a separate higher-resolution atlas; `foot_origin` and `reference_height` metadata preserve world size. Verify alternating leg contacts and passing poses visually; frame-count tests do not validate anatomy. Cultural motifs remain provisional.

Run `godot --headless --path . --script res://tests/test_bixhozegola_art.gd` for grandmother artwork changes. Preserve `FAMILY_POSITION` and existing dialogue/state logic. Her visual selector reads speaker turns; it never moves the NPC or advances dialogue. Keep feet aligned and pause her animation outside the courtyard.

Run `godot --headless --path . --script res://tests/test_gela_art.gd` for companion artwork changes. Keep the physical scale at one, collision radius at 4, and normal following logic unchanged. Align the trunk floor origin across poses; visually inspect alternating paws and tail motion. Gela appears at `(66, 151)` below the upper left garden tree only after notebook delivery. Restore saved positions only for an already available companion; hidden saves use the current encounter point.

Run `godot --headless --path . --script res://tests/test_gela_intro.gd` for Gela's entrance and temporary guiding behavior. A rustle announces her during notebook reading. After the encounter she leads to the gate, then the fountain, waiting for Nisa and pausing during dialogue. Derive guiding from existing committed progress without new save fields; resume normal following after examining the fountain. `gela_encounter.gd` supplies presentation-only leaves and a short local rustle sound. Her mysterious behavior is original fiction.

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout. Recommended commits use concise imperative subjects, such as `Fix touch action release`, and keep related changes together. Pull requests should explain the behavior changed, include verification steps, link relevant issues, and attach screenshots or recordings for visual changes.
