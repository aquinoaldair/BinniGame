# Presentación del patio

Prototipo visual incremental para el patio de Bixhozegola. Las fachadas, el corredor, las macetas, las tejas y los colores son una interpretación artística provisional de la referencia del patio. La calle conserva el dibujo anterior.

![Vista del patio renderizada en Godot](patio_preview.png)

## Probar

Abre `scenes/main.tscn` y ejecuta el proyecto. Continúa una partida situada en el patio o usa una partida nueva, teniendo en cuenta que reemplaza el guardado tras confirmar. Camina con WASD o flechas; cerca de Bixhozegola aparece **[ E ] Hablar**. Consulta el objetivo con **?**. En móvil, la acción está abajo a la derecha y las flechas son más pequeñas y translúcidas.

Activa `preview_touch_controls` en el nodo raíz para mostrar las flechas en computadora. Su interacción requiere eventos táctiles; esta opción solamente permite revisar el aspecto. `modern_patio_enabled = false` recupera el escenario anterior del patio al iniciar la escena, para comparar; Nisa mantiene su nuevo diseño en ambos escenarios.

## Módulos

- `world.gd` conserva las colisiones, los caminos de Gela y la selección de zona; instancia la presentación.
- `patio_ground.gd` dibuja el suelo estático con variación determinista y juntas de bajo contraste.
- `patio_presentation.gd` organiza casas, banco, vegetación, cuaderno y Bixhozegola con sus orígenes en el suelo. El orden por Y se comparte con Nisa y Gela. El suelo usa `z_index = -10`.
- `patio_prop.gd` dibuja fachadas, puertas, ventanas, columnas y objetos. Árboles, telas y algunas plantas se animan a un máximo de 24 actualizaciones visuales por segundo. Sus adornos no añaden obstáculos nuevos.
- `bixhozegola_art.gd` presenta a la abuela con atlas ilustrado y animaciones frontales de reposo y conversación, con altura aproximada de **86** unidades. Lee el turno de voz sin modificar el relato; consulta [su guía de diseño](bixhozegola_design.md). Nisa usa `nisa_art.gd` y un atlas con ocho animaciones; consulta [su guía de diseño](nisa_design.md). Los tamaños visuales no modifican los cuerpos físicos.
- `gela_art.gd` selecciona ocho animaciones ilustradas leyendo la dirección y velocidad de la compañera. Su origen se sitúa bajo el cuerpo y su cola ocupa espacio visual sin ampliar la colisión; consulta [su guía de diseño](gela_design.md).
- `patio_camera.gd` sigue a Nisa con suavizado y zoom **1.12**, limitado al patio, con 24 unidades de margen superior para el cabello de Nisa. La perspectiva 3/4 pertenece al dibujo, sin transformar el mapa.
- `patio_lighting.gd` combina `CanvasModulate`, `PointLight2D` y oclusores de las casas, con filtro de sombra PCF13. `daylight` permite explorar otra intensidad ambiental; todavía no existe un ciclo horario ni se guarda ese valor.
- `patio_ui.gd` presenta los botones y textos de `patio_story.gd`; las decisiones narrativas siguen en ese script. El menú y el guardado mantienen su comportamiento.

## Verificación

Ejecuta con Godot 4.7 en el PATH:

```sh
godot --headless --path . --script res://tests/test_presentation.gd
godot --headless --path . --script res://tests/test_bixhozegola_art.gd
godot --headless --path . --script res://tests/test_gela_art.gd
godot --headless --path . --script res://tests/test_companion.gd
godot --headless --path . --script res://tests/test_save.gd
godot --headless --path . --script res://tests/test_street.gd
```

Revisa además la lectura de los diálogos a 480×270, el orden delante/detrás de árboles y banco, el seguimiento al caminar hasta los límites y el retorno desde la calle. Prueba pulsar, arrastrar, soltar y usar dos dedos en un dispositivo táctil real; el rendimiento en móvil requiere validación allí.

## Referencias pendientes

Antes de tomar este patio como referencia definitiva, verifica fachadas, corredores, vegetación local y motivos de la blusa con fotografías y fuentes de comunidades específicas del Istmo y con personas de la región. No se atribuyen los motivos florales a una prenda tradicional verificada. Los términos en diidxazá y los nombres del relato continúan siendo provisionales; no se añaden traducciones ni afirmaciones culturales.

Referencia técnica: [iluminación 2D de Godot](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html).
