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
// Evaluates the i-th basis function of degree p at parameter u,
// given the full knot vector U.

function _nip(i, p, u, U) =
    let(maxidx = len(U) - 1)
    // Guard: return 0 if required knot indices are out of range
    (i < 0 || i + p + 1 > maxidx) ? 0
    : p == 0
      ? // Degree 0: indicator on [U_i, U_{i+1})
        // Special case: include right endpoint when it's the last knot
        (u >= U[i] && u < U[i+1]) ? 1
        : (abs(u - U[i+1]) < 1e-12 && abs(U[i+1] - U[maxidx]) < 1e-12) ? 1
        : 0
      : let(
            d1 = U[i+p] - U[i],
            d2 = U[i+p+1] - U[i+1],
            c1 = (abs(d1) > 1e-15)
                 ? (u - U[i]) / d1 * _nip(i, p-1, u, U) : 0,
            c2 = (abs(d2) > 1e-15)
                 ? (U[i+p+1] - u) / d2 * _nip(i+1, p-1, u, U) : 0
        )
        c1 + c2;


// =====================================================================
// SECTION: Parameterization
// =====================================================================

// Chord-length (or centripetal) parameterization for clamped/open curves.
// n+1 points -> n+1 parameter values in [0, 1].

function _interp_params(points, centripetal=false) =
    let(
        n = len(points) - 1,
        dists = [for (i = [0:n-1])
                     let(d = norm(points[i+1] - points[i]))
                     centripetal ? sqrt(d) : d],
        total = sum(dists)
    )
    total < 1e-15
      ? [for (i = [0:n]) i / n]
      : let(cs = cumsum(dists))
        concat([0], [for (i = [0:n-2]) cs[i] / total], [1]);


// Chord-length (or centripetal) parameterization for closed curves.
// n data points -> n parameter values in [0, 1) where 1.0 = period.
// Includes the closing segment from last point back to first.

function _interp_params_closed(points, centripetal=false) =
    let(
        n = len(points),
        dists = [for (i = [0:n-1])
                     let(d = norm(points[(i+1) % n] - points[i]))
                     centripetal ? sqrt(d) : d],
        total = sum(dists)
    )
    total < 1e-15
      ? [for (i = [0:n-1]) i / n]
      : let(cs = cumsum(dists))
        concat([0], [for (i = [0:n-2]) cs[i] / total]);


// =====================================================================
// SECTION: Knot Vector Construction
// =====================================================================

// Interior knots by averaging for clamped B-splines (Piegl & Tiller eq 9.8).

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
    concat(
        [for (i = [0:p]) 0],
        interior_knots,
        [for (i = [0:p]) 1]
    );


// Periodic "bar knots" for a closed B-spline with n control points,
// degree p.  Returns [bar_knots, shifted_params] where:
//   bar_knots = n+1 monotonically increasing values with bar[0]=0, bar[n]=1
//   shifted_params = the n parameter values shifted into [0, 1) to match
//
// The raw bar knots are computed by averaging p consecutive parameters
// from the extended (periodic) parameter sequence.  These don't start
// at 0, so we shift everything to get a clean [0, 1] range.

function _avg_knots_periodic(params, p) =
    let(
        n = len(params),
        // Compute raw bar knots by averaging extended parameters.
        // Extended parameter: t_m = params[m % n] + floor(m / n)
        raw = [for (j = [0:n])
                   sum([for (k = [0:p-1])
                            let(m = j + k)
                            params[m % n] + floor(m / n)
                       ]) / p
              ],
        // raw[n] - raw[0] == 1.0 (one period), guaranteed by construction.
        // Shift so that bar_knots start at 0:
        shift = raw[0],
        bar_knots = [for (u = raw) u - shift],
        // Shift parameter values by the same amount, wrapping into [0, 1)
        shifted = [for (t = params)
                       let(s = t - shift)
                       s < 0 ? s + 1 : (s >= 1 ? s - 1 : s)]
    )
    [bar_knots, shifted];


// Full periodic knot vector for basis function evaluation.
//
// Given bar knots [t_0, ..., t_n] with period T = t_n - t_0 = 1 and
// n distinct intervals, the full periodic knot vector has n + 2p + 1
// entries constructed by:
//   - Prepending p knots from the end of the previous period
//   - The n+1 bar knots themselves
//   - Appending p knots from the start of the next period
//
// For n=6, p=3, bar_knots = [t0, t1, t2, t3, t4, t5, t6]:
//   U = [t3-T, t4-T, t5-T,   t0, t1, t2, t3, t4, t5, t6,   t1+T, t2+T, t3+T]
//       <--- p=3 prepend -->  <----- n+1 bar knots ----->    <--- p=3 append -->
//
// This creates a valid knot vector where n periodic basis functions
// N_{0,p} through N_{n-1,p} form a partition of unity over [t_0, t_n).

function _full_periodic_knots(bar_knots, n, p) =
    let(T = bar_knots[n] - bar_knots[0])
    concat(
        [for (i = [n-p : n-1]) bar_knots[i] - T],   // p entries from end, shifted back
        bar_knots,                                     // n+1 bar knots
        [for (i = [1 : p]) bar_knots[i] + T]          // p entries from start, shifted forward
    );


// =====================================================================
// SECTION: Collocation Matrices
// =====================================================================

// Standard collocation matrix for clamped and open types.
// (n+1) x (n+1) matrix.  Row k: [ N_{0,p}(t_k), ..., N_{n,p}(t_k) ]

function _collocation_matrix(params, n, p, U) =
    [for (k = [0:n])
        [for (j = [0:n])
            _nip(j, p, params[k], U)
        ]
    ];


// Periodic collocation matrix for closed type.
// n x n matrix.
//
// In a periodic B-spline, BOSL2 wraps the first p control points to
// the end, creating n+p basis functions on the periodic knot vector.
// Basis N_{j+n} uses the same control point as N_j (for j = 0..p-1).
// So the effective basis for control point j is:
//   B_j(τ) = N_j(τ)  +  N_{j+n}(τ)    if j < p
//   B_j(τ) = N_j(τ)                     if j >= p

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
//   result = nurbs_interp(points, degree, [centripetal=], [type=]);
//
// Description:
//   Given a list of data points (2D or 3D) and a NURBS degree, computes
//   the control points and knot vector for a NURBS curve that passes
//   exactly through every data point.  The result is returned as a list
//   [control_points, knots] that can be fed directly to BOSL2's
//   nurbs_curve() function with the matching type parameter.
//   .
//   Three curve types are supported:
//   .
//   "clamped" (default): The curve starts at the first data point and
//   ends at the last, with tangent directions matching the first and
//   last control-point segments.  Requires at least degree+1 data points.
//   .
//   "closed": The curve forms a smooth closed loop passing through ALL
//   data points and returning smoothly to the start.  Do NOT repeat the
//   first point at the end — the closure is automatic.  Requires at
//   least degree+1 data points.
//   .
//   "open": An open (non-clamped) B-spline that passes through all data
//   points.  The underlying B-spline uses a uniform knot vector without
//   end-knot repetition.  Requires at least degree+1 data points.
//   .
//   The algorithm uses chord-length parameterization (or centripetal
//   if centripetal=true) and the knot-averaging method from Piegl &
//   Tiller, "The NURBS Book".
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate
//   degree      = degree of the NURBS curve (commonly 3 for cubic)
//   ---
//   centripetal = if true, use centripetal parameterization.  Default: false
//   type        = "clamped", "closed", or "open".  Default: "clamped"
//
// Returns:
//   A list [control_points, knots] where the knots are in the format
//   expected by nurbs_curve() for the specified type:
//     clamped: len(control) - degree + 1 knot values
//     closed:  len(control) + 1 knot values
//     open:    len(control) + degree + 1 knot values (full knot vector)

function nurbs_interp(points, degree, centripetal=false, type="clamped") =
    assert(is_list(points) && len(points) >= 2,
           "nurbs_interp: need at least 2 data points")
    assert(is_num(degree) && degree >= 1,
           "nurbs_interp: degree must be >= 1")
    assert(type == "clamped" || type == "closed" || type == "open",
           str("nurbs_interp: type must be \"clamped\", \"closed\", or \"open\"",
               ", got \"", type, "\""))
    type == "clamped" ? _nurbs_interp_clamped(points, degree, centripetal)
  : type == "closed"  ? _nurbs_interp_closed(points, degree, centripetal)
  :                     _nurbs_interp_open(points, degree, centripetal);


// ---------- CLAMPED interpolation ----------

function _nurbs_interp_clamped(points, degree, centripetal) =
    let(
        n = len(points) - 1,
        p = degree,
        _ = assert(n >= p,
                str("nurbs_interp (clamped): need at least ", p+1,
                    " points for degree ", p, ", got ", n+1)),
        params    = _interp_params(points, centripetal),
        int_knots = _avg_knots_interior(params, p),
        U_full    = _full_clamped_knots(int_knots, p),
        N_mat     = _collocation_matrix(params, n, p, U_full),
        control   = linear_solve(N_mat, points),
        knots     = concat([0], int_knots, [1])
    )
    assert(control != [],
           "nurbs_interp (clamped): singular system — could not solve")
    [control, knots];


// ---------- CLOSED interpolation ----------
//
// For n data points and degree p, we solve for n control points.
//
// The full periodic knot vector has n + 2p + 1 entries, built by
// wrapping p knots from each end of the bar knots.  This creates
// n independent periodic basis functions N_{0,p} .. N_{n-1,p} that
// together form a partition of unity over [t_0, t_n).
//
// We evaluate these basis functions at the n parameter values to
// build an n x n collocation matrix, then solve for control points.
//
// The bar knots (n+1 values) are passed to BOSL2 as the "knots"
// argument with type="closed".

function _nurbs_interp_closed(points, degree, centripetal) =
    let(
        n = len(points),
        p = degree,
        _ = assert(n >= p + 1,
                str("nurbs_interp (closed): need at least ", p+1,
                    " points for degree ", p, ", got ", n)),
        // Parameterize around the closed loop
        raw_params = _interp_params_closed(points, centripetal),
        // Compute periodic bar knots and shift parameters to match
        knot_result = _avg_knots_periodic(raw_params, p),
        bar_knots   = knot_result[0],
        params      = knot_result[1],
        // Build full periodic knot vector for basis evaluation
        U_periodic = _full_periodic_knots(bar_knots, n, p),
        // Build collocation matrix: N_{j,p}(τ_k) for j,k = 0..n-1
        N_mat      = _collocation_matrix_periodic(params, n, p, U_periodic),
        // Solve for control points
        control    = linear_solve(N_mat, points)
    )
    assert(control != [],
           "nurbs_interp (closed): singular system — could not solve")
    [control, bar_knots];


// ---------- OPEN interpolation ----------

function _nurbs_interp_open(points, degree, centripetal) =
    let(
        n = len(points) - 1,
        p = degree,
        _ = assert(n >= p,
                str("nurbs_interp (open): need at least ", p+1,
                    " points for degree ", p, ", got ", n+1)),
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
           "nurbs_interp (open): singular system — could not solve")
    [control, U_full];


// =====================================================================
// SECTION: Convenience Functions
// =====================================================================

// Function: nurbs_interp_curve()
// Synopsis: Generates a curve that interpolates through given data points.
// Topics: NURBS Curves, Interpolation
// See Also: nurbs_interp(), nurbs_curve()
//
// Usage:
//   path = nurbs_interp_curve(points, degree, [splinesteps], [centripetal=], [type=]);
//
// Description:
//   Convenience function that computes the NURBS interpolation and
//   immediately evaluates the curve.  Returns a path (list of points)
//   that passes through every input data point.

function nurbs_interp_curve(points, degree, splinesteps=16,
                            centripetal=false, type="clamped") =
    let(
        result  = nurbs_interp(points, degree, centripetal=centripetal, type=type),
        control = result[0],
        knots   = result[1]
    )
    nurbs_curve(control, degree, splinesteps=splinesteps,
                knots=knots, type=type);


// =====================================================================
// SECTION: Debug / Visualization
// =====================================================================

// Module: debug_nurbs_interp()
// Synopsis: Visualizes a NURBS interpolation with data points, control
//           polygon, and the interpolating curve.
// Topics: NURBS Curves, Interpolation, Debugging
// See Also: nurbs_interp(), debug_nurbs()
//
// Usage:
//   debug_nurbs_interp(points, degree, [splinesteps=], [centripetal=],
//                      [type=], [width=], [size=], [data_color=], [data_size=]);

module debug_nurbs_interp(points, degree, splinesteps=16, centripetal=false,
                          type="clamped", width=1, size=undef,
                          data_color="magenta", data_size=undef) {
    result  = nurbs_interp(points, degree, centripetal=centripetal, type=type);
    control = result[0];
    knots   = result[1];
    ds      = is_undef(data_size) ? 2 * width : data_size;
    sz      = is_undef(size)      ? 3 * width : size;

    // Draw the NURBS using BOSL2's debug_nurbs
    debug_nurbs(control, degree, splinesteps=splinesteps,
                knots=knots, type=type, width=width, size=sz);

    // Overlay the original data points
    color(data_color)
        for (i = [0 : len(points)-1])
            translate(points[i])
                if (len(points[i]) == 2)
                    circle(r=ds, $fn=16);
                else
                    sphere(r=ds, $fn=16);
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
// ---- Example 2: CLOSED ----
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
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [30,50], [60,40], [80,10], [50,-20], [20,-10]];
//   path = nurbs_interp_curve(data, 3, splinesteps=16, type="closed");
//   polygon(path);
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
//   color("red") move_copies(data) circle(r=1.5, $fn=16);
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
//   curve = nurbs_curve(control, 3, splinesteps=24, knots=knots, type="clamped");
//   stroke(curve);
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
//   color("red") move_copies(data3d) sphere(r=1.5, $fn=16);
//
//
// ---- Example 8: Centripetal parameterization ----
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   sharp = [[0,0], [5,40], [10,0], [50,0], [55,40], [60,0]];
//   color("blue")  stroke(nurbs_interp_curve(sharp, 3), width=0.5);
//   color("red")   stroke(nurbs_interp_curve(sharp, 3, centripetal=true), width=0.5);
//   color("green") move_copies(sharp) circle(r=1, $fn=16);
