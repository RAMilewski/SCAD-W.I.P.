function metaballs(funcs, isovalue, bounding_box, voxel_size, closed=true, show_stats=false) =
    assert(all_defined([funcs, isovalue, bounding_box, voxel_size]), "\nThe parameters funcs, isovalue, bounding_box, and voxel_size must all be defined.")
    assert(len(funcs)%2==0, "\nThe funcs parameter must be an even-length list of alternating transforms and functions")
    let(
        nballs = len(funcs)/2,
        // set up transformation matrices in advance
        transmatrix = [
            for(i=[0:nballs-1])
                let(j=2*i)
                assert(is_matrix(funcs[j],4,4), str("\nfuncs entry at position ", j, " must be a 4×4 matrix."))
                assert(is_function(funcs[j+1]), str("\nfuncs entry at position ", j+1, " must be a function literal."))
                transpose(select(matrix_inverse(funcs[j]), 0,2))
        ],

        // set up field array
        bot = bounding_box[0],
        top = bounding_box[1],
        halfvox = 0.5*voxel_size,
        ones = [for(i=[1:nballs]) 1],
        xset = [bot.x:voxel_size:top.x+halfvox],
        yset = list([bot.y:voxel_size:top.y+halfvox]),
        zset = list([bot.z:voxel_size:top.z+halfvox]),
        allpts = [for(x=xset, y=yset, z=zset) [x,y,z,1]],
        trans_pts = [for(i=[0:nballs-1]) allpts*transmatrix[i]],
        vals = [for(j=idx(allpts))
                   [for(i=[0:nballs-1]) funcs[2*i+1](trans_pts[i][j])] *ones
               ],
        fieldarray = list_to_matrix(list_to_matrix(vals,len(zset)),len(yset))
    )
    isosurface_array(fieldarray, isovalue, voxel_size, origin=bot, closed=closed, show_stats=show_stats);