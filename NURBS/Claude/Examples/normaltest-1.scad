include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<../nurbs_interp.scad>

method="centripetal";   // [length,centripetal,dynamic,foley,quadratic]

data1 = [ repeat([0,0,-15],9),
         for(i=[0:4]) path3d(regular_ngon(n=9, side=i==2?25:15),i*15),
         repeat([0,0,5*15],9)
      ];


for (ue = [2,3,4]) {
    left(300 - ue * 100) {
        debug_nurbs_interp_surface(data1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
            normal2=7*UP+2*RIGHT,u_edges=[ue],normal1=DOWN+LEFT/4);  

        down(30) xrot(90) text(str("u_edges = ",ue), size = 6, anchor = CENTER);
    }
}