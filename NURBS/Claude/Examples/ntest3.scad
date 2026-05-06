include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<data.scad>

$vpt = [80,75,25];
$vpr = [40,0,0];
$vpd = 5000;


method="centripetal";   // [length,centripetal,dynamic,foley,fang]


ydistribute(250){
xdistribute(250){
nurbs_interp_surface(surf1, 3);
nurbs_interp_surface(surf1, 3, flat_edges=1);
nurbs_interp_surface(surf1, 3, flat_edges=2);
nurbs_interp_surface(surf1, 3, flat_edges=[1,2,1,2]);
nurbs_interp_surface(surf1, 3, flat_edges=[1,2,[1,1,2,3,2,3,1,1,1],2]);
nurbs_interp_surface(surf1, 3, flat_edges=[undef,2,1/2,2]);
nurbs_interp_surface(rot([14,35,12],p=surf1), 3, flat_edges=1);
nurbs_interp_surface(surf1, 3, row_edges=[4]);
nurbs_interp_surface(surf1, 3, row_edges=[4],flat_edges=1);
nurbs_interp_surface(surf1, 3, row_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf1, 2, row_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf1, 3, row_edges=[3,6],flat_edges=1);
nurbs_interp_surface(surf1, 3, row_edges=[4],col_edges=5,flat_edges=1);
}



xdistribute(250){
nurbs_interp_surface(surf2, 3);
nurbs_interp_surface(surf2, 3, flat_edges=1);
nurbs_interp_surface(surf2, 3, flat_edges=2);
nurbs_interp_surface(surf2, 3, flat_edges=[1,2,1,2]);
nurbs_interp_surface(surf2, 3, flat_edges=[1,2,[1,1,2,3,2,3,1,1,1],2]);
nurbs_interp_surface(surf2, 3, flat_edges=[undef,2,1/2,2]);
nurbs_interp_surface(rot([14,35,12],p=surf2), 3, flat_edges=1);
nurbs_interp_surface(surf2, 3, row_edges=[4]);
nurbs_interp_surface(surf2, 3, row_edges=[4],flat_edges=1);
nurbs_interp_surface(surf2, 3, row_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf2, 2, row_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf2, 3, row_edges=[3,6],flat_edges=1);
nurbs_interp_surface(surf2, 3, row_edges=[4],col_edges=5,flat_edges=1);
}


xdistribute(250){
nurbs_interp_surface(surf3, 3);
nurbs_interp_surface(surf3, 3, flat_edges=1);
nurbs_interp_surface(surf3, 3, flat_edges=2);
nurbs_interp_surface(surf3, 3, flat_edges=[1,2,1,2]);
nurbs_interp_surface(surf3, 3, flat_edges=[1,2,[1,1,2,3,2,3,1,1,1],2]);
nurbs_interp_surface(surf3, 3, flat_edges=[undef,2,1/2,2]);
nurbs_interp_surface(rot([14,35,12],p=surf3), 3, flat_edges=1);
nurbs_interp_surface(surf3, 3, row_edges=[4]);
nurbs_interp_surface(surf3, 3, row_edges=[4],flat_edges=1);
nurbs_interp_surface(surf3, 3, row_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf3, 2, row_edges=[3,6],flat_edges=undef);
nurbs_interp_surface(surf3, 3, row_edges=[3,6],flat_edges=1);
nurbs_interp_surface(surf3, 3, row_edges=[4],col_edges=5,flat_edges=1);
nurbs_interp_surface(surf3, 3, col_edges=4,flat_edges=1);
}
}
