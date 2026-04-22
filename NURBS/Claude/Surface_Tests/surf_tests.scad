include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<../nurbs_interp.scad>


method="centripetal";   // [length,centripetal,dynamic,foley]
degree = 3;             // [2:1:8]

surf1=
[
  [ [-100,-100,0], [-75,-100,0], [-50,-100,0], [-25,-100,0], [0,-100,0], [25,-100,0], [50,-100,0], [75,-100,0], [100,-100,0] ],
  [ [-100,-75,0],  [-75,-75,12], [-50,-75,18], [-25,-75,25], [0,-75,30], [25,-75,22], [50,-75,15], [75,-75,8],  [100,-75,0] ],
  [ [-100,-50,0],  [-75,-50,20], [-50,-50,35], [-25,-50,48], [0,-50,55], [25,-50,40], [50,-50,28], [75,-50,12], [100,-50,0] ],
  [ [-100,-25,0],  [-75,-25,18], [-50,-25,42], [-25,-25,65], [0,-25,70], [25,-25,52], [50,-25,33], [75,-25,15], [100,-25,0] ],
  [ [-100,0,0],    [-75,0,10],   [-50,0,30],   [-25,0,55],   [0,0,60],   [25,0,50],   [50,0,40],   [75,0,22],   [100,0,0] ],
  [ [-100,25,0],   [-75,25,8],   [-50,25,25],  [-25,25,50],  [0,25,58],  [25,25,60],  [50,25,55],  [75,25,30],  [100,25,0] ],
  [ [-100,50,0],   [-75,50,6],   [-50,50,18],  [-25,50,35],  [0,50,45],  [25,50,55],  [50,50,48],  [75,50,26],  [100,50,0] ],
  [ [-100,75,0],   [-75,75,4],   [-50,75,10],  [-25,75,18],  [0,75,25],  [25,75,30],  [50,75,22],  [75,75,12],  [100,75,0] ],
  [ [-100,100,0],  [-75,100,0],  [-50,100,0],  [-25,100,0],  [0,100,0],  [25,100,0],  [50,100,0],  [75,100,0],  [100,100,0] ]
];

surf2=
[
  [ [-100,-100,0], [-82,-100,0], [-55,-100,0], [-20,-100,0], [0,-100,0], [28,-100,0], [60,-100,0], [85,-100,0], [100,-100,0] ],
  [ [-100,-78,0],  [-78,-80,8],  [-48,-79,16], [-18,-78,28], [7,-77,35], [32,-76,30], [55,-77,18], [78,-78,10], [100,-85,0] ],
  [ [-100,-52,0],  [-70,-51,14], [-42,-50,30], [-12,-51,50], [15,-52,60], [40,-53,48], [62,-54,26], [82,-53,12], [100,-60,0] ],
  [ [-100,-22,0],  [-75,-22,20], [-45,-21,45], [-20,-20,70], [5,-21,78], [30,-22,55], [57,-23,32], [80,-24,15], [100,-35,0] ],
  [ [-100,0,0],    [-72,-1,18],  [-40,0,40],   [-10,1,62],   [18,2,68],  [44,1,50],  [65,0,35],  [83,-1,22], [100,-5,0] ],
  [ [-100,26,0],   [-80,28,12],  [-52,27,28],  [-24,26,45],  [2,25,55],  [28,24,60], [55,25,48], [76,26,30], [100,25,0] ],
  [ [-100,55,0],   [-68,56,6],   [-38,55,18],  [-15,54,32],  [10,53,45], [36,54,52], [60,55,40], [82,56,24], [100,50,0] ],
  [ [-100,82,0],   [-74,82,4],   [-50,81,10],  [-25,80,18],  [0,81,28],  [26,82,35], [52,83,30], [78,84,16], [100,78,0] ],
  [ [-100,100,0],  [-90,100,0],  [-62,100,0],  [-30,100,0],  [5,100,0],  [35,100,0],  [58,100,0],  [80,100,0],  [100,100,0] ]
];


surf3=
[
  [ [-92,96,0],  [-70,93,0],  [-45,99,0],  [-18,92,0],  [6,97,0],   [28,91,0],  [49,95,0],  [71,89,0],  [88,90,0] ],
  [ [-98,72,0],  [-72,74,10], [-48,69,18], [-23,73,25], [2,68,22],  [27,72,28], [51,67,20], [73,70,12], [97,66,0] ],
  [ [-96,46,0],  [-69,52,18], [-44,43,35], [-19,48,48], [6,42,40],  [30,47,55], [54,41,38], [76,46,22], [90,44,0] ],
  [ [-88,21,0],  [-67,27,22], [-41,19,50], [-16,24,78], [8,17,60],  [33,22,85], [56,16,58], [79,21,30], [99,18,0] ],
  [ [-95,-4,0],  [-70,6,20],  [-43,-3,45], [-17,2,65],  [9,-6,35],  [35,-1,75], [58,-7,50], [80,-2,28], [92,-6,0] ],
  [ [-87,-30,0], [-65,-24,16],[-40,-33,38],[-14,-28,55],[11,-35,42],[37,-30,70],[59,-36,46],[81,-31,24],[96,-33,0] ],
  [ [-93,-55,0], [-67,-47,12],[-42,-56,28],[-18,-50,40],[7,-58,30], [32,-53,48], [55,-59,32], [77,-54,18], [89,-57,0] ],
  [ [-86,-73,0], [-60,-70,6], [-38,-78,15],[-12,-72,22],[13,-80,16],[36,-74,25],[57,-82,18],[79,-76,8],  [98,-76,0] ],
  [ [-85,-88,0], [-66,-95,0], [-40,-86,0], [-16,-97,0], [10,-90,0], [33,-98,0], [55,-87,0], [74,-94,0], [94,-92,0] ]
];

ydistribute(250){
xdistribute(250){
nurbs_interp_surface(surf1, degree);
nurbs_interp_surface(surf1, degree, method = method, flat_edges=1);
nurbs_interp_surface(surf1, degree, method = method, flat_edges=2);
nurbs_interp_surface(surf1, degree, method = method, flat_edges=[1,2,1,2]);
nurbs_interp_surface(surf1, degree, method = method, flat_edges=[1,2,[1,1,2,3,2,3,1,1,1],2]);
nurbs_interp_surface(surf1, degree, method = method, flat_edges=[undef,2,1/2,2]);
nurbs_interp_surface(rot([14,35,12],p=surf1), degree, method = method, flat_edges=1);
nurbs_interp_surface(surf1, degree, method = method, u_edges=[4]);
nurbs_interp_surface(surf1, degree, method = method, u_edges=[4],flat_edges=1);
nurbs_interp_surface(surf1, degree, method = method, u_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf1, degree, method = method, u_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf1, degree, method = method, u_edges=[3,6],flat_edges=1);
nurbs_interp_surface(surf1, degree, method = method, u_edges=[4],v_edges=5,flat_edges=1);
}



xdistribute(250){
nurbs_interp_surface(surf2, degree);
nurbs_interp_surface(surf2, degree, method = method, flat_edges=1);
nurbs_interp_surface(surf2, degree, method = method, flat_edges=2);
nurbs_interp_surface(surf2, degree, method = method, flat_edges=[1,2,1,2]);
nurbs_interp_surface(surf2, degree, method = method, flat_edges=[1,2,[1,1,2,3,2,3,1,1,1],2]);
nurbs_interp_surface(surf2, degree, method = method, flat_edges=[undef,2,1/2,2]);
nurbs_interp_surface(rot([14,35,12],p=surf2), degree, method = method, flat_edges=1);
nurbs_interp_surface(surf2, degree, method = method, u_edges=[4]);
nurbs_interp_surface(surf2, degree, method = method, u_edges=[4],flat_edges=1);
nurbs_interp_surface(surf2, degree, method = method, u_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf2, degree, method = method, u_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf2, degree, method = method, u_edges=[3,6],flat_edges=1);
nurbs_interp_surface(surf2, degree, method = method, u_edges=[4],v_edges=5,flat_edges=1);
}


xdistribute(250){
nurbs_interp_surface(surf3, 3);
nurbs_interp_surface(surf3, degree, method = method, flat_edges=1);
nurbs_interp_surface(surf3, degree, method = method, flat_edges=2);
nurbs_interp_surface(surf3, degree, method = method, flat_edges=[1,2,1,2]);
nurbs_interp_surface(surf3, degree, method = method, flat_edges=[1,2,[1,1,2,3,2,3,1,1,1],2]);
nurbs_interp_surface(surf3, degree, method = method, flat_edges=[undef,2,1/2,2]);
nurbs_interp_surface(rot([14,35,12],p=surf3), degree, method = method, flat_edges=1);
nurbs_interp_surface(surf3, degree, method = method, u_edges=[4]);
nurbs_interp_surface(surf3, degree, method = method, u_edges=[4],flat_edges=1);
nurbs_interp_surface(surf3, degree, method = method, u_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf3, degree, method = method, u_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf3, degree, method = method, u_edges=[3,6],flat_edges=1);
nurbs_interp_surface(surf3, degree, method = method, u_edges=[4],v_edges=5,flat_edges=1);
nurbs_interp_surface(surf3, degree, v_edges=4,flat_edges=1);
}
}
