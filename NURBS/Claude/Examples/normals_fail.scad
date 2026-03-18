include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<../nurbs_interp.scad>


method="centripetal";   // [length,centripetal,dynamic,foley]
//method="length";
//method="centripetal";
//method="dynamic";
//method="foley";

data1 = [ repeat([0,0,-15],9),
           for(i=[0:4]) path3d(regular_ngon(n=9, side=i==2?25:15),i*15),
           repeat([0,0,5*15],9)
        ];

xdistribute(75){
  debug_nurbs_interp_surface(data1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0);
  debug_nurbs_interp_surface(data1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=3*DOWN, normal2=2*UP);  
  debug_nurbs_interp_surface(data1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=5*DOWN, normal2=7*UP);  
  debug_nurbs_interp_surface(data1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=5*DOWN, normal2=7*UP,u_edges=3);  
}

