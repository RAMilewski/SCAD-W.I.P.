include<BOSL2/std.scad>
include<BOSL2/joiners.scad>

dovetail(dovetail_gender, w=side_dovetail_width, h=side_dovetail_height, 
    thickness=wall_thickness, back_width=side_dovetail_back_width, 
    slope=side_dovetail_slope);

