# nurbs_interp.scad — User Requests by Version

Reconstructed from conversation logs. Versions v1–v7 predate available logs;
requests are inferred from the Changelist. Quoted text is the user's prompt.

> **Ordering rule**: entries are in ascending version order (v1 at top, latest at bottom).
> New entries MUST be appended at the END of this file. Do not prepend.

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

## v98
Eliminate the current approach involving dc^2/dt^2. Implement the approach in note1.md and provide two options, first difference of control points and second difference of control points.

## v99
Add the integrated squared second derivative technique as additional option.

## v100
It seems like we should be able to get a solution in the underdetermined (singular) case by imposing the constraint that we just added. Why can't we? Yes [implement KKT fallback for all singular systems].

## v101
KKT system fails for closed constrained curves with extra_pts. Fix: add Tikhonov regularization to R matrix.

## v102
KKT still fails with ε=1e-10 regularization. Replaced indefinite KKT saddle-point system with Schur complement decomposition (two PD solves).

## v103
Schur complement still fails for closed constrained test case. Replaced with penalized normal equations (R + μ·A^T·A)·P = μ·A^T·Q — always SPD, no singular intermediate matrices.

## v104
User asked to investigate rank-deficiency. Diagnosed root cause: two data points sharing a knot span (Schoenberg-Whitney violation). Fix: auto-detect and split multi-occupied spans.

## v105
Penalized-only solve (v103-v104) misses two data points visually. Fix: try Schur complement first (exact interpolation now that span splitting ensures full-rank A), fall back to penalized only if needed.

## v106
v105 still misses data points — Schur complement was failing due to ill-conditioning from mixed row scales (curvature ~3000 vs interpolation ~0.7), falling back to approximate penalized solve. Fix: row equilibration.

## v107
v106 still misses points. Diagnosed: rot=0 had Schur=OK but high spread, so rotation search picked rot=9 which used penalized fallback (Schur=FAIL). Fix: rotation search only considers exact solutions; penalized is a last resort.

## v108
"(1) It's not OK to give answers that don't satisfy the constraints, so never use penalized normal equations. (2) Replace schur complement and penalized normal equations with null space method."

## v109
"Why is it still doing rotation searches?" / "Yes." (remove them)

## v110
"Modify the curvature code so that it accepts BOSL2 directions (UP, DOWN, etc) the way we can for derivatives."

## v111
"Can we have surfaces accept extra_pts which could be a scalar (applies to both directions) or a pair [ep_u,ep_v] that applies to the two directions separately. And then it would need to accept smooth as well"

## v112
"Bosl2's linear_solve() has been updated. Read lines 486 - 586 of linalg.scad. nurbs_interp.scad to take advantage of the changes. Make extra_pts work with corners. It seems like it needs to propagate to the subsegments, generally rounding up, but assigning zero extra points on linear segments (and I think maybe quadratic if smooth is not 1 because otherwise it doesn't work). Extra_points should be banned entirely when degree is 1."

## v113
"All my tests with surfaces are failing with: WARNING: undefined operation (undefined - number) in file ../nurbs_interp.scad, line 345"

## v114
"BOSL2's linear_solve() has been updated again. It now supports cholesky as well as QR and lu. Are you sure you're using the right method everywhere?"

## v115
"linear_solve() has been reworked yet again. QR should now be competitive with LU for speed. Take another look at how you're using linear_solve. Going forward if you see things that are badly implemented elsewhere in BOSL2, please notify me before you code a replacement as a work-around."

## v116
"nurbs_interp.scad will eventually be merged into nurbs.scad so it's ok to use _extend_knot_vector() and any other nurbs.scad internal function."

## v117
"Now we can use normal1 and normal2 only when the end points are are all the same.   Change to code to accept them if the points at each end are colinear."

## v118
"That was an error on my part.   I meant if the points at each end are coplanar, not colinear.  Roll back if you need to, but this should be v118."

## v119
"when the points at the end edge are all the same point, do what you were doing before.   When the points are coplanar, derivatives should be oriented so that a positive value causes the shape to close inward and a negative value causes it to flare outward.  Maybe is_polygon_clockwise() can help with this.   normal1 and normal2 should be arrays."

## v120
"Return normal1 and normal2 to previous behavior for points. Allow a vector, not a list. Add flat_end1 and flat_end2 that do what normal1 and normal2 were doing for coplanar ends in the latest version. And the sign interpretation of (current) normal1 and normal2 is backwards. The flat_end1 and flat_end2 feature would require that the end curve be coplanar and also that it define a plane, so not collinear, because the derivative has to live in that plane."

## v121
"The sign is correct at flat_end1, but mis-interpreted at flat_end2."

## v122
"The sign on flat_end1 and flat_end2 are backwards. Positive should point in and negative should point out. flat_end1 and flat_end2 should only be allowed on surfaces closed in one direction and clamped in the other. Extra points is not working on surfaces, it should."

## v123
"For flat_end1 and flat_end2, positive values should cause the shape to curl inwards towards the interior of the polygon. The centroid is not a robust way to find the polygon interior, but if the polygon is projected onto the plane that contains it and is then found to be clockwise then the interior is always on the right side as you traverse the polygon in the projected space. Is this fact being properly exploited? Or are you using some other equivalent method that finds the polygon interior and orients towards that? We're sometimes seeing 'failed: nurbs_interp_surface: flat_end1 is ambiguous — both u=0 and v=0 edges are coplanar; use u_edge1_deriv or v_edge1_deriv explicitly'. It should work like normal1 and normal2 where it has to be closed in one direction and that defines which edges are the 'ends'."

## v124
"The sign for flat_end1 is wrong."

## v125
"Revert KKT method to nullspace which was faster/more accurate. Flip sign at end1. 'The direction of the derivative for flat_end1 is reversed from what we need. Reverse this direction.' extra_pts doesn't work for surfaces (fails while building colocation matrix for the [clamped,closed] case and a different way for the fully clamped case--maybe this is a failed solve?)"

## v126
"Implement your proposed method for the moon problem, and implement the M fix. is it possible to set extra_pts too high so that it causes some kind of failure? (Should there be a max value for extra_pts?)"

## v127
"Look at smooth.scad in Examples and Examples/Images/smooth.png. When smooth=2 why is the interior exposed?"

## v128
"Look at smooth2.png. The interior is still showing in smooth.scad when smooth=2. Why?"

## v129
"clamped.scad fails with ERROR: Assertion '(!has_ve || (type_v == \"clamped\"))' failed ... Can you just cut the shape and turn it into a clamped-clamped case internally?"

## v130
"Set the smooth default to 3. Why are extra points not permitted in the u direction of surfaces?"

## v131
"I'm a little confused. It sounds like it says you can use extra_pts in the v direction with edges but not the u direction? I find that I get an error if I give extra_pts in either direction.
debug_nurbs_interp_surface(select(blob8,1,-2), 3, v_edges=[4,9], u_edges=2,type=[\"clamped\",\"closed\"],extra_pts=[0,3],smooth=3,data_size=0,splinesteps=[32,16]);"

## v132
"Allow, but don't require, edge derivative specifications such as u_edge1_deriv be a single 3-vector in which case it should use repeat() to expand it to the correct length."

## v133
"Look carefully at the functions available in geometry.scad, lists.scad, and vectors.scad and make sure nurbs_interp.scad doesn't re-implement functions available in those files. Simplify the code using functions found in lists.scad and vectors.scad, and particularly consider using repeat(), is_vector and force_list(). Also consider where default() found in utility.scad might be used to simplify the code."

## v135
"remove nurbs_interp_vnf.  merge nurbs_interp_surface and debug_nurbs_interp_surface under the single name nurbs_interp_surface.  The function version of nurbs_interp_surface remains unchanged.  The module form of nurbs_interp_surface runs the function form to create the spline and then passes it to the module nurbs_vnf() to create the geometry.  The module nurbs_interp_surface should pass through splinesteps (with same default of 16), the 3 caps parameters, reverse, style and triangulate.  the module nurbs_interp_surface should still support data_size, but the default should be size zero to produce no data points."

## v134
"extend nurbs_elevate_degree to support 'closed' and 'open' types so that this function is fully general."

## v136
"1. Fix closed degree elevation to be exact — BOSL2 now supports mult for closed type, enabling exact elevation via doubled multiplicities. 2. Update all output formats to new BOSL2 6-element format: [type, degree, control, knots, mult, weights] — affects nurbs_interp(), nurbs_elevate_degree(), internal callers. 3. rewrite debug_nurbs_interp, you can now offer a knots option, passthrough to debug_nurbs now because show_control exists. show derivative arrows and curvature circles (2d) or curvature cylinders (3d). curvature circles and cylinders should be color([0,1,0,0.1]), derivative arrows should be black, knots should be purple, control points should be blue and the lines connecting control points should be lightblue. make the derivative arrow using stroke and an 'arrow2' endcap. Make it half the width of the curve. mark zero curvature constraints with a line segment through the curve."

## v137
"Remove the color and data_color options to debug_nurbs_interp. In debug_nurbs_interp you should be able to avoid duplicating any functionality from debug_nurbs. If there's a problem, don't work around it, let us know the problem. The typo has been fixed. So you should be invoking debug_nurbs as a pass through and then adding just the data points, derivatives and curvature. Add show_curvature and show_deriv to control whether those items are displayed, both defaulting to true. Change show_ctrl to show_control and make it default to false.
It appears that there is code duplication across nurbs_interp.scad for computing the derivative list from deriv and start_deriv and end_deriv and similarly for computing the curvature. Instead of duplicating code, write a helper function that can be called in multiple places. This helper function will ensure consistent argument handling across the entire code.
Proper processing of 3d derivative directions does not occur in debug_nurbs_interp(). It treats UP as UP when drawing the arrow. This should be corrected when you consolidate with a helper function.
Derivative endcap should be endcap2='arrow2' as the current syntax does not work.
The derivative is scaled to a reasonable length but it is normalized. Since the behavior depends on the magnitude of the derivative the length should scale with that magnitude rather than just being a normalized length. The current scale depends on the curve, so the arrows get long when the answer is wild and bad; change that to be based on len(points) instead.
For curvature, the debug module assumes curvature is a vector and gives an error if it's a scalar. Again, an argument processing consistency issue that will be fixed by using a helper.
For zero curvature, draw a shorter line that is the same width as the curve and the same color as curvature circles. Also use the known exact derivative rather than estimating from the point list."

## v138
"The derivative arrows are too short. Set arrow_scale to pathlen(points)/np and scale their length by this value. The zero curvature case should have a fixed length independent of the derivative. Make the total length equal to 0.6*arrow_scale. Change the width to 2*width. Set endcaps='butt'. The helper functions for assembling derivative lists could help more if they also handled data conversions such as forcing 3d data to 2d for the 2d case, and handling array vs scalar conversion for 2d curvature. Is there some reason not to centralize as much of this parameter processing as possible into those helper functions? It looks like _nurbs_interp_closed_constrained is just a passthrough. Can it be eliminated? der_d in the curvature overlay section has a whole bunch of impossible cases checked. If we get this far, the derivative must always be defined in eff_der[i] or we should have asserted out already with a helpful message. For zero curvature, draw a shorter line that is the same width as the curve and the same color as curvature circles. Also use the known exact derivative rather than estimating from the point list."

## v139
"Finish the two-step cleanup: update _nurbs_interp_closed to project deriv/curvature via the helpers before dispatching, then remove the now-redundant _force_deriv_dim calls from both constrained solvers."

## v140
"At 2d corners (where derivative is nan) place a black mark using the same line width as for the derivative arrows with zrot(45)stroke([rect(3.5*width*ds)],width/2). For 3d corners place a mark using vnf_wireframe(octahedron(5*width, width/4)). Change the color of the data dots from 'magenta' to 'red'. For 3d curves the curvature cylinder does not appear in the correct place. It is not tangent to the curve and is sometimes rotated incorrectly. Fix this, and also make the curvature cylinder have a thickness equal to width. The curvature cylinder should be in the plane defined by the derivative and the curvature vector."

## v141
"You need to draw diamond on all of the declared corners, not just those set with a NaN derivative."

## v142
"rot(v=binom) rotates round the vector binom, which is not what you want. You need instead rot(from=UP,to=binom) to do it that way, but even better, use cyl(h=width, r=r, orient=binom) and then no rot() is needed. Instead of repeating the color command twice inside the curvature overlay section, put the color command at the beginning, right before the for() loop. Also can vector_perp be used to calculate cv_perp? And in the scalar case, couldn't cv be written using sign(cv) more neatly? Instead of for(pt=points) translate(pt) write move_copies(points)."

## v143
"You lost the translate(ctr) that is needed to correctly position the cyl(). You do not need anchor=CENTER for cyl() because that's the default. The translate(ctr) can be done as move(ctr) and can be above the if() so it doesn't need to be repeated, because that translation occurs in both 2d and 3d cases. Add a control_index option that acts as a passthrough to the show_index parameter of debug_nurbs(), and set the default for control_index to false."

## v144
"Add a data_index option which defaults to true that works like show_index for debug_nurbs() and displays the data point index value in red. Use the size parameter to determine text size of these labels. Only display labels if data_size>0."

## v145
"If I specify a derivative of BACK and a curvature of BACK/8 that should be an error in either 2d or 3d. It is not an error in nurbs_interp() in either dimension, but does produce a cryptic error in debug_nurbs_interp(). This error condition should get trapped in nurbs_interp() with a comprehensible error message. The text labels for the data points are landing on top of the dots. To fix this in 2d anchor the text to BACK and shift it fwd(2*ds). In 3D apply up(ds+sz/3) in front of the rotation. Also note that the data points and data point index labels can be combined into one block with one color command and a single test for ds>0 for the block. It could use a single move_copies() command and make use of $idx to get the index label if required."

## v146
"The translation of labels in 3d is wrong. Instead of up() in front of the rot($vpr) it should be back() after that rotate (to the right in the code, between the rot() and text3d() calls)."

## v147
"Create the curvature overlays last so that their transparent objects don't hide parts of the data point dots."

## v148
"Add to the nurbs_interp() docs a description of extra_pts and smooth. The docs should be written for a user, so they should explain how to use the function to get results, without excessive detail about internals that don't help the user use the function. There is no 'Returns:' documentation block. The information about what is returned should be rolled into the 'Description:' block. Also in the 'closed' case doesn't the return include a rotation parameter as its last entry? Include a description in the Description section of the 'method' parameter and the different methods and their advantages/disadvantages/purpose. The references can go there. In the arguments section just list them without the detailed descriptions and references. Right now if you request too many extra_pts it silently doesn't add more points. Add an echo that lets the user know that they have requested too many and the number has been decreased to <whatever>, so the user doesn't expect keep increasing the value and expecting a change. The extra_pts argument description should not tell where extra knots are placed---that can go in the Description. The user doesn't care what numerical solution method is used, so don't mention that at all. For explanation of smooth, instead of 'regularization' say 'smoothness metric' or something like that. You can say you're maximizing that metric, though I suppose total curve length isn't really smoothness, exactly. 'Regularization' is a technical term users won't know, so find a way to explain this better. Also a bit more on what 'true bending energy' means in words would be helpful, and how it's different from smooth=2. Note also throughout the docs that math is supported with dollar signs (I think mathjax) so that's a better way to incorporate math for the docs, which are markdown. Through the doc texts, put all of the parameter names in code font, e.g. \`param\`"

## v149
"For nurbs_debug_interp() say {{nurbs_interp()}} to create a linkable reference... Head text should say something like 'Calls nurbs_interp() to create an interpolated nurbs curve and displays the curve with informative overlays'... The list of overlays should have the headings read in this order data points, derivative constraints, curvature constraints, corners, knots, control points... Generally favor the active voice... In the nurbs_interp_surface doc section change heading to Function&Module... Describe the type options and outcomes... Describe the general partial derivative constraints last... Don't abbreviate parameter names with a * like '*_normal'... Make sure that this doc section is correct throughout... List the return information up front... The 'to render' section is obsolete since this now renders if called as a module, but you could give instructions on how to get a vnf. The list of parameters has items on separate lines, which will all be run together into a paragraph by markdown... The edges information should precede the info about general derivative constraints... Can flat_edges be used in a case other than ['clamped','clamped']? The docs say yes but I thought not."

## v150
"When you call debug_nurbs() can't you just pass result as a list? Restore the rotation entry to the return parameter list as a 7th element. When extra_pts is used with a surface that has edges, do you distribute the points over the sections? Or give each section the full amount? I got a message when I gave extra_pts = 3 with a 5x16 input grid that said 'extra_pts=3 exceeds available number of knots spans (1)' which is a little confusing. I have u_edges=2 so the length 5 dimension is broken into two smaller sections of 3 points each. I would expect each one to get 1.5 of the extra points, rounding up to 2, but then that's too many, so the message should tell me that 2 is the maximum? Is there some reason you need to just propagate the full extra_pts value? Can the error checking here happen at the higher level so I don't see the message repeated four times? And also it should tell me whether it's the u or v extra_pts value that was being capped. Documentation for return in nurbs_interp_surface doesn't list all the fields. For cases with a 'closed' direction with nurbs_interp_surface, I can end up with a rotation from the original input, right, just like in the curve case? Can we have the 7th return entry give the index pair where the [0,0] entry ended up in the rotated solution? Add a 1-2 sentence description of what curvature means for users that aren't familiar or forgot? the docs say that u_edge and v_edge require 'clamped'. That isn't true, is it? And for 'closed' case I think edges can go at index 0. Correct that doc inaccuracy. Introduce normal1/normal2 right after the flat boundary derivatives section. In the advanced section, the explanation of vector scale is confusing. Rewrite that to be more clear. I think you are allowed to give a list of vectors, or a single vector that will be expanded to a list. That's not clear from the docs. And the interpretation of the scale could be stated more clearly as well. Describe extra_points at least briefly in the interp_surface. You can reference the longer description in {{nurbs_interp()}} and focus here on how the option works for surfaces. Add to nurbs_interp docs a description of how extra_pts works when you add corners to the model."

## v151
"There is now a copy of nurbs.scad in the workspace with those two bugs fixed. Make the appropriate changes to nurbs_interp.scad."

## v152
"Remove the knots= parameter from debug_nurbs_interp(). Make sure that defaults for all parameters listed in the arguments section match the code and correct the documentation if they don't match. I noticed a mismatch for nurbs_interp() with method=. The documentation says that degree reduced segments created using corners don't get extra points. Is this the case even if I'm building for example a degree 8 spline and my degree reduced case is degree 7? Is there some reason not to give a segment like that some extra points? Is it the case that when a curve is broken up, the extra points are distributed with rounding up, so you may end up with more points than requested, but never fewer?"

## v153
"Add a brief description to nurbs_interp of how the knot positions are calculated. When you say that extra_pts are distributed 'according to size' do you mean according to the point count, or some other size? For curvature in the 2d case if you give a vector doesn't it also take the perpendicular component, just like with higher dimensions? instead of returning undef if no rotation occurs return 0 for curves or [0,0] for surfaces. Change default smooth value for debug_nurbs_interp to 3 and update docs."

## v154
"debug_nurbs_interp(regular_ngon(r=10,n=7), 3,type=\"closed\",deriv=[2*DOWN,undef,...],show_knots=true,extra_pts=3): two knots placed between points 6 and 0 — why? Similar issue with n=8 example. Is this a bug? In debug_nurbs_interp() make the default data_size equal to the width instead of fixed to 1."

## v155
"When splitting the extra_pts due to corners, instead of distributing extra_pts uniformly on eligible segments, distribute them proportionally to the number of control points in each segment, still rounding up."

## v156
"Rewrite and consolidate docs for nurbs_elevate_degree (concise, no internals, continuity preservation). The docs suggest mult is never new — isn't that false in the closed case? Accept mult or a nurbs parameter list. In nurbs_interp docs just say result can be passed to nurbs_curve(); don't say dynamic is the default; don't say end_deriv refers to [n] index, use last(deriv). In arguments give minimal smooth= descriptions. Don't say 'C0 corner'/'corner joint'. Knot markers are green not purple; control polygon looks gray; no need to mention debug_nurbs(). Disable labels with control_index=false. Turn overlay list into bullet list. Is nurbs_interp_surface return type correct (mult at [4])? flat_edges= with closed type doesn't work — docs misleading? Clarify flat_end. No blank lines in Arguments."

## v157
Manual edit by adrianVmariano. See diff between v156 and v157 archives for full details.

## v158
"It looks like nurbs_elevate_degree doesn't really accept mult and knots compatibly with how nurbs_curve works, where you can give mult alone (uniformly spaced knots with multiplicity) or give knots, where mult acts to duplicate the knots. I wonder if we need to refactor nurbs_curve to separate the argument processing code from the core so that both versions can have identical behavior. For example, knots are not required to lie in [0,1] by the core code. nurbs_elevate_degree should accept times=0 and just return the input. Should we consider changing the calling convention from type='clamped'/type='closed' to closed=true/closed=false? Since you can request 'closed' but get 'clamped' I wonder about our existing convention. Basically it's like changing the input to describe the data point set rather than to (sort of?) describe the desired NURBS type output. What are the required degrees for the different smooth options? In one place it says degree 3 or higher and in another it says >=2. So which is correct? Correct the documentation to state this consistently. For nurbs_interp(), debug_nurbs_interp() and nurbs_interp_surface(), change the way of specifying whether we treat the point list as closed or not. Eliminate the type parameter and replace it with a closed parameter. When closed=true that is equivalent to the old type='closed' and when closed=false that corresponds to the old type='clamped'. For surfaces closed can be a single boolean or a pair of booleans. It's fine to leave 'clamped'/'closed' terminology elsewhere in the code when describing the type of nurbs being built, and nurbs_degree_elevate should continue to use the type argument---no change there. Update the docs everywhere to describe the new convention. The return from nurbs_interp() and nurbs_interp_surface() is currently a length 7 list which has the rotation as its final entry. Add an 8th entry to this return in both functions that gives the parametrization, u, for the interpolation. In cases where rotation has occurred, apply list_rotate so that u[0] corresponds to points[0]."

## v159
"I notice that the 8th return from nurbs_interp_surface says 'averaged parametrization vectors'. Does this mean those vectors don't necessarily correspond to the actual locations where the points appear? If that's the case can we get an actual full 2d array such that u[i][j] corresponds precisely to points[i][j]. nurbs_elevate_degree needs to be compatible with nurbs_curve for its input parameters. This means that it should accept knots by itself, mult by itself (uniform knots with multiplicity), or knots and mult together. Also knots need not be given in [0,1]. What is the best way to do this? Yes, check nurbs.scad first."

## v160
"nurbs_elevate_degree missed a case handled by nurbs_curve, namely neither mult nor knots provided, in which case knots are simply uniform with multiplicity 1 everywhere. Hmmm. Actually tried testing a case and it failed. In this case the elevated curve doesn't match the original: [test case with mpts and mult=[1,1,1,2,1,1,1,1]]"

## v161
"mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]]; knots = [0,1,3,5,9,13,14,19,21]; e = nurbs_elevate_degree(mpts,2,knots=knots); Above case fails with a 'singular system (should not happen)' error. If I normalize the knots by dividing by 21 then the above case works. So it seems claude was confused about knots outside of [0,1] working in its elevation code. Claude didn't give an error when length(mult) doesn't match length(knots) in the elevation code."

## v162
"nurbs_elevate_degree() fails in most cases. See Examples/elevate_fails.scad for examples."

## v163
"All of those test cases now generate the error: WARNING: len() parameter could not be converted: argument 0: expected string, found undefined (undef) ... Execution aborted"

## v164
"Fix nurbs_elevate_degree() for type='closed' so all five closed test cases in Examples/elevate_fails.scad pass (approx(c1,c2) returns true for all five). Currently they run without error but give geometrically wrong results."
