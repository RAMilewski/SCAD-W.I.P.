include<BOSL2/std.scad>
include<BOSL2/threading.scad>

lamp_d = 124;
lamp_z = 51;

platform();



module platform() {
    dia = lamp_d + 4;
    threaded_rod(d = dia, h = 25, pitch = 3, $fn = 144);
}

