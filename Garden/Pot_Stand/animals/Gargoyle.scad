include<BOSL2/std.scad>
$fn = 144;

/* [Gargoyle Settngs] */
gargoyle = 14;   // [1:24]
size = 0.4;      // [0.1:0.1:3]
fill = true;     // [true,false]
fill_trim = 3;   // [0:0.5:30]

$align_msg = false;

daemon = str("./Gargoyle_",format2(gargoyle),"_MOD.stl");

dimY = fill ? fill_trim : 62;

scale(size) {
    diff() {
        fwd(4.5) prismoid([18.5,61.5],[20.5,57],h = 4.75, shift=[0,2.255])
        align(BACK, inside = true) back(0.1) cuboid([21,dimY,5], anchor = BACK);
    }
    import(daemon); 
}
    
function format2(n) = str(n < 10 ? "0" : "", n);

//up(5.01) fwd(50) zrot(90) ruler();


module filler() {
}

