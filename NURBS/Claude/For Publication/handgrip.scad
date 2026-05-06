
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

data = [[[0,7],[15,10],[30,10],[40,0],[30,-10],[15,-10],[0,-7]],
        [[0.5,6],[12,9],[30,8],[35,0],[30,-8],[12,-9],[0.5,-6]]];

path1 = nurbs_curve(nurbs_interp(data[0],3,closed=true, 
     deriv = [undef,undef,undef,FWD,undef,undef,undef],
     curvature = [undef,undef,undef,-.1,undef,undef,undef],
     extra_pts = 6, smooth = 3));

path2 = nurbs_curve(nurbs_interp(data[1],3,closed=true, 
     deriv = [undef,undef,undef,FWD,undef,undef,undef],
     curvature = [undef,undef,undef,-.2,undef,undef,undef],
     extra_pts = 6, smooth = 3));

// The 2 NURBS curves have different path lengths, so we resample them.
samples = 20;
paths = [resample_path(path2,samples), resample_path(path1,samples)];

shape = [ 
    repeat([15,0,0],samples), 
    for(i=[0:10]) path3d(paths[i%2],i*10),
    repeat([15,0,100],samples)
];


nurbs_interp_surface(shape, 3, col_wrap = true, normal1 = [0,0,-3], normal2 = [0,0,3]);

/* */


for (i=[0:10]) echo(i%2, i*10,  i%2 * 10);