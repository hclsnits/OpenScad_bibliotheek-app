include <../products/filterslang/filterslang.scad>;
// Minimale waarden + handmatige ringen + meerdere versterkingen
filterslang(L=800, D=120, t=1.2, medium="PPS_550", top="gezoomd",
bottom="enkel", bottom_opt="gat_lusje",
rings_auto=false, rings_positions=[200,400,600], ring_w=8, ring_t=1.6,
reinforce_enable=true, reinforce_side="onder", reinforce_spans=[[100,150],[500,650]],
productzijde="binnen", bom_tag="SMOKE_EDGE");