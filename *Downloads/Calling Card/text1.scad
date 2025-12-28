include<BOSL2/std.scad>

size = [90,50,0.6];
corner = 3;

line1 = "Richard Milewski";
font = "Lobster";
size1 = 8;

line2 = "W6HPA";
font2 = "Lobster";
size2 = 4;

line3 = "richard@milewski.org  –  txt:408-823-1312";
font3 = "Lobster";
size3 = 3.5;

ghost_this() cuboid(size, rounding = corner, edges = "Z") {
        grid_copies(n = 4, size = [size.x,size.y]) cyl(h = 0.05, d = 0.01);
        position(TOP) back(13) text3d(line1, h = 0.2, font = font, size = size1, center = true);
        position(TOP) back(0) text3d(line2, h = 0.2, font = font2, size = size2, center = true);
        position(TOP) fwd(10) text3d(line3, h = 0.2, font = font3, size = size3, center = true);

}