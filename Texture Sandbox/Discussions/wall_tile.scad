include<BOSL2/std.scad>
include<TexLib/data/StoneWall2DM_256x256.scad>
textured_tile(texture = StoneWall2DM, size = StoneWall2DM_size, tex_reps = [1,1], tex_depth = 3);