include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

funcs = [
      IDENT, mb_cyl(h = 0.0001, r=28) 
   ];
   voxelsize = 1;
   boundingbox = [[-30,-19,-20], [30,19,20]];
   metaballs(funcs, voxelsize, boundingbox, isovalue=1);



