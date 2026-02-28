//////////////////////////////////////////////////////////////////////
// LibFile: nurbs_interp.scad
//   NURBS Curve Interpolation through Data Points
//
//   Given a set of data points, computes the NURBS control points and
//   knot vector such that the resulting curve passes exactly through
//   every data point.  Supports all three BOSL2 NURBS types:
//     "clamped" - curve starts/ends at first/last data point
//     "closed"  - curve forms a smooth closed loop through all points
//     "open"    - open (non-clamped) B-spline interpolation
//
//   Optional per-point derivative (tangent) constraints can be applied
//   to all three curve types via the derivs= parameter.  The clamped
//   type also accepts the start_der=/end_der= shorthand arguments.
//   (Piegl & Tiller, "The NURBS Book", Section 9.2.2.)
//
//   Algorithm from Piegl & Tiller, "The NURBS Book", Chapters 2 & 9.
//
//   Requires BOSL2.  To use, add these lines to the top of your file:
//     include <BOSL2/std.scad>
//     include <BOSL2/nurbs.scad>
//     include <nurbs_interp.scad>
//
// Author: Claude (Anthropic), 2026
// License: BSD-2-Clause (same as BOSL2)
//////////////////////////////////////////////////////////////////////


// =====================================================================
// SECTION: Internal B-spline Basis Functions
// =====================================================================

// Cox-de Boor recursive B-spline basis function N_{i,p}(u).
// Returns 0 for out-of-range indices (safe for periodic evaluation).

function _nip(i, p, u, U) =
    let(maxidx = len(U) - 1)
    (i < 0 || i + p + 1 > maxidx) ? 0
    : p == 0
      ? (u >= U[i] && u < U[i+1]) ? 1
        : (abs(u - U[i+1]) < 1e-12 && abs(U[i+1] - U[maxidx]) < 1e-12) ? 1
        : 0
      : let(
            d1 = U[i+p] - U[i],
            d2 = U[i+p+1] - U[i+1],
            c1 = abs(d1) > 1e-15
                 ? (u - U[i]) / d1 * _nip(i, p-1, u, U) : 0,
            c2 = abs(d2) > 1e-15
                 ? (U[i+p+1] - u) / d2 * _nip(i+1, p-1, u, U) : 0
        )
        c1 + c2;


// Derivative of B-spline basis N_{j,p}'(u).
// Standard recurrence (P&T §2.3 eq. 2.9); zero-length spans are guarded.

function _dnip(j, p, u, U) =
    p == 0 ? 0
    : let(
          d1 = U[j+p]   - U[j],
          d2 = U[j+p+1] - U[j+1]
      )
      (abs(d1) > 1e-15 ? p * _nip(j,   p-1, u, U) / d1 : 0)
    - (abs(d2) > 1e-15 ? p * _nip(j+1, p-1, u, U) / d2 : 0);


// =====================================================================
// SECTION: Input Helpers
// =====================================================================

// Validate and coerce a single derivative vector to the required dimension.
//
// dim == 2 (special case):
//   Accepts a 3D BOSL2 direction constant (UP, DOWN, LEFT, RIGHT, BACK, FWD)
//   by projecting it onto the data plane.  The vector must lie in the XZ plane
//   (Y=0, as UP/DOWN/LEFT/RIGHT/FWD/BACK are defined) or the XY plane (Z=0).
//   Underlength inputs (1D) are zero-padded to 2D as in the general case.
//
// All dimensions (dim ≥ 2):
//   Any vector shorter than dim is zero-padded to length dim.
//   Vectors longer than dim (not handled by the dim=2 special case) error.

function _force_deriv_dim(deriv, dim) =
    dim == 2 && is_vector(deriv, 3) ?
        // Special: 3D BOSL2 constant for 2D curve — project onto data plane.
        assert(deriv.y == 0 || deriv.z == 0,
               "\nDerivative for a 2D interpolation cannot be fully 3D.  It must have either Y or Z component equal to zero.")
        deriv.y == 0 ? [deriv.x, deriv.z] : point2d(deriv)
    : // General: validate length ≤ dim, then zero-pad to exactly dim.
      assert(is_vector(deriv) && len(deriv) >= 1 && len(deriv) <= dim,
             str("\nDerivative must be a non-empty vector of dimension ", dim, " or less."))
      list_pad(deriv, dim, 0);


// =====================================================================
// SECTION: Parameterization
// =====================================================================

// Chord-length (or centripetal) parameterization for clamped/open curves.
// n+1 points -> n+1 values in [0, 1] with t_0=0, t_n=1.

function _interp_params(points, centripetal=false) =
    let(
        raw = path_segment_lengths(points),
        n   = len(raw)
    )
    assert(min(raw) > 1e-10,
           "nurbs_interp: consecutive duplicate data points detected")
    let(
        dists = centripetal ? [for (d = raw) sqrt(d)] : raw,
        total = sum(dists)
    )
    total < 1e-15
      ? [for (i = [0:n]) i / n]
      : let(cs = cumsum(dists))
        [0, each [for (i = [0:n-2]) cs[i] / total], 1];


// Parameterization for closed curves.
// n data points -> n values in [0, 1).  Includes closing segment.

function _interp_params_closed(points, centripetal=false) =
    let(
        raw = path_segment_lengths(points, closed=true),
        n   = len(raw)
    )
    assert(min(raw) > 1e-10,
           "nurbs_interp: consecutive duplicate data points detected")
    let(
        dists = centripetal ? [for (d = raw) sqrt(d)] : raw,
        total = sum(dists)
    )
    total < 1e-15
      ? [for (i = [0:n-1]) i / n]
      : let(cs = cumsum(dists))
        [0, each [for (i = [0:n-2]) cs[i] / total]];


// =====================================================================
// SECTION: Knot Vector Construction
// =====================================================================

// Interior knots by averaging (Piegl & Tiller eq 9.8).

function _avg_knots_interior(params, p) =
    let(
        n = len(params) - 1,
        num_internal = n - p
    )
    num_internal <= 0
      ? []
      : [for (j = [1:num_internal])
             sum([for (i = [j : j + p - 1]) params[i]]) / p
        ];


// Full clamped knot vector: (p+1) zeros, interior, (p+1) ones.

function _full_clamped_knots(interior_knots, p) =
    [each repeat(0, p+1), each interior_knots, each repeat(1, p+1)];


// Periodic "bar knots" for closed B-splines.
//
// Returns [bar_knots, shifted_params] where bar_knots is n+1
// monotonically increasing values with bar[0]=0, bar[n]=1, and
// shifted_params are the parameter values shifted to match.
//
// The raw bar knots are computed by averaging p consecutive values
// from the extended periodic parameter sequence t_m = params[m%n] +
// floor(m/n).  This is guaranteed monotonic.  We then shift so
// bar[0]=0, and shift params by the same amount.

function _avg_knots_periodic(params, p) =
    let(
        n = len(params),
        raw = [for (j = [0:n])
                   sum([for (k = [0:p-1])
                            let(m = j + k)
                            params[m % n] + floor(m / n)
                       ]) / p
              ],
        shift     = raw[0],
        bar_knots = add_scalar(raw, -shift),
        shifted   = [for (t = params)
                         let(s = t - shift)
                         s < 0 ? s + 1 : (s >= 1 ? s - 1 : s)]
    )
    [bar_knots, shifted];


// Full periodic knot vector for basis evaluation.
// n+2p+1 entries: p wrapped from end, n+1 bar knots, p wrapped from start.
// NOTE: This is the Piegl & Tiller symmetric extension.  It does NOT match
// what BOSL2's nurbs_curve() constructs internally.  Use
// _bosl2_full_closed_knots() when building collocation matrices for BOSL2.

function _full_periodic_knots(bar_knots, n, p) =
    let(T = bar_knots[n] - bar_knots[0])
    [for (i = [n-p : n-1]) bar_knots[i] - T,
     each bar_knots,
     for (i = [1 : p]) bar_knots[i] + T];


// BOSL2-compatible full periodic knot vector for "closed" type evaluation.
// n+2p+1 entries matching the vector that nurbs_curve() constructs internally
// via _extend_knot_vector(bar_knots, 0, n+2p+1).
//
// Formula: U[j] = floor(j/n)*T + bar_knots[j%n]
// where T = bar_knots[n] (always 1 for the averaging parameterization).
//
// Active evaluation domain: [U[p], U[n+p]] = [bar_knots[p], bar_knots[p]+T].

function _bosl2_full_closed_knots(bar_knots, n, p) =
    let(T = bar_knots[n])
    [for (j = [0 : n + 2*p])
        floor(j / n) * T + bar_knots[j % n]
    ];


// =====================================================================
// SECTION: Collocation Matrices
// =====================================================================

// Standard collocation matrix for clamped and open types.

function _collocation_matrix(params, n, p, U) =
    [for (k = [0:n])
        [for (j = [0:n])
            _nip(j, p, params[k], U)
        ]
    ];


// Periodic collocation matrix for closed type (n x n).
//
// BOSL2 wraps the first p control points to the end, creating n+p
// basis functions.  Basis N_{j+n} aliases control point j for j<p.
// So the effective basis for control point j is:
//   B_j(t) = N_j(t) + N_{j+n}(t)   if j < p
//   B_j(t) = N_j(t)                  if j >= p

function _collocation_matrix_periodic(params, n, p, U_periodic) =
    [for (k = [0:n-1])
        [for (j = [0:n-1])
            _nip(j, p, params[k], U_periodic)
          + (j < p ? _nip(j + n, p, params[k], U_periodic) : 0)
        ]
    ];


// =====================================================================
// SECTION: Main Interpolation Function
// =====================================================================

// Function: nurbs_interp()
// Synopsis: Finds NURBS control points that interpolate through given data points.
// Topics: NURBS Curves, Interpolation
// See Also: nurbs_curve(), debug_nurbs(), nurbs_interp_curve()
//
// Usage:
//   result = nurbs_interp(points, degree, [centripetal=], [type=],
//                         [derivs=], [start_der=], [end_der=]);
//
// Description:
//   Given a list of data points (2D or 3D) and a NURBS degree, computes
//   the control points and knot vector for a NURBS curve that passes
//   exactly through every data point.  Returns [control_points, knots]
//   for use with nurbs_curve().
//   .
//   Three curve types are supported:
//   .
//   "clamped" (default): Curve starts at the first point and ends at
//   the last point.  Optionally constrain tangent directions at any data
//   point with derivs=.
//   .
//   "closed": Smooth closed loop through all points.  Do NOT repeat the
//   first point at the end.
//   .
//   "open": Open (non-clamped) B-spline through all points.  Unlike
//   clamped, the curve does not grip the first/last points tightly,
//   giving a softer end-to-end behavior similar to a natural spline.
//   Useful when endpoints should blend smoothly without a sharp anchor.
//   .
//   Derivative constraints (derivs=):
//   .
//   derivs[k] specifies the desired tangent direction (and relative speed)
//   at the k-th data point.  Each derivative vector is automatically scaled
//   by the total chord length of the data, so a unit vector produces motion
//   at natural arc-length speed and a vector of magnitude 2 produces twice
//   that speed.  BOSL2 named constants (UP, DOWN, LEFT, RIGHT, BACK, FWD)
//   are accepted for 2D curves; the 3D vector is projected onto the data
//   plane (XZ if Y=0, XY otherwise).
//   start_der= and end_der= are shorthand equivalents for specifying
//   derivs[0] and derivs[n] respectively.
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate
//   degree      = degree of the NURBS curve (commonly 3)
//   ---
//   centripetal = if true, use centripetal parameterization.  Default: false
//   type        = "clamped", "closed", or "open".  Default: "clamped"
//   derivs      = list of tangent vectors, one per data point; undef entries
//                 are unconstrained.  All three curve types supported.
//                 Cannot be combined with start_der=/end_der=.  Vectors are
//                 scaled by total chord length internally; pass unit vectors
//                 for natural speed.  BOSL2 direction constants (UP, DOWN,
//                 LEFT, RIGHT, BACK, FWD) accepted for 2D curves.
//                 Default: undef
//   start_der   = tangent at start point; shorthand for derivs[0].
//                 Clamped only.  Default: undef
//   end_der     = tangent at end point; shorthand for derivs[n].
//                 Clamped only.  Default: undef
//
// Returns:
//   [control_points, knots, start_index] for nurbs_curve(..., type=type).
//   start_index is the index into the original points list of the data point
//   at the parametric origin.  For clamped/open this is always 0.  For
//   closed it equals the seam-rotation offset _rot, which may be nonzero
//   when the conditioning heuristic cyclic-shifts the data.

function nurbs_interp(points, degree, centripetal=false, type="clamped",
                      derivs=undef, start_der=undef, end_der=undef) =
    assert(is_list(points) && len(points) >= 2,
           "nurbs_interp: need at least 2 data points")
    assert(is_num(degree) && degree >= 1,
           "nurbs_interp: degree must be >= 1")
    assert(type == "clamped" || type == "closed" || type == "open",
           str("nurbs_interp: type must be \"clamped\", \"closed\", or \"open\"",
               ", got \"", type, "\""))
    assert(is_undef(derivs) || (is_undef(start_der) && is_undef(end_der)),
           "nurbs_interp: use derivs= OR start_der=/end_der=, not both")
    assert(type == "clamped" || (is_undef(start_der) && is_undef(end_der)),
           "nurbs_interp: start_der/end_der only supported for type=\"clamped\"")
    assert(is_undef(derivs) || len(derivs) == len(points),
           str("nurbs_interp: derivs= must have same length as points (",
               len(points), " points, ", is_undef(derivs) ? 0 : len(derivs), " derivs)"))
    type == "clamped" ? _nurbs_interp_clamped(points, degree, centripetal,
                                               derivs, start_der, end_der)
  : type == "closed"  ? _nurbs_interp_closed(points, degree, centripetal, derivs)
  :                     _nurbs_interp_open(points, degree, centripetal, derivs);


// ---------- CLAMPED interpolation ----------
//
// start_der= and end_der= are convenience shorthands for derivs= at the
// endpoints.  They are merged into a derivs list here so that all
// derivative-constrained cases flow through a single solver
// (_nurbs_interp_clamped_derivlist).

function _nurbs_interp_clamped(points, degree, centripetal,
                                derivs, start_der, end_der) =
    let(n = len(points) - 1, p = degree)
    assert(n >= p,
           str("nurbs_interp (clamped): need at least ", p+1,
               " points for degree ", p, ", got ", n+1))
    let(
        has_sd = !is_undef(start_der),
        has_ed = !is_undef(end_der),

        // Convert start_der / end_der to a derivs list when no explicit
        // derivs= was provided.
        eff_der = !is_undef(derivs) ? derivs
                : (has_sd || has_ed)
                  ? [for (k = [0:n])
                         k == 0 && has_sd ? start_der
                       : k == n && has_ed ? end_der
                       : undef]
                : undef,

        has_any = !is_undef(eff_der) &&
                  len([for (k = [0:n]) if (!is_undef(eff_der[k])) k]) > 0
    )
    has_any ? _nurbs_interp_clamped_derivlist(points, p, centripetal, eff_der)
            : _nurbs_interp_clamped_basic(points, p, centripetal);


// Basic clamped interpolation (no derivatives).
// n+1 points -> n+1 control points.

function _nurbs_interp_clamped_basic(points, p, centripetal) =
    let(
        n       = len(points) - 1,
        params  = _interp_params(points, centripetal),
        int_kn  = _avg_knots_interior(params, p),
        U_full  = _full_clamped_knots(int_kn, p),
        N_mat   = _collocation_matrix(params, n, p, U_full),
        control = linear_solve(N_mat, points),
        knots   = [0, each int_kn, 1]
    )
    assert(control != [],
           "nurbs_interp (clamped): singular system")
    [control, knots, 0];


// General clamped interpolation with per-point derivative constraints.
//
// Uses Method A (expanded-parameter knot averaging, P&T §9.2.2):
// For each constrained index k, duplicate params[k] in an expanded
// sequence ũ, then apply the standard interior-knot averaging formula
// to ũ.  This naturally clusters knots near constrained parameters and
// provides one extra DOF per derivative constraint.

function _nurbs_interp_clamped_derivlist(points, p, centripetal, derivs) =
    let(
        n         = len(points) - 1,
        dim       = len(points[0]),
        path_len  = path_length(points),
        params    = _interp_params(points, centripetal),

        // [index, scaled+validated vector] for every non-undef entry
        der_specs = [for (k = [0:n]) if (!is_undef(derivs[k]))
                        [k, _force_deriv_dim(derivs[k], dim) * path_len]],
        n_extra   = len(der_specs),
        N         = n + 1 + n_extra,   // total control points

        // Expanded parameter sequence ũ: duplicate params[k] for each
        // derivative constraint at k (sort preserves monotonicity)
        u_tilde = sort([each params, for (spec = der_specs) params[spec[0]]]),

        // Interior knots by standard averaging on ũ (P&T eq 9.8)
        int_kn  = _avg_knots_interior(u_tilde, p),
        U_full  = _full_clamped_knots(int_kn, p),

        // Interpolation rows: N_{j,p}(t_k)
        interp_rows = [for (k = [0:n])
            [for (j = [0:N-1]) _nip(j, p, params[k], U_full)]
        ],

        // Derivative rows: N'_{j,p}(t_k)
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:N-1]) _dnip(j, p, params[k], U_full)]
        ],

        A       = [each interp_rows, each deriv_rows],
        rhs     = [each points, for (spec = der_specs) spec[1]],
        control = linear_solve(A, rhs),
        knots   = [0, each int_kn, 1]
    )
    assert(control != [],
           "nurbs_interp (clamped+derivs): singular system")
    [control, knots, 0];


// ---------- CLOSED interpolation ----------

function _nurbs_interp_closed(points, degree, centripetal, derivs) =
    let(n = len(points), p = degree)
    assert(n >= p + 1,
           str("nurbs_interp (closed): need at least ", p+1,
               " points for degree ", p, ", got ", n))
    let(has_dl = !is_undef(derivs) &&
                 len([for (k = [0:n-1]) if (!is_undef(derivs[k])) k]) > 0)
    has_dl ? _nurbs_interp_closed_derivlist(points, p, centripetal, derivs)
           : _nurbs_interp_closed_basic(points, p, centripetal);


// Basic closed interpolation — start-point independent.
//
// Implements the cyclic chord-length parameterization and cyclic knot
// averaging of Piegl & Tiller §9.2.4.  In exact arithmetic the resulting
// curve is the same regardless of which data point is listed first; only
// the parametric origin changes (the curve is just reparameterized).
//
// Numerical conditioning depends on where the "worst junction" — a very
// short chord immediately before a very long one — falls relative to the
// active knot spans.  When that junction is an interior point pair, the
// two close-together parameters can land in the same span, making the
// collocation matrix near-singular.  We avoid this by choosing the cyclic
// starting offset r* = (argmax_i d[i+1]/d[i] + 1) % n, which places that
// junction at the periodic seam.  At the seam, the two parameters straddle
// the [0,1] boundary and are assigned to different knot spans by the
// cyclic averaging, restoring a one-param-per-span distribution.
//
// This is an O(n) deterministic selection rather than a rotation search.
// If the resulting collocation matrix is still ill-conditioned (assert
// below), use centripetal=true or provide more uniform data.

function _nurbs_interp_closed_basic(points, p, centripetal) =
    let(
        n      = len(points),

        // Cyclic chord lengths, including the closing segment.
        chords = path_segment_lengths(points, closed=true),

        // Ratio d[i+1]/d[i] for each junction.  A large ratio flags a
        // "short before long" junction that should go at the seam.
        ratios  = [for (i = [0:n-1]) chords[(i+1)%n] / max(chords[i], 1e-15)],

        // argmax(ratios): first index achieving the maximum.
        rat_idx = max_index(ratios),

        // Optimal starting offset: one past the short chord of the worst pair.
        _rot       = (rat_idx + 1) % n,
        pts        = select(points, _rot, _rot + n - 1),

        raw_params = _interp_params_closed(pts, centripetal),
        bar_knots  = _avg_knots_periodic(raw_params, p)[0],

        // BOSL2-compatible full knot vector (matches _extend_knot_vector()).
        U_full  = _bosl2_full_closed_knots(bar_knots, n, p),

        // Map raw params into the BOSL2 active domain [bar_knots[p], bar_knots[p]+T].
        params  = add_scalar(raw_params, bar_knots[p]),

        // Sanity: each active span must contain exactly one param.
        _span_counts = [for (k = [0:n-1])
                            len([for (t = params)
                                     if (t >= U_full[p+k] && t < U_full[p+k+1])
                                         t])
                       ]
    )
    assert(max(_span_counts) <= 1,
           str("nurbs_interp (closed): ill-conditioned parameterization ",
               "(span counts = ", _span_counts, "). ",
               "Use centripetal=true or provide more uniform data."))
    let(
        _echo   = _rot > 0
                  ? echo(str("nurbs_interp (closed): cyclic start rotation = ", _rot,
                             " (optimal seam placement for chord ratio ",
                             round(ratios[rat_idx] * 100) / 100, ")"))
                  : undef,
        N_mat   = _collocation_matrix_periodic(params, n, p, U_full),
        control = linear_solve(N_mat, pts)
    )
    assert(control != [], "nurbs_interp (closed): singular system")
    [control, bar_knots, _rot];


// Closed interpolation with per-point derivative constraints.
//
// Uses Method A (expanded-parameter knot averaging): for each constrained
// index k, duplicate raw_params[k] in an expanded sequence ũ of length M,
// then re-run _avg_knots_periodic on ũ to get M+1 bar knots.  The
// resulting M = n + n_extra control points use the standard BOSL2 periodic
// aliasing: B_j(t) = N_j(t) + (j<p ? N_{j+M}(t) : 0), likewise for
// derivatives.
//
// Applies the same optimal-seam rotation as _nurbs_interp_closed_basic for
// numerical conditioning.  Both the data points and the derivative list are
// rotated together so the constraint associations are preserved.

function _nurbs_interp_closed_derivlist(points, p, centripetal, derivs) =
    let(
        n        = len(points),
        dim      = len(points[0]),
        path_len = path_length(points, closed=true),

        // Optimal-seam rotation (same criterion as basic closed case).
        chords  = path_segment_lengths(points, closed=true),
        ratios  = [for (i = [0:n-1]) chords[(i+1)%n] / max(chords[i], 1e-15)],
        rat_idx = max_index(ratios),
        _rot    = (rat_idx + 1) % n,

        // Rotate both data points and derivative list by the same offset.
        pts      = select(points, _rot, _rot + n - 1),
        derivs_r = select(derivs, _rot, _rot + n - 1),

        raw_params = _interp_params_closed(pts, centripetal),

        der_specs = [for (k = [0:n-1]) if (!is_undef(derivs_r[k]))
                        [k, _force_deriv_dim(derivs_r[k], dim) * path_len]],
        n_extra   = len(der_specs),
        M         = n + n_extra,   // total control points

        // Expanded parameter sequence ũ of length M: duplicate raw_params[k]
        // for each derivative constraint at k
        u_tilde = sort([each raw_params, for (spec = der_specs) raw_params[spec[0]]]),

        // Periodic bar knots from expanded sequence: M+1 entries
        aug_bar = _avg_knots_periodic(u_tilde, p)[0],
        U_full  = _bosl2_full_closed_knots(aug_bar, M, p),

        // Map raw params into active domain [aug_bar[p], aug_bar[p]+T]
        params = add_scalar(raw_params, aug_bar[p]),

        // Interpolation rows: aliased basis for M control points
        interp_rows = [for (k = [0:n-1])
            [for (j = [0:M-1])
                _nip(j, p, params[k], U_full)
              + (j < p ? _nip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        // Derivative rows: aliased derivative basis for M control points
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:M-1])
                _dnip(j, p, params[k], U_full)
              + (j < p ? _dnip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        A       = [each interp_rows, each deriv_rows],
        rhs     = [each pts, for (spec = der_specs) spec[1]],
        control = linear_solve(A, rhs)
    )
    assert(control != [],
           "nurbs_interp (closed+derivs): singular system")
    [control, aug_bar, _rot];


// ---------- OPEN interpolation ----------

function _nurbs_interp_open(points, degree, centripetal, derivs) =
    let(n = len(points) - 1, p = degree)
    assert(n >= p,
           str("nurbs_interp (open): need at least ", p+1,
               " points for degree ", p, ", got ", n+1))
    let(has_dl = !is_undef(derivs) &&
                 len([for (k = [0:n]) if (!is_undef(derivs[k])) k]) > 0)
    has_dl ? _nurbs_interp_open_derivlist(points, p, centripetal, derivs)
           : _nurbs_interp_open_basic(points, p, centripetal);


function _nurbs_interp_open_basic(points, p, centripetal) =
    let(
        n      = len(points) - 1,
        m      = n + p + 1,
        U_full = [for (i = [0:m]) i / m],
        u_lo   = U_full[p],
        u_hi   = U_full[n + 1],
        raw_params = _interp_params(points, centripetal),
        params     = [for (t = raw_params) u_lo + t * (u_hi - u_lo)],
        N_mat   = _collocation_matrix(params, n, p, U_full),
        control = linear_solve(N_mat, points)
    )
    assert(control != [],
           "nurbs_interp (open): singular system")
    [control, U_full, 0];


// Open interpolation with per-point derivative constraints.
//
// Increases the control point count to N = n + 1 + n_extra and rebuilds
// the uniform knot vector for N points.  The evaluation domain scales
// accordingly; raw chord-length params are remapped into it.

function _nurbs_interp_open_derivlist(points, p, centripetal, derivs) =
    let(
        n          = len(points) - 1,
        dim        = len(points[0]),
        path_len   = path_length(points),
        raw_params = _interp_params(points, centripetal),
        der_specs  = [for (k = [0:n]) if (!is_undef(derivs[k]))
                         [k, _force_deriv_dim(derivs[k], dim) * path_len]],
        n_extra    = len(der_specs),
        N          = n + 1 + n_extra,   // total control points

        m      = N + p,                 // last knot index
        U_full = [for (i = [0:m]) i / m],
        u_lo   = U_full[p],
        u_hi   = U_full[N],
        params = [for (t = raw_params) u_lo + t * (u_hi - u_lo)],

        // Interpolation rows
        interp_rows = [for (k = [0:n])
            [for (j = [0:N-1]) _nip(j, p, params[k], U_full)]
        ],

        // Derivative rows (evaluated at same mapped parameters)
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:N-1]) _dnip(j, p, params[k], U_full)]
        ],

        A       = [each interp_rows, each deriv_rows],
        rhs     = [each points, for (spec = der_specs) spec[1]],
        control = linear_solve(A, rhs)
    )
    assert(control != [],
           "nurbs_interp (open+derivs): singular system")
    [control, U_full, 0];


// =====================================================================
// SECTION: Convenience Functions
// =====================================================================

// Function: nurbs_interp_curve()
// Synopsis: Generates a curve path that interpolates through data points.
// See Also: nurbs_interp(), nurbs_curve()
//
// Usage:
//   path = nurbs_interp_curve(points, degree, [splinesteps],
//              [centripetal=], [type=], [derivs=], [start_der=], [end_der=]);

function nurbs_interp_curve(points, degree, splinesteps=16,
                            centripetal=false, type="clamped",
                            derivs=undef, start_der=undef, end_der=undef) =
    let(
        result  = nurbs_interp(points, degree, centripetal=centripetal,
                               type=type, derivs=derivs,
                               start_der=start_der, end_der=end_der),
        control = result[0],
        knots   = result[1]
    )
    nurbs_curve(control, degree, splinesteps=splinesteps,
                knots=knots, type=type);


// =====================================================================
// SECTION: Debug / Visualization
// =====================================================================

// Module: debug_nurbs_interp()
// Synopsis: Visualizes interpolation: data points, control polygon, curve.
// See Also: nurbs_interp(), debug_nurbs()
//
// Usage:
//   debug_nurbs_interp(points, degree, [splinesteps=], [centripetal=],
//                      [type=], [start_der=], [end_der=],
//                      [width=], [size=], [data_color=], [data_size=]);

module debug_nurbs_interp(points, degree, splinesteps=16, centripetal=false,
                          type="clamped", derivs=undef,
                          start_der=undef, end_der=undef,
                          width=0.1, size=undef,
                          data_color="magenta", data_size=undef) {
    result  = nurbs_interp(points, degree, centripetal=centripetal,
                           type=type, derivs=derivs,
                           start_der=start_der, end_der=end_der);
    control = result[0];
    knots   = result[1];
    ds      = is_undef(data_size) ? 0.125 : data_size;
    sz      = is_undef(size)      ? 3 * width : size;

    debug_nurbs(control, degree, splinesteps=splinesteps,
                knots=knots, type=type, width=width, size=sz);

    color(data_color)
        for (i = [0 : len(points)-1])
            translate(points[i])
                if (len(points[i]) == 2)
                    circle(r=ds, $fn=16);
                else
                    sphere(r=ds, $fn=16);
}


// =====================================================================
// SECTION: Interpolation System Builder (shared by curve & surface)
// =====================================================================

// Builds the collocation matrix and BOSL2-format knots for a single
// parameterized direction.  Returns [N_mat, bosl2_knots].

function _build_interp_system(params, p, type) =
    type == "clamped" ? _build_clamped_system(params, p)
  : type == "closed"  ? _build_closed_system(params, p)
  :                     _build_open_system(params, p);

function _build_clamped_system(params, p) =
    let(
        n       = len(params) - 1,
        int_kn  = _avg_knots_interior(params, p),
        U_full  = _full_clamped_knots(int_kn, p),
        N_mat   = _collocation_matrix(params, n, p, U_full),
        knots   = [0, each int_kn, 1]
    )
    [N_mat, knots];

function _build_closed_system(params, p) =
    let(
        n          = len(params),
        bar_knots  = _avg_knots_periodic(params, p)[0],
        U_full     = _bosl2_full_closed_knots(bar_knots, n, p),
        col_params = add_scalar(params, bar_knots[p]),
        N_mat      = _collocation_matrix_periodic(col_params, n, p, U_full)
    )
    [N_mat, bar_knots];

function _build_open_system(params, p) =
    let(
        n      = len(params) - 1,
        m      = n + p + 1,
        U_full = [for (i = [0:m]) i / m],
        u_lo   = U_full[p],
        u_hi   = U_full[n + 1],
        mapped = [for (t = params) u_lo + t * (u_hi - u_lo)],
        N_mat  = _collocation_matrix(mapped, n, p, U_full)
    )
    [N_mat, U_full];


// =====================================================================
// SECTION: Surface Interpolation
// =====================================================================

// Averaged parameterization for the u-direction (across rows).
// For each column, compute chord-length params, then average.

function _surface_params_u(points, centripetal, closed_u) =
    let(
        n_rows = len(points),
        n_cols = len(points[0]),
        col_params = [for (l = [0:n_cols-1])
            let(col = [for (k = [0:n_rows-1]) points[k][l]])
            closed_u ? _interp_params_closed(col, centripetal)
                     : _interp_params(col, centripetal)
        ],
        n_p = len(col_params[0])
    )
    [for (k = [0:n_p-1])
        sum([for (l = [0:n_cols-1]) col_params[l][k]]) / n_cols
    ];


// Averaged parameterization for the v-direction (across columns).
// For each row, compute chord-length params, then average.

function _surface_params_v(points, centripetal, closed_v) =
    let(
        n_rows = len(points),
        n_cols = len(points[0]),
        row_params = [for (k = [0:n_rows-1])
            closed_v ? _interp_params_closed(points[k], centripetal)
                     : _interp_params(points[k], centripetal)
        ],
        n_p = len(row_params[0])
    )
    [for (l = [0:n_p-1])
        sum([for (k = [0:n_rows-1]) row_params[k][l]]) / n_rows
    ];


// Function: nurbs_interp_surface()
// Synopsis: Finds NURBS surface control points that interpolate a grid of data points.
// Topics: NURBS Surfaces, Interpolation
// See Also: nurbs_vnf(), nurbs_interp(), nurbs_interp_vnf()
//
// Usage:
//   result = nurbs_interp_surface(points, degree, [centripetal=], [type=]);
//
// Description:
//   Given a rectangular grid of 3D data points and a NURBS degree,
//   computes the control point grid and knot vectors for a NURBS
//   surface that passes exactly through every data point.  Uses the
//   two-pass method from Piegl & Tiller §9.2.5: first interpolate
//   each row in the v-direction, then each column in the u-direction.
//   .
//   The degree and type can each be a single value (applied to both
//   directions) or a 2-element list [u_value, v_value] to specify
//   different settings per direction.
//   .
//   Returns [control_grid, u_knots, v_knots].  To render:
//   .
//     result = nurbs_interp_surface(data, 3);
//     vnf = nurbs_vnf(result[0], 3, splinesteps=8,
//               knots=[result[1], result[2]], type=type);
//     vnf_polyhedron(vnf);
//   .
//   Or use the convenience function nurbs_interp_vnf().
//
// Arguments:
//   points      = rectangular grid of 3D data points (list of rows)
//   degree      = NURBS degree: scalar or [u_degree, v_degree]
//   ---
//   centripetal = use centripetal parameterization.  Default: false
//   type        = "clamped"/"closed"/"open", or [u_type, v_type].
//                 Default: "clamped"
//
// Returns:
//   [control_grid, u_knots, v_knots]

function nurbs_interp_surface(points, degree, centripetal=false,
                              type="clamped") =
    let(
        p_u    = is_list(degree) ? degree[0] : degree,
        p_v    = is_list(degree) ? degree[1] : degree,
        type_u = is_list(type) ? type[0] : type,
        type_v = is_list(type) ? type[1] : type,
        n_rows = len(points),
        n_cols = len(points[0])
    )
    assert(is_list(points) && n_rows >= 2,
           "nurbs_interp_surface: need at least 2 rows")
    assert(n_cols >= 2,
           "nurbs_interp_surface: need at least 2 columns")
    assert(n_rows >= p_u + 1,
           str("nurbs_interp_surface: need at least ", p_u+1,
               " rows for u-degree ", p_u, ", got ", n_rows))
    assert(n_cols >= p_v + 1,
           str("nurbs_interp_surface: need at least ", p_v+1,
               " columns for v-degree ", p_v, ", got ", n_cols))
    let(
        // Averaged parameterization in each direction
        u_params = _surface_params_u(points, centripetal,
                                     type_u == "closed"),
        v_params = _surface_params_v(points, centripetal,
                                     type_v == "closed"),

        // ----- Pass 1: Interpolate in v-direction (across columns) -----
        // Build the v collocation matrix once; solve for every row.
        v_sys    = _build_interp_system(v_params, p_v, type_v),
        N_v      = v_sys[0],
        v_knots  = v_sys[1],
        R        = [for (k = [0:n_rows-1])
                        linear_solve(N_v, points[k])],

        // ----- Pass 2: Interpolate in u-direction (across rows) -----
        // Build the u collocation matrix once; solve for every column.
        u_sys    = _build_interp_system(u_params, p_u, type_u),
        N_u      = u_sys[0],
        u_knots  = u_sys[1],

        // Transpose R so each entry is a column of intermediate points
        n_v_ctrl = len(R[0]),
        R_T      = [for (j = [0:n_v_ctrl-1])
                        [for (k = [0:n_rows-1]) R[k][j]]],

        // Solve u-direction for each column of intermediate points
        P_T      = [for (j = [0:n_v_ctrl-1])
                        linear_solve(N_u, R_T[j])],

        // Transpose back to get the final control point grid
        n_u_ctrl = len(P_T[0]),
        P        = [for (i = [0:n_u_ctrl-1])
                        [for (j = [0:n_v_ctrl-1]) P_T[j][i]]]
    )
    [P, u_knots, v_knots];


// Function: nurbs_interp_vnf()
// Synopsis: Generates a VNF for a surface interpolating a grid of data points.
// Topics: NURBS Surfaces, Interpolation
// See Also: nurbs_interp_surface(), nurbs_vnf()
//
// Usage:
//   vnf = nurbs_interp_vnf(points, degree, [splinesteps],
//             [centripetal=], [type=], [style=]);
//
// Description:
//   Convenience function that computes the NURBS surface interpolation
//   and immediately generates a VNF for rendering.  Equivalent to
//   calling nurbs_interp_surface() followed by nurbs_vnf().

function nurbs_interp_vnf(points, degree, splinesteps=8,
                          centripetal=false, type="clamped",
                          style="default") =
    let(
        result  = nurbs_interp_surface(points, degree,
                      centripetal=centripetal, type=type),
        patch   = result[0],
        u_knots = result[1],
        v_knots = result[2],
        deg     = is_list(degree) ? degree : [degree, degree],
        tp      = is_list(type) ? type : [type, type]
    )
    nurbs_vnf(patch, deg, splinesteps=splinesteps,
              knots=[u_knots, v_knots], type=tp, style=style);


// Module: debug_nurbs_interp_surface()
// Synopsis: Visualizes surface interpolation with data points and surface.
// See Also: nurbs_interp_surface(), nurbs_interp_vnf()
//
// Usage:
//   debug_nurbs_interp_surface(points, degree, [splinesteps=],
//       [centripetal=], [type=], [style=], [data_color=], [data_size=]);

module debug_nurbs_interp_surface(points, degree, splinesteps=8,
                                  centripetal=false, type="clamped",
                                  style="default",
                                  data_color="red", data_size=0.5) {
    vnf = nurbs_interp_vnf(points, degree, splinesteps=splinesteps,
              centripetal=centripetal, type=type, style=style);
    vnf_polyhedron(vnf);

    color(data_color)
        for (row = points)
            for (pt = row)
                translate(pt) sphere(r=data_size, $fn=16);
}


// =====================================================================
// SECTION: Usage Examples
// =====================================================================
//
// ---- Example 1: CLAMPED (default) ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   debug_nurbs_interp(data, 3);
//
//
// ---- Example 2: CLOSED (debug view) ----
//   Do NOT repeat the first point at the end.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [30,50], [60,40], [80,10], [50,-20], [20,-10]];
//   debug_nurbs_interp(data, 3, type="closed");
//
//
// ---- Example 3: OPEN ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   debug_nurbs_interp(data, 3, type="open");
//
//
// ---- Example 4: Closed polygon ----
//   All data points should lie exactly on the boundary of the polygon.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [30,50], [60,40], [80,10], [50,-20], [20,-10]];
//   path = nurbs_interp_curve(data, 3, splinesteps=16, type="closed");
//   polygon(path);
//   color("red") move_copies(data) circle(r=0.25, $fn=16);
//
//
// ---- Example 5: Get just the path ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   path = nurbs_interp_curve(data, 3, splinesteps=32, type="clamped");
//   stroke(path, width=0.5);
//   color("red") move_copies(data) circle(r=0.25, $fn=16);
//
//
// ---- Example 6: Low-level access ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   result  = nurbs_interp(data, 3, type="clamped");
//   control = result[0];
//   knots   = result[1];
//   curve = nurbs_curve(control, 3, splinesteps=24, knots=knots,
//                       type="clamped");
//   stroke(curve, width=0.5);
//
//
// ---- Example 7: 3D closed curve ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data3d = [[20,0,0],[0,20,10],[-20,0,20],[0,-20,10]];
//   path = nurbs_interp_curve(data3d, 3, splinesteps=32, type="closed");
//   stroke(path, width=1);
//   color("red") move_copies(data3d) sphere(r=0.25, $fn=16);
//
//
// ---- Example 8: Centripetal parameterization for sharp turns ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   sharp = [[0,0], [5,40],[6,40], [10,0], [50,0], [55,40],[56,42], [60,0]];
//   color("blue")  stroke(nurbs_interp_curve(sharp, 3), width=0.1);
//   color("red")   stroke(nurbs_interp_curve(sharp, 3, centripetal=true), width=0.1);
//   color("green") move_copies(sharp) circle(r=.1, $fn=16);
//
//
// ---- Example 9: Endpoint tangent control ----
//   Specify start and/or end tangent vectors.  Each vector is automatically
//   scaled by the total chord length; a unit vector produces natural
//   arc-length speed.  Magnitude > 1 increases pull, < 1 weakens it.
//   BOSL2 direction constants (UP, RIGHT, etc.) work for 2D curves.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [20,30], [50,25], [80,0]];
//   // No tangent control (natural):
//   color("gray") stroke(nurbs_interp_curve(data, 3), width=0.3);
//   // Tangent: start going straight up, end going straight down:
//   color("blue") stroke(
//       nurbs_interp_curve(data, 3, start_der=[0,1], end_der=[0,-1]),
//       width=0.3);
//   // Tangent: start going right, end going right:
//   color("red") stroke(
//       nurbs_interp_curve(data, 3, start_der=[1,0], end_der=[1,0]),
//       width=0.3);
//   color("black") move_copies(data) circle(r=0.25, $fn=16);
//
//
// ---- Example 10: Start tangent only ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [20,30], [50,25], [80,0]];
//   color("gray") stroke(nurbs_interp_curve(data, 3), width=0.3);
//   color("blue") stroke(
//       nurbs_interp_curve(data, 3, start_der=[0,1]),
//       width=0.3);
//   color("black") move_copies(data) circle(r=0.25, $fn=16);
//
//
// =====================================================================
// SECTION: Surface Interpolation Examples
// =====================================================================
//
// ---- Example 11: Basic surface interpolation ----
//   A 4x5 grid of 3D data points → smooth interpolating surface.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [
//       [[-50, 50,  0], [-16, 50,  20], [ 16, 50,  10], [50, 50,  0], [80, 50,  5]],
//       [[-50, 16, 20], [-16, 16,  40], [ 16, 16,  30], [50, 16, 20], [80, 16, 10]],
//       [[-50,-16, 20], [-16,-16,  35], [ 16,-16,  40], [50,-16, 15], [80,-16, 25]],
//       [[-50,-50,  0], [-16,-50,  10], [ 16,-50,  20], [50,-50,  0], [80,-50,  5]],
//   ];
//   debug_nurbs_interp_surface(data, 3, splinesteps=8);
//
//
// ---- Example 12: Different degrees per direction ----
//   Quadratic in u, cubic in v.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [
//       for (u = [-40:20:40])
//           [for (v = [-40:20:40])
//               [v, u, 15*sin(u*3)*cos(v*3)]]
//   ];
//   vnf = nurbs_interp_vnf(data, [2,3], splinesteps=8);
//   vnf_polyhedron(vnf);
//
//
// ---- Example 13: Surface closed in one direction (tube) ----
//   Closed around the v-direction (the rings), clamped in u (along the
//   axis).  Uses 5 rings rather than 4: a cubic closed direction needs
//   at least p+2 = 5 data rows/columns to have interior knot freedom.
//   With only p+1 = 4, the system is solvable but the closed direction
//   has no interior flexibility and produces results nearly identical to
//   the clamped case.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   r = 20;
//   data = [for (u = [0:15:60])      // 5 rings: u = 0,15,30,45,60
//       [for (i = [0:5])
//           let(a = i * 360/6)
//           [r*cos(a), r*sin(a), u]]
//   ];
//   vnf = nurbs_interp_vnf(data, 3, splinesteps=8,
//             type=["clamped","closed"]);
//   vnf_polyhedron(vnf);
//
//
// ---- Example 14: Surface closed in both directions (torus) ----
//   For ["closed","closed"] to produce a shape visibly different from
//   ["clamped","closed"], two conditions must both be met:
//
//   1. ENOUGH POINTS: each direction needs at least p+2 points so the
//      periodic system has at least one interior knot with genuine
//      freedom.  With exactly p+1 points the system is solvable but
//      there is no interior flexibility, and the result looks nearly
//      identical to the clamped case.
//
//   2. BALANCED PARAMETERIZATION: the data must form an actual closed
//      loop in each direction.  For chord-length parameterization the
//      "closing" segment (last point back to first) is included in the
//      parameter budget.  If that segment is much longer than the inter-
//      point distances the closed direction folds back on itself rather
//      than forming a smooth loop.  Use evenly-spaced data, or data
//      whose first and last points coincide (so the closing chord is
//      zero and parameter spacing is uniform).
//
//   The canonical example is a torus: both directions sample a full
//   360° circle with even angular spacing, so the closing segment
//   equals the inter-point spacing and parameterization is uniform.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   R = 30; r = 10;    // major / minor torus radii
//   N = 6;             // 6 samples each way  (N > p+1 = 4 for cubic)
//   data = [for (i = [0:N-1])
//       let(phi = i * 360/N)
//       [for (j = [0:N-1])
//           let(theta = j * 360/N)
//           [(R + r*cos(theta))*cos(phi),
//            (R + r*cos(theta))*sin(phi),
//            r*sin(theta)]]
//   ];
//   vnf = nurbs_interp_vnf(data, 3, splinesteps=12,
//             type=["closed","closed"]);
//   vnf_polyhedron(vnf);
//
//
// ---- Example 15: Low-level surface access ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [
//       [[-30,30,0], [0,30,20], [30,30,0]],
//       [[-30, 0,10],[0, 0,30], [30, 0,10]],
//       [[-30,-30,0],[0,-30,15],[30,-30,0]],
//   ];
//   result  = nurbs_interp_surface(data, 2);
//   patch   = result[0];
//   u_knots = result[1];
//   v_knots = result[2];
//   vnf = nurbs_vnf(patch, 2, splinesteps=12,
//             knots=[u_knots, v_knots], type="clamped");
//   vnf_polyhedron(vnf);
//   color("red")
//       for (row = data) for (pt = row)
//           translate(pt) sphere(r=1, $fn=16);
