include <BOSL2/std.scad>
$fn=72;

diff("remA")
  recolor("goldenrod") cyl(r=9, h=6)
    tag("remA")diff("remB")
      left(.2)position(RIGHT) cyl(r=8,h=7,anchor=RIGHT)
        tag("remB")diff("remA")
         left(.2)position(LEFT) cyl(r=7,h=7,anchor=LEFT)
           tag("remA")diff("remB")
             left(.2)position(LEFT) cyl(r=6,h=8,anchor=LEFT)
               tag("remB")diff("remA")
                 right(.2)position(RIGHT) cyl(r=5,h=9,anchor=RIGHT)
                   tag("remA")diff("remB")
                     right(.2)position(RIGHT) cyl(r=4,h=10,anchor=RIGHT)
                       tag("remB")left(.2)position(LEFT) cyl(r=3,h=11,anchor=LEFT);


  
