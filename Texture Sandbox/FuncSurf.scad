// Arguments:
//   f = function literal accepting two arguments (x and y) that defines the function to compute
//   xrange = A list or range of values for x
//   yrange = A list or range of values for y
//   zbounds = Constrain the function to these bounds.  Default: [-INF,INF]
//   base = Amount of extra thickness to add at the bottom of the model.  Default: 1
//   style = {{vnf_vertex_array()}} style used to triangulate heightfield textures.  Default: "default"

module func_surf(f,xrange,yrange,zbounds=[-INF,INF], base=1, sheet=false, anchor="origin", orient=UP, spin=0, atype="hull", cp="centroid", convexity=4, style="default")
   vnf_polyhedron(func_surf(f,xrange,yrange,zbounds,base,sheet, style=style), atype=atype, orient=orient, anchor=anchor, cp=cp, convexity=convexity) children();
   
function func_surf(f,xrange,yrange,zbounds=[-INF,INF], base=1, sheet=false, anchor="origin", orient=UP, spin=0, atype="hull", cp="centroid", style="default") =
   assert(is_finite(base) && base>0, "base must be a positive number")
   assert(is_vector(xrange) || valid_range(xrange), "xrange must be a vector or nonempty range")
   assert(is_vector(yrange) || valid_range(yrange), "yrange must be a vector or nonempty range")
   assert(is_bool(sheet))
   assert(is_list(zbounds) && len(zbounds)==2 && is_num(zbounds[0]) && is_num(zbounds[1]), "zbounds must be a list of two values (which may be infinite)")
   let(
       data = [for(x=xrange) [for(y=yrange) [x,y,min(max(f(x,y),zbounds[0]),zbounds[1])]]]
   )
   sheet ? vnf_vertex_array(data,style=style)
 :
   let(
       bottom = min(column(flatten(data),2))-base,
       data = [ [for(p=data[0]) [p.x,p.y,bottom]],
                each data,
                [for(p=last(data)) [p.x,p.y,bottom]]
              ],
       vnf = vnf_vertex_array(transpose(data), col_wrap=true, caps=true, style=style)
   )
   reorient(anchor,spin,orient, vnf=vnf, p=vnf);
