/*
    NURBS / B-spline interpolation through a set of data points, using BOSL2.

    This file provides TWO interpolation modes:

      1) mode="global"
         - Global (classic) interpolation:
             * Builds one open-clamped B-spline curve of a chosen degree (default cubic).
             * Solves a linear system A * control = dataPoints to find control points.
             * IMPORTANT: Global means changing/inserting one data point can affect the entire curve.

      2) mode="local"
         - Piecewise/local interpolation:
             * Builds a curve as a sequence of independent cubic segments.
             * Each segment is constructed from local tangents (Catmull–Rom / Hermite style).
             * Each segment is expressed as a cubic Bezier, and any cubic Bezier can be represented
               as a (non-rational) cubic NURBS with knot vector [0,0,0,0,1,1,1,1].
             * IMPORTANT: Local means changing/inserting one data point affects only neighboring spans.

    WHAT YOU GET:
      - A function that returns curve "data" (controls/knots/etc.)
      - A function that samples either curve type into a polyline you can stroke(), polygon(), sweep(), etc.

    DEPENDENCIES:
      - BOSL2: std.scad gives us linalg + nurbs_curve + helpers like cumsum(), repeat(), norm().
      - We rely on BOSL2 linear_solve(A,b) for the global interpolation solve.

    NOTES ABOUT "NURBS":
      - The global and local routines below generate NON-RATIONAL splines (all weights = 1).
      - You can extend to rational NURBS by adding per-control weights, but interpolation then becomes
        non-linear if you also want to solve for weights.

    PARAMETERIZATION OPTIONS ("param" argument):
      - "uniform"
          * u or t values are equally spaced.
          * Fast, but can behave poorly when point spacing is uneven.
      - "chord"
          * spacing proportional to chord length between points.
          * Usually better than uniform when spacing varies.
      - "centripetal"  (often best default)
          * spacing proportional to sqrt(chord length).
          * Tends to reduce loops/overshoot compared to chord-length Catmull-Rom / splines.

    MODE OPTIONS ("mode" argument):
      - "global"
          * One curve, degree selectable (degree=1..)
          * Requires at least degree+1 points.
      - "local"
          * Many cubic segments, always degree=3 per segment.
          * Requires at least 2 points.
          * Has "tension" control to reduce overshoot.

    DEGREE OPTIONS ("degree" argument, global mode only):
      - Typical values: 1 (polyline), 2 (quadratic), 3 (cubic, common), 4+ (higher order).
      - Higher degree can wiggle more and requires more points.
      - Must satisfy: len(pts) >= degree+1

    TENSION OPTIONS ("tension" argument, local mode only):
      - Range: [0..1] recommended
          * 0   = standard Catmull–Rom style tangents (smooth; can overshoot)
          * 0.5 = tighter curve, less overshoot
          * 1   = zero tangents => degenerates toward straight segments (polyline-ish)
      - Outside [0..1] can be used, but may produce extreme results.

    SPLINESTEPS OPTIONS ("splinesteps" argument):
      - Integer >= 1
      - Number of sample steps per curve (global) or per segment (local).
      - Higher = smoother polyline output (more points).
*/


// ============================================================
// GLOBAL INTERPOLATION (open-clamped B-spline; solve linear system)
// ============================================================

/*
    _nurbs_interp_params(pts, method)

    Returns parameter values u[i] in [0,1] for each data point.

    method options:
      - "uniform"      => u[i] = i/n
      - "chord"        => u proportional to chord length
      - "centripetal"  => u proportional to sqrt(chord length)  (often best)
*/
function _nurbs_interp_params(pts, method="chord") =
    let(n = len(pts)-1)
    assert(n >= 1, "Need at least 2 points")
    method=="uniform" ? [for(i=[0:n]) i/n] :
    let(
        // Segment "lengths" between successive points
        // chord: use d
        // centripetal: use sqrt(d)
        seg = [for(i=[1:n])
                let(d = norm(pts[i]-pts[i-1]))
                method=="centripetal" ? sqrt(d) : d
              ],
        total = max(1e-12, sum(seg)),
        cum = concat([0], cumsum(seg))
    )
    [for(i=[0:n]) cum[i]/total];


/*
    _nurbs_interp_knots(u, p)

    Builds open-clamped knot vector using the standard "averaging" method
    (often described in "The NURBS Book") for global interpolation.

    u : parameter list length n+1
    p : degree

    Output:
      Knot vector U of length (n + p + 2).

    Properties:
      - First p+1 knots are 0 (clamped start)
      - Last  p+1 knots are 1 (clamped end)
      - Interior knots are averages of consecutive u's
*/
function _nurbs_interp_knots(u, p) =
    let(
        n = len(u)-1,
        // number of interior knots = n - p
        interior = (n-p <= 0) ? [] :
            [for(j=[1 : n-p])
                (1/p) * sum([for(i=[j : j+p-1]) u[i]])
            ]
    )
    concat(repeat(0, p+1), interior, repeat(1, p+1));


/*
    _bspline_N(i, p, u, U)

    Cox–de Boor recursion for B-spline basis functions N_{i,p}(u).

    i : basis index
    p : degree
    u : parameter value
    U : knot vector

    NOTE:
      - Includes special-case so last basis evaluates to 1 at u==1.
*/
function _bspline_N(i, p, u, U) =
    let(n = len(U) - p - 2)   // n = #basis-1
    (p==0) ?
        ((U[i] <= u && u < U[i+1]) || (u==1 && i==n)) ? 1 : 0
    :
    let(
        d1 = U[i+p]   - U[i],
        d2 = U[i+p+1] - U[i+1],
        a  = (d1==0) ? 0 : (u - U[i])     / d1,
        b  = (d2==0) ? 0 : (U[i+p+1] - u) / d2
    )
    a * _bspline_N(i, p-1, u, U) + b * _bspline_N(i+1, p-1, u, U);


/*
    _nurbs_interp_matrix(u, p, U)

    Builds interpolation matrix A where:
      A[r][c] = N_{c,p}(u[r])

    For global interpolation:
      - #data points = #control points = n+1
      - A is (n+1) x (n+1)
*/
function _nurbs_interp_matrix(u, p, U) =
    let(n = len(u)-1)
    [for(r=[0:n]) [for(c=[0:n]) _bspline_N(c, p, u[r], U)]];


/*
    _nurbs_interp_controls(pts, p, u, U)

    Solves for control points C so that:
      curve(u[i]) == pts[i] for all i

    We do this by solving:
      A * C = P

    But P is vector-valued (2D/3D/ND), so we solve once per coordinate dimension.

    Requires BOSL2:
      linear_solve(A, b) returns x for A*x=b

    IMPORTANT:
      - This is a GLOBAL solve. Moving one data point can change all control points.
*/
function _nurbs_interp_controls(pts, p, u, U) =
    let(
        A   = _nurbs_interp_matrix(u, p, U),
        dim = len(pts[0]),
        n   = len(pts)-1
    )
    assert(len(pts) >= p+1, "Need at least degree+1 points for interpolation")
    [for(i=[0:n])
        [for(d=[0:dim-1])
            // Solve coordinate d:
            // A * x_d = P_d
            linear_solve(A, [for(r=[0:n]) pts[r][d] ])[i]
        ]
    ];


/*
    nurbs_interpolating_curve_data_global(pts, degree, param)

    Returns a record describing the GLOBAL interpolating curve:

      ["global", controlPts, knotVector, uParams]

    controlPts: computed control points
    knotVector: open-clamped knots
    uParams:    parameter values for each data point (in [0,1])

    To sample the curve, call BOSL2 nurbs_curve() with:
      nurbs_curve(control=controlPts, degree=degree, knots=knotVector, type="open", ...)
*/
function nurbs_interpolating_curve_data_global(pts, degree=3, param="chord") =
    let(
        u = _nurbs_interp_params(pts, method=param),
        U = _nurbs_interp_knots(u, degree),
        C = _nurbs_interp_controls(pts, degree, u, U)
    )
    ["global", C, U, u];


// ============================================================
// LOCAL / PIECEWISE INTERPOLATION (Catmull–Rom style -> Bezier -> NURBS)
// ============================================================

/*
    Local interpolation strategy:

      For each span [P_i, P_{i+1}] we build a cubic Bezier segment:
        B0 = P_i
        B3 = P_{i+1}
        B1 = P_i   + m_i   * (dt/3)
        B2 = P_{i+1} - m_{i+1} * (dt/3)

      where m_i is a tangent (derivative) estimate at P_i, and dt is the "time"
      between points i and i+1 from the chosen parameterization.

    Each cubic Bezier segment is exactly representable as a non-rational cubic NURBS
    with knot vector:
        [0,0,0,0, 1,1,1,1]

    BENEFITS:
      - LOCAL control: moving/inserting one point changes only adjacent segments
      - C1 continuous (tangent continuous) given consistent tangents

    LIMITATIONS:
      - This produces a piecewise curve (list of segments), not a single global knot vector.
      - Curvature continuity (C2) is not guaranteed.
*/


/*
    _local_t_params(pts, method)

    Returns a monotonic "time" parameter t[i] for each point.

    method options:
      - "uniform"      => t[i] = i
      - "chord"        => t increments by chord length
      - "centripetal"  => t increments by sqrt(chord length)

    NOTE:
      We do NOT normalize to [0,1] here; the actual dt spacing is used for tangents.
*/
function _local_t_params(pts, method="centripetal") =
    let(n = len(pts)-1)
    method=="uniform" ? [for(i=[0:n]) i] :
    let(seg = [for(i=[1:n])
                let(d = norm(pts[i]-pts[i-1]))
                method=="centripetal" ? sqrt(d) : d
              ])
    concat([0], cumsum(seg));


/*
    _local_tangents(pts, t, tension)

    Computes local tangent vectors m[i] at each data point.

    tension options (recommended range [0..1]):
      - 0   => standard Catmull–Rom style tangents
      - 0.5 => tighter curve, less overshoot
      - 1   => zero tangents (degenerates toward straight segments)

    Tangent formula:
      - endpoints: one-sided difference
      - interior:  centered difference (P_{i+1} - P_{i-1}) / (t_{i+1} - t_{i-1})

    Then scaled by (1 - tension).
*/
function _local_tangents(pts, t, tension=0) =
    let(
        n = len(pts)-1,
        s = 1 - tension
    )
    [for(i=[0:n])
        (i==0) ?
            s * (pts[1]-pts[0]) / max(1e-12, (t[1]-t[0]))
        : (i==n) ?
            s * (pts[n]-pts[n-1]) / max(1e-12, (t[n]-t[n-1]))
        :
            s * (pts[i+1]-pts[i-1]) / max(1e-12, (t[i+1]-t[i-1]))
    ];


/*
    _local_bezier_segments(pts, t, m)

    Builds a list of cubic Bezier control polygons, one per span.

    Output format:
      [
        [B0,B1,B2,B3],   // segment 0 from P0->P1
        [B0,B1,B2,B3],   // segment 1 from P1->P2
        ...
      ]
*/
function _local_bezier_segments(pts, t, m) =
    let(n = len(pts)-1)
    [for(i=[0:n-1])
        let(
            dt = t[i+1]-t[i],
            B0 = pts[i],
            B3 = pts[i+1],
            B1 = pts[i]   + m[i]   * (dt/3),
            B2 = pts[i+1] - m[i+1] * (dt/3)
        )
        [B0,B1,B2,B3]
    ];


/*
    nurbs_interpolating_curve_data_local(pts, param, tension)

    Returns a record describing the LOCAL interpolating curve:

      ["local", segmentList, tParams]

    where segmentList is:
      [
        [controlPtsForSegment0, knotsForSegment0],
        [controlPtsForSegment1, knotsForSegment1],
        ...
      ]

    Each segment uses:
      - degree = 3
      - knots  = [0,0,0,0,1,1,1,1]
*/
function nurbs_interpolating_curve_data_local(pts, param="centripetal", tension=0) =
    let(
        t   = _local_t_params(pts, method=param),
        m   = _local_tangents(pts, t, tension=tension),
        bez = _local_bezier_segments(pts, t, m),
        U   = [0,0,0,0, 1,1,1,1]
    )
    ["local", [for(seg=bez) [seg, U]], t];


// ============================================================
// PUBLIC API (choose global vs local)
// ============================================================

/*
    nurbs_interpolating_curve_data(pts, ...)

    Returns curve data in one of two formats depending on mode.

    Arguments:
      pts:
        - list of points
        - points may be 2D, 3D, or higher dimension as long as all points share dimension

      mode:
        - "global" (default)
            * One curve, global linear solve
            * Uses 'degree'
            * Uses 'param' as parameterization for the global interpolation
        - "local"
            * Piecewise cubic curve (list of segments)
            * degree is ignored (always cubic per segment)
            * Uses 'param' for local time spacing
            * Uses 'tension'

      degree: (global only)
        - integer >= 1
        - common: 2 or 3
        - requires len(pts) >= degree+1

      param:
        - "uniform" | "chord" | "centripetal"
        - global default could be "chord"; local default often "centripetal"

      tension: (local only)
        - recommended range [0..1]
        - see _local_tangents() comment above
*/
function nurbs_interpolating_curve_data(
    pts,
    degree=3,
    mode="global",
    param="centripetal",
    tension=0
) =
    (mode=="local")
        ? nurbs_interpolating_curve_data_local(pts, param=param, tension=tension)
        : nurbs_interpolating_curve_data_global(pts, degree=degree, param=param);


/*
    nurbs_interpolating_curve_points(pts, ...)

    Convenience sampler that returns a POLYLINE (list of points) approximating the curve.

    Arguments:
      splinesteps:
        - integer >= 1
        - For global mode: samples entire curve with this density
        - For local mode:  samples EACH segment with this density

    Output:
      - list of points (polyline) suitable for stroke(), polygon(), etc.
*/
function nurbs_interpolating_curve_points(
    pts,
    degree=3,
    mode="global",
    param="centripetal",
    tension=0,
    splinesteps=16
) =
    let(data = nurbs_interpolating_curve_data(pts, degree, mode, param, tension))
    (data[0]=="global")
        ? nurbs_curve(control=data[1], degree=degree, knots=data[2], type="open", splinesteps=splinesteps)
        : let(
            segs = data[1],
            // Sample each segment; drop first point of each segment except the first
            // to avoid duplicated points at segment boundaries.
            polylines = [for(k=[0:len(segs)-1])
                let(ctrl=segs[k][0], U=segs[k][1])
                nurbs_curve(control=ctrl, degree=3, knots=U, type="open", splinesteps=splinesteps)
            ]
          )
          concat(
            polylines[0],
            [for(k=[1:len(polylines)-1]) for(i=[1:len(polylines[k])-1]) polylines[k][i]]
          );


// ============================================================
// EXAMPLE USAGE
// ============================================================

/*
    Example:
      - Render both global and local interpolations of the same points.

    Tips:
      - If you see wiggles/overshoot:
          * global: try degree=2, or use param="centripetal"
          * local:  raise tension (e.g. 0.3 to 0.7), keep param="centripetal"
*/
pts = [[0,0],[20,10],[40,-5],[60,15],[80,0]];

curve_global = nurbs_interpolating_curve_points(
    pts,
    degree=3,            // used only in global
    mode="global",
    param="centripetal", // "uniform" | "chord" | "centripetal"
    splinesteps=24
);

curve_local = nurbs_interpolating_curve_points(
    pts,
    mode="local",
    param="centripetal", // "uniform" | "chord" | "centripetal"
    tension=0,           // 0..1 recommended
    splinesteps=24
);

// draw global curve above
translate([0,20]) stroke(curve_global, width=1);

// draw local curve below
stroke(curve_local, width=1);

// show data points
color("red") move_copies(pts) circle(r=1.5, $fn=16);

// optionally show control polygon for global mode:
// (uncomment to view; note it uses curve data returned by nurbs_interpolating_curve_data())
// gd = nurbs_interpolating_curve_data(pts, degree=3, mode="global", param="centripetal");
// color("lightblue") stroke(gd[1], width=0.5);
