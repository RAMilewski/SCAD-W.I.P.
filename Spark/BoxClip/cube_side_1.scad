include<BOSL2/std.scad>

fudge = 0;       //[0:1:10]
logo_size = 30;  //[20:1:50]
logo_rot = 40;   //[30:1:60]
cutout = 60;
    
difference() {
    import("reaction_wheel_cube_1.stl");
    cyl(h = 10, r = cutout);
}

*zrot(logo_rot) logo(logo_size);

module logo(size) {
    zrot_copies(n=4)
    back(size-fudge) text3d("M", font = "Arial Black", center = true,  size = size);
}