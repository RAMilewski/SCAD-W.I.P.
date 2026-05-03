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
//   type also accepts the start_deriv=/end_deriv= shorthand arguments.
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
// Development Version 174
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
//              Vector: magnitude = |κ|; the perpendicular projection onto
//              the plane normal to tang_dir provides the direction only.
//              For dim=2 curves, accepts 3D BOSL2 direction constants
//              (UP, DOWN, LEFT, RIGHT, etc.) — projected to 2D same as deriv=.
// tang_dir   = tangent direction at the point (need not be normalized).
// dim        = spatial dimension (len(points[0])).
// v2         = |C'(t)|² at the constrained point.

function _curv_to_d2(curv_spec, tang_dir, dim, v2) =
    let(t_hat = unit(tang_dir))
    (dim == 2 && is_num(curv_spec))
    ? // 2D signed scalar: rotate tangent 90° CCW to get the normal direction.
      let(n_hat = [-t_hat[1], t_hat[0]])
      curv_spec * n_hat * v2
    : // Vector form (any dim, including 2D): magnitude from the input vector,
      // direction from the perpendicular projection.
      // Accepts 3D BOSL2 direction constants (UP, DOWN, etc.) for 2D curves
      // via _force_deriv_dim projection, same as derivative constraints.
      assert(is_vector(curv_spec) && len(curv_spec) >= 1 &&
             (len(curv_spec) <= dim || (dim == 2 && len(curv_spec) == 3)),
             str("nurbs_interp: curvature constraint must be a signed scalar (2D) or a vector of dimension 1–", dim,
                 " (3D BOSL2 constants like UP/DOWN accepted for 2D curves)"))
      let(
          cv      = _force_deriv_dim(curv_spec, dim),
          mag     = norm(cv),
          cv_perp = cv - (cv * t_hat) * t_hat,
          n_perp  = norm(cv_perp)
      )
      assert(n_perp > 1e-12,
             "nurbs_interp: curvature constraint is parallel to the derivative at the same point — curvature must have a component perpendicular to the tangent direction")
      mag * (cv_perp / n_perp) * v2;


// Merges start_deriv=/end_deriv= into a per-point list of length n+1.
// When dim is provided each non-undef, non-NaN entry is projected via
// _force_deriv_dim(): BOSL2 3D direction constants (UP, LEFT, …) map to the
// correct 2D or 3D vector, and shorter vectors are zero-padded.
// NaN corner-marker entries (0/0) pass through unchanged.
// Returns undef when no constraint is specified.
function _merge_deriv_list(n, deriv, dim=undef, start_deriv=undef, end_deriv=undef) =
    let(
        raw = !is_undef(deriv) ? deriv
            : (!is_undef(start_deriv) || !is_undef(end_deriv))
              ? [for (k = [0:1:n])
                     k == 0 && !is_undef(start_deriv) ? start_deriv
                   : k == n && !is_undef(end_deriv)   ? end_deriv
                   : undef]
            : undef
    )
    is_undef(dim) || is_undef(raw) ? raw
    : [for (v = raw) is_undef(v) || is_nan(v) ? v : _force_deriv_dim(v, dim)];


// Merges start_curvature=/end_curvature= into a per-point list of length n+1.
// When dim is provided, vector entries are projected via _force_deriv_dim()
// (handles BOSL2 3D direction constants for 2D curves).  Signed-scalar entries
// (valid for dim=2) are left as-is; the sign encodes the turn direction.
// Returns undef when no constraint is specified.
function _merge_curv_list(n, curvature, dim=undef, start_curvature=undef, end_curvature=undef) =
    let(
        raw = !is_undef(curvature) ? curvature
            : (!is_undef(start_curvature) || !is_undef(end_curvature))
              ? [for (k = [0:1:n])
                     k == 0 && !is_undef(start_curvature) ? start_curvature
                   : k == n && !is_undef(end_curvature)   ? end_curvature
                   : undef]
            : undef
    )
    is_undef(dim) || is_undef(raw) ? raw
    : [for (v = raw) (is_undef(v) || is_num(v)) ? v : _force_deriv_dim(v, dim)];


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



// Foley-Neilson parameterization (Foley & Neilson 1987).
// Centripetal base with deflection-angle correction at each vertex.
function _foley_dists(points, closed) =
    let(
        n  = len(points),
        c  = path_segment_lengths(points, closed=closed),
        nc = len(c),
        // Centripetal base: sqrt of each chord length.
        d  = [for (ci = c) sqrt(ci)],
        // θ̂[i] = min(deflection angle at P[i], π/2) in radians.
        // Deflection angle = 180° − interior angle at P[i].
        // Endpoints of an open curve contribute zero correction.
        theta_hat = [for (i = [0:1:n-1])
            !closed && (i == 0 || i == n-1) ? 0
          : let(phi_deg = 180 - vector_angle(select(points, i-1, i+1)))
            min(phi_deg * PI/180, PI/2)
        ]
    )
    [for (i = [0:1:nc-1])
        let(
            di     = d[i],
            d_prev = d[(i - 1 + nc) % nc],
            d_next = d[(i + 1) % nc],
            th_L   = theta_hat[i],
            th_R   = theta_hat[(i + 1) % n],
            left   = 3 * th_L * d_prev / (2 * (d_prev + di)),
            right  = 3 * th_R * d_next / (2 * (di + d_next))
        )
        di * (1 + left + right)
    ];


// Fang improved centripetal parameterization (Fang & Hung, CAD 2013, Eq. 10).
// Centripetal base + osculating-circle dragging tolerance (α = 0.1).
// At each interior point Pᵢ, eᵢ = α·(θᵢ·ℓᵢ/(2·sin(θᵢ/2)) + θᵢ₋₁·ℓᵢ₋₁/(2·sin(θᵢ₋₁/2)))
// where θᵢ is deflection angle at Pᵢ, ℓᵢ is shortest side of triangle Pᵢ₋₁PᵢPᵢ₊₁.
// Each chord increment is Δᵢ = √‖Lᵢ‖ + eᵢ + eᵢ₊₁ (corrections from both endpoints).

function _fang_correction(points, closed) =
    let(n = len(points))
    [for (i = [0:1:n-1])
        !closed && (i == 0 || i == n-1) ? 0
      : let(
            tri      = select(points, i-1, i+1),
            ell      = min(path_segment_lengths(tri, closed=true)),
            theta_deg = 180 - vector_angle(select(points, i-1, i+1))
        )
        // θ·ℓ/(2·sin(θ/2)); limit as θ→0 is ℓ.
        0.1 * (abs(theta_deg) < 1e-6 ? ell
              : theta_deg * PI/180 * ell / (2 * sin(theta_deg / 2)))
    ];

function _fang_dists(points, closed) =
    let(
        c  = path_segment_lengths(points, closed=closed),
        nc = len(c),
        ef = _fang_correction(points, closed)
    )
    [for (i = [0:1:nc-1])
        sqrt(c[i]) + ef[i] + select(ef, i+1)
    ];


// Chord-length, centripetal, dynamic, Foley, or Fang parameterization.
// clamped: n+1 points -> n+1 values in [0, 1] with t_0=0, t_n=1.
// closed:  n   points -> n   values in [0, 1) with t_0=0.
// method: "length"      = chord-length
//        "centripetal" = sqrt exponent (Lee 1989)
//        "dynamic"     = per-chord dynamic exponent (Balta et al. 2020)
//        "foley"       = centripetal + deflection-angle correction (Foley & Neilson 1987)
//        "fang"        = centripetal + osculating-circle correction (Fang & Hung 2013)

function _interp_params(points, method="centripetal", closed=false) =
    let(
        raw       = path_segment_lengths(points, closed=closed),
        n         = len(raw),
        total_raw = sum(raw)
    )
    // Degenerate: all points identical (e.g. a surface pole row/column).
    // Return uniform spacing so surface parameter averages stay valid.
    total_raw < 1e-10
      ? (closed
           ? [for (i = [0:1:n-1]) i / n]
           : [for (i = [0:1:n  ]) i / n])
      : assert(min(raw) > 1e-10,
               "nurbs_interp: consecutive duplicate data points detected")
        let(
            dists = method == "centripetal" ? [for (d = raw) sqrt(d)]
                  : method == "dynamic"     ? _dynamic_dists(raw)
                  : method == "foley"       ? _foley_dists(points, closed)
                  : method == "fang"        ? _fang_dists(points, closed)
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
      : [for (j = [1:1:num_internal])
             sum([for (i = [j :1: j + p - 1]) params[i]]) / p
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
        raw = [for (j = [0:1:n])
                   sum([for (k = [0:1:p-1])
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


// Repair degenerate periodic bar knots: if any span is smaller than
// eps × period, merge it into its neighbor and bisect the resulting
// larger span.  Preserves the knot count (n+1 entries, n spans) and
// the endpoint values bar[0]=0, bar[n]=period.  Recurses until no
// tiny spans remain.

function _fix_tiny_spans(bar_knots, n, eps=1e-6) =
    let(
        T        = bar_knots[n],
        spans    = [for (k = [0:1:n-1]) bar_knots[k+1] - bar_knots[k]],
        min_span = min(spans)
    )
    min_span >= eps * T ? bar_knots
    : let(
        k          = min_index(spans),
        // Remove an interior knot bounding the tiny span.
        // For span 0 (first span), remove knot 1 and absorb into span 1.
        // For span n-1 (last span), remove knot n-1 and absorb into span n-2.
        // Otherwise, remove knot k+1 and absorb into the merged span at k.
        remove_idx = k == 0     ? 1
                   : k == n - 1 ? n - 1
                   :              k + 1,
        merged     = [for (i = [0:1:n]) if (i != remove_idx) bar_knots[i]],
        absorb_k   = k == 0 ? 0 : k - 1,
        // Bisect the absorbing span to restore the knot count.
        mid        = (merged[absorb_k] + merged[absorb_k + 1]) / 2,
        fixed      = [for (i = [0:1:n-1])   // n entries in merged
                         each (i == absorb_k ? [merged[i], mid] : [merged[i]])]
    )
    _fix_tiny_spans(fixed, n, eps);


// Insert extra knots into a base bar_knots vector, one per
// constraint parameter.  For each constraint, finds the span
// containing its parameter value and inserts at the span midpoint.
// When multiple constraints compete, the one whose containing span
// is largest is processed first — this avoids splitting a small
// span when a larger one is available.  Each insertion updates the
// knot vector before the next constraint is processed.
//
// bar_knots:       base bar_knots from periodic or interior averaging.
// constraint_ts:   list of parameter values identifying which span
//                  to split.  For closed: raw params in [0,1).
//                  For clamped: params in [0,1].
//
// Returns the augmented bar_knots with len(constraint_ts) extra entries.

function _insert_constraint_knots(bar_knots, constraint_ts) =
    len(constraint_ts) == 0 ? bar_knots
    : let(
        n     = len(bar_knots),
        // For each constraint, find its containing span and that span's width.
        spans = [for (ci = [0:1:len(constraint_ts)-1])
            let(
                t   = constraint_ts[ci],
                pos = [for (i = [0:1:n-2])
                           if (bar_knots[i] <= t && t < bar_knots[i+1]) i],
                idx = len(pos) > 0 ? pos[0] : n - 2,
                w   = bar_knots[idx+1] - bar_knots[idx]
            )
            [ci, idx, w]
        ],
        // Pick the constraint whose span is largest.
        best  = max_index([for (s = spans) s[2]]),
        ci    = spans[best][0],
        idx   = spans[best][1],
        mid   = (bar_knots[idx] + bar_knots[idx+1]) / 2,
        new_knots = [each [for (i = [0:1:idx]) bar_knots[i]], mid,
                     each [for (i = [idx+1:1:n-1]) bar_knots[i]]],
        remaining = [for (i = [0:1:len(constraint_ts)-1])
                         if (i != ci) constraint_ts[i]]
    )
    _insert_constraint_knots(new_knots, remaining);


// Return k parameter values, each at the midpoint of one of the k
// widest spans in bar_knots.  Used to target extra knot insertions
// and smoothness rows at the most under-resolved regions.
//
// When all k picks come from equal-width spans (the common case for
// uniformly-parameterized closed curves), spans are chosen at centred-
// stratified indices floor((2g+1)*n/(2*k_eff)) % n for g=0..k_eff-1.
// This places each pick at the centre of its equal-width quantile
// rather than at the quantile boundary.  For n=18, k=4 the picks
// are spans 2, 6, 11, 15 instead of 0, 4, 9, 13.
//
// Centering is essential for closed curves: _extend_knot_vector wraps
// span widths across the seam (span n-1 into the pre-region, span 0
// into the post-region).  If an extra knot is inserted in span 0, the
// span width at the start of aug_bar differs from the width at the end,
// making the basis functions slightly asymmetric at the seam and
// causing a visible fold in the null-space solution.  Centering keeps
// both boundary spans at their original (uniform) width.
// When the k widest spans are not all equal, the standard widest-first
// selection is used (knot insertion targets the most under-resolved
// regions regardless of position).

function _widest_span_params(bar_knots, k) =
    let(
        n      = len(bar_knots) - 1,
        k_eff  = min(k, n),
        _echo  = k > n ? echo(str("nurbs_interp: extra_pts=", k,
                                  " exceeds the number of available knot spans (", n,
                                  "); reduced to ", n, ".")) : 0,
        spans   = [for (i = [0:1:n-1]) bar_knots[i+1] - bar_knots[i]],
        w_max   = max(spans),
        // Indices of spans at the maximum width (within floating-point tolerance).
        // Stratification picks only from these so that constraint-narrowed spans
        // (e.g. from _insert_constraint_knots) are never accidentally chosen.
        eq_idxs = [for (i = [0:1:n-1]) if (abs(spans[i] - w_max) < 1e-10 * w_max) i],
        n_eq    = len(eq_idxs)
    )
    // If all k_eff picks come from equal-width spans, use centred stratification
    // over eq_idxs so that constraint-narrowed spans are never selected.
    n_eq >= k_eff
    ? [for (g = [0:1:k_eff-1])
           let(i = eq_idxs[floor((2 * g + 1) * n_eq / (2 * k_eff))])
           (bar_knots[i] + bar_knots[i+1]) / 2
      ]
    // Otherwise use widest-first selection (non-uniform spans).
    : let(
        sorted = sort([for (i = [0:1:n-1]) [spans[i], i]]),
        top_k  = [for (i = [n-1:-1:n-k_eff]) sorted[i]]
      )
      [for (s = top_k) (bar_knots[s[1]] + bar_knots[s[1]+1]) / 2];


// Find knot spans containing multiple data parameters and return
// splitting midpoints.  Two data points in the same span cause a
// rank-deficient collocation matrix; inserting a knot between them
// restores full rank.
//
// bar_knots: sorted knot vector with n_spans+1 entries.
// params:    sorted or unsorted data parameter values.
//
// Returns a list of splitting parameter values — one midpoint between
// each consecutive pair of params that share a span.

function _span_split_params(bar_knots, params) =
    let(
        n_spans = len(bar_knots) - 1,
        sorted  = sort(params),
        n_p     = len(sorted),
        // For each sorted param, find its span index.
        span_of = [for (t = sorted)
            let(pos = [for (i = [0:1:n_spans-1])
                           if (t >= bar_knots[i] &&
                               (i < n_spans-1 ? t < bar_knots[i+1]
                                              : t <= bar_knots[i+1])) i])
            len(pos) > 0 ? pos[0] : n_spans - 1
        ]
    )
    // Midpoints between consecutive sorted params sharing a span.
    [for (i = [0:1:n_p-2])
        if (span_of[i] == span_of[i+1])
        (sorted[i] + sorted[i+1]) / 2
    ];


// Build one row of the L^T*L matrix for control-polygon regularization.
// order=1: first-difference penalty (penalizes polygon length/variation).
// order=2: second-difference penalty (penalizes polygon bending).
// periodic=true wraps the differences around for closed curves.
//
// For clamped (non-periodic):
//   order=1 L^T*L: tridiag [1,-1,0..] [-1,2,-1,0..] .. [0..,-1,1]
//   order=2 L^T*L: pentadiag boundary-adapted
// For closed (periodic):
//   order=1 L^T*L: circulant [2,-1,0..0,-1]
//   order=2 L^T*L: circulant [6,-4,1,0..0,1,-4]

function _ltl_row(M, i, order, periodic=false) =
    periodic
    ? (order == 1
       ? [for (j = [0:1:M-1])
              j == i ? 2
            : j == (i+1)%M || j == (i-1+M)%M ? -1
            : 0]
       : // order == 2
         [for (j = [0:1:M-1])
              j == i ? 6
            : j == (i+1)%M || j == (i-1+M)%M ? -4
            : j == (i+2)%M || j == (i-2+M)%M ? 1
            : 0])
    : // clamped (non-periodic)
      (order == 1
       ? [for (j = [0:1:M-1])
              j == i ? (i == 0 || i == M-1 ? 1 : 2)
            : (j == i+1 || j == i-1) ? -1
            : 0]
       : // order == 2, L is (M-2)×M second-difference matrix.
         // (L^T L)[i][j] = sum_{r=0}^{M-3} L[r][i]*L[r][j]
         // where L[r][c] = (c==r ? 1 : c==r+1 ? -2 : c==r+2 ? 1 : 0).
         // Nonzero only when |i-j| <= 2.
         [for (j = [0:1:M-1])
              abs(i-j) > 2 ? 0
            : i == j
              ? (i <= M-3 ? 1 : 0)            // r=i: 1²
              + (i >= 1 && i <= M-2 ? 4 : 0)  // r=i-1: (-2)²
              + (i >= 2 ? 1 : 0)              // r=i-2: 1²
            : abs(i-j) == 1
              ? let(lo = min(i,j))
                (lo <= M-3 ? -2 : 0)            // r=lo: (1)(-2)
              + (lo >= 1 && lo <= M-2 ? -2 : 0) // r=lo-1: (-2)(1)
            : // abs(i-j) == 2
              (min(i,j) <= M-3 ? 1 : 0)         // r=min: (1)(1)
         ]);


// Solve the constrained optimization  min P^T·R·P  s.t. A·P = rhs
// via null-space method.
//
// R   = M×M regularization matrix (positive semidefinite).
// A   = N×M constraint matrix (interpolation + derivative + curvature).
// rhs = N×dim right-hand side (data points + constraint vectors).
//
// Algorithm:
//   1. Step A — minimum-norm particular solution x_p satisfying A·x_p = rhs
//      exactly, via BOSL2 linear_solve() (handles underdetermined systems).
//   2. Step B — minimize x^T·R·x in the null space of A (if M > N):
//      Q2 = null_space(A) basis vectors (returned as rows by BOSL2)
//      H  = Q2^T · R_pd · Q2   (n_ns × n_ns, SPD)
//      Solve H · z = -Q2^T · R_pd · x_p  via Cholesky
//      P  = x_p + Q2 · z
//
// Returns list of M control points, or undef on rank-deficient A.

function _nullspace_solve(R, A, rhs, eps=1e-6) =
    let(
        M      = len(R),
        N_rows = len(A),
        // Step A: minimum-norm particular solution via BOSL2.
        // linear_solve handles underdetermined (M > N_rows) systems
        // by returning the minimum-norm solution via QR of A^T.
        x_p    = linear_solve(A, rhs)
    )
    x_p == [] ? undef
    : M == N_rows ? x_p    // Square: unique solution, no null space.
    : let(
        // Step B: minimize x^T·R·x in the null space.
        // null_space() returns null-space vectors as rows.
        ns   = null_space(A),
        n_ns = len(ns)
    )
    n_ns == 0 ? x_p       // Full rank despite M > N; no null space.
    : let(
        Q2   = transpose(ns),   // M × n_ns (columns are basis vectors)
        // Regularize R for strict positive-definiteness.
        R_pd = [for (i = [0:1:M-1])
                    [for (j = [0:1:M-1])
                        R[i][j] + (i == j ? eps : 0)]],
        // H = Q2^T · R_pd · Q2  (n_ns × n_ns, SPD)
        // Symmetrize to counteract floating-point round-off.
        RQ2  = R_pd * Q2,
        H_raw = transpose(Q2) * RQ2,
        H    = (H_raw + transpose(H_raw)) / 2,
        // g = Q2^T · R_pd · x_p   (n_ns × dim)
        g    = transpose(Q2) * (R_pd * x_p),
        // Solve H · z = -g  (H is SPD → Cholesky is fastest)
        z    = linear_solve(H, -g, method="cholesky")
    )
    // If H solve fails (degenerate), x_p alone still satisfies constraints.
    z == [] ? x_p
    : x_p + Q2 * z;


// Gauss-Legendre quadrature nodes and weights on [-1,1].
// Returns [[nodes], [weights]] for n-point rule (n = 2..5).
// Exact for polynomials up to degree 2n-1.

function _gauss_legendre(n) =
    n == 2 ? [[-0.5773502691896258, 0.5773502691896258],
              [1.0, 1.0]]
  : n == 3 ? [[-0.7745966692414834, 0.0, 0.7745966692414834],
              [0.5555555555555556, 0.8888888888888888, 0.5555555555555556]]
  : n == 4 ? [[-0.8611363115940526, -0.3399810435848563,
                0.3399810435848563,  0.8611363115940526],
              [0.3478548451374538, 0.6521451548625461,
               0.6521451548625461, 0.3478548451374538]]
  : // n >= 5
    [[-0.9061798459386640, -0.5384693101056831, 0.0,
       0.5384693101056831,  0.9061798459386640],
     [0.2369268850561891, 0.4786286704993665, 0.5688888888888889,
      0.4786286704993665, 0.2369268850561891]];


// Bending-energy regularization matrix R for the null-space solver.
// R[j][k] = ∫ B''_j(t) B''_k(t) dt  (integrated squared second derivative).
// For clamped: B_j = N_{j,p}, integrated over full domain.
// For closed/periodic: B_j = N_j + (j<p ? N_{j+M} : 0), integrated over
// one period [U[p], U[M+p]].
// Uses Gauss-Legendre quadrature with max(2, p-1) points per knot span
// (exact for p <= 6).

function _bending_energy_matrix(M, p, U_full, periodic=false) =
    let(
        n_gauss  = max(2, p - 1),
        gl       = _gauss_legendre(n_gauss),
        gl_nodes = gl[0],
        gl_wts   = gl[1],
        n_knots  = len(U_full),
        span_lo  = periodic ? p : 0,
        span_hi  = periodic ? M + p - 1 : n_knots - 2,

        // Quadrature points: [parameter_value, scaled_weight]
        quad_pts = [for (i = [span_lo:1:span_hi])
                        if (U_full[i+1] - U_full[i] > 1e-15)
                        let(a = U_full[i], b = U_full[i+1],
                            hw = (b - a) / 2, mid = (a + b) / 2)
                        for (g = [0:1:n_gauss-1])
                        [mid + hw * gl_nodes[g], gl_wts[g] * hw]
                   ],

        // Precompute all M (aliased) second derivatives at each quad point.
        d2_at = [for (q = quad_pts)
                    let(t = q[0])
                    [for (j = [0:1:M-1])
                        periodic
                        ? _d2nip(j, p, t, U_full)
                          + (j < p ? _d2nip(j + M, p, t, U_full) : 0)
                        : _d2nip(j, p, t, U_full)
                    ]
                ],
        nq = len(quad_pts)
    )
    // Assemble R[j][k] = sum_q  w_q * d2[q][j] * d2[q][k]
    [for (j = [0:1:M-1])
        [for (k = [0:1:M-1])
            sum([for (q = [0:1:nq-1])
                quad_pts[q][1] * d2_at[q][j] * d2_at[q][k]
            ])
        ]
    ];


// Full periodic knot vector for "closed" type evaluation.
// Uses BOSL2's _extend_knot_vector() to build the n+2p+1 entry knot vector
// that nurbs_curve() constructs internally for closed-type curves.
// Active evaluation domain: [U[p], U[n+p]].

function _full_closed_knots(bar_knots, n, p) =
    _extend_knot_vector(bar_knots, 0, n + 2*p + 1);


// =====================================================================
// SECTION: Collocation Matrices
// =====================================================================

// Standard collocation matrix for clamped type.

function _collocation_matrix(params, n, p, U) =
    [for (k = [0:1:n])
        [for (j = [0:1:n])
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
    [for (k = [0:1:n-1])
        [for (j = [0:1:n-1])
            _nip(j, p, params[k], U_periodic)
          + (j < p ? _nip(j + n, p, params[k], U_periodic) : 0)
        ]
    ];


// =====================================================================
// SECTION: Degree Elevation
// =====================================================================

// Greville abscissae for B-spline basis of degree p with full knot
// vector U.  Returns n+1 values where n = len(U) - p - 2.  Each g_i
// is the average of knots U[i+1] .. U[i+p].  For a clamped knot
// vector, g_0 = 0 and g_n = 1.  These are optimal collocation sites
// for the B-spline space and automatically satisfy the Schoenberg-
// Whitney condition for non-singular collocation.

function _greville(U, p) =
    let(n = len(U) - p - 2)
    [for (i = [0:1:n])
        sum([for (j = [i+1:1:i+p]) U[j]]) / p
    ];


// Increment the multiplicity of every distinct value in a knot vector
// by 1.  Walk the vector; at the end of each run of equal values emit
// one extra copy.  Equivalent to the new_interior construction in
// _elevate_once_clamped but applied to the complete (full) knot vector.
// Used by _elevate_once_open.

function _increment_knot_mults(U) =
    [for (i = [0:1:len(U)-1]) each
        [U[i],
         if (i == len(U)-1 || abs(U[i+1] - U[i]) > 1e-14) U[i]]
    ];


// Single degree elevation of a clamped B-spline via exact collocation.
//
// The elevated curve lies in the degree-(p+1) B-spline space whose
// knot vector has each distinct knot's multiplicity incremented by 1.
// Evaluating the original curve at the Greville abscissae of the new
// basis and solving the collocation system recovers the exact elevated
// control points (since the new space contains the original curve).
//
// Input:  ctrl    = control points (any dimension >= 1)
//         p       = current degree (>= 1)
//         xknots  = BOSL2-format knot vector [k0, interior..., km]
//                   (endpoints need not be 0 and 1)
// Output: [new_ctrl, new_xknots, p+1]

function _elevate_once_clamped(ctrl, p, xknots) =
    let(
        k0    = xknots[0],
        km    = last(xknots),
        // Full old knot vector: prepend p copies of k0, append p copies of km.
        U_old = concat(repeat(k0, p), xknots, repeat(km, p)),
        n_old = len(ctrl) - 1,
        dim   = len(ctrl[0]),

        // Interior knots from xknots (strip leading k0 and trailing km).
        interior = len(xknots) <= 2 ? []
                 : [for (i = [1:1:len(xknots)-2]) xknots[i]],

        // Each distinct interior knot value gets one extra copy
        // (multiplicity + 1).  Walk the sorted list; at the end of
        // each group of identical values, emit one additional copy.
        new_interior = len(interior) == 0 ? []
            : [for (i = [0:1:len(interior)-1]) each concat(
                  [interior[i]],
                  (i == len(interior)-1 ||
                   abs(interior[i+1] - interior[i]) > 1e-14)
                  ? [interior[i]]   // end of group: extra copy
                  : []
              )],

        new_xknots = [k0, each new_interior, km],
        p_new      = p + 1,
        U_new      = concat(repeat(k0, p_new), new_xknots, repeat(km, p_new)),
        n_new      = len(U_new) - p_new - 2,

        // Greville abscissae of the new basis.
        grev = _greville(U_new, p_new),

        // Evaluate original B-spline at each Greville abscissa.
        C_vals = [for (u = grev)
            let(row = [for (j = [0:1:n_old]) _nip(j, p, u, U_old)])
            [for (d = [0:1:dim-1])
                sum([for (j = [0:1:n_old]) row[j] * ctrl[j][d]])]
        ],

        // Collocation matrix of the new basis at the Greville abscissae.
        A = [for (k = [0:1:n_new])
            [for (i = [0:1:n_new]) _nip(i, p_new, grev[k], U_new)]
        ],

        // Solve for new control points.
        Q = linear_solve(A, C_vals)
    )
    assert(Q != [],
           "nurbs_elevate_degree: singular collocation system (should not happen)")
    [Q, new_xknots, p_new];


// Single degree elevation of an open B-spline via exact collocation.
//
// Works identically to _elevate_once_clamped but operates on the full
// open knot vector U (length n+p+2) rather than the BOSL2 xknots
// format.  _increment_knot_mults doubles every distinct value in U to
// produce U_new; the Greville / collocation solve is the same.
//
// Input:  ctrl  = control points
//         p     = current degree
//         knots = full open knot vector (length len(ctrl)+p+1)
// Output: [new_ctrl, U_new, p+1]
//         U_new is the new full open knot vector.

function _elevate_once_open(ctrl, p, knots) =
    let(
        U_old = knots,
        n_old = len(ctrl) - 1,
        dim   = len(ctrl[0]),
        p_new = p + 1,
        U_new = _increment_knot_mults(U_old),
        n_new = len(U_new) - p_new - 2,
        grev  = _greville(U_new, p_new),
        C_vals = [for (u = grev)
            let(row = [for (j = [0:1:n_old]) _nip(j, p, u, U_old)])
            [for (d = [0:1:dim-1])
                sum([for (j = [0:1:n_old]) row[j] * ctrl[j][d]])]
        ],
        A = [for (k = [0:1:n_new])
            [for (i = [0:1:n_new]) _nip(i, p_new, grev[k], U_new)]
        ],
        Q = linear_solve(A, C_vals)
    )
    assert(Q != [],
           "nurbs_elevate_degree: singular collocation (open, should not happen)")
    [Q, U_new, p_new];


// Single degree elevation of a closed (periodic) B-spline via exact collocation.
//
// Algorithm:
//   1. Reconstruct the full periodic knot vector U_old from bar_knots (+ curr_mult).
//   2. Extract the active section U_old[p..n+p] and increment the multiplicity of
//      every INTERIOR knot value (strictly between a_old and b_old) by 1.  The
//      active-domain boundary values a_old and b_old remain singly represented.
//   3. Derive the pre-domain for U_new_full by periodicity:
//        pre_new[k] = active_new[n_new - p_new + k] - T   (k = 0..p_new-1)
//   4. bar_knots_new = [pre_new..., active_new[0..n_new-p_new]].
//      _extend_knot_vector(bar_knots_new, 0, n_new+2*p_new+1) then reproduces
//      U_new_full exactly — verified by the periodic gap structure of the pre-domain.
//   5. Collocate at n_new uniform sites in [a_old, b_old) using the periodic
//      basis functions of U_new_full.  All sites lie in the active domain so
//      the original curve can be evaluated directly.  The wrap contributions
//      N_{j+n_new, p_new} activate for sites > U_new[n_new], giving a
//      full-rank collocation matrix.
//
// Input:  ctrl      = n control points (no closing repeat)
//         p         = current degree
//         bar_knots = BOSL2-format closed knot vector
//         curr_mult = per-distinct-value multiplicity (undef → bar_knots already
//                     contains all repetitions; non-undef → expand first)
// Output: [new_ctrl, bar_knots_new, p+1]

function _elevate_once_closed(ctrl, p, bar_knots, curr_mult=undef) =
    let(
        n_old  = len(ctrl),
        dim    = len(ctrl[0]),
        p_new  = p + 1,

        // Expand bar_knots with multiplicities when provided (first call only).
        bar_knots_full =
            is_undef(curr_mult) ? bar_knots
            : [for (i = [0:1:len(curr_mult)-1]) each repeat(bar_knots[i], curr_mult[i])],

        T      = last(bar_knots_full) - bar_knots_full[0],

        // Full periodic knot vector.
        U_old  = _extend_knot_vector(bar_knots_full, 0, n_old + 2*p + 1),
        a_old  = U_old[p],
        b_old  = U_old[n_old + p],

        // Interior active knots: U_old entries strictly between a_old and b_old.
        interior_old = [for (k = [p+1:1:n_old+p-1])
            if (U_old[k] > a_old + 1e-12 && U_old[k] < b_old - 1e-12)
            U_old[k]
        ],

        // Increment each interior knot's multiplicity by 1.
        interior_new = _increment_knot_mults(interior_old),

        // Elevated active section: boundary values stay singly represented.
        active_new = [a_old, each interior_new, b_old],
        n_new      = len(active_new) - 1,

        // Pre-domain (p_new entries): last p_new active values before b_old, minus T.
        // This is the exact periodic wrap-around that makes _extend_knot_vector
        // reproduce U_new_full correctly.
        pre_new = [for (k = [0:1:p_new-1]) active_new[n_new - p_new + k] - T],

        // bar_knots_new = pre_new || active_new[0..n_new-p_new].
        bar_knots_new = [each pre_new,
                         for (k = [0:1:n_new - p_new]) active_new[k]],

        // Full elevated periodic knot vector (BOSL2 extension).
        U_new = _extend_knot_vector(bar_knots_new, 0, n_new + 2*p_new + 1),

        // Uniform collocation sites in [a_old, b_old) — all in the active domain.
        sites = [for (k = [0:1:n_new-1]) a_old + k * T / n_new],

        // Extended control points for original curve evaluation.
        ext_ctrl = [each ctrl, for (k = [0:1:p-1]) ctrl[k]],
        n_ext    = n_old + p - 1,

        // RHS: evaluate original curve at each site.
        C_vals = [for (u = sites)
            let(row = [for (j = [0:1:n_ext]) _nip(j, p, u, U_old)])
            [for (d = [0:1:dim-1])
                sum([for (j = [0:1:n_ext]) row[j] * ext_ctrl[j][d]])]
        ],

        // Periodic collocation matrix: B_{j,p_new}(sites[k]).
        // Wrap term activates for sites > U_new[n_new], giving non-zero entries
        // in the j=0..p_new-1 columns for large-k rows.
        A = [for (k = [0:1:n_new-1])
            [for (j = [0:1:n_new-1])
                let(wrap = j < p_new ? _nip(j + n_new, p_new, sites[k], U_new) : 0)
                _nip(j, p_new, sites[k], U_new) + wrap
            ]
        ],

        Q = linear_solve(A, C_vals)
    )
    assert(Q != [],
           "nurbs_elevate_degree: singular periodic collocation (closed)")
    [Q, bar_knots_new, p_new];


// Function: nurbs_elevate_degree()
// Synopsis: Raises the degree of a NURBS curve while exactly preserving its shape.
// Topics: NURBS Curves
// See Also: nurbs_interp(), nurbs_curve()
//
// Usage:
//   result = nurbs_elevate_degree(control, degree, [knots=], [mult=], [type=], [times=], [weights=]);
//   result = nurbs_elevate_degree(nurbs_param_list, [times=]);
//
// Description:
//   Raises the degree of a B-spline or rational NURBS curve by `times` steps, producing
//   a geometrically identical curve at the higher degree.  The result is a NURBS
//   parameter list that can be passed directly to {{nurbs_curve()}}.
//   .
//   This function works by increasing the knot multiplicity by `times`.  
//   An elevated curve has the same smoothness as the original curve at knots.  A degree 2
//   curve is $C^1$ at its knots and after elevation to degree 3 will still be $C^1$ at its
//   knots, not $C^2$ like a cubic NURBS without duplicated knots.
//   .
//   Knots can be specified the same way as for `{{nurbs_curve()}}`: omit both `knots=`
//   and `mult=` for uniform knots (BOSL2-compatible defaults), give `knots=` alone
//   (interior-format vector for clamped/open, bar_knots for closed; knots need not lie
//   in [0,1]), give `mult=` alone (uniform positions 0..1 with those multiplicities;
//   for clamped, endpoint multiplicities are forced to `degree+1` matching BOSL2), or
//   give both `knots=` and `mult=` (distinct positions with per-knot multiplicities;
//   for clamped endpoint mult is forced to `degree+1`).  For closed curves, `mult=`
//   gives the per-position multiplicity vector (same length as `knots=`); endpoint
//   positions appear once in the periodic knot vector regardless of their mult value.
//   .
//   Instead of providing separate parameters you can give the first argument as a NURBS
//   parameter list `[type, degree, control, knots, mult, weights]`.
//   The return is a list of the same form.
//
// Arguments:
//   control = Control points or a NURBS parameter list
//   degree  = degree of NURBS
//   ---
//   knots   = Knot positions.  With `mult=`: distinct positions (any range).  Without `mult=`: interior-format vector including endpoints.  Default: `undef` (uniform)
//   mult    = Per-knot multiplicity list (same length as `knots`).  If given without `knots=`, uniform positions 0..1 are used; for clamped, endpoint mult is forced to `degree+1`.  Default: `undef` (uniform, mult 1)
//   type    = `"clamped"`, `"closed"`, or `"open"`.  Default: `"clamped"`
//   times   = Number of degree-elevation steps.  `0` returns the input unchanged.  Default: `1`
//   weights = Weight at each control point.  Default: 1

function nurbs_elevate_degree(control, degree, knots=undef,
                              type="clamped", times=1, weights=undef,
                              mult=undef) =
    // Accept a NURBS parameter list as the first argument.
    is_list(control) && in_list(control[0], ["closed","open","clamped"]) ?
         assert(len(control)>=6, "Invalid NURBS parameter list")
         assert(num_defined([degree,mult,weights,knots])==0,
                "Cannot give degree, mult, weights or knots when you provide a NURBS parameter list")
         times == 0 ? control
         : nurbs_elevate_degree(control[2], control[1], control[3],
                                type=control[0], times=times,
                                weights=control[5], mult=control[4])
  : times == 0
    ? [type, degree, control, knots, mult, weights]
    : assert(type == "clamped" || type == "closed" || type == "open",
             str("nurbs_elevate_degree: type must be \"clamped\", \"closed\", or \"open\", got \"", type, "\""))
      assert(is_num(times) && times >= 1,
             "nurbs_elevate_degree: times must be a positive integer")
    assert(is_num(degree) && degree >= 1,
           "nurbs_elevate_degree: degree must be >= 1")
    assert(is_list(control) && len(control) >= 2,
           "nurbs_elevate_degree: need at least 2 control points")
    assert(is_undef(weights) || len(weights) == len(control),
           "nurbs_elevate_degree: weights must have same length as control points")
    assert(is_undef(knots) || is_undef(mult) || len(mult) == len(knots),
           str("nurbs_elevate_degree: mult and knots must have the same length; got len(mult)=",
               is_undef(mult) ? "undef" : len(mult),
               " len(knots)=",
               is_undef(knots) ? "undef" : len(knots)))
    let(
        // Normalize (knots, mult) → internal format for the elevation algorithms.
        //
        //   clamped: xknots = [k0, interior..., km] — one copy each including endpoints.
        //            For clamped, endpoint multiplicities are forced to degree+1 (BOSL2
        //            convention) then stripped, so _elevate_once_clamped always receives
        //            the standard interior-format [k0, k1..kn-1, km].
        //   open:    xknots = full expanded knot vector (all repetitions).
        //   closed:  xknots = bar_knots (distinct positions only).
        //            Per-position multiplicities are tracked separately in closed_mult0
        //            and threaded through _elevate_once_closed.
        //
        // Neither knots nor mult → BOSL2-compatible uniform knots.
        //   clamped → interior format [0, uniform interior..., 1]
        //   open    → full expanded vector (length n+p+2, uniform)
        //   closed  → bar_knots format (length n+1, all distinct)
        //
        // knots only (no mult): pass through unchanged (all types).
        //
        // mult only (no knots): uniform positions 0..1 with given multiplicities.
        //   clamped: endpoint mult forced to degree+1; expand then strip.
        //   open:    full expanded vector.
        //   closed:  return only the distinct uniform positions; mult is separate.
        //
        // knots + mult: explicit distinct positions with per-knot multiplicities.
        //   clamped: endpoint mult forced to degree+1; expand then strip.
        //   open:    full expanded vector.
        //   closed:  return only the knot positions; mult is separate.
        xknots =
            is_undef(knots) && is_undef(mult)
            ? ( type == "clamped" ? lerpn(0, 1, len(control) - degree + 1)
              : type == "open"    ? lerpn(0, 1, len(control) + degree + 1)
              :                     lerpn(0, 1, len(control) + 1) )
            : is_undef(mult) ? knots
            : is_undef(knots)
              ? let(
                    m   = len(mult),
                    // For clamped, force endpoint multiplicities to degree+1 (BOSL2 convention).
                    adj = type == "clamped" && m >= 2
                          ? [degree+1, each [for (i = [1:1:m-2]) mult[i]], degree+1]
                          : mult,
                    pos = [for (i = [0:1:m-1]) m == 1 ? 0 : i / (m - 1)],
                    exp = [for (i = [0:1:m-1]) each repeat(pos[i], adj[i])]
                )
                type == "clamped"
                ? [for (i = [degree : 1 : len(exp) - degree - 1]) exp[i]]
                : type == "closed"
                ? pos   // closed: return distinct positions; mult handled via closed_mult0
                : exp   // open: full expanded
              : let(
                    m   = len(mult),
                    // For clamped, force endpoint multiplicities to degree+1 (BOSL2 convention).
                    adj = type == "clamped" && m >= 2
                          ? [degree+1, each [for (i = [1:1:m-2]) mult[i]], degree+1]
                          : mult,
                    exp = [for (i = [0:1:m-1]) each repeat(knots[i], adj[i])]
                )
                type == "clamped"
                ? [for (i = [degree : 1 : len(exp) - degree - 1]) exp[i]]
                : type == "closed"
                ? knots   // closed: return distinct positions; mult handled via closed_mult0
                : exp     // open: full expanded
    )
    assert(type != "clamped" || len(xknots) >= 2,
           "nurbs_elevate_degree: clamped knots must have at least 2 entries [first,...,last]")
    assert(type != "open" || len(xknots) == len(control) + degree + 1,
           str("nurbs_elevate_degree: open knots must have length len(control)+degree+1 = ",
               len(control) + degree + 1, ", got ", len(xknots)))
    let(
        // For closed type, pass the user's mult= to _elevate_once_closed on the
        // first call so it can build the correct xknots_old (matching BOSL2's
        // internal knot vector for c1).  On recursive calls mult=undef (default),
        // so _elevate_once_closed auto-detects multiplicities from xknots_new
        // (which carries the correct interior mults from the previous elevation).
        closed_mult0 = type != "closed" ? undef : mult,

        elevate_once = type == "clamped" ? function(c, p, k) _elevate_once_clamped(c, p, k)
                     : type == "open"    ? function(c, p, k) _elevate_once_open(c, p, k)
                     :                    function(c, p, k) _elevate_once_closed(c, p, k, closed_mult0)
    )
    is_undef(weights)
    ? // Non-rational B-spline: elevate directly.
      // r = [new_ctrl, new_knots, p_new] for all types.
      // For closed: r[1] = xknots_new (BOSL2-compatible bar_knots).
      //   Recursive call passes xknots_new as bar_knots and mult=undef so that
      //   _elevate_once_closed auto-detects interior mults from xknots_new. ✓
      let(r = elevate_once(control, degree, xknots))
      times == 1
      ? [type, r[2], r[0], r[1], undef, undef]
      : nurbs_elevate_degree(r[0], r[2], r[1], type=type, times=times-1)
    : // Rational NURBS: convert to homogeneous, elevate, extract.
      let(
          dim = len(control[0]),
          homo_ctrl = [for (i = [0:1:len(control)-1])
              [for (d = [0:1:dim-1]) weights[i] * control[i][d],
               weights[i]]
          ],
          r = elevate_once(homo_ctrl, degree, xknots),
          new_w = [for (pt = r[0]) pt[dim]],
          new_ctrl = [for (i = [0:1:len(r[0])-1])
              [for (d = [0:1:dim-1]) r[0][i][d] / new_w[i]]
          ]
      )
      times == 1
      ? [type, r[2], new_ctrl, r[1], undef, new_w]
      : nurbs_elevate_degree(new_ctrl, r[2], r[1],
                             type=type, times=times-1, weights=new_w);


// =====================================================================
// SECTION: Local Rational Quadratic Interpolation (P&T §9.3.3)
// =====================================================================


// =====================================================================
// SECTION: Main Interpolation Function
// =====================================================================

// Function: nurbs_interp()
// Synopsis: Finds a NURBS curve passing through a point list with optional derivative constraints.
// Topics: NURBS Curves, Interpolation
// SynTags: Geom
// See Also: nurbs_curve(), debug_nurbs(), nurbs_interp_curve(), debug_nurbs_interp()
//
// Usage:
//   result = nurbs_interp(points, degree, [method=], [closed=],
//                         [start_deriv=], [end_deriv=],
//                         [curvature=], [start_curvature=], [end_curvature=],
//                         [corners=], [deriv=], [extra_pts=], [smooth=]);
//
// Description:
//   Given a list of data points and a NURBS degree, computes a curve
//   that passes exactly through every data point.  The computed curve always has
//   uniform weights, but irregularly spaced knots, so it is actually a non-uniform B-spline.  
//   Data points may 2D or any higher dimension.
//   Returns a NURBS parameter list of the form
//   `[type, degree, control_points, knots, undef, undef, rotation, u]` that can be
//   passed directly to {{nurbs_curve()}} and other NURBS functions.
//   The 8th element `u` is the parameterization vector: `u[k]` is the NURBS
//   parameter value assigned to `points[k]` during the interpolation solve.
//   .
//   Set `closed=true` to produce a smooth closed loop through all data points.
//   Set `closed=false` (the default) to produce a clamped curve that starts at
//   `points[0]` and ends at the last point.
//   Under some circumstances when you request `closed=true` the return type will be
//   `"clamped"` (e.g. when `corners=` is specified for a closed curve).
//   Choosing `closed=true` is different from duplicating the first point at the end:
//   `closed=true` produces a smooth joint at the closing point, whereas
//   repeating the point with `closed=false` creates a corner.
//   .
//   **Parameterization** (`method=`)
//   .
//   In order to solve the interpolation problem, the algorithm first chooses
//   the NURBS parameter value `u[k]` that will correspond to each `points[k]`. 
//   This parametrization step significantly affects the shape of the output curve, particularly when the
//   data points are not evenly spaced.  The following methods are supported:
//   .
//   - `"length"` — Base parameters values on the chord length, which is distance between the consecutive data points.
//     Best when data points are fairly evenly spaced.  
//   - `"centripetal"` (default) — Base parameters values on the square root of the chord length. (Lee 1989).
//   - `"dynamic"` — like centripetal, but the exponent 0.5 is replaced
//     by a per-chord value chosen based on local spacing variation.  Long chords
//     get a smaller exponent and short chords a larger one, compressing the
//     influence of outliers.  Chord lengths are normalized, which makes the method scale
//     invariant and prevents misbehavior at extreme scales.  Scaling is not given in the original reference. (Balta et al. 2020).
//   - `"foley"` — centripetal base, augmented by corrections at each point that
//     are proportional to the local turn angle.  Sharp bends pull parameter values
//     closer together, which tends to reduce overshoot at corners (Foley & Neilson 1987).
//   - `"fang"` — centripetal base, augmented by a correction based on the radius
//     of the osculating circle at each point.  Said to handles mixed straight-and-curved
//     segments particularly well.  This method is NOT scale invariant, so results will
//     change if you scale your input data. (Fang & Hung 2013).
//   .
//   The other required input to the interpolation is the location of the knots.
//   We place knots using a moving average `degree` consecutive parameter values, which links
//   the knots to the local parameter spacing.  A consequence of this process for selection
//   of the parameters and knot locations is that even if your input data has symmetry it is
//   likely that the symmetry will be broken in the output.  For closed curves, another
//   consequence is that the resulting curve will depend on which point is chosen as the
//   starting point for the interpolation.  The algorithm chooses a starting point 
//   that is expected to provide the best behaved interpolation curve.  
//   If your curve does not
//   behave as desired you may be able to adjust it by imposing additional constraints.  
//   .
//   **Derivative constraints** (`deriv=`, `start_deriv=`, `end_deriv=`)
//   .
//   `deriv[k]` specifies the tangent direction (and speed) the curve must have
//   as it passes through `points[k]`.  The vector is scaled by the
//   total chord length, so a unit vector gives natural speed and is a good starting point.
//   The speed has a big effect on the shape of the curve, so if the local shape is
//   not what you desired you should try increasing it, which will make the curve around
//   the point flatter or decrease it, which will make the curve more pointy. 
//   Set `deriv[k] = undef` to leave point `k` unconstrained.  
//   If you only want to set the derivative at the ends of a "clamped" curve you can use
//   `start_deriv=` and `end_deriv=`, which set 
//   `deriv[0]` and `last(deriv)` with the need to provide a list of undefs for all the interior points. 
//   .
//   **Curvature constraints** (`curvature=`, `start_curvature=`, `end_curvature=`)
//   .
//   The curvature at a point measures how tightly a curve bends.
//   When a point has curvature $\kappa$ then a circle with radius $1/\kappa$ 
//   locally matches the curve at that point so both its first and second derivatives agree.
//   This matched circle is called the osculating circle.  When you set `curvature[k]` this
//   constrains the curvature at `points[k]`.  Every curvature-constrained point **must** also have a derivative constraint
//   at the same index.  Curvature constraints require a degree of at least 2.  
//   .
//   In general curvature constraints require the curvature **vector**, which
//   points in the direction of the osculating circle and has length equal to the curvature. 
//   The curvature vector must be orthogonal to the tangent vector at the point;
//   when you specify a curvature vector any component parallel to the tangent is removed.
//   The magnitude of the curvature is taken as the magnitude of your original input vector,
//   even if subtracting the tangent component changes its length.  
//   For 2D curves you can also provide curvature as a scalar, with the sign indicating direction. 
//   (positive = left/CCW,  negative = right/CW).
//   .
//   As for derivatives you can specify the curvature at the ends of "clamped" curves using
//   `start_curvature=` and `end_curvature=`, which specify `curvature[0]`
//   and `last(curvature)` without the need to create undefs for all the interior points. 
//   .
//   **Corners** (`corners=`)
//   .
//   `corners=` is a list of interior point indices where the curve has
//   a corner, a discontinuity in the derivative.  You can also specify a corner
//   at point `k` by setting `deriv[k]=NAN`.  When you request corners, the
//   algorithm chops up the input data into separate clamped curves that run from corner
//   to corner.  In the case of a "closed" curve this results in a "clamped" output.
//   If you place corners close together, the effective degree of the short segment
//   in between the corners may be reduced.  These curve sections are assembled into a single
//   NURBS so this process is transparent to the user.  For the "closed" case
//   the curve will start at one of your corner points.  A limitation is that you cannot control
//   the dervatives of the two segments that meet at a corner.  If you need to do this you
//   should construct your own sequence of clamped interpolations.  
//   .
//   **Extra control points** (`extra_pts=`, `smooth=`)
//   .
//   By default, the solver uses exactly as many control points as are needed to
//   satisfy the interpolation and constraint conditions, which gives a unique
//   solution.  This unique solution may be badly behaved, with undesirable oscillations.
//   You can improve the behavior by requesting extra points.  
//   Specifying `extra_pts=N` inserts `N` additional knots, making the
//   system underdetermined: infinitely many curves pass through the data points and satisfy 
//   the constraints.  The solver picks the one that satisfies
//   a smoothness criterion specified by `smooth=`:
//   .
//   - `smooth=1` — minimises the sum of squared differences between consecutive
//     control points.  This tends to keep the control polygon short and reduces
//     large-scale variation in the curve.
//   - `smooth=2` — minimises the sum of squared second differences of the control
//     points.  This penalises bending in the control polygon, generally producing
//     a fairer, less wiggly curve than `smooth=1`.
//   - `smooth=3` (default) — minimises the integrated squared second derivative
//     $\int \|\mathbf{C}''(t)\|^2 \, dt$, often called the *bending energy* of
//     the curve.  Unlike `smooth=2`, which only looks at the control polygon,
//     this criterion acts directly on the curve shape and is the most
//     mathematically principled choice for smooth interpolation.  Requires
//     `degree >= 2`.
//   .
//   The number of extra control points cannot exceed the number of knot spans.
//   If you request too many, the number is capped and a warning is displayed.
//   With `corners=`, the curve is split into independent clamped segments and 
//   the extra points are distributed across eligible segments proportionally
//   to their control-point count, rounding up, so the total may
//   exceed the requested number but will never be less.  A segment is eligible when
//   its effective degree is 3 or higher, or when it is degree 2 with `smooth=1`.
//   .
//   **Starting Point for closed curves**
//   .
//   Closed curves may not start at `points[0]`.  The rotation applied is
//   returned as `result[6]` (an integer index).  The parameterization `result[7]`
//   is always rotated so that `result[7][k]` corresponds to `points[k]`.
//
// Arguments:
//   points = List of data points to interpolate (2D or any higher dimension).
//   degree = Degree of the NURBS.  Degree 3 (cubic) is the most common choice.
//   ---
//   method    = Parameterization method: `"length"`, `"centripetal"`, `"dynamic"`, `"foley"`, or `"fang"`. Default: `"centripetal"`
//   closed    = If true, interpolate as a smooth closed loop; if false, interpolate as a clamped (open-ended) curve.  Default: `false`
//   start_deriv    = Tangent vector at the first point.  Clamped only.  Default: `undef`
//   end_deriv      = Tangent vector at the last point.  Clamped only.  Default: `undef`
//   deriv     = List of tangent vector constraints for every point, NAN at corners or undef at unconstrained points.  Cannot be combined with `start_deriv=`/`end_deriv=`.  Default: `undef`
//   start_curvature = Curvature at first point.  Requires `start_deriv=` or `deriv[0]`.  Clamped only.  Default: `undef`
//   end_curvature   = Curvature at last point.  Requires `end_deriv=` or `last(deriv)`.  Clamped only.  Default: `undef`
//   curvature = List of curvature constraints for every point, or undef at unconstrained points.  Each defined entry must be paired with a defined `deriv` entry at the same index.  Cannot be combined with `start_curvature=`/`end_curvature=`.  Default: `undef`
//   corners   = List of interior point indices where corners are permitted.  Equivalent to `deriv[k]=NAN`.  Default: `undef`
//   extra_pts = Number of extra control points to add to provide additional freedom to control undesirable oscillations.  Default: `0`
//   smooth    = Smoothness criterion used with extra control points.  Set to 1 (minimize control-polygon length), 2 (minimize control-polygon bending) or 3 (minimize curve bending energy).   Default: `3`

function nurbs_interp(points, degree, method="centripetal", closed=false,
                      deriv=undef, start_deriv=undef, end_deriv=undef,
                      curvature=undef, start_curvature=undef, end_curvature=undef,
                      corners=undef, extra_pts=0, smooth=3) =
    assert(is_path(points, undef) && len(points) >= 2,
           "nurbs_interp: points must be a path (list of same-dimension vectors) with at least 2 points")
    assert(is_num(degree) && degree >= 1,
           "nurbs_interp: degree must be >= 1")
    assert(method == "length" || method == "centripetal" || method == "dynamic"
               || method == "foley" || method == "fang",
           str("nurbs_interp: method must be \"length\", \"centripetal\", \"dynamic\", \"foley\", or \"fang\", got \"", method, "\""))
    assert(is_undef(deriv) || (is_undef(start_deriv) && is_undef(end_deriv)),
           "nurbs_interp: use deriv= OR start_deriv=/end_deriv=, not both")
    assert(!closed || (is_undef(start_deriv) && is_undef(end_deriv)),
           "nurbs_interp: start_deriv/end_deriv only supported for closed=false")
    assert(is_undef(deriv) || len(deriv) == len(points),
           str("nurbs_interp: deriv= must have same length as points (",
               len(points), " points, ", is_undef(deriv) ? 0 : len(deriv), " deriv)"))
    assert(is_undef(curvature) || (is_undef(start_curvature) && is_undef(end_curvature)),
           "nurbs_interp: use curvature= OR start_curvature=/end_curvature=, not both")
    assert(!closed || (is_undef(start_curvature) && is_undef(end_curvature)),
           "nurbs_interp: start_curvature=/end_curvature= only supported for closed=false")
    assert(is_undef(curvature) || len(curvature) == len(points),
           str("nurbs_interp: curvature= must have same length as points (",
               len(points), " points, ", is_undef(curvature) ? 0 : len(curvature), " curvature)"))
    assert(is_undef(corners) || (
               !closed
                 ? (min(corners) >= 1 && max(corners) <= len(points)-2)
                 : (min(corners) >= 0 && max(corners) <= len(points)-1)),
           str("nurbs_interp: corners= indices must be ",
               !closed ? str("interior (1..", len(points)-2, ")")
                       : str("valid point indices (0..", len(points)-1, ")")))
    assert(is_num(extra_pts) && extra_pts >= 0 && extra_pts == floor(extra_pts),
           str("nurbs_interp: extra_pts must be a non-negative integer, got ", extra_pts))
    assert(extra_pts == 0 || degree >= 2,
           "nurbs_interp: extra_pts requires degree >= 2")
    assert(smooth == 1 || smooth == 2 || smooth == 3,
           str("nurbs_interp: smooth must be 1, 2, or 3, got ", smooth))
    assert(smooth != 3 || degree >= 2,
           "nurbs_interp: smooth=3 (bending energy) requires degree >= 2")
    let(
        type     = closed ? "closed" : "clamped",
        raw = type == "clamped"
            ? _nurbs_interp_clamped(points, degree, method,
                                     deriv, start_deriv, end_deriv,
                                     curvature, start_curvature, end_curvature,
                                     corners, extra_pts, smooth)
            : _nurbs_interp_closed(points, degree, method, deriv, curvature,
                                    corners, extra_pts, smooth),
        eff_type = is_string(raw[3]) ? raw[3] : type,
        rot      = raw[2],
        u        = type == "closed" && !is_string(raw[3])
                   ? list_rotate(
                         _interp_params(list_rotate(points, rot), method, closed=true),
                         -rot)
                   : _interp_params(points, method)
    )
    [eff_type, degree, raw[0], raw[1], undef, undef, rot, u];


// ---------- CLAMPED interpolation ----------
//
// start_deriv=/end_deriv= and start_curvature=/end_curvature= are convenience shorthands.
// They are merged into eff_der / eff_curv lists here so that all
// constrained cases flow through a single solver
// (_nurbs_interp_clamped_constrained).

function _nurbs_interp_clamped(points, degree, method,
                                deriv, start_deriv, end_deriv,
                                curvature, start_curvature, end_curvature,
                                corners, extra_pts=0, smooth=3) =
    let(n = len(points) - 1, p = degree, dim = len(points[0]))
    assert(n >= p,
           str("nurbs_interp (clamped): need at least ", p+1,
               " points for degree ", p, ", got ", n+1))
    let(
        eff_der  = _merge_deriv_list(n, deriv, dim=dim, start_deriv=start_deriv, end_deriv=end_deriv),
        eff_curv = _merge_curv_list(n, curvature, dim=dim, start_curvature=start_curvature, end_curvature=end_curvature),

        // C0 corner joints from NaN entries in eff_der and/or corners= list.
        // Must be interior points; cannot coincide with curvature constraints.
        nan_corners    = is_undef(eff_der) ? []
                       : [for (k = [0:1:n]) if (is_nan(eff_der[k])) k],
        explicit_corners = default(corners, []),
        corner_idxs    = deduplicate(sort(concat(nan_corners, explicit_corners))),
        has_corners    = len(corner_idxs) > 0,
        bad_corner_end = [for (k = corner_idxs) if (k == 0 || k == n) k],
        bad_corner_curv = is_undef(eff_curv) ? []
                        : [for (k = corner_idxs) if (!is_undef(eff_curv[k])) k],
        // Explicit corners= entries must not also carry a derivative constraint.
        // (NaN-in-deriv corners are fine — they ARE the corner syntax.)
        bad_corner_der  = is_undef(eff_der) ? []
                        : [for (k = explicit_corners)
                               if (!is_undef(eff_der[k]) && !is_nan(eff_der[k])) k],

        // Exclude NaN corner markers from the derivative-constraint count.
        has_any_der  = !is_undef(eff_der) &&
                       len([for (k = [0:1:n])
                                if (!is_undef(eff_der[k]) && !is_nan(eff_der[k])) k]) > 0,
        has_any_curv = !is_undef(eff_curv) &&
                       len([for (k = [0:1:n]) if (!is_undef(eff_curv[k])) k]) > 0,

        // Every curvature-constrained point must also have a derivative
        // constraint; the derivative direction defines the curve's tangent
        // and is required to orient the curvature normal.
        bad_curv_pts = is_undef(eff_curv) ? [] :
            [for (k = [0:1:n])
                if (!is_undef(eff_curv[k]) &&
                    (is_undef(eff_der) || is_undef(eff_der[k])))
                k]
    )
    assert(bad_corner_end == [],
           str("nurbs_interp: corner cannot be at the first or last point: ", bad_corner_end))
    assert(bad_corner_curv == [],
           str("nurbs_interp: curvature constraint cannot coincide with a corner at: ", bad_corner_curv))
    assert(bad_corner_der == [],
           str("nurbs_interp: derivative constraint cannot coincide with a corner at: ", bad_corner_der))
    assert(bad_curv_pts == [],
           str("nurbs_interp: curvature constraint requires a derivative constraint ",
               "at the same point(s): ", bad_curv_pts))
    has_corners
      ? _nurbs_interp_clamped_corners(points, p, method, eff_der, eff_curv, corner_idxs,
                                       extra_pts=extra_pts, smooth=smooth)
      : (has_any_der || has_any_curv || extra_pts > 0)
        ? _nurbs_interp_clamped_constrained(points, p, method, eff_der, eff_curv, extra_pts, smooth)
        : _nurbs_interp_clamped_basic(points, p, method, smooth);


// Basic clamped interpolation (no derivatives).
// n+1 points -> n+1 control points.

function _nurbs_interp_clamped_basic(points, p, method, smooth=3) =
    let(
        n       = len(points) - 1,
        M       = n + 1,
        dim     = len(points[0]),
        params  = _interp_params(points, method),
        int_kn  = _avg_knots_interior(params, p),
        U_full  = _full_clamped_knots(int_kn, p),
        N_mat   = _collocation_matrix(params, n, p, U_full),
        control = linear_solve(N_mat, points),
        knots   = [0, each int_kn, 1]
    )
    assert(control != [],
           "nurbs_interp (clamped): singular collocation matrix")
    [control, knots, 0];


// Assemble independently-solved clamped corner segments into one B-spline.
//
// All segments must be degree p.  Returns [ctrl, xknots, 0] — the standard
// non-segmented result format that callers can pass directly to nurbs_curve /
// debug_nurbs with type="clamped".
//
// BOSL2 clamped knot convention: nurbs_curve() takes xknots of length
//   len(control) - degree + 1
// and internally prepends (degree) zeros and appends (degree) ones to form
// the full clamped knot vector.  For a C0 corner at global parameter s_c,
// s_c must appear exactly p times in xknots (giving multiplicity p in the
// full vector = C^0 continuity for degree p).
//
// Segment local knots seg[1] = [0, int_kn..., 1] are remapped to the
// segment's global parameter interval [s_a, s_b] using
//   k_global = s_a + (s_b - s_a) * k_local
// which is consistent with any chord-proportional parameterization.

function _combine_corner_segs(segments, params, corner_idxs, p) =
    let(
        n_segs  = len(segments),
        // Global parameter at each corner junction.
        cpar    = [for (c = corner_idxs) params[c]],
        // Global interval [s_a, s_b] for each segment.
        seg_sa  = [for (s = [0:1:n_segs-1]) s == 0         ? 0    : cpar[s-1]],
        seg_sb  = [for (s = [0:1:n_segs-1]) s == n_segs-1  ? 1    : cpar[s]  ],
        // Per-segment interior knots (exclude leading 0 and trailing 1),
        // remapped from local [0,1] to the segment's global interval.
        seg_gi  = [for (s = [0:1:n_segs-1])
            let(
                loc = [for (i = [1:1:len(segments[s][1])-2]) segments[s][1][i]],
                sa  = seg_sa[s],
                sb  = seg_sb[s]
            )
            [for (k = loc) sa + (sb - sa) * k]
        ],
        // Build combined xknots:
        //   [0, seg0_int, corner0^p, seg1_int, corner1^p, ..., segN_int, 1]
        interior = [for (s = [0:1:n_segs-1])
            each concat(
                seg_gi[s],
                s < n_segs-1 ? repeat(cpar[s], p) : []
            )
        ],
        xknots  = [0, each interior, 1],
        // Combined control points: all of seg0, then seg[1:1:] for each later seg.
        // The first control point of seg s (s >= 1) equals the last of seg s-1
        // because both are the clamped-endpoint interpolant of the shared corner
        // data point — so we drop the duplicate.
        ctrl = [
            each segments[0][0],
            for (s = [1:1:n_segs-1])
                for (j = [1:1:len(segments[s][0])-1])
                    segments[s][0][j]
        ]
    )
    [ctrl, xknots, 0];


// Clamped interpolation with C0 corner joints.
//
// NaN entries in eff_der mark corners: the curve is split into independent
// clamped segments at each corner index.  Each segment is solved at the
// highest degree possible: min(p, m-1) where m is the segment point count.
// Degree reduction silently handles short segments (e.g. only 2 or 3 data
// points between adjacent corners).
//
// Segments that needed degree reduction are degree-elevated back to p
// via nurbs_elevate_degree() so that all segments can be assembled into
// a single clamped B-spline.  Elevated segments preserve their original
// lower-degree shape but have higher knot multiplicity, so they are
// less smooth at interior knots than natively degree-p segments.

function _nurbs_interp_clamped_corners(points, p, method, eff_der, eff_curv, corner_idxs,
                                       extra_pts=0, smooth=3) =
    let(
        n          = len(points) - 1,
        params     = _interp_params(points, method),
        seg_bounds = [0, each corner_idxs, n],
        n_segs     = len(seg_bounds) - 1,
        // Distribute extra_pts across eligible segments proportionally to
        // their control-point count (= data-point count = seg_sizes[s]+1).
        // Eligible = segments with seg_p >= 3, or seg_p == 2 when smooth == 1.
        // Linear (seg_p==1) and quadratic with smooth!=1 get 0 extra_pts.
        seg_sizes   = [for (s = [0:1:n_segs-1])
                           seg_bounds[s+1] - seg_bounds[s]],
        seg_degrees = [for (sz = seg_sizes) min(p, sz)],
        // Weight = control-point count for eligible segments, 0 for ineligible.
        seg_weights = [for (s = [0:1:n_segs-1])
                           let(sp = seg_degrees[s])
                           (sp >= 3 || (sp == 2 && smooth == 1))
                             ? seg_sizes[s] + 1 : 0],
        total_weight = max(1, sum(seg_weights)),
        // Round up per-segment allocation so total >= extra_pts.
        seg_extra   = extra_pts == 0 ? repeat(0, n_segs)
                    : [for (s = [0:1:n_segs-1])
                           seg_weights[s] == 0 ? 0
                           : ceil(extra_pts * seg_weights[s] / total_weight)],
        raw_segments = [for (s = [0:1:n_segs-1])
            let(
                i0       = seg_bounds[s],
                i1       = seg_bounds[s+1],
                seg_pts  = [for (k = [i0:1:i1]) points[k]],
                // Reduce degree if the segment has fewer than p+1 points.
                seg_p    = seg_degrees[s],
                // Replace NaN corner markers with undef at shared endpoints.
                seg_der  = is_undef(eff_der) ? undef
                         : [for (k = [i0:1:i1])
                                is_nan(eff_der[k]) ? undef : eff_der[k]],
                seg_curv = is_undef(eff_curv) ? undef
                         : [for (k = [i0:1:i1]) eff_curv[k]],
                r        = _nurbs_interp_clamped(seg_pts, seg_p, method,
                                                 seg_der, undef, undef,
                                                 seg_curv, undef, undef,
                                                 extra_pts=seg_extra[s],
                                                 smooth=smooth)
            )
            [r[0], r[1], seg_p]   // [control, knots, degree]
        ],
        // Degree-elevate short segments to the full degree p.
        segments = [for (seg = raw_segments)
            seg[2] == p ? seg
            : let(elev = nurbs_elevate_degree(seg[0], seg[2], seg[1],
                              type="clamped", times=p - seg[2]))
              [elev[2], elev[3], p]
        ]
    )
    _combine_corner_segs(segments, params, corner_idxs, p);


// General clamped interpolation with per-point derivative and/or curvature
// constraints.
//
// eff_der:  list of n+1 first-derivative specs (undef = unconstrained).
// eff_curv: list of n+1 curvature specs (undef = unconstrained).
//           dim=2: signed scalar κ.  dim≥3: curvature vector.
//
// Uses Method A (expanded-parameter knot averaging, P&T §9.2.2): for each
// constraint at index k, duplicate params[k] in an expanded sequence ũ —
// once per constraint type (deriv and curvature each add one duplication per
// constrained point).  This provides one extra DOF per extra constraint.

function _nurbs_interp_clamped_constrained(points, p, method, eff_der, eff_curv,
                                            extra_pts=0, smooth=3) =
    let(
        n         = len(points) - 1,
        dim       = len(points[0]),
        path_len  = path_length(points),
        path_len2 = path_len * path_len,
        params    = _interp_params(points, method),

        // First-derivative specs: [index, C'(t) vector].
        // eff_der entries are already dim-projected by _nurbs_interp_clamped.
        der_specs = is_undef(eff_der) ? []
                  : [for (k = [0:1:n]) if (!is_undef(eff_der[k]))
                        [k, eff_der[k] * path_len]],

        // Curvature specs: [index, C''(t) vector].
        // eff_der and eff_curv are already dim-projected.
        // Tangent from eff_der[k] when available; otherwise estimated from chord.
        // Speed² from |eff_der[k]|² × path_len² when derivative given.
        curv_specs = is_undef(eff_curv) ? []
                   : [for (k = [0:1:n]) if (!is_undef(eff_curv[k]))
                          let(
                              t_from_der = is_undef(eff_der) ? undef : eff_der[k],
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
        _chk_curv_deg = assert(n_extra_curv == 0 || p >= 2,
                               "nurbs_interp: curvature constraints require degree >= 2"),
        n_constraint = n_extra_der + n_extra_curv,

        // Build knots: average data params, insert at constraint spans,
        // then insert extra_pts more at widest spans.
        base_int       = _avg_knots_interior(params, p),
        base_bar       = [0, each base_int, 1],
        constraint_ts  = [for (spec = der_specs) params[spec[0]],
                          for (spec = curv_specs) params[spec[0]]],
        after_constr   = _insert_constraint_knots(base_bar, constraint_ts),
        // For extra_pts, insert knots at midpoints of the widest spans.
        // _widest_span_params silently caps the request at the available span count.
        extra_ts       = extra_pts == 0 ? []
                       : _widest_span_params(after_constr, extra_pts),
        aug_bar_raw    = _insert_constraint_knots(after_constr, extra_ts),
        n_spans_pre    = len(aug_bar_raw) - 1,
        aug_bar_pre    = _fix_tiny_spans(aug_bar_raw, n_spans_pre),

        // Split any knot span that contains multiple data parameters.
        // Without this, two data points in the same span produce a
        // rank-deficient collocation matrix (Schoenberg-Whitney condition).
        occ_splits     = _span_split_params(aug_bar_pre, params),
        n_occ          = len(occ_splits),
        M              = n + 1 + n_constraint + len(extra_ts) + n_occ,
        aug_bar        = n_occ == 0 ? aug_bar_pre
                       : _fix_tiny_spans(
                             sort([each aug_bar_pre, each occ_splits]),
                             n_spans_pre + n_occ),
        int_kn         = [for (i = [1:1:len(aug_bar)-2]) aug_bar[i]],
        U_full         = _full_clamped_knots(int_kn, p),

        // Constraint matrix A: interpolation + derivative + curvature rows.
        // Dimensions: N_rows × M  where N_rows = (n+1) + n_constraint.
        N_rows = n + 1 + n_constraint,

        // Interpolation rows: N_{j,p}(t_k)
        interp_rows = [for (k = [0:1:n])
            [for (j = [0:1:M-1]) _nip(j, p, params[k], U_full)]
        ],

        // First-derivative rows: N'_{j,p}(t_k)
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:1:M-1]) _dnip(j, p, params[k], U_full)]
        ],

        // Second-derivative rows: N''_{j,p}(t_k)
        curv_rows = [for (spec = curv_specs)
            let(k = spec[0])
            [for (j = [0:1:M-1]) _d2nip(j, p, params[k], U_full)]
        ],

        A_constr = [each interp_rows, each deriv_rows, each curv_rows],
        rhs_constr = [each points,
                      for (spec = der_specs)  spec[1],
                      for (spec = curv_specs) spec[1]],

        knots   = [0, each int_kn, 1]
    )
    // When M == N_rows (square), try direct solve first.
    // When M > N_rows (underdetermined from extra_pts or span splits),
    // use null-space method: exact constraints + minimum-energy smoothing.
    let(
        direct = M == N_rows ? linear_solve(A_constr, rhs_constr) : []
    )
    direct != []
    ? [direct, knots, 0]
    : let(
        R    = smooth <= 2
             ? [for (i = [0:1:M-1]) _ltl_row(M, i, smooth)]
             : _bending_energy_matrix(M, p, U_full),
        control = _nullspace_solve(R, A_constr, rhs_constr)
      )
      assert(!is_undef(control),
             "nurbs_interp (clamped+constrained): rank-deficient constraint matrix")
      [control, knots, 0];


// ---------- CLOSED interpolation ----------

function _nurbs_interp_closed(points, degree, method, deriv, curvature,
                               corners, extra_pts=0, smooth=3) =
    let(n = len(points), p = degree, dim = len(points[0]))
    assert(n >= p + 1,
           str("nurbs_interp (closed): need at least ", p+1,
               " points for degree ", p, ", got ", n))
    let(
        // Detect C0 corners from NaN entries in the RAW deriv list before projection,
        // since _merge_deriv_list would leave NaN entries intact but we detect them here.
        nan_corners      = is_undef(deriv) ? []
                         : [for (k = [0:1:n-1]) if (is_nan(deriv[k])) k],
        explicit_corners = default(corners, []),
        corner_idxs      = deduplicate(sort(concat(nan_corners, explicit_corners))),
        has_corners      = len(corner_idxs) > 0,

        // Project derivative and curvature lists (handles BOSL2 direction constants, etc.)
        eff_der  = _merge_deriv_list(n-1, deriv, dim=dim),
        eff_curv = _merge_curv_list(n-1, curvature, dim=dim),

        has_dl = !is_undef(eff_der) &&
                 len([for (k = [0:1:n-1])
                          if (!is_undef(eff_der[k]) && !is_nan(eff_der[k])) k]) > 0,
        has_cl = !is_undef(eff_curv) &&
                 len([for (k = [0:1:n-1]) if (!is_undef(eff_curv[k])) k]) > 0,

        // Every curvature-constrained point must also have a derivative constraint.
        bad_curv_pts = is_undef(eff_curv) ? [] :
            [for (k = [0:1:n-1])
                if (!is_undef(eff_curv[k]) &&
                    (is_undef(eff_der) || is_undef(eff_der[k])))
                k],
        // Curvature at a corner is not allowed.
        bad_corner_curv = is_undef(eff_curv) ? []
                        : [for (k = corner_idxs) if (!is_undef(eff_curv[k])) k],
        // Derivative at an explicit corner is not allowed.
        bad_corner_der  = is_undef(eff_der) ? []
                        : [for (k = explicit_corners)
                               if (!is_undef(eff_der[k]) && !is_nan(eff_der[k])) k]
    )
    assert(bad_curv_pts == [],
           str("nurbs_interp: curvature constraint requires a derivative constraint ",
               "at the same point(s): ", bad_curv_pts))
    assert(bad_corner_curv == [],
           str("nurbs_interp: curvature constraint cannot coincide with a corner at: ",
               bad_corner_curv))
    assert(bad_corner_der == [],
           str("nurbs_interp: derivative constraint cannot coincide with a corner at: ",
               bad_corner_der))
    // Basic and constrained solvers handle rotation search internally.
    // Corner case uses its own rotation (to the first corner).
    has_corners
      ? _nurbs_interp_closed_corners(points, p, method, eff_der, eff_curv, corner_idxs,
                                      extra_pts=extra_pts, smooth=smooth)
      : (has_dl || has_cl || extra_pts > 0)
        ? let(
              _raw_c = _closed_constrained_solve(points, p, method, eff_der, eff_curv,
                                                  0, extra_pts, smooth),
              _chk   = assert(!is_undef(_raw_c),
                              "nurbs_interp (closed+constrained): rank-deficient constraint matrix")
          ) _raw_c
        : _nurbs_interp_closed_basic(points, p, method, smooth);


// Closed interpolation with C0 corner joints.
//
// Converts the closed-with-corners problem into a clamped-with-corners
// problem: rotate data so the first corner is at the start, duplicate
// that point at the end to close the loop, remap remaining corners to
// the rotated frame, and delegate to _nurbs_interp_clamped_corners.
//
// The result is a clamped B-spline whose first and last control points
// coincide at the corner point.  r[3] = "clamped" tells convenience
// functions to render with type="clamped" instead of "closed".

function _nurbs_interp_closed_corners(points, p, method, deriv, curvature,
                                       corner_idxs, extra_pts=0, smooth=3) =
    let(
        n   = len(points),   // n points (0..n-1), no repeat
        rot = corner_idxs[0],

        // Augmented point list: rotated + closing duplicate of first corner.
        aug_pts = [for (k = [0:1:n-1]) points[(k + rot) % n],
                   points[rot]],

        // Remap remaining corners to rotated frame.
        rot_corners = sort([for (i = [1:1:len(corner_idxs)-1])
                               (corner_idxs[i] - rot + n) % n]),

        // Rotate and augment deriv list.
        // NaN at the rotation point (now start/end) is cleaned to undef
        // since the corner is handled structurally by the clamped endpoints.
        aug_der = is_undef(deriv) ? undef :
            let(rd = [for (k = [0:1:n-1]) deriv[(k + rot) % n]],
                d0 = is_nan(rd[0]) ? undef : rd[0])
            [d0, for (k = [1:1:n-1]) rd[k], d0],

        // Rotate and augment curvature list.
        aug_curv = is_undef(curvature) ? undef :
            let(rc = [for (k = [0:1:n-1]) curvature[(k + rot) % n]])
            [rc[0], for (k = [1:1:n-1]) rc[k], rc[0]],

        // Solve as clamped with corners.
        result = _nurbs_interp_clamped_corners(aug_pts, p, method,
                                                aug_der, aug_curv,
                                                rot_corners,
                                                extra_pts=extra_pts,
                                                smooth=smooth)
    )
    // Return with the original rotation index and type override.
    [result[0], result[1], rot, "clamped"];


// Returns the maximum number of parameters that fall in any single active
// knot span for cyclic rotation r.  A value of 1 is ideal (one parameter
// per span); values > 1 indicate span collisions that may (but do not
// always) cause a singular collocation matrix.

function _closed_rotation_collision_count(points, n, p, method, r) =
    let(
        pts = select(points, r, r + n - 1),
        rp  = _interp_params(pts, method, closed=true),
        bk  = _fix_tiny_spans(_avg_knots_periodic(rp, p)[0], n),
        U   = _full_closed_knots(bk, n, p),
        ps  = add_scalar(rp, bk[p])
    )
    max([for (k = [0:1:n-1])
            len([for (t = ps) if (t >= U[p+k] && t < U[p+k+1]) t])
        ]);


// Find the best seam rotation for closed curve interpolation.
// The chord-ratio heuristic (argmax d[i+1]/d[i] + 1) is tried first.
// If it has span collisions, all n rotations are scored by collision
// count and the one with the fewest collisions is chosen.  Mild
// collisions (max 2 params per span) often still produce a non-singular
// system, so the final check is deferred to linear_solve().

function _find_closed_rotation(points, n, p, method) =
    let(
        chords     = path_segment_lengths(points, closed=true),
        ratios     = [for (i = [0:1:n-1]) chords[(i+1)%n] / max(chords[i], 1e-15)],
        rot0       = (max_index(ratios) + 1) % n
    )
    _closed_rotation_collision_count(points, n, p, method, rot0) <= 1
      ? rot0
      : let(
            scores = [for (i = [0:1:n-1])
                         [_closed_rotation_collision_count(points, n, p, method, i), i]],
            best   = min_index([for (s = scores) s[0]])
        )
        scores[best][1];


// Solve a basic closed interpolation for a specific rotation.
// Returns [control, bar_knots, rot] or undef if singular.

function _closed_basic_solve(points, n, p, method, rot, smooth=3) =
    let(
        dim        = len(points[0]),
        pts        = select(points, rot, rot + n - 1),
        raw_params = _interp_params(pts, method, closed=true),
        bar_knots  = _fix_tiny_spans(_avg_knots_periodic(raw_params, p)[0], n),
        U_full     = _full_closed_knots(bar_knots, n, p),
        params     = add_scalar(raw_params, bar_knots[p]),
        N_mat      = _collocation_matrix_periodic(params, n, p, U_full),
        control    = linear_solve(N_mat, pts)
    )
    control != [] ? [control, bar_knots, rot]
    : // Singular — fall back to constrained optimization.
      let(
        M    = n,
        R    = smooth <= 2
             ? [for (i = [0:1:M-1]) _ltl_row(M, i, smooth, periodic=true)]
             : _bending_energy_matrix(M, p, U_full, periodic=true),
        ctrl = _nullspace_solve(R, N_mat, pts)
      )
      is_undef(ctrl) ? undef : [ctrl, bar_knots, rot];


// Control-point spread ratio: max extent of control points divided by
// max extent of data points.  Values near 1 are ideal; large values
// indicate oscillation from ill-conditioning.

function _ctrl_point_ratio(points, control) =
    let(
        pbound = pointlist_bounds(points),
        cbound = pointlist_bounds(control),
        pmax   = max(pbound[1] - pbound[0]),
        cmax   = max(cbound[1] - cbound[0])
    )
    cmax / max(pmax, 1e-15);


// Basic closed interpolation — start-point independent.
//
// Implements the cyclic chord-length parameterization and cyclic knot
// averaging of Piegl & Tiller §9.2.4.  In exact arithmetic the resulting
// curve is the same regardless of which data point is listed first; only
// the parametric origin changes (the curve is just reparameterized).
//
// The chord-ratio heuristic rotation is tried first.  If the resulting
// control-point spread exceeds 2^p/p times the data spread (indicating
// oscillation), all n rotations are tried and the one with the smallest
// spread is selected.

function _nurbs_interp_closed_basic(points, p, method, smooth=3) =
    let(
        n         = len(points),
        rot0      = _find_closed_rotation(points, n, p, method),
        result0   = _closed_basic_solve(points, n, p, method, rot0, smooth)
    )
    assert(!is_undef(result0), "nurbs_interp (closed): singular system")
    let(
        ratio0    = _ctrl_point_ratio(points, result0[0]),
        threshold = pow(2, p) / p
    )
    ratio0 <= threshold ? result0
    : let(
        // Heuristic rotation produced excessive control-point spread.
        // Try all rotations and pick the one with the smallest spread.
        candidates = [for (r = [0:1:n-1])
                         let(res = _closed_basic_solve(points, n, p, method, r, smooth))
                         if (!is_undef(res))
                         [_ctrl_point_ratio(points, res[0]), res]],
        _chk = assert(len(candidates) > 0,
                       "nurbs_interp (closed): all rotations produce singular systems"),
        best_idx = min_index([for (c = candidates) c[0]]),
        best     = candidates[best_idx][1],
        _echo    = echo(str("nurbs_interp (closed): rotation search chose ",
                            best[2], " (spread ratio ",
                            candidates[best_idx][0], ")"))
    )
    best;


// Solve a constrained closed interpolation for a specific rotation.
// Returns [control, aug_bar, rot] or undef if singular.
//
// eff_der:  list of n first-derivative specs (undef = unconstrained).
// eff_curv: list of n curvature specs (undef = unconstrained).
//           dim=2: signed scalar κ or 2D vector.  dim≥3: curvature vector.
//
// Knot construction: standard periodic averaging of N data params,
// then insert one knot per constraint at the midpoint of the span
// containing its parameter (largest span first).
// M control points use standard BOSL2 periodic aliasing:
// B_j(t) = N_j(t) + (j<p ? N_{j+M}(t) : 0), and likewise for derivatives.

function _closed_constrained_solve(points, p, method, eff_der, eff_curv, rot,
                                    extra_pts=0, smooth=3) =
    let(
        n         = len(points),
        dim       = len(points[0]),
        path_len  = path_length(points, closed=true),
        path_len2 = path_len * path_len,

        // Rotate data, deriv, and curvature lists by the same offset so constraint
        // associations are preserved after rotation.
        pts    = select(points,  rot, rot + n - 1),
        der_r  = is_undef(eff_der)  ? undef : select(eff_der,  rot, rot + n - 1),
        curv_r = is_undef(eff_curv) ? undef : select(eff_curv, rot, rot + n - 1),

        raw_params = _interp_params(pts, method, closed=true),

        // First-derivative specs: [index, C'(t) vector].
        // eff_der entries are already dim-projected by _nurbs_interp_closed.
        der_specs = is_undef(der_r) ? []
                  : [for (k = [0:1:n-1]) if (!is_undef(der_r[k]))
                        [k, der_r[k] * path_len]],

        // Curvature specs: [index, C''(t) vector].
        // eff_curv entries are already dim-projected by _nurbs_interp_closed.
        // Tangent from explicit derivative (required by caller; validated upstream).
        curv_specs = is_undef(curv_r) ? []
                   : [for (k = [0:1:n-1]) if (!is_undef(curv_r[k]))
                          let(
                              tang_dir = der_r[k],
                              v2       = path_len2 * (tang_dir * tang_dir)
                          )
                          [k, _curv_to_d2(curv_r[k], tang_dir, dim, v2)]
                      ],

        n_extra_der  = len(der_specs),
        n_extra_curv = len(curv_specs),
        _chk_curv_deg = assert(n_extra_curv == 0 || p >= 2,
                               "nurbs_interp: curvature constraints require degree >= 2"),
        n_constraint = n_extra_der + n_extra_curv,

        // Build bar_knots: standard periodic averaging of N data
        // params, then insert knots for constraints and extra_pts.
        base_bar       = _avg_knots_periodic(raw_params, p)[0],
        constraint_idxs = [for (spec = der_specs) spec[0],
                           for (spec = curv_specs) spec[0]],
        constraint_ts  = [for (k = constraint_idxs) raw_params[k]],
        after_constr   = _insert_constraint_knots(base_bar, constraint_ts),
        // _widest_span_params silently caps the request at the available span count.
        extra_ts       = extra_pts == 0 ? []
                       : _widest_span_params(after_constr, extra_pts),
        aug_bar_raw    = _insert_constraint_knots(after_constr, extra_ts),
        // M_pre = span count of aug_bar_raw.  Use len()-1 rather than
        // n+n_constraint+extra_pts so it reflects the actual knots inserted.
        M_pre          = len(aug_bar_raw) - 1,
        aug_bar_pre    = _fix_tiny_spans(aug_bar_raw, M_pre),

        // Split any knot span that contains multiple data parameters.
        // Without this, two data points in the same span produce a
        // rank-deficient collocation matrix (§9.2.1 Schoenberg-Whitney).
        occ_splits     = _span_split_params(aug_bar_pre, raw_params),
        n_occ          = len(occ_splits),
        M              = M_pre + n_occ,
        aug_bar        = n_occ == 0 ? aug_bar_pre
                       : _fix_tiny_spans(
                             sort([each aug_bar_pre, each occ_splits]),
                             M),
        T              = aug_bar[M],
        U_full         = _full_closed_knots(aug_bar, M, p),

        // Map raw params into active domain [aug_bar[p], aug_bar[p]+T].
        // Nudge any shifted parameter that lands on or near a knot.
        raw_shifted = add_scalar(raw_params, aug_bar[p]),
        eps_knot    = T / M * (p == 2 ? 0.01 : 1e-6),
        params      = [for (k = [0:1:n-1])
            let(
                u     = raw_shifted[k],
                d_min = min([for (j = [0:1:M + 2*p]) abs(u - U_full[j])])
            )
            d_min < eps_knot ? u + eps_knot : u
        ],

        // Constraint matrix A: interpolation + derivative + curvature rows.
        N_rows = n + n_constraint,

        // Interpolation rows: aliased basis for M control points
        interp_rows = [for (k = [0:1:n-1])
            [for (j = [0:1:M-1])
                _nip(j, p, params[k], U_full)
              + (j < p ? _nip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        // First-derivative rows: aliased derivative basis
        deriv_rows = [for (spec = der_specs)
            let(k = spec[0])
            [for (j = [0:1:M-1])
                _dnip(j, p, params[k], U_full)
              + (j < p ? _dnip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        // Second-derivative rows: aliased second-derivative basis
        curv_rows = [for (spec = curv_specs)
            let(k = spec[0])
            [for (j = [0:1:M-1])
                _d2nip(j, p, params[k], U_full)
              + (j < p ? _d2nip(j + M, p, params[k], U_full) : 0)
            ]
        ],

        A_constr = [each interp_rows, each deriv_rows, each curv_rows],
        rhs_constr = [each pts,
                      for (spec = der_specs)  spec[1],
                      for (spec = curv_specs) spec[1]]
    )
    // When M == N_rows (square), try direct solve first.
    // When M > N_rows (underdetermined from extra_pts or span splits),
    // use null-space method: exact constraints + minimum-energy smoothing.
    let(
        direct = M == N_rows ? linear_solve(A_constr, rhs_constr) : []
    )
    direct != []
    ? [direct, aug_bar, rot]
    : let(
        R    = smooth <= 2
             ? [for (i = [0:1:M-1]) _ltl_row(M, i, smooth, periodic=true)]
             : _bending_energy_matrix(M, p, U_full, periodic=true),
        ctrl = _nullspace_solve(R, A_constr, rhs_constr)
      )
      is_undef(ctrl) ? undef : [ctrl, aug_bar, rot];


// =====================================================================
// SECTION: Debug / Visualization
// =====================================================================

// Module: debug_nurbs_interp()
// Synopsis: Interpolates a NURBS using {{nurbs_interp()}} and displays the curve with informative overlays.
// Topics: NURBS Curves, Interpolation, Debugging
// See Also: nurbs_interp(), nurbs_interp_curve(), debug_nurbs()
//
// Usage:
//   debug_nurbs_interp(points, degree, [splinesteps=], [method=],
//                      [closed=], [deriv=], [start_deriv=], [end_deriv=],
//                      [curvature=], [start_curvature=], [end_curvature=],
//                      [corners=], [extra_pts=], [smooth=],
//                      [width=], [size=], [data_size=], [data_index=],
//                      [show_control=], [control_index=], [show_knots=],
//                      [show_deriv=], [show_curvature=]);
//
// Description:
//   Calls {{nurbs_interp()}} with the supplied arguments and displays the
//   resulting curve together with a informative overlays.  All interpolation
//   arguments are passed through unchanged; see {{nurbs_interp()}} for their 
//   descriptions.  The overlays are:
//   .
//   - **Data points** — red circles (2D) or spheres (3D) at each input point.
//     When `data_index=true` (the default), the point index is printed in red next
//     to its marker.  Set `data_size=0` to suppress display of the data point dots.
//   - **Derivative constraints** — a black arrow at each derivative constrained data point.
//     Arrow direction and length reflect the constraint vector, scaled to the average
//     point spacing.  When the derivative is NAN or a point has a corner, this is shown
//     using a black diamond.  Shown by default: set `show_deriv=false` to hide.
//   - **Curvature constraints** — a transparent green overlay at each curvature-constrained point.
//     In 2D the overlay is the osculating circle.  In 3D the overlay is a cylinder created
//     from the 3D osculating circle.  Zero curvature appears as a short green bar.
//     Shown by default: Set `show_curvature=false` to hide.
//   - **Knots** — Green crosses mark each knot position.  Not shown by default.  
//     Enable with `show_knots=true`.
//   - **Control points and polygon** — If you set `show_control=true` then a gray control polygon
//     Is displayed.  If you additionally set `control_index=true` then blue control-point
//     index labels appear.
//
// Arguments:
//   points  = List of 2-D or 3-D data points to interpolate through.
//   degree  = NURBS degree.
//   ---
//   splinesteps     = Steps per knot span for curve rendering.  Default: `16`
//   method          = Parameterization method; see {{nurbs_interp()}}.  Default: `"centripetal"`
//   closed          = If true, interpolate as a closed loop; if false, interpolate as clamped.  Default: `false`
//   deriv           = Per-point derivative constraints; see {{nurbs_interp()}}.  Default: `undef`
//   start_deriv     = Derivative at first point.  Default: `undef`
//   end_deriv       = Derivative at last point.  Default: `undef`
//   curvature       = Per-point curvature constraints; see {{nurbs_interp()}}.  Default: `undef`
//   start_curvature = Curvature at first point.  Default: `undef`
//   end_curvature   = Curvature at last point.  Default: `undef`
//   corners         = Corner indices; see {{nurbs_interp()}}.  Default: `undef`
//   extra_pts       = Extra control points; see {{nurbs_interp()}}.  Default: `0`
//   smooth          = Smoothness criterion for `extra_pts`; see {{nurbs_interp()}}.  Default: `3`
//   width           = Stroke width for the curve.  Arrows and other overlays scale with this.  Default: `1`
//   size            = Text size for labels on control points and data points.  Default: `3*width`
//   data_size       = Radius of the red data-point markers.  Set to `0` to hide data points and their labels.  Default: equal to `width`
//   data_index      = Show index labels next to each data point.  Only shown when `data_size > 0`.  Default: `true`
//   show_control    = Show the control polygon.  Default: `false`
//   control_index   = Show control-point index labels if `show_control=true`.  Default: `false`
//   show_knots      = Show knot position markers on the curve.  Default: `false`
//   show_deriv      = Show derivative-constraint arrows.  Default: `true`
//   show_curvature  = Show curvature-constraint circles / disks.  Default: `true`

module debug_nurbs_interp(points, degree, splinesteps=16, method="centripetal",
                          closed=false, deriv=undef,
                          start_deriv=undef, end_deriv=undef,
                          curvature=undef, start_curvature=undef, end_curvature=undef,
                          corners=undef, extra_pts=0, smooth=3,
                          width=1, size=undef, data_size=undef,
                          show_control=false, show_knots=false,
                          show_deriv=true, show_curvature=true,
                          control_index=false, data_index=true) {
    result = nurbs_interp(points, degree, method=method,
                          closed=closed, deriv=deriv,
                          start_deriv=start_deriv, end_deriv=end_deriv,
                          curvature=curvature, start_curvature=start_curvature,
                          end_curvature=end_curvature, corners=corners,
                          extra_pts=extra_pts, smooth=smooth);

    np          = len(points);
    dim         = len(points[0]);
    is2d        = (dim == 2);
    ds          = default(data_size, width);
    sz          = default(size, 3 * width);
    ctrl        = result[2];
    arrow_scale = path_length(points) / np;

    // Helpers project BOSL2 direction constants and pad dimensions automatically.
    eff_der  = _merge_deriv_list(np-1, deriv, dim=dim, start_deriv=start_deriv, end_deriv=end_deriv);
    eff_curv = _merge_curv_list(np-1, curvature, dim=dim, start_curvature=start_curvature, end_curvature=end_curvature);

    // --- Curve, control polygon, knot markers (delegated to debug_nurbs) ---
    debug_nurbs(result, splinesteps=splinesteps, width=width, size=sz,
                show_knots=show_knots, show_control=show_control,
                show_index=control_index);

    // --- Corner marks (NaN-deriv corners + explicit corners= indices) ---
    // 2D: rotated square stroke.  3D: octahedron wireframe.
    nan_corner_idxs = is_undef(eff_der) ? []
                    : [for (i = [0:1:np-1]) if (!is_undef(eff_der[i]) && is_nan(eff_der[i])) i];
    explicit_corner_idxs = default(corners, []);
    all_corner_idxs = deduplicate(sort(concat(nan_corner_idxs, explicit_corner_idxs)));
    for (i = all_corner_idxs)
        color("black")
            translate(points[i])
                if (is2d)
                    zrot(45) stroke(rect(3.5*width*ds), width=width/2, closed=true);
                else
                    vnf_wireframe(octahedron(size=5*width), width=width/4);

    // --- Derivative arrows (black, half width, arrow2 endcap) ---
    // Length = norm(eff_der[i]) * arrow_scale: preserves relative magnitudes;
    // arrow_scale = path_length(points)/np gives a geometry-relative baseline.
    if (show_deriv && !is_undef(eff_der))
        for (i = [0:1:np-1])
            if (!is_undef(eff_der[i]) && !is_nan(eff_der[i]) && norm(eff_der[i]) > 1e-12)
                color("black")
                    stroke([points[i], points[i] + eff_der[i] * arrow_scale],
                           width=width/2,
                           endcap1="butt", endcap2="arrow2");

    // --- Data points and index labels ---
    if (ds > 0)
        color("red")
            move_copies(points) {
                if (is2d) circle(r=ds, $fn=16);
                else      sphere(r=ds, $fn=16);
                if (data_index)
                    if (is2d)
                        fwd(2*ds) text(text=str($idx), size=sz, anchor=BACK);
                    else
                        rot($vpr) back(ds + sz/3) text3d(text=str($idx), size=sz, anchor=CENTER);
            }

    // --- Curvature overlays (rendered last so transparent objects don't occlude dots) ---
    // Validator already asserted every curvature-constrained point has a derivative,
    // so eff_der[i] is always defined and non-NaN here.
    if (show_curvature && !is_undef(eff_curv))
        color([0,1,0,0.1])
        for (i = [0:1:np-1])
            if (!is_undef(eff_curv[i])) {
                // cv is either a signed scalar (2D) or a dim-projected vector.
                cv    = eff_curv[i];
                kn    = is_num(cv) ? abs(cv) : norm(cv);
                T_hat = unit(eff_der[i]);
                if (kn < 1e-12) {
                    // Zero curvature: fixed-length segment (0.6*arrow_scale) along
                    // the exact derivative direction.
                    half = 0.3 * arrow_scale;
                    stroke([points[i] - T_hat * half,
                            points[i] + T_hat * half],
                           width=2*width, endcaps="butt");
                } else {
                    // Non-zero curvature: osculating circle (2D) or cylinder (3D).
                    // N_hat: unit principal normal — component of cv perpendicular to T_hat.
                    N_hat = is_num(cv)
                        ? // Signed scalar (2D): rotate T_hat 90° left or right by sign(cv).
                          sign(cv) * [-T_hat[1], T_hat[0]]
                        : // Vector: strip tangential component via vector_perp, then unit.
                          unit(vector_perp(T_hat, cv));
                    r   = 1 / kn;
                    ctr = points[i] + N_hat * r;
                    // move(ctr) applies to both 2D and 3D branches.
                    move(ctr)
                        if (is2d) {
                            circle(r=r);
                        } else {
                            // Cylinder in the osculating plane: axis along binormal B̂ = T̂ × N̂.
                            // cyl(orient=binom) aligns the cylinder axis to B̂ without rot().
                            binom = cross(T_hat, N_hat);
                            cyl(h=width, r=r, orient=binom);
                        }
                }
            }
}


// =====================================================================
// SECTION: Interpolation System Builder (shared by curve & surface)
// =====================================================================

// Builds the collocation matrix and BOSL2-format knots for a single
// parameterized direction.  Returns [N_mat, bosl2_knots].

function _build_interp_system(params, p, type, extra_pts=0) =
    type == "clamped" ? _build_clamped_system(params, p, extra_pts)
  :                     _build_closed_system(params, p, extra_pts);

function _build_clamped_system(params, p, extra_pts=0) =
    let(
        n       = len(params) - 1,
        int_kn  = _avg_knots_interior(params, p),
        base_bar = [0, each int_kn, 1]
    )
    extra_pts == 0
    ? let(
        U_full = _full_clamped_knots(int_kn, p),
        N_mat  = _collocation_matrix(params, n, p, U_full),
        knots  = [0, each int_kn, 1]
      )
      [N_mat, knots]
    : let(
        extra_ts    = _widest_span_params(base_bar, extra_pts),
        aug_bar_raw = _insert_constraint_knots(base_bar, extra_ts),
        occ_splits  = _span_split_params(aug_bar_raw, params),
        n_occ       = len(occ_splits),
        // Use len(extra_ts), not extra_pts: _widest_span_params silently caps
        // the request at the number of available spans.
        M           = n + 1 + len(extra_ts) + n_occ,
        aug_bar_merged = n_occ == 0 ? aug_bar_raw
                       : sort([each aug_bar_raw, each occ_splits]),
        aug_bar     = _fix_tiny_spans(aug_bar_merged, len(aug_bar_merged) - 1),
        aug_int     = [for (i = [1:1:len(aug_bar)-2]) aug_bar[i]],
        U_full      = _full_clamped_knots(aug_int, p),
        // Rectangular (n+1) × M matrix: n+1 data rows, M control columns.
        // _collocation_matrix uses a single n for both dimensions, so build inline.
        N_mat       = [for (k = [0:1:n])
                           [for (j = [0:1:M-1]) _nip(j, p, params[k], U_full)]],
        knots       = [0, each aug_int, 1]
      )
      [N_mat, knots];

function _build_closed_system(params, p, extra_pts=0) =
    let(
        n          = len(params),
        base_bar   = _fix_tiny_spans(_avg_knots_periodic(params, p)[0], n)
    )
    extra_pts == 0
    ? let(
        U_full     = _full_closed_knots(base_bar, n, p),
        col_params = add_scalar(params, base_bar[p]),
        T          = base_bar[n],
        eps_knot   = T / n * (p == 2 ? 0.01 : 1e-6),
        col_safe   = [for (k = [0:1:n-1])
            let(
                u     = col_params[k],
                d_min = min([for (j = [0:1:n + 2*p]) abs(u - U_full[j])])
            )
            d_min < eps_knot ? u + eps_knot : u
        ],
        N_mat      = _collocation_matrix_periodic(col_safe, n, p, U_full)
      )
      [N_mat, base_bar]
    : let(
        extra_ts    = _widest_span_params(base_bar, extra_pts),
        aug_bar_raw = _insert_constraint_knots(base_bar, extra_ts),
        occ_splits  = _span_split_params(aug_bar_raw, params),
        n_occ       = len(occ_splits),
        // Use len(extra_ts), not extra_pts: _widest_span_params silently caps
        // the request at the number of available spans.
        M           = n + len(extra_ts) + n_occ,
        aug_bar_merged = n_occ == 0 ? aug_bar_raw
                       : sort([each aug_bar_raw, each occ_splits]),
        aug_bar     = _fix_tiny_spans(aug_bar_merged, len(aug_bar_merged) - 1),
        T           = aug_bar[M],
        U_full      = _full_closed_knots(aug_bar, M, p),
        raw_shifted = add_scalar(params, aug_bar[p]),
        eps_knot    = T / M * (p == 2 ? 0.01 : 1e-6),
        col_safe    = [for (k = [0:1:n-1])
            let(
                u     = raw_shifted[k],
                d_min = min([for (j = [0:1:M + 2*p]) abs(u - U_full[j])])
            )
            d_min < eps_knot ? u + eps_knot : u
        ],
        // Rectangular n × M matrix: n data rows, M control columns.
        // _collocation_matrix_periodic uses a single n for both dimensions, so
        // build inline. Periodic wrapping folds basis j < p by adding N_{j+M}.
        N_mat       = [for (k = [0:1:n-1])
                           [for (j = [0:1:M-1])
                               _nip(j, p, col_safe[k], U_full)
                             + (j < p ? _nip(j + M, p, col_safe[k], U_full) : 0)
                           ]]
      )
      [N_mat, aug_bar];


// Build a clamped interpolation system with optional start/end first-derivative rows.
// Extends _build_clamped_system by adding one extra DOF and one extra matrix row
// for each active boundary (start and/or end).  Used for surface boundary tangents.
//
// has_sd / has_ed — whether a start / end derivative constraint is active.
// extra_pts — number of additional control points (widens the system).
// Returns [A_matrix, bosl2_knots].  Square when extra_pts==0, rectangular otherwise.
// Row order: interpolation rows (k=0..n), deriv_start (if any), deriv_end (if any).

function _build_clamped_system_with_derivs(params, p, has_sd, has_ed, extra_pts=0) =
    let(
        n       = len(params) - 1,
        n_extra = (has_sd ? 1 : 0) + (has_ed ? 1 : 0),
        // Average n+1 data params to get base interior knots, then
        // insert extra knots for boundary constraints.  Each insertion
        // bisects the span containing the constraint parameter
        // (largest span first).  Constraint params 0 and 1 land in
        // the first and last spans respectively.
        base_int      = _avg_knots_interior(params, p),
        base_bar      = [0, each base_int, 1],
        constraint_ts = [if (has_sd) params[0], if (has_ed) params[n]],
        after_constr  = _insert_constraint_knots(base_bar, constraint_ts),
        // Insert extra_pts knots at widest spans.
        extra_ts      = extra_pts == 0 ? []
                      : _widest_span_params(after_constr, extra_pts),
        aug_bar_raw   = extra_pts == 0 ? after_constr
                      : _insert_constraint_knots(after_constr, extra_ts),
        occ_splits    = extra_pts == 0 ? []
                      : _span_split_params(aug_bar_raw, params),
        n_occ         = len(occ_splits),
        M             = n + 1 + n_extra + len(extra_ts) + n_occ,
        aug_bar_merged = n_occ == 0 ? aug_bar_raw
                       : sort([each aug_bar_raw, each occ_splits]),
        aug_bar       = _fix_tiny_spans(aug_bar_merged, len(aug_bar_merged) - 1),
        int_kn      = [for (i = [1:1:len(aug_bar)-2]) aug_bar[i]],
        U_full      = _full_clamped_knots(int_kn, p),
        interp_rows = [for (k = [0:1:n])
                           [for (j = [0:1:M-1]) _nip(j, p, params[k], U_full)]
                      ],
        deriv_start = has_sd
                    ? [[for (j = [0:1:M-1]) _dnip(j, p, params[0], U_full)]]
                    : [],
        deriv_end   = has_ed
                    ? [[for (j = [0:1:M-1]) _dnip(j, p, params[n], U_full)]]
                    : [],
        knots       = [0, each int_kn, 1]
    )
    [[each interp_rows, each deriv_start, each deriv_end], knots];


// Precompute per-segment interpolation systems for edge-aware surface solves.
// All rows (or columns) share the same averaged parameterization, so the
// collocation matrices only need to be built once.
//
// params    = averaged parameter values for this direction
// p         = degree
// edge_idxs = sorted list of interior indices where C0 edges occur
// has_sd    = if true, first segment gets a start-derivative row
// has_ed    = if true, last  segment gets an end-derivative row
//
// Returns a list of [N_mat, xknots, seg_p, i0, i1, seg_sd, seg_ed]
// per segment, where seg_sd/seg_ed indicate whether that segment's
// system includes a derivative row.

function _build_edge_systems(params, p, edge_idxs,
                              has_sd=false, has_ed=false, extra_pts=0, label="") =
    let(
        n          = len(params) - 1,
        seg_bounds = [0, each edge_idxs, n],
        n_segs     = len(seg_bounds) - 1,

        // Pre-compute seg_p and available interior knot spans per segment.
        // For a segment with n_pts data points at degree seg_p, the averaged
        // interior knot vector has (n_pts-1) - seg_p entries = that many spans.
        seg_n_pts   = [for (s = [0:1:n_segs-1]) seg_bounds[s+1] - seg_bounds[s] + 1],
        seg_p_arr   = [for (npts = seg_n_pts) min(p, npts - 1)],
        avail_spans = [for (i = [0:1:n_segs-1])
                           max(0, seg_n_pts[i] - 1 - seg_p_arr[i])],
        total_avail = sum(avail_spans),
        k_use       = min(extra_pts, total_avail),

        // Emit one diagnostic when extra_pts exceeds the combined span budget.
        _echo = extra_pts > 0 && extra_pts > total_avail && label != ""
              ? echo(str("nurbs_interp_surface: extra_pts (", label, "-direction)=",
                         extra_pts, " exceeds available knot spans across ",
                         n_segs, " segment(s) (max ", total_avail, " total); ",
                         "reduced to ", total_avail, "."))
              : 0,

        // Distribute k_use proportionally to avail_spans, capped per segment.
        seg_ep = extra_pts == 0 || total_avail == 0 ? repeat(0, n_segs)
               : [for (s = [0:1:n_segs-1])
                     avail_spans[s] == 0 ? 0
                     : min(avail_spans[s],
                           ceil(k_use * avail_spans[s] / total_avail))]
    )
    [for (s = [0:1:n_segs-1])
        let(
            i0      = seg_bounds[s],
            i1      = seg_bounds[s+1],
            seg_par = [for (k = [i0:1:i1]) params[k]],
            // Remap to [0,1]
            t0      = seg_par[0],
            t1      = last(seg_par),
            span    = max(t1 - t0, 1e-15),
            local_p = [for (t = seg_par) (t - t0) / span],
            seg_p   = seg_p_arr[s],
            // Derivative extension requires at least seg_p+1 data points
            // (same minimum as basic interpolation); each derivative row
            // adds one control point and one equation, keeping the system
            // square.  Degree-reduced segments with fewer points silently
            // skip the constraint.
            n_pts   = seg_n_pts[s],
            seg_sd  = has_sd && s == 0          && n_pts >= seg_p + 1,
            seg_ed  = has_ed && s == n_segs - 1 && n_pts >= seg_p + 1,
            // extra_pts only applies when degree >= 2; silently skip for
            // degree-reduced (seg_p < 2) segments.
            cur_ep  = seg_p >= 2 ? seg_ep[s] : 0,
            sys     = (seg_sd || seg_ed)
                    ? _build_clamped_system_with_derivs(local_p, seg_p,
                                                        seg_sd, seg_ed, cur_ep)
                    : _build_interp_system(local_p, seg_p, "clamped", cur_ep)
        )
        [sys[0], sys[1], seg_p, i0, i1, seg_sd, seg_ed]
    ];


// Solve one row (or column) using precomputed edge-aware systems.
// Each segment is solved independently; short segments are degree-elevated.
// Results are assembled into a single clamped B-spline via _combine_corner_segs.
//
// systems    = list from _build_edge_systems
// data       = row/column data points (same length as params)
// params     = averaged parameter values
// edge_idxs  = edge index list (same as passed to _build_edge_systems)
// p          = target degree
// start_deriv  = derivative vector at start of first segment (undef if none)
// end_deriv    = derivative vector at end of last segment (undef if none)

function _solve_with_edges(systems, data, params, edge_idxs, p,
                            start_deriv=undef, end_deriv=undef, smooth=3) =
    let(
        raw_segments = [for (sys = systems)
            let(
                N_mat    = sys[0],
                knots    = sys[1],
                i0       = sys[3],
                i1       = sys[4],
                seg_p    = sys[2],
                seg_sd   = sys[5],
                seg_ed   = sys[6],
                seg_data = [for (k = [i0:1:i1]) data[k]],
                rhs      = concat(seg_data,
                                  seg_sd ? [start_deriv] : [],
                                  seg_ed ? [end_deriv]   : []),
                M        = len(N_mat[0]),
                N_rows   = len(rhs),
                // When M > N_rows the segment system is underdetermined (extra_pts).
                // Use null-space method: exact interpolation + minimum bending energy.
                ctrl = M > N_rows
                     ? let(
                         int_kn     = [for (i = [1:1:len(knots)-2]) knots[i]],
                         U_full     = _full_clamped_knots(int_kn, seg_p),
                         eff_smooth = (smooth == 3 && seg_p < 2) ? 2 : smooth,
                         R          = eff_smooth <= 2
                                    ? [for (i = [0:1:M-1]) _ltl_row(M, i, eff_smooth)]
                                    : _bending_energy_matrix(M, seg_p, U_full)
                       )
                       _nullspace_solve(R, N_mat, rhs)
                     : linear_solve(N_mat, rhs)
            )
            assert(ctrl != [] && !is_undef(ctrl),
                   str("nurbs_interp_surface: singular edge-segment system for rows/cols ",
                       i0, "-", i1, " (", i1-i0+1, " points, degree ", seg_p,
                       seg_sd ? ", start deriv" : "",
                       seg_ed ? ", end deriv" : "", ")"))
            [ctrl, knots, seg_p]
        ],
        // Degree-elevate short segments to full degree p.
        segments = [for (seg = raw_segments)
            seg[2] == p ? seg
            : let(elev = nurbs_elevate_degree(seg[0], seg[2], seg[1],
                              type="clamped", times=p - seg[2]))
              [elev[2], elev[3], p]
        ]
    )
    _combine_corner_segs(segments, params, edge_idxs, p);


// =====================================================================
// SECTION: Surface Interpolation
// =====================================================================

// Compute per-point tangent vectors for a degenerate apex row or column.
// Returns true if all points in pts are collinear (lie on a single line).
// Computes the direction from first to last point, then checks that every
// intermediate point projects onto that line within eps.  Points that are
// all identical also pass (dn < eps branch).

// Returns true if all points in pts are coplanar (lie in a single plane).
// For 2D points always returns true.  For 3D: finds the plane through the
// first three non-collinear points (using their cross-product normal), then
// checks that all remaining points satisfy |dot(pt-p0, nhat)| < eps.
// Points that are all collinear (degenerate plane) also return true.

function _is_coplanar_pts(pts, eps=1e-10) =
    let(n = len(pts), dim = len(pts[0]))
    n <= 3 || dim <= 2 ? true
    : let(
        p0  = pts[0],
        d1  = pts[1] - p0,
        // Index of first point not collinear with pts[0..1].
        nc  = [for (i = [2:1:n-1])
                   let(c = cross(d1, pts[i] - p0))
                   if (norm(c) > eps) i][0]
    )
    is_undef(nc) ? true   // all collinear → trivially coplanar
    : let(
        normal = cross(d1, pts[nc] - p0),
        nhat   = normal / norm(normal)
    )
    max([for (pt = pts) abs((pt - p0) * nhat)]) < eps;


// Plane normal for a set of 3D points (returns 3D vector, or undef if collinear).
// Always returns [0,0,1] for 2D points.

function _pts_plane_normal(pts, eps=1e-10) =
    let(dim = len(pts[0]))
    dim <= 2
    ? [0, 0, 1]
    : let(
          p0 = pts[0],
          d1 = last(pts) - p0,
          nc = [for (i = [1:1:len(pts)-1])
                    let(c = cross(d1, pts[i] - p0))
                    if (norm(c) > eps) c][0]
      )
      is_undef(nc) ? undef : nc;


// Used to auto-generate first_row_deriv / last_row_deriv / first_col_deriv / last_col_deriv
// when normal1=/normal2= or flat_end1=/flat_end2= is supplied.
//
// Apex edge (all boundary points identical):
//   _apex_tangents(N, apex, ring)
//   N defines the symmetry axis (user-supplied vector); magnitude sets derivative scale.
//   Returns per-point outward vectors (apex→ring, projected ⊥ N) of magnitude norm(N).
//   Pass the negated result for an end (u=1 or v=1) apex; see caller.
//
// Coplanar edge (boundary points coplanar and span a plane, i.e. non-collinear):
//   _coplanar_inward_tangents(scales, edge, ring, periodic=false)
//   At each edge point computes a unit vector perpendicular to the polygon edge tangent,
//   lying in the edge plane, oriented toward the polygon interior.
//
//   Interior orientation uses polygon winding: the signed area of the edge polygon
//   projected onto the edge plane (via the area vector = Σ cross(edge[i], edge[(i+1)%n])).
//   If the area vector aligns with P_hat (CCW when viewed from P_hat) the interior is to
//   the LEFT of the traversal direction; cross(P_hat, T3) already points left and so is
//   the inward normal.  If CW (area vector opposes P_hat), cross(P_hat, T3) points right
//   (outward) and is negated.  This is robust for any non-convex polygon.
//
//   scales: scalar or per-point list; positive = inward (closes surface),
//           negative = outward (flares surface).  Same convention at start and end edges.
//   periodic=true uses wrapped central differences at the first/last point (for closed v/u).

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
        n_perp > 1e-12 ? mag * d_perp / n_perp : repeat(0, len(N))
    ];


function _coplanar_inward_tangents(scales, edge, ring, periodic=false) =
    let(
        n     = len(edge),
        dim   = len(edge[0]),
        P     = _pts_plane_normal(edge),
        zero  = repeat(0, dim),
        sc    = is_num(scales) ? repeat(scales, n) : scales
    )
    is_undef(P) ? repeat(zero, n)
    : let(
        P_hat    = P / norm(P),
        // Polygon area vector = Σ cross(edge[i], edge[(i+1)%n]).
        // Positive dot with P_hat → CCW when viewed from P_hat → interior is LEFT.
        // Negative dot                → CW                       → interior is RIGHT.
        area_vec = sum([for (i = [0:1:n-1])
                            cross(dim == 2 ? [edge[i][0],          edge[i][1],          0]
                                          :  edge[i],
                                  dim == 2 ? [edge[(i+1)%n][0],    edge[(i+1)%n][1],    0]
                                          :  edge[(i+1)%n])]),
        sign     = (area_vec * P_hat) >= 0 ? 1 : -1
    )
    [for (j = [0:1:n-1])
        let(
            jm   = periodic ? (j == 0   ? n-1 : j-1) : max(0,   j-1),
            jp   = periodic ? (j == n-1 ? 0   : j+1) : min(n-1, j+1),
            // Incoming and outgoing edge vectors (lifted to 3D for 2D input).
            seg1 = dim == 2 ? [edge[j][0]-edge[jm][0], edge[j][1]-edge[jm][1], 0]
                            :  edge[j] - edge[jm],
            seg2 = dim == 2 ? [edge[jp][0]-edge[j][0], edge[jp][1]-edge[j][1], 0]
                            :  edge[jp] - edge[j],
            s1   = norm(seg1),
            s2   = norm(seg2),
            // Inward normal to each adjacent edge (unit vector), using polygon
            // winding sign.  cross(P_hat, unit_edge) = 90° left rotation in plane.
            // Angle-bisector (average of unit normals) is length-independent, so
            // non-uniform sample spacing has no effect — unlike the chord-average
            // tangent method it replaces.
            n1   = s1 < 1e-12 ? undef : sign * cross(P_hat, seg1 / s1),
            n2   = s2 < 1e-12 ? undef : sign * cross(P_hat, seg2 / s2),
            bis  = is_undef(n1) ? n2 : is_undef(n2) ? n1 : n1 + n2,
            blen = is_undef(bis) ? 0 : norm(bis)
        )
        blen < 1e-12 ? zero
        : let(
            in3    = bis / blen,
            inward = dim == 2 ? [in3[0], in3[1]] : in3
        )
        sc[j] * inward
    ];

// Averaged parameterization for the u-direction (across rows).
// For each column, compute chord-length params, then average.

function _surface_params_u(points, method, closed_u) =
    let(
        n_rows = len(points),
        n_cols = len(points[0]),
        col_params = [for (l = [0:1:n_cols-1])
            let(col = [for (k = [0:1:n_rows-1]) points[k][l]])
            _interp_params(col, method, closed=closed_u)
        ],
        n_p = len(col_params[0])
    )
    [for (k = [0:1:n_p-1])
        sum([for (l = [0:1:n_cols-1]) col_params[l][k]]) / n_cols
    ];


// Averaged parameterization for the v-direction (across columns).
// For each row, compute chord-length params, then average.

function _surface_params_v(points, method, closed_v) =
    let(
        n_rows = len(points),
        n_cols = len(points[0]),
        row_params = [for (k = [0:1:n_rows-1])
            _interp_params(points[k], method, closed=closed_v)
        ],
        n_p = len(row_params[0])
    )
    [for (l = [0:1:n_p-1])
        sum([for (k = [0:1:n_rows-1]) row_params[k][l]]) / n_rows
    ];


// Function&Module: nurbs_interp_surface()
// Synopsis: Returns a NURBS surface that passes through a regular grid of 3D data points.
// SynTags: Geom
// Topics: NURBS Surfaces, Interpolation
// See Also: nurbs_vnf(), nurbs_interp()
//
// Usage: As a function, returns a NURBS parameter list:
//   result = nurbs_interp_surface(points, degree, [method=], [row_wrap=], [col_wrap=], [normal1=], [normal2=], [flat_edges=], [flat_end1=], [flat_end2=],
//                [u_edges=], [v_edges=], [extra_pts=], [smooth=], [first_row_deriv=], [last_row_deriv=], [first_col_deriv=], [last_col_deriv=]);
// Usage: As a module, renders the surface directly:
//   nurbs_interp_surface(points, degree, [splinesteps=], [method=], [row_wrap=], [col_wrap=],
//                [style=], [reverse=], [triangulate=],
//                [caps=], [cap1=], [cap2=],
//                [first_row_deriv=], [last_row_deriv=],
//                [first_col_deriv=], [last_col_deriv=],
//                [normal1=], [normal2=],
//                [flat_edges=], [flat_end1=], [flat_end2=],
//                [u_edges=], [v_edges=],
//                [extra_pts=], [smooth=],
//                [data_color=], [data_size=]);
//
// Description:
//   Finds the control points and knot vectors for a NURBS surface that passes
//   exactly through every data point in a grid of 3D points.  The result has
//   uniform weights but non-uniform knots so it is actually a non-uniform B-spline.
//   Uses the two-pass method from Piegl & Tiller §9.2.5: first interpolate each
//   row in the v-direction, then each column in the u-direction.  When called as a function ,the return value
//   is a NURBS parameter list
//   `[type, degree, ctrl_grid, knots, mult, weights, rotation, u]` that can be passed
//   directly to `{{nurbs_vnf()}}`.  The 8th element `u` is `[u_params, v_params]`,
//   the parameterization vectors used in the solve.
//   When called as a module, renders the NURBS surface as geometry.
//   .
//   `row_wrap=true` makes the surface wrap in the u-direction (joining the first
//   and last rows into a smooth loop).  `col_wrap=true` wraps in the v-direction
//   (joining the first and last columns).  Both false (the default) gives a flat
//   surface with four edges.  One true gives a tube; both true gives a torus.
//   A tube by itself is not a valid closed manifold in OpenSCAD;
//   you can close it into a ball by specifying degenerate edges where every
//   point on the edge is the same point.
//   .
//   ** Boundary constraints **
//   .
//   Flat boundary (`["clamped","clamped"]`) &mdash; `flat_edges=`. Applies when the four surface
//   edges are coplanar.  You can constrain the derivative to lie in
//   the plane that contains the edges.  You specify the derivative scale either for
//   and entire edge by giving a scalar, or for each point on the edge by giving a list
//   of values.  Set `flat_edges` to a 4-element list
//   `[start_u, end_u, start_v, end_v]`, where each entry gives the derive scale as a scalar or list
//   for the specified edge.  Set an entry to `undef` to leave that entire edge unconstrained. 
//   You can also set `flat_edges=s` as a shorthand for `flat_edges=[s,s,s,s]`.  A positive value results
//   in the curve flaring outward, away from the edges.   A negative value results in the curve turning inward from the edge.  
//   .
//   End normals (`["closed","clamped"]` or `["clamped","closed"]`) &mdash; `normal1=` and `normal2=`.  Apply when the specified
//   edge is degenerate and consists of copies of the same point.  Set `normal1` to control
//   the first (`u_edge1` or `v_edge1`).  Set `normal2` to control the second edge (`u_edge2` or `v_edge2`).
//   The surface at the point defined by the edge will be constrained so it is normal to the specified
//   vector.  The magnitude of your normal controls the speed of the curves as they approach the degenerate
//   end point.  Large values will create a broad, mushroom-like end. The condition applies to whichever of `u` and `v` has the clamped ends.
//   .
//   Flat ends (`["closed","clamped"]` or `["clamped","closed"]`) &mdash; `flat_end1=` and `flat_end2=`. Apply when the specified edge
//   coplanar and not degenerate.  Constrains the derivative to lie in the plane that contains the edge.  For a positive value the
//   derivative will point inward from the edge, so it would blend smoothly into a cap placed on this end.  For a negative
//   value the curve will flare outward at the end.  As usual the scale controls the derivative speed.  You can give
//   a scalar or you can give a list of values corresponding to each point in the edge.  The two ends can be controlled
//   independently and you can also apply a flat end at one end and a normal constraint at the other.
//   .
//   Advanced: boundary partial-derivative constraints** &mdash; `first_row_deriv=`,
//   `last_row_deriv=`, `first_col_deriv=`, and `last_col_deriv=` enforce specific first
//   partial derivatives along each of the four boundary edges.  Each parameter
//   accepts either a single vector (applied uniformly to every point on that edge)
//   or a list of vectors, one per point on the edge.  Vectors are scaled by the
//   total per-row or per-column chord length, so a unit vector gives a derivative
//   speed that matches the parameterization.  These options apply to any "clamped" edge.
//   If an edge does not exist because the surface is closed in that direction, then you cannot specify a derivative.
//   .
//   Use these constraints with care.  The solver enforces your derivatives exactly
//   at the boundary data points, but between those points the surface may wander.
//   The basic constraints above apply in special cases where the geometry guarantees
//   well-defined behavior along an entire edge, including the points in between data points.
//   .
//   When both u- and v-boundary derivatives are active simultaneously, the
//   cross-derivative $\partial^2 S/\partial u \partial v$ is assumed zero at the
//   corners.  This is accurate when corner mixed derivatives are small.
//   .
//   **Edges** — `u_edges=` and `v_edges=` insert edges or creas lines 
//   across the surface.  `u_edges=` creates an edge or crease running in the v-direction at
//   each named row index; `v_edges=` creates an edge or crease running in the u-direction at
//   each named column index.   For a `"closed"` direction, the smallest named index becomes
//   the seam and the direction is internally converted to `"clamped"`; any valid
//   index may be used.  For a `"clamped"` direction, indices must be interior (not
//   first or last).  Can be combined with boundary derivative constraints in the
//   same direction; boundary constraints apply at the outer edges of the first and
//   last segments.
//   .
//   **Extra control points** (`extra_pts=`, `smooth=`) — works the same as for
//   curves (see {{nurbs_interp()}}), applied independently in each direction.  Scalar `extra_pts=N`
//   applies to both directions; `[ep_u, ep_v]` sets each independently.
//   .
//   **Starting Point for closed surfaces**  When a closed direction is shifted to align a seam,
//   the rotation is returned in `result[6]` as `[u_rot, v_rot]`.  The parameterization
//   in `result[7]` is always `[u_params, v_params]` indexed to match the original input grid.
// Arguments:
//   points = Rectangular grid of 3D data points
//   degree = Scalar or 2-vector giving the degree of the NURBS in the two directions.
//   ---
//   method    = Parameterization method: `"length"`, `"centripetal"`, `"dynamic"`, `"foley"`, or `"fang"`. Default: `"centripetal"`
//   row_wrap = If true, the surface wraps in the u-direction (rows form a closed loop).  Default: `false`
//   col_wrap = If true, the surface wraps in the v-direction (columns form a closed loop).  Default: `false`
//   extra_pts = A number or 2-vector giving the number of extra control points to use in the two directions.  Default: 0
//   smooth = A number of 2-vector giving the smoothness metric for extra points in the two directions.  Set to 1 (minimize control-polygon length), 2 (minimize control-polygon bending) or 3 (minimize curve bending energy).   Default: `3`
//   flat_edges = 4-element list `[start_u, end_u, start_v, end_v]` of derivative scale factors at the four boundary edges, which must be coplanar.  Each entry is a scalar or a list giving a scalar value for each point on the edge.  An `undef` leaves that edge unconstrained.  Set `flat_edges=s` expands to `[s, s, s, s]`.  Requires both directions to be `"clamped"`.  Default: undef
//   normal1 = Set the normal to the surface at the first edge of a mixed "closed"/"clamped" surface.  The edge must be degenerate, with all of its values equal to the same point.  Default: undef
//   normal2 = Set the normal to the surface at the second edge of a mixed "closed"/"clamped" surface.  The edge must be degenerate, with all of its values equal to the same point.  Default: undef
//   flat_end1 = Set inward derivatives for the first edge of a mixed "closed"/"clamped" surface.  The specified edge must be coplanar and nondegenerate.  Can be a scalar or a list of values for each point on the edge.  Default: undef
//   flat_end2 = Set inward derivatives for the second edge of a mixed "closed"/"clamped" surface.  The specified edge must be coplanar and nondegenerate.  Can be a scalar or a list of values for each point on the edge.  Default: undef
//   u_edges = Row index (or list of indices) where an edge or crease runs in the v-direction.  Default: undef
//   v_edges = Column index (or list of indices) where an edge or crease runs in the u-direction.  Default: undef
//   first_row_deriv = Partial-derivative constraint $\partial S/\partial u$ along the u=0 boundary (first row).  Single vector applied to all columns, or a list of vectors to apply to each point in the column.  Requires type in the u direction to be `"clamped"`.  Default: undef
//   last_row_deriv = Partial-derivative constraint $\partial S/\partial u$ along the u=1 boundary (last row).   Single vector applied to all columns, or a list of vectors to apply to each point in the column.  Requires type in the u direction to be `"clamped"`.  Default: undef
//   first_col_deriv = Partial-derivative constraint $\partial S/\partial v$ along the v=0 boundary (first column).  Single vector applied to all rows, or a list of vectors to apply to each point in the column.  Requires type in the v direction to be `"clamped"`.  Default: `undef`
//   last_col_deriv = Partial-derivative constraint $\partial S/\partial v$ along the v=1 boundary (last column).   Single vector applied to all rows, or a list of vectors to apply to each point in the column.  Requires type in the v direction to be `"clamped"`.  Default: `undef`
//   splinesteps = (Module form only) Steps per knot span per direction when building the mesh.  Default: `16`
//   style = (Module form only) Triangulation style passed to `nurbs_vnf()`.  Default: `"default"`
//   reverse = (Module form only) If true, reverses face normals.  Default: `false`
//   triangulate = (Module form only) If true, triangulates all quads.  Default: `false`
//   caps = (Module form only) If true, caps both open boundary edges.  Requires a mixed "closed"/"clamped" type.  Default: `undef`
//   cap1 = (Module form only) If true, caps the first open boundary edge.  Default: `undef`
//   cap2 = (Module form only) If true, caps the second open boundary edge.  Default: `undef`
//   data_size = (Module form only) Display data point markers of this radius.  If set to zero, don't display markers.  Default: `0`
//   data_color = (Module form only) Color for data-point sphere markers.  Default: `"red"`

function nurbs_interp_surface(points, degree, method="centripetal",
                              row_wrap=false, col_wrap=false,
                              first_row_deriv=undef, last_row_deriv=undef,
                              first_col_deriv=undef, last_col_deriv=undef,
                              normal1=undef, normal2=undef,
                              flat_end1=undef, flat_end2=undef,
                              flat_edges=undef,
                              u_edges=undef, v_edges=undef,
                              extra_pts=0, smooth=3) =
    // Preamble: extract type/shape/edge info needed for closed-direction dispatch.
    let(
        closed_u    = row_wrap,
        closed_v    = col_wrap,
        type_u      = closed_u ? "closed" : "clamped",
        type_v      = closed_v ? "closed" : "clamped",
        n_rows      = len(points),
        n_cols      = len(points[0]),
        ue_norm_pre = is_undef(u_edges) ? undef : force_list(u_edges),
        ve_norm_pre = is_undef(v_edges) ? undef : force_list(v_edges),
        has_ue_pre  = !is_undef(ue_norm_pre) && len(ue_norm_pre) > 0,
        has_ve_pre  = !is_undef(ve_norm_pre) && len(ve_norm_pre) > 0
    )
    // v_edges on a closed v-direction: rotate columns so the first crease column
    // becomes the v=0/v=1 boundary, append a copy at the end for the C0 seam,
    // then recurse with type_v="clamped".  Remaining crease indices are shifted
    // into the rotated coordinate system.
    has_ve_pre && type_v == "closed" ?
        let(
            ve_sorted  = sort(ve_norm_pre),
            rot        = ve_sorted[0],
            new_pts    = [for (row = points)
                              concat([for (l = [rot:1:n_cols-1]) row[l]],
                                     [for (l = [0:1:rot-1])      row[l]],
                                     [row[rot]])],
            adj_ve_raw = [for (i = [1:1:len(ve_sorted)-1])
                              let(j = (ve_sorted[i] - rot + n_cols) % n_cols)
                              if (j > 0) j],
            adj_ve     = len(adj_ve_raw) == 0 ? undef : adj_ve_raw
        )
        let(inner = nurbs_interp_surface(new_pts, degree, method=method,
                row_wrap=(type_u == "closed"), col_wrap=false,
                first_row_deriv=first_row_deriv, last_row_deriv=last_row_deriv,
                first_col_deriv=first_col_deriv, last_col_deriv=last_col_deriv,
                normal1=normal1, normal2=normal2,
                flat_end1=flat_end1, flat_end2=flat_end2, flat_edges=flat_edges,
                u_edges=u_edges, v_edges=adj_ve,
                extra_pts=extra_pts, smooth=smooth))
        [inner[0], inner[1], inner[2], inner[3], inner[4], inner[5],
         [(len(inner) > 6 ? inner[6][0] : undef), rot],
         [_surface_params_u(points, method, type_u == "closed"),
          _surface_params_v(points, method, type_v == "closed")]]
    // u_edges on a closed u-direction: rotate rows so the first crease row
    // becomes the u=0/u=1 boundary, append a copy at the end, recurse clamped.
    : has_ue_pre && type_u == "closed" ?
        let(
            ue_sorted  = sort(ue_norm_pre),
            rot        = ue_sorted[0],
            new_pts    = concat([for (k = [rot:1:n_rows-1]) points[k]],
                                [for (k = [0:1:rot-1])      points[k]],
                                [points[rot]]),
            adj_ue_raw = [for (i = [1:1:len(ue_sorted)-1])
                              let(j = (ue_sorted[i] - rot + n_rows) % n_rows)
                              if (j > 0) j],
            adj_ue     = len(adj_ue_raw) == 0 ? undef : adj_ue_raw
        )
        let(inner = nurbs_interp_surface(new_pts, degree, method=method,
                row_wrap=false, col_wrap=(type_v == "closed"),
                first_row_deriv=first_row_deriv, last_row_deriv=last_row_deriv,
                first_col_deriv=first_col_deriv, last_col_deriv=last_col_deriv,
                normal1=normal1, normal2=normal2,
                flat_end1=flat_end1, flat_end2=flat_end2, flat_edges=flat_edges,
                u_edges=adj_ue, v_edges=v_edges,
                extra_pts=extra_pts, smooth=smooth))
        [inner[0], inner[1], inner[2], inner[3], inner[4], inner[5],
         [rot, (len(inner) > 6 ? inner[6][1] : undef)],
         [_surface_params_u(points, method, type_u == "closed"),
          _surface_params_v(points, method, type_v == "closed")]]
    // Normal path: both directions already clamped, or no conflicting edge constraints.
    : let(
        p_u    = is_list(degree) ? degree[0] : degree,
        p_v    = is_list(degree) ? degree[1] : degree,
        ep_u     = is_list(extra_pts) ? extra_pts[0] : extra_pts,
        ep_v     = is_list(extra_pts) ? extra_pts[1] : extra_pts,
        smooth_u = is_list(smooth) ? smooth[0] : smooth,
        smooth_v = is_list(smooth) ? smooth[1] : smooth,
        n_rows = len(points),
        n_cols = len(points[0]),
        dim    = len(points[0][0]),
        // Scalar-vector promotion: if the caller passes a single vector instead of
        // a list of vectors, repeat() it to the required length.  A single vector
        // is detected as a list whose first element is a number, not a list.
        first_row_deriv = is_undef(first_row_deriv) || is_list(first_row_deriv[0]) ? first_row_deriv
                      : repeat(first_row_deriv, n_cols),
        last_row_deriv = is_undef(last_row_deriv) || is_list(last_row_deriv[0]) ? last_row_deriv
                      : repeat(last_row_deriv, n_cols),
        first_col_deriv = is_undef(first_col_deriv) || is_list(first_col_deriv[0]) ? first_col_deriv
                      : repeat(first_col_deriv, n_rows),
        last_col_deriv = is_undef(last_col_deriv) || is_list(last_col_deriv[0]) ? last_col_deriv
                      : repeat(last_col_deriv, n_rows),
        // Treat an all-undef derivative list the same as undef.
        has_sud = !is_undef(first_row_deriv) && num_defined(first_row_deriv) > 0,
        has_eud = !is_undef(last_row_deriv) && num_defined(last_row_deriv) > 0,
        has_svd = !is_undef(first_col_deriv) && num_defined(first_col_deriv) > 0,
        has_evd = !is_undef(last_col_deriv) && num_defined(last_col_deriv) > 0,
        has_sn  = !is_undef(normal1),
        has_en  = !is_undef(normal2),
        // normal1/normal2: apex edges only (all boundary points identical, e.g. cone tip).
        // Auto-detect u=0/v=0 direction; u=0 (first row) takes priority.
        start_u_apex = has_sn && max([for (pt = points[0])       norm(pt - points[0][0])]) < 1e-10,
        start_v_apex = has_sn && max([for (k = [0:1:n_rows-1])   norm(points[k][0] - points[0][0])]) < 1e-10,
        end_u_apex   = has_en && max([for (pt = points[n_rows-1]) norm(pt - points[n_rows-1][0])]) < 1e-10,
        end_v_apex   = has_en && max([for (k = [0:1:n_rows-1])   norm(points[k][n_cols-1] - points[0][n_cols-1])]) < 1e-10,
        has_sun = has_sn && start_u_apex,
        has_eun = has_en && end_u_apex,
        has_svn = has_sn && !start_u_apex && start_v_apex,
        has_evn = has_en && !end_u_apex   && end_v_apex,
        start_u_degen = start_u_apex,
        start_v_degen = start_v_apex,
        end_u_degen   = end_u_apex,
        end_v_degen   = end_v_apex,
        // flat_end1/flat_end2: coplanar non-collinear edges (points span a plane).
        // Scalar or per-point list.  positive = closes inward, negative = flares outward.
        // Direction is determined by the clamped direction of the surface:
        //   type_u="clamped" → flat_end applies to row boundaries (u-direction, first/last row).
        //   type_v="clamped" → flat_end applies to column boundaries (v-direction, first/last col).
        // Exactly one direction must be clamped (enforced by assertion below).
        has_fe1    = !is_undef(flat_end1),
        has_fe2    = !is_undef(flat_end2),
        has_fe1_u  = has_fe1 && type_u == "clamped",
        has_fe1_v  = has_fe1 && type_v == "clamped",
        has_fe2_u  = has_fe2 && type_u == "clamped",
        has_fe2_v  = has_fe2 && type_v == "clamped",
        // Boundary edges for coplanar validation.
        fe1_edge   = has_fe1_u ? points[0]
                   : has_fe1_v ? [for (k = [0:1:n_rows-1]) points[k][0]]
                   : [],
        fe2_edge   = has_fe2_u ? points[n_rows-1]
                   : has_fe2_v ? [for (k = [0:1:n_rows-1]) points[k][n_cols-1]]
                   : [],
        fe1_ok     = !has_fe1 || (_is_coplanar_pts(fe1_edge) && !is_undef(_pts_plane_normal(fe1_edge))),
        fe2_ok     = !has_fe2 || (_is_coplanar_pts(fe2_edge) && !is_undef(_pts_plane_normal(fe2_edge))),
        // flat_edges= parsing: 4-element list [start_u, end_u, start_v, end_v].
        // Scalar shorthand: flat_edges=s expands to [s, s, s, s].
        fe_norm  = !is_undef(flat_edges) && !is_list(flat_edges)
                 ? [flat_edges, flat_edges, flat_edges, flat_edges]
                 : flat_edges,
        has_fe   = !is_undef(fe_norm),
        fe_su    = has_fe ? fe_norm[0] : undef,
        fe_eu    = has_fe ? fe_norm[1] : undef,
        fe_sv    = has_fe ? fe_norm[2] : undef,
        fe_ev    = has_fe ? fe_norm[3] : undef,
        has_fesu = has_fe && !is_undef(fe_su),
        has_feeu = has_fe && !is_undef(fe_eu),
        has_fesv = has_fe && !is_undef(fe_sv),
        has_feev = has_fe && !is_undef(fe_ev),
        // Edge (C0 discontinuity) support.  Singleton promotion: scalar → list.
        ue_norm = is_undef(u_edges) ? undef : force_list(u_edges),
        ve_norm = is_undef(v_edges) ? undef : force_list(v_edges),
        has_ue = !is_undef(ue_norm) && len(ue_norm) > 0,
        has_ve = !is_undef(ve_norm) && len(ve_norm) > 0
    )
    assert(is_list(points) && n_rows >= 2,
           "nurbs_interp_surface: need at least 2 rows")
    assert(n_cols >= 2,
           "nurbs_interp_surface: need at least 2 columns")
    assert(min([for (row = points) len(row)]) == max([for (row = points) len(row)]),
           "nurbs_interp_surface: all rows must have the same number of columns")
    assert(is_num(p_u) && p_u >= 1 && is_num(p_v) && p_v >= 1,
           "nurbs_interp_surface: degree must be >= 1")
    assert(method == "length" || method == "centripetal" || method == "dynamic"
               || method == "foley" || method == "fang",
           str("nurbs_interp_surface: method must be \"length\", \"centripetal\", \"dynamic\", \"foley\", or \"fang\", got \"", method, "\""))
    assert(is_num(ep_u) && ep_u >= 0 && ep_u == floor(ep_u),
           str("nurbs_interp_surface: extra_pts (u) must be a non-negative integer, got ", ep_u))
    assert(is_num(ep_v) && ep_v >= 0 && ep_v == floor(ep_v),
           str("nurbs_interp_surface: extra_pts (v) must be a non-negative integer, got ", ep_v))
    assert(ep_u == 0 || p_u >= 2,
           "nurbs_interp_surface: extra_pts in u-direction requires u-degree >= 2")
    assert(ep_v == 0 || p_v >= 2,
           "nurbs_interp_surface: extra_pts in v-direction requires v-degree >= 2")
    assert(n_rows >= p_u + 1,
           str("nurbs_interp_surface: need at least ", p_u+1,
               " rows for u-degree ", p_u, ", got ", n_rows))
    assert(n_cols >= p_v + 1,
           str("nurbs_interp_surface: need at least ", p_v+1,
               " columns for v-degree ", p_v, ", got ", n_cols))
    assert(!(has_sud || has_eud || has_sun || has_eun || has_fesu || has_feeu || has_fe1_u || has_fe2_u) || type_u == "clamped",
           "nurbs_interp_surface: u-direction derivative/normal/flat_end/flat_edges params require type_u=\"clamped\"")
    assert(!(has_svd || has_evd || has_svn || has_evn || has_fesv || has_feev || has_fe1_v || has_fe2_v) || type_v == "clamped",
           "nurbs_interp_surface: v-direction derivative/normal/flat_end/flat_edges params require type_v=\"clamped\"")
    assert(!has_sud || len(first_row_deriv) == n_cols,
           str("nurbs_interp_surface: first_row_deriv must have ", n_cols,
               " entries (one per column), got ", is_undef(first_row_deriv) ? 0 : len(first_row_deriv)))
    assert(!has_eud || len(last_row_deriv) == n_cols,
           str("nurbs_interp_surface: last_row_deriv must have ", n_cols,
               " entries (one per column), got ", is_undef(last_row_deriv) ? 0 : len(last_row_deriv)))
    assert(!has_svd || len(first_col_deriv) == n_rows,
           str("nurbs_interp_surface: first_col_deriv must have ", n_rows,
               " entries (one per row), got ", is_undef(first_col_deriv) ? 0 : len(first_col_deriv)))
    assert(!has_evd || len(last_col_deriv) == n_rows,
           str("nurbs_interp_surface: last_col_deriv must have ", n_rows,
               " entries (one per row), got ", is_undef(last_col_deriv) ? 0 : len(last_col_deriv)))
    // normal1/normal2 assertions: apex edges only.
    assert(!has_sn || (start_u_degen || start_v_degen),
           "nurbs_interp_surface: normal1 requires a degenerate start edge (first row or first column must be all the same point)")
    assert(!has_en || (end_u_degen || end_v_degen),
           "nurbs_interp_surface: normal2 requires a degenerate end edge (last row or last column must be all the same point)")
    assert(!has_sn || !(start_u_degen && start_v_degen),
           "nurbs_interp_surface: normal1 is ambiguous — both u=0 and v=0 edges are degenerate; use first_row_deriv or first_col_deriv explicitly")
    assert(!has_en || !(end_u_degen && end_v_degen),
           "nurbs_interp_surface: normal2 is ambiguous — both u=1 and v=1 edges are degenerate; use last_row_deriv or last_col_deriv explicitly")
    assert(!(has_sun && has_sud),
           "nurbs_interp_surface: normal1 resolves to u-direction but first_row_deriv was also given")
    assert(!(has_eun && has_eud),
           "nurbs_interp_surface: normal2 resolves to u-direction but last_row_deriv was also given")
    assert(!(has_svn && has_svd),
           "nurbs_interp_surface: normal1 resolves to v-direction but first_col_deriv was also given")
    assert(!(has_evn && has_evd),
           "nurbs_interp_surface: normal2 resolves to v-direction but last_col_deriv was also given")
    // flat_end1/flat_end2 assertions.
    // Direction is determined by the clamped type; surface must be mixed clamped/closed.
    assert(!has_fe1 || (type_u == "clamped") != (type_v == "clamped"),
           "nurbs_interp_surface: flat_end1 requires the surface to be clamped in one direction and closed in the other")
    assert(!has_fe2 || (type_u == "clamped") != (type_v == "clamped"),
           "nurbs_interp_surface: flat_end2 requires the surface to be clamped in one direction and closed in the other")
    assert(fe1_ok,
           has_fe1_u
           ? "nurbs_interp_surface: flat_end1 requires the u=0 boundary (first row) to be coplanar and non-collinear"
           : "nurbs_interp_surface: flat_end1 requires the v=0 boundary (first column) to be coplanar and non-collinear. If your first row is coplanar, swap type order (e.g. [\"clamped\",\"closed\"] instead of [\"closed\",\"clamped\"])")
    assert(fe2_ok,
           has_fe2_u
           ? "nurbs_interp_surface: flat_end2 requires the u=1 boundary (last row) to be coplanar and non-collinear"
           : "nurbs_interp_surface: flat_end2 requires the v=1 boundary (last column) to be coplanar and non-collinear. If your last row is coplanar, swap type order (e.g. [\"clamped\",\"closed\"] instead of [\"closed\",\"clamped\"])")
    assert(!(has_fe1_u && has_sud),
           "nurbs_interp_surface: flat_end1 conflicts with first_row_deriv")
    assert(!(has_fe2_u && has_eud),
           "nurbs_interp_surface: flat_end2 conflicts with last_row_deriv")
    assert(!(has_fe1_v && has_svd),
           "nurbs_interp_surface: flat_end1 conflicts with first_col_deriv")
    assert(!(has_fe2_v && has_evd),
           "nurbs_interp_surface: flat_end2 conflicts with last_col_deriv")
    assert(!(has_fe1_u && has_fesu),
           "nurbs_interp_surface: flat_end1 conflicts with flat_edges[0] on same edge")
    assert(!(has_fe2_u && has_feeu),
           "nurbs_interp_surface: flat_end2 conflicts with flat_edges[1] on same edge")
    assert(!(has_fe1_v && has_fesv),
           "nurbs_interp_surface: flat_end1 conflicts with flat_edges[2] on same edge")
    assert(!(has_fe2_v && has_feev),
           "nurbs_interp_surface: flat_end2 conflicts with flat_edges[3] on same edge")
    assert(!has_fe1 || is_num(flat_end1) || len(flat_end1) == (has_fe1_u ? n_cols : n_rows),
           str("nurbs_interp_surface: flat_end1 list must have ", has_fe1_u ? n_cols : n_rows, " entries"))
    assert(!has_fe2 || is_num(flat_end2) || len(flat_end2) == (has_fe2_u ? n_cols : n_rows),
           str("nurbs_interp_surface: flat_end2 list must have ", has_fe2_u ? n_cols : n_rows, " entries"))
    // flat_edges assertions.
    assert(!has_fe || (is_list(fe_norm) && len(fe_norm) == 4),
           "nurbs_interp_surface: flat_edges must be a scalar or 4-element list [start_u, end_u, start_v, end_v]")
    assert(!(has_fesu && has_sud),
           "nurbs_interp_surface: flat_edges[0] (start_u) conflicts with first_row_deriv")
    assert(!(has_feeu && has_eud),
           "nurbs_interp_surface: flat_edges[1] (end_u) conflicts with last_row_deriv")
    assert(!(has_fesv && has_svd),
           "nurbs_interp_surface: flat_edges[2] (start_v) conflicts with first_col_deriv")
    assert(!(has_feev && has_evd),
           "nurbs_interp_surface: flat_edges[3] (end_v) conflicts with last_col_deriv")
    assert(!(has_fesu && has_sun),
           "nurbs_interp_surface: flat_edges[0] (start_u) conflicts with normal1 on same edge")
    assert(!(has_feeu && has_eun),
           "nurbs_interp_surface: flat_edges[1] (end_u) conflicts with normal2 on same edge")
    assert(!(has_fesv && has_svn),
           "nurbs_interp_surface: flat_edges[2] (start_v) conflicts with normal1 on same edge")
    assert(!(has_feev && has_evn),
           "nurbs_interp_surface: flat_edges[3] (end_v) conflicts with normal2 on same edge")
    assert(!has_fesu || !is_list(fe_su) || len(fe_su) == n_cols,
           str("nurbs_interp_surface: flat_edges[0] scale list must have ", n_cols, " entries (one per column)"))
    assert(!has_feeu || !is_list(fe_eu) || len(fe_eu) == n_cols,
           str("nurbs_interp_surface: flat_edges[1] scale list must have ", n_cols, " entries (one per column)"))
    assert(!has_fesv || !is_list(fe_sv) || len(fe_sv) == n_rows,
           str("nurbs_interp_surface: flat_edges[2] scale list must have ", n_rows, " entries (one per row)"))
    assert(!has_feev || !is_list(fe_ev) || len(fe_ev) == n_rows,
           str("nurbs_interp_surface: flat_edges[3] scale list must have ", n_rows, " entries (one per row)"))
    // Edge (C0) validation.
    assert(!has_ue || type_u == "clamped",
           "nurbs_interp_surface: u_edges requires type_u=\"clamped\"")
    assert(!has_ve || type_v == "clamped",
           "nurbs_interp_surface: v_edges requires type_v=\"clamped\"")
    assert(!has_ue || (min(ue_norm) >= 1 && max(ue_norm) <= n_rows-2),
           str("nurbs_interp_surface: u_edges indices must be interior (1..", n_rows-2, ")"))
    assert(!has_ve || (min(ve_norm) >= 1 && max(ve_norm) <= n_cols-2),
           str("nurbs_interp_surface: v_edges indices must be interior (1..", n_cols-2, ")"))
    // u_edges / v_edges are compatible with same-direction boundary derivatives,
    // normals, and flat_edges: the first/last segment of the edge-aware system
    // carries the boundary derivative constraint.
    let(
        // Boundary plane for flat_edges=: cross product of two perimeter vectors.
        // Guarded so degenerate geometry can't produce NaN when flat_edges is unused.
        fe_e1    = has_fe ? (points[0][n_cols-1] - points[0][0])    : [1,0,0],
        fe_e2    = has_fe ? (points[n_rows-1][0] - points[0][0])    : [0,1,0],
        fe_N_raw = has_fe ? cross(fe_e1, fe_e2)                     : [0,0,1],
        fe_N_hat = fe_N_raw / max(norm(fe_N_raw), 1e-15),
        // Per-edge flat-outward derivative lists; undef when edge not active.
        // Direction at each point: from adjacent interior point toward edge,
        // projected into the boundary plane, then normalized and scaled.
        flat_su_der = !has_fesu ? undef :
            [for (j = [0:1:n_cols-1])
                let(
                    d      = points[1][j]       - points[0][j],
                    d_flat = d - (d * fe_N_hat) * fe_N_hat,
                    d_hat  = d_flat / max(norm(d_flat), 1e-15),
                    s      = is_list(fe_su) ? fe_su[j] : fe_su
                ) d_hat * s],
        flat_eu_der = !has_feeu ? undef :
            [for (j = [0:1:n_cols-1])
                let(
                    d      = points[n_rows-1][j] - points[n_rows-2][j],
                    d_flat = d - (d * fe_N_hat) * fe_N_hat,
                    d_hat  = d_flat / max(norm(d_flat), 1e-15),
                    s      = is_list(fe_eu) ? fe_eu[j] : fe_eu
                ) d_hat * s],
        flat_sv_der = !has_fesv ? undef :
            [for (k = [0:1:n_rows-1])
                let(
                    d      = points[k][1]       - points[k][0],
                    d_flat = d - (d * fe_N_hat) * fe_N_hat,
                    d_hat  = d_flat / max(norm(d_flat), 1e-15),
                    s      = is_list(fe_sv) ? fe_sv[k] : fe_sv
                ) d_hat * s],
        flat_ev_der = !has_feev ? undef :
            [for (k = [0:1:n_rows-1])
                let(
                    d      = points[k][n_cols-1] - points[k][n_cols-2],
                    d_flat = d - (d * fe_N_hat) * fe_N_hat,
                    d_hat  = d_flat / max(norm(d_flat), 1e-15),
                    s      = is_list(fe_ev) ? fe_ev[k] : fe_ev
                ) d_hat * s]
    )
    assert(!has_fesu || min([for (j = [0:1:n_cols-1]) let(d = points[1][j] - points[0][j], d_flat = d - (d * fe_N_hat) * fe_N_hat) norm(d_flat)]) > 1e-10,
           "nurbs_interp_surface: flat_edges start_u direction is perpendicular to the boundary plane at one or more points")
    assert(!has_feeu || min([for (j = [0:1:n_cols-1]) let(d = points[n_rows-1][j] - points[n_rows-2][j], d_flat = d - (d * fe_N_hat) * fe_N_hat) norm(d_flat)]) > 1e-10,
           "nurbs_interp_surface: flat_edges end_u direction is perpendicular to the boundary plane at one or more points")
    assert(!has_fesv || min([for (k = [0:1:n_rows-1]) let(d = points[k][1] - points[k][0], d_flat = d - (d * fe_N_hat) * fe_N_hat) norm(d_flat)]) > 1e-10,
           "nurbs_interp_surface: flat_edges start_v direction is perpendicular to the boundary plane at one or more points")
    assert(!has_feev || min([for (k = [0:1:n_rows-1]) let(d = points[k][n_cols-1] - points[k][n_cols-2], d_flat = d - (d * fe_N_hat) * fe_N_hat) norm(d_flat)]) > 1e-10,
           "nurbs_interp_surface: flat_edges end_v direction is perpendicular to the boundary plane at one or more points")
    assert(!has_fe || is_coplanar(concat(
        points[0], points[n_rows-1],
        [for (k = [1:1:n_rows-2]) points[k][0]],
        [for (k = [1:1:n_rows-2]) points[k][n_cols-1]]), eps=1e-6),
        "nurbs_interp_surface: flat_edges= requires all four boundary edges to be coplanar")
    let(
        // Compute effective derivative lists.
        // Priority: normal1/normal2 (apex) > flat_end1/flat_end2 (coplanar) > flat_edges > explicit *_der=.
        // Apex (all boundary points identical): fan outward from apex, user axis vector N.
        //   End-edge apex tangents are negated because _apex_tangents() returns outward
        //   (apex→ring) vectors; negating gives inward (ring→apex), making the surface
        //   converge to the apex tip at the correct parametric direction.
        // Coplanar (flat_end): _coplanar_inward_tangents() returns in-plane vectors
        //   oriented toward the polygon interior using the polygon winding order.
        //   Positive scale closes inward, negative flares outward.
        //   flat_end1 result is negated: _coplanar_inward_tangents returns outward
        //   for the start boundary; negating gives the correct inward direction.
        //   flat_end2 uses the same function without negation (end boundary sign matches).
        //   Periodic tangent differences used when the cross-direction is "closed".
        first_row_deriv_eff = has_sun
            ? _apex_tangents(normal1, points[0][0], points[1])
            : has_fe1_u
            ? [for (v = _coplanar_inward_tangents(flat_end1, points[0], points[1],
                                        periodic=(type_v == "closed"))) -v]
            : has_fesu ? flat_su_der
            : first_row_deriv,
        last_row_deriv_eff = has_eun
            ? [for (v = _apex_tangents(normal2, points[n_rows-1][0], points[n_rows-2])) -v]
            : has_fe2_u
            ? _coplanar_inward_tangents(flat_end2, points[n_rows-1], points[n_rows-2],
                                        periodic=(type_v == "closed"))
            : has_feeu ? flat_eu_der
            : last_row_deriv,
        first_col_deriv_eff = has_svn
            ? _apex_tangents(normal1, points[0][0],
                             [for (k = [0:1:n_rows-1]) points[k][1]])
            : has_fe1_v
            ? [for (v = _coplanar_inward_tangents(flat_end1,
                                        [for (k = [0:1:n_rows-1]) points[k][0]],
                                        [for (k = [0:1:n_rows-1]) points[k][1]],
                                        periodic=(type_u == "closed"))) -v]
            : has_fesv ? flat_sv_der
            : first_col_deriv,
        last_col_deriv_eff = has_evn
            ? [for (v = _apex_tangents(normal2, points[0][n_cols-1],
                                       [for (k = [0:1:n_rows-1]) points[k][n_cols-2]])) -v]
            : has_fe2_v
            ? _coplanar_inward_tangents(flat_end2,
                                        [for (k = [0:1:n_rows-1]) points[k][n_cols-1]],
                                        [for (k = [0:1:n_rows-1]) points[k][n_cols-2]],
                                        periodic=(type_u == "closed"))
            : has_feev ? flat_ev_der
            : last_col_deriv,
        has_sud_eff = has_sud || has_sun || has_fesu || has_fe1_u,
        has_eud_eff = has_eud || has_eun || has_feeu || has_fe2_u,
        has_svd_eff = has_svd || has_svn || has_fesv || has_fe1_v,
        has_evd_eff = has_evd || has_evn || has_feev || has_fe2_v
    )
    // u_edges / v_edges boundary-derivative segment-size checks.
    // A derivative-carrying edge segment needs at least 3 rows/columns;
    // with only 2 the degree-reduced knot vector becomes degenerate.
    assert(!(has_ue && has_sud_eff && ue_norm[0] + 1 < 3),
           !has_ue ? "" :
           str("nurbs_interp_surface: u_edges=", ue_norm,
               " creates a ", ue_norm[0]+1, "-row first segment (rows 0-",
               ue_norm[0], ") which is too short to carry the start-u derivative constraint. ",
               "Move the first u_edges index to at least 2"))
    assert(!(has_ue && has_eud_eff && n_rows - last(ue_norm) < 3),
           !has_ue ? "" :
           str("nurbs_interp_surface: u_edges=", ue_norm,
               " creates a ", n_rows - last(ue_norm), "-row last segment (rows ",
               last(ue_norm), "-", n_rows-1, ") which is too short to carry the end-u derivative constraint. ",
               "Move the last u_edges index to at most ", n_rows - 3))
    assert(!(has_ve && has_svd_eff && ve_norm[0] + 1 < 3),
           !has_ve ? "" :
           str("nurbs_interp_surface: v_edges=", ve_norm,
               " creates a ", ve_norm[0]+1, "-column first segment (columns 0-",
               ve_norm[0], ") which is too short to carry the start-v derivative constraint. ",
               "Move the first v_edges index to at least 2"))
    assert(!(has_ve && has_evd_eff && n_cols - last(ve_norm) < 3),
           !has_ve ? "" :
           str("nurbs_interp_surface: v_edges=", ve_norm,
               " creates a ", n_cols - last(ve_norm), "-column last segment (columns ",
               last(ve_norm), "-", n_cols-1, ") which is too short to carry the end-v derivative constraint. ",
               "Move the last v_edges index to at most ", n_cols - 3))
    let(
        // Averaged parameterization in each direction
        u_params = _surface_params_u(points, method, type_u == "closed"),
        v_params = _surface_params_v(points, method, type_v == "closed"),

        // Per-row v-direction path lengths for scaling v-boundary tangents.
        // Follows the curve convention: user passes normalized vectors; code
        // scales by total chord length so a unit vector gives natural speed.
        v_path_lens = [for (k = [0:1:n_rows-1]) path_length(points[k])],

        // Per-column u-direction path lengths for scaling u-boundary tangents.
        u_path_lens = [for (l = [0:1:n_cols-1])
                           path_length([for (k = [0:1:n_rows-1]) points[k][l]])],

        // ----- Build v-direction system -----
        // When v_edges is active, precompute per-segment collocation systems.
        // Otherwise use the standard (or derivative-extended) system.
        v_edge_sys = has_ve
                   ? _build_edge_systems(v_params, p_v, ve_norm,
                                          has_sd=has_svd_eff,
                                          has_ed=has_evd_eff,
                                          extra_pts=ep_v, label="v") : undef,
        v_sys   = has_ve ? undef
                : (has_svd_eff || has_evd_eff)
                ? _build_clamped_system_with_derivs(v_params, p_v, has_svd_eff, has_evd_eff, ep_v)
                : _build_interp_system(v_params, p_v, type_v, ep_v),
        N_v     = has_ve ? undef : v_sys[0],
        // When underdetermined (extra_pts), build regularization matrix for v.
        M_v      = has_ve ? undef : len(N_v[0]),
        N_rows_v = has_ve ? undef : len(N_v),
        ns_v     = !has_ve && M_v > N_rows_v,
        R_reg_v  = !ns_v ? undef
                 : let(vk = v_sys[1],
                       vint = type_v == "clamped"
                            ? [for (i = [1:1:len(vk)-2]) vk[i]]
                            : undef,
                       vU = type_v == "clamped"
                          ? _full_clamped_knots(vint, p_v)
                          : _full_closed_knots(vk, M_v, p_v))
                   smooth_v <= 2
                   ? [for (i = [0:1:M_v-1]) _ltl_row(M_v, i, smooth_v, periodic=(type_v=="closed"))]
                   : _bending_energy_matrix(M_v, p_v, vU, periodic=(type_v=="closed")),

        // ----- Pass 1: Interpolate rows in v-direction -----
        // With v_edges: solve each row via edge-aware segmented system.
        // Without: same A_v matrix for every row; only the RHS changes per row.
        R_raw = has_ve
            ? [for (k = [0:1:n_rows-1])
                _solve_with_edges(v_edge_sys, points[k],
                                  v_params, ve_norm, p_v,
                    start_deriv = has_svd_eff
                        ? _force_deriv_dim(first_col_deriv_eff[k], dim) * v_path_lens[k]
                        : undef,
                    end_deriv = has_evd_eff
                        ? _force_deriv_dim(last_col_deriv_eff[k], dim) * v_path_lens[k]
                        : undef,
                    smooth = smooth_v)]
            : undef,
        R = has_ve
            ? [for (r = R_raw) r[0]]
            : [for (k = [0:1:n_rows-1])
                let(rhs = concat(
                        points[k],
                        has_svd_eff
                            ? [_force_deriv_dim(first_col_deriv_eff[k], dim) * v_path_lens[k]]
                            : [],
                        has_evd_eff
                            ? [_force_deriv_dim(last_col_deriv_eff[k], dim) * v_path_lens[k]]
                            : []))
                ns_v ? _nullspace_solve(R_reg_v, N_v, rhs)
                     : linear_solve(N_v, rhs)
            ],

        v_knots  = has_ve ? R_raw[0][1] : v_sys[1],
        n_v_ctrl = len(R[0]),

        // ----- Pass 1.5: Project u-boundary tangents into v-control space -----
        // ∂S/∂u along u=0 or u=1 is given at the n_cols data v-positions.
        // To use them as derivative RHS in the u-direction column solves, we
        // must express them in the v B-spline control basis — done by solving
        // the same v-system.  When v_edges is active, project through the
        // edge-aware segmented system instead.
        zero_v = repeat(0, dim),
        _su_der_data = has_sud_eff
            ? [for (l = [0:1:n_cols-1])
                _force_deriv_dim(first_row_deriv_eff[l], dim) * u_path_lens[l]]
            : undef,
        _eu_der_data = has_eud_eff
            ? [for (l = [0:1:n_cols-1])
                _force_deriv_dim(last_row_deriv_eff[l], dim) * u_path_lens[l]]
            : undef,
        T_u_start = has_sud_eff
                  ? has_ve
                    ? _solve_with_edges(v_edge_sys, _su_der_data,
                                        v_params, ve_norm, p_v,
                          start_deriv = has_svd_eff ? zero_v : undef,
                          end_deriv   = has_evd_eff ? zero_v : undef,
                          smooth      = smooth_v)[0]
                    : let(_rhs = concat(_su_der_data,
                              has_svd_eff ? [zero_v] : [],
                              has_evd_eff ? [zero_v] : []))
                      ns_v ? _nullspace_solve(R_reg_v, N_v, _rhs)
                           : linear_solve(N_v, _rhs)
                  : undef,
        T_u_end   = has_eud_eff
                  ? has_ve
                    ? _solve_with_edges(v_edge_sys, _eu_der_data,
                                        v_params, ve_norm, p_v,
                          start_deriv = has_svd_eff ? zero_v : undef,
                          end_deriv   = has_evd_eff ? zero_v : undef,
                          smooth      = smooth_v)[0]
                    : let(_rhs = concat(_eu_der_data,
                              has_svd_eff ? [zero_v] : [],
                              has_evd_eff ? [zero_v] : []))
                      ns_v ? _nullspace_solve(R_reg_v, N_v, _rhs)
                           : linear_solve(N_v, _rhs)
                  : undef,

        // ----- Build u-direction system -----
        // When u_edges is active, precompute per-segment systems.
        u_edge_sys = has_ue
                   ? _build_edge_systems(u_params, p_u, ue_norm,
                                          has_sd=has_sud_eff,
                                          has_ed=has_eud_eff,
                                          extra_pts=ep_u, label="u") : undef,
        u_sys   = has_ue ? undef
                : (has_sud_eff || has_eud_eff)
                ? _build_clamped_system_with_derivs(u_params, p_u, has_sud_eff, has_eud_eff, ep_u)
                : _build_interp_system(u_params, p_u, type_u, ep_u),
        N_u     = has_ue ? undef : u_sys[0],
        // When underdetermined (extra_pts), build regularization matrix for u.
        M_u      = has_ue ? undef : len(N_u[0]),
        N_rows_u = has_ue ? undef : len(N_u),
        ns_u     = !has_ue && M_u > N_rows_u,
        R_reg_u  = !ns_u ? undef
                 : let(uk = u_sys[1],
                       uint = type_u == "clamped"
                            ? [for (i = [1:1:len(uk)-2]) uk[i]]
                            : undef,
                       uU = type_u == "clamped"
                          ? _full_clamped_knots(uint, p_u)
                          : _full_closed_knots(uk, M_u, p_u))
                   smooth_u <= 2
                   ? [for (i = [0:1:M_u-1]) _ltl_row(M_u, i, smooth_u, periodic=(type_u=="closed"))]
                   : _bending_energy_matrix(M_u, p_u, uU, periodic=(type_u=="closed")),

        // ----- Pass 2: Interpolate columns in u-direction -----
        // Transpose R so each entry is a column of intermediate points.
        R_T  = [for (j = [0:1:n_v_ctrl-1])
                    [for (k = [0:1:n_rows-1]) R[k][j]]],

        // With u_edges: solve each column via edge-aware segmented system.
        // Without: add u-tangent constraint rows to the RHS for each column j.
        P_T_raw = has_ue
            ? [for (j = [0:1:n_v_ctrl-1])
                _solve_with_edges(u_edge_sys, R_T[j],
                                  u_params, ue_norm, p_u,
                    start_deriv = has_sud_eff ? T_u_start[j] : undef,
                    end_deriv   = has_eud_eff ? T_u_end[j]   : undef,
                    smooth      = smooth_u)]
            : undef,
        P_T  = has_ue
            ? [for (r = P_T_raw) r[0]]
            : [for (j = [0:1:n_v_ctrl-1])
                let(rhs = concat(
                        R_T[j],
                        has_sud_eff ? [T_u_start[j]] : [],
                        has_eud_eff ? [T_u_end[j]]   : []))
                ns_u ? _nullspace_solve(R_reg_u, N_u, rhs)
                     : linear_solve(N_u, rhs)
            ],

        u_knots  = has_ue ? P_T_raw[0][1] : u_sys[1],

        // Transpose back to get the final control point grid.
        n_u_ctrl = len(P_T[0]),
        P        = [for (i = [0:1:n_u_ctrl-1])
                        [for (j = [0:1:n_v_ctrl-1]) P_T[j][i]]]
    )
    [[type_u, type_v], [p_u, p_v], P, [u_knots, v_knots], undef, undef, [0, 0],
     [u_params, v_params]];


// Module: nurbs_interp_surface()
// See Also: nurbs_interp_surface() (function form, above)

module nurbs_interp_surface(points, degree,
                            splinesteps=16, method="centripetal",
                            row_wrap=false, col_wrap=false,
                            style="default", reverse=false, triangulate=false,
                            caps=undef, cap1=undef, cap2=undef,
                            first_row_deriv=undef, last_row_deriv=undef,
                            first_col_deriv=undef, last_col_deriv=undef,
                            normal1=undef, normal2=undef,
                            flat_end1=undef, flat_end2=undef,
                            flat_edges=undef,
                            u_edges=undef, v_edges=undef,
                            extra_pts=0, smooth=3,
                            data_color="red", data_size=0) {
    result = nurbs_interp_surface(points, degree,
                 method=method, row_wrap=row_wrap, col_wrap=col_wrap,
                 first_row_deriv=first_row_deriv, last_row_deriv=last_row_deriv,
                 first_col_deriv=first_col_deriv, last_col_deriv=last_col_deriv,
                 normal1=normal1, normal2=normal2,
                 flat_end1=flat_end1, flat_end2=flat_end2,
                 flat_edges=flat_edges,
                 u_edges=u_edges, v_edges=v_edges,
                 extra_pts=extra_pts, smooth=smooth);
    vnf_polyhedron(nurbs_vnf(result, splinesteps=splinesteps, style=style,
                             reverse=reverse, triangulate=triangulate,
                             caps=caps, cap1=cap1, cap2=cap2));
    if (data_size > 0)
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
//   debug_nurbs_interp(data, 3, closed=true);
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
//   path = nurbs_interp_curve(data, 3, splinesteps=16, closed=true);
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
//   path = nurbs_interp_curve(data, 3, splinesteps=32);
//   stroke(path, width=0.5);
//   color("red") move_copies(data) circle(r=0.25, $fn=16);
//
//
// ---- Example 6: Low-level access ----
//   nurbs_interp() returns a NURBS parameter list that can be passed
//   directly to nurbs_curve(), debug_nurbs(), etc.
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   result = nurbs_interp(data, 3);
//   curve = nurbs_curve(result, splinesteps=24);
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
//   path = nurbs_interp_curve(data3d, 3, splinesteps=32, closed=true);
//   stroke(path, width=1, closed=true);
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
//   color("orange") stroke(nurbs_interp_curve(sharp, 3, method="centripetal"), width=0.1);
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
//       nurbs_interp_curve(data, 3, start_deriv=[0,1], end_deriv=[0,-1]),
//       width=0.3);
//   // Tangent: start going right, end going right:
//   color("red") stroke(
//       nurbs_interp_curve(data, 3, start_deriv=[1,0], end_deriv=[1,0]),
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
//       nurbs_interp_curve(data, 3, start_deriv=[0,1]),
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
//   nurbs_interp_surface(data, 3, splinesteps=8);
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
//   nurbs_interp_surface(data, [2,3], splinesteps=8);
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
//       [for (i = [0:1:5])
//           let(a = i * 360/6)
//           [r*cos(a), r*sin(a), u]]
//   ];
//   nurbs_interp_surface(data, 3, splinesteps=8,
//             col_wrap=true);
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
//   data = [for (i = [0:1:N-1])
//       let(phi = i * 360/N)
//       [for (j = [0:1:N-1])
//           let(theta = j * 360/N)
//           [(R + r*cos(theta))*cos(phi),
//            (R + r*cos(theta))*sin(phi),
//            r*sin(theta)]]
//   ];
//   nurbs_interp_surface(data, 3, splinesteps=12,
//             row_wrap=true, col_wrap=true);
//
//
// ---- Example 15: Low-level surface access ----
//   nurbs_interp_surface() returns a NURBS parameter list that can be
//   passed directly to nurbs_vnf().
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
//   result = nurbs_interp_surface(data, 2);
//   vnf = nurbs_vnf(result, splinesteps=12);
//   vnf_polyhedron(vnf);
//   color("red")
//       for (row = data) for (pt = row)
//           translate(pt) sphere(r=1, $fn=16);
