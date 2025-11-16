include<BOSL2/std.scad>

card = [63,88,0.2];

size = [72,95,4];
depth = 20;



diff(){
    cuboid(size, rounding = 5, edges = "Z"){
        position(BACK) tag("remove") cyl(h = 4, d = 15 );
        position(BACK+BOT) tag("remove"){
                    fwd(10) xcopies(n = 2, spacing = card.x + 4) cuboid([2.5,5.5,4], anchor = BOT);
                }
                position(FWD+BOT) tag("remove") {
                    back(12) xcopies(n = 2, spacing = card.x-2) 
                        zrot($idx * 90) zrot(45) left_half()  tube($fn=4, h = 4, id = 5, wall = 3, anchor = BOT);
                   
                }
    }
}


right(80){
    diff(){
            cuboid(size, rounding = 5, edges = "Z"){
                position(BACK+TOP) {
                    fwd(10) xcopies(n = 2, spacing = card.x + 4) cuboid([2,5,depth], anchor = BOT);
                }
                position(FWD+TOP) {
                    back(12) xcopies(n = 2, spacing = card.x-2) 
                        zrot($idx * 90) zrot(45) left_half()  tube($fn=4, h = depth, id = 5, wall = 3, anchor = BOT);
            

                }
            }
    }
}
move([0,-40,10]) ruler();