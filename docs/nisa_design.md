# Diseño visual de Nisa

Niña protagonista de aproximadamente 9–11 años, con cabello largo oscuro y ligeramente ondulado, rostro expresivo, blusa crema con pequeños detalles florales, falda coral sencilla, sandalias y morral tejido turquesa. El morral va en su cadera izquierda y conserva ese lado en las cuatro vistas; al mirar a la derecha queda parcialmente detrás del cuerpo.

![Vistas de Nisa renderizadas en Godot](nisa_directions.png)

[Vista de Nisa dentro del patio](nisa_gameplay.png).

## Integración

Antes de este cambio, Nisa se dibujaba por código: no había `AnimatedSprite2D`, `AnimationPlayer`, atlas ni nombres de animación existentes. El nuevo `AnimatedSprite2D` se crea dentro de la capa visual `HumanArt`, conservando la referencia `player.human_art`. `nisa_art.gd` lee `facing`, `velocity` y `can_move` del controlador y selecciona la animación; no escribe en ellos.

El cuerpo `CharacterBody2D`, su escala **1**, la colisión circular de radio **6.5**, la velocidad **78**, los límites, el movimiento, las interacciones y los diálogos conservan su funcionamiento. La función `_physics_process` y `scenes/player.tscn` se verificaron idénticas a las anteriores al rediseño. Nisa mantiene la misma identidad al pasar entre patio y calle.

El atlas RGBA mide **1536×1024**. Cada `AtlasTexture` aporta un lienzo virtual **320×320**, alineado con los pies en **(160, 304)**. Las regiones y márgenes compensan las diferencias de posición del dibujo original sin recortar ni retocar el PNG. El render usa escala **0.33**, filtro lineal y una altura aproximada de **74–80 unidades**, frente a unas 51 del dibujo anterior. La sombra es independiente del sprite. El patio incluye un pequeño margen superior de cámara para evitar cortar el cabello junto al portón.

## Animaciones listas

| Direcciones | Nombres | Fotogramas | Velocidad |
| --- | --- | --- | --- |
| Abajo, arriba, izquierda, derecha | `idle_down`, `idle_up`, `idle_left`, `idle_right` | 2 por dirección | 2 FPS |
| Abajo, arriba, izquierda, derecha | `walk_down`, `walk_up`, `walk_left`, `walk_right` | 4 por dirección | 7 FPS |

Las vistas izquierda y derecha tienen fotogramas propios: no se reflejan con `flip_h`, para conservar la posición del morral. Al detenerse, Nisa mantiene la última orientación. Durante los diálogos permanece en reposo; el selector admite futuras animaciones `talk_*` cuando se incorporen al recurso.

## Recursos editables

- [`nisa_atlas.png`](../assets/characters/nisa/nisa_atlas.png): imagen fuente transparente seleccionada.
- [`sprite_frames.tres`](../assets/characters/nisa/sprite_frames.tres): ocho animaciones, regiones y márgenes, editables como `SpriteFrames` en Godot.
- [`atlas_layout.json`](../assets/characters/nisa/atlas_layout.json): registro de posiciones y orígenes de los 24 fotogramas.
- [`nisa_art.gd`](../scripts/presentation/nisa_art.gd): selector y sombra; conserva el controlador del jugador.
- [`generation_prompt.md`](../assets/characters/nisa/generation_prompt.md): solicitudes exactas de generación y corrección con la herramienta integrada `image_gen`.

Posteriormente pueden añadirse `run_*`, `talk_*`, `pick_up_*`, `sit_*`, `surprise_*`, `joy_*`, `sad_*` y `fear_*`, usando las mismas cuatro direcciones y el mismo origen. Estos nombres son una convención propuesta, no animaciones ya creadas. Las nuevas acciones deben conectarse a la capa visual cuando se desarrollen sus comportamientos correspondientes.

## Verificar

```sh
godot --headless --path . --script res://tests/test_nisa_art.gd
```

Comprueba además las pruebas de presentación, Gela, guardado y calle. Para revisar los fotogramas individualmente, abre `sprite_frames.tres` en Godot; ejecuta el proyecto para ver escala, luz y superposición reales. Valida también legibilidad y suavidad en un dispositivo móvil.

Los detalles bordados y el tejido del morral son propuestas gráficas provisionales. Deben verificarse con referencias de comunidades específicas del Istmo y con personas de la región antes de atribuirlos a diseños tradicionales concretos. El cambio no añade traducciones, costumbres ni afirmaciones culturales a la historia.
