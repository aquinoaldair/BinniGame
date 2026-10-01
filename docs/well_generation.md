# Generación del pozo comunitario

Recurso: `assets/street/well.png`. Herramienta: ImageGen integrada. Fondo transparente, importación móvil limitada a 512 píxeles con mipmaps. Solo este elemento se generó; cubeta y sombras se reutilizan. El diseño es ficción del juego y no una afirmación etnográfica.

## Prompt inicial

```text
Create ONE isolated game prop: a modest everyday community water WELL, for the warm hand-painted 2D top-down 3/4 indie adventure shown in the reference. Reference is STYLE ONLY, do not recreate the scene or any characters/buildings. Transparent background. Entire well centered with empty transparent margin. Circular broad low rim of pale aged irregular stone masonry, knee-to-waist high, dark recessed opening with believable interior depth, no pool of bright water. Two plain wooden upright posts at left and right anchored beside rim, a single horizontal timber beam, simple small pulley at middle, thin rope hanging into dark opening, modest coil near pulley. Wood natural warm brown, worn practical construction. No roof, no ornaments, no magic, no medieval styling, no European fantasy. Silhouette clear at small game scale. Soft painterly texture and lighting from upper left. No bucket (existing game bucket will be reused), no ground patch, no scenery, no text, no external cast shadow (engine adds it). Render orthographic front three-quarter overhead view consistent with reference houses. Rim broad horizontally oval due to perspective; uprights rise about one rim-width above base. Only this single well, no duplicate assets or atlas labels.
```

## Limpieza de transparencia

```text
Edit this well sprite ONLY to clean transparency. Preserve the exact well geometry, all stone, wooden posts and beam, pulley, coil and rope, colors, painting style and coordinates. Remove ALL brown/golden glow/haze/background around the silhouette AND the entire open area between the wooden posts, below the beam and ABOVE the stone rim, leaving only the hanging rope opaque there. Those open spaces must have true zero-alpha transparency. Preserve the dark deep interior BELOW the stone rim inside the well as opaque. Do not add anything, do not redraw or move the well, no ground or cast shadow. Transparent clean cutout game sprite.
```

El PNG seleccionado conserva su alfa original. Godot separa sus regiones mediante AtlasTexture para profundidad, sin editar sus píxeles. La colisión del brocal sigue siendo Rect2(205, 115, 40, 40); los postes no añaden obstáculos. Se conservan identificadores internos FOUNTAIN_POSITION y FOUNTAIN_BOUNDS para limitar el cambio; los textos visibles dicen pozo.

