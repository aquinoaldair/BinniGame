# Generación del atlas de Gela

Herramienta: ImageGen integrada, PNG RGBA con fondo transparente. Referencias de estilo: `docs/nisa_directions.png` y `docs/bixhozegola_preview.png`. Se eligió la primera generación, con 36 dibujos. Una edición posterior de color se descartó: la inspección del alfa confirmó que los bordes rojos visibles en la previsualización eran casi transparentes y no formaban parte del animal. El PNG seleccionado se conserva sin modificar; Godot define regiones y márgenes.

## Prompt seleccionado

Use case: illustration-story.
Asset type: actual transparent RGBA 2D game iguana animation atlas. Images1 and2 show HUMAN characters of this game's visual style ONLY. Do NOT draw people, clothing, bags, accessories, text or labels. Draw ONLY the green iguana companion Gela.
Create a square 1536x1536 sprite sheet, EXACTLY SIX COLUMNS by SIX ROWS, 36 complete isolated iguana drawings, one per cell, clear transparent gutters. Identical size and anatomy in every pose. All cells exactly256x256. Keep bodies at a stable local root and ground height within each directional row; tail tip must not leave its cell.
Animal identity: recognizable green iguana, lean elongated modest body, short muscular splayed four legs with delicate clawed toes, long tapering tail about twice trunk length, prominent but modest dorsal crest of small triangular spines continuing into tail base, small throat dewlap and rounded cheek scale, sensible small amber eyes with dark pupil, natural closed reptile mouth. Mostly leafy/olive greens, lighter sage belly, dark green banding tail, tiny restrained ochre touches on dorsal spines. Simplified subtle scales. Head anatomically sized, no giant eyes, no oversized baby head, no human smile, no dragon horns/wings, no dinosaur, no magic or fantasy ornaments. Calm, alert, curious small wild animal, mild appealing personality without pet-toy caricature.
Match these illustrated humans' warm hand-painted contemporary indie game art: soft clean forms, subtle contours, warm highlights, natural greens, gentle volume/shading, detail simplified for legibility small on screen. NOT pixel art, anime, hyperrealism or overhead flat silhouette.
Perspective: camera top-down THREE QUARTER, seeing SIDE VOLUME as well as back. Down view shows face and little pale throat/chest, head at screen bottom, tail extending behind toward screen top. Up view shows back/head away and dorsal crest, head toward top, tail extends toward screen bottom. LEFT view head screen left, long tail to right; RIGHT view head right, long tail left. Keep all four views the exact same animal.
BODY SCALE: trunk+head only around75-85 source pixels long, short legs, actual body volume around35-45 pixels high on side views; total visible silhouette with tail about205-220 pixels, fitting all cells with generous padding. Long tail makes length, not a big body.
LAYOUT:
ROW1: SIX walking DOWN frames, chronological full loop.
ROW2: SIX walking UP frames.
ROW3: SIX walking LEFT frames.
ROW4: SIX walking RIGHT frames.
ROW5: columns1-3 idle DOWN; columns4-6 idle UP.
ROW6: columns1-3 idle LEFT; columns4-6 idle RIGHT.
Each walk row is a true complete alternating diagonal quadruped gait: near foreleg+opposite hindleg forward, passing stance, alternate opposite foreleg/hindleg forward, passing, transition, return. Fore and hind paws alternate support; do not just duplicate a stationary iguana with different tail tips. Short quiet crawling steps, low body, small head/body sway. Tail smoothly changes C/S curvature in a consistent flowing loop with its base attached; exactly same total tail length and banding. Tail not rigid and not flailing.
Each three-frame idle group: alert soft breath, small glance/head tilt with eyelid half blink, return looking forward with relaxed tail shifted gently; same body planted, slight motion only. Do not change scale or body length. No full sleep or special interactions yet.
Maintain same cheek scale, crest color, scale pattern, tail thickness, proportions and shading across ALL frames. Preserve frame consistency; no decorative backgrounds, ground, drop shadows, words, arrows, labels, panels or grid. Actual transparent alpha everywhere outside the animals. Complete tail and all visible toes must fit each tile.
