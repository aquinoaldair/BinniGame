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
- Compañera: Gela aparece en el jardín izquierdo después de entregar el cuaderno a Bixhozegola y cerrar la conversación. Acércate y presiona **E** o toca **Saludar**. Al cerrar el encuentro, te sigue rodeando las casas y descansa cerca de Nisa. Ambas se detienen durante los diálogos.

## Primer encuentro

Habla con Bixhozegola, busca el cuaderno al lado derecho del patio y regresa para compartir un recuerdo. Nisa se detiene durante las conversaciones. El objetivo aparece en la parte superior.

## Guardado de partida

Al abrir el proyecto, elige **Continuar** para recuperar tu partida o **Nueva partida** para empezar desde cero. Continuar se desactiva si no hay un guardado válido. Nueva partida pide confirmación antes de reemplazar los datos existentes.

La partida se guarda localmente en `user://partida.json`, con respaldo en `user://partida.json.bak`. Conserva el progreso del cuaderno, la aparición y el seguimiento de Gela y las posiciones de ambas. Hay autoguardado al cerrar conversaciones, cada diez segundos y al perder el foco, pasar a segundo plano o cerrar la ventana. Si sales durante un diálogo, se repite desde el último objetivo completado.

Si el archivo principal está dañado, Continuar intenta recuperar el respaldo. Una partida nueva reemplaza también ese respaldo. En el editor, **Proyecto → Abrir carpeta de datos de usuario** permite localizar los archivos. Este guardado es local al dispositivo.

Este relato es ficción provisional en español; no incluye traducciones ni representa una costumbre regional verificada.

Esta primera escena permite caminar por un patio sin nombre, conversar, completar un objetivo sencillo y explorar con Gela. El diseño visto desde arriba incluye dos casas con techos de teja, césped, senderos, jardineras y un patio de losetas rojizas. Las casas bloquean el paso; el portón aún no cambia de escena. Los personajes y el escenario usan formas dibujadas con código como arte provisional. El saludo y el seguimiento de la iguana son comportamientos ficticios del juego.

## Prueba de integración

Con Godot en el `PATH`, ejecuta `godot --headless --path . --script res://tests/test_companion.gd`. Comprueba el encuentro, el seguimiento alrededor de las dos casas, el descanso, la pausa en diálogos y la misión del cuaderno. El proceso termina con código distinto de cero si falla una comprobación.

Ejecuta también `godot --headless --path . --script res://tests/test_save.gd` para comprobar el menú, el autoguardado, la recuperación del progreso y el respaldo. Esta prueba usa archivos aislados y no modifica tu partida.
