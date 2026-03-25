// Function to center a dataset plot in the viewport using $vpt
// $vpt is OpenSCAD's viewport translation special variable
// It's a 3-element vector [x, y, z] that translates the view
//
// This function calculates the necessary viewport translation to center
// a dataset (list of 2D or 3D points) in the current viewport.

use <BOSL2/std.scad>

// Calculate the centroid (center) of a dataset
function centroid(points) =
    let(
        dims = len(points[0]),  // 2D or 3D
        n = len(points)
    )
    [for(d = [0:dims-1]) sum([for(p = points) p[d]]) / n];


// Calculate bounding box of a dataset
function bounding_box(points) =
    let(
        dims = len(points[0]),
        min_vals = [for(d = [0:dims-1]) min([for(p = points) p[d]])],
        max_vals = [for(d = [0:dims-1]) max([for(p = points) p[d]])]
    )
    [min_vals, max_vals];


// Calculate the size (extent) of the bounding box
function bbox_size(bbox) =
    let(
        min_pt = bbox[0],
        max_pt = bbox[1]
    )
    [for(d = [0:len(min_pt)-1]) max_pt[d] - min_pt[d]];


// Primary function: return the viewport translation needed to center points
// For 2D data, provide z=0 or handle 2D points
// Usage:
//   points = [[1, 5], [3, 2], [2, 8], [4, 6]];
//   vpt_center = center_viewport(points);  // Returns translation vector
//   // Then in your main code, add translate(vpt_center) { ... }
//
function center_viewport(points, zoom=1) =
    let(
        center = centroid(points),
        dims = len(center),
        // For 2D data, extend to 3D with z=0
        center_3d = dims == 2 ? [center[0], center[1], 0] : center,
        // Negate to move viewport to origin (opposite direction)
        // We negate because $vpt translates the view, not the objects
        translation = [-center_3d[0], -center_3d[1], -center_3d[2]] * zoom
    )
    translation;


// Alternative: return centered points directly
// Useful if you want to transform your data instead of using $vpt
function center_points(points) =
    let(
        center = centroid(points),
        dims = len(center)
    )
    [for(p = points)
        if(dims == 2)
            [p[0] - center[0], p[1] - center[1]]
        else
            [p[0] - center[0], p[1] - center[1], p[2] - center[2]]
    ];


// Calculate camera distance from xy plane given FOV and data size
// Calculates the Z distance the camera needs to be from the xy plane so that
// the data fits properly in the viewport with specified coverage.
//
// Parameters:
//   points - list of [x, y] or [x, y, z] coordinates
//   viewport - [width, height] of viewport in pixels, e.g. [1800, 900]
//   fov - field of view in degrees, default 22.5
//   coverage - fraction of viewport the data should occupy (0-1), default 0.75
//
// The larger of (x_span / viewport_width) or (y_span / viewport_height)
// determines the limiting dimension. Camera distance is calculated so this
// dimension occupies 'coverage' fraction of the viewport.
//
// Math: distance = (data_extent / 2) / tan(fov / 2)
//
function camera_distance(points, viewport=[1800, 900], fov=22.5, coverage=0.75) =
    let(
        bbox = bounding_box(points),
        size = bbox_size(bbox),
        x_span = size[0],
        y_span = size[1],
        // Ratios of data span to viewport dimension
        x_ratio = x_span / viewport[0],
        y_ratio = y_span / viewport[1],
        // The limiting dimension (larger ratio)
        max_ratio = max(x_ratio, y_ratio),
        // Required extent to achieve desired coverage
        required_extent = max([x_span, y_span]) / coverage,
        // Half angle in radians
        half_fov_rad = fov / 2 * 3.14159265359 / 180,
        // Distance from xy plane
        distance = (required_extent / 2) / rtan(half_fov_rad),
    )
    distance;


// Helper: tangent function (OpenSCAD sin/cos based)
function rtan(angle_rad) =
    sin(angle_rad * 180 / 3.14159265359) / cos(angle_rad * 180 / 3.14159265359);


// ============================================================================
// EXAMPLE USAGE:
// ============================================================================

// Sample dataset
sample_data = [
    [10, 20],
    [45, 60],
    [30, 15],
    [55, 50],
    [25, 35]
];

// Get centering translation
vpt_translation = center_viewport(sample_data);

// Get centered point data
centered_points = center_points(sample_data);

// Get camera distance for 1800x900 viewport, 22.5° FOV, 75% coverage
camera_dist = camera_distance(sample_data, viewport=[1800, 900], fov=22.5, coverage=0.75);

// Echo for debugging
echo("Original data:", sample_data);
echo("Centroid:", centroid(sample_data));
echo("Bounding box:", bounding_box(sample_data));
echo("Bounding box size:", bbox_size(bounding_box(sample_data)));
echo("Viewport translation needed:", vpt_translation);
echo("Centered points:", centered_points);
echo("Camera distance from xy plane:", camera_dist);

// ============================================================================
// VISUALIZATION: Use with translate() and scale()
// ============================================================================

// Uncomment to visualize:
/*
// Draw original points
color("red") {
    for(p = sample_data) {
        translate(p) sphere(d=2);
    }
}

// Draw centered points (translated version)
color("blue") {
    translate([60, 0, 0]) {  // Offset to the right to compare
        for(p = centered_points) {
            translate(p) sphere(d=2);
        }
    }
}

// Draw bounding box of original data
bbox = bounding_box(sample_data);
color("green", alpha=0.2) {
    translate(bbox[0]) {
        cube(bbox_size(bbox));
    }
}
*/
