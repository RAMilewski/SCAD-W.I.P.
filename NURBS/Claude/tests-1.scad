include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
$vpr=[60,0,45];
$vpt=[0,0,10];
$vpd= 120;
surface = [   
  for(i=[0:8]) zrot(i*16,path3d(star(or=25,ir=22, n=11),i*2)),
];
nurbs_interp_surface(surface, method="dynamic", degree=2, col_wrap=true, row_wrap=true, extra_pts=7, smooth=2);

