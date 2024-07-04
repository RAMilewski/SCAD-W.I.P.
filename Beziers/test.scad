
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>


bez =  [[0,0], [10,30], [20,0], [30,-30], [40,0], [50,30],[60,0],
       // [70,-30], [80,0], [90,30], [100,0], [110,-30], [120,0],
       // [130,30], [140,0], [150,-30], [160,0]
        ];

N = 3;
debug_bezier(bez, N = N);

//stroke(bezpath_curve(bez,N=N,splinesteps = 64));


/*

debug_bezier(bez[$t*4], N=$t*4+2);
echo($t);
move([60,30]) color("blue") text(str("N = ",($t*4+2)));

*/