When parameterization matters most: closed curves with uneven chord lengths. The chord-length ratio (max/min) is the key indicator. Data2 has a 7:1 ratio — not extreme, but enough to cause span collisions for all methods.

Method comparison:

|Method	|What it does	|Best for|
|:------------|:------------------------------|:-------------------------------------------------|
|"length"	|Increment = chord length	|Nearly uniform spacing. Preserves the raw chord ratio (7:1 here), so it's the worst at compressing gaps.|
"centripetal"	Increment = √chord	The classic workhorse. Compresses the ratio from 7:1 down to 2.7:1. Good default for most data.
"dynamic"	Increment = chord^e, exponent varies per segment	Similar compression to centripetal but adapts the exponent per chord. Best for sharp turns with mixed spacing.
"foley"	Centripetal + deflection-angle correction	Best when the issue is sharp angular turns rather than chord-length variation. Adjusts spacing based on how much the curve bends at each vertex.
Rules of thumb:

Smooth, roughly uniform data — any method works; "centripetal" is the safe default.
Sharp turns with short chords (like data2) — "centripetal" or "dynamic" to compress the chord-length ratio. Both reduce a 7:1 ratio to ~2.7:1.
Very uneven spacing (ratio > 10:1) — "dynamic" adapts per-segment and tends to be most robust.
Angular cusps (sharp direction changes, not just short chords) — "foley" adds correction for the deflection angle at each vertex.
Closed curves are harder than clamped — the periodic knot averaging smooths over p values, so parameter gaps need to be wider relative to span widths. With the v58 fix, mild collisions are tolerated, but extremely uneven data may still produce a singular system.
The key takeaway: no method guarantees collision-free spans for all data. The v58 fix ensures that mild collisions (which are numerically benign) no longer cause failures. If linear_solve truly returns singular, the data itself may need resampling.