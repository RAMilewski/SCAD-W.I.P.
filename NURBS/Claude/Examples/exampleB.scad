include <BOSL2/std.scad>
   include <BOSL2/nurbs.scad>
   include <../nurbs_interp.scad>
//


ddata = [ repeat([0,0,-15],9),
          for(i=[0:3]) path3d(regular_ngon(n=9, side=15),i*15),
          repeat([0,0,60],9)
        ];
fdata = path2d(ddata[1])+random_points(9,dim=2)*.01;
debug_nurbs_interp(fdata, 2, splinesteps=32, type="closed",width=1,method="centripetal");
//debug_nurbs_interp(fdata, 5, splinesteps=32, type="closed",width=1,method="dynamic");
debug_nurbs_interp_surface(ddata, [2,2], splinesteps=32,method="centripetal",type=(["clamped","closed"]),end_normal=4*UP+0*RIGHT,start_normal=3*DOWN);
color("black")move_copies(fdata)circle(r=1,$fn=16);
