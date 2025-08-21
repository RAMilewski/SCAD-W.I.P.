
s = 25;
rr = 5;
sr = s+rr;

$fs = .1;
$fa = 2;

module tetratwister ()
{
difference () {
hull () {
translate ([s,s,s]) sphere (rr);
translate ([s,-s,-s]) sphere (rr);
translate ([-s,-s,s]) sphere (rr);
translate ([-s,s,-s]) sphere (rr);
}

translate ([0,0,-sr]) linear_extrude (height=2*sr, twist=1801.5, convexity = 10) rotate (45) square ([4*s,.2], center=true);
}
}

tetratwister ();