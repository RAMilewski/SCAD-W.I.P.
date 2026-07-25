include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <skull_pile_128x128.scad>

    lamp_d = 121;
    lamp_z = 51;
    wizardstick_d = 43;
    magnet_d = 17.5;
    magnet_z = 3;
    tinylamp_d = 135;
    tinylamp_z = 75;
    
    $fn = 96;
    
    //textured_tile(texture = skull_pile, size = [50, 50, 1], tex_reps = [1,1], tex_depth = 1);
  
    part = "holder3"; //["holder", "base", "lid", "holder2", "holder3"]

    
if (part == "holder") holder();
if (part == "base") back_half(s = 300) base(); 
if (part == "lid") back_half(s = 300) lid();
if (part == "holder2") holder2();
if (part == "holder3") holder3();
    
module holder () {    
    difference() {
        union() {
        tube(h=60, od=142, wall=3, rounding=3, teardrop = true)
            position(BOT) cyl(h = 2, d1 = 137, d2 = 140); 
        down(34)
            threaded_rod(d=138, l=14, end_len2=2, pitch=3); 
        }       
        down(34)
            cyl(d=132, h=17);

        up(26.5)
        threaded_rod(d=138, l=7, pitch=3, internal=true);

        //charging port//
        down(14)
        right(70)
        cube([15, 22, 14], center=true);
    
        }
//skull skin//
    difference() {
        cyl(
        h=56,
        d=143,
        rounding=3, teardrop = true,
        texture=skull_pile,
        tex_size=[65,65],
        tex_depth=1
    );
    //hollow for skull skin//
    cyl(h=76, d=138);
    down(14)
    right(70)
    cube([15, 22, 14], center=true);
    }
            
}

module holder3 () {        
    //skull skin//
    diff() {
        cyl( h=36, d=143, rounding=3, teardrop = true,
        texture=skull_pile, tex_reps=[10,1], tex_depth=1 ) {
            tag("remove") position(TOP) cyl(h = 36+12+0.01, d = 130, anchor = TOP);  //clear core
            down(4) right(70) tag("remove") cube([15, 22, 14], center=true);   //charge port
            position(BOT) threaded_rod(d=137, l=12, end_len1=2, pitch=3, anchor = TOP);
            position(TOP) {
                up(1) cyl(h = 4, d = 143, rounding2 = 4, anchor = TOP);
                tag("remove") cyl(h = 10, d = 100);
                up(1) tag("remove") zrot_copies(n = 10, r = 60) xscale(.75) cyl(h = 2, d = 15, anchor = TOP);
           }
        }        
    }
}

   
    
module base () {
    
    difference() {
    union() {
        tube(h=100, od1=47, od2=140, wall=4, rounding=3);
        up(56)
        threaded_rod(d=137.5, l=14, pitch=3); 
     }   
       }
    //skull skin//
      difference() {
         cyl(
            h=98,
            d=48,
            d2=140,
            rounding=3,
            texture=skull_pile,
            tex_size=[65, 65],
            tex_depth=1
       );
        //hollow for skull skin//
        cyl(h=101, d=47, d2=139);
       
}
    //up(64) xrot(90) ruler();
    }

module lid () {
    difference() {
    union() {
    tube(h=28, od=142, wall=3, rounding=1);
    up(13)
    tube(h=3, od=136, wall=10, rounding=1);
     }
    down(7)
    threaded_rod(d=138, l=7, pitch=3,internal=true); 
        }
    //skull skin for lid//
      difference() {
         cyl(
            h=26,
            d=144,
            rounding=1,
            texture=skull_pile,
            tex_size=[30, 30],
            tex_depth=1
         );   
        //hollow for skull skin//
        cyl(h=28, d=142);
      }   
    }
    
 module holder2 () {   
     difference() {
     union() { 
        //upper ring//
        up(22)
        cyl(h=20, d=148, rounding=3);       
       //lower ring//
        down(47)
        tube(h=70, od=148, wall=6, rounding=3);
       //inner lip// 
        down(12)
        tube(h=3, od=142, wall=10, rounding=1);
        
        //pillars//
        branch_shape = function(x, y)
            2*sin(5*x + 15*y) + 2;

        for (i=[0:5]) {
            zrot(i*60)
                right(68)
                   plot_revolution(
                    branch_shape,
                    z=[-12.5:0.1:12.5],
                    angle=[-180:8:180],
                    r1=2,
                    r2=3
                   );
        }
     }        
        //threads//       
        down(75)
        threaded_rod(d=138, l=14, pitch=3,internal=true); 
        up(25)
        threaded_rod(d=138, l=14, pitch=3,internal=true);

        up(18)
        cyl(h=20, d=136, anchor=BOTTOM);
           //magnet divot//
            up(16)
            cyl(d=19, l=4, center=true);

           //charging port//
            down(55)
            right(71)
            cube([15, 22, 14], center=true);
    
       
     }    
        

        //skull skin for bottom//
      difference() {
        down(47)
         cyl(
            h=68,
            d=148,
            texture=skull_pile,
            tex_size=[65, 65],
            tex_depth=1
       );
        //hollow for skull skin//
        down(47)
        cyl(h=69, d=147);

        //charging cutout for skull skin//
        down(55)
        right(70)
        cube([15, 22, 14], center=true);
      }
       

        //skull skin for top//
      difference() {
        up(22)
         cyl(
            h=18,
            d=150,           
            texture=skull_pile,
            tex_size=[30, 30],
            tex_depth=1
       );
        //hollow for skull skin//
        up(22)
        cyl(h=19, d=147);
    }
}
