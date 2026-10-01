# Música ambiental

`exploration.ogg` es una composición instrumental original creada para BINNI con síntesis local: cuerdas pulsadas, bajo suave y una melodía de timbre similar a flauta. No contiene grabaciones externas, voces ni melodías tradicionales. No representa música zapoteca; cualquier futura referencia musical regional deberá verificarse con músicos o fuentes de la región.

- Duración: 48 segundos; bucle continuo con colas de eco circulares.
- Formato: Ogg Vorbis estéreo, 22 050 Hz; aproximadamente 147 KiB.
- Regeneración desde la raíz: `python3 tools/generate_exploration_music.py` (Python 3 y `ffmpeg` con `libvorbis`). Estas herramientas no son necesarias para jugar.
- `scripts/presentation/background_music.gd` mantiene un único reproductor entre zonas y baja gradualmente el volumen durante diálogos y el modo resortera.
- En el juego: `?` → `Música: activada/silenciada`. El ajuste dura la sesión y no modifica los archivos de partida.
- Verificación: `godot --headless --path . --script res://tests/test_background_music.gd`. Revisar mezcla con auriculares y altavoz de móvil.
