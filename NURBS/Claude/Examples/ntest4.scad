include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<../nurbs_interp.scad>
include<data.scad>


$vpd=1350;
$vpr = [50,5,20];

method="centripetal";   // [length,centripetal,dynamic,foley,fang]

ydistribute(85){

  
xdistribute(75){
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0);
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=3*DOWN, normal2=2*UP);  
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=5*DOWN, normal2=7*UP);
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=4*UP+RIGHT,u_edges=[2],normal1=DOWN+LEFT/4);  
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=4*UP+RIGHT,u_edges=3,normal1=DOWN+LEFT/4);  
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=4*UP+RIGHT,u_edges=4,normal1=DOWN+LEFT/4);  
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=UP+RIGHT/4,u_edges=[2,4],normal1=DOWN+LEFT/4);  
  nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=UP,u_edges=[2,3],normal1=DOWN);  

}


xdistribute(75){
  nurbs_interp_surface(blob2, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0);
  nurbs_interp_surface(blob2, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=2*UP);  
  nurbs_interp_surface(blob2, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=4*UP);  
}


xdistribute(75){
  nurbs_interp_surface(blob3, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0);
  nurbs_interp_surface(blob3, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=2*UP);  
  nurbs_interp_surface(blob3, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=7*DOWN,normal2=5*UP);  
}


xdistribute(75){
  nurbs_interp_surface(blob4, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0);
  nurbs_interp_surface(blob4, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=2*UP);  
}


xdistribute(75){
  nurbs_interp_surface(blob5, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0);
  nurbs_interp_surface(blob5, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=UP);  
}



}

/*  // Random shape maker
oooordata = [repeat([0,0,-15], 9),
         for(i=[0:6]) path3d(scale(1,random_polygon(n=9,angle_sep=.7,size=[50,80])),i*15),
         repeat([0,0,15*7],9)
        ];
*/
