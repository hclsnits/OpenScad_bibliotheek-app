// geom.scad — basisvormen
module tube_len(D=160, t=2, L=200, $fn=96){
difference(){
cylinder(h=L, d=D+2*t, center=false, $fn=$fn);
translate([0,0,0]) cylinder(h=L+0.2, d=D, center=false, $fn=$fn);
}
}