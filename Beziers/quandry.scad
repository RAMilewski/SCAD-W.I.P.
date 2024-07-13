include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bez1 = flatten([
    bez_begin ([-50,0,0],   90, 50, p=90),
    bez_tang  ([-50,25,0],  90, 50, p=90),  
    bez_tang  ([0,70,30],    0, 25, p=90),
    bez_tang  ([50,25,0],   -90, 25, p=90),
    bez_tang  ([50,0,0],   -90, 25, p=90),
    bez_tang  ([0,-50,30], 180, 50, p=90),    
    bez_end   ([-50,0,0],  -90, 50, p=90)
]);

bez2 = flatten([
    bez_begin ([-50,0,50],   90, 25, p=90),
    bez_tang  ([-50,25,50],   90, 25, p=90),  
    bez_tang  ([0,70,90],    0, 25, p=90),
    bez_tang  ([50,25,50],   -90, 25, p=90),
    bez_tang  ([50,0,50],   -90, 25, p=90),
    bez_tang  ([0,-50,90], 180, 25, p=90),    
    bez_end   ([-50,0,50],  -90, 25, p=90)
]);



height = 45;
sub_base = octagon(d=71, rounding=2, $fn=128);
base = octagon(d=75, rounding=2, $fn=128);
interior = regular_ngon(n=len(base), d=60);

  skin([ sub_base, base, base, sub_base, interior], z=[0,2,height, height, 2], slices=0, refine=1, method="reindex");





/*

ss = 16;
//debug_bezier(bez1);
path1 = bezpath_curve(bez1, splinesteps = ss);
//stroke(path1, closed = true);

debug_bezier(bez2);
path2 = bezpath_curve(bez2, splinesteps = ss);
//stroke(path2, closed = true);

skin([path1,path2], refine = 10,slices = 50);



bez1 = flatten([
    bez_begin ([-50,0,0],   90, 50, p=90),
    bez_tang  ([-50,25,0],  90, 50, p=90),  
    bez_tang  ([0,70,30],    0, 25, p=90),
    bez_tang  ([50,25,0],   -90, 25, p=90),
    bez_tang  ([50,0,0],   -90, 25, p=90),
    bez_tang  ([0,-50,30], 180, 50, p=90),    
    bez_end   ([-50,0,0],  -90, 50, p=90)
]);

bez2 = flatten([
    bez_begin ([-50,0,50],   90, 25, p=90),
    bez_tang  ([-50,25,50],   90, 25, p=90),  
    bez_tang  ([0,70,120],    0, 25, p=90),
    bez_tang  ([50,25,50],   -90, 25, p=90),
    bez_tang  ([50,0,50],   -90, 25, p=90),
    bez_tang  ([0,-50,120], 180, 25, p=90),    
    bez_end   ([-50,0,50],  -90, 25, p=90)
]);












bez = flatten([
    bez_begin([0,25],   40, 40),
    bez_joint([0,-25],  30, 150, 60, 60),
    bez_end  ([0,25],  140, 40)
]);

debug_bezier(bez, N=3);


bez = flatten([
    bez_begin([-50,0],  90, 25),
    bez_tang ([0,50],    0, 25),
    bez_tang ([50,0],  -90, 25),
    bez_tang ([0,-50], 180, 25),
    bez_end  ([-50,0], -90, 25)
]);

debug_bezier(bez, N=3);




/* */
