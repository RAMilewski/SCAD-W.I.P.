include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

// Adding extra points reduces the differences
data = [[0,0], [20,30], [35,120], [50,30], [70,0]];
method = ["length", "centripetal", "dynamic", "foley", "fang"];
color = ["blue","lime","yellow","orange","red"]; 
for (i = [0:4]) {
    color(color[i]) {
        debug_nurbs_interp(data, 3, closed = true, method = method[i], extra_pts= 5, size = 5, data_size = 3);
        move([80,100-i*15]) text(method[i]);
    }
}