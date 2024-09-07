include <aVm/BOSL2/std.scad>

//wedge([20, 40, 15]) show_anchors();


//regular_prism(3,d = 20, h = 20) show_anchors();

//cyl(h = 20, d = 20, $fn = 3) show_anchors();

d=regular_prism(3,d = 20, h = 20);
vnf_polyhedron(zrot(0,d), atype="hull") {
    attach(zrot(0,RIGHT), BOT) anchor_arrow();
    attach(zrot(30,RIGHT), BOT) anchor_arrow();
    attach(zrot(-30,RIGHT), BOT) anchor_arrow();
    //attach(zrot(120,RIGHT), BOT) anchor_arrow();    
}
