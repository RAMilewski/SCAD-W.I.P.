Method A (expanded-parameter knot averaging)

Let the spline degree be p=3p=3. Compute your chord-length parameters uiui​ as usual (nonuniform is fine).

    Build an expanded parameter sequence u~u~ by duplicating uiui​ once per extra derivative constraint at qiqi​:

    always include uiui​ once for position
    if q′(ui)q′(ui​) is specified, include one extra copy of uiui​
    if q′′(ui)q′′(ui​) is specified, include another extra copy, etc.

Example: if you have points i=0..ni=0..n and first derivatives at indices in a set DD, then

    u~u~ contains uiui​ twice for i∈Di∈D, otherwise once.

Let N=(len(u~)−1)N=(len(u~)−1), so you now have N+1N+1 “conditions”.

    Form the clamped knot vector U={U0,…,UN+p+1}U={U0​,…,UN+p+1​} by the standard averaging formula but using u~u~:

    Clamped ends:
        U0=U1=U2=U3=u~0U0​=U1​=U2​=U3​=u~0​
        UN+1=UN+2=UN+3=UN+4=u~NUN+1​=UN+2​=UN+3​=UN+4​=u~N​

    Interior knots (general pp):
    $$U_{j+p}=\frac{1}{p}\sum_{k=j}^{j+p-1}\tilde u_k,\quad j=1,\dots,N-p$$

For cubic ($p=3$):
Uj+3=u~j+u~j+1+u~j+23,j=1,…,N−3
Uj+3​=3u~j​+u~j+1​+u~j+2​​,j=1,…,N−3

This naturally “clusters” knots near parameters where you duplicated u~u~, giving you the extra DOFs to satisfy derivative constraints.
Method B (knot insertion at derivative parameters)

    Build the knot vector UU from the original (non-duplicated) uiui​ using ordinary knot averaging (your current method).
    For each specified derivative condition at parameter uiui​, insert one knot with value uiui​ into UU (repeat if you have multiple derivative constraints at the same uiui​).

Each inserted knot increases the knot vector length by 1, hence increases the number of control points/DOFs by 1, matching your “one extra knot per derivative” requirement.
