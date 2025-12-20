// Nameplate OpenSCAD example modified by Michael Laws, to create a parametric version of 'Printable Velcro' by MM Printing: https://www.printables.com/model/543802-printable-velcro , itself a remix of 'Printable VELCRO' by eried: https://www.printables.com/model/33302-printable-velcro
//
// Original license:
//
// Written by Amarjeet Singh Kapoor <amarjeet.kapoor1@gmail.com>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain
// Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

/*[ Velcro tower elements]*/

//The diameter of the lowest (and narrowest) part of each tower in mm. A base diameter of 1.0, will yield a top diameter of 1.3, and a tower height of 2.0mm.
Base_diameter = 1.0;//[0.5:0.1:10]

function Top_diameter() = Base_diameter*1.3;

//The height of each tower in mm.
function Height() = Base_diameter*2;

//How tight the fit is. This is an arbitrary value, not a measurement. -10 is tightest, 10 is loosest, 0 matches the original MM Printing model. As you scale up the base diameter, a tighter interference is needed.
Interference = 0;//[-10 : 10]

/*[ Pattern ] */
// Pattern is twice as wide horizontally as vertically. For a square pattern, the vertical value should be twice the horizontal.

//Horizontal tower sets in pattern.
Horizontal = 10; //[1:1:1000]

//Vertical tower sets in pattern.
Vertical = 10; //[1:1:1000]

/*[ Base plate ] */

//Thickness of the baseplate.
Thickness = 0.6;//[0.2:0.1:5]

// Horiziontal offset of base plate border from towers in mm.
BorderH = 5;//[1:1:100]

// Vertical offset of base plate border from towers in mm.
BorderV = 5;//[1:1:100]

/*[Misc] */

//Number of fragments in 360 degrees. Higher value produces a more detailed output at the expense of file size and processing time.
Resolution = 12;//[5:100]

$fn = Resolution;

function factor() = Base_diameter/12.5;

function spacing()=Base_diameter*4.4+Interference*factor();

module tower(){
        cylinder(h = Height(), r1 = Base_diameter/2, r2 = Top_diameter()/2, center = false);      
}        

module single_array(){
    render(){
        h=spacing();
        tower();
        translate([h/2,h/4,0])tower();
    }
}

module horizontal_array(){
    render(){
        h=spacing();
        for(dx=[0:h:h*Horizontal-1]){
           translate([dx,0,0])single_array();
        }
    }
}

module large_array(){
    v=spacing()/2;
    for(dy=[0:v:v*Vertical-1]){
       translate([0,dy,0])horizontal_array();
    }
}

module base_plate(){
    h=spacing();
    v=h/2;
    translate([-1*BorderH,-1*BorderV,-1*Thickness])cube([(h*Horizontal+BorderH*2-h/2),v*Vertical+BorderV*2-v/2,Thickness]);
}

union(){
    large_array();
    base_plate();
}