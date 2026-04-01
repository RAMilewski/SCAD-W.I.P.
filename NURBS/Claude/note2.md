1) Use a null-space (equality-constrained QP) solve via pivoted QR of ATAT

You are solving the classic equality-constrained quadratic problem
min⁡x12xTRx−b1Txs.t.Ax=b2,
xmin​21​xTRx−b1T​xs.t.Ax=b2​,

whose KKT system is [RATA0][RA​AT0​].

Compute a rank-revealing QR of ATAT:
ATP=Q[RA0],
ATP=Q[RA​0​],

where:

    PP is a permutation of the constraints (rows of AA),
    Q=[Q1  Q2]Q=[Q1​Q2​] with Q1∈Rn×rQ1​∈Rn×r spanning the row space of AA and Q2∈Rn×(n−r)Q2​∈Rn×(n−r) spanning N(A)N(A),
    RA∈Rr×mRA​∈Rr×m is upper trapezoidal; if AA has full row rank then r=mr=m and RARA​ is square upper triangular.

Step A: get an exactly feasible particular solution xpxp​

Using A=P RATQ1TA=PRAT​Q1T​, the constraint becomes
RAT(Q1Tx)=PTb2.
RAT​(Q1T​x)=PTb2​.

If r=mr=m (full row rank), solve the triangular system:

    u=Q1Txu=Q1T​x from RATu=PTb2RAT​u=PTb2​
    set xp=Q1uxp​=Q1​u (this satisfies Axp=b2Axp​=b2​ exactly, up to floating error)

If r<mr<m (rank-deficient), pivoted QR tells you that. Then you can:

    check consistency (whether PTb2PTb2​ lies in the span of the first rr columns),
    drop dependent constraints (those corresponding to tiny diagonals in RARA​) to keep the problem well-posed while still enforcing the independent constraints exactly.

Step B: minimize in the null space (no constraints to worry about)

Write all feasible xx as
x=xp+Q2z.
x=xp​+Q2​z.

Plugging into the objective gives an unconstrained SPD system in zz:
(Q2TRQ2) z=Q2T(b1−Rxp).
(Q2T​RQ2​)z=Q2T​(b1​−Rxp​).

Then
x=xp+Q2z.
x=xp​+Q2​z.

Why this is a big deal for you: the system you solve is size (n−r)×(n−r)(n−r)×(n−r), i.e., “number of extra DOFs”. In your 11-point example with ~17 constraints and maybe ~25 unknowns, that’s on the order of 8 unknowns in the reduced solve—tiny compared to the full KKT.

You can still use your existing QR (with pivoting) to solve this reduced system if you don’t implement Cholesky yet.
2) Is it worth implementing Cholesky?

Yes, if RR is SPD (typical when RR comes from a least-squares or smoothing penalty). You would use Cholesky on the reduced SPD matrix H:=Q2TRQ2H:=Q2T​RQ2​. That is substantially faster than QR and simpler to implement than a full symmetric-indefinite LDLᵀ.

Even if you don’t implement Cholesky, the null-space reduction usually makes QR fast because the reduced dimension n−rn−r is small.
3) Should you consider CG/GMRES?

For your situation, iterative methods are usually not the first choice:

    Full-KKT is symmetric indefinite ⇒ CG doesn’t apply; you’d want MINRES (best) or GMRES.
    Without a good preconditioner, iterations can blow up when AA is ill-conditioned/rank-deficient.
    With dense operations only, each iteration costs dense matvecs anyway; for n∼20n∼20–$30$ direct methods are almost always simpler and faster.

Iterative becomes attractive mainly when you can exploit true sparsity/structure in matvecs, which you said you can’t represent directly.
Recommendation

    Implement the pivoted-QR null-space method above (it uses exactly what you already have: pivoted QR + fast matrix products).
    Add Cholesky later if you want another significant speedup on the reduced SPD solve.
    Use the pivoted QR to detect numerical rank of AA and drop dependent constraints (or at least warn), because that’s the real source of “singular A” behavior.
