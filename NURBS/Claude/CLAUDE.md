# CLAUDE.md — NURBS Interpolation Library Dev

## Project Goal
Develop `nurbs_interp.scad`: a NURBS curve and surface interpolation library
for eventual inclusion in the BOSL2 OpenSCAD library.

## Next Step
What we need to do now is modify nurbs_interp.scad to accept a derivitive list with "undef" being a possible entry for a point.  The default should be all "undef".

## Key References
- **Algorithm**: Piegl & Tiller, *The NURBS Book* (2nd ed.) — primary reference for all math.
  Cite section numbers in comments (e.g., "§9.2.2").
- **BOSL2 NURBS source**: https://github.com/BelfrySCAD/BOSL2/blob/master/nurbs.scad
- **BOSL2 API used**: `nurbs_curve()`, `nurbs_vnf()`, `debug_nurbs()`, `vnf_polyhedron()`,
  `linear_solve()`, `cumsum()`, `sum()`, `norm()`, `last()`, `is_list()`, `is_num()`, `is_undef()`

## NURBS Type Conventions (must match BOSL2)
- `"clamped"` — curve/surface starts and ends at first/last data point
- `"closed"` — smooth periodic loop; do NOT repeat the first point at the end
- `"open"` — non-clamped B-spline

## Coding Conventions

### Naming
- Public functions/modules: `nurbs_interp()`, `nurbs_interp_curve()`, `nurbs_interp_surface()`,
  `nurbs_interp_vnf()`, `debug_nurbs_interp()`, `debug_nurbs_interp_surface()`
- Internal helpers: prefix with `_` (e.g., `_nip()`, `_interp_params()`, `_collocation_matrix()`)
- Internal dispatch helpers: `_build_*_system()`, `_nurbs_interp_*()`, `_avg_knots_*()`, etc.

### File Structure (maintain this section order)
1. File header block with `// LibFile:` doc
2. Internal B-spline Basis Functions
3. Parameterization
4. Knot Vector Construction
5. Collocation Matrices
6. Main Interpolation Function
7. Convenience Functions
8. Debug / Visualization
9. Interpolation System Builder (shared infrastructure)
10. Surface Interpolation
11. Usage Examples (in comments)

### BOSL2 Doc Comment Style (required for all public API)
```
// Function: function_name()
// Synopsis: One-line description.
// Topics: NURBS Curves, Interpolation
// See Also: related_function()
//
// Usage:
//   result = function_name(args, [optional=]);
//
// Description:
//   Multi-line description.  Use a period on a blank `//   .` line
//   to create paragraph breaks.
//
// Arguments:
//   arg1 = description
//   arg2 = description
//   ---
//   optional= = description.  Default: value
//
// Returns:
//   Description of return value.
```

### OpenSCAD Style
- Use `let()` chains in functions — no imperative assignments
- 4-space indentation throughout
- Align `=` in `let()` blocks when it aids readability
- Default optional args to `undef`; test with `is_undef()`
- All `assert()` calls must have descriptive string messages
- Use named arguments (`centripetal=centripetal`) at call sites for clarity
- Numeric tolerances: `1e-12` for near-zero checks, `1e-15` for divisor guards

### License
BSD-2-Clause (same as BOSL2). All files must carry this header.

## Testing
- Test files: `test.scad`, `test2.scad`, `test_random_3d.scad`
- Use `debug_nurbs_interp()` / `debug_nurbs_interp_surface()` for visual verification
- Verify all three types: `"clamped"`, `"closed"`, `"open"`
- Test 2D and 3D point sets
- For surfaces, test scalar degree/type AND `[u,v]` list form

## Known BOSL2 Integration Details
- BOSL2 `nurbs_curve()` with `type="closed"` internally calls `_extend_knot_vector()`.
  Must use `_bosl2_full_closed_knots()` (not `_full_periodic_knots()`) when building
  collocation matrices for the closed type — see comments in `nurbs_interp.scad`.
- `linear_solve()` returns `[]` on singular matrix — always assert this.
- `nurbs_vnf()` for surfaces takes `knots=[u_knots, v_knots]` and `type=[u_type, v_type]`.

## Do Not
- Do not use NURBS weights (all weights = 1; this is a B-spline interpolator)
- Do not break BOSL2 argument ordering conventions
- Do not use OpenSCAD modules for anything that should be a function
- Do not add surface-of-revolution or extrusion logic here (belongs in BOSL2 core)
