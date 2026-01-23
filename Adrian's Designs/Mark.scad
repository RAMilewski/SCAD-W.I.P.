include<BOSL2/std.scad>

pat1 = [[0,0,1],[1,1,1],[1,1,1]];

pat2 = [[0,1],[1,1]];

top_half()
    textured_tile(pat1, [2,2,1],  tex_reps=1)
        align(TOP, RIGHT+FWD)
            textured_tile(pat2, [1,1,1], tex_reps=1);
