# La siguiente pista del recuerdo

Después de compartir el fragmento de la vecina y observar el regreso de la brisa, el objetivo invita a hablar otra vez con Bixhozegola. Ella recuerda a **don Jacinto**, personaje ficticio y nombre provisional: también contaba el relato junto al pozo y vive cerca de un árbol grande.

La conversación activa «Busca a don Jacinto junto al árbol grande». Hablar nuevamente con la abuela recuerda ese destino. La [misión de Don Jacinto](jacinto_mission.md) ya está disponible: desde la calle del pozo, tomar el camino de la derecha e interactuar para entrar a su zona. Nisa lo ayuda a bajar tres mangos y obtiene el contexto de la palabra, todavía pendiente de verificación.

No se incorpora una traducción inventada. La palabra en diidxazá queda pendiente de revisión por el usuario con hablantes nativos. El cuento y su relación con el cielo son ficción del videojuego.

## Guardado y pruebas

`next_clue_received` se confirma únicamente al cerrar la conversación y se conserva con el formato versión 2. Las partidas anteriores, sin ese campo, pueden continuar y recibir la pista. Una conversación interrumpida se repite desde el comienzo; no pierde ni adelanta el progreso.

Ejecutar `godot --headless --path . --script res://tests/test_next_clue.gd` para verificar compatibilidad, interrupciones, objetivo, recordatorio y persistencia. También se comprueban el inicio, guardado y recorrido de la calle mediante sus pruebas existentes.

Para probarlo con una partida avanzada: regresar al patio después de hablar con la vecina, compartir el fragmento con Bixhozegola, cerrar la observación del cielo y volver a pulsar Hablar.
