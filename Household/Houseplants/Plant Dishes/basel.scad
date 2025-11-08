include <BOSL2/std.scad>
height = 145;
wall = 1.5;   //[0.5:0.25:5]
bottom = 95;
top = 145;
o_base = square(bottom, anchor = CTR);
i_base = square(bottom - 2 * wall, anchor = CTR);
o_top = square(top, anchor = CTR);
i_top = square(top - 2 * wall, anchor = CTR);
//right_half()
  skin([ o_base, o_base, o_top, i_top, i_base], z=[0,wall,height, height, wall], slices=0, refine=1, method="reindex");