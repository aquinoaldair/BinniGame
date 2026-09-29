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
- `scripts/player.gd`: movement, room bounds, and procedural character drawing.
- `scripts/world.gd`: courtyard drawing and HUD creation.
- `scripts/touch_controls.gd`: touch input and directional controls.
- `scenes/gela.tscn` and `scripts/gela.gd`: companion drawing, collision, and following; `world.gd` provides courtyard paths.
- `scripts/patio_story.gd`: conversations, companion encounter, and notebook objective.
- `tests/test_companion.gd`: headless integration checks.

Artwork currently uses drawing functions; there is no dedicated asset directory. Treat `.godot/` as generated editor data, not source.

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

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout. Recommended commits use concise imperative subjects, such as `Fix touch action release`, and keep related changes together. Pull requests should explain the behavior changed, include verification steps, link relevant issues, and attach screenshots or recordings for visual changes.
