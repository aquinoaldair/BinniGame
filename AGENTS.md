# Repository Guidelines

## Proyecto BINNI

Estamos creando un juego de aventura 2D para móviles con Godot 4 y GDScript. La historia ocurre en un pueblo ficticio inspirado en el Istmo de Tehuantepec.

Nisa explora el pueblo con Gela, una iguana compañera. El conflicto central es que se olvidan palabras, relatos y lugares en zapoteco, y con esa pérdida se debilita el mundo antiguo de Lidxi Gula. El tema principal es la memoria y la transmisión de la lengua entre generaciones.

El primer prototipo es un patio donde Nisa puede caminar. Desarrolla el juego poco a poco, con pasos pequeños y jugables. Explica los cambios en español.

Los nombres y términos en diidxazá son provisionales. No inventes traducciones ni presentes elementos ficticios como hechos culturales. Señala qué necesita verificarse con hablantes o fuentes de la región.

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
- `scenes/gela.tscn` and `scripts/gela.gd`: companion collision and following; `world.gd` provides courtyard paths.
- `scripts/presentation/gela_art.gd` and `assets/characters/gela/`: illustrated companion atlas and eight animations; see `docs/gela_design.md`.
- `scripts/patio_story.gd`: conversations, companion encounter, and notebook objective.
- `tests/test_companion.gd`: headless integration checks.
- `scripts/save_session.gd`: start menu and autosave; `scripts/save_store.gd`: validated JSON storage and backup recovery.
- `tests/test_save.gd`: save and menu integration checks with isolated files.
- `tests/test_street.gd`: courtyard/street transitions, story progression, and save migration. Both locations share `scenes/main.tscn`; `world.gd` selects drawings, collisions, and paths by zone.

Scenery uses drawing functions. Nisa, Bixhozegola, and Gela use illustrated PNG atlases. Nisa has eight directional animations; see `docs/nisa_design.md`. Treat `.godot/` as generated editor data, not source.

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

Run `godot --headless --path . --script res://tests/test_presentation.gd` for presentation changes. Keep visual scale separate from collision bodies, preserve dialogue/state logic in `patio_story.gd`, and verify camera bounds, occlusion, contextual prompts, and the street fallback. Validate touch and performance on a real mobile device.

Run `godot --headless --path . --script res://tests/test_nisa_art.gd` for Nisa artwork changes. Keep the actor scale at one and collision radius at 6.5; align atlas frames at their feet and keep the satchel on the same anatomical side. Lateral walks use a separate higher-resolution atlas; `foot_origin` and `reference_height` metadata preserve world size. Verify alternating leg contacts and passing poses visually; frame-count tests do not validate anatomy. Cultural motifs remain provisional.

Run `godot --headless --path . --script res://tests/test_bixhozegola_art.gd` for grandmother artwork changes. Preserve `FAMILY_POSITION` and existing dialogue/state logic. Her visual selector reads speaker turns; it never moves the NPC or advances dialogue. Keep feet aligned and pause her animation outside the courtyard.

Run `godot --headless --path . --script res://tests/test_gela_art.gd` for companion artwork changes. Keep the physical scale at one, collision radius at 4, and following logic unchanged. Align the trunk floor origin across poses; visually inspect alternating paws and tail motion. Gela appears at `(66, 151)` below the upper left garden tree only after notebook delivery. Restore saved positions only for an already available companion; hidden saves use the current encounter point.

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout. Recommended commits use concise imperative subjects, such as `Fix touch action release`, and keep related changes together. Pull requests should explain the behavior changed, include verification steps, link relevant issues, and attach screenshots or recordings for visual changes.
