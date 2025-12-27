include<BOSL2/std.scad>

bez1 = flatten([
    bez_begin([-20,0], 45,20),
    bez_tang ([0.,50],  0,10),
    bez_end  ([20, 0],  135,20),
]);

bez2 = flatten([
    bez_begin([-23,0], 45,20),
    bez_tang ([  0,53],  0,13),
    bez_end  ([23, 0], 135,20),
]); 

path1 = bezpath_curve(bez1);
path2 = bezpath_curve(bez2);
path = concat(path1,reverse(path2));

stroke(path, width = 0.25);

polygon(path);

linear_sweep(path, 10);