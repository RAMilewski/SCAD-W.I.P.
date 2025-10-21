# LibFile: hooks.scad

Modules for making hooks

To use, add the following lines to the beginning of your file:

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>

## File Contents

- [`s_hook()`](#module-s_hook) – Creates an S-hook <sup title="Can return geometry.">[<abbr>Geom</abbr>]</sup>


### Module: s\_hook()

**Synopsis:** Creates an S-hook <sup title="Can return geometry.">[<abbr>Geom</abbr>]</sup>

**Topics:** [Shapes (3D)](Topics#shapes-3d), [Hooks](Topics#hooks), [VNF Generators](Topics#vnf-generators)

**See Also:** 

**Usage:** As Module

- s_hook(or, sides, ....);

**Description:** 

Creates an S-hook with specified cross-section shape and size.
Optional straight segments and reverse curls can be added to each end of the hook.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`or`                 | the outside radius of the cross-section shape. Default: 3
`sides`              | the number of sides of the cross-section shape, values less than 3 result in a circular cross-section. Default: 6
`l_shaft`            | length of the half-shaft, the distance from the origin to the beginning of the loop. Default: 25.
`sym`                | if true makes a symmetrical S-hook, if false makes half an S-hook.  Default: true

<abbr title="These args must be used by name, ie: name=value">By&nbsp;Name</abbr> | What it does
-------------------- | ------------
`r_loop`             | radius of the loop at the +Y end of the hook. Default: 5
`angle`              | end angle in degrees of loop1.  Default: 180
`l_stem`             | length of the straight segment at the end of loop1. Default: 0
`r_curl`             | radius of the curl at the +Y end of the hook.  Default: 0
`angle_curl`         | end angle in degrees of the curl at the +Y end of the hook. Default: 0

**Example 1:** Default S-hook

<img align="left" alt="s\_hook() Example 1" src="images/hooks/s_hook.png" width="320" height="240">

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook();

<br clear="all" /><br/>

**Example 2:** S-hook with circular cross section

<img align="left" alt="s\_hook() Example 2" src="images/hooks/s_hook_2.png" width="320" height="240">

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook(sides = 0);

<br clear="all" /><br/>

**Example 3:** S-hook with longer shaft.

<img align="left" alt="s\_hook() Example 3" src="images/hooks/s_hook_3.png" width="320" height="240">

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook(l_shaft = 50);

<br clear="all" /><br/>

**Example 4:** S-hook with end stems.

<img align="left" alt="s\_hook() Example 4" src="images/hooks/s_hook_4.png" width="320" height="240">

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook(l_shaft = 30, l_stem = 5);

<br clear="all" /><br/>

**Example 5:** S-Hook with end curls

<img align="left" alt="s\_hook() Example 5" src="images/hooks/s_hook_5.png" width="320" height="240">

<br clear="all" />

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook(or = 3, sides = 0, r_loop = 7, l_stem = 4, r_curl = 4, angle_curl = 60, l_shaft = 40);

**Example 6:** Asymetrical S-hook with differing end shapes.

<img align="left" alt="s\_hook() Example 6" src="images/hooks/s_hook_6.png" width="320" height="240">

<br clear="all" />

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook(or = 3, sides = 0, sym = false, r_loop = 7, angle = 230, l_stem = 4, r_curl = 4, angle_curl = 60, l_shaft = 40)
        zrot(180) s_hook(or = 3, sides = 0, sym = false, r_loop = 7, l_stem = 4, l_shaft = 50) ;

**Example 7:** Half square S-hook to attach to other objects.

<img align="left" alt="s\_hook() Example 7" src="images/hooks/s_hook_7.png" width="320" height="240">

<br clear="all" />

    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>
    s_hook(or = 3, sides = 4, sym = false, r_loop = 7, l_shaft = 40);

---

