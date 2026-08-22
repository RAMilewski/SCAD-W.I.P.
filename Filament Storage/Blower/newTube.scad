module tube(
    h, or, ir, center,
    od, id, wall,
    or1, or2, od1, od2,
    ir1, ir2, id1, id2,
    realign, l, length, height,
    anchor, spin=0, orient=UP, orounding1,irounding1,orounding2,irounding2,rounding1,rounding2,rounding,
    ochamfer1,ichamfer1,ochamfer2,ichamfer2,chamfer1,chamfer2,chamfer,irounding,ichamfer,orounding,ochamfer,
    teardrop=false, clip_angle=90, shift=[0,0],
    ifn, rounding_fn, circum=false
) {
    realign = assert(is_bool(circum))
              default(realign,circum);
    h = one_defined([h,l,height,length],"h,l,height,length",dflt=1);
    orr1 = get_radius(r1=or1, r=or, d1=od1, d=od, dflt=undef);
    orr2 = get_radius(r1=or2, r=or, d1=od2, d=od, dflt=undef);
    irr1 = get_radius(r1=ir1, r=ir, d1=id1, d=id, dflt=undef);
    irr2 = get_radius(r1=ir2, r=ir, d1=id2, d=id, dflt=undef);
    wall = default(wall, 1);
    r1 = default(orr1, u_add(irr1,wall));
    r2 = default(orr2, u_add(irr2,wall));
    ir1 = default(irr1, u_sub(orr1,wall));
    ir2 = default(irr2, u_sub(orr2,wall));
    checks =
        assert(is_bool(realign))      
        assert(is_undef(center) || is_bool(center), "\ncenter must be boolean.")
        assert(num_defined([anchor,center])<2, "\nCannot give both anchor and center.")
        assert(is_vector(shift,2), "\n'shift' must be a 2D vector.")
        assert(all_defined([r1, r2, ir1, ir2]), "\nMust specify two of inner radius/diam, outer radius/diam, and wall width.")
        assert(num_defined([rounding,chamfer])<2, "\nCannot give both rounding and chamfer.")
        assert(num_defined([irounding,ichamfer])<2, "\nCannot give both irounding and ichamfer.")
        assert(num_defined([orounding,ochamfer])<2, "\nCannot give both orounding and ochamfer.")
        assert(num_defined([rounding1,chamfer1])<2, "\nCannot give both rounding1 and chamfer1.")
        assert(num_defined([irounding1,ichamfer1])<2, "\nCannot give both irounding1 and ichamfern.")
        assert(num_defined([orounding1,ochamfer1])<2, "\nCannot give both orounding1 and ochamfer1.")
        assert(num_defined([rounding2,chamfer2])<2, "\nCannot give both rounding2 and chamfer2.")
        assert(num_defined([irounding2,ichamfer2])<2, "\nCannot give both irounding2 and ichamfern.")
        assert(num_defined([orounding2,ochamfer2])<2, "\nCannot give both orounding2 and ochamfer2.");
    names = ["irounding","orounding","rounding","irounding1","irounding2","orounding1","orounding2",
             "ichamfer","ochamfer","chamfer","ichamfer1","ichamfer2","ochamfer1","ochamfer2"];
    vals =  [irounding,orounding,rounding,irounding1,irounding2,orounding1,orounding2,
             ichamfer,ochamfer,chamfer,ichamfer1,ichamfer2,ochamfer1,ochamfer2];
    bad = [for(i=idx(names)) if (is_def(vals[i]) && !is_finite(vals[i])) i];
    checks2 = assert(bad==[],str("\nRounding/chamfer parameters must be numbers. The following are invalid: ",
                                 select(names,bad)));
    findval = function (factor,vlist,i=0)
         i>=len(vlist) || is_def(vlist[i][1]) ? undef
                      : is_def(vlist[i][0]) ? factor*vlist[i][0]
                      : findval(factor,vlist,i+1);
    irounding1 = findval(-1,[[irounding1,ichamfer1],[rounding1,chamfer1],[irounding,ichamfer],[rounding,chamfer]]);
    irounding2 = findval(-1,[[irounding2,ichamfer2],[rounding2,chamfer2],[irounding,ichamfer],[rounding,chamfer]]);
    orounding1 = findval(1,[[orounding1,ochamfer1],[rounding1,chamfer1],[orounding,ochamfer],[rounding,chamfer]]);
    orounding2 = findval(1,[[orounding2,ochamfer2],[rounding2,chamfer2],[orounding,ochamfer],[rounding,chamfer]]);
    ichamfer1 = findval(-1,[[ichamfer1,irounding1],[chamfer1,rounding1],[ichamfer,irounding],[chamfer,rounding]]);
    ichamfer2 = findval(-1,[[ichamfer2,irounding2],[chamfer2,rounding2],[ichamfer,irounding],[chamfer,rounding]]);
    ochamfer1 = findval(1,[[ochamfer1,orounding1],[chamfer1,rounding1],[ochamfer,orounding],[chamfer,rounding]]);
    ochamfer2 = findval(1,[[ochamfer2,orounding2],[chamfer2,rounding2],[ochamfer,orounding],[chamfer,rounding]]);

    /*  This is too restrictive, at least on cones 
    dummy = 
      assert( first_defined([irounding1,ichamfer1,0])+first_defined([orounding1,ochamfer1,0]) <= r1-ir1, "\nChamfer/rounding doesn't fit at bottom.")
      assert( first_defined([irounding2,ichamfer2,0])+first_defined([orounding2,ochamfer2,0]) <= r2-ir2, "\nChamfer/rounding doesn't fit at top.")
      assert( -first_defined([irounding1,ichamfer1,0])<ir1, "\nNegative inside chamfer/rounding doesn't fit at bottom.")
      assert( -first_defined([irounding2,ichamfer2,0])<ir1, "\nNegative inside chamfer/rounding doesn't fit at top.");
    */

    anchor = get_anchor(anchor, center, BOT, CENTER);

    osides = segs(max(r1,r2));
    isides = default(ifn, segs(max(ir1,ir2)));

    adj_ir1 = circum ? ir1/cos(180/isides) : ir1;
    adj_ir2 = circum ? ir2/cos(180/isides) : ir2;
    adj_r1 = circum ? r1/cos(180/osides): r1;
    adj_r2 = circum ? r2/cos(180/osides): r2;


    
    morecheck=
        assert(adj_ir1 <= adj_r1, "\nInner radius is larger than outer radius.")
        assert(adj_ir2 <= adj_r2, "\nInner radius is larger than outer radius.");


    $fn = default(rounding_fn,$fn);

    outside= [
               [0,-h/2],
               each _cyl_path(adj_r1,adj_r2,h, 
                              chamfer1=ochamfer1, chamfer2=ochamfer2,
                              rounding1=orounding1, rounding2=orounding2,
                              teardrop=teardrop, clip_angle=clip_angle,n=osides, noscale=true),
               [0,h/2]
             ];
    ipath = _cyl_path(adj_ir1,adj_ir2,h, 
                      chamfer1=ichamfer1, chamfer2=ichamfer2,
                      rounding1=irounding1,rounding2=irounding2,n=isides, noscale=!circum);
    inside = [
               [0,-h/2-1],
               ipath[0]-[0,1],
               each ipath, 
               last(ipath)+[0,1],
               [0,h/2+1]
             ];
    parts = [
               define_part("inside", attach_geom(r1=adj_ir1, r2=adj_ir2, l=h), inside=true)
            ];
    attachable(anchor,spin,orient, r1=adj_r1, r2=adj_r2, l=h, parts=parts) {
        down(h/2) skew(sxz=shift.x/h, syz=shift.y/h) up(h/2) 
          difference(){
            zrot(realign? 180/osides : 0)rotate_extrude($fn=osides,angle=360) polygon(outside);
            zrot(realign? 180/isides : 0)rotate_extrude($fn=isides,angle=360) polygon(inside);
          }
        children();
    }
}    


