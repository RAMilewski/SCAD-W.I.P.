//////////////////////////////////////////////////////////////////////
// LibFile: nurbs_interp.scad
//   NURBS Curve Interpolation through Data Points
//
//   Given a set of data points, computes the NURBS control points and
//   knot vector such that the resulting curve passes exactly through
//   every data point.  Uses the global interpolation algorithm from
//   Piegl & Tiller, "The NURBS Book", Chapter 9.
//
//   Requires BOSL2.  To use, add these lines to the top of your file:
//     include <BOSL2/std.scad>
//     include <BOSL2/nurbs.scad>
//     include <nurbs_interp.scad>
//
// Author: Claude (Anthropic), 2026
// License: BSD-2-Clause (same as BOSL2)
//////////////////////////////////////////////////////////////////////


// ---------- Internal helper: B-spline basis function (Cox-de Boor) ----------
//
// Evaluates basis function N_{i,p}(u) given the full knot vector U.
// Uses the standard recursive definition with safe division (0/0 = 0).

function _nip(i, p, u, U) =
    p == 0
      ? // Degree 0: indicator function on [U_i, U_{i+1})
        // Special case: include right endpoint when u equals the last knot
        (u >= U[i] && u < U[i+1]) ? 1
        : (u == U[i+1] && abs(u - U[len(U)-1]) < 1e-12) ? 1
        : 0
      : // Recursive case
        let(
            d1 = U[i+p] - U[i],
            d2 = U[i+p+1] - U[i+1],
            c1 = (d1 > 1e-15) ? (u - U[i]) / d1 * _nip(i, p-1, u, U) : 0,
            c2 = (d2 > 1e-15) ? (U[i+p+1] - u) / d2 * _nip(i+1, p-1, u, U) : 0
        )
        c1 + c2;


// ---------- Internal: Chord-length parameterization ----------
//
// Assigns parameter values t_k to each data point based on the
// cumulative chord length (or centripetal variant).
//   points     = list of data points
//   centripetal = if true, use sqrt(chord length) (better for sharp turns)

function _interp_params(points, centripetal=false) =
    let(
        n = len(points) - 1,
        dists = [for (i = [0:n-1])
                     let(d = norm(points[i+1] - points[i]))
                     centripetal ? sqrt(d) : d],
        total = sum(dists)
    )
    total < 1e-15
      ? [for (i = [0:n]) i / n]              // fallback: uniform
      : let(cs = cumsum(dists))
        concat([0], [for (i = [0:n-2]) cs[i] / total], [1]);


// ---------- Internal: Knot vector by averaging (Piegl & Tiller eq 9.8) ----------
//
// For n+1 data points and degree p the clamped knot vector has:
//   - first p+1 knots = 0
//   - last  p+1 knots = 1
//   - n-p internal knots computed by averaging the parameter values
//
// Returns just the distinct knot values [0, k1, ..., k_{n-p}, 1]
// which is exactly what BOSL2's nurbs_curve() wants for type="clamped".

function _avg_knots(params, p) =
    let(
        n = len(params) - 1,
        num_internal = n - p          // number of interior knots
    )
    num_internal <= 0
      ? []                            // degree >= n, no interior knots needed
      : [for (j = [1:num_internal])
             sum([for (i = [j : j + p - 1]) params[i]]) / p
        ];


// ---------- Internal: Build full clamped knot vector for basis evaluation ----------
//
// Adds the (p+1)-fold repeated end knots that the Cox-de Boor recursion needs.

function _full_clamped_knots(interior_knots, p) =
    concat(
        [for (i = [0:p]) 0],
        interior_knots,
        [for (i = [0:p]) 1]
    );


// ---------- Internal: Assemble collocation matrix ----------
//
// Row k contains [ N_{0,p}(t_k),  N_{1,p}(t_k),  ...,  N_{n,p}(t_k) ]
// evaluated using the full knot vector U.

function _collocation_matrix(params, n, p, U) =
    [for (k = [0:n])
        [for (j = [0:n])
            _nip(j, p, params[k], U)
        ]
    ];


// ====================================================================
// Function: nurbs_interp()
// Synopsis: Finds NURBS control points that interpolate through given data points.
// Topics: NURBS Curves, Interpolation
// See Also: nurbs_curve(), debug_nurbs()
//
// Usage:
//   result = nurbs_interp(points, degree);
//   result = nurbs_interp(points, degree, centripetal=true);
//
// Description:
//   Given a list of data points (2D or 3D) and a NURBS degree, computes
//   the control points and knot vector for a clamped NURBS curve that
//   passes exactly through every data point.  The result is returned as
//   a list [control_points, knots] that can be fed directly to the
//   BOSL2 nurbs_curve() function.
//   .
//   The algorithm uses chord-length parameterization (or centripetal
//   parameterization if centripetal=true) and computes the knot vector
//   using the averaging method from Piegl & Tiller, "The NURBS Book".
//   .
//   The degree must be at least 1 and at most len(points)-1.  The most
//   common choice is degree=3 (cubic), which gives C2 continuity.
//   .
//   The returned curve starts at the first data point and ends at the
//   last data point (clamped NURBS behavior).
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate through
//   degree      = degree of the NURBS curve (commonly 3 for cubic)
//   ---
//   centripetal = if true, use centripetal parameterization instead of
//                 chord-length.  Can give better results when data points
//                 have sharp turns.  Default: false
//
// Returns:
//   A list [control_points, knots] where:
//     control_points = list of NURBS control points (same dimension as input)
//     knots          = knot vector to pass to nurbs_curve() with type="clamped"

function nurbs_interp(points, degree, centripetal=false) =
    assert(is_list(points) && len(points) >= 2,
           "nurbs_interp: need at least 2 data points")
    assert(is_num(degree) && degree >= 1,
           "nurbs_interp: degree must be >= 1")
    let(
        n   = len(points) - 1,
        p   = min(degree, n),       // clamp degree to max possible
        _   = assert(p == degree,
                str("nurbs_interp: degree ", degree,
                    " is too high for ", n+1, " points (max ", n, ")")),

        // Step 1: Parameterize data points
        params = _interp_params(points, centripetal),

        // Step 2: Compute interior knots by averaging
        int_knots = _avg_knots(params, p),

        // Step 3: Build the full knot vector for basis evaluation
        U = _full_clamped_knots(int_knots, p),

        // Step 4: Assemble collocation matrix  N[k][j] = N_{j,p}(t_k)
        N_mat = _collocation_matrix(params, n, p, U),

        // Step 5: Solve  N * P = D  for control points P
        //         linear_solve handles matrix right-hand sides, so this
        //         solves for all coordinates simultaneously.
        control = linear_solve(N_mat, points),

        // Step 6: Assemble the knot vector for BOSL2's nurbs_curve().
        //         For type="clamped", BOSL2 expects len(control)-degree+1 knots
        //         which equals n-p+2 = len(int_knots)+2.
        knots = concat([0], int_knots, [1])
    )
    assert(control != [],
           "nurbs_interp: singular system — could not solve for control points")
    [control, knots];


// ====================================================================
// Function: nurbs_interp_curve()
// Synopsis: Generates a curve that interpolates through given data points.
// Topics: NURBS Curves, Interpolation
//
// Usage:
//   path = nurbs_interp_curve(points, degree, splinesteps, [centripetal=]);
//
// Description:
//   Convenience function that computes the NURBS interpolation and
//   immediately evaluates the curve.  Returns a path (list of points)
//   that passes through every input data point with the given number
//   of splinesteps between each knot.
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate through
//   degree      = degree of the NURBS curve (commonly 3 for cubic)
//   splinesteps = number of curve segments between each pair of knots
//   ---
//   centripetal = use centripetal parameterization.  Default: false

function nurbs_interp_curve(points, degree, splinesteps=16, centripetal=false) =
    let(
        result  = nurbs_interp(points, degree, centripetal=centripetal),
        control = result[0],
        knots   = result[1]
    )
    nurbs_curve(control, degree, splinesteps=splinesteps,
                knots=knots, type="clamped");


// ====================================================================
// Module: debug_nurbs_interp()
// Synopsis: Visualizes a NURBS interpolation, showing the data points,
//           computed control polygon, and the interpolating curve.
// Topics: NURBS Curves, Interpolation, Debugging
//
// Usage:
//   debug_nurbs_interp(points, degree, [splinesteps=], [centripetal=],
//                      [width=], [size=], [data_color=], [data_size=]);
//
// Description:
//   A debugging/visualization module that shows:
//     - The original data points (as colored dots)
//     - The computed NURBS control polygon and control points (via debug_nurbs)
//     - The interpolating curve
//
// Arguments:
//   points      = list of 2D or 3D data points to interpolate through
//   degree      = degree of the NURBS curve (commonly 3 for cubic)
//   splinesteps = curve segments between each knot pair.  Default: 16
//   centripetal = use centripetal parameterization.  Default: false
//   width       = width of the curve stroke.  Default: 1
//   size        = size of text labels.  Default: 3*width
//   data_color  = color used for the data points.  Default: "magenta"
//   data_size   = radius of data point markers.  Default: 2*width

module debug_nurbs_interp(points, degree, splinesteps=16, centripetal=false,
                          width=1, size=undef, data_color="magenta",
                          data_size=undef) {
    result  = nurbs_interp(points, degree, centripetal=centripetal);
    control = result[0];
    knots   = result[1];
    ds      = is_undef(data_size) ? 2 * width : data_size;
    sz      = is_undef(size)      ? 3 * width : size;

    // Draw the NURBS using BOSL2's debug_nurbs
    debug_nurbs(control, degree, splinesteps=splinesteps,
                knots=knots, type="clamped", width=width, size=sz);

    // Overlay the original data points
    color(data_color)
        for (i = [0 : len(points)-1])
            translate(points[i])
                if (len(points[i]) == 2)
                    circle(r=ds, $fn=16);
                else
                    sphere(r=ds, $fn=16);
}


// ===================== USAGE EXAMPLES =============================
//
// Example 1: Basic cubic interpolation through 2D points
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   debug_nurbs_interp(data, 3);
//
//
// Example 2: Get just the interpolating curve as a path
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   path = nurbs_interp_curve(data, 3, splinesteps=32);
//   stroke(path, width=0.5);
//   color("red") move_copies(data) circle(r=1.5, $fn=16);
//
//
// Example 3: Using the low-level function for full control
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//   result = nurbs_interp(data, 3);
//   control = result[0];  // the computed control points
//   knots   = result[1];  // the knot vector
//   // Now use nurbs_curve() directly with full access to all options:
//   curve = nurbs_curve(control, 3, splinesteps=24, knots=knots, type="clamped");
//   stroke(curve);
//
//
// Example 4: 3D interpolation
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   data3d = [[0,0,0],[10,20,5],[20,10,15],[30,25,10],[40,5,20],[50,15,5]];
//   path = nurbs_interp_curve(data3d, 3, splinesteps=32);
//   stroke(path);
//   color("red") move_copies(data3d) sphere(r=1, $fn=16);
//
//
// Example 5: Centripetal parameterization for sharp turns
//
//   include <BOSL2/std.scad>
//   include <BOSL2/nurbs.scad>
//   include <nurbs_interp.scad>
//
//   sharp_data = [[0,0], [5,40], [10,0], [50,0], [55,40], [60,0]];
//   // Compare chord-length vs centripetal:
//   color("blue")  stroke(nurbs_interp_curve(sharp_data, 3), width=0.5);
//   color("red")   stroke(nurbs_interp_curve(sharp_data, 3, centripetal=true), width=0.5);
//   color("green") move_copies(sharp_data) circle(r=1, $fn=16);
