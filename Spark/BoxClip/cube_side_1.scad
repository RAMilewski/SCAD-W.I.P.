include<BOSL2/std.scad>
//include<reaction_wheel_cube_1.scad>



fudge = 8.75;       //[0:0.25:20]
logo_size = 46;  //[20:1:50]
logo_rot = 45;   //[30:1:60]
cutout = 63;
zlogo = 2.75;     // [0:0.25:5]


    
    difference() {
        import("reaction_wheel_cube_1.stl");
        cyl(h= 10, r = cutout, $fn = 72);
    }
    zrot(logo_rot) logo(logo_size);

module logo(size) {
    zrot_copies(n=4)
    back(size-fudge) down(zlogo) text3d("M", h = 1.85, font = "Arial Black", center = true, anchor = CENTER, size = size);
}