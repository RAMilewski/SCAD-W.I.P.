include <BOSL2/std.scad>

$fn = 288;

top_dia = 67;  //id of mason jar ring
top_h = 13;
dia = 120;     //od of bulge
h = 100;       //bulge height 


cyl(top_h, d = top_dia, anchor = BOT){
    position(BOT) up(3) bulb(dia,h)
        position(TOP) up(3) cyl(top_h, d = top_dia, anchor = TOP); 
}


module bulb(d,h,anchor = BOT, spin = 0, orient = UP) {
    attachable(anchor,spin,orient,d = d, h = h ){
        zscale (h/d) spheroid(d = d);
        children();
    }
}
