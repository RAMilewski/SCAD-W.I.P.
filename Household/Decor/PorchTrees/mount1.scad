include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 72;

hyp = 220;
opp = 10.9;
theta = hyp_opp_to_ang(hyp, opp);
echo(theta);

base = [35,12,65];
ins = [25,7,66];
plate = [base.x, 1.5, ins.z];
cham = ins.y * 0.75;


zrot(180) shoe();
right(50) frontplate();


module shoe() {
    diff() {
        cuboid(base, rounding = 2, anchor = BACK){
            position(FWD) fwd(2) down(0.5) tag("remove") xrot(theta) xscale(1.03) foot();
            zcopies(n = 2, spacing = base.z * .66)  back(2)
                screw_hole("#6,1/4", head = "flat sharp", counterbore = 4,  orient = FWD);
        }
    }
}


module foot() {
    prismoid(size1 = [ins.x * 0.8, ins.y], size2 = [ins.x, ins.y], h = ins.z,
        chamfer = [0, 0, cham, cham], anchor = FWD);
}

module frontplate() {
    cuboid(plate, rounding= 2, edges = "Y", anchor = FWD)
        position(BACK) foot();
}