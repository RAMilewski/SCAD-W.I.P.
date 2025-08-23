// NURBS interpolation (adaptive sampling) for OpenSCAD + BOSL2
// Drop-in: no external clamp() needed.

include <BOSL2/std.scad>

// ---- utilities ----
function _clamp(x,a,b) = min(max(x,a), b);
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
         tt = _clamp(t,0,1),
         Q = _vadd(A, _vmul(AB, tt))
    ) _norm(_vsub(P,Q));

// ---- tiny epsilon based on knot range ----
function _eps(knots) = let(r = knots[len(knots)-1]-knots[0]) max(1e-12, r*1e-12);

// ---- basis with endpoint handling ----
function _basis(i,k,u,knots) =
    (u >= knots[len(knots)-1] - _eps(knots)) ?
        ((k==0) ? ((i == len(knots)-2) ? 1 : 0)
                : ((i == len(knots)-k-2) ? 1 : 0))
    :
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
function nurbs_point(u, ctrl, w, p, knots) =
    let(
        n = len(ctrl)-1,
        ww = (is_undef(w) ? [ for(i=[0:n]) 1 ] :
              (len(w)==len(ctrl) ? w : assert(false, "weights length != control length"))),
        dim = _dim(ctrl),
        num = [ for (d=[0:dim-1])
                  sum([ for (i=[0:n]) _basis(i,p,u,knots) * ww[i] * ctrl[i][d] ]) ],
        den = sum([ for (i=[0:n]) _basis(i,p,u,knots) * ww[i] ])
    ) assert(den>0, "NURBS denominator zero at u")
      _vmul(num, 1/den);

// ---- Adaptive interpolation ----
function nurbs_path(ctrl, p, knots, w=[], u0=undef, u1=undef, tol=0.01, max_depth=12) =
    let(
        N = len(ctrl),
        _ = assert(len(knots) == N + p + 1, "Invalid knot vector length"),
        u_min = knots[p],
        u_max = knots[len(knots)-p-1],
        eps = _eps(knots),
        U0 = is_undef(u0) ? (u_min + eps) : max(u0, u_min + eps),
        U1 = is_undef(u1) ? (u_max - eps) : min(u1, u_max - eps),
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
    ? [P1]
    : let(
        left  = _nurbs_subdivide(ctrl,p,knots,w,u0,um,P0, Pm,tol,depth-1),
        right = _nurbs_subdivide(ctrl,p,knots,w,um,u1,Pm, P1,tol,depth-1)
      ) concat(left, right);

// ---- Drawer ----
module draw_nurbs(ctrl, p, knots, w=[], tol=0.01, max_depth=12, width=0.5) {
    path = nurbs_path(ctrl, p, knots, w=w, tol=tol, max_depth=max_depth);
    is2d = _dim(ctrl)==2;
    if (is2d) stroke(path, width=width, closed=false, endcaps="round");
    else for (pt = path) translate(pt) sphere(d=width);
}
