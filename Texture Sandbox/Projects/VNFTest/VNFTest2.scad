include <BOSL2/std.scad>
bottom =-1;
/* maxz = 20;
data = [
    [ 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  ],
    [ 8, 12, 12, 12, 12, 12, 12, 12, 12, 8, ],
    [ 8, 12, 8, 8, 8, 8, 8, 8, 12, 8,  ],
    [ 8, 12, 8, 8, 8, 8, 8, 8, 12, 8,  ],
    [ 8, 12, 8, 8, 8, 9, 8, 8, 12, 8,  ],
    [ 8, 12, 8, 8, 8, 8, 8, 8, 12, 8,  ],
    [ 8, 12, 8, 8, 8, 8, 8, 8, 12, 8,  ],
    [ 8, 12, 8, 8, 8, 8, 8, 8, 12, 8,  ],
    [ 8, 12, 12, 12, 12, 12, 12, 12, 12, 8,  ],
    [ 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  ],
   
];

vnf = heightfield(data, size=[10,10], bottom = bottom, maxz = maxz);
vnf_validate(vnf, check_isects = true);

*back_half() heightfield(data, size = [10,10], bottom = bottom, maxz = maxz, style = "concave");
*/

fn = function (x,y) sin(x*360)*cos(y*360);
    heightfield(size=[10,10], data=fn, bottom = -1, anchor = BOT);
    
    








