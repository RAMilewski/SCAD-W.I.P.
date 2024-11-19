include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 144;

function cpd(r) = r * (4/3) * tan(180/8); // Control pt distance for quarter round.

r1 = 25; // Major radius of the coin
r2= 5;  // radius of the edge
cz = 1; // center z

body = bezpath_curve(flatten([
    bez_begin([0, -r2], RIGHT, 10),
    bez_tang ([r1-r2,-r2], 0, cpd(r2)),
    bez_tang ([r1,0], 90, cpd(r2)),
    bez_tang ([r1-r2, r2], 180, cpd(r2)),
    bez_end([0,cz], RIGHT, 12),
]));

diff(){
    rotate_sweep(body,360);
    zrot_copies(n = 8, r = r1 + r2 -1)
        tag("remove") cyl(h = r2*2, r = 8);
        tag("remove") text3d("OS", font = "Arial:bold", size = 14, h = r2, anchor = CENTER+BOT, atype = "ycenter");
}
/*
    color("red"){
        move(cylindrical_to_xyz(r1+r2-9,-90,r2-.1)) sphere(.1);
        move(cylindrical_to_xyz(r1,-75.3,0)) sphere(.1);
        move(cylindrical_to_xyz(r1+r2-9,-90,-r2+.1)) sphere(.1);
        move(cylindrical_to_xyz(r1,-104.7,0)) sphere(.1);
    }


/* */