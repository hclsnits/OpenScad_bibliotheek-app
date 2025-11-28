// tests/smoke_filterslang_edgecases_dxf.scad
// 2D projection for DXF export (edge case parameters)
use <../products/filterslang/filterslang.scad>;

projection(cut=false)
filterslang(
  L=500, D=80, t=1.5, medium="PPS_550",
  top="klemband", open_top=true,
  bottom="enkel", bottom_opt="gat_lusje",
  rings_auto=false, rings_positions=[100, 250, 400], ring_w=8, ring_t=1.5,
  reinforce_enable=false, reinforce_side="boven", reinforce_spans=[],
  productzijde="binnen",
  bom_tag="SMOKE_EDGE_DXF",
  $fn=48
);
