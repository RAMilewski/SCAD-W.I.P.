include <BOSL2/std.scad>
include <BOSL2/turtle3d.scad>
r = 40;
x = 6.67;   


t_list = ["setdir",UP, "zmove",50, "arcxrot",r,-70, "move",20, "move",x];

xfrm = turtle3d(t_list,transforms = true);
sweep(circle(10),xfrm);

path = turtle3d(t_list);
move(path[len(path)-2]) #cyl(d = 1, h = 50); 
        
