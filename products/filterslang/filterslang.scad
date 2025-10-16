use <../../lib/core/core.scad>;
use <../../lib/core/geom.scad>;


module filterslang(
L=2000, D=160, t=2, medium="PE_500",
top="snapring", open_top=false,
bottom="enkel", bottom_opt="zonder",
rings_auto=true, rings_count=6, rings_positions=[], ring_w=10, ring_t=2,
reinforce_enable=true, reinforce_side="boven", reinforce_spans=[[200,400]],
productzijde="buiten",
bom_tag="bag_std", $fn=96
){
// Validaties
assert(L>0 && D>0 && t>0, "L,D,t must be > 0");
assert(_enum_top_valid(top), str("Unknown top: ", top));
assert(_enum_bottom_valid(bottom), str("Unknown bottom: ", bottom));
assert(_enum_bottom_opt_valid(bottom, bottom_opt), str("Invalid bottom_opt ", bottom_opt));
assert(_enum_productzijde_valid(productzijde), "productzijde must be 'buiten' or 'binnen'");
assert(ring_w>0 && ring_t>0, "ring_w, ring_t must be > 0");


ring_pos = rings_auto ? _auto_ring_positions(L, rings_count) : rings_positions;
for (p = ring_pos) assert(p>0 && p<L, "ring position must be within (0,L)");


_bom_echo(bom_tag, [
"L",L,"D",D,"t",t,"medium",medium,
"top",top,"open_top",open_top,
"bottom",bottom,"bottom_opt",bottom_opt,
"rings",ring_pos,"ring_w",ring_w,"ring_t",ring_t,
"reinforce",reinforce_enable,"rein_side",reinforce_side,"rein_spans",reinforce_spans,
"productzijde",productzijde
]);


mat_col = (productzijde=="buiten") ? [1,1,1] : [0.92,0.92,0.92];
color(mat_col) tube_len(D=D, t=t, L=L, $fn=$fn);


// Top (schematisch)
if (!open_top) {
if (top=="snapring" || top=="kopring") {
translate([0,0,0]) difference(){
cylinder(h=15, d=D+2*t+2*ring_t, $fn=$fn);
cylinder(h=15+0.2, d=D+2*t, $fn=$fn);
}
} else {
translate([0,0,0]) cylinder(h=6, d=D+2*t, $fn=$fn);
}
}


// Bodem basis
if (bottom=="platdicht") {
translate([0,0,L-0.6]) cylinder(h=0.6, d=D+2*t, $fn=$fn);
} else if (bottom=="enkel") {
translate([0,0,L-10]) cylinder(h=10, d=D+2*t, $fn=$fn);
translate([0,0,L-0.5]) cylinder(h=0.5, d=D, $fn=$fn);
} else if (bottom=="dubbel") {
translate([0,0,L-18]) cylinder(h=18, d=D+2*t, $fn=$fn);
translate([0,0,L-0.5]) cylinder(h=0.5, d=D, $fn=$fn);
}


// Bodem subopties
hole_d = D*0.25; loop_w = 18; loop_t = 4; slot_w = D*0.6; slot_h = 10;
if (bottom=="enkel" || bottom=="dubbel"){
if (bottom_opt=="lusje" || bottom_opt=="gat_lusje"){
translate([D/2 + t + 6, 0, L-12]) rotate([0,90,0])
difference(){ cube([loop_w, loop_t, 8], center=true);
cube([loop_w-8, loop_t-2, 8.2], center=true); }
}
if (bottom_opt=="gat" || bottom_opt=="gat_lusje"){
translate([0,0,L-0.8]) cylinder(h=1.0, d=hole_d, $fn=$fn);
}
if (bottom_opt=="doorlaat_ophangstang"){
translate([-slot_w/2,-slot_h/2, L-0.8]) cube([slot_w, slot_h, 1.0], center=false);
}
} else if (bottom=="platdicht"){
if (bottom_opt=="ophangstang"){
translate([-slot_w/2,-slot_h/2, L-0.6]) cube([slot_w, slot_h, 1.0], center=false);
} else if (bottom_opt=="zoom"){
translate([0,0,L-2]) difference(){
cylinder(h=2, d=D+2*t+3, $fn=$fn);
cylinder(h=2.2, d=D+2*t-3, $fn=$fn);
}
}
}


// Tussenringen
for (p = ring_pos){
translate([0,0,p-ring_w/2]) difference(){
cylinder(h=ring_w, d=D+2*t+2*ring_t, $fn=$fn);
cylinder(h=ring_w+0.2, d=D+2*t, $fn=$fn);
}
}


// Versterking(en)
if (reinforce_enable){
for (span = reinforce_spans){
zs = span[0]; ze = span[1];
assert(ze>zs && zs>=0 && ze<=L, "reinforce span invalid");
is_outer = (reinforce_side=="boven");
d_outer = is_outer ? D+2*t+0.1 : D-0.1; thick=t;
translate([0,0,zs]) difference(){
cylinder(h=ze-zs, d=d_outer + (is_outer? 2*thick : 0), $fn=$fn);
cylinder(h=ze-zs+0.2, d=is_outer ? d_outer : d_outer-2*thick, $fn=$fn);
}
}
}
}