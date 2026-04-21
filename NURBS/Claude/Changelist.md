
# nurbs_interp.scad — Version Changelist

> **Ordering rule**: entries are in ascending version order (v1 at top, latest at bottom).
> New entries MUST be appended at the END of this file.  Do not prepend.

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

## v116
- Removed `_bosl2_full_closed_knots()` workaround and unused `_full_periodic_knots()`. Replaced with `_full_closed_knots()`, a thin wrapper around BOSL2's internal `_extend_knot_vector()`. Since nurbs_interp.scad will merge into nurbs.scad, calling BOSL2 internals directly is appropriate.

## v117
- `normal1=`/`normal2=` now accept collinear boundary edges (all points in the row/column lie on a line) in addition to the previous all-identical (apex) requirement.
- Added `_is_collinear_pts(pts, eps)` helper: checks collinearity by projecting each point onto the first-to-last direction and measuring perpendicular distance.
- Replaced `_apex_tangents(N, apex, ring)` with `_edge_tangents(N, edge, ring)` where `edge` is the full list of boundary points. For the apex case (all same) the result is identical; for a collinear (straight) edge each derivative is computed from its own edge point toward the adjacent ring point, projected perpendicular to the normal.
- Updated degeneracy detection, assert messages, and doc comments to use "collinear" terminology.

## v118
- Corrected v117: `normal1=`/`normal2=` now accept **coplanar** boundary edges (not merely collinear).
- Replaced `_is_collinear_pts()` with `_is_coplanar_pts(pts, eps)`: finds the first three non-collinear points, computes their plane normal via cross product, then checks all remaining points satisfy |dot(pt-p0, nhat)| < eps.  2D points and collinear point sets trivially return true.
- Updated degeneracy detection, assert messages, and doc comments to use "coplanar" terminology.
- `_edge_tangents()` unchanged (already correct for the coplanar case).

## v119
- `normal1=`/`normal2=` reworked: now accept a per-point scalar scale array (or a single scalar broadcast to all edge points).
- **Apex sub-case** (all boundary points identical): direction computed same as before — fans outward from apex, axis auto-computed from ring plane normal via new `_pts_plane_normal()` helper.  Positive scale = outward.
- **Coplanar sub-case** (boundary points coplanar, not all identical): new `_coplanar_inward_tangents()` computes the polygon edge inward normal at each point (perpendicular to edge tangent, in the edge plane, toward centroid).  Positive scale = closes inward, negative = flares outward.  Falls back to ring direction when centroid is ambiguous (collinear boundary).
- Added `_pts_plane_normal(pts)` helper: returns 3D plane normal for a set of 3D coplanar points (undef if collinear), or [0,0,1] for 2D.
- Renamed `_apex_fan_tangents()` / removed `_edge_tangents()` (v118 intermediate).
- Added apex-detection booleans (`start_u_apex`, etc.) and scale-broadcast lets (`n1_u`, `n1_v`, `n2_u`, `n2_v`).
- Added array-length assertions for non-scalar `normal1`/`normal2`.

## v120
- Restored `normal1=`/`normal2=` to v116 vector interface: must be a 3D axis vector (direction + magnitude); only valid for apex edges where all boundary points are the same point (cone tip).  Removed per-point scalar array behavior.  `_apex_tangents(N, apex, ring)` restored exactly.
- Added `flat_end1=`/`flat_end2=` parameters: scalar or per-point list for coplanar non-collinear start/end boundary edges.  Auto-detects u=0/v=0 direction (u-row takes priority).  Uses `_coplanar_inward_tangents()` with positive=inward, negative=outward.  End edges NOT negated — positive always closes inward for both start and end (fixes sign issue from v119).
- Added `periodic=false` parameter to `_coplanar_inward_tangents()`: when true (closed v/u direction), uses wrapped central differences at j=0 and j=n-1 for consistent edge tangent at the periodic join point.  Fixes the derivative discontinuity at the seam.
- Removed `_apex_fan_tangents()` and the n1_u/n1_v/n2_u/n2_v broadcast intermediates.
- Updated all assertions, doc comments, and convenience functions (`nurbs_interp_vnf()`, `debug_nurbs_interp_surface()`).

## v121
- Fixed `flat_end2=` sign: negated the result of `_coplanar_inward_tangents()` for end edges (u=1 and v=1), matching the same parametric convention as `normal2=`.  `∂S/∂u` at u=1 points outward, so the inward vector must be negated for positive scale to correctly close the surface inward.  User-facing sign convention (positive=inward) is now consistent between `flat_end1` and `flat_end2`.

## v122
- **`flat_end1`/`flat_end2` sign fix**: Both signs were backwards.  Changed `_coplanar_inward_tangents()` to orient toward the ring (adjacent interior row/column) rather than the polygon centroid — more robust for non-convex boundaries (e.g. star polygons).  Removed the end-edge negation (`[for (v = ...) -v]`) added in v121 for both u and v flat_end2 call sites; no negation is needed because positive scale always produces derivatives pointing toward the surface interior (= closing inward) at both start and end boundaries.
- **`flat_end1`/`flat_end2` type restriction**: Added assertions requiring that `flat_end1`/`flat_end2` only be used on surfaces that are clamped in one direction and closed in the other.  Surfaces that are clamped in both directions have no closed boundary for the flat_end to apply to.
- **`extra_pts` on surfaces**: Replaced the `_nullspace_solve()` implementation — the old version called `null_space(A)` which is fragile with BOSL2's current implementation.  New approach uses the KKT saddle-point system: `[R+ε·I  A^T; A  0][x; λ] = [0; b]` solved by `linear_solve` directly.  This is mathematically equivalent (minimizes `x^T·R·x` subject to `A·x = b`) and avoids SVD-based null-space computation entirely.  Surface `extra_pts` now works reliably.

## v123
- **`_coplanar_inward_tangents` orientation fix**: Replaced ring-direction orientation (v122) with polygon winding order. Computes area vector = Σ cross(edge[i], edge[(i+1)%n]); if it aligns with P_hat the polygon is CCW (viewed from P_hat) and interior is to the LEFT — `cross(P_hat, T3)` points inward. If opposed (CW), negate. This is fully robust for any non-convex polygon (star shapes, etc.) and does not require a "ring" reference for orientation.
- **`flat_end1`/`flat_end2` direction detection**: Replaced geometry-based auto-detection (which triggered the "ambiguous" error when both boundary edges were coplanar) with type-based detection: `type_u="clamped"` → flat_end applies to row boundaries (u-direction); `type_v="clamped"` → column boundaries (v-direction). This matches the `normal1`/`normal2` convention — the closed direction uniquely defines which edges are the "ends." Removed the "ambiguous" assertions; added coplanar validation only for the relevant edge.

## v124
- **`flat_end1`/`flat_end2` sign fix (test.scad)**: `type=["closed","clamped"]` was wrong for blob3 data (star rings stacked in height). The correct type is `["clamped","closed"]`: height direction is clamped (clear start/end boundaries), ring direction is closed (forms a smooth loop). With the wrong type, `flat_end1` applied to the first *column* (a non-planar spiral), causing the coplanarity assertion to fire or — in older OpenSCAD — producing garbage tangents.  With `["clamped","closed"]`, `flat_end1` correctly applies to the first row (coplanar star ring at z=0), and the sign convention is correct: positive closes inward, negative flares outward.
- **Improved coplanarity assertion messages**: `fe1_ok`/`fe2_ok` assertions now report which boundary was checked (u=0 first row, v=0 first column, etc.) and, for the v-direction case, suggest swapping the type order as a fix.
- **Stale comment fix**: Updated the `_coplanar_inward_tangents` call-site comment to say "polygon winding order" instead of "ring-direction reference" (leftover from v122).

## v125
- **Reverted `_nullspace_solve` to null-space method** (was KKT saddle-point in v124): Step A computes minimum-norm particular solution x_p via `linear_solve(A, rhs)`; Step B finds null-space basis Q2 via BOSL2 `null_space(A)`, forms H = Q2ᵀ·R·Q2 (n_ns × n_ns), solves H·z = −Q2ᵀ·R·x_p via Cholesky, returns x_p + Q2·z.  Faster and more accurate than KKT because the reduced H system is much smaller than the (M+N)×(M+N) KKT system.  Updated doc comment, "Bending-energy regularization matrix" comment, and `extra_pts=` doc string to remove "KKT" references.
- **Flipped sign of `flat_end1` derivative** at both u-direction (has_fe1_u) and v-direction (has_fe1_v) call sites: wrap `_coplanar_inward_tangents(flat_end1, ...)` result in `[for (v = ...) -v]`.  The function returns the outward direction for the start boundary; negating gives the correct inward derivative so that positive `flat_end1` closes inward.  Updated call-site comment.  `flat_end2` unchanged.
- **Fixed `extra_pts` for surface interpolation**: `_build_clamped_system` and `_build_closed_system` were calling `_collocation_matrix` / `_collocation_matrix_periodic` with a single `n` controlling both row and column count, producing n×n square matrices instead of n×M rectangular ones when extra_pts > 0.  Both extra_pts branches now build the matrix inline: clamped uses `[for (k=0..n)][for (j=0..M-1)]`, closed uses `[for (k=0..n-1)][for (j=0..M-1)]` with periodic wrapping `j + M`.  The `_build_clamped_system_with_derivs` path was already correct (already used M-1 for j).

## v126
- **`_coplanar_inward_tangents`: angle-bisector method** replaces chord-average tangent. Previously the per-point tangent T was `edge[j+1] - edge[j-1]` (length-weighted, biased by non-uniform spacing). Now each adjacent edge's unit normal is computed independently (`cross(P_hat, seg/|seg|)`, with the winding-order sign applied), and their sum is normalized: `bisect = n1 + n2; result = bisect/|bisect|`. This is the miter direction — length-independent, so non-uniform sampling has no effect. Handles degenerate edges (|seg| < 1e-12) by using the other edge's normal alone.
- **`extra_pts` M overcounting fix** at all 5 computation sites: `_build_clamped_system`, `_build_closed_system`, `_build_clamped_system_with_derivs`, `_nurbs_interp_clamped_constrained`, `_closed_constrained_solve`. Previously `M` was computed using the requested `extra_pts` value directly, but `_widest_span_params` silently caps at the available span count, so M was too large when the cap triggered. Fixed by using `len(extra_ts)` (the actual number of knots inserted) instead of `extra_pts`. In `_closed_constrained_solve`, M_pre is now derived from `len(aug_bar_raw) - 1` so it always matches the actual knot vector length. Without this fix, `select(blob3,2,-2)` with `extra_pts=2` fails because the 1-span u-direction only inserts 1 extra knot but M was computed as if 2 were inserted, producing a rank-deficient matrix.
- **`extra_pts` docstrings updated** in both `nurbs_interp()` and `nurbs_interp_surface()`: added note that requests beyond the available span count are silently clamped — no failure occurs, excess extra_pts simply has no additional effect.

## v127
- **`_widest_span_params`: evenly-spread selection for equal-width spans**. Previously, when all candidate spans had equal width (common for uniformly-parameterized closed curves like the blob3 star ring), the sort's lexicographic tiebreaker always selected the k highest-indexed spans. For a closed curve with n=18 equal spans and k=4, this placed all 4 extra knots at parameter positions ≈0.806, 0.861, 0.917, 0.972 — clustered in the last 22% of the period, right at the seam. The smooth=2 circulant regularization (which treats control-point indices as uniformly spaced) then sees a region with 8 control points packed into 22% of the parameter range. A localized fold can form at the seam because smooth=2 (second-difference) penalizes localized bumps weakly — the bump interior has near-zero second-difference even while geometrically large. smooth=1 suppresses this because a localized bump pays a large first-difference penalty at its edges. Fix: when `n_eq >= k_eff` (all k picks come from equal-width spans), replace the sort with evenly-spread stratified selection: span index `floor(g*n/k_eff)` for g=0..k_eff-1. For n=18, k=4 this gives spans 0, 4, 9, 13 at midpoints ≈0.028, 0.25, 0.528, 0.75 — evenly distributed around the parameterization. When the k widest spans are not all equal, the standard widest-first selection is preserved.

## v128
- **`_widest_span_params`: centred-stratified selection for equal-width spans** (follow-up to v127). v127 used `floor(g*n/k_eff)` which for n=18, k=4 gave spans 0, 4, 9, 13. Span 0 is adjacent to the seam of the periodic parameterization. `_extend_knot_vector` wraps span widths across the seam: span n-1 (width 1/18) wraps into the pre-region, span 0 (now width 0.028 after knot insertion) wraps into the post-region. These different widths make basis functions slightly asymmetric at the seam; the null-space solver can't fully regularize this away, leaving a visible fold. Fix: change the index to `floor((2*g+1)*n/(2*k_eff)) % n` (centroid of the g-th equal-width quantile). For n=18, k=4 this gives spans 2, 6, 11, 15 — none at the boundary. Both span 0 and span 17 keep their original width 1/18, the periodic extension is smooth, and the seam artifact is eliminated.

## v129
- **`v_edges`/`u_edges` on closed surfaces**: Previously these required `type_v="clamped"` / `type_u="clamped"` respectively and asserted otherwise. Now, when `v_edges` is given for a `type_v="closed"` surface, a preamble let block detects the case and internally cuts the surface: columns are rotated so the first crease column becomes index 0, that column is appended again at the end (n_cols+1 total), and `nurbs_interp_surface` is called recursively with `type_v="clamped"`. Remaining crease indices are remapped into the rotated coordinate system: `(original - rot + n_cols) % n_cols`, with `j==0` filtered (seam is already C0). The same transform is applied symmetrically for `u_edges` on `type_u="closed"`. The returned NURBS parameter list has `type="clamped"` in the cut direction; the surface closes geometrically because the first and last boundary rows/columns are identical data points. Updated doc comments for `u_edges=` and `v_edges=`.

## v130
- **`smooth` default changed from 2 to 3** in all public and internal functions: `nurbs_interp()`, `nurbs_interp_curve()`, `debug_nurbs_interp()`, `nurbs_interp_surface()`, `nurbs_interp_vnf()`, `debug_nurbs_interp_surface()`, and all internal helpers (`_nurbs_interp_clamped_basic/constrained/corners`, `_nurbs_interp_closed_basic/constrained/corners`, `_closed_basic_solve`, `_closed_constrained_solve`). `smooth=3` (true bending energy, ∫|C''(t)|²dt) is the geometrically correct regularization for non-uniform knot spacing; `smooth=2` (circulant second-difference) is only correct when control points are uniformly spaced, which is rarely the case with extra_pts. Updated both doc strings.

## v131
- **`extra_pts` now compatible with `u_edges`/`v_edges`**: Previously `extra_pts > 0` with `u_edges` or `v_edges` asserted and failed. The infrastructure (`_build_edge_systems`, `_solve_with_edges`) only supported square systems (exact interpolation). Now `_build_edge_systems` accepts `extra_pts=0` and passes it per-segment to `_build_interp_system` / `_build_clamped_system_with_derivs` (silently skipping for degree-reduced `seg_p < 2` segments). `_solve_with_edges` accepts `smooth=3` and detects the underdetermined case (`M > N_rows`): builds the per-segment regularization matrix R (using bending energy for `smooth=3`, with fallback to second-difference when `seg_p < 2`) and calls `_nullspace_solve`. All `_build_edge_systems` and `_solve_with_edges` call sites in `nurbs_interp_surface` updated to pass `ep_v`/`ep_u` and `smooth_v`/`smooth_u`. The two blocking asserts removed. Doc string for `extra_pts=` updated: "Compatible with u_edges/v_edges: extra knots are distributed independently within each segment."

## v132
- **Scalar-vector promotion for `u_edge1_deriv`, `u_edge2_deriv`, `v_edge1_deriv`, `v_edge2_deriv`**: Previously these required a full list of per-column or per-row vectors. Now a single vector may be passed; it is automatically expanded via `repeat()` to the required length (n_cols for u-direction, n_rows for v-direction). Detection: if the first element of the supplied value is a number (not a list), it is treated as a single vector. Added at the top of the normal-path `let()` block, after `n_rows`/`n_cols` are established, so all downstream `has_*` checks and asserts see the already-expanded list. Updated doc strings for all four parameters.

## v133
- **BOSL2 simplifications — `repeat()`, `default()`**: Replaced manual list-comprehension idioms with BOSL2 equivalents throughout.
  - `repeat(0, n)` replaces `[for (i = [0:1:n-1]) 0]` at 4 sites: zero-vector in `_apex_tangents`, `zero` in `_coplanar_inward_tangents`, `zero_v` in surface pass 1.5, and the `seg_extra` fallback in `_nurbs_interp_clamped_corners`.
  - `repeat(scales, n)` replaces `[for (i = [0:1:n-1]) scales]` in `_coplanar_inward_tangents` scalar scale expansion.
  - `repeat(zero, n)` replaces `[for (j = [0:1:n-1]) zero]` in `_coplanar_inward_tangents` collinear fallback.
  - `default(corners, [])` replaces `is_undef(corners) ? [] : corners` at 2 sites (clamped and closed paths).
  - `default(data_size, 1)` and `default(size, 3 * width)` replace `is_undef()` ternaries in `debug_nurbs_interp`.
  No behavioral changes.

## v135
- **Merged `nurbs_interp_vnf` and `debug_nurbs_interp_surface` into module `nurbs_interp_surface`**: Removed the `nurbs_interp_vnf()` convenience function and the `debug_nurbs_interp_surface()` module. In their place, a new module `nurbs_interp_surface()` renders the surface directly. OpenSCAD's separate function/module namespaces allow both to coexist under the same name. The module calls the function form, passes the result to `nurbs_vnf()`, and renders via `vnf_polyhedron()`. New parameters passed through to `nurbs_vnf()`: `splinesteps=16` (default now 16, matching nurbs_vnf), `style="default"`, `reverse=false`, `triangulate=false`, `caps=undef`, `cap1=undef`, `cap2=undef`. Retains `data_color="red"` and `data_size=0` (default changed to 0 — no data points rendered unless explicitly requested). Function doc comment updated to remove `nurbs_interp_vnf` references. Usage examples updated: `debug_nurbs_interp_surface(...)` → `nurbs_interp_surface(...)`, and `vnf = nurbs_interp_vnf(...); vnf_polyhedron(vnf)` → `nurbs_interp_surface(...)`.

## v134
- **`nurbs_elevate_degree` extended to support `type="open"` and `type="closed"`**: Previously only `"clamped"` was supported.
  - New helper `_increment_knot_mults(U)`: increments the multiplicity of every distinct value in a full knot vector by 1 (appends one extra copy at each run boundary). Used by the open elevation path.
  - New `_elevate_once_open(ctrl, p, knots)`: exact degree elevation for open B-splines. Applies `_increment_knot_mults` to the full open knot vector, then solves a Greville collocation system to find the elevated control points. Returns `[new_ctrl, U_new, p+1]` where `U_new` is the new full open knot vector.
  - New `_elevate_once_closed(ctrl, p, bar_knots)`: near-exact degree elevation for closed (periodic) B-splines in BOSL2 bar_knots format. BOSL2's `_extend_knot_vector` requires all-distinct bar_knots, so multiplicity cannot be incremented; instead the same bar_knots are kept and new control points are found via periodic Greville collocation in the degree-(p+1) space. The result is geometrically very close to the original and has the same n control points. Returns `[new_ctrl, bar_knots, p+1]`.
  - `nurbs_elevate_degree` updated: accepts `type="clamped"` (unchanged), `type="open"`, or `type="closed"`; asserts validate knot vector length for each type; lambda dispatch (`elevate_once`) selects the appropriate helper. Rational NURBS (weights) support works for all three types via the homogeneous-coordinate path. Doc string updated with format requirements and description of near-exact closed elevation.

## v136
- **BOSL2 6-element NURBS parameter list**: All public return values updated to `[type, degree, ctrl, knots, mult, weights]` (BOSL2 standard). `nurbs_interp()` now returns `[type, degree, ctrl, knots, undef, undef]` (dropped `start_idx` from pos5; `mult`=undef = uniform). `nurbs_elevate_degree()` returns `[type, new_degree, new_ctrl, new_knots, mult, new_weights]` where `mult` carries the per-knot multiplicity vector for closed type. Internal callers updated to use `elev[2]`/`elev[3]` (ctrl/knots) rather than old `elev[0]`/`elev[1]`. Doc comments for both functions updated to describe the new format.
- **Exact closed degree elevation via doubled multiplicities**: `_elevate_once_closed()` completely rewritten. Previously held bar_knots fixed and solved in degree-(p+1) space (near-exact only). Now doubles the multiplicity at every knot position — consistent with BOSL2's `_extend_knot_vector` path — giving exact representation. New `curr_mult` param tracks the current per-position multiplicity, seeded from `_curr_mult=undef` (→ 1 on first call) and threaded through recursive `nurbs_elevate_degree` calls via `_curr_mult=r[3]`. Full periodic knot vectors `U_old`/`U_new` built from `_extend_knot_vector(xknots, 0, n+2p+1)` matching BOSL2 evaluation exactly. Greville sites aligned to `U_old`'s active domain via `offset = U_old[p] − U_new[p_new]` with ±T wrapping. Periodic collocation matrix with wrap correction for `j < p_new`. Returns `[new_ctrl, bar_knots, p+1, new_mult]`. `nurbs_elevate_degree()` gained `_curr_mult=` private parameter and updated assert to skip the length check on recursive calls.
- **`debug_nurbs_interp()` rewrite**: Complete rewrite with richer visualization and explicit BOSL2 keyword passthrough (avoiding the `contorl[4]` typo in BOSL2). New parameters: `show_knots=false`, `knots=undef`. Rendering layers:
  - *Curve*: `debug_nurbs(ctrl, degree, ..., show_control=false, show_knots=false)` with explicit keyword args; wrapped in `color(color)` when color is set.
  - *Control polygon*: `stroke(ctrl, ...)` in `"lightblue"` (half curve width); `"blue"` circle/sphere markers at each control point; shown when `show_ctrl=true`.
  - *Knot markers*: `"purple"` dots evaluated on the curve at each distinct interior knot parameter; shown when `show_knots=true`. Clamped: filters `unique(knots)` to interior range. Closed: all `bar_knots[0..n-1]`.
  - *Derivative arrows*: black `stroke()` with `"arrow2"` endcap at half curve width; drawn at every point carrying a `deriv`, `start_deriv`, or `end_deriv` constraint. Arrow length = `path_length(curve) / np * 0.4`.
  - *Curvature osculating circles/disks*: `color([0,1,0,0.1])`. 2-D: `circle(r=1/κ)` centred at `pt + κ_vec/κ²`. 3-D: thin `cylinder(h=width/2, r=1/κ)` oriented via `rot(v=cross(T̂, N̂))`. Zero-curvature constraint (κ=0): black line segment through the data point along the nearest-sample tangent direction.
  - *Data points*: `data_color` (default `"magenta"`) circle/sphere markers.

## v137
- **`_merge_deriv_list()` / `_merge_curv_list()` helpers**: Two new private functions centralise the start_deriv=/end_deriv= and start_curvature=/end_curvature= merging that was previously duplicated inline. `_merge_deriv_list(n, deriv, start_deriv, end_deriv)` returns undef (no constraint) or a per-point list of length n+1 with NaN corner-marker entries left intact. `_merge_curv_list(n, curvature, start_curvature, end_curvature)` does the same for curvature. Both leave entries in their original form; callers apply `_force_deriv_dim()` separately where needed. `_nurbs_interp_clamped()` updated to use these helpers, replacing four `has_*` booleans and the two inline comprehensions with single helper calls.
- **`debug_nurbs_interp()` rewrite**: Removed `color=`, `data_color=` (data points always magenta), `show_ctrl=`. Added `show_control=false` (passed directly to `debug_nurbs`), `show_deriv=true`, `show_curvature=true`. Curve / control polygon / knot rendering now fully delegated to `debug_nurbs()` with `show_control=show_control`, `show_knots=show_knots`, `show_index=show_control` — no duplicate rendering. Note: `debug_nurbs` uses a white control polygon and blue text index labels (BOSL2 fixed styling). Overlays added on top:
  - *Derivative arrows*: `_merge_deriv_list` + `_force_deriv_dim` applied so BOSL2 3D direction constants (UP, LEFT, etc.) project correctly to 2D; `endcap1="butt"` + `endcap2="arrow2"` (correct BOSL2 syntax); arrow vector = `eff_der[i] / np` — preserves relative magnitudes, scale independent of curve length.
  - *Curvature*: `_merge_curv_list` used; handles signed scalar κ (2D) via 90°-rotated tangent or curvature vector via `_force_deriv_dim` + unit-normalise. Zero curvature: short green `color([0,1,0,0.1])` segment of full curve `width` along exact derivative direction (half arrow scale). Non-zero curvature: `color([0,1,0,0.1])` osculating circle (2D) or disk (`rot(v=cross(T̂,N̂))` cylinder, `h=width/2`) (3D). Center at `pt + N_hat/kn`.
  - *Data points*: fixed magenta.

## v138
- **`_merge_deriv_list` / `_merge_curv_list` gained `dim=` parameter**: Both helpers now accept an optional `dim` parameter. When provided, `_merge_deriv_list` applies `_force_deriv_dim(v, dim)` to every non-undef, non-NaN entry — handling BOSL2 3D direction constants (UP, LEFT, etc.) and short-vector zero-padding centrally. `_merge_curv_list` applies the same projection to every non-scalar entry (signed-scalar 2D curvature passes through unchanged, preserving the sign-of-turn encoding). `_nurbs_interp_clamped` updated to compute `dim = len(points[0])` and pass it to both helpers; the (now-redundant but harmless) `_force_deriv_dim` calls inside the constrained solver remain as no-ops.
- **Eliminated `_nurbs_interp_closed_constrained`**: The function was a thin passthrough to `_closed_constrained_solve` with one assert. Inlined the assert (`_chk = assert(...)` in a `let` block) at the call site in `_nurbs_interp_closed`. Function deleted.
- **`debug_nurbs_interp` — arrow scale**: Introduced `arrow_scale = path_length(points) / np`. Arrow tip now at `points[i] + eff_der[i] * arrow_scale`; length is proportional to the derivative magnitude and scales with average point spacing rather than curve length. Removed the previous `/ np` normalization that discarded magnitude.
- **`debug_nurbs_interp` — zero-curvature segment**: Fixed length `0.6 * arrow_scale` (half-lengths of `0.3 * arrow_scale` each side), `width = 2 * width`, `endcaps = "butt"`, `color([0,1,0,0.1])` (matches non-zero curvature). Previously scaled with the derivative magnitude and used the estimated tangent from the point list; now uses exact `eff_der[i]` direction and is length-independent.
- **`debug_nurbs_interp` — curvature code simplified**: `der_d` variable and its chain of impossible-case guards removed; replaced with direct use of `eff_der[i]` (always defined at this point, enforced by the curvature-requires-derivative assert in the solver). `_force_deriv_dim` call removed from the curvature loop (helper already projected `eff_der` and `eff_curv`). `_merge_deriv_list` and `_merge_curv_list` now called with `dim=dim`.

## v139
- **Closed-path derivative/curvature projection centralised**: `_nurbs_interp_closed` now computes `dim = len(points[0])` and calls `_merge_deriv_list(n-1, deriv, dim=dim)` and `_merge_curv_list(n-1, curvature, dim=dim)` before any dispatch. All validation checks and both call sites (`_nurbs_interp_closed_corners`, `_closed_constrained_solve`) now receive `eff_der`/`eff_curv` with BOSL2 direction constants already projected and vectors already zero-padded to `dim`. NaN corner detection still uses the raw `deriv` list (before projection), which is correct since `_merge_deriv_list` passes NaN entries through unchanged.
- **`_force_deriv_dim` removed from both constrained solvers**: Now that callers guarantee projected inputs, the `_force_deriv_dim` wrapping in `_nurbs_interp_clamped_constrained` (der_specs and t_from_der inside curv_specs) and `_closed_constrained_solve` (der_specs and t_from_der inside curv_specs) has been removed. In the closed solver, the three-branch `tang_dir` fallback also collapses: a curvature constraint requires a co-located derivative (validated upstream), so `tang_dir = der_r[k]` directly and `v2 = path_len2 * (tang_dir * tang_dir)` always.

## v140
- **`debug_nurbs_interp` — corner marks**: NaN entries in `eff_der` (C0 corners from the NaN syntax) now rendered as black marks at the data point. 2D: `zrot(45) stroke(rect(3.5*width*ds), width=width/2, closed=true)` (diamond outline). 3D: `vnf_wireframe(octahedron(size=5*width), width=width/4)`.
- **`debug_nurbs_interp` — 3D curvature cylinder corrected**: Previously `N_hat = cv/kn` used the raw curvature vector which may have a tangential component, placing the cylinder off the osculating plane. Now `cv_perp = cv - (cv·T̂)·T̂` strips the tangential component before normalising: `N_hat = unit(cv_perp)`. This guarantees T̂ ⊥ N̂ and places the cylinder in the exact osculating plane. Cylinder height changed from `width/2` to `width`.
- **`debug_nurbs_interp` — data point color**: Changed from `"magenta"` to `"red"`.

## v141
- **`debug_nurbs_interp` — corner marks now cover all declared corners**: Previously only NaN-derivative entries were marked. Now both NaN-deriv indices and explicit `corners=` indices are collected and merged (`deduplicate(sort(concat(...)))`) into `all_corner_idxs`; marks are drawn for every element.

## v142
- **`debug_nurbs_interp` — curvature overlay cleanup**:
  - `color([0,1,0,0.1])` moved to wrap the entire `for` loop; removed two duplicate `color()` calls inside.
  - 3D cylinder: replaced `translate(ctr) rot(v=binom) cylinder(...)` with `cyl(h=width, r=r, orient=binom, anchor=CENTER)` placed at `ctr` — `cyl(orient=)` aligns the axis directly without an extra `rot()`.
  - Vector N_hat: `cv - (cv * T_hat) * T_hat` replaced with `unit(vector_perp(T_hat, cv))` (BOSL2 `vectors.scad`).
  - Scalar N_hat (2D): `(cv >= 0) ? [-T_hat[1], T_hat[0]] : [T_hat[1], -T_hat[0]]` simplified to `sign(cv) * [-T_hat[1], T_hat[0]]`.
- **`debug_nurbs_interp` — data points**: `for (pt = points) translate(pt)` replaced with `move_copies(points)`.

## v143
- **`debug_nurbs_interp` — curvature cylinder placement fixed**: `cyl()` was missing its `translate`; the cylinder was always rendered at the origin. Fixed by hoisting `move(ctr)` above the `if (is2d)` branch so it applies to both the 2D circle and 3D cylinder. Removed redundant `anchor=CENTER` (it is the default for `cyl`).
- **`debug_nurbs_interp` — `control_index=false` parameter**: New parameter passed through to `debug_nurbs(show_index=control_index)`. Previously `show_index` was tied to `show_control`; now independently controllable. Default false.

## v144
- **`debug_nurbs_interp` — `data_index=true` parameter**: When `data_size > 0` and `data_index=true`, renders the index of each data point as red text at the point location. 2D: `text(text=str(i), size=sz, anchor=CENTER)`. 3D: `rot($vpr) text3d(text=str(i), size=sz, anchor=CENTER)` (billboard style, same as `debug_nurbs`). Text size uses the `size` parameter (defaults to `3*width`). Labels suppressed when `data_size=0`.

## v145
- **`_curv_to_d2` — assert on curvature parallel to tangent**: Previously, when the curvature vector had no component perpendicular to the tangent (e.g. `curvature=BACK` with `deriv=BACK`), `cv_perp` was a zero vector and `cv_dir` silently became zero, producing a degenerate constraint and a cryptic downstream error. Now asserts with a clear message: "curvature constraint is parallel to the derivative at the same point". The silent `n_perp > 1e-12 ? ... : cv_perp` fallback is removed; `cv_perp / n_perp` is computed directly after the assert.
- **`debug_nurbs_interp` — data points and labels consolidated**: The two separate `color("red")` blocks (dots + labels) merged into one `move_copies(points)` block. `$idx` used for the label index, eliminating the explicit `for` loop. Label positioning fixed: 2D uses `fwd(2*ds) text(..., anchor=BACK)` to place the label above the dot; 3D uses `up(ds + sz/3) rot($vpr) text3d(...)` to lift the label clear of the sphere before billboarding.

## v146
- **`debug_nurbs_interp` — 3D data label offset corrected**: `up(ds+sz/3) rot($vpr)` → `rot($vpr) back(ds+sz/3)`. The offset must come after the viewport rotation so it moves in screen space (away from the viewer), not in world space.

## v147
- **`debug_nurbs_interp` — curvature overlays rendered last**: Swapped the order of the data-points block and the curvature-overlays block so that the transparent `color([0,1,0,0.1])` circles/cylinders are drawn after the opaque red dots. This prevents the transparent geometry from occluding the data point markers in the OpenSCAD renderer.

## v148
- **`nurbs_interp()` doc rewrite**: Complete overhaul for user readability.
  - `method=`: Full description of all five parameterization methods with their advantages/trade-offs; references cited in Description, not in Arguments.
  - `extra_pts=`/`smooth=`: New prose sections explaining what extra control points do, how the smoothness criterion is chosen, and what each `smooth` value minimises — including plain-English explanation of bending energy vs control-polygon differences. "Regularization" removed; replaced with "smoothness criterion" / "bending energy".
  - Return value: Folded into Description (no separate Returns: block).
  - Closed-curve return note: clarified that `type` becomes `"clamped"` when corners are present.
  - All parameter names in code font (`param`); math in `$...$` (MathJax).
  - Arguments section: concise one-line entries without embedded references or internal implementation details.
- **`_widest_span_params` — `extra_pts` cap echo**: When `k > n` (more extra points requested than available knot spans), emits `echo("nurbs_interp: extra_pts=K exceeds the number of available knot spans (N); reduced to N.")`. Previously silent.

## v149
- **`debug_nurbs_interp()` doc rewrite**: Complete overhaul for user readability. Heading changed to `Module:`. Synopsis says "Calls {{nurbs_interp()}} and displays the curve with informative overlays". Description uses `{{nurbs_interp()}}` links; overlay list in user-facing order: data points, derivative constraints, curvature constraints, corners, knot markers, control points. All parameter names in code font. Active voice throughout.
- **`nurbs_interp_surface()` / module doc combined**: Heading changed to `Function&Module:`. Single combined doc block replaces separate function and module docs. Return value described up front (6-element list, each element defined). Topology section describes all four type combinations (sheet, ring/tube, torus, degenerate blob/cone). Sharp-crease (`u_edges=`/`v_edges=`) section before flat-derivative section before advanced boundary-derivative section. `flat_edges=` correctly documented as per-direction (only requires `type="clamped"` in the affected direction — not restricted to both directions clamped). Boundary partial-derivative constraints (`*_deriv=`) labeled as "Advanced" with caveat about between-point wandering. `normal1=`/`normal2=` names used throughout (no `*_normal=` abbreviation). Parameter list uses blank lines between entries for markdown compatibility. "To render" prose removed; replaced with inline VNF instructions. Module-only parameters grouped at end of Arguments list.

## v150
- **`nurbs_interp()` return — 7th element restored**: `[type, degree, ctrl, knots, undef, undef, rotation]` — the cyclic rotation index applied to the input points before solving. Always `0` for clamped; for closed (and closed+corners converted to clamped) it is the index of the input point that became the first control point.
- **`nurbs_interp_surface()` return — 7th element added**: `[type, degree, ctrl_grid, knots, undef, undef, [u_rot, v_rot]]` — each entry is the index moved to the seam when a closed direction was converted to clamped via `u_edges=`/`v_edges=`, or `undef` if no rotation occurred. The preamble recursion (closed+edges) now wraps the inner result and propagates both rotations.
- **`_build_edge_systems()` — distributed `extra_pts` and single echo**: Added `label=""` parameter. Pre-computes available interior knot spans per segment, distributes `extra_pts` proportionally (ceiling, capped per segment). Emits one echo per direction (via `label`) when the total request is reduced — replacing the previous repeated per-segment echoes. The echo message now names the direction (u or v) and states the total maximum.
- **`_build_edge_systems()` surface calls** — `label="u"` / `label="v"` passed at both call sites so direction is named in echo messages.
- **`nurbs_interp()` doc** — added 1-2 sentence plain-language explanation of curvature before the detailed spec; added `extra_pts+corners` description (proportional distribution, degree-reduced ineligibility); updated return description to mention 7th element.
- **`nurbs_interp_surface()` doc** — reorganized Description: sharp creases → flat edges → degenerate-edge normals (new section) → extra_pts (new section) → advanced derivatives. Fixed sharp-creases section to say `u_edges`/`v_edges` work with both `"clamped"` and `"closed"`. Improved advanced-derivative vector-scale explanation (single vector vs list, unit vector convention). Updated both ret_body and Returns: to list all 7 elements including `result[6]`. Updated `u_edges=`/`v_edges=` Arguments entries to remove incorrect `"clamped"` requirement.

## v151
- **`debug_nurbs_interp()` — pass `result` directly to `debug_nurbs()`**: Now that the two BOSL2 bugs are fixed (`contorl` typo and missing `show_control=` forwarding in the param-list dispatch path), `debug_nurbs(result, ...)` is used when no `knots=` override is supplied. The explicit unpacked call (`debug_nurbs(ctrl, result[1], ...)`) is retained only for the `knots=` override case, where a plain param-list pass-through cannot substitute the user-supplied knot vector.

## v152
- **`debug_nurbs_interp()` — `knots=` parameter removed**: With `debug_nurbs()` now accepting a NURBS param list directly, the knot-override path is unnecessary. Removed `knots=undef` from module signature, Usage line, and Arguments section. Removed `knots_eff` local variable. The `debug_nurbs()` call is now unconditionally `debug_nurbs(result, ...)`.
- **`nurbs_interp()` doc — `method=` default corrected**: Doc said `Default: "dynamic"` but code has `method="centripetal"`. Fixed to `"centripetal"`.
- **`debug_nurbs_interp()` doc — `smooth=` default corrected**: Doc said `Default: 3` but code has `smooth=2`. Fixed to `2`.
- **`nurbs_interp()` doc — `extra_pts+corners` eligibility clarified**: Previous text incorrectly said degree-reduced segments are not eligible. Corrected: a segment is eligible when its effective degree is >= 3 (or == 2 with `smooth=1`). A degree-reduced segment (e.g. degree 7 in a degree-8 curve) is still eligible as long as its reduced degree is >= 3. Linear and quadratic (with smooth>=2) segments are not eligible. Added rounding note: distribution uses ceiling so the total may slightly exceed the requested amount but will never be less.

## v153
- **`nurbs_interp()` doc — knot-vector construction added**: Brief description of the Piegl & Tiller averaging formula (§9.2.1 eq. 9.8) inserted as a new **Knot vector** section in the Description, placed before the Derivative constraints section.
- **`nurbs_interp()` doc — `extra_pts` corners distribution corrected**: Previous text said "distributed proportionally to their size"; corrected to "divided equally across eligible segments, rounding up per segment."
- **`nurbs_interp()` doc — 2D curvature vector clarified**: Added "any component parallel to the tangent is automatically removed" for the 2D vector form, matching the existing 3D wording (consistent with code: `_curv_to_d2` performs the same perpendicular projection in both cases).
- **`nurbs_interp_surface()` base return — `[undef,undef]` → `[0,0]`**: 7th element now always `[0,0]` when no rotation occurs, matching the curve convention (which already returns `0`).
- **`debug_nurbs_interp()` — `smooth=` default changed `2` → `3`**: Aligns with the `nurbs_interp()` default and gives better-quality curves when `extra_pts` is used. Doc updated to match.

## v154
- **`_widest_span_params()` — centred stratification bug fixed**: The formula previously stratified over all `n` spans (including constraint-narrowed spans), which could place an `extra_pts` knot inside the already-split seam region (e.g. two knots between points 6 and 0 when a constraint at point 0 narrowed that span). Fix: build `eq_idxs` (indices of spans at max width) and stratify over `eq_idxs` using `eq_idxs[floor((2g+1)*n_eq/(2*k_eff))]` instead of `floor(...*n/...)) % n`. Narrow constraint-adjacent spans are never selected; extra knots are evenly distributed among the untouched full-width spans.
- **`debug_nurbs_interp()` — `data_size=` default changed from `1` to `width`**: Data-point marker radius now scales with the curve stroke width, keeping the visual proportions consistent when `width` is set to something other than 1.

## v155
- **`_nurbs_interp_clamped_corners()` — `extra_pts` distribution changed to proportional-by-control-point-count**: Previously each eligible segment received an equal share (`ceil(extra_pts / n_eligible)`). Now weight = `seg_sizes[s] + 1` (the number of data/control points in the segment); each eligible segment receives `ceil(extra_pts * weight_s / total_weight)`. Larger segments absorb more extra knots; ineligible segments still receive zero. Doc in `nurbs_interp()` description updated to match.

## v156
- **`nurbs_elevate_degree()` — doc rewritten**: Removed per-type algorithm internals. Focus is now on what users care about: geometrically identical result, continuity preservation (elevated curve is NOT smoother than original), and passing the result to `nurbs_curve()`. Corrected `Returns:` — for `"closed"`, `mult` is a non-undef vector of repeated integers (doubles each elevation), not `undef`.
- **`nurbs_elevate_degree()` — accepts NURBS param list as first argument**: If `control[0]` is a string (a type name), the function dispatches to itself with `control[2]`, `control[1]`, `control[3]`, `type=control[0]`, `weights=control[5]`. Allows `nurbs_elevate_degree(nurbs_interp(...), times=2)`.
- **`nurbs_interp()` doc fixes**: Removed `nurbs_vnf()` from the list of functions that accept the return value (only `nurbs_curve()` and `debug_nurbs()` are named); removed `(default)` label from `"dynamic"` in method list; `end_deriv`/`end_curvature` now say `last(deriv)`/`last(curvature)` instead of `deriv[n]`/`curvature[n]`; **C0 corners** heading → **Corners**; `corners=` arg: "C0 corner joints" → "corners"; `smooth=` argument description now gives one-line summaries of each value.
- **`debug_nurbs_interp()` doc**: Description converted to bullet list; knot markers described as green (not purple), not small; control polygon described as gray (not white); removed reference to `debug_nurbs()`; "Set `control_index=false` to disable the labels" added.
- **`nurbs_interp_surface()` doc — return value**: `result[4]` now labelled as `mult` (not "no rational weights"); `result[5]` (weights) added; rotation entries described as `0` (not `undef`) when no rotation.
- **`nurbs_interp_surface()` doc — `flat_edges=`**: Clarified that it requires **both** directions to be `"clamped"` (not just the affected direction). `flat_end1=`/`flat_end2=` are now clearly presented as the alternative for mixed-type surfaces.
- **`nurbs_interp_surface()` Arguments**: Removed all blank lines between argument entries; `u_edges=`/`v_edges=` entries removed "C0"; `flat_edges=` and `flat_end1=`/`flat_end2=` descriptions revised; Returns section updated to show `mult, weights` (both `undef`) and `0` rotation.

## v157
- **Manual edit by adrianVmariano.** Changes relative to v156:
- **`nurbs_elevate_degree()` doc**: Synopsis tightened; Topics trimmed to `NURBS Curves`; continuity-preservation explanation reworded using $C^1$/$C^2$ concrete example; param-list usage described inline ("Instead of providing separate parameters…"); `Returns:` section removed (superseded by inline description); argument descriptions shortened; `mult` parameter added to the dispatch assert logic (`num_defined` check).
- **`nurbs_interp()` doc**: Synopsis reworded; `SynTags: Geom` added; Usage line reordered (`start_deriv=`/`end_deriv=` before `deriv=`); Description restructured — type section rewritten as prose (no bullet list), parameterization section leads with "In order to solve…" framing and notes scale-invariance property of `"dynamic"` and scale-dependence of `"fang"`; knot-vector section rewritten as prose without formula; derivative section expanded with practical speed advice; curvature section expanded with osculating-circle explanation and vector-form details; corners section expanded with clamped-segment assembly explanation; extra_pts section reworded; new **Starting Point for "closed" curves** section explains `last(result)` index; argument descriptions tightened throughout.
- **`nurbs_interp_curve()` removed**: Function and its doc block deleted entirely.
- **`debug_nurbs_interp()` doc**: Synopsis reworded; Description revised — corners shown via black diamond on derivative arrow (not separate marker description); curvature overlay described as cylinder in 3D; knots section simplified; control polygon section rewritten with `show_control=true`/`control_index=true` logic; `size=` described as "text size for labels"; `show_control=` and `control_index=` argument descriptions tightened.
- **`nurbs_interp_surface()` doc**: Synopsis reworded; `SynTags: Geom` added; `See Also` trimmed; Usage line condensed; Description restructured — intro mentions non-uniform B-spline nature; type/topology section rewritten as prose with torus/tube explanation; boundary-constraints section reorganised with `flat_edges=` (clamped+clamped), `normal1=`/`normal2=` (degenerate ends), `flat_end1=`/`flat_end2=` (mixed-type flat ends) each in their own paragraph; return-value element list removed from Description (now only in Returns); advanced deriv-constraint section retained; flat_edges positive/negative sign semantics added.

## v158
- **`nurbs_elevate_degree()`**: accepts `times=0`, returning the input unchanged (param-list input returns the list as-is; raw input returns `[type, degree, control, knots, undef, weights]`).
- **`nurbs_interp()`**: `type=` parameter replaced by `closed=false` (boolean). `closed=false` → clamped curve; `closed=true` → smooth closed loop. All asserts updated. 8th return element added: `u`, the parameterization vector where `u[k]` is the NURBS parameter assigned to `points[k]`. For closed curves, `u` is rotated via `list_rotate` so `u[0]` corresponds to `points[0]`.
- **`debug_nurbs_interp()`**: `type=` parameter replaced by `closed=false`. Passes `closed=closed` to `nurbs_interp()`.
- **`nurbs_interp_surface()`** (function and module): `type=` parameter replaced by `closed=false`. Scalar boolean applies to both u and v directions; 2-vector `[u_closed, v_closed]` sets each independently. 8th return element added: `[u_params, v_params]`, the averaged parameterization vectors from the solve.
- **Docs**: All doc blocks and examples updated to reflect `closed=` convention.

## v159
- **`nurbs_elevate_degree()`**: Added `mult=undef` parameter and made `knots=undef` (now optional). Accepts the same knot/mult input forms as `nurbs_curve()`:
  - `knots=` alone: interior-format vector (existing behavior); knots need not be in [0,1].
  - `mult=` alone: uniform knot positions 0..1 with those multiplicities.
  - Both `knots=` and `mult=`: distinct knot positions with per-knot multiplicities.
  - For clamped curves, endpoint repetitions are stripped internally so the elevation algorithm receives `[k0, interior..., km]` regardless of which form is used.
  - Param-list dispatch now passes `mult=control[4]` to the recursive call.
  - `times=0` return now preserves the input `mult` (was `undef`): `[type, degree, control, knots, mult, weights]`.
- **Doc**: Updated Usage and Arguments to describe the new `knots=`/`mult=` flexibility.

## v160
- **`nurbs_elevate_degree()`**: Fixed two bugs in `xknots` normalization:
  1. **Missing "neither" case**: When both `knots=` and `mult=` are omitted, now generates BOSL2-compatible uniform knots: clamped → `lerpn(0,1, n-p+1)` (interior format); open → `lerpn(0,1, n+p+2)` (full); closed → `lerpn(0,1, n+1)` (bar_knots format). The `assert(!is_undef(xknots), ...)` guard is no longer needed and was removed.
  2. **Endpoint mult not forced for `mult=`-only + clamped**: When `mult=` is given without `knots=`, endpoint multiplicities are now forced to `degree+1` before expanding (matching BOSL2's `nurbs_curve()` behavior). Previously the mult vector was used literally, producing a knot vector too short by the missing endpoint repetitions, yielding an incorrect elevation.
- **Doc**: Updated description and argument docs to describe the "neither" case and the endpoint-forcing behavior.

## v161
- **`_elevate_once_clamped()`**: Fixed hardcoded `0`/`1` endpoint values. The function now extracts `k0 = xknots[0]` and `km = last(xknots)` and uses them everywhere: building `U_old`, `new_xknots`, and `U_new`. Previously, knot vectors with endpoints outside [0,1] caused a parameter-domain mismatch between `U_old` (arbitrary range) and `U_new` (hardcoded [0,1]), producing a singular collocation matrix and the "should not happen" assert.
- **`nurbs_elevate_degree()`**: Added assert `len(mult) == len(knots)` when both are provided.

## v162
- **`_elevate_once_closed()`**: Complete rewrite to fix all closed-curve degree elevation failures.
  - **Knot construction**: Endpoint positions now appear **once** in the xknots vector fed to `_extend_knot_vector` (acting as the period boundary). Interior positions appear `curr_m[i]` times. This keeps the first extension step non-zero (`bar_knots[0]→bar_knots[1]`) so `_extend_knot_vector` produces a correctly-periodic U. Previously all positions including endpoints were repeated `curr_mult_per` times, giving delta=0 at the start and corrupting the extension.
  - **`n_new`**: Derived as `len(xknots_new) - 1` (correct for any multiplicity structure). Previous formula `2*n+1` was only right for the first elevation with uniform simple knots, and was wrong for all subsequent elevations and non-uniform mults.
  - **Multiplicity increment**: `new_m[i] = curr_m[i] + 1` (increment by 1 per elevation). Previous code doubled: `new_mult_per = 2 * curr_mult_per`, giving wrong multiplicities on the second and subsequent elevations.
  - **Greville shifting**: Greville abscissae are now shifted into the active domain `[a_new, b_new]` before evaluating the new-basis collocation matrix. Previously they were used unshifted, so sites below `a_new` produced all-zero rows in A → singular system. Only the old-curve evaluation (C_vals) was shifted; now both A and C_vals use correctly shifted sites.
  - **Auto-deduplication**: When `curr_mult` is undef and `bar_knots` contains repeated consecutive values (as occurs when re-elevating a closed curve via its NURBS param-list, whose knots field is `xknots_new` from the prior elevation), the function deduplicates to find unique positions and counts their multiplicities automatically.
  - **Return format changed**: Now returns `[new_ctrl, xknots_new, p_new, new_m, true_bar_knots]` (5 elements). `xknots_new` is BOSL2-compatible for direct use by `nurbs_curve()`; `new_m` and `true_bar_knots` are threaded through recursive elevation calls.
- **`nurbs_elevate_degree()`**: Multiple fixes for closed and clamped+knots+mult cases.
  - **Clamped + knots+mult**: Endpoint multiplicities are now forced to `degree+1` before expanding and stripping, matching the mult-only clamped behavior. Previously the raw user-provided mult was used, so endpoint mult < degree+1 would cause the strip to remove the endpoint values entirely, producing wrong xknots.
  - **Closed + mult-only**: `xknots` is now the distinct uniform positions (K values), not the expanded form. The user's `mult` is passed separately as `closed_mult0`.
  - **Closed + knots+mult**: `xknots` is now the distinct knot positions (not expanded). The user's `mult` is passed separately as `closed_mult0`.
  - **`closed_mult0`**: New variable that determines the initial per-position multiplicity vector for `_elevate_once_closed`: user's `mult=` on the first call, `_curr_mult` (from prior step) on recursive calls, or `undef` for auto-detection.
  - **`elevate_once` lambda**: Closed type now passes `closed_mult0` as `curr_mult`.
  - **Recursion / return**: For closed type, recursive calls use `r[4]` (true_bar_knots) as the `knots` argument and `r[3]` (new_m) as `_curr_mult`. The final BOSL2 param-list uses `r[1]` (xknots_new) as the knots field and `undef` as mult, ensuring `nurbs_curve()` can evaluate it directly.
  - **Removed closed-length assert**: The old `len(xknots)==len(control)+1` assert was too restrictive for non-uniform closed mult (where the K distinct positions ≠ n+1). Removed.

## v163
- **`nurbs_elevate_degree()`**: Fixed fatal error when `mult=undef`. The assert message string was calling `len(mult)` and `len(knots)` unconditionally; in this OpenSCAD version `len(undef)` aborts execution. Guards added: `is_undef(mult) ? "undef" : len(mult)` and similarly for knots.  The ternary operator in OpenSCAD evaluates lazily, so `len()` is only called when the value is not undef.

## v164
- **`_elevate_once_closed()`**: Complete rewrite to fix geometrically incorrect degree elevation for all five closed test cases in `Examples/elevate_fails.scad`.
  - **New signature**: `(ctrl, p, U_old)` — accepts the full periodic knot vector directly instead of `(ctrl, p, bar_knots, curr_mult)`.
  - **U_new construction**: Decomposes `U_old` into PREFIX/ACTIVE/EXTENSION regions and applies `_increment_knot_mults(ACTIVE)` to double every distinct knot value's multiplicity. This preserves `a_new = a_old` and `b_new = b_old` (active domain unchanged) and correctly satisfies the B-spline degree elevation theorem. Previously, the code applied `_extend_knot_vector` to `xknots_new`, which shifted `b_new` by one step per elevation and caused active-domain mismatch.
  - **Return format simplified**: Now returns `[new_ctrl, U_new, p+1]` (3 elements). `U_new` has length `n_new + 2*(p+1) + 1`; BOSL2's `_extend_knot_vector(U_new, 0, target)` returns `U_new` unchanged, so `nurbs_curve(type="closed")` evaluates with exactly the knot vector used to compute `Q`.
  - **C_vals evaluation**: Greville abscissae of `U_new` lie within `[U_old[0], U_old[-1]]`, so the original curve is evaluated directly at each site without any domain-shifting. Removed the buggy two-step shift (`grev → [a_new,b_new] → [a_old,b_old]`) that could double-shift sites outside the valid range.
  - **Removed**: `grev_raw`, `grev`, `grev_orig` shift logic, `true_bar`, `auto_m`, `curr_m`, `new_m`, `xknots_old`, `xknots_new`, `a_old`/`b_old`/`a_new`/`b_new` variables.
- **`nurbs_elevate_degree()`**: Updated closed-type path to match new `_elevate_once_closed` interface.
  - **`closed_U_old`**: New variable that computes the full periodic `U_old` from the user's `knots`/`mult` input for each input variant (no-knots/no-mult: uniform bar_knots; knots-only: pass through to `_extend_knot_vector`; mult-only or knots+mult: expand positions by multiplicities then extend). On recursive calls, `knots=U_new` (full vector) is passed; `_extend_knot_vector` returns it unchanged.
  - **Removed**: `_curr_mult` parameter, `closed_mult0` variable, `r[3]`/`r[4]` threading for closed type.
  - **Recursion simplified**: `nurbs_elevate_degree(r[0], r[2], r[1], type=type, times=times-1)` for all types (closed passes `r[1]=U_new` as `knots`; non-closed passes `r[1]=new_xknots`).
