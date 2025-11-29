use "../Products/Filterslang/fs_filterslang.scad";


/* [Dimensions] */
L = 2000;           // [500:50:4000]
D = 160;            // [80:10:400]
t = 2.0;            // [1:0.5:10]


/* [Material & Ends] */
medium = "PE_500";      // [PE_500, PE_1000, PP, PVC]
top = "snapring";       // [snapring, open, flens]
open_top = false;
bottom = "platdicht";   // [platdicht, open, conisch]
bottom_opt = "zoom";    // [none, zoom, flens]
productzijde = "buiten"; // [buiten, binnen]
bom_tag = "PE500_Medium_Standard";


/* [Rings] */
rings_auto = true;
rings_count = 6;    // [0:1:20]
ring_w = 10;        // [5:1:40]
ring_t = 2;         // [1:0.5:10]


/* [Reinforcement] */
reinforce_enable = true;
reinforce_side = "boven"; // [boven, onder, beide]


/* [Quality] */
fn_segments = 96;   // [24:4:192]


/* [Hidden] */
rings_positions = [];
reinforce_spans = [[100, 200]];


// MAIN CALL

filterslang(
  L = L,
  D = D,
  t = t,
  medium = medium,
  top = top,
  open_top = open_top,
  bottom = bottom,
  bottom_opt = bottom_opt,
  rings_auto = rings_auto,
  rings_count = rings_count,
  rings_positions = rings_positions,
  ring_w = ring_w,
  ring_t = ring_t,
  reinforce_enable = reinforce_enable,
  reinforce_side = reinforce_side,
  reinforce_spans = reinforce_spans,
  productzijde = productzijde,
  bom_tag = bom_tag,
  $fn = fn_segments
);
