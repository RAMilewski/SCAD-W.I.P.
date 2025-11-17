include<BOSL2/std.scad>

$fn = 72;

card = [63,88,0.4];
floor = 3;
post = 8;
size = [card.x + 3 * post,card.y + 1.5 * post,floor];
depth = 20;
post_hole = post + 1.5;

echo(size);


base();   right(size.x + 35) lid();


module card() { cuboid(card, rounding = 4, edges = "Z"); }


module lid() {
    diff(){
        cuboid(size, rounding = 5, edges = "Z"){
            position(BACK) tag("remove") yscale(2) cyl(h = floor, d = 25 , rounding = -floor/2);
            tag("remove"){
                    grid_copies(spacing = [card.x + post + 1, card.y* 0.5], n = [2,2]) 
                        cyl(h = size.z, d = post_hole, rounding = -floor/2);
                    fwd(card.y/2 - post_hole/3) xcopies(spacing = card.x/2)
                        cyl(h = size.z, d = post_hole, rounding = -floor/2);
            }
        }
    }
}

module base() {
    cuboid(size, rounding = 5, edges = "Z"){
        position(TOP) grid_copies(spacing = [card.x + post + 1, card.y* 0.5], n = [2,2]) 
                    cyl(h = depth, d = post, rounding1 = -post/4, rounding2 = post/2, anchor = BOT);
        position(TOP) fwd(card.y/2 - post_hole/3) xcopies(spacing = card.x/2)
                    cyl(h = depth, d = post, rounding1 = -post/4, rounding2 = post/2, anchor = BOT);
    }
}

