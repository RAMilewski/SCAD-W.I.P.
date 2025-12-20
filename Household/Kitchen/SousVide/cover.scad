// Cover for a Cambro 6L square container with space for a Breville Joule Sous Vide stick.

include<BOSL2/std.scad>

$fn = 72;


//back_half(y = 30, s=250) right_half(x = 30, s=250) 
diff() {
    cuboid([215,215,3], rounding = 14.5*2.414, edges = "Z") {
        attach(TOP,BOT) rect_tube(h = 10, size = 198, wall = 3, rounding = 11.1*2.424);
            tag("remove") {
                position(BACK+RIGHT) zrot(45) cuboid([45,50,30], anchor = RIGHT){
                    position(LEFT)  cyl(d = 50, h = 30);
                    position(FWD) left(2.5) #rounding_edge_mask(l = 20, r = 5, ang = 45, spin = 180);
                    position(BACK) left(2.5) #rounding_edge_mask(l = 20, r = 5, ang = 45, spin = 135);
                }

            }
    }

}
//move([20,55,20]) zrot(45) ruler();

