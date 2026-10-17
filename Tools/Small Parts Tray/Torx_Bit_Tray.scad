include <BOSL2/std.scad>

$export_name = "TorxTray";
$fs=0.25;$fa=0.25;

//left_half(x=18)

diff() {
    cuboid([46,77,15], rounding = 3, except = BOT) {
        attach(TOP, LEFT, inside=true) right(3) tag("remove")
            hemicyl(65, 15, thickness = 10, rounding= -3, end_rounding=-3, extra = 1);
        position(TOP) right(18) ycopies(n = 10, spacing = 7.1) tag("remove")
            zrot(180/6) cyl(h = 10, d1 = 4, d2 = 4.5, chamfer2 = -1, 
                circum = true, $fn = 6, anchor = TOP);
        right(18) down(2) tag("remove") cuboid([1.5,70,5]);
    
    
    }
}

