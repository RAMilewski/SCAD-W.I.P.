 keep true interpolation ($AP=Q$ exactly) and add extra control points ($M>N$), you can still choose a unique “best” interpolant by solving a quadratic minimization with linear equality constraints. This remains a linear system solve (a KKT/saddle-point system) because both the constraints and the regularizer are linear/quadratic in the control points.

Let:

    Q∈RN×dQ∈RN×d be your data points ($d=2$ or 33)
    P∈RM×dP∈RM×d be unknown control points
    A∈RN×MA∈RN×M with Aij=Nj,p(ui)Aij​=Nj,p​(ui​) so interpolation is AP=QAP=Q

Constrained regularized interpolation (exact constraints)

Pick a “fairness” functional and solve
min⁡P12∥LP∥2s.t.AP=Q
Pmin​21​∥LP∥2s.t.AP=Q

where LL is a linear operator (matrix) you choose.

The optimality conditions give the KKT linear system
[LTLATA0][PΛ]=[0Q]
[LTLA​AT0​][PΛ​]=[0Q​]

Solve this once per coordinate (or treat PP as stacked coordinates; same idea). This system is linear; it’s symmetric but indefinite (standard in constrained least-squares).

A key requirement: the constraints must be feasible (i.e., there exists some PP with AP=QAP=Q). With M≥NM≥N and a reasonable knot/parameter setup, this is typically feasible.
Common regularizers LL (what they mean)

    Minimum-norm interpolant (simple, not always “fair”)

    Choose L=IL=I:
    $$
    \min_P |P|^2 \ \text{s.t.}\ AP=Q
    $$
    This picks the smallest-control-vector solution among all interpolants. Linear, easy, but the resulting curve fairness is indirect.

    Control-polygon smoothness (very common; easy; sparse)

    Choose LL as a finite-difference operator on control points:
        First-difference: (LP)j=Pj+1−Pj(LP)j​=Pj+1​−Pj​ (penalizes length/variation)
        Second-difference: (LP)j=Pj−1−2Pj+Pj+1(LP)j​=Pj−1​−2Pj​+Pj+1​ (penalizes “bending” of the control polygon; usually the best default)
        This tends to produce visually smooth curves and keeps matrices sparse/banded.

    True spline “bending energy” (continuous curvature-like penalty)

    Penalize squared second derivative of the curve:
    $$
    \min_P \int |C''(u)|^2,du \quad \text{s.t.}\ AP=Q
    $$
    This is still quadratic in PP and becomes
    $$
    \min_P \frac{1}{2} P^T R P\ \text{s.t.}\ AP=Q
    $$
    where
    $$
    R_{jk} = \int N''{j,p}(u),N''{k,p}(u),du
    $$
    Then the KKT system uses RR in place of LTLLTL. This is a very principled “fair curve” choice.
