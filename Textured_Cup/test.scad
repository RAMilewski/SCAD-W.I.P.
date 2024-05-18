include <BOSL2/std.scad>
include <BOSL2/walls.scad>

$fn = 72;

module sparse_cuboid(size, dir, strut=5, maxang=30, max_bridge=20,
    chamfer,
    rounding,
    edges=EDGES_ALL,
    except=[],
    except_edges,
    trimcorners=true,
    teardrop=false,
    anchor=CENTER, spin=0, orient=UP)
{
  dummy1=assert(is_vector(dir,3), "dir must be a 3-vector");
  count = len([for(d=dir) if (d!=0) d]);
  dummy2=assert(count==1 && len(dir)<=3, "dir must have exactly one non-zero component");
  attachable(anchor,spin,orient,size=size){
    intersection(){
      if (dir.x) 
         sparse_wall(size.z,size.y,size.x,strut=strut,maxang=maxang, max_bridge=max_bridge);
      else if (dir.y)
         zrot(90)
           sparse_wall(size.z,size.x,size.y,strut=strut,maxang=maxang, max_bridge=max_bridge);
      else
         yrot(90)
           sparse_wall(size.x,size.y,size.z,strut=strut,maxang=maxang, max_bridge=max_bridge);
      cuboid(size=size, chamfer=chamfer, rounding=rounding,edges=edges, except=except, except_edges=except_edges,
             trimcorners=trimcorners, teardrop=teardrop);
    }
    children();
  }    
}  


sparse_cuboid([20,20,30], strut=2, dir=RIGHT, maxang = 15, rounding=3, except = TOP, teardrop = true);
fwd(30) sparse_cuboid([30,20,10], strut=1, dir=UP, chamfer=1);
fwd(60) sparse_cuboid([20,10,30], strut=1, dir=FWD);
