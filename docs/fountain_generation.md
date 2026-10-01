# Generación de los recursos de la fuente

Herramienta: ImageGen integrada, con fondo transparente. Se reutilizó el kit del patio; solo se generaron la fuente y la vecina. Los motivos de vestimenta son inspiración provisional, no documentación cultural.

## Fuente

Archivo: `assets/street/fountain_atlas.png`. La pila y el surtidor se recortan mediante AtlasTexture en Godot, conservando el PNG original.

```text
Use case: illustration-story. Production transparent game prop sprite atlas, for a warm modern hand-painted 2D top-down 3/4 narrative adventure. Reference images show the game's courtyard painting and stucco/tile architecture; match that exact warm painterly soft-outline style. NEW SPECIFIC PROP ONLY: an everyday modest old community fountain, pale cream weathered stone, octagonal wide rim, low raised basin, teal-blue water, simple short central rounded stone pedestal with tiny spout, subtle dark moisture and worn chips, no statues, no tiers, no European monument, no magic, no symbols, no text. Two SEPARATE isolated components on one transparent 1024x1024 atlas: TOP HALF the entire low octagonal stone basin with blue-green water viewed at 3/4, physical footprint fits ellipse about 480px wide and 310px deep, thick rim, short front stone wall, transparent outside silhouette, NO central pedestal in this basin sprite; BOTTOM HALF a single separate short central pedestal with small normal stream, upright matching same perspective, about 180px wide and 210px tall, transparent outside. Leave generous clear transparent space separating components. Light from upper left, little embedded shadow only, no cast ground shadow. Both pieces belong to SAME fountain, assembled in Godot with a separate low front rim for Y-sorting. Avoid flowers and any decorative magical marks. Crisp detailed painted materials, designed to read at small game scale, not pixel art, not photorealistic, not geometric flat vectors.
```

## Vecina

Archivo: `assets/characters/vecina/vecina.png`. Pose frontal estática, suficiente para su papel actual. No se añadieron animaciones ni comportamiento.

```text
Use case: illustration-story. ONE isolated full-body game NPC sprite on genuinely transparent background, warm modern 2D painted indie narrative game, top-down 3/4 perspective matching the reference protagonist and grandmother, soft shapes and hand-painted details. Reference images are STYLE REFERENCES ONLY; create a DISTINCT adult woman neighbor age 35-45 in a contemporary fictional Oaxacan village. Warm medium brown skin, expressive friendly adult face with mature proportions, dark hair braided and gathered in low bun, no gray hair or head scarf. Everyday dusty terracotta/rose cotton blouse with only tiny simple cream stitched cuff/neck details, long simple deep teal skirt with very subtle hem wear, plain brown sandals. NOT grandmother's black floral blouse/cream floral skirt, NOT protagonist's white blouse/coral skirt/turquoise satchel, NOT elaborate ceremonial outfit. Natural adult silhouette, modest slightly stylized head, no anime, no chibi. Standing idle frontal 3/4 facing slightly toward screen left, one arm hanging relaxed and the other resting lightly at her waist, approachable neutral slight smile. Feet both clearly visible on same floor line. Entire body head to sandals centered with 12% empty transparent margins, no ground, no scenery, no shadow, no text, no border, no alternative poses. Consistent warm upper-left lighting, readable at 75 pixels tall, elegant contemporary illustration matching existing game's character art. Cultural embroidery is an original provisional artistic motif; no sacred symbols.
```

## Limpieza de transparencia de la vecina

```text
Use case: background-extraction. Edit target is the attached generated neighbor sprite. Keep the woman EXACTLY unchanged: same face, age, dark braided bun, terracotta blouse, teal skirt, sandals, pose, proportions, painted details and every opaque character pixel. REMOVE ALL the colored/dark glowing haze surrounding the woman, ALL backdrop gradient, ALL ground shadow, ALL background pixels. Return a clean game character cutout with genuinely fully transparent alpha=0 outside the silhouette and normal antialiased edges only, including between arm and torso and around sandals. Do not repaint, change outfit, change pose, add scenery, text, borders, or crop any part of her body. The output is a production Sprite2D asset; a semi-transparent cloud or vignette around her is unacceptable.
```

