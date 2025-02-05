// Wave FIFO Battery Holder by Adrian Mariano
//
// You can adjust the compression and amplitude as well as
// the cycles to create battery holdes with different shapes
// and heights.  You may have to tinker with the dovetail
// parameters to ensure that assembly is possible.
//
// The marked sides of the bars should face inward and the joint
// is tapered, so it should start easily but wedge firmly in place.  

dobars = true;
dosides = true;

///////////////////////////////////////////////////////
//
// AA size

battery_length = 52; 
battery_diam = 15;    
amplitude=16;      // Width of the wave
compression=8;     // How tight cycles are
dove_toplen=12;    // Length of top back dovetail
dove_topwidth = 12;// Width of top back dovetail
railheight=14;      // Height of rail that batteries roll on


///////////////////////////////////////////////////////
//
//  AAA size  smaller version
/*
battery_length = 46;  
battery_diam = 11;
amplitude = 11.5;
compression = 11;
dove_toplen=6;     // Length of top back dovetail
dove_topwidth = 11;// Width of top back dovetail
railheight=12;     // Height of rail that batteries roll on
*/

///////////////////////////////////////////////////////
//
//  AAA size - larger version
/*
battery_length = 46;  
battery_diam = 11;
amplitude = 13;
compression = 9.8;
dove_toplen=6;     // Length of top back dovetail
dove_topwidth = 11;// Width of top back dovetail
railheight=12;     // Height of rail that batteries roll on
*/
///////////////////////////////////////////////////////

cycles = 2;        // Number of cycles in the wave

dove_botlen=12;    // Length of bottom dovetail
dove_botwidth = 13;// Width of bottom dovetail


elevation=20;      // Elevation of base.  Actually the -x coordinate
                   // so the true elevation is a bit less because
		   // the ramp ends somewhere below x=0
		   
ramp_extension=1.5*battery_diam;  // Amount of ramp extension past the wave

backthickness = 2;  // Projection of back wall in +Z direction
                    // Total back thickness is this plus mink_expansion

mink_r=2;           // Minkowski radius; determines rail thickness
mink_facets = 20;   // Facet count for minkowski

dovetail_slop=0;    // Slop in dovetail fit for printers that overextrude

//////////////////////////////////////////////////////////////////
//
// These are derived values that should not be edited.  

   // Due to polyhedral natural of "spheres" the minkowski function
   // doesn't expand by the advertised radius.  
   // When I assumed mink_expansion=mink_r parts of the model
   // were in slightly different planes and the model did not
   // adhere to the bed, so this correct appears to be necessary,
   // at least when mink_facets is small (8).  
mink_expansion = cos(180/mink_facets)*mink_r;

battery_radius = battery_diam/2;
period = 360/compression;
height = cycles*period;
step = 1/compression;

backheight = height - period/2;
backwidth = amplitude+battery_radius+mink_expansion;

inf = 1000;  // infinity
all=[-inf,inf];

module boundsquare(x,y){
   translate([x[0],y[0]])
     square(size=[x[1]-x[0],y[1]-y[0]],center=false);
}

module boundcube(x,y,z){
   translate([x[0],y[0],z[0]])
     cube(size=[x[1]-x[0],y[1]-y[0],z[1]-z[0]],center=false);
}

// Define battery path for the channel where batteries go.  The path
// extends along the X direction.

batterypath = [for(theta=[step:step:height+step]) 
              [theta,
                 theta>period/4?
                     amplitude*cos(theta*compression): // wiggly part
                    -amplitude*tan(theta*compression-90)]   // ramp
          ];

// To make a polygon add some junk at the ends.  The polygon will be filled
// on the left side (when y is smaller than the path).  

batterypolygon = concat(
                  [[-height,-amplitude*4],
		   [-height,batterypath[0][1]]], 
                  batterypath,
                  [[ height*1.2,batterypath[len(batterypath)-1][1]],
		   [height*1.2,-amplitude*4]]);

module batterychannel(){
  linear_extrude(height=battery_length)
    intersection(){
      difference(){
        offset(r=battery_radius) polygon(batterypolygon);
        offset(r=-battery_radius) polygon(batterypolygon);
      }
      // Critical dimensions are the x and y maximum values. Others
      // are chosen to be oversized, but not so big that we capture
      // the junk that happens at the ends of the polygon
      boundsquare([-battery_diam, height],
                  [-amplitude-battery_diam,
		          amplitude+battery_radius+ramp_extension]);
    }
}

accessgap = [[period/2, -amplitude],
             [period/2, 2*battery_diam+amplitude], 
             [batterypath[0][0],2*battery_diam+amplitude]];            
  
module rail(){
  difference(){
    intersection(){
      // Define rail height 
      boundcube([-inf,height], all, [-inf,railheight]);
      difference(){  // Creates a hollow box
        render() minkowski(){
          sphere(r=mink_r, $fn=mink_facets);
	      batterychannel();
        }
        batterychannel();
      } 
    }
    // Clip off rail at the bottom so you can remove batteries
    linear_extrude(height=inf)
      polygon(accessgap);
  }
}

module backwall(){  
  // Make the feet
  linear_extrude(height=8){
    boundsquare([-elevation,-elevation+4],[-backwidth, -dove_botwidth/2-1]);
    boundsquare([-elevation,-elevation+4],
                [backwidth+battery_radius-15,backwidth+battery_radius]);
  }
  // Fill small gap between feet and dovetail
  boundcube([-elevation,-elevation+dove_botlen], [-dove_botwidth/2-1,-dove_botwidth/2],
            [0,dove_thickness+backthickness]);
  intersection(){
    boundcube([-elevation,inf],all,[-inf,backthickness]);
    render()minkowski(){
      sphere(r=mink_r, $fn=mink_facets);
      linear_extrude(height=inf)
          // Rectangular base and back section, intersected 
          // with battery path polygon.  The polygon is shrunk 
          // by 2*mink_r (which moves it in the -y direction), which 
          // removes the space needed for minkowski expansion.  The .1 
          // is because the exposed layer looked bad and tightening it 
          // slightly fixed that.  
        intersection(){
          offset(r=-battery_radius-1.9*mink_r)
            polygon(batterypolygon);
          boundsquare([-inf, // elevation+mink_expansion, // straight bottom
                       backheight-mink_expansion],
                      [-backwidth+mink_expansion,
                       backwidth+battery_radius-mink_expansion]);
        }     
    }  
  }
}


// Sliding dovetail.
//
// For female part, the joint lies in the XY plane, with the large end on the X axis,
// and the taper shrinking as y increases.  There is a small base at z<0 so that you can
// combine it with other shapes without problems.
//
// For the male part the joint sticks up in the Z direction with the large end at z=0.

dove_leftwall = 3;     // Size of left wall at dovetail base, large end
dove_rightwall = 3;    // Size of right wall at dovetail base, large end
dove_thickness = 4.05; // Thickness of the joint (height)
dove_slope = 4;        // Dovetail slope
dove_chamfer_size = 1; // Size of corner chamfers
dove_taper_angle = 2;  // Taper angle (set to zero for non-tapered)

module dovetail(length,width,height,gender){
  module chamfer(direction,location){
    translate(location)
      rotate(a=direction*dove_taper_angle, v=[0,1,0])
        rotate(a=direction*atan(dove_slope)/2,v=[0,0,1])
          cube(size=[dove_chamfer_size, dove_chamfer_size, inf], center=true);
  }  
  module cut(direction,location){
    translate(location)
      intersection(){
        boundcube(all, [0,inf],all);
        rotate(a=direction*dove_taper_angle, v=[0,1,0])
          rotate(a=direction*atan(dove_slope),v=[0,0,1])
          boundcube([-20, 20],[-20,0],[-20,20]);
      }
  }
  if (gender=="female"){
    rotate(a=90, v=[1,0,0])
    mirror([0,0,1])
    difference(){
      boundcube([0,width],[-.1,height],[0, length]);
      intersection(){
	cut(1,[dove_leftwall,0,0]);
	cut(-1,[width-dove_rightwall,0,0]);
      }
      chamfer(1,[dove_leftwall+dove_slope/height, height]);
      chamfer(-1,[width-dove_rightwall-dove_slope/height,height]);
    }
  }
  if (gender=="male"){
  translate([width, height])
    rotate(a=180, v=[0,0,1])
    difference(){
      intersection(){
        cube(size=[width,height,length], center=false);
	cut(1,[dove_rightwall,0,0]);
	cut(-1,[width-dove_leftwall,0,0]);
      }
      chamfer(1,[dove_rightwall, 0]);
      chamfer(-1,[width-dove_leftwall,0]);
    } 
  }
}

module doverails(){
  translate([-elevation,dove_botwidth/2,backthickness])
    rotate(a=-90, v=[0,0,1])
        dovetail(dove_botlen,dove_botwidth,dove_thickness,"female");
    translate([height-period-dove_topwidth/2,
              -backwidth,
	     backthickness])
      dovetail(dove_toplen,dove_topwidth,dove_thickness,"female");
}   

// Length of the bar

strutlength = battery_length - 2*backthickness - 2*dove_thickness;

// dlength is the length of the sliding dovetail
// dwidth is the width of the sliding dovetail
//
// These two parameters define the cross sectional dimension
// of the bar.  

module bar(dlength,dwidth){
  difference(){
    union(){
      cube(size=[dwidth, strutlength, dlength]);
      mirror([0,1,0])
        dovetail(dlength,dwidth-dovetail_slop,dove_thickness-dovetail_slop,"male");
      translate([0,strutlength,0])
          dovetail(dlength,dwidth-dovetail_slop,dove_thickness-dovetail_slop,"male");
    }
    // Create orientation line marker on top	
    boundcube([dwidth/2-0.5, dwidth/2+0.5],[strutlength/4,3/4*strutlength],
              [dlength-1,dlength+1]);
  }
}


module quarterroundover(r,length, facets)
{
  difference(){
  cube(size=[r,r,length]);
  *translate([0,0,-1])
     cylinder(r=r, h=length+2, $fn=facets);
  hull(){
     translate([0,0,r])sphere(r=r,$fn=facets);
     translate([0,0,length-r])sphere(r=r, $fn=facets);
  }
  }
}
  
module halfroundover(r,length,facets)
{
  difference(){
    translate([0,-r,0])cube(size=[r,2*r,length]);
    translate([0,0,-1])
      cylinder(r=r, h=length+2, $fn=facets);
  }
}

edgetheta = (atan(-(amplitude+battery_radius+ramp_extension)/amplitude)+90)
            /compression;
edgey = -amplitude*tan(compression*edgetheta-90);

module do_roundover(){
    translate([height-2+.1,amplitude+battery_radius,-2])
      quarterroundover(2,inf,16);
    translate([height-2+.1,amplitude+battery_radius+2,0])
      rotate(a=90,v=[1,0,0])rotate(a=-90, v=[0,0,1])
        quarterroundover(2,30,16);
    translate([height-6+.1,amplitude+battery_radius+2+15,railheight-6+.1])
      rotate(a=90,v=[1,0,0])quarterroundover(6,30,64);
    translate([edgetheta+battery_radius-6+2, edgey+15, railheight-6])
      rotate(a=90,v=[1,0,0])quarterroundover(6,30,64);
}

module thing(){
  difference(){
    union(){
      backwall();
      rail();
      doverails();
    }
    do_roundover();
  }
}

if (dosides){
  thing();
  translate([0,-2*backwidth-10,0])mirror([0,1,0]) thing();
}

if (dobars){
  translate([-elevation-dove_topwidth-8,-0.5*strutlength,-mink_expansion])
    bar(dove_toplen,dove_topwidth);
  translate([-elevation-dove_botwidth-8,-1.5*strutlength-18,-mink_expansion])	
    difference(){   // Trim bar slightly to ensure it fits next to the foot
      bar(dove_botlen,dove_botwidth);
      boundcube([dove_botwidth-0.5,inf],all,all);
  }
}
