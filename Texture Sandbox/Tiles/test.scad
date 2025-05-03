include<BOSL2/std.scad>
<<<<<<< Updated upstream
<<<<<<< Updated upstream
include<pathbuilder.scad>

 import("flower.svg", center = true);


=======
=======
>>>>>>> Stashed changes

   img = [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0,.5,.5, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0,.5,.5, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
   ];
   h = 20;
   r = 15;
   ang = len(img[0])/len(img)*h/(2*PI*r)*360;
   rotate_sweep([[15,-10],[15,10]], texture=img,
              tex_reps=1,angle=ang, closed=false);
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
