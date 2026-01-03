//  MB_grid.scad - A quick and dirty OpenSCAD Multiboard Generator using the BOSL2 library
//  Unless otherwise noted .stl files are from Tile Components - STL Multiboard Remixing Files 
//  (https://thangs.com/designer/Multiboard/3d-model/Tile%20Components%20-%20STL%20Multiboard%20Remixing%20Files-994663),
//  and their use is subject to the terms of the Multiboard License (https://www.multiboard.io/license).
//  



include<BOSL2/std.scad>


/* [Grid Size] */
rows = 2;   //[2:1:10]
cols = 2;   //[2:1:10]

/* [Stack Size] */
stack = 1; //[1:1:42]

/* [Edge Type] */
top = 0;    //[0:None, 1:Border, 2:Small Hole, 3:Alt A, 4:Alt B]
bottom = 0; //[0:None, 1:Border, 2:Small Hole, 3:Alt A, 4:Alt B]
left = 0;   //[0:None, 1:Border, 2:Small Hole, 3:Alt A, 4:Alt B]
right = 0;  //[0:None, 1:Border, 2:Small Hole, 3:Alt A, 4:Alt B]

/* [Corners] */
top_left = 0;       //[0:None, 1:Small Hole, 2:Vertical Border, 3: Horizontal Border]
top_right = 0;      //[0:None, 1:Small Hole, 2:Vertical Border, 3: Horizontal Border]
bottom_left = 0;    //[0:None, 1:Small Hole, 2:Vertical Border, 3: Horizontal Border]
bottom_right = 0;   //[0:None, 1:Small Hole, 2:Vertical Border, 3: Horizontal Border]


/* [Hidden] */
grid = [cols,rows];
alt_grid = grid - [1,1];

mu = [25,25];
x_shift = mu.x * grid.x/2;
y_shift = mu.y * grid.y/2;
z = 6.4; //height of grid + 0.2

/* MAIN */

for (i = [0:stack-1]) up(i * z) mb_grid();



/* Modules */

module mb_grid () {
    grid_copies(n = grid, spacing = mu) octohole2();
    move(-mu/2) grid_copies(n = alt_grid, spacing = mu) thread_hole2();
    edges();
    corners();
}

module edges() {
    if (top)    { xcopies(n = alt_grid.x, spacing = mu.x) back(y_shift)  make_edge(top,180);  }
    if (bottom) { xcopies(n = alt_grid.x, spacing = mu.x) fwd(y_shift)   make_edge(bottom,0); }
    if (left)   { ycopies(n = alt_grid.y, spacing = mu.y) left(x_shift)  make_edge(left,-90); }
    if (right)  { ycopies(n = alt_grid.y, spacing = mu.y) right(x_shift) make_edge(right,90); }
}


module make_edge(edge,theta) {
    if (edge == 1) border_wedge(theta); 
            if (edge == 2) move(-mu/2) thread_hole2();
            if (edge == 3) {
                if ($idx % 2) border_wedge(theta);
            }
            if (edge == 4) {
                if ($idx % 2) {border_wedge(theta);} 
                else {move(-mu/2) thread_hole2();}
            } 
}

module corners() {
    if (top_left)     { back(y_shift) left(x_shift)  make_corner(top_left,-90,180);  }
    if (top_right)    { back(y_shift) right(x_shift) make_corner(top_right,90,180);  }
    if (bottom_left)  { fwd(y_shift)  left(x_shift)  make_corner(bottom_left,-90,0); }
    if (bottom_right) { fwd(y_shift)  right(x_shift) make_corner(bottom_right,90,0); }
}
module make_corner(type,theta,phi) {
     if(type == 1) move(-mu/2) thread_hole2(); 
     if(type == 2) border_wedge(theta);
     if(type == 3) border_wedge(phi);
}

/* STL Library */

module octohole() {
    import("Remixing_STLs/Large Octagon Hole (Positive)2.stl");
}

module octohole2() {
    import("Remixing_STLs/Large Octagon Hole with side holes (Positive)2.stl");
}

module thread_hole() {
    import("Remixing_STLs/Small Thread Hole (Positive)2.stl");
}

module thread_hole2() {
    import("Remixing_STLs/Small Thread Hole with side bumps (Positive)2.stl");
}

module border_wedge(rot) {
    //The original STL from https://github.com/colbytimm/multiboard-storage-solution is offset from the origin
    zrot(rot) back(mu.y/2) left(mu.x/2) import("Remixing_STLs/Tile Border Connection Component2.stl");
}