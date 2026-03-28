# nurbs_interp.scad — User Requests by Version

Reconstructed from conversation logs. Versions v1–v7 predate available logs;
requests are inferred from the Changelist. Quoted text is the user's prompt.

---

## v1
*(No log available — initial version created before recorded sessions)*

## v2
*(No log available — added closed/open types, debug module)*

## v3
*(No log available — fixed `_avg_knots_periodic` return format)*

## v4
*(No log available — added `start_der=`/`end_der=` endpoint tangent constraints)*

## v5
*(No log available — added surface interpolation)*

## v6
*(No log available — added `_bosl2_full_closed_knots` to match BOSL2)*

## v7
*(No log available — switched closed collocation to BOSL2 knots)*

## v8
> "I've added a ## Next Step section describing what we should do next. Let's go."
>
> *(CLAUDE.md Next Step said: "Modify nurbs_interp.scad to accept a derivative list with 'undef' being a possible entry for a point. The default should be all 'undef'.")*

## v9
> "Derivative control should work for closed and open NURBS as well as clamped."

## v10
*(Version bump only — no functional changes)*

## v11
> "Look at Methods.png. Switch from using Method B to using Method A in nurbs_interp.scad"

## v12
*(Span-count validation added during debugging — no separate prompt)*

## v13
> "Can you make the closed case rotation invariant?"

## v14
> "Look at Reference-1.png. With that information can you make the closed case rotationally invariant?"

## v15
> "These still seem somewhat wonky as interpolations of the provided data. Two issues: (1) adjust the curve back so the starting point aligns with the user specified one to avoid confusion and (2) is this interpolation correct/as good as it gets?"

## v16
> "interp_params() should throw an error on duplicate data. How should we normalize derivatives. The NURBS Book suggests using total chord length. Change start_der and end_der to use derivlist."

Also:
> "nurbs_interp-v14.scad in the archive folder is rotationally invariant, nurbs_interp.scad is not. What happened?"
> "Yes, verify whether the new method gives correct results."

## v17
> "explain why we need to have the starting offset _rot"

*(Investigation led to removing the unrotation logic)*

## v18–v19
> "Derivatives supplied as input should be multiplied by the total path length. The starting point for closed nurbs should be returned as result[2]. Check that derivatives input by users are of the correct dimension using this code: [provides _force_deriv_dim function]. Accept 3d derivative inputs for 2d derivatives to enable using LEFT, RIGHT, UP, DOWN, BACK, and FWD."

> "The resolver function should return the index of the starting point for the closed case, not the location of the starting point. The _force_derive_dim function should handle things specially when dim=2 and promote underlength derivatives to length for all higher dimensions."

## v20–v21
> "Simplify the code using BOSL2 functions max_index(), path_lengths(), path_segment_lengths(), repeat(), add_scalar(), select(). When several asserts appear in a row chain them together like assert(cond1)assert(cond2) etc. As a style choice for BOSL2, favor making lists without concat but using each instead..."

> "We don't need the open case. Simplify the code by removing the calculations for the open case."

## v22
> "We overdid a bit. `[each repeat(0, p+1), each interior_knots, each repeat(1, p+1)]` where everything is a list should in fact use concat. _interp_params_closed and _interp_params should be combined into one function with a closed param. And the total < 1e-15 bogus conditional branch removed. And the indexing of cs done using slice. Style issue: change derivs to deriv."

## v23
> "Look at the dynamic-centripetal-parameterization document and implement that as parameterization method. Use param = dynamic, param = centripetal, and param = length to select between the different methods."

## v24
> "What is the current default param method?" / "Change that to dynamic."

## v25
*(Degenerate-path handling added during debugging — surface pole rows returning uniform spacing instead of asserting)*

> "Example 3. RIVER PEBBLE in BlobLib_v2.scad used to run properly. It now fails with ERROR: Assertion ... 'nurbs_interp: consecutive duplicate data points detected'. Can you fix the issue in nurbs_interp.scad?"

## v26
*(Closed rotation validation helpers added during debugging)*

> "Look at test.scad in the workspace. Why does nurbs_interp_curve() fail only for the param='dynamic' case. Can you fix that?"

## v27
> "Figure 5 in dynamic-centripetal-parameterization-method.pdf and Figure 1 in fang.pdf appear to be using the same data sets. I would like to use those data sets to test our code."

*(Fang method added by user manually; see v28)*

## v28
> "I have added the fang interpolation method by hand. Check that I did that correctly. If not don't change anything, just report the problem. Also add the Foley interpolation method shown in balta.pdf in the workspace."

*(Bug fix: fang added to assertion whitelist)*

## v29
*(Foley parameterization added as part of v28 request)*

## v30
> "We would like the option to specify the start and end curvature on clamped curves. In 2d you need a signed curvature number; in 3d (and above?) you need a curvature vector, which is a vector pointing in the normal direction to the curve whose length is the desired curvature. Technically the curvature vector needs to be normal to the curve, but it seems like we could allow arbitrary vectors and it would take the magnitude from the length provided but take the direction by removing the tangential component."

## v31
> "Require derivative to be provided and non-zero if curvature is given. Allow vector specification of the curvature in 2d as well as higher dimension, but also accept a signed scalar in the 2d case. Add curvature support for the closed case too."

## v32
> "Normalize the dynamic parameterization method. Rename the param= argument method="

## v33
> "Why did you normalize using cmax? The paper says we want d>1, so if we normalize by cmin we guarantee that. If we normalize by cmax we guarantee that we never meet it."

## v34
> "Can we support partial derivatives on the edges of surfaces?"

## v35
> "The generic derivative constraints for surface edges aren't useful because they don't guarantee that the points in between the interpolated points actually have any known structure. So replace the derivative constraints for surfaces with a simpler constraint: For each edge accept a single derivative direction, and require that the edge points input be collinear."

## v36
*(Rollback — v35's collinear approach didn't work)*

> "We're going to roll back the last set of changes. nurbs_interp.scad should be made to match the version in the Archive folder named nurbs_interp-v34.scad"

> "Add a comment line near the top right after the License line that says 'Development Version 36' and each time we modify nurbs_interp.scad, increment that version number."

## v37
> "In the [clamped,closed] and [closed,clamped] cases, when a clamped edge consists of only copies of the same point, allow the user to specify a normal vector that is used to determine the partial derivatives at the degenerate edge. The partial derivatives should be chosen in the direction that creates a smooth surface at the end of the shape. Use the magnitude of the normal vector provided by the user to determine the magnitude of the partial derivatives, with the same scaling as usual."

## v38
> "Add the appropriate version number comment to those files in the Archive folder that do not yet have one."

> "Going forward every time you generate a new nurbs_interp.scad file put an appropriately named duplicate in the Archive folder."

## v39
> "Remove method='fang'. If start_u_normal, end_u_normal, start_v_normal, or end_v_normal is specified check that that edge is all a single point. If not throw an error."

> "Consolidate start_u_normal, etc parameters into just start_normal and end_normal. Since this only useful when one direction is clamped let the code decide between u and v."

## v40
> "Add the flat_edges= feature, which applies only when the four edges are coplanar, assigning derivatives along the edges that lie in the plane defined by the four edges so that the shape flares outward, scaled as specified in the parameter. The argument has the form flat_edges=[1,1,1,1] for a uniform derivative along each edge. You can vary an edge like so: flat_edges=[1,1,[1,2,2,1],1]"

## v41
> "Reverse the sign on flat_edges[0] and flat_edges[2]. Allow flat_edges = 1 to mean flat_edges[1,1,1,1]. For 2d have nan in the deriv list indicate a corner."

## v42
> "Corners don't seem to be working, try supporting corners by adding appropriate constraints to the matrix to deal with having repeated knots."

## v43
> "Set the default width to 1 in debug_nurbs_interp(). Can you make the corner code join all the segments together in a single b-spline?"

## v44
> "In cases of inadequate point counts with corners: error (not enough points), perform degree elevation so the curves can mesh, with the caveat that the degree elevated data won't really be of the specified degree, so it will be less smooth at knots. Expand corner support to the 'closed' case. Expand corner support into edge support for surfaces. Can curve interpolation work in arbitrary dimension if we just don't constrain it? Degree elevation may as well be a user facing function, and presumably should work for closed and clamped both."

> "4 and 5" *(selecting degree elevation and dimension-agnostic from the task list)*

## v45
> "Since we already have support for corners for curves, couldn't edges in surfaces be achieved by just calling the existing support without having to divide the surfaces up into patches?"

> "Yes, so u_edges= and v_edges= list the index where an edge is to be inserted."

## v46
> "Add corners=[index list] as an alternative syntax for the corners in the 2d curve case to parallel u_edges and v_edges."

## v47
> "Does the corners= syntax work on closed NURBS?"
> "Yes." *(confirming implementation requested)*

## v48
> "If you specify a corner and derivative at the same location it looks like the derivative wins. Instead that should be an error."

## v49
> "For nurbs_interp and nurbs_interp_surface reorganize so that the returns are of the form [type, degree, control_pts, knots, weights, closed_starting_point]. Specify weights as undef if there are no weights. Provide a way to turn off the control point lines in debug_nurbs_interp(). Permit u_edges and v_edges to accept a singleton and promote it to a list, e.g. with force_list(). Allow flat_edges to work with u_edges and v_edges."

## v50
> "Change from chord length foley to centripetal foley. Use BOSL2 is_nan() and is_coplanar() throughout the code where appropriate. Do a code review of all of nurbs_interp(). Write asserts for parameter validity where appropriate."

## v51
> "nurbs_interp should assert is_path(points, undef). Arguments text strings need to be on one line. Degree elevation only works on b-splines not NURBS. Change parameter names: start/end_normal -> normal1/2, start/end_der -> start/end_deriv, start/end_u/v_deriv -> u/v_edge1/2_deriv, curv -> curvature, start/end_curve -> start/end_curvature. Throw an error if flat derivative condition is impossible. When converting the curvature specification, get the magnitude from the input vector before taking the perpendicular projection, and then use the perpendicular projection only to provide the direction."

## v52
> "We need degree elevation to work on NURBS. Follow the procedure you outlined, i.e. elevate to the n+1 dimensional space, recursively run a non-weighted elevation, then take what you get, extract the weights."

## v53
> "Change the argument descriptions back to the way they were in v50, but just don't break the description of a single argument into more than one line. The lines can be very long. Newlines confuse the post-processor we use to generate the wiki."

## v54
> "See the code in curvature.scad. It throws an error. Can you fix that?"

*(Bug fix: `eff_curvature` → `eff_curv` typo in 5 locations)*

## v55
> "Review all of nurbs_interp and ensure that in every for loop you're declaring an explicit step size. e.g. line 808 should be: `loc = [for (i = [1:1:len(segments[s][1])-2]) segments[s][1][i]],`"

## v56
> "In debug_nurbs_interp(), stroke should be called with closed=true."

## v57
> "Are there any other places in nurbs_interp() where stroke() is called when drawing closed loops without declaring closed=true?"

> "Fix example 7 anyway."

## v58
> "Look at line 153 in test-3.scad. Why does that fail, and can it be fixed?"

## v59
> "For closed curves only: Use chord-length parameterization. Compute averaged knots cyclically (Park-Lee style). After construction, check the minimum knot span. If any span is below a threshold epsilon ~= 10^-6 (relative to the period), merge that span and adjust neighboring knots by bisection."

> "Don't force chord-length."

## v60
> "This seems to give bad results though: `debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color='black', data_size=1, method=method, type='closed', deriv=[undef,undef,undef,undef,[1,-1]/2,LEFT/3], curvature=[undef,undef,undef,undef,undef,undef]);`"

> "Add more control points to closed curves that don't have corners where the ctrlpoint_ratio > 2^degree/degree"

## v61
> "data2 = [[54.2713, -14.679], [41.5689, -29.042], [67.9256, -63.3349], [-50.39, -73.0243], [-36.9592, -43.2663], [-34.3756, -26.604], [-50.5462, -22.6036], [-42.484, 12.7769], [-53.767, 57.6077], [-4.56084, 49.3793], [3.27214, 28.315]]; debug_nurbs_interp(data2,3, splinesteps=32, show_ctrl=false, data_color='black', data_size=1, method=method, type='closed'); Why is this example wildly out of control?"

*(Replaced midpoint-refinement with spread-based rotation search)*

## v62
> "Look at the code in examples_fail.scad and the image in examples_fail.png. Why does setting normals have no effect?"

> "Look at normaltest-1.scad. If u_edges is set to 3 neither normal constraint is imposed. If u_edges is set to 4, only the normal1 constraint is imposed. If u_edges is set to 2, only the normal2 constraint is imposed. Can you fix it?"

## v63
> "Add a `method='quadratic'` option to nurbs_interp which implements local rational curve interpolation as described in the NURBS Book, 9.3.3. Implement only the corner preserving mode where alpha_k=1. Add support for data_size=0 in debug_nurbs_interp_surface, or another way to turn off the dots."

## v64–v65
*(Bug fixes for assert message guards — undefined variable warnings in surface edge code)*

> "If I run normaltest-1.scad using v64, even for the valid u_edges values of 2, 3, or 4, I get a large number of warnings about operations on undefined values and unknown variables."

## v66–v67
> "Still getting warnings about has_sud_eff and has_eud_eff being missing."

> "Now getting WARNING: undefined operation (undefined - number)..."

## v68
> "Look at curvetest.scad. It does not appear to be preserving corners."

## v69
> "I'm looking for behavior more like figure 9.24(b) in The NURBS Book, page 395."

> "Not even close. Using method quadratic it yields what you see in curvetest-data5.png."

## v70
> "{(0,0),(3,4),(-1,4),(-4,0),(-4,-3)} can't be the data from P&T fig 9.24. The book doesn't list the data points. v69 and that data yields what you see in curvetest-data6.png. v69 and data5 yields what you see in data5.png which isn't quite right either."

## v71–v72
> "It looks like you implemented the Bessel method for estimating tangents, which is a 3 point method based on (9.30) and (9.28) in The NURBS Book. Change that to use the five point estimate based on (9.29) and (9.31)."

## v73
> "NO!! ALWAYS increment the version number if you change anything in nurbs_interp.scad no matter how small the change. Undo the changes in v72 in the archive and archive the current version as v73."

*(Bug fix: restored accidentally removed `params = _interp_params(...)` line)*

## v74
> "Figure 9.24(b) in The NURBS Book is in the file fig9.24b.png. When I run curvetest.scad with method = 'quadratic' and data5 (from data.scad) I get the plot in data6.png. It's supposed to require 3 collinear points to get a straight line. What's wrong?"

## v75
> "All the corners are still right angles with data6. Why don't we get the curve like in fig9.24b.png?"

## v76
> "Still not right. According to P&T, 3 collinear points should define a straight line. So there should be square corners at data points 6 and 8."

## v77
> "nurbs.scad in BOSL2 has been updated to support parameter lists [type, degree, ...] to specify the nurbs. A bug involving knots vanishing if you specify weights has been fixed. Review the nurbs_interp.scad code and simplify it to take advantage of those changes."

## v78
> "Remove the quadratic method from all of nurbs_interp.scad."

## v79
> "Add a new method named 'lockyer' that implements the W=1 method from Lockyer2007.pdf shown in chapter 3.1"

## v80
> "The results from lockyer W=1 method are worse than centripetal, but the paper said they were supposed to be better. Are you sure the implementation is correct? Can you double check please?"

## v81
> "Implement the full pipeline."

*(Replaced custom Newton solver with BOSL2's `root_find()`)*

## v82
> "nurbs_debug() in nurbs.scad has been fixed to accept parameter lists. [error about blob3 data failing with len() undef]"

> "Review nurbs_interp.scad, use find_root() from BOSL2's math.scad where appropriate."

## v83
> "Look at test_random3d.scad. The results for centripetal and lockyer appear identical. Is that correct?"

*(Investigation confirmed lockyer was identical to centripetal; led to removal)*

> "Remove both the lockyer and foley methods." / "My error! Roll that back and just remove Lockyer."

## v84
> "Put fang back in. Foley has a check that the value is smaller than 1e-15. Can this ever happen or can this check be removed? Foley also sets theta_hat to zero at the ends and then later checks again for the ends. Is this necessary? Remove if it's not."

## v85
> "Add a color argument to debug_nurbs_interp(). Be sure that both color and data_color arguments work properly. Note that BOSL2's color.scad has modules that may be useful. Increase the size of the data dot to double its current size."

> "Keep the version number and make centripetal the default method everywhere."

## v86
> "If I run: `data = regular_ngon(8,100); debug_nurbs_interp(data,3,show_ctrl=false,data_size=1,type='closed', deriv=[DOWN,undef,undef,undef,undef,undef,undef,undef]);` Why does the shape of the curve change on the opposite side of the curve from where I applied the constraint?"

> "Why is the solution not symmetric when the constraint is symmetric?"

*(Led to trying rot=0 first for symmetry preservation)*

## v87
> "Does 'insert a knot at the constraint parameter value' create a duplicated knot? If so, that would create a problem. If not, implement your knot-insertion approach."

## v88
> "But symmetry is broken."

*(Added knot palindrome symmetrization)*

## v89
> "Yes, the comment was about v88. The code I'm running is ngonsandbox.scad. Only line 3 is changing between runs. Added v88.png to Images/"

*(Changed closed constrained rotation back to rot=0 first)*

## v90
> "So you bumped the version number without putting a copy of v89 in the Archive?"

> "Query: Could the symmetry breaking be a result of the extra control point that is inserted due to the derivative constraint? How is the control point location chosen for this extra point? But look at v89.png in Images/. That's not symmetrical."

*(Made knot-proximity nudge direction symmetry-aware)*

## v91
> "It's not." *(confirming v90 is still not symmetric)*

*(Replaced knot-insertion with uniform bar_knots)*

## v92
> "There is still a bug with degree 2 surfaces. It fails with WARNING: len() parameter could not be converted... in file nurbs_interp.scad, line 2294"

## v93
> "Remove current symmetry enforcing code and implement this: [detailed strategy for quantile/selection knots for clamped and closed cases, with formulas for index placement and discussion of regularizers]"

## v94
> "The quantile method produces poor results, with long segments that wiggle weirdly, so we think we need to switch to averaging with knot insertion."
>
> "If we run _fix_tiny_spans() at the end doesn't that handle concerns about knots being too close or colliding? Couldn't we insert at the parameter location and then clean up with _fix_tiny_spans?"

## v95
> "Implement this: Compute base bar_knots by standard averaging (periodic or interior). For each constraint, identify the span containing its parameter. Insert at the midpoint of that span, one at a time, largest-span-first among constraint spans if there are ties. Apply _fix_tiny_spans at the end as a safety net."

## v96
> "Add the 'extra control points' feature."

*(Implemented midpoint-refinement; superseded by v97)*

## v97
> "I had in mind that the user gives extra_pts=2 and it increases the number of control points by 2. I'm hoping that instead of having to poke the weirdness with a whole bunch of derivative constraints, that adding points can help."
>
> Approach: weighted-quantile / widest-span knot placement + d²C/dt²=0 smoothness rows.
