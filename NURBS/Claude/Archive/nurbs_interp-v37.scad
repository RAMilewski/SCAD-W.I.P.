//////////////////////////////////////////////////////////////////////
// LibFile: nurbs_interp.scad
//   NURBS Curve Interpolation through Data Points
//
//   Given a set of data points, computes the NURBS control points and
//   knot vector such that the resulting curve passes exactly through
//   every data point.  Supports two BOSL2 NURBS types:
//     "clamped" - curve starts/ends at first/last data point
//     "closed"  - curve forms a smooth closed loop through all points
//
//   Optional per-point derivative (tangent) constraints can be applied
//   to both curve types via the deriv= parameter.  The clamped
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
// Development Version 37
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


// Second derivative of B-spline basis N_{j,p}''(u).
// Same recurrence as _dnip applied once more (P&T §2.3 eq. 2.9);
// zero-length spans are guarded.  Returns 0 for p ≤ 1.

function _d2nip(j, p, u, U) =
    p <= 1 ? 0
    : let(
          d1 = U[j+p]   - U[j],
          d2 = U[j+p+1] - U[j+1]
      )
      (abs(d1) > 1e-15 ? p * _dnip(j,   p-1, u, U) / d1 : 0)
    - (abs(d2) > 1e-15 ? p * _dnip(j+1, p-1, u, U) / d2 : 0);


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


// Convert a curvature specification to a C''(t) constraint vector.
//
// Under natural-speed parameterization (|C'(t)| = v), curvature κ and
// the second derivative relate by: C''(t) = κ_vec_normal × v².
// Tangential acceleration is set to zero (arc-length parameterization at that point).
//
// curv_spec  = signed scalar κ (dim=2), or a vector (any dim including 2D).
//              Scalar (dim=2): positive = CCW (left), negative = CW (right).
//              Vector: direction = desired normal; magnitude = |κ|;
//              any component along tang_dir is automatically projected out.
// tang_dir   = tangent direction at the point (need not be normalized).
// dim        = spatial dimension (len(points[0])).
// v2         = |C'(t)|² at the constrained point.

function _curv_to_d2(curv_spec, tang_dir, dim, v2) =
    let(t_hat = unit(tang_dir))
    (dim == 2 && is_num(curv_spec))
    ? // 2D signed scalar: rotate tangent 90° CCW to get the normal direction.
      let(n_hat = [-t_hat[1], t_hat[0]])
      curv_spec * n_hat * v2
    : // Vector form (any dim, including 2D): project out tangential component.
      assert(is_vector(curv_spec) && len(curv_spec) >= 1 && len(curv_spec) <= dim,
             str("nurbs_interp: curvature constraint must be a signed scalar (2D) or a ",
                 "vector of dimension 1–", dim))
      let(
          cv      = _force_deriv_dim(curv_spec, dim),
          cv_perp = cv - (cv * t_hat) * t_hat
      )
      cv_perp * v2;


// =====================================================================
// SECTION: Parameterization
// =====================================================================


// Dynamic centripetal parameterization (Balta et al., IEEE Access 2020 §III).
// Per-chord exponent inversely proportional to ln(chord_length):
//   e_i = ln(chordmax/chordi) / ln(chordmax/chordmin) * (emax-emin) + emin
// Long chords get exponent emin=0.35 (compressed contribution).
// Short chords get exponent emax=0.65 (expanded contribution).
// Falls back to e=0.5 (standard centripetal) when all chords are equal.

function _dynamic_dists(raw, emin=0.35, emax=0.65) =
    let(
        cmax  = max(raw),
        cmin  = min(raw),
        log_r = ln(cmax / cmin)
    )
    // Divide each chord by cmin so that d/cmin ≥ 1 for every chord.
    // This is required for correctness: pow(x, e) is an increasing function
    // of e only when x > 1, so d > 1 ensures that the longer chords (with
    // smaller exponent emin) are correctly compressed relative to shorter
    // chords (with larger exponent emax).  Normalizing by cmin also makes
    // the result scale-invariant: λd/λcmin = d/cmin for any scale factor λ.
    log_r < 1e-12
      ? [for (d = raw) sqrt(d / cmin)]   // equal chords → uniform spacing
      : [for (d = raw)
            let(e = ln(cmax / d) / log_r * (emax - emin) + emin)
            pow(d / cmin, e)
        ];



// Improved centripetal parameterization (Fang et al. Computer-Aided Design Volume 45, Issue 6, June 2013, Pages 1005-1028) 

function _fang_dists(path, closed) =
  let(
      efactor = [for(i=idx(path))
                   !closed && (i==0 || i==len(path)-1) ? 0
                 : let(
                       tri = select(path,i-1,i+1),
                       ell = min(path_segment_lengths(tri,closed=true)),
                       theta=180-vector_angle(select(path,i-1,i+1))
                    )
                    0.1 * theta*PI/180 / 2 / sin(theta/2) * ell],
      dists = [for(i=[0:len(path)-(closed?1:2)])
                 sqrt(path_length(select(path,i,i+1)))+efactor[i]+select(efactor,i+1)]
  )
  dists;


// Foley-Neilson parameterization (Foley & Neilson 1987; as cited in
// Balta et al., IEEE Access 2020 §II.E).  Each chord's parameter increment
// is chord_length × (1 + curvature corrections from both adjacent vertices).
// The correction weight at each vertex is proportional to the deflection angle
// at that vertex (clamped to π/2) and the shorter of the two adjacent chords.
// For open curves, endpoint deflection angles are treated as zero.
// For closed curves, wrap-around angles and chords are used at the seam.

function _foley_dists(points, closed) =
    let(
        n  = len(points),
        c  = path_segment_lengths(points, closed=closed),
        nc = len(c),
        // θ̂[i] = min(deflection angle at P[i], π/2) in radians.
        // Deflection angle = 180° − interior angle at P[i].
        // Endpoints of an open curve contribute zero correction.
        theta_hat = [for (i = [0:n-1])
            !closed && (i == 0 || i == n-1) ? 0
          : let(phi_deg = 180 - vector_angle(select(points, i-1, i+1)))
            min(phi_deg * PI/180, PI/2)
        ]
    )
    [for (i = [0:nc-1])
        let(
            ci     = c[i],
            c_prev = c[(i - 1 + nc) % nc],
            c_next = c[(i + 1) % nc],
            th_L   = theta_hat[i],
            th_R   = theta_hat[(i + 1) % n],
            left   = (i == 0 && !closed) ? 0
                   : 3 * th_L * c_prev / max(2 * (c_prev + ci), 1e-15),
            right  = (i == nc-1 && !closed) ? 0
                   : 3 * th_R * c_next / max(2 * (ci + c_next), 1e-15)
        )
        ci * (1 + left + right)
    ];


// Chord-length, centripetal, dynamic, Fang, or Foley parameterization.
// clamped: n+1 points -> n+1 values in [0, 1] with t_0=0, t_n=1.
// closed:  n   points -> n   values in [0, 1) with t_0=0.
// method: "length"      = chord-length
//        "centripetal" = sqrt exponent (Lee 1989)
//        "dynamic"     = per-chord dynamic exponent (Balta et al. 2020)
//        "fang"        = osculating-circle correction (Fang & Hung 2013)
//        "foley"       = deflection-angle correction (Foley & Neilson 1987)

function _interp_params(points, method="dynamic", closed=false) =
    let(
        raw       = path_segment_lengths(points, closed=closed),
        n         = len(raw),
        total_raw = sum(raw)
    )
    // Degenerate: all points identical (e.g. a surface pole row/column).
    // Return uniform spacing so surface parameter averages stay valid.
    total_raw < 1e-10
      ? (closed
           ? [for (i = [0:n-1]) i / n]
           : [for (i = [0:n  ]) i / n])
      : assert(min(raw) > 1e-10,
               "nurbs_interp: consecutive duplicate data points detected")
        let(
            dists = method == "centripetal" ? [for (d = raw) sqrt(d)]
                  : method == "dynamic"     ? _dynamic_dists(raw)
                  : method == "fang"        ? _fang_dists(points, closed)
                  : method == "foley"       ? _foley_dists(points, closed)
                  :                          raw,
            total = sum(dists),
            cs    = cumsum(dists)
        )
        closed ? [0, each [for (x = list_head(cs)) x / total]]
               : [0, each [for (x = list_head(cs)) x / total], 1];


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
    concat(repeat(0, p+1), interior_knots, repeat(1, p+1));


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

// Standard collocation matrix for clamped type.

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
//   result = nurbs_interp(points, degree, [method=], [type=],
//                         [deriv=], [start_der=], [end_der=],
//                         [curv=], [start_curv=], [end_curv=]);
//
// Description:
//   Given a list of data points (2D or 3D) and a NURBS degree, computes
//   the control points and knot vector for a NURBS curve that passes
//   exactly through every data point.  Returns [control_points, knots]
//   for use with nurbs_curve().
//   .
//   Two curve types are supported:
//   .
//   "clamped" (default): Curve starts at the first point and ends at
//   the last point.  Optionally constrain tangent directions at any data
//   point with deriv=, and curvature at any data point with curv=.
//   .
//   "closed": Smooth closed loop through all points.  Do NOT repeat the
//   first point at the end.
//   .
//   Derivative constraints (deriv=):
//   .
//   deriv[k] specifies the desired tangent direction (and relative speed)
//   at the k-th data point.  Each derivative vector is automatically scaled
//   by the total chord length of the data, so a unit vector produces motion
//   at natural arc-length speed and a vector of magnitude 2 produces twice
//   that speed.  BOSL2 named constants (UP, DOWN, LEFT, RIGHT, BACK, FWD)
//   are accepted for 2D curves; the 3D vector is projected onto the data
//   plane (XZ if Y=0, XY otherwise).
//   start_der= and end_der= are shorthand equivalents for specifying
//   deriv[0] and deriv[n] respectively.
//   .
//   Curvature constraints (curv=):
//   .
//   curv[k] specifies the desired curvature at the k-th data point.  Each
//   curvature-constrained point MUST also have a derivative constraint
//   (deriv[k], start_der=, or end_der=); the derivative defines the tangent
//   direction needed to orient the curvature normal.  For 2D curves, supply
//   a signed scalar κ (positive = left/CCW, negative = right/CW) or a 2D
//   vector pointing in the desired normal direction.  For 3D curves, supply a
//   vector whose direction is the desired normal and whose magnitude is |κ|;
//   any component along the tangent is automatically removed.  Curvature
//   constraints are supported for both "clamped" and "closed" curve types.
//   They require degree >= 2; most useful at degree >= 3.  start_curv= and
//   end_curv= are shorthand equivalents for curv[0] and curv[n] (clamped only).
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate
//   degree      = degree of the NURBS curve (commonly 3)
//   ---
//   method       = parameterization method: "length" (chord-length),
//                 "centripetal" (square-root exponent, Lee 1989),
//                 "dynamic" (per-chord dynamic exponent, Balta et al. 2020),
//                 "fang" (osculating-circle correction, Fang & Hung 2013), or
//                 "foley" (deflection-angle correction, Foley & Neilson 1987).
//                 Default: "dynamic"
//   type        = "clamped" or "closed".  Default: "clamped"
//   deriv       = list of tangent vectors, one per data point; undef entries
//                 are unconstrained.  Both curve types supported.
//                 Cannot be combined with start_der=/end_der=.  Vectors are
//                 scaled by total chord length internally; pass unit vectors
//                 for natural speed.  BOSL2 direction constants (UP, DOWN,
//                 LEFT, RIGHT, BACK, FWD) accepted for 2D curves.
//                 Default: undef
//   start_der   = tangent at start point; shorthand for deriv[0].
//                 Clamped only.  Default: undef
//   end_der     = tangent at end point; shorthand for deriv[n].
//                 Clamped only.  Default: undef
//   curv        = list of curvature constraints, one per data point; undef
//                 entries are unconstrained.  2D curves: signed scalar κ
//                 (positive=CCW/left, negative=CW/right) or a 2D vector
//                 (direction = desired normal, magnitude = |κ|).  3D curves:
//                 vector (direction = normal, magnitude = |κ|; any tangential
//                 component is projected out).  Both clamped and closed types.
//                 Each curv[k] requires a corresponding non-undef deriv[k].
//                 Cannot be combined with start_curv=/end_curv=.
//                 Default: undef
//   start_curv  = curvature at start point; shorthand for curv[0].
//                 Requires start_der= or deriv[0].  Clamped only.
//                 Default: undef
//   end_curv    = curvature at end point; shorthand for curv[n].
//                 Requires end_der= or deriv[n].  Clamped only.
//                 Default: undef
//
// Returns:
//   [control_points, knots, start_index] for nurbs_curve(..., type=type).
//   start_index is the index into the original points list of the data point
//   at the parametric origin.  For clamped this is always 0.  For
//   closed it equals the seam-rotation offset _rot, which may be nonzero
//   when the conditioning heuristic cyclic-shifts the data.

function nurbs_interp(points, degree, method="dynamic", type="clamped",
                      deriv=undef, start_der=undef, end_der=undef,
                      curv=undef, start_curv=undef, end_curv=undef) =
    assert(is_list(points) && len(points) >= 2,
           "nurbs_interp: need at least 2 data points")
    assert(is_num(degree) && degree >= 1,
           "nurbs_interp: degree must be >= 1")
    assert(method == "length" || method == "centripetal" || method == "dynamic"
               || method == "fang" || method == "foley",
           str("nurbs_interp: method must be \"length\", \"centripetal\", \"dynamic\", \"fang\", or \"foley\", got \"", method, "\""))
    assert(type == "clamped" || type == "closed",
           str("nurbs_interp: type must be \"clamped\" or \"closed\"",
               ", got \"", type, "\""))
    assert(is_undef(deriv) || (is_undef(start_der) && is_undef(end_der)),
           "nurbs_interp: use deriv= OR start_der=/end_der=, not both")
    assert(type == "clamped" || (is_undef(start_der) && is_undef(end_der)),
           "nurbs_interp: start_der/end_der only supported for type=\"clamped\"")
    assert(is_undef(deriv) || len(deriv) == len(points),
           str("nurbs_interp: deriv= must have same length as points (",
               len(points), " points, ", is_undef(deriv) ? 0 : len(deriv), " deriv)"))
    assert(is_undef(curv) || (is_undef(start_curv) && is_undef(end_curv)),
           "nurbs_interp: use curv= OR start_curv=/end_curv=, not both")
    assert(type == "clamped" || (is_undef(start_curv) && is_undef(end_curv)),
           "nurbs_interp: start_curv=/end_curv= only supported for type=\"clamped\"")
    assert(is_undef(curv) || len(curv) == len(points),
           str("nurbs_interp: curv= must have same length as points (",
               len(points), " points, ", is_undef(curv) ? 0 : len(curv), " curv)"))
    type == "clamped" ? _nurbs_interp_clamped(points, degree, method,
                                               deriv, start_der, end_der,
                                               curv, start_curv, end_curv)
  :                     _nurbs_interp_closed(points, degree, method, deriv, curv);


// ---------- CLAMPED interpolation ----------
//
// start_der=/end_der= and start_curv=/end_curv= are convenience shorthands.
// They are merged into eff_der / eff_curv lists here so that all
// constrained cases flow through a single solver
// (_nurbs_interp_clamped_constrained).

function _nurbs_interp_clamped(points, degree, method,
                                deriv, start_der, end_der,
                                curv, start_curv, end_curv) =
    let(n = len(points) - 1, p = degree)
    assert(n >= p,
           str("nurbs_interp (clamped): need at least ", p+1,
               " points for degree ", p, ", got ", n+1))
    let(
        has_sd = !is_undef(start_der),
        has_ed = !is_undef(end_der),
        has_sc = !is_undef(start_curv),
        has_ec = !is_undef(end_curv),

        // Merge start_der / end_der into a deriv list.
        eff_der = !is_undef(deriv) ? deriv
                : (has_sd || has_ed)
                  ? [for (k = [0:n])
                         k == 0 && has_sd ? start_der
                       : k == n && has_ed ? end_der
                       : undef]
                : undef,

        // Merge start_curv / end_curv into a curv list.
        eff_curv = !is_undef(curv) ? curv
                 : (has_sc || has_ec)
                   ? [for (k = [0:n])
                          k == 0 && has_sc ? start_curv
                        : k == n && has_ec ? end_curv
                        : undef]
                 : undef,

        has_any_der  = !is_undef(eff_der) &&
                       len([for (k = [0:n]) if (!is_undef(eff_der[k]))  k]) > 0,
        has_any_curv = !is_undef(eff_curv) &&
                       len([for (k = [0:n]) if (!is_undef(eff_curv[k])) k]) > 0,

        // Every curvature-constrained point must also have a derivative
        // constraint; the derivative direction defines the curve's tangent
        // and is required to orient the curvature normal.
        bad_curv_pts = is_undef(eff_curv) ? [] :
            [for (k = [0:n])
                if (!is_undef(eff_curv[k]) &&
                    (is_undef(eff_der) || is_undef(eff_der[k])))
                k]
    )
    assert(bad_curv_pts == [],
           str("nurbs_interp: curvature constraint requires a derivative constraint ",
               "at the same point(s): ", bad_curv_pts))
    (has_any_der || has_any_curv)
      ? _nurbs_interp_clamped_constrained(points, p, method, eff_der, eff_curv)
      : _nurbs_interp_clamped_basic(points, p, method);


// Basic clamped interpolation (no derivatives).
// n+1 points -> n+1 control points.

function _nurbs_interp_clamped_basic(points, p, method) =
    let(
        n       = len(points) - 1,
        params  = _interp_params(points, method),
        int_kn  = _avg_knots_interior(params, p),
        U_full  = _full_clamped_knots(int_kn, p),
        N_mat   = _collocation_matrix(params, n, p, U_full),
        control = linear_solve(N_mat, points),
        knots   = [0, each int_kn, 1]
    )
    assert(control != [],
           "nurbs_interp (clamped): singular system")
    [control, knots, 0];


// General clamped interpolation with per-point derivative and/or curvature
// constraints.
//
// eff_der:  list of n+1 first-derivative specs (undef = unconstrained).
// eff_curv: list of n+1 curvature specs (undef = unconstrained).
//           dim=2: signed scalar κ.  dim≥3: curvature vector.
//
// Uses Method A (expanded-parameter knot averaging, P&T §9.2.2): for each
// constraint at index k, duplicate params[k] in an expanded sequence ũ —
// once per constraint type (deriv and curv each add one duplication per
// constrained point).  This provides one extra DOF per extra constraint.

function _nurbs_interp_clamped_constrained(points, p, method, eff_der, eff_curv) =
    let(
        n         = len(points) - 1,
        dim       = len(points[0]),
        path_len  = path_length(points),
        path_len2 = path_len * path_len,
        params    = _interp_params(points, method),

        // First-derivative specs: [index, C'(t) vector]
        der_specs = is_undef(eff_der) ? []
                  : [for (k = [0:n]) if (!is_undef(eff_der[k]))
                        [k, _force_deriv_dim(eff_der[k], dim) * path_len]],

        // Curvature specs: [index, C''(t) vector].
        // Tangent direction taken from eff_der[k] when available;
        // otherwise estimated from the adjacent chord.
        // Speed² taken from |eff_der[k]|² × path_len² when eff_der is given;
        // otherwise path_len² (unit-speed assumption).
        curv_specs = is_undef(eff_curv) ? []
                   : [for (k = [0:n]) if (!is_undef(eff_curv[k]))
                          let(
                              t_from_der = is_undef(eff_der)       ? undef
                                         : is_undef(eff_der[k])    ? undef
                                         : _force_deriv_dim(eff_der[k], dim),
                              tang_dir   = !is_undef(t_from_der) ? t_from_der
                                         : k == 0 ? points[1] - points[0]
                                         : k == n ? points[n] - points[n-1]
                                         :          points[k+1] - points[k-1],
                              v2         = !is_undef(t_from_der)
                                         ? path_len2 * (t_from_der * t_from_der)
                                         : path_len2
                          )
                          [k, _curv_to_d2(eff_curv[k], tang_dir, dim, v2)]
                      ],

        n_extra_der  = len(der_specs),
        n_extra_curv = len(curv_specs),
        n_extra      = n_extra_der + n_extra_curv,
        N            = n + 1 + n_extra,   // total control points

        // Expanded parameter sequence ũ: duplicate params[k] once per
        // constraint type at k (sort preserves monotonicity)
        u_tilde = sort([
            each params,
            for (spec = der_specs)  params[spec[0]],
            for (spec = curv_specs) params[spec[0]]
        ]),

        // Interior knots by standard averaging on ũ (P&T eq 9.8)
        int_kn  = _avg_knots_interior(u_tilde, p),
        U_full  = _full_clamped_knots(int_kn, p),

        // Interpolation rows: N_{j,p}(t_k)
        interp_rows = [for (k = [0:n])
            [for (j = [0:N-1]) _nip(j, p, params[k], U_full)]
        ],

        // First-derivative rows: N'_{j,p}(t_k)
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:N-1]) _dnip(j, p, params[k], U_full)]
        ],

        // Second-derivative rows: N''_{j,p}(t_k)
        curv_rows = [for (spec = curv_specs)
            let(k = spec[0])
            [for (j = [0:N-1]) _d2nip(j, p, params[k], U_full)]
        ],

        A       = [each interp_rows, each deriv_rows, each curv_rows],
        rhs     = [each points,
                   for (spec = der_specs)  spec[1],
                   for (spec = curv_specs) spec[1]],
        control = linear_solve(A, rhs),
        knots   = [0, each int_kn, 1]
    )
    assert(n_extra_curv == 0 || p >= 2,
           "nurbs_interp: curvature constraints require degree >= 2")
    assert(control != [],
           "nurbs_interp (clamped+constrained): singular system")
    [control, knots, 0];


// ---------- CLOSED interpolation ----------

function _nurbs_interp_closed(points, degree, method, deriv, curv) =
    let(n = len(points), p = degree)
    assert(n >= p + 1,
           str("nurbs_interp (closed): need at least ", p+1,
               " points for degree ", p, ", got ", n))
    let(
        has_dl = !is_undef(deriv) &&
                 len([for (k = [0:n-1]) if (!is_undef(deriv[k])) k]) > 0,
        has_cl = !is_undef(curv) &&
                 len([for (k = [0:n-1]) if (!is_undef(curv[k])) k]) > 0,

        // Every curvature-constrained point must also have a derivative constraint.
        bad_curv_pts = is_undef(curv) ? [] :
            [for (k = [0:n-1])
                if (!is_undef(curv[k]) &&
                    (is_undef(deriv) || is_undef(deriv[k])))
                k]
    )
    assert(bad_curv_pts == [],
           str("nurbs_interp: curvature constraint requires a derivative constraint ",
               "at the same point(s): ", bad_curv_pts))
    (has_dl || has_cl)
      ? _nurbs_interp_closed_constrained(points, p, method, deriv, curv)
      : _nurbs_interp_closed_basic(points, p, method);


// Returns true if cyclic rotation r produces exactly one parameter per
// active knot span — the necessary condition for a non-singular collocation.
// The method="dynamic" method can invert the chord→increment ordering, so
// the chord-ratio heuristic may pick a rotation that causes a span collision
// for that method even though the data itself is well-conditioned.

function _closed_rotation_valid(points, n, p, method, r) =
    let(
        pts = select(points, r, r + n - 1),
        rp  = _interp_params(pts, method, closed=true),
        bk  = _avg_knots_periodic(rp, p)[0],
        U   = _bosl2_full_closed_knots(bk, n, p),
        ps  = add_scalar(rp, bk[p])
    )
    max([for (k = [0:n-1])
            len([for (t = ps) if (t >= U[p+k] && t < U[p+k+1]) t])
        ]) <= 1;


// Find the best seam rotation for closed curve interpolation.
// The chord-ratio heuristic (argmax d[i+1]/d[i] + 1) is tried first;
// if it causes a span collision, all n rotations are searched in order.
// Returns undef only if every rotation produces a collision.

function _find_closed_rotation(points, n, p, method) =
    let(
        chords     = path_segment_lengths(points, closed=true),
        ratios     = [for (i = [0:n-1]) chords[(i+1)%n] / max(chords[i], 1e-15)],
        rot0       = (max_index(ratios) + 1) % n,
        candidates = concat([rot0], [for (i = [0:n-1]) if (i != rot0) i]),
        valid      = [for (r = candidates)
                         if (_closed_rotation_valid(points, n, p, method, r)) r]
    )
    len(valid) > 0 ? valid[0] : undef;


// Basic closed interpolation — start-point independent.
//
// Implements the cyclic chord-length parameterization and cyclic knot
// averaging of Piegl & Tiller §9.2.4.  In exact arithmetic the resulting
// curve is the same regardless of which data point is listed first; only
// the parametric origin changes (the curve is just reparameterized).
//
// Numerical conditioning requires one parameter per active knot span.
// The chord-ratio heuristic rotation works for method="length" and
// method="centripetal" (long chord → large increment).  For method="dynamic"
// the exponent inversion (long chord → small increment) can make the
// heuristic rotation suboptimal, so _find_closed_rotation() searches all
// n candidates and picks the first valid one.

function _nurbs_interp_closed_basic(points, p, method) =
    let(
        n    = len(points),
        _rot = _find_closed_rotation(points, n, p, method)
    )
    assert(!is_undef(_rot),
           "nurbs_interp (closed): no valid seam rotation found; data may be too irregular.")
    let(
        pts        = select(points, _rot, _rot + n - 1),
        raw_params = _interp_params(pts, method, closed=true),
        bar_knots  = _avg_knots_periodic(raw_params, p)[0],
        U_full     = _bosl2_full_closed_knots(bar_knots, n, p),
        params     = add_scalar(raw_params, bar_knots[p]),
        _echo      = _rot > 0
                     ? echo(str("nurbs_interp (closed): seam rotation = ", _rot))
                     : undef,
        N_mat      = _collocation_matrix_periodic(params, n, p, U_full),
        control    = linear_solve(N_mat, pts)
    )
    assert(control != [], "nurbs_interp (closed): singular system")
    [control, bar_knots, _rot];


// Closed interpolation with per-point derivative and/or curvature constraints.
//
// eff_der:  list of n first-derivative specs (undef = unconstrained).
// eff_curv: list of n curvature specs (undef = unconstrained).
//           dim=2: signed scalar κ or 2D vector.  dim≥3: curvature vector.
//
// Uses Method A (expanded-parameter knot averaging): for each constraint
// at index k, duplicate raw_params[k] in an expanded sequence ũ of length M,
// then re-run _avg_knots_periodic on ũ to get M+1 bar knots.  The
// M = n + n_extra control points use standard BOSL2 periodic aliasing:
// B_j(t) = N_j(t) + (j<p ? N_{j+M}(t) : 0), and likewise for derivatives.
//
// Applies the chord-ratio seam rotation for numerical conditioning; both the
// data points and all constraint lists are rotated by the same offset.

function _nurbs_interp_closed_constrained(points, p, method, eff_der, eff_curv) =
    let(
        n         = len(points),
        dim       = len(points[0]),
        path_len  = path_length(points, closed=true),
        path_len2 = path_len * path_len,

        // Chord-ratio seam rotation (same heuristic as basic closed case).
        chords  = path_segment_lengths(points, closed=true),
        ratios  = [for (i = [0:n-1]) chords[(i+1)%n] / max(chords[i], 1e-15)],
        _rot    = (max_index(ratios) + 1) % n,

        // Rotate data, deriv, and curv lists by the same offset so constraint
        // associations are preserved after rotation.
        pts    = select(points,  _rot, _rot + n - 1),
        der_r  = is_undef(eff_der)  ? undef : select(eff_der,  _rot, _rot + n - 1),
        curv_r = is_undef(eff_curv) ? undef : select(eff_curv, _rot, _rot + n - 1),

        raw_params = _interp_params(pts, method, closed=true),

        // First-derivative specs: [index, C'(t) vector]
        der_specs = is_undef(der_r) ? []
                  : [for (k = [0:n-1]) if (!is_undef(der_r[k]))
                        [k, _force_deriv_dim(der_r[k], dim) * path_len]],

        // Curvature specs: [index, C''(t) vector]
        curv_specs = is_undef(curv_r) ? []
                   : [for (k = [0:n-1]) if (!is_undef(curv_r[k]))
                          let(
                              // Tangent from explicit derivative (required by caller).
                              t_from_der = is_undef(der_r)    ? undef
                                         : is_undef(der_r[k]) ? undef
                                         : _force_deriv_dim(der_r[k], dim),
                              tang_dir   = !is_undef(t_from_der) ? t_from_der
                                         : pts[(k+1)%n] - pts[(k-1+n)%n],
                              v2         = !is_undef(t_from_der)
                                         ? path_len2 * (t_from_der * t_from_der)
                                         : path_len2
                          )
                          [k, _curv_to_d2(curv_r[k], tang_dir, dim, v2)]
                      ],

        n_extra_der  = len(der_specs),
        n_extra_curv = len(curv_specs),
        n_extra      = n_extra_der + n_extra_curv,
        M            = n + n_extra,   // total control points

        // Expanded parameter sequence ũ: duplicate raw_params[k] once per
        // constraint type at k (sort preserves monotonicity)
        u_tilde = sort([
            each raw_params,
            for (spec = der_specs)  raw_params[spec[0]],
            for (spec = curv_specs) raw_params[spec[0]]
        ]),

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

        // First-derivative rows: aliased derivative basis
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:M-1])
                _dnip(j, p, params[k], U_full)
              + (j < p ? _dnip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        // Second-derivative rows: aliased second-derivative basis
        curv_rows = [for (spec = curv_specs)
            let(k = spec[0])
            [for (j = [0:M-1])
                _d2nip(j, p, params[k], U_full)
              + (j < p ? _d2nip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        A       = [each interp_rows, each deriv_rows, each curv_rows],
        rhs     = [each pts,
                   for (spec = der_specs)  spec[1],
                   for (spec = curv_specs) spec[1]],
        control = linear_solve(A, rhs)
    )
    assert(n_extra_curv == 0 || p >= 2,
           "nurbs_interp: curvature constraints require degree >= 2")
    assert(control != [],
           "nurbs_interp (closed+constrained): singular system")
    [control, aug_bar, _rot];


// =====================================================================
// SECTION: Convenience Functions
// =====================================================================

// Function: nurbs_interp_curve()
// Synopsis: Generates a curve path that interpolates through data points.
// See Also: nurbs_interp(), nurbs_curve()
//
// Usage:
//   path = nurbs_interp_curve(points, degree, [splinesteps],
//              [method=], [type=], [deriv=], [start_der=], [end_der=],
//              [curv=], [start_curv=], [end_curv=]);

function nurbs_interp_curve(points, degree, splinesteps=16,
                            method="dynamic", type="clamped",
                            deriv=undef, start_der=undef, end_der=undef,
                            curv=undef, start_curv=undef, end_curv=undef) =
    let(
        result  = nurbs_interp(points, degree, method=method,
                               type=type, deriv=deriv,
                               start_der=start_der, end_der=end_der,
                               curv=curv, start_curv=start_curv,
                               end_curv=end_curv),
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
//   debug_nurbs_interp(points, degree, [splinesteps=], [method=],
//                      [type=], [start_der=], [end_der=],
//                      [start_curv=], [end_curv=],
//                      [width=], [size=], [data_color=], [data_size=]);

module debug_nurbs_interp(points, degree, splinesteps=16, method="dynamic",
                          type="clamped", deriv=undef,
                          start_der=undef, end_der=undef,
                          curv=undef, start_curv=undef, end_curv=undef,
                          width=0.1, size=undef,
                          data_color="magenta", data_size=undef) {
    result  = nurbs_interp(points, degree, method=method,
                           type=type, deriv=deriv,
                           start_der=start_der, end_der=end_der,
                           curv=curv, start_curv=start_curv,
                           end_curv=end_curv);
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
  :                     _build_closed_system(params, p);

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


// Build a clamped interpolation system with optional start/end first-derivative rows.
// Extends _build_clamped_system by adding one extra DOF and one extra matrix row
// for each active boundary (start and/or end).  Used for surface boundary tangents.
//
// has_sd / has_ed — whether a start / end derivative constraint is active.
// Returns [A_matrix, bosl2_knots].  A_matrix is square with n+1+n_extra rows/columns,
// where n = len(params)-1 and n_extra = (has_sd?1:0)+(has_ed?1:0).
// Row order: interpolation rows (k=0..n), deriv_start (if any), deriv_end (if any).

function _build_clamped_system_with_derivs(params, p, has_sd, has_ed) =
    let(
        n       = len(params) - 1,
        n_extra = (has_sd ? 1 : 0) + (has_ed ? 1 : 0),
        N_ctrl  = n + 1 + n_extra,
        u_tilde = sort(concat(
            params,
            has_sd ? [params[0]] : [],
            has_ed ? [params[n]] : []
        )),
        int_kn      = _avg_knots_interior(u_tilde, p),
        U_full      = _full_clamped_knots(int_kn, p),
        interp_rows = [for (k = [0:n])
                           [for (j = [0:N_ctrl-1]) _nip(j, p, params[k], U_full)]
                      ],
        deriv_start = has_sd
                    ? [[for (j = [0:N_ctrl-1]) _dnip(j, p, params[0], U_full)]]
                    : [],
        deriv_end   = has_ed
                    ? [[for (j = [0:N_ctrl-1]) _dnip(j, p, params[n], U_full)]]
                    : [],
        knots       = [0, each int_kn, 1]
    )
    [[each interp_rows, each deriv_start, each deriv_end], knots];


// =====================================================================
// SECTION: Surface Interpolation
// =====================================================================

// Compute per-point tangent vectors for a degenerate apex row or column.
// Used to auto-generate start_u_der / end_u_der / start_v_der / end_v_der
// when the corresponding *_normal= parameter is supplied.
//
// N    = normal vector at the apex (defines axis; magnitude sets derivative
//        scale using the same convention as the explicit *_der= parameters).
// apex = the degenerate point (all data points in the row/col are identical).
// ring = list of points in the adjacent row/column (one per sample).
//
// Returns a list (same length as ring) of vectors each of magnitude norm(N)
// lying in the plane perpendicular to N, pointing from apex toward ring[j].
// Pass the negated result for an end (u=1 or v=1) apex; see caller.

function _apex_tangents(N, apex, ring) =
    let(
        mag   = norm(N),
        N_hat = N / max(mag, 1e-15)
    )
    [for (pt = ring)
        let(
            d      = pt - apex,
            d_perp = d - (d * N_hat) * N_hat,
            n_perp = norm(d_perp)
        )
        n_perp > 1e-12 ? mag * d_perp / n_perp : [for (i = [0:len(N)-1]) 0]
    ];

// Averaged parameterization for the u-direction (across rows).
// For each column, compute chord-length params, then average.

function _surface_params_u(points, method, closed_u) =
    let(
        n_rows = len(points),
        n_cols = len(points[0]),
        col_params = [for (l = [0:n_cols-1])
            let(col = [for (k = [0:n_rows-1]) points[k][l]])
            _interp_params(col, method, closed=closed_u)
        ],
        n_p = len(col_params[0])
    )
    [for (k = [0:n_p-1])
        sum([for (l = [0:n_cols-1]) col_params[l][k]]) / n_cols
    ];


// Averaged parameterization for the v-direction (across columns).
// For each row, compute chord-length params, then average.

function _surface_params_v(points, method, closed_v) =
    let(
        n_rows = len(points),
        n_cols = len(points[0]),
        row_params = [for (k = [0:n_rows-1])
            _interp_params(points[k], method, closed=closed_v)
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
//   result = nurbs_interp_surface(points, degree, [method=], [type=],
//                [start_u_der=], [end_u_der=],
//                [start_v_der=], [end_v_der=],
//                [start_u_normal=], [end_u_normal=],
//                [start_v_normal=], [end_v_normal=]);
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
//   Partial derivative constraints can be specified along any of the
//   four boundary edges.  start_v_der / end_v_der constrain ∂S/∂v
//   along the first and last column edges (v=0 and v=1).
//   start_u_der / end_u_der constrain ∂S/∂u along the first and last
//   row edges (u=0 and u=1).  When both u- and v-boundary derivatives
//   are active simultaneously, cross-derivatives ∂²S/∂u∂v are assumed
//   zero at the corners; this is accurate when the corner mixed
//   derivatives are small.  Derivative vectors follow the same
//   convention as the curve API: pass normalized vectors and the code
//   scales by the per-row or per-column chord length.
//   .
//   For [clamped,closed] or [closed,clamped] surfaces whose clamped
//   boundary is a degenerate edge (all data points in that row or
//   column are identical — e.g. a cone apex or vase tip), the
//   *_normal= parameters offer a simpler alternative to *_der=.
//   Supply a single normal vector N at the degenerate edge; the code
//   automatically fans the partial-derivative vectors outward from the
//   apex into the plane perpendicular to N.  The magnitude of N sets
//   the derivative scale using the same convention as *_der=.  For a
//   start (u=0 or v=0) apex the fan points outward; for an end (u=1
//   or v=1) apex it is automatically negated to match the +u/+v
//   parametric direction.  Cannot be combined with the corresponding
//   explicit *_der= parameter.
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
//   points         = rectangular grid of 3D data points (list of rows)
//   degree         = NURBS degree: scalar or [u_degree, v_degree]
//   ---
//   method         = parameterization method: "length", "centripetal", "dynamic",
//                    "fang", or "foley".  Default: "dynamic"
//   type           = "clamped"/"closed", or [u_type, v_type].
//                    Default: "clamped"
//   start_u_der    = list of n_cols derivative vectors for ∂S/∂u along the u=0
//                    boundary (first row edge).  One 3D vector per data column.
//                    Requires type_u="clamped".  Vectors scaled by per-column
//                    u-direction chord length (pass unit vectors for natural speed).
//                    Default: undef
//   end_u_der      = list of n_cols vectors for ∂S/∂u along the u=1 boundary.
//                    Default: undef
//   start_v_der    = list of n_rows derivative vectors for ∂S/∂v along the v=0
//                    boundary (first column edge).  One 3D vector per data row.
//                    Requires type_v="clamped".  Vectors scaled by per-row
//                    v-direction chord length.  Default: undef
//   end_v_der      = list of n_rows vectors for ∂S/∂v along the v=1 boundary.
//                    Default: undef
//   start_u_normal = normal vector at a degenerate u=0 edge (all points the same).
//                    Automatically generates start_u_der perpendicular to this
//                    normal; magnitude of vector sets derivative scale.
//                    Cannot be used together with start_u_der.  Default: undef
//   end_u_normal   = normal vector at a degenerate u=1 edge.  Default: undef
//   start_v_normal = normal vector at a degenerate v=0 edge.  Default: undef
//   end_v_normal   = normal vector at a degenerate v=1 edge.  Default: undef
//
// Returns:
//   [control_grid, u_knots, v_knots]

function nurbs_interp_surface(points, degree, method="dynamic", type="clamped",
                              start_u_der=undef, end_u_der=undef,
                              start_v_der=undef, end_v_der=undef,
                              start_u_normal=undef, end_u_normal=undef,
                              start_v_normal=undef, end_v_normal=undef) =
    let(
        p_u    = is_list(degree) ? degree[0] : degree,
        p_v    = is_list(degree) ? degree[1] : degree,
        type_u = is_list(type) ? type[0] : type,
        type_v = is_list(type) ? type[1] : type,
        n_rows = len(points),
        n_cols = len(points[0]),
        dim    = len(points[0][0]),
        has_sud = !is_undef(start_u_der),
        has_eud = !is_undef(end_u_der),
        has_svd = !is_undef(start_v_der),
        has_evd = !is_undef(end_v_der),
        has_sun = !is_undef(start_u_normal),
        has_eun = !is_undef(end_u_normal),
        has_svn = !is_undef(start_v_normal),
        has_evn = !is_undef(end_v_normal)
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
    assert(!(has_sud || has_eud || has_sun || has_eun) || type_u == "clamped",
           "nurbs_interp_surface: u-direction derivative/normal params require type_u=\"clamped\"")
    assert(!(has_svd || has_evd || has_svn || has_evn) || type_v == "clamped",
           "nurbs_interp_surface: v-direction derivative/normal params require type_v=\"clamped\"")
    assert(!has_sud || len(start_u_der) == n_cols,
           str("nurbs_interp_surface: start_u_der must have ", n_cols,
               " entries (one per column), got ", is_undef(start_u_der) ? 0 : len(start_u_der)))
    assert(!has_eud || len(end_u_der) == n_cols,
           str("nurbs_interp_surface: end_u_der must have ", n_cols,
               " entries (one per column), got ", is_undef(end_u_der) ? 0 : len(end_u_der)))
    assert(!has_svd || len(start_v_der) == n_rows,
           str("nurbs_interp_surface: start_v_der must have ", n_rows,
               " entries (one per row), got ", is_undef(start_v_der) ? 0 : len(start_v_der)))
    assert(!has_evd || len(end_v_der) == n_rows,
           str("nurbs_interp_surface: end_v_der must have ", n_rows,
               " entries (one per row), got ", is_undef(end_v_der) ? 0 : len(end_v_der)))
    assert(!(has_sun && has_sud),
           "nurbs_interp_surface: cannot specify both start_u_normal and start_u_der")
    assert(!(has_eun && has_eud),
           "nurbs_interp_surface: cannot specify both end_u_normal and end_u_der")
    assert(!(has_svn && has_svd),
           "nurbs_interp_surface: cannot specify both start_v_normal and start_v_der")
    assert(!(has_evn && has_evd),
           "nurbs_interp_surface: cannot specify both end_v_normal and end_v_der")
    let(
        // Compute effective derivative lists.
        // Normal-based: auto-fan perpendicular to the axis defined by the normal.
        // For a start (u=0 or v=0) apex the fan points outward (apex→ring).
        // For an end  (u=1 or v=1) apex the fan is negated to match the +u/+v
        // parametric direction (ring→apex, i.e. converging toward the tip).
        start_u_der_eff = has_sun
            ? _apex_tangents(start_u_normal, points[0][0], points[1])
            : start_u_der,
        end_u_der_eff   = has_eun
            ? [for (v = _apex_tangents(end_u_normal,
                                       points[n_rows-1][0],
                                       points[n_rows-2])) -v]
            : end_u_der,
        start_v_der_eff = has_svn
            ? _apex_tangents(start_v_normal, points[0][0],
                             [for (k = [0:n_rows-1]) points[k][1]])
            : start_v_der,
        end_v_der_eff   = has_evn
            ? [for (v = _apex_tangents(end_v_normal,
                                       points[0][n_cols-1],
                                       [for (k = [0:n_rows-1]) points[k][n_cols-2]])) -v]
            : end_v_der,
        has_sud_eff = has_sud || has_sun,
        has_eud_eff = has_eud || has_eun,
        has_svd_eff = has_svd || has_svn,
        has_evd_eff = has_evd || has_evn
    )
    let(
        // Averaged parameterization in each direction
        u_params = _surface_params_u(points, method, type_u == "closed"),
        v_params = _surface_params_v(points, method, type_v == "closed"),

        // Per-row v-direction path lengths for scaling v-boundary tangents.
        // Follows the curve convention: user passes normalized vectors; code
        // scales by total chord length so a unit vector gives natural speed.
        v_path_lens = [for (k = [0:n_rows-1]) path_length(points[k])],

        // Per-column u-direction path lengths for scaling u-boundary tangents.
        u_path_lens = [for (l = [0:n_cols-1])
                           path_length([for (k = [0:n_rows-1]) points[k][l]])],

        // ----- Build v-direction system -----
        // Use the derivative-extended system when any v-boundary tangent is given.
        v_sys   = (has_svd_eff || has_evd_eff)
                ? _build_clamped_system_with_derivs(v_params, p_v, has_svd_eff, has_evd_eff)
                : _build_interp_system(v_params, p_v, type_v),
        N_v     = v_sys[0],
        v_knots = v_sys[1],

        // ----- Pass 1: Interpolate rows in v-direction -----
        // Same A_v matrix for every row; only the RHS changes per row.
        R = [for (k = [0:n_rows-1])
            let(rhs = concat(
                    points[k],
                    has_svd_eff
                        ? [_force_deriv_dim(start_v_der_eff[k], dim) * v_path_lens[k]]
                        : [],
                    has_evd_eff
                        ? [_force_deriv_dim(end_v_der_eff[k], dim) * v_path_lens[k]]
                        : []))
            linear_solve(N_v, rhs)
        ],

        n_v_ctrl = len(R[0]),

        // ----- Pass 1.5: Project u-boundary tangents into v-control space -----
        // ∂S/∂u along u=0 or u=1 is given at the n_cols data v-positions.
        // To use them as derivative RHS in the u-direction column solves, we
        // must express them in the v B-spline control basis — done by solving
        // the same v-system.  When v-derivative constraints are also active the
        // extra RHS slots correspond to cross-derivatives ∂²S/∂u∂v, set to zero.
        zero_v = [for (d = [0:dim-1]) 0],
        T_u_start = has_sud_eff
                  ? linear_solve(N_v,
                        concat(
                            [for (l = [0:n_cols-1])
                                _force_deriv_dim(start_u_der_eff[l], dim) * u_path_lens[l]],
                            has_svd_eff ? [zero_v] : [],
                            has_evd_eff ? [zero_v] : []))
                  : undef,
        T_u_end   = has_eud_eff
                  ? linear_solve(N_v,
                        concat(
                            [for (l = [0:n_cols-1])
                                _force_deriv_dim(end_u_der_eff[l], dim) * u_path_lens[l]],
                            has_svd_eff ? [zero_v] : [],
                            has_evd_eff ? [zero_v] : []))
                  : undef,

        // ----- Build u-direction system -----
        u_sys   = (has_sud_eff || has_eud_eff)
                ? _build_clamped_system_with_derivs(u_params, p_u, has_sud_eff, has_eud_eff)
                : _build_interp_system(u_params, p_u, type_u),
        N_u     = u_sys[0],
        u_knots = u_sys[1],

        // ----- Pass 2: Interpolate columns in u-direction -----
        // Transpose R so each entry is a column of intermediate points.
        R_T  = [for (j = [0:n_v_ctrl-1])
                    [for (k = [0:n_rows-1]) R[k][j]]],

        // Add u-tangent constraint rows (T_u[j]) to the RHS for each column j.
        P_T  = [for (j = [0:n_v_ctrl-1])
            let(rhs = concat(
                    R_T[j],
                    has_sud_eff ? [T_u_start[j]] : [],
                    has_eud_eff ? [T_u_end[j]]   : []))
            linear_solve(N_u, rhs)
        ],

        // Transpose back to get the final control point grid.
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
//             [method=], [type=], [style=],
//             [start_u_der=], [end_u_der=], [start_v_der=], [end_v_der=]);
//
// Description:
//   Convenience function that computes the NURBS surface interpolation
//   and immediately generates a VNF for rendering.  Equivalent to
//   calling nurbs_interp_surface() followed by nurbs_vnf().

function nurbs_interp_vnf(points, degree, splinesteps=8,
                          method="dynamic", type="clamped",
                          style="default",
                          start_u_der=undef, end_u_der=undef,
                          start_v_der=undef, end_v_der=undef,
                          start_u_normal=undef, end_u_normal=undef,
                          start_v_normal=undef, end_v_normal=undef) =
    let(
        result  = nurbs_interp_surface(points, degree,
                      method=method, type=type,
                      start_u_der=start_u_der, end_u_der=end_u_der,
                      start_v_der=start_v_der, end_v_der=end_v_der,
                      start_u_normal=start_u_normal, end_u_normal=end_u_normal,
                      start_v_normal=start_v_normal, end_v_normal=end_v_normal),
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
//       [method=], [type=], [style=],
//       [start_u_der=], [end_u_der=], [start_v_der=], [end_v_der=],
//       [data_color=], [data_size=]);

module debug_nurbs_interp_surface(points, degree, splinesteps=8,
                                  method="dynamic", type="clamped",
                                  style="default",
                                  start_u_der=undef, end_u_der=undef,
                                  start_v_der=undef, end_v_der=undef,
                                  start_u_normal=undef, end_u_normal=undef,
                                  start_v_normal=undef, end_v_normal=undef,
                                  data_color="red", data_size=0.5) {
    vnf = nurbs_interp_vnf(points, degree, splinesteps=splinesteps,
              method=method, type=type, style=style,
              start_u_der=start_u_der, end_u_der=end_u_der,
              start_v_der=start_v_der, end_v_der=end_v_der,
              start_u_normal=start_u_normal, end_u_normal=end_u_normal,
              start_v_normal=start_v_normal, end_v_normal=end_v_normal);
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
// ---- Example 3: Closed polygon ----
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
// ---- Example 8: Parameterization methods for sharp turns ----
//   "length" (blue), "centripetal" (red), "dynamic" (orange) compared.
//   For data with sudden direction changes or uneven chord spacing,
//   "centripetal" and "dynamic" reduce unwanted oscillations.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   sharp = [[0,0], [5,40],[6,40], [10,0], [50,0], [55,40],[56,42], [60,0]];
//   color("blue")   stroke(nurbs_interp_curve(sharp, 3), width=0.1);
//   color("red")    stroke(nurbs_interp_curve(sharp, 3, method="centripetal"), width=0.1);
//   color("orange") stroke(nurbs_interp_curve(sharp, 3, method="dynamic"), width=0.1);
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
