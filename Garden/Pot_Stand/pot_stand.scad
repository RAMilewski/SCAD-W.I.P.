include<BOSL2/std.scad>
$fn = 144;

/*
    rounded_prism(rect([125,50]), apply(left(12.5),rect([100,50])), h = 25, 
        joint_top = 5, joint_bot = 0, joint_sides = 5, anchor = BOT)
            position([TOP]) right(30) down(5) onion(r = 15, ang = 50, anchor = BOT);


    back(60)            
    diff() {
        prismoid([125,50],[100,50], shift = [-12.5,0], rounding = 5, h = 25)
         edge_profile([TOP,"Z"], except = TOP+RIGHT)
             mask2d_roundover(r=5);
    }
*/
    
    tex = texture("rough");
    fwd(80) 
    linear_sweep(
        rect([125,50]), texture=tex, h=30, tex_depth=0.2,
        tex_size=[10,10], style="min_edge");

 /*

 include <BOSL2/std.scad>
tex = texture("rough");
linear_sweep(
    rect(30), texture=tex, h=30, tex_depth=0.2,
    tex_size=[10,10], style="min_edge"
);

 /* */