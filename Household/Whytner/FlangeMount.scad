include<BOSL2/std.scad>

$fn = 360;

frame = [15.5 * INCH, 10 * INCH];

path = rect(frame);
color("black") {
    stroke(path, width = 0.1, closed = true);

    path2 = circle(r = 62);
    path3 = circle(d = 2);

    xcopies(n = 
    2, spacing =180) {
    stroke(path2, width = 0.1, closed = true);
        zrot_copies(n = 4, r = 71)
            stroke(path3, width = 0.1, closed = true);
    //down(5) import("Flange.stl");
    }

}

