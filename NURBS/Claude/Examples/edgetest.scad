include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>

  data = [
       [[-50, 50,  0], [-16, 50,  0], [ 16, 50,  0], [30, 50,  0], [50, 50,  0]],
       [[-50, 16, 0], [-16, 16,  40], [ 16, 16,  30], [30, 16, 20], [50, 16, 0]],
       [[-50,-16, 0], [-16,-16,  35], [ 16,-16,  40], [30,-16, 15], [50,-16, 0]],
       [[-50,-50,  0], [-16,-50,  0], [ 16,-50,  0], [30,-50,  0], [50,-50,  0]],
   ];
   
  prismoid(size1 = [120,120], size2 = [100,100], h = 10);
  up(10)
  debug_nurbs_interp_surface(data, 3, splinesteps=16,
        start_u_der=[0,-1,1],
        end_u_der=[0,-1,-1],
        start_v_der=[1,0,1],
        end_v_der=[1,0,-1]                             
     );