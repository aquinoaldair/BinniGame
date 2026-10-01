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
- Compañera: un crujido y unas hojas anuncian a Gela al leer el cuaderno. Aparece debajo del árbol superior del jardín izquierdo después de terminar la entrega. Acércate y presiona **E** o toca **Saludar**: Gela invita a Nisa a seguirla hacia el portón y el pozo. Espera si Nisa se retrasa y se detiene durante los diálogos. Después de examinar el pozo, sigue a Nisa y descansa cerca como antes.

## Primer encuentro

En una partida nueva, Nisa comienza frente al centro de su casa pequeña. Observa una franja pálida e inmóvil en el cielo y nota que el viento se detuvo. La cámara muestra el cielo durante esa breve observación; al cerrar el diálogo vuelve a seguir a Nisa. Pregunta a Bixhozegola qué ocurre, busca su cuaderno al lado derecho del patio y regresa para leerlo juntas. La abuela recuerda un cuento de su infancia, pero la frase y una palabra en diidxazá están incompletas.

Nisa se detiene durante las conversaciones. En el patio, consulta el objetivo y los controles con el botón **?** de la esquina superior derecha. La acción aparece junto a Nisa en computadora y como botón en la esquina inferior derecha en móvil.

## Primer paseo

Después de leer el recuerdo incompleto, Nisa pregunta cómo encontrar lo que falta y oye hojas bajo el árbol. Al acercarse, Gela mira hacia el portón; Nisa pregunta «¿Quieres que te siga?». La abuela le pide volver para contarle lo que encuentre. Sigue a Gela, acércate al portón y pulsa **E** o **Salir**. En la calle Gela se dirige al pozo: Nisa reconoce el dibujo del cuaderno al examinarlo. Pregunta a la vecina cómo continúa la frase y regresa con Bixhozegola. Al terminar de compartir el fragmento, el cielo se aclara ligeramente y vuelve una brisa; la palabra pendiente todavía necesita recuperarse.

El cuento y su relación con el cielo son ficción original del juego. No representan una tradición o creencia zapoteca verificada. La flor azul dejó de ser la pista narrativa. Los lugares no tienen nombres definitivos y no se han inventado traducciones en diidxazá. Consulta [la guía del nuevo inicio](docs/story_opening.md).

Tras recuperar ese fragmento, vuelve a hablar con Bixhozegola para recibir la [siguiente pista](docs/next_memory.md): buscar a don Jacinto. Su [zona y misión de resortera](docs/jacinto_mission.md) ya están disponibles siguiendo el sendero hasta el borde derecho del pozo. El modo resortera usa carga al mantener pulsado y disparo al soltar, con trayectoria curva, viento suave y piedras ilimitadas. La conversación y el objetivo ya se guardan al continuar.

## Guardado de partida

Al abrir el proyecto, elige **Continuar** para recuperar tu partida o **Nueva partida** para empezar desde cero. Continuar se desactiva si no hay un guardado válido. Nueva partida pide confirmación antes de reemplazar los datos existentes.

La partida se guarda localmente en `user://partida.json`, con respaldo en `user://partida.json.bak`. Conserva el escenario actual, el progreso del cuaderno y del primer recuerdo, la aparición y el seguimiento de Gela y las posiciones de ambas. Hay autoguardado al cambiar de escenario, cerrar conversaciones, cada diez segundos y al perder el foco, pasar a segundo plano o cerrar la ventana. Si sales durante un diálogo, se repite desde el último objetivo completado. La observación inicial se repite mientras no hayas terminado la primera conversación con Bixhozegola. Las partidas anteriores conservan su progreso; un paseo ya completado corresponde al primer fragmento recuperado.

Si el archivo principal está dañado, Continuar intenta recuperar el respaldo. Una partida nueva reemplaza también ese respaldo. En el editor, **Proyecto → Abrir carpeta de datos de usuario** permite localizar los archivos. Este guardado es local al dispositivo.

Este relato es ficción provisional en español; no incluye traducciones ni representa una costumbre regional verificada.

El patio sin nombre tiene dos casas con techos de teja, césped, senderos, jardineras y losetas rojizas. El portón conecta con una pequeña calle con casas, un pozo y una vecina. Las casas y el pozo bloquean el paso. Nisa, Bixhozegola y Gela usan sprites ilustrados. El patio combina materiales pintados en TileMapLayer y props ilustrados; la calle reutiliza el mismo kit y añade un pozo y una vecina ilustradas. El saludo y el seguimiento de la iguana son comportamientos ficticios del juego.

## Prueba de integración

Con Godot en el `PATH`, ejecuta `godot --headless --path . --script res://tests/test_companion.gd`. Comprueba el encuentro, el seguimiento alrededor de las dos casas, el descanso, la pausa en diálogos y la misión del cuaderno. El proceso termina con código distinto de cero si falla una comprobación.

Ejecuta también `godot --headless --path . --script res://tests/test_save.gd` para comprobar el menú, el autoguardado, la recuperación del progreso y el respaldo. Esta prueba usa archivos aislados y no modifica tu partida.

`godot --headless --path . --script res://tests/test_street.gd` comprueba la pista, la salida y el regreso, las conversaciones de la calle, las colisiones y la migración del guardado anterior. Ambos escenarios comparten la escena principal; `world.gd` cambia el diseño y las colisiones según el escenario guardado.

`godot --headless --path . --script res://tests/test_story_opening.gd` recorre el inicio, verifica que el cielo y la brisa cambien solo al completar el primer recuerdo y comprueba la recuperación de conversaciones interrumpidas con guardados aislados.

`godot --headless --path . --script res://tests/test_gela_intro.gd` comprueba el ruido, la invitación, la guía hacia el portón y el pozo, las esperas, la separación de Nisa y la recuperación al continuar en ambas zonas.

## Prueba visual del patio

El patio usa materiales de césped, tierra, piedra y barro con variaciones y bordes suaves; tres árboles ilustrados, plantas y macetas reutilizables; y casas separadas en fachada, aberturas, columnas y techo. La banca, silla, cubeta, escoba, vasijas y tendedero aportan vida cotidiana sin bloquear caminos. Conserva la cámara suave, sombras y luz cálida. Al inicio, las copas y telas permanecen quietas; su movimiento y dos hojas regresan después del primer recuerdo. Una mariposa pequeña sigue revoloteando. Todo el ambiente se pausa fuera del patio. El área del pozo reutiliza este kit con una plazoleta irregular, casas variadas y un pozo por capas; las colisiones conservan sus coordenadas. Consulta [su diseño y verificación](docs/fountain_visual.md).

Consulta [la guía de presentación](docs/patio_visual.md) para conocer los módulos, probar controles táctiles en computadora y ajustar la luz. Ejecuta `godot --headless --path . --script res://tests/test_presentation.gd` para comprobar el aislamiento visual, la cámara, las poses, la interfaz contextual y los controles.

`godot --headless --path . --script res://tests/test_patio_art.gd` verifica las capas del suelo, los props sin colisiones nuevas, las rutas, el encuadre inicial y la pausa del ambiente. La [auditoría del patio](docs/patio_audit.md) documenta las coordenadas y sistemas conservados.

## Diseño de Nisa

Nisa tiene una blusa clara con detalles florales pequeños, falda coral, sandalias y un morral tejido turquesa. Sus animaciones ilustradas usan 24 fotogramas: reposo y caminata en las cuatro direcciones. Las caminatas laterales tienen una lámina propia para alternar ambas piernas y sus apoyos. Su diseño se conserva al salir del patio. El dibujo es una propuesta artística contemporánea; los motivos requieren verificación local.

Consulta [la guía de Nisa](docs/nisa_design.md) para revisar sus vistas, recursos y nombres de animación. Ejecuta `godot --headless --path . --script res://tests/test_nisa_art.gd` para comprobar las direcciones, los fotogramas, el encuadre y que las propiedades físicas se mantienen.

## Diseño de Bixhozegola

Bixhozegola tiene cabello canoso recogido, rostro anciano, blusa negra con flores grandes, falda larga crema y sandalias. Permanece junto al banco: su atlas incluye reposo y conversación de cuerpo completo en vista frontal 3/4. El gesto se activa durante sus intervenciones y vuelve al reposo cuando escucha a Nisa. Las caminatas y otras direcciones quedan pendientes de una necesidad narrativa.

Consulta [la guía de Bixhozegola](docs/bixhozegola_design.md) para revisar recursos, encuadre y referencias culturales pendientes. Ejecuta `godot --headless --path . --script res://tests/test_bixhozegola_art.gd` para comprobar las animaciones, la alineación de los pies, los turnos de voz y el punto original de interacción.

## Diseño de Gela

Gela usa un atlas ilustrado con cuerpo verde, vientre claro, cresta discreta y cola larga con bandas. Tiene ocho animaciones: tres poses de reposo y seis de caminata por dirección. Su tamaño y origen visual se ajustan en una capa separada del seguimiento y las colisiones, y conserva el diseño en la calle.

Consulta [la guía de Gela](docs/gela_design.md) y ejecuta `godot --headless --path . --script res://tests/test_gela_art.gd`. Las partidas donde todavía no apareció usan el nuevo encuentro debajo del árbol; las que ya la descubrieron recuperan su ubicación guardada.
