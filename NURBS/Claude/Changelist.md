
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
