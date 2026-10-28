include <BOSL2/std.scad>

$fn = 144;
tube_od  = 23;
tube_h   = 50;
throat_d = 25.4/8;   // 3.175mm
funnel_d = 20;
diff() {

    // Main tube
    cyl(h=tube_h, d=tube_od, anchor=CENTER){
        // Center flange
        cyl(r1 = tube_od, r1 = tube_od + 5, h = 1, anchor = BOT);
        position(TOP)
        tag("remove") cyl( h=25, d1=throat_d, d2=funnel_d, anchor= TOP);
        position(BOT)
        tag("remove") cyl( h=25, d2=throat_d, d1=funnel_d, anchor= BOT);
            
    }
  
}