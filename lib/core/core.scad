// core.scad — enums, checks, BOM-echo, util
// Eenheden: mm

// — Helpers
// True als 's' exact voorkomt in lijst 'a' (zonder search()).
function _contains(a, s) = len([for (x = a) if (x == s) 1]) > 0;

// — Enums
function _enum_top_valid(s) =
  _contains(["klemband","sponsrubber","koordzoom","onafgewerkt","gezoomd","kopring","snapring","viltring"], s);

function _enum_bottom_valid(s) =
  _contains(["enkel","dubbel","platdicht"], s);

// Bodem-subopties
function _enum_bottom_opt_valid(bottom, opt) =
    (bottom=="enkel" || bottom=="dubbel")
      ? _contains(["zonder","lusje","gat","gat_lusje","doorlaat_ophangstang"], opt)
      : (bottom=="platdicht" ? _contains(["zonder","ophangstang","zoom"], opt) : false);

// Productzijde (oriëntatie hoofdmateriaal)
function _enum_productzijde_valid(s) = _contains(["buiten","binnen"], s);

// — Utilities
module _bom_echo(bom_tag, params_list=[]) {
  echo("BOM_ITEM:", bom_tag, params_list);
}

// Gelijk verdeelde ringposities (geen ringen exact op uiteinden)
function _auto_ring_positions(L, n) =
  (n <= 0) ? [] : [ for (i=[1:n]) L * i/(n+1) ];
