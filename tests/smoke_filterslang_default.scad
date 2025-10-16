// tests/smoke_filterslang_default.scad
include <../products/filterslang/filterslang.scad>;

filterslang(
  L=2000, D=160, t=2, medium="PE_500",
  top="snapring", open_top=false,
  bottom="platdicht", bottom_opt="zoom",
  rings_auto=true, rings_count=6, ring_w=10, ring_t=2,
  reinforce_enable=true, reinforce_side="boven", reinforce_spans=[[100,200]],
  productzijde="buiten",
  bom_tag="SMOKE_DEFAULT"
);
