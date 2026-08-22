include <BOSL2/std.scad>

project = "BagVac ";
part = "adapter";
$export_name = str(project,part);



$fn = 8;        //[3:32]
oct1 = 36.8 / cos(180/$fn);
wall = 2;    //[1:0.25:5]
oct2 = oct1 + 2 * wall;

dia1 = 15;
dia2 = dia1 + 2 * wall;

ibase = circle(d = oct1);
obase = circle(d = oct2);

imid = circle(d = dia1);
omid = circle(d = dia2);

itop = zrot(180/$fn, rect([8,3],rounding = 1.25, $fn = 72));
otop = zrot(180/$fn, rect([8+wall,3+wall], rounding = wall, $fn = 72));

skin([obase,obase,omid,otop,otop,itop,itop,imid,ibase,ibase],
        z=[0,10,20,40,55,55,40,20,10,0], slices = 10, closed = true); 



