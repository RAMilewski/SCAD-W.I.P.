include <BOSL2/std.scad>
include <BOSL2/turtle3d.scad>

$fn = 64;
handle();
handleBend();

module handle(){
path = turtle3d([
"move",1,
["arc",2,"up",36,"shrink",[1,2]],
"arcdown",2,72,
["arc",2,"up",36,"grow",[1,2]],
"move",1
],
state=move([0,.75,.375]),
transforms=true
);

sweep(
ellipse( d=[.75,1.5] ),
path
);
}
//

module handleBend(){
path = turtle3d([
"move",1,
["arc",2,"up",36,"left",45,"shrink",[1,2],"rollto", UP],
"arcdown",2,72,
["arc",2,"up",36,"right",45,"grow",[1,2]],
"move",1
],
state=move([0,.75,.375]),
transforms=true
);

sweep(
ellipse( d=[.75,1.5] ),
path
);
}
  
