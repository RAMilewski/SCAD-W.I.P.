include<BOSL2/std.scad>
include<wilburDR_200x288.scad>

back(74) zrot(-90) import ("mesh_stl.stl");

right(60)
textured_tile(wilburDR, [50,74,2],tex_depth = 1, tex_reps = [1,1], anchor = FWD+LEFT);

