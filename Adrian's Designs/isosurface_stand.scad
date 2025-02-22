include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>



cuboid([45,45,10]) attach(TOP,BOT)
  isosurface(function(p)  (p.x*p.y*p.z^3-3*p.x^2*p.z^2)/norm(p)^2+norm(p)^2, 
  isovalue=[-INF,35], bounding_box=2*[[-10,-10,-5],[10,10,5]], voxel_size=0.5)
    align(TOP, [LEFT+BACK,RIGHT+FWD]) cyl(d=19, h=2, $fn=64);
