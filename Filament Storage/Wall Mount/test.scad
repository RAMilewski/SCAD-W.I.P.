include <BOSL2/std.scad>
include <BOSL2/threading.scad>

 acme_threaded_rod(d = 40, l=20, pitch=5, starts=3, 
                    blunt_start = false, $fa=1, $fs=1, $slop = 8.3, anchor = TOP);

                    fwd(20) nut("m14x1");
        