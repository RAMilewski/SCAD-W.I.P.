include <BOSL2/std.scad>
$fn = $preview ? 32 : 256;
DIST=23;
SCREWS=[45,135,225, 315];
  diff()
    cuboid([35,35,6],anchor=BOTTOM){
      tag("remove") position(BOTTOM) up(1) cuboid([33,33,6],anchor=BOTTOM);
      tag("keep") zrot_copies(sa=0,n=4) move([-1,-1])position(BOT+BACK+RIGHT)  {
          cyl(d=4,l=6, anchor=BOT)
            tag("remove")cyl(d=2,l=2*6, anchor=BOT);
          cyl(d=6,l=3, anchor=BOTTOM)
            tag("remove") #cyl(d=2,l=2*6, anchor=BOT);
      }
    }

