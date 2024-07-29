/**********************
* Advaced Parametric Coin Holder
* https://www.thingiverse.com/thing:6036063
*
* Info: There's a lot of options here so I tried to keep them organized
* 
* Remix/enhancement of http://www.thingiverse.com/thing:212164
* inspired by http://www.thingiverse.com/thing:9116
*
* Write library required for labels on the plungers, but can use without
* Just ignore the warnings. 
*
* If you like this work, buy me a coffee or something. 
* I drank a lot working on it.
*
***********************/

use <Write/Write.scad>;

/*****************
** MAIN OPTIONS **
*****************/

/* [Global] */

// Piston labels not available in cutsomizer as they require the write library for openSCAD. To get labels, download the code and open in OpenSCAD along with the write library at ./Write/Write.scad
Note_about_piston_label_text = "OK";

// Part to display -- use plated to print all parts. 
part = 5; //[1:Preview, 2:Body, 3:Plungers, 4:Cover, 5:Plated]

// Enter numbers corresponding to which coins you want to use. 0 is no coin and will be ignored in final assembly. [0:None, 1:US Dollar, 2:US half dollar, 3:US quarter, 4:US dime, 5:US nickle, 6:US penny, 7:euro cent, 8:2 euro cents, 9:5 euro cents, 10:10 euro cents, 11:20 euro cents, 12:50 euro cents, 13:1 euro, 14:2 euros, 15:5 Australian cents, 16:10 Australian cents, 17:20 Australian cents, 18:50 Australian cents, 19:Australian Dollar, 20:Australian $2, 21:CAN $2, 22:CAN $1, 23:CAN 25c, 24:CAN 10c, 25:CAN 5c, 26:CAN 1c]
coins = [1, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0]; 

// Select ordering method. 1: Manual uses exactly what you enter. 2: largest to smallest. 3: Alternating can fit the most in a small space.
coinOrderingMethod = 3; // [1: Manual , 2: Descending Size , 3: Alternating]
// Select Spacing method. 1: Auto recommended. 2: symmetrical. 3: manual
coinSpacingMethod = 1; // [1: Automatic , 2: Symmetrical , 3: Manual]

/* [Cup Holder and Spring Dimensions] */

// Total diameter of the outer cylinder in mm.
cupHolderWidth = 66; 
 // thickness of the bottom in mm
cupHolderFloor = 5;
// distance between outer edge of coins and outer edge of holder. If smaller than clearance value, edges of coins will be exposed.
wall = 0.1; 
// bottom bevel undercut in mm
bevelUndercut = 2; 

// height of spring at full extension: determines height of full assembly 
springAtFullExtension = 75; 
// spring outer diameter in mm. used to size plungers. Must be smaller than smallest coin
springOD = 17.1; 
// spring inner diameter in mm. used to size centering cone and small pistons.
springID = 15.1; 
// spring lenght when fully compressed, used to size plunger depth.
springHeight = 19; // spring lenght when fully compressed, used to size plunger depth.

/* [Other Parameters] */

// min thickness of lid. More = stronger.
lidThickness = 3; 
// lid overhang on each coin slot
lidOverhang = 4; 
clearance = 0.4; //adjust to suit your printer and allow parts to move freely
plungerTopThickness = 1.7; // thickness of top of plunger.
dowelRadius = 1.5; // thickness of cover fixing dowels
// angles from 0 in degrees to place coin slots manually. Ignore unless using manual spacing
manualCoinSpacing = [0,90,155,220,285,0,0,0,0,0,0,0]; 
// angle precision for rendering circles as polygons of $fn sides. More is higher quality but slower to render. Recommend keeping it low while adjusting model, turning it up for final render.
$fn=64; 

/***** ADVANCED PARAMETERS *******
**    Do not change anything    **
**    below this line unless    **
**  you know what you are doing **
*********************************/

/* [Hidden] */

// to make surfaces not perfectly aligned.. when you need walls of diff solids to not overlap
zeroPlaneGap = 0.01; 
// tweak these values first if auto or symmetrical spacing needs adjusting.
coinSlotSpacingFactor = [1,1,1,1,1,1,1,1,1,1,1,1]; 
// for use with the Write library to label cylinders. 
textScale = 2;

// Coin definitions
coinName = ["None", "\$1", "50", "25", "10", //US 1-6
	"5", "1",
	"1", "2", "5", "10", //Euro 7-14
	"20", "50", "E", "2E",
	"5", "10", "20", "50", "\$1", "\$2", //Australian 15-20
	"\$2", "\$1", "25", "10", "5", "1"]; // Canadian 21-26
coinSize = [0, 26.49, 30.6, 24.3, 17.9,//US 1-6
	21.21, 19,
	16.25, 18.75, 21.25, 19.75,//Euro 7-14
	22.25, 24.25, 23.25, 25.75,
	19.41, 23.6, 28.65, 32, 25, 20.5, //Australian 15-20
	28, 26.5, 23.9, 18, 21.2, 19.1]; // Canadian 21-26
coinHeight = [0, 2, 2.15, 1.75, 1.35, //US 1-6
	1.95, 1.55,
	1.67, 1.67, 1.67, 1.93,//Euro 7-14
	2.14, 2.38, 2.33, 2.20,
	1.3,2,2.5,2.5,3,3.2, //Australian 15-20
	1.6,1.9,1.6,1.3,1.8,1.5]; // Canadian 21-26

// Calculated variables
cupHolderDepth = springAtFullExtension + cupHolderFloor + plungerTopThickness -1;
cupHolderR = cupHolderWidth / 2;
boundingCylR = cupHolderR - wall;
springOR = springOD / 2;
springIR = springID / 2;
slotHeight = cupHolderDepth - wall;
bevelHeight = cupHolderFloor * (2 / 3);
bevelRadius = cupHolderR - bevelUndercut;
dowelHeight = lidThickness;


/****************************
** COMPUTATIONAL FUNCTIONS **
****************************/

// array manipulation and summation functions

// Function to return one of the objects v1-v4 based on the value of select
function select_and_return(select = 0, v1, v2, v3, v4) = 
    select == 1 ? v1 : 
    select == 2 ? v2 : 
    select == 3 ? v3 : 
    select == 4 ? v4 : 
    undef;

// Add the first n elements of a vector v
function add_n(v, n, i = 0, r = 0) = i < n && i < len(v) ? add_n(v, n, i + 1, r + v[i]) : r;

// Sum all elements in vector v
function sum(v) = add_n(v, len(v));

// Get the index of the maximum element in a vector
function max_index(v) = [for (i = [0:len(v) - 1]) if (v[i] == max(v)) i][0];

// Sort a vector in descending order based on coinSize
function sort_desc(v, coinSize) = len(v) == 0 ? [] : let(max_idx = max_index([for (i = v) coinSize[i]])) concat([v[max_idx]], sort_desc([for (i = [0:len(v) - 1]) if (i != max_idx) v[i]], coinSize));
    
// Functions to return a pre-sorted vector in an alternating pattern
function sublist(v, start, end) = [for (i = [start : end - 1]) v[i]];
    
function split_vector(v) = [
    sublist(v, 0, ceil(len(v) / 2)),
    sublist(v, ceil(len(v) / 2), len(v))
];

function merge_alternating(v1, v2) = [
    for (j = [0 : len(v1) + len(v2) - 1])
        j % 2 == 0 ? v1[floor(j / 2)] : v2[floor(j / 2)]
];
    
// Filter out zero elements from a vector
function filter_non_zero(v) = [for (i = v) if (i != 0) i];
    
// Functions for calculating automatic coin slot spacing

// Calculate apparent angular diameter of coins from center
function apparent_angular_diameter(R, D) = 2 * acos(sqrt(D^2 - R^2) / D);

// Calculate apparent angular diameter vector for all coins
function calculate_apparent_angular_diameter_vector(coin, boundingCylR, coinSize) = [for (i = coin) apparent_angular_diameter(coinSize[i] / 2, boundingCylR - (coinSize[i] / 2))];

// Calculate total angular empty space using the passed apparent angular diameter vector
function calculate_total_angular_empty_space(coin, boundingCylR, apparentAngularDiameter) = 360 - sum(apparentAngularDiameter);
    
// Build relative apparent angle using the passed apparent angular diameter vector
function build_relative_apparent_angle(coin, boundingCylR, numSlots, angularEmptySpace, apparentAngularDiameter) = [for (i = [0:numSlots - 1]) apparentAngularDiameter[i] / 2 + apparentAngularDiameter[(i - 1 + numSlots) % numSlots] / 2 + angularEmptySpace];
 
// tail recursive function to build automatic positioning array
function build_weighted_automatic_spacing_array(numSlots, relativeApparentAngle, normalizedSpacingFactors, i = 0, acc = [], angleSum = 0) =
  i < numSlots
  ? let(currentSpacing = relativeApparentAngle[i] * normalizedSpacingFactors[i],
        newAngleSum = angleSum + currentSpacing - (i == 0 ? relativeApparentAngle[i] : 0))
    build_weighted_automatic_spacing_array( 
      numSlots,
      relativeApparentAngle,
      normalizedSpacingFactors,
      i + 1,
      concat(acc, [newAngleSum]),
      newAngleSum)
  : acc;

// Function to calculate symmetrical spacing for coins
function calculate_symmetrical_spacing(numSlots) = [for (n = [0 : numSlots - 1]) (360 / numSlots) * n]; 

// Tail recursive function to build symmetrical positioning array
function build_weighted_symmetrical_spacing_array(numSlots, evenSpacing, normalizedSpacingFactors, i = 0, acc = [], angleSum = 0) =
  i < numSlots
  ? let(currentSpacing = evenSpacing * normalizedSpacingFactors[i],
        newAngleSum = angleSum + currentSpacing - (i == 0 ? evenSpacing : 0))
    build_weighted_symmetrical_spacing_array(
      numSlots,
      evenSpacing,
      normalizedSpacingFactors,
      i + 1,
      concat(acc, [newAngleSum]),
      newAngleSum)
  : acc;
  
// calculate where to put the pins to fix the lid
  function calculate_dowel_positions(angularPosition, apparentAngularDiameter, angularEmptySpace) = [
    for (i = [0 : len(angularPosition) - 1])
        angularPosition[i] + (apparentAngularDiameter[i] / 2) + (angularEmptySpace / 2)
];

/******************************
** GLOBAL SCOPE COMPUTATIONS **
******************************/

// Filter out zero values from the coins list and store the result in manualCoinOrdering
manualCoinOrdering = filter_non_zero(coins);
echo("Manual coin ordering: ", manualCoinOrdering);

// Get the number of slots (non-zero coins) and store it in numSlots
numSlots = len(manualCoinOrdering);
echo("numSlots: ", numSlots);

// Sort the coins in descending order based on their size and store the result in descendingCoinOrdering
descendingCoinOrdering = sort_desc(manualCoinOrdering, coinSize);
echo("descendingCoinOrdering: ", descendingCoinOrdering);

// Split the descendingCoinOrdering list into two lists (even and odd indices) and store the result in splitDescending
splitDescending = split_vector(descendingCoinOrdering);
echo("splitDescending: ", splitDescending);

// Merge the two lists from splitDescending in an alternating manner and store the result in alternatingCoinOrdering
alternatingCoinOrdering = merge_alternating(splitDescending[0], splitDescending[1]);
echo("alternatingCoinOrdering: ", alternatingCoinOrdering);

// Select the coin ordering method based on the user input (coinOrderingMethod) and store the result in coin
coin = select_and_return(coinOrderingMethod, manualCoinOrdering, descendingCoinOrdering, alternatingCoinOrdering);
echo("coin: ", coin);

// Calculate normalized spacing factors for each slot and store the result in normalizedSpacingFactors
normalizedSpacingFactors = [for (i = [0:numSlots - 1]) numSlots * coinSlotSpacingFactor[i] / add_n(coinSlotSpacingFactor, numSlots)];
echo("Normalized spacing factors: ", normalizedSpacingFactors);

// Calculate even spacing for the coins and store the result in evenSpacing
evenSpacing = 360 / numSlots;
echo("Even spacing: ", evenSpacing);

// Calculate symmetrical coin spacing based on the even spacing and normalized spacing factors and store the result in symmetricalCoinSpacing
symmetricalCoinSpacing = build_weighted_symmetrical_spacing_array(numSlots, evenSpacing, normalizedSpacingFactors);
echo("Symmetrical coin spacing: ", symmetricalCoinSpacing);

// Calculate the apparent angular diameter vector for all coins and store the result in apparentAngularDiameter
apparentAngularDiameter = calculate_apparent_angular_diameter_vector(coin, boundingCylR, coinSize);
echo("Apparent angular diameter vector: ", apparentAngularDiameter);

// Calculate the total angular empty space between coins and store the result in totalAngularEmptySpace
totalAngularEmptySpace = calculate_total_angular_empty_space(coin, boundingCylR, apparentAngularDiameter);
echo("Total angular empty space: ", totalAngularEmptySpace);
echo("Coins: ", coin, "Bounding cylinder radius: ", boundingCylR);

// Calculate the angular empty space per slot and store the result in angularEmptySpace
angularEmptySpace = totalAngularEmptySpace / numSlots;
echo("Angular empty space per slot: ", angularEmptySpace);

// Calculate the relative apparent angle for each coin and store the result in relativeApparentAngle
relativeApparentAngle = build_relative_apparent_angle(coin, boundingCylR, numSlots, angularEmptySpace, apparentAngularDiameter);
echo("Relative apparent angles: ", relativeApparentAngle);
echo("Coins: ", coin, "Bounding cylinder radius: ", boundingCylR, "Number of slots: ", numSlots, "Angular empty space: ", angularEmptySpace);

// Calculate the automatic coin spacing based on the relative apparent angle and normalized spacing factors and store the result in automaticCoinSpacing
automaticCoinSpacing = build_weighted_automatic_spacing_array(numSlots, relativeApparentAngle, normalizedSpacingFactors);
echo("Automatic coin spacing: ", automaticCoinSpacing);

// Select the final angular position based on the chosen coinSpacingMethod and store the result in angularPosition
angularPosition = select_and_return(coinSpacingMethod, automaticCoinSpacing, symmetricalCoinSpacing, manualCoinSpacing);
echo("Final angular position: ", angularPosition);

// Calculate the dowel positions based on the angular position, apparent angular diameter, and angular empty space and store the result in dowelPosition
dowelPosition = calculate_dowel_positions(angularPosition, apparentAngularDiameter, angularEmptySpace);

/***************************
** MODEL ASSEMBLY MODULES **
***************************/

module CoinSlot(coin) {
    union() {
        cylinder(r=coinSize[coin]/2+clearance, h=slotHeight+1);
    }
}

module coinSlotPlunger(c) {
    difference() {
        union() {
            cylinder(r=coinSize[c]/2, h=springHeight-coinHeight[c]);
            translate([0,0,springHeight-coinHeight[c]-zeroPlaneGap])
                cylinder(r1=coinSize[c]/2, r2=coinSize[c]/2-coinHeight[c], h=coinHeight[c]);
        }
        translate([0,0,-1]) cylinder(r=springOR+clearance, h=springHeight-plungerTopThickness);
        translate([0,0,springHeight-.49]) scale([textScale,textScale,1]) write(coinName[c], center=true);
    }
}

module coinSlotPlunger2(c) {
    difference() {
        union() {
            translate([0, 0, springHeight - plungerTopThickness * 1.5 - zeroPlaneGap])
                cylinder(r = coinSize[c] / 2, h = plungerTopThickness * 1.5 - coinHeight[c]);
            difference() {
                cylinder(r = springIR - clearance, h = springHeight - coinHeight[c]);
                translate([0, 0, -zeroPlaneGap])
                    cylinder(r1 = springIR, r2 = springIR / 2, h = springIR + clearance);
            }
            translate([0, 0, springHeight - coinHeight[c] - 2 * zeroPlaneGap])
                cylinder(r1 = coinSize[c] / 2, r2 = coinSize[c] / 2 - coinHeight[c], h = coinHeight[c]);
        }
        translate([0, 0, springHeight - 0.49])
            scale([textScale, textScale, 1])
            write(coinName[c], center = true);
    }
}

module dowel() {
    cylinder(r=dowelRadius, h=dowelHeight-clearance);
    translate([0,0,dowelHeight-clearance])cylinder(r1=dowelRadius,r2=dowelRadius-clearance/2, h=clearance);
    translate([0,0,clearance])cylinder(r1=dowelRadius+clearance/2,r2=dowelRadius, h=clearance);
    translate([0,0,clearance*2/3])cylinder(r1=dowelRadius,r2=dowelRadius+clearance/2, h=clearance/3);
}

module dowelSocket() {
    cylinder(r=dowelRadius+clearance, h=dowelHeight+clearance);
}

module coinHolder() {
    echo("start");
    difference() {
        cylinder(r=cupHolderR-clearance,h=cupHolderDepth);
        for (c=[0:numSlots-1]) {
            echo("coin",c,"is ",coinName[coin[c]]);
            rotate([0,0,angularPosition[c]])
                translate([cupHolderR-coinSize[coin[c]]/2-wall,0,cupHolderFloor]) {
                CoinSlot(coin[c]);
                translate([coinSize[coin[c]]/2,0,
                          cupHolderDepth-cupHolderFloor-coinHeight[coin[c]]+2*clearance])
                    cube([coinSize[coin[c]]+2*clearance,
                         coinSize[coin[c]]+2*clearance,
                         1.5*coinHeight[coin[c]]+2*clearance], center=true);
            }
        }
        difference() {
            translate([0,0,-zeroPlaneGap])cylinder(r=(cupHolderR + zeroPlaneGap), h=bevelHeight);
            translate([0,0,-zeroPlaneGap])cylinder(r1=bevelRadius, r2=cupHolderR, h=bevelHeight);
        }
    }
    for (c=[0:numSlots-1]) {
        echo("coin",c,"is ",coinName[coin[c]]," angle ",angularPosition[c]);
        rotate([0,0,angularPosition[c]]) 
            translate([cupHolderR-coinSize[coin[c]]/2-wall,0,cupHolderFloor-zeroPlaneGap]) {
            cylinder(r1=springIR-clearance,r2=springIR/2-clearance,h=springIR);
        }
    }
    cylinder(r=cupHolderR/7, h=cupHolderDepth+lidThickness+clearance, $fn=3);
    cylinder(r=cupHolderR/7, h=cupHolderDepth+lidThickness+clearance, $fn=4);
    for (c = [0 : numSlots - 1]) {
        rotate([0, 0, dowelPosition[c]]) {
            translate([cupHolderR - dowelRadius * 3, 0, cupHolderDepth]) {
                dowel();
            }
        }
    }
}

module coinPlungers(extra) {
    for (c=[0:numSlots-1]) {
        echo("coin",c,"is ",coinName[coin[c]]," angle ",angularPosition[c]);
        rotate([0,0,angularPosition[c]])
            translate([cupHolderR-coinSize[coin[c]]/2-wall+extra,0,cupHolderDepth-springHeight-cupHolderFloor-2*clearance]) {
            if (abs(springOD - coinSize[coin[c]]) <= clearance * 4) {
                coinSlotPlunger2(coin[c]);
            } else {
                coinSlotPlunger(coin[c]);
            }
        }
    }
}


module slot_shape(coin_size, lidOverhang, clearance, slot_height) {
    r = coin_size / 2 - lidOverhang + clearance;
    cube_size = coin_size - 2 * lidOverhang + 2 * clearance;
    extended_cube_size = (coin_size + 2 * clearance);
    slot_center = [coin_size / 2 + lidOverhang, 0, slot_height / 2];
    cylinder_pos = [coin_size / 2 - lidOverhang + clearance, (coin_size / 2 - lidOverhang + clearance) * 2, 0];

    difference() {
        union() {
            translate([lidOverhang, 0, 0]) {
                cylinder(r=r, h=slot_height);
                translate(slot_center)
                    cube([coin_size + 2 * lidOverhang + 2 * clearance, cube_size, slot_height], center=true);
            }
            translate([coin_size, 0, slot_height / 2])
                cube([coin_size + 2 * lidOverhang + 2 * clearance, extended_cube_size, slot_height], center=true);
        }
        union() {
            translate(cylinder_pos)
                cylinder(r=r, h=slot_height);
            translate([cylinder_pos[0], -cylinder_pos[1], 0])
                cylinder(r=r, h=slot_height);
        }
    }

    translate([0, 0, slot_height]) {
        linear_extrude(height=slot_height, scale=1 + 2 * lidOverhang / slot_height, center=true) {
            difference() {
                union() {
                    translate([lidOverhang, 0, 0]) {
                        circle(r=r);
                        translate([coin_size / 2 + lidOverhang, 0])
                            square([coin_size + 2 * lidOverhang + 2 * clearance, cube_size], center=true);
                    }
                    translate([coin_size, 0])
                        square([coin_size + 2 * lidOverhang + 2 * clearance, extended_cube_size], center=true);
                }
                union() {
                    translate(cylinder_pos)
                        circle(r=r);
                    translate([cylinder_pos[0], -cylinder_pos[1]])
                        circle(r=r);
                }
            }
        }
    }
}

module cover() {
    cover_sphere_r = cupHolderR * 4;
    cover_opposite_r = sqrt(cover_sphere_r^2 - cupHolderR^2);

    difference() {
        union() {
            cylinder(r=cupHolderR, h=lidThickness);

            intersection() {
                translate([0, 0, lidThickness - cover_opposite_r]) sphere(r=cover_sphere_r);
                cylinder(r=cupHolderR, h=lidThickness * 3);
            }
        }

        for (c=[0:numSlots-1]) {
            rotate([0, 0, angularPosition[c]])
            translate([cupHolderR - coinSize[coin[c]] / 2 - wall - lidOverhang, 0, -1]) {
                slot_shape(coinSize[coin[c]], lidOverhang, clearance, 3 * lidThickness);
            }
        }
        translate([0, 0, -1]) cylinder(r=cupHolderR / 7 + clearance, h=lidThickness + 2, $fn=3);
        translate([0, 0, -1]) cylinder(r=cupHolderR / 7 + clearance, h=lidThickness + 2, $fn=4);

        for (c = [0 : numSlots - 1]) {
            rotate([0, 0, dowelPosition[c]]) {
                translate([cupHolderR - dowelRadius * 3, 0, -zeroPlaneGap]) {
                    dowelSocket();
                }
            }
        }
    }
}

module assembled() {
    color("blue") coinHolder();
    color("grey") translate([0,0,cupHolderFloor]) coinPlungers(0);
    color("green") translate([0,0,cupHolderDepth+clearance+zeroPlaneGap]) cover();
}

module plated() {
    coinHolder();
    translate([cupHolderWidth+5,0,0]) rotate([180,0,0]) translate([0,0,-cupHolderDepth+cupHolderFloor+clearance*2]) coinPlungers(wall);
    translate([-cupHolderWidth-5,0,0]) cover();
}

difference() {
	if (part==1) assembled();
	if (part==2) coinHolder();
	if (part==3) rotate([180,0,0]) translate([0,0,-cupHolderDepth+cupHolderFloor+clearance*2]) coinPlungers(wall);
	if (part==4) cover();
	if (part==5) plated();
	}
    
/* 
Future To-Do
refactor and simplify
test with many more coins

    --change center key and make center hollow for storing more stuff
  
  replace the center key with a procedurally generated lip around a cavity, for storing bills etc. create a center cap to cover it, with an integrated bill clip like a dipstick in the middle.

*/