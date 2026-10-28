module bored_block(size=20, bore=12, rounded=true) {
    translate([115, 0, 0]) scale([1, 1, 1.7]) translate([-115, 0, 0]) translate([85, 0, 0]) rotate([-45, 0, 0]) translate([-75, 0, 0]) difference() {
        if (rounded)
            minkowski() { cube(size - 4, center=true); sphere(2, $fn=16); }
        else
            cube(size, center=true);
        cylinder(h=size*2, d=bore, center=true);
    }
}

for (i = [0:3])
    translate([i * 30 + 15, 0, 0])
        bored_block(size = 20 + i*4, bore = 6 + i*2);