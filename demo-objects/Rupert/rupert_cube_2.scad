// Corner-up demo: inner cube’s body diagonal is vertical
s = 40;
eps = 0.1;
phi = atan(1/sqrt(2)); // ≈ 35.26438968° (angle from face normal to body diagonal)

difference() {
  cube([s,s,s], center=true);

  // First twist 45° around Z so a face diagonal aligns to X/Y,
  // then tilt by phi to aim a body diagonal along Z.
  rotate([0,0,45])
    rotate([phi,0,0])
      #cube([s+2*eps, 2*s+2*eps, s+2*eps], center=true);
}
