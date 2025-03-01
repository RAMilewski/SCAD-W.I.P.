height = 20;
size = height/4;
ratio = 1.4;
rounding = size/5;
gap = 0.2;

module tooth() intersection() {
    $fn=160; 
    translate([0, gap/2])
    // STEP 3: Quad offset
    // external
    offset(rounding) offset(-rounding)
    // internal
    offset(-rounding) offset(rounding)
    // adding rounding to sides to cancel radius when looping
    // STEP 1
    polygon([
        [-size - rounding, -size/2], // left shoulder
        [-size/2  * (2-ratio), -size/2], // left neck
        // STEP 2 (ratio)
        [-size*ratio/2, size/2], // left ear
        [size*ratio/2, size/2], // right ear
        [size/2 * (2-ratio), -size/2], // right neck

        [size + rounding, -size/2], // right shoulder
        [size + rounding, -size*2], // right bottom
        [-size - rounding, -size*2], // left bottom
    ]); 

    // shave off the rounded bit of the shoulders
    translate([-size, -size*4]) square([size*2, size*5]);
}


module tooth_cut() difference() {
    // STEP 4
    tooth();
    offset(-gap) tooth();
    // STEP 5
    translate([-size*2, -size*5 - size/2 - gap/2, 0]) square([size*4, size*5]);
}


// this is done in 3D rather than 2D to allow for a taper -- this way the fit
// tightens as the teeth are pushed in, and the glue is squeezed instead of
// scraped
 module tooth_cut_3d() difference() {
    translate([size, 0, -1])
    // STEP 6 & 7
    linear_extrude(height, scale=ratio, convexity=3)
    tooth_cut();
    // STEP 8
    // difference is used to constrain the edges to prevent overlap
    // I tried intersection (to do it in one pass) but performance TANKED!
    translate([-size*2-0.01,-size, -1]) linear_extrude(height+2) square([size*2, size*2]);
    translate([size*2+0.01,-size, -1]) linear_extrude(height+2) square([size*2, size*2]);
}

// will get at least length
module teeth_cut_3d(length) {
    n = ceil(length / (size*2))+2;
    real_length = n * size*2;

    // STEP 9
    for (i=[0:n-1])
        translate([i*size*2 - real_length/2, 0]) tooth_cut_3d();

}

module dovetail_demo() difference() {
    linear_extrude(18) square([110, 60], center=true);
    // STEP 10
    teeth_cut_3d(300);
}

dovetail_demo();
