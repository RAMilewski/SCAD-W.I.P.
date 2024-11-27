include <BOSL2/std.scad>
50_cal_ammo_box = [ 304.8, 177.8, 203.2 ];
40_sw = [ 10.8, 28.8 ];
 
container_dimensions = 50_cal_ammo_box;
half_container_plus_wiggle = (container_dimensions[0] / 2) - 2;
round_diameter = 40_sw [0] + 0.2;
cell_height = 40_sw [1] / 2;
rows = floor(container_dimensions[0] / 2 / round_diameter);
 echo(rows);
module gen_cells() {
  grid_copies(n = rows, size = half_container_plus_wiggle) {
    rect_tube(isize = round_diameter, h = cell_height, wall = 1,
              anchor = BOTTOM);
  }
}
 
cuboid([ half_container_plus_wiggle, half_container_plus_wiggle, 1 ]) {
  align(TOP, CENTER) { gen_cells(); };
}