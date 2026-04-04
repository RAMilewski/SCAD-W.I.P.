
# nurbs_interp.scad — Version Changelist
## v1
- Initial version: Clamped-only B-spline curve interpolation (Piegl & Tiller Ch. 9). Functions: `_nip()` (Cox-de Boor basis), `_interp_params()` (chord-length/centripetal parameterization), `_avg_knots()` (interior knot averaging, eq 9.8), `_full_clamped_knots()`, `_collocation_matrix()`, `nurbs_interp()` (main solver), `nurbs_interp_curve()` (convenience). Supports degree selection and centripetal parameterization.

## v2
- Added `type="closed"` and `type="open"` curve interpolation alongside existing clamped. New functions: `_interp_params_closed()`, `_avg_knots_periodic()`, `_full_periodic_knots()`, `_collocation_matrix_periodic()`, `debug_nurbs_interp()` module. `_nip()` gained out-of-range index guard. Renamed `_avg_knots` to `_avg_knots_interior`. Added BOSL2 doc comment style and section headers.

## v3
- Fixed `_avg_knots_periodic()` to return `[bar_knots, shifted_params]` pair, properly shifting bar knots to start at 0 and wrapping parameter values to match.

## v4
- Added `start_der=`/`end_der=` endpoint tangent constraint support for clamped curves (P&T Section 9.2.2). New `_nurbs_interp_clamped_deriv()` with extra interior knots and derivative equations.

## v5
- Added surface interpolation: `nurbs_interp_surface()`, `nurbs_interp_vnf()`, `debug_nurbs_interp_surface()`. New shared infrastructure: `_build_interp_system()`, `_build_clamped_system()`, `_build_closed_system()`, `_build_open_system()`. New `_surface_params_u()`/`_surface_params_v()` for averaged cross-direction parameterization (P&T Section 9.2.5).

## v6
- Added `_bosl2_full_closed_knots()` to match BOSL2's internal `_extend_knot_vector()` knot construction for closed curves (the P&T symmetric extension does not match BOSL2).

## v7
- Switched closed curve collocation to use `_bosl2_full_closed_knots()` instead of `_full_periodic_knots()`, mapping collocation parameters into the BOSL2 active domain. Applied the same fix to `_build_closed_system()`.

## v8
- Added `_dnip()` (B-spline basis derivative, P&T eq. 2.9). Added `derivs=` parameter to `nurbs_interp()` for per-point tangent constraints on clamped curves. New `_nurbs_interp_clamped_derivlist()` solver.

## v9
- Extended `derivs=` support to closed and open curve types (previously clamped only). New `_nurbs_interp_closed_derivlist()` and `_nurbs_interp_open_derivlist()` solvers.

## v10
- Version number bump only (no functional changes).

## v11
- Changed knot placement for derivative-constrained interpolation from ad-hoc midpoint insertion to expanded-parameter knot averaging (duplicate params[k], then apply P&T eq 9.8). Applied to both clamped and closed solvers.

## v12
- Added span-count validation for closed curve collocation: asserts that each active knot span contains at most one collocation parameter. Detects ill-conditioned parameterization.

## v13
- Made closed curve interpolation rotation-invariant by cycling through all n starting-point rotations until a well-conditioned parameterization is found.

## v14
- Replaced brute-force rotation search (O(n²)) with O(n) deterministic optimal-seam selection: picks the cyclic offset that places the worst chord-ratio junction at the periodic seam.

## v15
- Added control-point unrotation after closed curve solving so the output curve starts at `points[0]` regardless of internal seam rotation.

## v16
- Added duplicate-point detection in `_interp_params()`. Removed legacy `_nurbs_interp_clamped_deriv()` (endpoint-only derivative solver); `start_der=`/`end_der=` now merged into `derivs=` list.

## v17
- Removed control-point unrotation logic from closed interpolation; control points returned directly from solve.

## v18
- Added `_force_deriv_dim()` helper for derivative vector validation/coercion (enables BOSL2 3D constants like UP/DOWN for 2D curves). Derivative vectors now auto-scaled by total chord length internally. Return format changed to `[control, knots, start_point]`.

## v19
- Return format changed from `[control, knots, start_point]` to `[control, knots, start_index]`.

## v20
- Broad refactoring to use BOSL2 utility functions: `path_segment_lengths()`, `path_length()`, `select()`, `add_scalar()`, `max_index()`. Replaced `concat()` with `[each ...]` list construction.

## v21
- Removed `type="open"` support entirely. Library now only supports "clamped" and "closed" types.

## v22
- Renamed `derivs=` to `deriv=` throughout. Merged `_interp_params()` and `_interp_params_closed()` into a single function with `closed=` parameter.

## v23
- Added `_dynamic_dists()` implementing Balta et al. (2020) dynamic centripetal parameterization. Replaced `centripetal=` boolean with `param=` string parameter accepting "length", "centripetal", or "dynamic".

## v24
- Changed default parameterization from `param="length"` to `param="dynamic"`.

## v25
- Added degenerate-path handling in `_interp_params()`: all-identical points return uniform spacing instead of asserting (enables surface pole rows/columns).

## v26
- Added `_closed_rotation_valid()` and `_find_closed_rotation()` helpers that validate seam rotations by checking one-param-per-span condition, with fallback search when the chord-ratio heuristic fails.

## v27
- Added `_fang_dists()` implementing Fang & Hung (2013) osculating-circle correction parameterization. Integrated as `param="fang"`.

## v28
- Bug fix: added `param="fang"` to the assertion whitelist (missing from v27).

## v29
- Added `_foley_dists()` implementing Foley-Neilson (1987) deflection-angle parameterization. Integrated as `param="foley"`.

## v30
- Added `_d2nip()` second-derivative basis function and `_curv_to_d2()` helper. Added curvature end constraints: `curv=`, `start_curv=`, `end_curv=` parameters. Renamed `_nurbs_interp_clamped_derivlist()` to `_nurbs_interp_clamped_constrained()`.

## v31
- Extended curvature constraints to closed curves. Added assertion requiring every curvature-constrained point to also have a derivative constraint. `_curv_to_d2()` now accepts both signed scalar and vector form for 2D.

## v32
- Renamed `param=` to `method=` throughout all public and internal APIs. Made `_dynamic_dists()` scale-invariant by dividing each chord by `cmax`.

## v33
- Bug fix in `_dynamic_dists()`: changed normalization divisor from `cmax` to `cmin` so `d/cmin >= 1`, ensuring `pow(x, e)` is correctly monotone.

## v34
- Added `_build_clamped_system_with_derivs()` for surface boundary tangent constraints. Added `start_u_der=`, `end_u_der=`, `start_v_der=`, `end_v_der=` parameters to surface functions. Added Pass 1.5: projects u-boundary tangents into v-control space.

## v35
- Replaced per-point derivative lists with single-vector edge derivatives requiring collinear boundary edges. Added `_pts_collinear()` and `_proj_onto_dir()` helpers. Added boundary oscillation fix for simultaneous u/v constraints.

## v36
- Reverted v35's single-vector/collinear approach back to per-point derivative lists. Removed `_pts_collinear()` and `_proj_onto_dir()`. Restored per-row/per-column path length scaling.

## v37
- Added `_apex_tangents()` helper for fan derivatives at degenerate surface edges. Added `start_u_normal=`, `end_u_normal=`, `start_v_normal=`, `end_v_normal=` parameters for automatic perpendicular derivative fans at collapsed edges.

## v38
- Removed `method="fang"` parameterization and all associated code. Added assert validations that `*_normal=` parameters require truly degenerate edges.

## v39
- Consolidated four normal parameters into two: `start_normal=` and `end_normal=`, with auto-detection of which direction (u vs v) has the degenerate edge.

## v40
- Added `flat_edges=` parameter: coplanar-boundary outward derivatives with scalar or per-point scale, order `[start_u, end_u, start_v, end_v]`. Scalar shorthand `flat_edges=s` expands to `[s,s,s,s]`.

## v41
- Added NaN corner markers in `deriv=` for clamped curves: `_is_nan()` and `_nurbs_is_segmented()` helpers; `_nurbs_interp_clamped_corners()` splits curve into independent clamped segments at NaN-marked points. Bug fix in `flat_edges=` derivative direction.

## v42
- Corner segments with fewer than `p+1` points now use automatic degree reduction: `seg_p = min(p, m-1)`.

## v43
- Added `_combine_corner_segs()`: assembles corner segments into a single clamped B-spline with C0 multiplicity knots at junctions. Changed `debug_nurbs_interp()` default `width` from `0.1` to `1`.

## v44
- Added degree elevation: `_greville()`, `_elevate_once_clamped()` helpers and public `nurbs_elevate_degree()` function. Corner segments with degree reduction now auto-elevated to full degree p (segmented fallback removed). Updated docs to note dimension-agnostic support.

## v45
- Added `_build_edge_systems()` and `_solve_with_edges()` helpers. Added `u_edges=`/`v_edges=` parameters for sharp creases at interior row/column indices.

## v46
- Added `corners=` parameter to `nurbs_interp()` as an alternative to NaN syntax for C0 corner points.

## v47
- Added closed curve corner support: `_nurbs_interp_closed_corners()` rotates to first corner, closes loop, solves as clamped. Added `_nurbs_eff_type()` helper.

## v48
- Added validation that explicit `corners=` entries must not also carry a derivative constraint. Cleaned up assert messages.

## v49
- Reorganized return format to `[type, degree, control_points, knots, weights, start_index]` (BOSL2 parameter list). Removed `_nurbs_is_segmented()` and `_nurbs_eff_type()`. Added `show_ctrl=` parameter to `debug_nurbs_interp()`. Extended `_build_edge_systems()` and `_solve_with_edges()` with boundary derivative support.

## v50
- Changed Foley parameterization from chord-length base to centripetal base. Replaced internal `_is_nan()` with BOSL2's `is_nan()`. Added input validation assert for dimension >= 1.

## v51
- Renamed public API parameters: `start_der`/`end_der` to `start_deriv`/`end_deriv`, `curv`/`start_curv`/`end_curv` to `curvature`/`start_curvature`/`end_curvature`. Changed curvature vector magnitude behavior.

## v52
- Added rational NURBS support to `nurbs_elevate_degree()`: new `weights=` parameter with homogeneous coordinate conversion.

## v53
- Documentation-only: restored detailed argument descriptions that were condensed in v51.

## v54
- Bug fix: corrected variable name typo `eff_curvature` to `eff_curv` in 5 locations within `_nurbs_interp_clamped()`.

## v55
- Systematic syntax change: added explicit step `:1:` to all `for` loop ranges throughout the entire file.

## v56
- Bug fix in `debug_nurbs_interp()`: added `closed=true` to `stroke()` for closed curves with `show_ctrl=false`.

## v57
- Comment-only fix: added `closed=true` to `stroke()` in usage example.

## v58
- Reworked closed curve seam rotation strategy: `_find_closed_rotation()` now picks the rotation with fewest collisions instead of requiring zero collisions.

## v59
- Added `_fix_tiny_spans()` helper for repairing degenerate periodic bar knots. Applied to all four `_avg_knots_periodic()` call sites.

## v60
- Added automatic midpoint-refinement for closed curves when control-point spread exceeds threshold, doubling data density and re-solving.

## v61
- Removed midpoint-refinement from v60. Replaced with spread-based rotation search: extracted `_closed_basic_solve()` and `_closed_constrained_solve()`, try heuristic rotation first then all rotations picking smallest spread.

## v62
- Relaxed minimum segment size for derivative constraints in `_build_edge_systems()` from `seg_p + 2` to `seg_p + 1`.

## v63
- Added `method="quadratic"` (local rational quadratic interpolation, P&T Section 9.3.3): `_line_intersect()`, `_bessel_tangents()`, `_local_quadratic_interp()`, shoulder weights from cos(theta/2). Added `data_size=0` suppression in debug modules.

## v64
- Added early validation asserts for `u_edges`/`v_edges` combined with boundary derivatives. Improved error messages for singular edge-segment systems.

## v65
- Bug fix: added guards to surface edge-segment-size assert messages preventing `str()` evaluation on undef.

## v66
- Moved `u_edges`/`v_edges` boundary-derivative segment-size checks to after effective derivative flags are computed.

## v67
- Re-added undef guards to assert messages that were removed in v66.

## v68
- Bug fix in `_local_quadratic_interp`: removed incorrect rejection test for behind-the-point intersections, now only parallel tangent lines trigger midpoint fallback.

## v69
- Rewrote shoulder-point logic to implement adaptive alpha blending (P&T Eq. 9.44). Control point R is `(1-alpha)*M + alpha*S` with weight `cos(alpha*theta/2)` when tangent-line intersection falls behind a data point.

## v70
- Added `_nurbs_curve_rational()` workaround for BOSL2 bug where `nurbs_curve()` drops custom knots for rational NURBS.

## v71
- Rewrote `_bessel_tangents()` to use higher-order Newton divided differences: 5-point quartic for interior, 4-point cubic at endpoints, 3-point near endpoints.

## v72
- Replaced `_bessel_tangents()` with `_five_point_tangents()` using cross-product-based alpha blending (P&T Eqs. 9.29 + 9.31) with virtual chord boundary extension. Added `_cross_mag()` helper.

## v73
- Bug fix: restored accidentally removed `params = _interp_params(...)` line in `_local_quadratic_interp` (still needed for knot construction).

## v74
- Simplified `_local_quadratic_interp` by removing adaptive alpha blending from v69. Pure alpha=1 with direct shoulder point.

## v75
- Added `_shoulder_weight()` helper. Major rewrite of `_local_quadratic_interp` to handle corner/degenerate segments via sub-arc splitting (P&T Eqs. 9.41-9.42, rational gamma from Eq. 9.45).

## v76
- Renamed `_five_point_tangents()` to `_five_point_tangents_lr()` returning `[T_left, T_right]` pairs for C0 discontinuity at true corners.

## v77
- Adopted BOSL2 parameter list convention: results pass directly to `nurbs_curve()`, `nurbs_vnf()`, `debug_nurbs()`. Removed `_nurbs_curve_rational()` workaround (BOSL2 bug fixed upstream). Simplified all convenience functions.

## v78
- Removed `method="quadratic"` and all associated code: `_local_quadratic_interp()`, `_line_intersect()`, `_cross_mag()`, `_five_point_tangents_lr()`, `_shoulder_weight()`.

## v79
- Added `method="lockyer"` parameterization: Lockyer W=1 orthogonal construction. New `_lockyer_params()` and `_lockyer_build_params()` functions with Bessel tangent estimation and Ball's option (b) fallback.

## v80
- Rewrote Lockyer derivative magnitude computation: replaced closed-form with Newton-method solution of the W=1 quartic. Added `_lockyer_w1_root()`. Added `_lockyer_clamped_full()` for full Lockyer pipeline with section 3.1.5 derivative magnitude estimation and optimal phi/psi values.

## v81
- Replaced custom `_lockyer_w1_root()` Newton solver with BOSL2's `root_find()`.

## v82
- Added knot-proximity nudge for closed collocation parameters in `_build_closed_system()` to prevent rank loss. Surface derivative detection now treats all-undef derivative lists the same as undef.

## v83
- Removed `method="lockyer"` entirely: deleted `_lockyer_params()`, `_lockyer_build_params()`, `_lockyer_w1_root()`, and `_lockyer_clamped_full()` (~230 lines).

## v84
- Re-added `method="fang"` parameterization (Fang & Hung 2013, Eq. 10): new `_fang_correction()` and `_fang_dists()` helpers. Removed Foley's dead 1e-15 divisor guard and redundant endpoint checks.

## v85
- Changed default parameterization from `"dynamic"` to `"centripetal"`. Added `color=` parameter to `debug_nurbs_interp()`. Changed default `data_size` from 0.125 to 1.

## v86
- Changed closed constrained rotation strategy to try rot=0 first (preserves geometric symmetry), then falls back to chord-ratio heuristic, then all rotations.

## v87
- Added `_insert_constraint_knots()` helper for closed constrained solve: inserts knots near constraint parameters into unconstrained periodic knots. Reverted v86's rot=0-first strategy back to heuristic-first. Added knot-proximity nudge to closed constrained solve.

## v88
- Added knot palindrome symmetrization in closed constrained solve: after inserting constraint knots, enforces `aug_bar[j] + aug_bar[M-j] = T`.

## v89
- Changed closed constrained rotation back to rot=0 first (re-applying v86 approach) with comment explaining palindromic symmetry alignment.

## v90
- Made knot-proximity nudge direction symmetry-aware: parameters below center nudged +eps, above center -eps, preserving palindromic symmetry. Applied to both `_build_closed_system()` and closed constrained solve.

## v91
- Replaced knot-insertion approach for closed constrained solve with uniform bar_knots (`bar[j] = j*T/M`). Only uniform spacing produces palindromic full knots via `_bosl2_full_closed_knots()`, required for symmetric solutions.

## v92
- Increased knot-proximity nudge for degree 2 from `1e-6` to `0.01` in both `_build_closed_system()` and closed constrained solve. For degree 2 with near-uniform params and even n, all shifted parameters land on knots causing exact singularity; the larger nudge lifts the problematic eigenvalue to ~0.02.

## v93
- Replaced uniform bar_knots and palindromic symmetry enforcement in `_closed_constrained_solve` with data-density-aware quantile knot construction. New `_quantile_resample()` function generates M virtual parameters from N data parameters at uniform quantile positions, then standard periodic averaging produces knots adapted to data density rather than forced uniform or placed near constraint locations.
- Replaced parameter-duplication knot strategy in `_build_clamped_system_with_derivs` with quantile resampling: generates N_ctrl virtual params from data params, distributing extra DOFs by data density.
- Removed `_insert_constraint_knots()` (dead code since v91).
- Simplified knot-proximity nudge in both `_build_closed_system` and `_closed_constrained_solve`: removed sign-based direction (was for palindromic symmetry preservation); now uses uniform +eps nudge.

## v94
- Replaced quantile resampling (`_quantile_resample()`) with adaptive knot insertion (`_insert_constraint_knots()`, `_insert_one_knot()`). Extra knots are now inserted at constraint parameter values into the base averaged knot vector, placing resolution exactly where each constraint needs it. `_fix_tiny_spans()` cleans up any near-coincident knots after insertion.
- `_closed_constrained_solve`: computes base bar_knots via standard periodic averaging of N data params, then inserts one knot per derivative/curvature constraint at its parameter value.
- `_build_clamped_system_with_derivs`: computes base interior knots via standard averaging, then inserts extra knots at midpoints of first/last spans for start/end derivative constraints.

## v95
- Changed `_insert_constraint_knots()` to insert at the **midpoint of the containing span** rather than at the constraint parameter value itself. When multiple constraints are pending, the one whose span is largest is processed first. Removed `_insert_one_knot()` helper (logic folded into the main function).
- Both closed constrained and clamped-with-derivs call sites now pass constraint parameter values; the function finds the containing span and bisects it.

## v96
- (Superseded by v97 — midpoint-refinement was not the intended feature.)

## v97
- Added `extra_pts=` parameter to `nurbs_interp()`, `nurbs_interp_curve()`, and `debug_nurbs_interp()`. Adds user-specified extra control points beyond what data and constraints require. Extra knots placed at midpoints of widest spans; extra equations enforce d²C/dt²=0 (smoothness) at those locations. Requires degree >= 2.
- New helpers: `_widest_span_params()` and `_widest_span_midpoints()` return midpoints of the k widest spans in a bar_knots vector.
- `_nurbs_interp_clamped_constrained()` and `_closed_constrained_solve()` extended with `extra_pts` parameter: inserts extra knots after constraint knots, adds smoothness rows to the collocation matrix.
- When `extra_pts > 0` and no other constraints exist, the basic paths redirect to the constrained solvers (which handle the extra DOFs).
- Reverted v96's midpoint-refinement (`_refined` parameter removed).
- Fixed stale comment in `_closed_constrained_solve` that referenced quantile resampling.

## v98
- Replaced d²C/dt²=0 smoothness rows for `extra_pts` with KKT constrained optimization from note1.md. When `extra_pts > 0`, the underdetermined system (M > N_rows) is solved as: min ||L*P||² s.t. A*P = Q, yielding exact interpolation with minimum control-polygon roughness.
- Added `smooth=` parameter (default 2): 1 = first-difference penalty (minimizes control polygon length/variation), 2 = second-difference penalty (minimizes control polygon bending).
- New helper `_ltl_row(M, i, order, periodic)`: builds one row of the L^T*L regularization matrix. Supports both clamped (boundary-adapted) and periodic (circulant) variants for first- and second-difference operators.
- KKT system: [(L^T*L, A^T); (A, 0)] * [P; Λ] = [0; rhs]. Solved via `linear_solve()`; control points extracted from first M rows.
- Removed `_widest_span_midpoints()` (only used by the eliminated smoothness-row approach).
- Removed degree >= 2 requirement for `extra_pts` (KKT approach works at any degree).
- `smooth=` propagated through all public API: `nurbs_interp()`, `nurbs_interp_curve()`, `debug_nurbs_interp()`, and all internal dispatch/solver functions.

## v99
- Added `smooth=3`: integrated squared second derivative of the curve (true bending energy, ∫|C′′(t)|²dt). This minimizes actual curve curvature energy rather than control-polygon proxies. Requires degree >= 2.
- New helper `_gauss_legendre(n)`: returns Gauss-Legendre quadrature nodes and weights on [-1,1] for n = 2..5 points. Exact for polynomials up to degree 2n-1.
- New helper `_bending_energy_matrix(M, p, U_full, periodic)`: computes the M×M matrix R where R[j][k] = ∫ B′′_j(t) B′′_k(t) dt via Gauss-Legendre quadrature over each knot span. Supports both clamped and periodic (aliased) basis functions.
- Uses max(2, p-1) Gauss points per span (exact for p ≤ 6). Precomputes all second derivatives at quad points for efficiency.
- Updated `smooth=` assert to accept 1, 2, or 3. Added degree >= 2 check for smooth=3.

## v100
- KKT regularization fallback for singular systems: all four solve paths (`_nurbs_interp_clamped_basic`, `_nurbs_interp_clamped_constrained`, `_closed_basic_solve`, `_closed_constrained_solve`) now attempt a direct `linear_solve()` first, and if it returns `[]` (singular), automatically retry via the KKT system with the `smooth=` regularizer.
- This makes the solver more robust: any singular/underdetermined system is resolved by picking the minimum-energy interpolant instead of failing with an assertion.
- Propagated `smooth=` parameter to `_nurbs_interp_clamped_basic`, `_closed_basic_solve`, and `_nurbs_interp_closed_basic` so the fallback can use the user's chosen regularizer.
- The constrained solvers no longer gate on `extra_pts > 0` to decide the solve strategy; the direct solve is always attempted first and KKT is the unified fallback.

## v101
- Fixed KKT system singularity: added Tikhonov regularization (ε·I, ε=1e-10) to the R matrix in all four KKT solve paths. The periodic second-difference L^T*L is positive semidefinite (rank M-1, null space = constants), which left the KKT saddle-point system indefinite with near-zero pivots that caused BOSL2's `linear_solve()` to fail. The tiny diagonal perturbation makes R strictly positive definite, stabilizing the solve without meaningfully affecting the solution.
- New helper `_regularize(R, eps)`: adds ε to the diagonal of a square matrix.

## v102
- Replaced indefinite KKT saddle-point system with Schur complement decomposition. The KKT matrix [R, A^T; A, 0] is symmetric indefinite, which BOSL2's `linear_solve()` cannot reliably handle. The Schur complement approach decomposes the problem into two positive-definite solves that `linear_solve()` handles robustly:
  1. Solve R·Z = A^T (R is PD after ε·I regularization)
  2. Form S = A·Z (Schur complement, PD)
  3. Solve S·Λ = rhs
  4. P = Z·Λ
- New helper `_kkt_solve(R, A, rhs, eps)`: implements the Schur complement approach. All four KKT sites now call this instead of building the saddle-point matrix directly.
- Removed `_regularize()` (replaced by inline ε·I inside `_kkt_solve`).
- Increased default regularization to ε=1e-6 (1e-10 was too small to stabilize pivots).

## v103
- Replaced Schur complement decomposition in `_kkt_solve` with **penalized normal equations**: min P^T·R·P + μ·‖A·P − rhs‖², yielding the SPD system (R + μ·A^T·A)·P = μ·A^T·rhs.
- The Schur complement S = A·R⁻¹·A^T was singular when the constraint matrix A was numerically rank-deficient. The new formulation avoids forming S entirely — a single M×M SPD solve replaces the two-step Schur decomposition.
- μ=1e8 gives interpolation accuracy ~1e-6 relative to data scale (negligible for visualization).
- Removed ε·I regularization of R (no longer needed; the μ·A^T·A term ensures the system matrix is SPD).

## v104
- **Root cause found**: rank-deficient collocation matrix caused by two data points in the same knot span. Constraint knot insertion only targets constrained parameters; unconstrained data points can share a span, violating the Schoenberg-Whitney condition (at most one evaluation per span).
- New helper `_span_split_params(bar_knots, params)`: detects knot spans containing multiple data parameters and returns midpoint splitting values.
- Both `_closed_constrained_solve` and `_nurbs_interp_clamped_constrained` now call `_span_split_params` after constraint/extra knot insertion. If any span has multiple params, splitting knots are inserted, increasing M and making the system underdetermined — solved exactly via penalized normal equations.
- Changed direct-solve guard from `extra_pts == 0` to `M == N_rows` so that span-split-induced extra columns also trigger the KKT path.
- Removed diagnostic echo statements from v103.

## v105
- `_kkt_solve` now tries **Schur complement first** (exact interpolation), falls back to **penalized normal equations** only if S is singular. v103-v104's penalized-only approach traded smoothness for interpolation accuracy, causing the curve to miss data points in sharp-turn regions.
- With v104's span splitting ensuring A has full row rank, the Schur complement S = A·R⁻¹·A^T is now SPD and the exact path succeeds. The penalized fallback is retained as a safety net for edge cases.

## v106
- Added **row equilibration** to `_kkt_solve`: each row of A (and corresponding rhs) is scaled to unit norm before forming the Schur complement. This fixes the conditioning problem caused by curvature rows having norms ~3000× larger than interpolation rows (~0.7).
- Row equilibration preserves the exact solution (P_scaled = P_original by algebraic identity: D cancels in P = R⁻¹·A^T·D⁻¹·(D⁻¹·A·R⁻¹·A^T·D⁻¹)⁻¹·D⁻¹·Q = R⁻¹·A^T·(A·R⁻¹·A^T)⁻¹·Q).
- The penalized fallback also uses equilibrated A for balanced constraint weighting.

## v107
- **Root cause of missed points**: rot=0 achieved exact interpolation (Schur=OK) but had high spread ratio, triggering the rotation search. The rotation search picked rot=9 which had low spread (1.20) but used the penalized fallback (Schur=FAIL) — so the curve smoothed past data points instead of interpolating them.
- `_kkt_solve` now accepts `fallback=` parameter: when false, returns undef on Schur failure instead of falling back to penalized.
- `_closed_constrained_solve` passes `fallback=` through to `_kkt_solve`.
- `_nurbs_interp_closed_constrained` rotation search now uses `fallback=false` — only exact (Schur complement) solutions are considered. If no exact rotation exists, a second pass with `fallback=true` picks the best penalized solution.
- Removed diagnostic echo statements.

## v108
- Replaced Schur complement + penalized normal equations with null-space method via pivoted QR of A^T. New `_nullspace_solve()` guarantees exact constraint satisfaction by construction: Step A computes a particular solution in the row space of A via QR back-substitution; Step B minimizes bending energy in the null space via a small SPD system. Removed `_kkt_solve()`, all `fallback=` parameters, and all penalized normal equation code paths. Uses BOSL2's `qr_factor()`, `back_substitute()`, and `submatrix()`. Rotation search for closed constrained curves simplified (no more exact-vs-penalized two-pass logic).

## v109
- Removed rotation search from closed constrained interpolation. Null-space method guarantees exact interpolation and bending-energy minimization prevents oscillation, so trying multiple rotations is unnecessary. Always uses rot=0 to preserve reflection symmetry.

## v110
- Curvature vector constraints now accept 3D BOSL2 direction constants (UP, DOWN, LEFT, RIGHT, etc.) for 2D curves, matching the existing derivative behavior. Relaxed assert in `_curv_to_d2()` to allow len=3 when dim=2; projection handled by existing `_force_deriv_dim()`.

## v113
- Fixed `_fix_tiny_spans` out-of-bounds bug in `_build_clamped_system()` and `_build_clamped_system_with_derivs()`: v111 introduced `extra_pts` support by passing the control-point count M as the span count to `_fix_tiny_spans`, but clamped xknots have only M-p spans. Used `len(bar_knots)-1` instead. The `_with_derivs` variant was hit even with `extra_pts=0` whenever flat_edges or boundary derivatives were active in surface interpolation.

## v114
- Switched `linear_solve()` to use BOSL2's new `method=` parameter for optimal solver selection:
  - **LU** (`method="lu"`) for all square systems where failure is asserted (collocation matrices, degree elevation, surface per-row/column solves) — ~30x faster than QR.
  - **Cholesky** (`method="cholesky"`) for the SPD reduced system H in `_nullspace_solve()` — ~5x faster than LU.
  - **QR** (default) retained for: (1) underdetermined systems in `_nullspace_solve()` Step A (only QR supports m<n), (2) systems that check for `[]` return on singular and fall back (LU's `lu_factor` returns `undef` instead of `[]`).
- Symmetrized H matrix in `_nullspace_solve()` via `(H + transpose(H)) / 2` before Cholesky to counteract floating-point asymmetry from matrix multiplication.

## v115
- Reverted all `method="lu"` calls back to default QR: BOSL2 QR factorization was significantly sped up and is now competitive with LU. Removed unnecessary method selection complexity.
- Kept `method="cholesky"` only for the SPD reduced system H in `_nullspace_solve()` where Cholesky remains ~5x faster.
- All three methods (QR, LU, Cholesky) now return `[]` on singular/non-SPD in updated BOSL2, so the fallback-vs-assert distinction from v114 is no longer needed.
