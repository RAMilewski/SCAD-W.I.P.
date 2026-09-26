include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/*      Metric Thread Pitches

Size	   Coarse pitch   Fine pitch (ISO 261)	 Tap drill (coarse)
M2	    0.40 mm	       0.25 mm	              1.6 mm
M2.5    	0.45 mm	       0.35 mm	              2.05 mm (2.1 in practice)
M3	    0.50 mm	       0.35 mm	              2.5 mm
M4	    0.70 mm	       0.50 mm	              3.3 mm
M5	    0.80 mm	       0.50 mm	              4.2 mm
*/

part = "shell";  //[shell,ring]

pitch = 0.5;    //[0.4:M2, 0.45:M2.5, 0.5:M3, 0.7:M4, 0.8:M5 ]
dia = 25;
len = 10;
wall = 1;
flair = 4;
base = 0.5;

$fn = 144;
$export_name = str("thread_test_",part);


//back_half()

if (part == "shell")
    shell();
else
    ring();



module shell() {
    diff() {
        tube(h = len,  id = dia-pitch, wall = wall, orounding1 = -flair) {
            position(TOP) tag("remove")
                threaded_rod(d = dia, h = len/2, pitch = pitch, bevel2 = true,
                lead_in_shape = "sqrt", internal = true, anchor = TOP);
            position(BOT) tube(h = base, rounding1 = base, teardrop = true,
                id = dia-pitch, od = dia + 2*wall + 2*flair, anchor = TOP);
       }   
    }
};



module ring(){
    diff() {
        threaded_rod(d = dia, h = len, pitch = pitch, bevel = 0.75, lead_in_shape = "sqrt");
        tag("remove") cyl(d = dia - 3*wall, h = 11);
    }   
};
