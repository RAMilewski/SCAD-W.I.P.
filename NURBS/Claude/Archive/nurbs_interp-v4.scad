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
//   For clamped curves, optional start and end tangent vectors can be
//   specified to control the curve direction at the endpoints (Piegl &
//   Tiller, "The NURBS Book", Section 9.2.2).
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


// =====================================================================
// SECTION: Parameterization
// =====================================================================

// Chord-length (or centripetal) parameterization for clamped/open curves.
// n+1 points -> n+1 values in [0, 1] with t_0=0, t_n=1.

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


// Parameterization for closed curves.
// n data points -> n values in [0, 1).  Includes closing segment.

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
    concat(
        [for (i = [0:p]) 0],
        interior_knots,
        [for (i = [0:p]) 1]
    );


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
        shift = raw[0],
        bar_knots = [for (u = raw) u - shift],
        shifted = [for (t = params)
                       let(s = t - shift)
                       s < 0 ? s + 1 : (s >= 1 ? s - 1 : s)]
    )
    [bar_knots, shifted];


// Full periodic knot vector for basis evaluation.
// n+2p+1 entries: p wrapped from end, n+1 bar knots, p wrapped from start.

function _full_periodic_knots(bar_knots, n, p) =
    let(T = bar_knots[n] - bar_knots[0])
    concat(
        [for (i = [n-p : n-1]) bar_knots[i] - T],
        bar_knots,
        [for (i = [1 : p]) bar_knots[i] + T]
    );


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
//                         [start_der=], [end_der=]);
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
//   the last.  Optionally specify start_der and/or end_der to control
//   the tangent direction and magnitude at the endpoints.  Each tangent
//   adds one control point to the result.
//   .
//   "closed": Smooth closed loop through all points.  Do NOT repeat the
//   first point at the end.
//   .
//   "open": Open (non-clamped) B-spline through all points.
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate
//   degree      = degree of the NURBS curve (commonly 3)
//   ---
//   centripetal = if true, use centripetal parameterization.  Default: false
//   type        = "clamped", "closed", or "open".  Default: "clamped"
//   start_der   = tangent vector at start (clamped only).  Default: undef
//   end_der     = tangent vector at end (clamped only).  Default: undef
//
// Returns:
//   [control_points, knots] for nurbs_curve(..., type=type)

function nurbs_interp(points, degree, centripetal=false, type="clamped",
                      start_der=undef, end_der=undef) =
    assert(is_list(points) && len(points) >= 2,
           "nurbs_interp: need at least 2 data points")
    assert(is_num(degree) && degree >= 1,
           "nurbs_interp: degree must be >= 1")
    assert(type == "clamped" || type == "closed" || type == "open",
           str("nurbs_interp: type must be \"clamped\", \"closed\", or \"open\"",
               ", got \"", type, "\""))
    assert(type == "clamped" || (is_undef(start_der) && is_undef(end_der)),
           "nurbs_interp: start_der/end_der only supported for type=\"clamped\"")
    type == "clamped" ? _nurbs_interp_clamped(points, degree, centripetal,
                                               start_der, end_der)
  : type == "closed"  ? _nurbs_interp_closed(points, degree, centripetal)
  :                     _nurbs_interp_open(points, degree, centripetal);


// ---------- CLAMPED interpolation ----------

function _nurbs_interp_clamped(points, degree, centripetal,
                                start_der, end_der) =
    let(
        n = len(points) - 1,
        p = degree,
        _ = assert(n >= p,
                str("nurbs_interp (clamped): need at least ", p+1,
                    " points for degree ", p, ", got ", n+1)),
        has_sd = !is_undef(start_der),
        has_ed = !is_undef(end_der)
    )
    (!has_sd && !has_ed)
      ? _nurbs_interp_clamped_basic(points, p, centripetal)
      : _nurbs_interp_clamped_deriv(points, p, centripetal,
                                     start_der, end_der,
                                     has_sd, has_ed);


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
        knots   = concat([0], int_kn, [1])
    )
    assert(control != [],
           "nurbs_interp (clamped): singular system")
    [control, knots];


// Clamped interpolation with endpoint derivatives (§9.2.2).
//
// Each specified derivative adds one control point and one extra
// interior knot.  The derivative conditions are:
//   C'(0)   = (p / U_{p+1}) * (P_1 - P_0)
//   C'(1)   = (p / (1 - U_{m-p-1})) * (P_{N-1} - P_{N-2})
// which gives linear equations on adjacent control points.

function _nurbs_interp_clamped_deriv(points, p, centripetal,
                                      start_der, end_der,
                                      has_sd, has_ed) =
    let(
        n = len(points) - 1,
        n_extra = (has_sd ? 1 : 0) + (has_ed ? 1 : 0),
        N = n + 1 + n_extra,   // total control points (N-1 = last index)

        params = _interp_params(points, centripetal),

        // Standard interior knots (would be used for n+1 control points)
        std_int = _avg_knots_interior(params, p),

        // Insert extra knots near boundaries for the derivative DOFs.
        start_knot = !has_sd ? []
                   : len(std_int) > 0
                     ? [std_int[0] / 2]
                     : has_ed ? [1/3] : [1/2],
        end_knot   = !has_ed ? []
                   : len(std_int) > 0
                     ? [(last(std_int) + 1) / 2]
                     : has_sd ? [2/3] : [1/2],
        int_knots = concat(start_knot, std_int, end_knot),

        U_full = _full_clamped_knots(int_knots, p),
        m = len(U_full) - 1,

        // Knot values needed for derivative equations
        u_first = U_full[p + 1],
        u_last  = U_full[m - p - 1],

        // Build augmented system:
        //   Rows 0..n:  N_{j,p}(t_k) * P_j = D_k  (interpolation)
        //   Extra rows: derivative conditions
        interp_rows = [for (k = [0:n])
            [for (j = [0:N-1]) _nip(j, p, params[k], U_full)]
        ],

        // C'(0) = start_der  =>  P_1 - P_0 = (u_first/p) * start_der
        // C'(1) = end_der    =>  P_{N-1} - P_{N-2} = ((1-u_last)/p) * end_der
        deriv_rows = concat(
            has_sd ? [[for (j = [0:N-1]) j==0 ? -1 : j==1 ? 1 : 0]] : [],
            has_ed ? [[for (j = [0:N-1]) j==N-2 ? -1 : j==N-1 ? 1 : 0]] : []
        ),

        A = concat(interp_rows, deriv_rows),

        rhs = concat(
            points,
            has_sd ? [(u_first / p) * start_der] : [],
            has_ed ? [((1 - u_last) / p) * end_der] : []
        ),

        control = linear_solve(A, rhs),
        knots   = concat([0], int_knots, [1])
    )
    assert(control != [],
           "nurbs_interp (clamped+deriv): singular system")
    [control, knots];


// ---------- CLOSED interpolation ----------

function _nurbs_interp_closed(points, degree, centripetal) =
    let(
        n = len(points),
        p = degree,
        _ = assert(n >= p + 1,
                str("nurbs_interp (closed): need at least ", p+1,
                    " points for degree ", p, ", got ", n)),
        raw_params  = _interp_params_closed(points, centripetal),
        knot_result = _avg_knots_periodic(raw_params, p),
        bar_knots   = knot_result[0],
        params      = knot_result[1],
        U_periodic  = _full_periodic_knots(bar_knots, n, p),
        N_mat       = _collocation_matrix_periodic(params, n, p, U_periodic),
        control     = linear_solve(N_mat, points)
    )
    assert(control != [],
           "nurbs_interp (closed): singular system")
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
           "nurbs_interp (open): singular system")
    [control, U_full];


// =====================================================================
// SECTION: Convenience Functions
// =====================================================================

// Function: nurbs_interp_curve()
// Synopsis: Generates a curve path that interpolates through data points.
// See Also: nurbs_interp(), nurbs_curve()
//
// Usage:
//   path = nurbs_interp_curve(points, degree, [splinesteps],
//              [centripetal=], [type=], [start_der=], [end_der=]);

function nurbs_interp_curve(points, degree, splinesteps=16,
                            centripetal=false, type="clamped",
                            start_der=undef, end_der=undef) =
    let(
        result  = nurbs_interp(points, degree, centripetal=centripetal,
                               type=type, start_der=start_der,
                               end_der=end_der),
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
                          type="clamped", start_der=undef, end_der=undef,
                          width=0.1, size=undef,
                          data_color="magenta", data_size=undef) {
    result  = nurbs_interp(points, degree, centripetal=centripetal,
                           type=type, start_der=start_der,
                           end_der=end_der);
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
//   Specify start and/or end tangent vectors.  The tangent vector
//   controls both direction and magnitude — a longer vector makes
//   the curve "pull" more strongly in that direction.
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
//       nurbs_interp_curve(data, 3, start_der=[0,80], end_der=[0,-80]),
//       width=0.3);
//   // Tangent: start going right, end going right:
//   color("red") stroke(
//       nurbs_interp_curve(data, 3, start_der=[80,0], end_der=[80,0]),
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
//       nurbs_interp_curve(data, 3, start_der=[0,100]),
//       width=0.3);
//   color("black") move_copies(data) circle(r=0.25, $fn=16);
