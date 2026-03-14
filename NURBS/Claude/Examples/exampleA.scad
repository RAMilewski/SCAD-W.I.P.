include <BOSL2/std.scad>
   include <BOSL2/nurbs.scad>
   include <../nurbs_interp.scad>
//

   cdata = [repeat([0,0,-15],6),
         [[20, 0, 0], [10, 17.3205, 0], [-10, 17.3205, 0], [-20, 0, 0], [-10, -17.3205, 0], [10, -17.3205, 0]], 
         [[20, 0, 15], [10, 17.3205, 15], [-10, 17.3205, 15], [-20, 0, 15], [-10, -17.3205, 15], [10, -17.3205, 15]],
         [[20, 0, 30], [10, 17.3205, 30], [-10, 17.3205, 30], [-20, 0, 30], [-10, -17.3205, 30], [10, -17.3205, 30]],
         [[20, 0, 45], [10, 17.3205, 45], [-10, 17.3205, 45], [-20, 0, 45], [-10, -17.3205, 45], [10, -17.3205, 45]],
         [[0,0,60],[0,0,60],[0,0,60],[0,0,60],[0,0,60],[0,0,60]]
        ];
fdata = path2d(cdata[1]);
debug_nurbs_interp(path2d(fdata), 3, splinesteps=32, type="closed",width=1,method="dynamic");
debug_nurbs_interp_surface(cdata, [3,3], splinesteps=32,method="dynamic", type=(["clamped","closed"]));//end_u_normal=4*UP+0*RIGHT,start_u_normal=3*DOWN);
