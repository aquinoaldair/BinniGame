# Corrección de la caminata lateral de Nisa

Herramienta: ImageGen integrada. Referencia de identidad y estilo: `nisa_atlas.png`. Salida seleccionada: `nisa_lateral_walk_atlas.png`, fondo transparente, ocho poses en cuatro columnas y dos filas. Tres ediciones preliminares del atlas completo se descartaron por la ambigüedad del apoyo de las piernas; no se usan en el proyecto.

La lámina independiente se refinó con una [guía vectorial de las piernas](../../../docs/nisa_walk_pose_guide.svg), renderizada por Godot para usarla como referencia. En la guía, rojo identifica la pierna cercana y azul la lejana; esos colores no forman parte de Nisa.

## Prompt de la lámina independiente

Use case: precise-object-edit / identity-preserve.
Create a new, clean TRANSPARENT game animation sprite sheet containing ONLY the eight side-walking poses of the Nisa character from the supplied reference. Reference is identity/style only: the existing walk is faulty, do NOT copy its leg poses.
Layout: exactly FOUR COLUMNS by TWO ROWS, 1536x1024 canvas. Full character body height around 465 pixels in each 384x512 cell, same scale everywhere, centered over a shared ground point. No idle frames, no front/back views, no text, background, grid, ground shadow.
Identical girl as reference: age10, expressive child head, dark long wavy hair half tied behind, cream blouse small flowers, coral skirt same length, brown two-strap sandals, teal crossbody satchel on anatomical left hip. Same warm polished indie illustrated style and 3/4 game perspective. Row1 faces LEFT with teal satchel prominently visible. Row2 faces RIGHT with bag on FAR side, only turquoise sliver behind rear hip; do NOT mirror the bag.
FOUR-POSE LOOP EACH ROW, anatomically distinct near and far legs with consistent occlusion:
1 CONTACT A: VISIBLE CAMERA-SIDE LEG FORWARD, far leg BACK. Near foot is lower in image, far foot a little higher.
2 PASS A: visible camera-side leg STRAIGHT PLANTED UNDER HIP; far leg bent just slightly, heel lifting, passing forwards past planted calf. Feet close to hip axis, no wide stride.
3 CONTACT B: VISIBLE CAMERA-SIDE LEG BACK, far leg FORWARD. This must be clearly the OPPOSITE STRIDE to frame1. Near calf is drawn IN FRONT at the crossing and its sandal is the BACK sandal, larger/brighter/lower than the far FRONT sandal. DO NOT reproduce frame1 with hair/skirt variation. The visible camera-side calf must lean BACKWARDS in frame3.
4 PASS B: FAR leg STRAIGHT PLANTED UNDER HIP, visible camera-side leg slightly bent with sandal swinging forwards, slightly raised. Opposite planted leg to frame2.
For LEFT views: frame1 near/low sandal screen LEFT, far/high sandal RIGHT; frame3 near/low sandal screen RIGHT, far/high sandal LEFT.
For RIGHT views: frame1 near/low sandal screen RIGHT, far/high sandal LEFT; frame3 near/low sandal screen LEFT, far/high sandal RIGHT.
Frame1 and3 are not two copies: visible shin slopes forwards in1, backwards in3, and nearer sandal changes sides. Foreground sandal should be around 14px lower than background sandal on contact poses so the two anatomical legs can be tracked. Small natural stride with foot spread about100px total at this enlarged sprite scale. In passing poses feet nearly overlap under hip and lifted sole is only 12-18px above planted sole.
Arms counter-swing with near leg: camera-side arm BACK when near leg forward (pose1), camera-side arm FORWARD when near leg back (pose3). Let this give a second unmistakable clue that strides alternate.
Keep torso and head perfectly stable, same face, clothes and patterns. No high knees, exposed thighs, lunges, jumping, galloping or running. Calm ordinary walking. Subtle hair/skirt/satchel sway, genuine loop A→pass→B→pass→A. Legs visible below original skirt hem. Clean transparent alpha.

## Refinamiento seleccionado con guía de pose

Edit target = Image1: transparent Nisa eight-frame sheet, FOUR columns xTWO rows.
Image2 = exact LEG POSE GUIDE only, not final style. RED bones mean the NEAR camera-facing leg, BLUE bones mean FAR leg; gray shape is a skirt placeholder. IMPORTANT: map this red/blue leg geometry onto Nisa's natural skin and sandals, DO NOT put colored red/blue lines, labels or any diagram in the output.
Replace the legs in Image1 to FOLLOW Image2's four poses exactly. Especially third column in BOTH rows: the red NEAR leg is directed BACKWARDS, and the blue FAR leg FORWARDS. It is visibly opposite to column1. Where calves cross, the NEAR red leg must be IN FRONT of the FAR blue leg. In row1 column3 this means the visible foreground calf runs diagonally RIGHT to the backward right sandal; leftward-leading calf is the far shaded leg. In row2 column3 visible foreground calf runs diagonally LEFT to backward left sandal, forward right calf is far shaded leg. The backward near sandal is lower on the canvas than forward far sandal, just as in diagram.
Columns2 and4 follow the guide's quiet passing poses (opposite planted legs, low lifted feet, close to hip axis). Not high-knee march or a repeated split stride.
Retain ALL character identity, face, head height, hair, cream blouse, coral skirt, brown sandals, teal bag on anatomical LEFT hip, shading and illustrated style from Image1. Row1 LEFT, row2 RIGHT, correct bag visibility as in Image1. Set camera-side arms naturally opposite the near leg (back on contact1, forward on contact3) for a clear alternating gait.
Preserve 1536x1024 resolution, four columns two rows, same body height and transparent spacing. Only poses of lower legs and small corresponding arm swing are changed; no redesign. Actual transparent alpha background, no floor, ground shadows, boxes, extra sprites, text or coloured guide marks.
