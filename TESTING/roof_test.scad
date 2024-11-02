include <BOSL2/std.scad>

size = 25;
fudge = 9.25;

intersection() {
    roof() logo();
    cuboid ([80,80,4]);
}

module logo(){
    zrot_copies(n = 4, d = size - fudge) zrot(-90)
        text("M", size = size, font = "Arial Black", halign = "center", valign = "baseline");
}