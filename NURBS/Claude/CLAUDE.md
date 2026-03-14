# CLAUDE.md — NURBS Interpolation Library Dev

## Project Goal
Develop `nurbs_interp.scad`: a NURBS curve and surface interpolation library
for eventual inclusion in the BOSL2 OpenSCAD library.

## Recent Completions
- `deriv=` list with `undef` entries (per-point, any index) — done
- Foley-Neilson parameterization (`param="foley"`) — done
- Curvature end constraints (`start_curv=`, `end_curv=`, `curv=`) — done
- Surface edge partial derivatives (`start_u_der=`, `end_u_der=`, `start_v_der=`, `end_v_der=`) — done
- Surface boundary oscillation fix: project derivatives onto edge direction at boundary rows/cols when both u and v constraints are active simultaneously — done
- `start_normal=`/`end_normal=` consolidated from 4 params (`start_u_normal` etc.); auto-detects u vs v from degenerate edge — done
- `flat_edges=[su, eu, sv, ev]` — coplanar-boundary outward derivatives; scalar or per-point list scale; scalar shorthand `flat_edges=s` expands to `[s,s,s,s]` — done
- NaN corner markers in `deriv=` for clamped curves: `deriv[k]=0/0` splits curve into independent clamped segments at that point; `_nurbs_is_segmented()` detects the multi-segment result; `nurbs_interp_curve()` / `debug_nurbs_interp()` handle both cases — done
- Corner segments with fewer than `p+1` points now automatically use `seg_p = min(p, m-1)` (degree reduction); callers use `seg[2]` for the per-segment degree, not the global degree — done
- When all corner segments achieve full degree p, `_combine_corner_segs()` assembles them into a single clamped B-spline: local segment knots remapped to global params, `p` copies of each corner param in xknots → C0 multiplicity; first ctrl of each seg[1:] dropped (equals shared junction); result is regular `[ctrl, xknots, 0]` — done
- `debug_nurbs_interp()` default `width` changed from `0.1` to `1` — done
- `nurbs_elevate_degree(control, degree, knots, [type=], [times=])` — public function for exact clamped B-spline degree elevation via Greville-abscissae collocation; `_greville()` and `_elevate_once_clamped()` helpers — done
- Corner segments with degree reduction now auto-elevated to full degree p via `nurbs_elevate_degree()`, always producing a single combined B-spline (segmented fallback removed) — done
- Curve interpolation documented as dimension-agnostic (any dimension >= 1); no code changes needed — done
- Surface C0 edges: `u_edges=` and `v_edges=` for `nurbs_interp_surface()` — sharp creases at interior row/column indices; reuses curve corner infrastructure (`_build_edge_systems()`, `_solve_with_edges()`, `_combine_corner_segs()`); supports degree elevation for short segments; compatible with cross-direction boundary derivatives — done
- `corners=` for `nurbs_interp()` — both clamped and closed; alternative to NaN syntax; closed corners rotate to first corner, close loop, solve as clamped via `_nurbs_interp_closed_corners()`; `_nurbs_eff_type()` signals type override to convenience functions — done
- Return format reorganized: `nurbs_interp()` returns `[type, degree, ctrl, knots, weights, start_idx]`; `nurbs_interp_surface()` returns `[type, degree, ctrl_grid, knots, weights, undef]` where type/degree/knots are `[u,v]` lists; weights=undef (B-spline); removed dead `_nurbs_is_segmented()`/`_nurbs_eff_type()` helpers — done
- `debug_nurbs_interp()` `show_ctrl=` parameter: when false, renders curve only (via `stroke()`) without control polygon/points; default true — done
- `u_edges=`/`v_edges=` singleton promotion: scalar value automatically wrapped in a list via `force_list()` — done
- `flat_edges=` now compatible with `u_edges=`/`v_edges=`: `_build_edge_systems()` accepts `has_sd`/`has_ed` for first/last segment derivative rows; `_solve_with_edges()` accepts `start_der`/`end_der` data per solve; boundary asserts relaxed — done

## Next Step
TBD — fix the Fang parameterization implementation (wrong angle, wrong `ell`, no zero-guard).

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
6. Degree Elevation
7. Main Interpolation Function
8. Convenience Functions
9. Debug / Visualization
10. Interpolation System Builder (shared infrastructure)
11. Surface Interpolation
12. Usage Examples (in comments)

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
- Use named arguments (`param=param`) at call sites for clarity
- Numeric tolerances: `1e-12` for near-zero checks, `1e-15` for divisor guards

### License
BSD-2-Clause (same as BOSL2). All files must carry this header.

## Testing
- Test files: `test.scad`, `test2.scad`, `test_random_3d.scad`
- Use `debug_nurbs_interp()` / `debug_nurbs_interp_surface()` for visual verification
- Verify all three types: `"clamped"`, `"closed"`, `"open"`
- Test 2D and 3D point sets
- For surfaces, test scalar degree/type AND `[u,v]` list form

## Revisions
- Make ALL changes to nurbs_interp.scad first, THEN archive the finished result.
- Workflow: (1) make all edits, (2) bump the version number in the file header,
  (3) copy the completed file to Archive/nurbs_interp-v##.scad (lowercase v).
- The archive copy should be identical to nurbs_interp.scad after all changes are done.
  Never archive before changes are complete — the archive is the final state, not a backup.
- Use lowercase "v" in archive filenames (nurbs_interp-v40.scad, not v40 or V40).

  
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
