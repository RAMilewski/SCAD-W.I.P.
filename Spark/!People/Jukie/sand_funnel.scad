include <BOSL2/std.scad>

$fn = 144;
tube_od  = 23;
tube_h   = 50;
throat_d = 25.4/8;   // 3.175mm
funnel_d = 20;
flange   = 15; 
diff() {
    // Main tube
    cyl(h=tube_h, d=tube_od, anchor=CENTER){
        // Funnel
        tag("remove") zflip_copy() 
            position(TOP) cyl( h=25, d1=throat_d, d2=funnel_d, anchor= TOP);
        // Center flange
        cyl(d = tube_od+flange, h = 0.8)
            zflip_copy()position(TOP) cyl(d2 = tube_od, d1 = tube_od + flange, h = 0.6, anchor = BOT);
       
            
    }
  
}