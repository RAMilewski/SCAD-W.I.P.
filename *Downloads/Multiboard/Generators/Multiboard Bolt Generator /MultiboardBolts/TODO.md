v0.0.2 Changes
[x] Threads should be flat shaded by default
[x] Add thread resolution under tolerance
[x] Head undersides not flat
[x] Tolerance not adjusting head height appropriately
[x] Bolts should use minor thread diameter for shank diameter
[x] New bolts should be located at 3d cursor and aligned with world z
[x] Chamfer is inconsistent, likely and error of using length rather than pitch
[x] Add threadead rod support
[x] Large thread push fit hole has not push fit cutout
[x] Added folded bolt
[x] Some t-bolt orientations are wrong
[x] Tolerance should not change any through hole tolerance.

v0.0.3 Changes
[x] Adjusted tolerance cap of -/+ 0.3 and treatment of bolt tip. This should address both observed chamfer issue, and folded bolt issue.
[x] Added Small heads
[x] Added preset caching
[x] Additional cutout for small thread on t-bolt
[x] Correct tbolt trim shape's height issue
[x] When no shank or head, top thread should be chamfered
[x] 0.0 shank meshing issues
[x] Decresase severity of head patten overhang on folded bolt

v0.0.4 Changes
[x] Observed threaded rod base tolerance issue softened. Might still be a few slightly too sharp verts, but I'm not seeing anything topologically significant to the extent that a print would be affected.
[x] Added missing Standard Flat Head Push-Fit
[x] Made folded bolt head chamfering apply to all edges. 0.4 chamfer to convex angles sharper than 60 degrees. I believe this also addresses other issue witnessed in folded bolt thread distortion.
[x] Added extra joining meshes to handle folded threaded rods, big and mid threads, with through holes. You can slight tweak. Note that the joining meshes are stored in resources/meshes.blend in a collection called folded_joiners. I've done this rather than generate them through code so you can make minor adjustments to tweaks to their verts for alignment without needing me to implement them for you. Just don't rename anything in that file.

v0.0.5 Changes
[x] Add additional mesh cuts for better printing of push fit folded bolts
[x] Fixed general topology issues
[x] Correct missing folded joiner conditions
[x] Folded joiner meshes no longer added through boolean. Too many issues with invalid boolean operations and given that folded is for printing it isn't necessary for them to be single mesh as the slicer will treat them as such anyway.
[x] Correct instances of incorrect push fit orientation
[x] Performance optimizations
[x] Correct hole alignment issues

v0.0.6 Changes
[x] Tbolt trim not being applied to threaded rods
[x] Threaded rod folded isn't correct
[x] "Small head push fit mid" "large thread" "small thread hole" folded missing overhang mod
[x] Small head, small thread too deep
[x] Standard head push fit big needs flat internal section when tbolt
