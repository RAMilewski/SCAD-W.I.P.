include <BOSL2/std.scad>

$fn = 128;

left_center = [-100, 20];
right_center = [100, 20];
bottom_center = [0, -20];

c = circle(r = 35);

bc = move(bottom_center, p = c);

l = hull_region(union([
  move(left_center, p = c),
  bc,
]));

r = hull_region(union([
  move(right_center, p = c),
  bc,
]));

v = union([l, r]);

expanded = offset(
  path = v,
  delta = 200,
);

smooth = offset(
  path = expanded,
  r = -200,
);

region(smooth);