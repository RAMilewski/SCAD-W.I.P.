    // ==========================================================
    // Rectangular Cover Plate with Sidewalls
    // ==========================================================

    include <BOSL2/std.scad>;

    // ------------------------------------------------
    // Parameters
     // -----------------------------------------------
    // Object to cover
    obj_length = 135;     
    obj_width = 40;  

    object = [obj_length, obj_width]; 

    // Sidewall
    wall_length = obj_length;
    wall_width = 1;
    wall_height = 3;

    sidewall = [wall_length, wall_width, wall_height];

    // Cover_plate
    cover_length = object.x;
    cover_width = object.y + 2 * wall_width;
    cover_thickness = 3;

    cover = [cover_length, cover_width, cover_thickness];    

    // -------------------------------------------------------
    // Module: cover_plate()
    // Creates a rectangular cover plate with sidewalls on
    // the long edges to fit the object.
    // -------------------------------------------------------

    module cover_plate(cover,sidewall) {
        cuboid(cover)
            align(TOP,[FWD,BACK]) cuboid(sidewall);
    }

    // ----------------------------------------------------------
    // Example call
    // ----------------------------------------------------------
    cover_plate(cover,sidewall);