// Prince Rupert demo: same-size cube passes through another
s = 40;          // cube edge (mm)
eps = 0.1;       // tiny oversize so the hole is clean
theta = atan(1/2); // ≈ 26.565051°  (the classic Rupert tilt)

difference() {
  // Outer cube, centered
  cube([s,s,s], center=true);

  // Subtractive cube: same size, slightly oversize
  // Rotate Z by 45°, then X by theta
  // (OpenSCAD apply order is X then Y then Z for rotate([x,y,z]),
  // so use two rotates to control order.)
  rotate([0,0,45])
    rotate([theta,0,0])
      #cube([s+2*eps, 2*s+2*eps, s+2*eps], center=true);
}

