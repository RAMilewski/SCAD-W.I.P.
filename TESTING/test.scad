include <BOSL2/std.scad>
$fn= $preview ? 60 : 180;

//yrot(180) down(52.5) // for print orientation

difference() {
//outside
prismoid([147,48],[145,40],52.5, shift=[0,-1.5], rounding=[8,2,2,2]);
//inside
down(1.5)
prismoid([144,44],[141,36],52.5, shift=[0,-1.5], rounding=[8,2,2,2]);
}

