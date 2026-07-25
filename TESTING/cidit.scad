
// TODO: make herringbone by sandwiching two helical on top of each other? constrain on hex shaft
// TODO: add second stage with interlocked sun gear

include <BOSL2/std.scad>
include <BOSL2/gears.scad>
include <BOSL2/ball_bearings.scad>

inner_diameter = 100; // aka, pitch diameter
modulus = 2;
helical = 25;
height = 15;

// modulus * teeth_count = circumf
// circumf / PI = diam
max_teeth_count = floor(inner_diameter / 2 * PI / modulus);
num_planets = 4;

bearing_info = ball_bearing_info(trade_size="608ZZ");
bearing_loadbearing_lip = 2;

gear_data = planetary_gears(
  mod=modulus,
  n=num_planets,
  max_teeth=max_teeth_count,
  helical=helical,
  sun_ring=2.2,
  gear_spin=360 / 27 * $t
);

echo(gear_data);
echo("sun teeth", gear_data[0][1]);
echo("ringteeth", gear_data[1][1]);
echo("total", (gear_data[0][1] + gear_data[1][1]));
// NOTE: assert instead
echo("is uniform?", ( (gear_data[0][1] + gear_data[1][1]) / num_planets) % 2 == 0);

module encrusted_bearing(name = "608ZZ") {
  bi = ball_bearing_info(name);
  difference() {
    children();
    cyl(d=bi[1], h=bi[2]);
  }
}

module encrusted_nut(){
  flat2flat = 12.8;
  a = flat2flat/2;
  r = a/cos(30);
  difference() {
    children();
    cyl(r=r, h=7, $fn=6);
  }
}

ring_gear(
  mod=modulus,
  teeth=gear_data[1][1],
  profile_shift=gear_data[1][2],
  gear_spin=gear_data[1][3],
  helical=helical,
  herringbone=true,
  backing=4, // TODO: what does this do?
  thickness=10
);

// color("blue") {
//   move_copies(
//     gear_data[2][4]
//   )
//     cyl(
//       h=12,
//       d=4
//     );
//   down(9)
//     linear_extrude(height=3)
//       scale(1.2)
//         polygon(gear_data[2][4]);
// }

//sun

cyl(h=1.5, r=36) {
  // TODO: actually, thats shit because its bad for assembly, i think. probably better to transfer power by interlocking the two pieces

  attach([TOP, BOTTOM]) spur_gear(
      mod=modulus,
      teeth=gear_data[0][1],
      profile_shift=gear_data[0][2],
      gear_spin=gear_data[0][3],
      helical=helical,
      herringbone=true,
      thickness=height,
      shaft_diam=bearing_info[1],
      anchor=BOTTOM
    );

}
// planets

// module bearing_inset_gear(modulus, teeth, profile_shift, helical, gear_spin) {
//   height = 20;
//   pitch_rad = pitch_radius(mod=modulus, teeth=teeth, helical=-helical);
//   attachable(anchor=CENTER, spin=0, orient=UP, r=pitch_rad, h=height) {
//     diff()
//       spur_gear(
//         mod=modulus,
//         teeth=teeth,
//         profile_shift=profile_shift,
//         helical=helical,
//         gear_spin=gear_spin,
//         herringbone=true,
//         thickness=height,
//         shaft_diam=bearing_info[1] - (bearing_loadbearing_lip * 2)
//       )
//         align([TOP, BOTTOM], inside=true, shiftout=0.001) cyl(h=7, r=11);
//     children();
//   }
// }

// move_copies(gear_data[2][4]) {
//   bearing_inset_gear(
//     modulus=modulus,
//     teeth=gear_data[2][1],
//     profile_shift=gear_data[2][2],
//     helical=-helical,
//     gear_spin=gear_data[2][3][$idx]
//   ) align([TOP], inside=true) ball_bearing("608ZZ");
// }

move_copies(gear_data[2][4]) encrusted_bearing(name = "608ZZ") spur_gear(
  mod=modulus,
  teeth=gear_data[2][1],
    profile_shift=gear_data[2][2],
    helical=-helical,
    gear_spin=gear_data[2][3][$idx],
  herringbone=true,
  thickness=10,
  shaft_diam=10
)
*up(20) ball_bearing("608ZZ");