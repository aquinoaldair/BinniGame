# BINNI: El corazón del viento

Primer prototipo jugable en Godot 4.7, escrito en GDScript.

## Abrirlo

1. Instala Godot 4.7 estándar (no la edición .NET).
2. Abre Godot y selecciona **Importar**.
3. Elige la carpeta `binni_godot` o el archivo `project.godot`.
4. Presiona **F6** para probar la escena principal o **F5** para ejecutar el proyecto.

## Controles

- Computadora: WASD o flechas del teclado.
- Pantalla táctil: flechas semitransparentes en la esquina inferior izquierda.
- Interacción: acércate a Bixhozegola junto al banco y presiona **E** o toca **Hablar**. Usa **E** o el botón del diálogo para avanzar y cerrar.
- Compañera: Gela aparece en el suelo, debajo del árbol superior del jardín izquierdo, después de entregar el cuaderno a Bixhozegola y cerrar la conversación. Acércate y presiona **E** o toca **Saludar**. Al cerrar el encuentro, te sigue rodeando las casas y descansa cerca de Nisa. Ambas se detienen durante los diálogos.

## Primer encuentro

En una partida nueva, Nisa comienza en el patio, alineada con el centro de su casa pequeña de la parte inferior del escenario. Continuar recupera la ubicación guardada. Habla con Bixhozegola, busca el cuaderno al lado derecho del patio y regresa para compartir un recuerdo. Nisa se detiene durante las conversaciones. En el patio, consulta el objetivo y los controles con el botón **?** de la esquina superior derecha. La acción aparece junto a Nisa en computadora y como botón en la esquina inferior derecha en móvil.

## Primer paseo

Después de entregar el cuaderno y saludar a Gela, acércate al portón superior izquierdo y pulsa **E** o **Salir**. Nisa revisa el dibujo de una fuente con una flor azul y sale al cerrar ese diálogo. También puedes consultar antes la pista con la abuela. En la calle, examina la fuente y habla con la vecina. Vuelve por el portón de la parte inferior para compartir la pista con la abuela y completar el paseo.

La calle, la vecina y el azulejo ausente son ficción provisional. Los lugares no tienen nombres definitivos y no se han inventado traducciones en diidxazá.

## Guardado de partida

Al abrir el proyecto, elige **Continuar** para recuperar tu partida o **Nueva partida** para empezar desde cero. Continuar se desactiva si no hay un guardado válido. Nueva partida pide confirmación antes de reemplazar los datos existentes.

La partida se guarda localmente en `user://partida.json`, con respaldo en `user://partida.json.bak`. Conserva el escenario actual, el progreso del cuaderno y del paseo, la aparición y el seguimiento de Gela y las posiciones de ambas. Hay autoguardado al cambiar de escenario, cerrar conversaciones, cada diez segundos y al perder el foco, pasar a segundo plano o cerrar la ventana. Si sales durante un diálogo, se repite desde el último objetivo completado. Las partidas de la versión anterior se actualizan conservando el progreso.

Si el archivo principal está dañado, Continuar intenta recuperar el respaldo. Una partida nueva reemplaza también ese respaldo. En el editor, **Proyecto → Abrir carpeta de datos de usuario** permite localizar los archivos. Este guardado es local al dispositivo.

Este relato es ficción provisional en español; no incluye traducciones ni representa una costumbre regional verificada.

El patio sin nombre tiene dos casas con techos de teja, césped, senderos, jardineras y losetas rojizas. El portón conecta con una pequeña calle con casas, una fuente y una vecina. Las casas y la fuente bloquean el paso. Nisa, Bixhozegola y Gela usan sprites ilustrados; la vecina y los escenarios usan formas dibujadas con código como arte provisional. El saludo y el seguimiento de la iguana son comportamientos ficticios del juego.

## Prueba de integración

Con Godot en el `PATH`, ejecuta `godot --headless --path . --script res://tests/test_companion.gd`. Comprueba el encuentro, el seguimiento alrededor de las dos casas, el descanso, la pausa en diálogos y la misión del cuaderno. El proceso termina con código distinto de cero si falla una comprobación.

Ejecuta también `godot --headless --path . --script res://tests/test_save.gd` para comprobar el menú, el autoguardado, la recuperación del progreso y el respaldo. Esta prueba usa archivos aislados y no modifica tu partida.

`godot --headless --path . --script res://tests/test_street.gd` comprueba la pista, la salida y el regreso, las conversaciones de la calle, las colisiones y la migración del guardado anterior. Ambos escenarios comparten la escena principal; `world.gd` cambia el diseño y las colisiones según el escenario guardado.

## Prueba visual del patio

El patio usa una presentación 2D con fachadas en perspectiva 3/4, Nisa y Bixhozegola más grandes, cámara suave, sombras, luz cálida y vegetación animada. La calle mantiene su presentación anterior. La historia, las colisiones y las partidas guardadas conservan su funcionamiento.

Consulta [la guía de presentación](docs/patio_visual.md) para conocer los módulos, probar controles táctiles en computadora y ajustar la luz. Ejecuta `godot --headless --path . --script res://tests/test_presentation.gd` para comprobar el aislamiento visual, la cámara, las poses, la interfaz contextual y los controles.

## Diseño de Nisa

Nisa tiene una blusa clara con detalles florales pequeños, falda coral, sandalias y un morral tejido turquesa. Sus animaciones ilustradas usan 24 fotogramas: reposo y caminata en las cuatro direcciones. Las caminatas laterales tienen una lámina propia para alternar ambas piernas y sus apoyos. Su diseño se conserva al salir del patio. El dibujo es una propuesta artística contemporánea; los motivos requieren verificación local.

Consulta [la guía de Nisa](docs/nisa_design.md) para revisar sus vistas, recursos y nombres de animación. Ejecuta `godot --headless --path . --script res://tests/test_nisa_art.gd` para comprobar las direcciones, los fotogramas, el encuadre y que las propiedades físicas se mantienen.

## Diseño de Bixhozegola

Bixhozegola tiene cabello canoso recogido, rostro anciano, blusa negra con flores grandes, falda larga crema y sandalias. Permanece junto al banco: su atlas incluye reposo y conversación de cuerpo completo en vista frontal 3/4. El gesto se activa durante sus intervenciones y vuelve al reposo cuando escucha a Nisa. Las caminatas y otras direcciones quedan pendientes de una necesidad narrativa.

Consulta [la guía de Bixhozegola](docs/bixhozegola_design.md) para revisar recursos, encuadre y referencias culturales pendientes. Ejecuta `godot --headless --path . --script res://tests/test_bixhozegola_art.gd` para comprobar las animaciones, la alineación de los pies, los turnos de voz y el punto original de interacción.

## Diseño de Gela

Gela usa un atlas ilustrado con cuerpo verde, vientre claro, cresta discreta y cola larga con bandas. Tiene ocho animaciones: tres poses de reposo y seis de caminata por dirección. Su tamaño y origen visual se ajustan en una capa separada del seguimiento y las colisiones, y conserva el diseño en la calle.

Consulta [la guía de Gela](docs/gela_design.md) y ejecuta `godot --headless --path . --script res://tests/test_gela_art.gd`. Las partidas donde todavía no apareció usan el nuevo encuentro debajo del árbol; las que ya la descubrieron recuperan su ubicación guardada.
