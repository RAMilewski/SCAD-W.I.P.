// NURBS interpolation (adaptive sampling) for OpenSCAD + BOSL2
// Evaluates a NURBS curve and returns an interpolated polyline of points.
// Works with 2D or 3D control points.

// ---- deps ----
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

// ---- utilities ----
function _dim(P) = is_list(P[0]) ? len(P[0]) : undef;

function _vadd(a,b) = [for (i=[0:len(a)-1]) a[i]+b[i]];
function _vsub(a,b) = [for (i=[0:len(a)-1]) a[i]-b[i]];
function _vmul(a,s) = [for (i=[0:len(a)-1]) a[i]*s];

function _dot(a,b) = sum([for (i=[0:len(a)-1]) a[i]*b[i]]);
function _norm(a)  = sqrt(_dot(a,a));

// Distance from point P to segment AB
function _dist_point_seg(P,A,B) =
    let( AB=_vsub(B,A),
         AP=_vsub(P,A),
         t = ( _dot(AP,AB) ) / max( _dot(AB,AB), 1e-12 ),
         tt = clamp(t,0,1),
         Q = _vadd(A, _vmul(AB, tt))
    ) _norm(_vsub(P,Q));

// ---- Cox–de Boor basis ----
function _basis(i,k,u,knots) =
    (k==0) ?
        ((knots[i] <= u && u < knots[i+1]) ? 1 : 0) :
        let(
            denom1 = knots[i+k]   - knots[i],
            denom2 = knots[i+k+1] - knots[i+1],
            a = (denom1 > 0) ? (u - knots[i])      / denom1 : 0,
            b = (denom2 > 0) ? (knots[i+k+1] - u)  / denom2 : 0
        )
        a * _basis(i, k-1, u, knots) + b * _basis(i+1, k-1, u, knots);

// ---- NURBS point evaluator ----
/*
  ctrl   : list of control points [[x,y(,z)], ...]
  w      : list of weights (same length as ctrl); default all 1
  p      : degree (e.g., 3 for cubic)
  knots  : nondecreasing knot vector of length len(ctrl)+p+1
  u      : parameter in [u_min, u_max] (usually knots[p]..knots[-p-1])
*/
function nurbs_point(u, ctrl, w, p, knots) =
    let(
        n = len(ctrl)-1,
        ww = (is_undef(w) ? [ for(i=[0:n]) 1 ] :
              (len(w)==len(ctrl) ? w : assert(false, "weights length != control length"))),
        dim = _dim(ctrl),
        // weighted sums
        num = [ for (d=[0:dim-1])
                  sum([ for (i=[0:n]) _basis(i,p,u,knots) * ww[i] * ctrl[i][d] ]) ],
        den = sum([ for (i=[0:n]) _basis(i,p,u,knots) * ww[i] ])
    ) assert(den>0, "NURBS denominator zero at u")
      _vmul(num, 1/den);

// ---- Adaptive interpolation ----
/*
  Returns a polyline (list of points) sampling the NURBS between u0..u1 so that
  the mid-point deviation from the chord is <= tol (or max_depth reached).
*/
function nurbs_path(ctrl, p, knots, w=[], u0=undef, u1=undef, tol=0.01, max_depth=12) =
    let(
        n = len(ctrl),
        _ = assert(len(knots) == n + p + 1, "Invalid knot vector length"),
        U0 = is_undef(u0) ? knots[p] : u0,
        U1 = is_undef(u1) ? knots[len(knots)-p-1] : u1,
        P0 = nurbs_point(U0, ctrl, w, p, knots),
        P1 = nurbs_point(U1, ctrl, w, p, knots)
    )
    concat([P0], _nurbs_subdivide(ctrl,p,knots,w,U0,U1,P0,P1,tol,max_depth));

function _nurbs_subdivide(ctrl,p,knots,w,u0,u1,P0,P1,tol,depth) =
    let(
        um = (u0+u1)/2,
        Pm = nurbs_point(um, ctrl, w, p, knots),
        dev = _dist_point_seg(Pm, P0, P1)
    )
    (dev <= tol || depth<=0)
    ? [P1]  // chord is good enough—end with P1
    : let(
        left  = _nurbs_subdivide(ctrl,p,knots,w,u0,um,P0, Pm,tol,depth-1),
        right = _nurbs_subdivide(ctrl,p,knots,w,um,u1,Pm, P1,tol,depth-1)
      ) concat(left, right);

// ---- Convenience drawer (2D): uses BOSL2 stroke() ----
/*
  Draws the interpolated polyline as a stroked path (2D).
  For 3D paths, use the returned points for your own sweep/tube.
*/
module draw_nurbs(ctrl, p, knots, w=[], tol=0.01, max_depth=12, width=0.5) {
    path = nurbs_path(ctrl, p, knots, w=w, tol=tol, max_depth=max_depth);
    // If points are 2D, we can stroke; otherwise just place markers.
    is2d = _dim(ctrl)==2;
    if (is2d) {
        stroke(path, width=width, closed=false, endcaps="round");
    } else {
        // For 3D, draw small spheres along the path as a quick preview
        for (pt = path) translate(pt) sphere(d=width);
    }
}
