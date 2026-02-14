# SparkStudio_18650_Project

This OpenSCAD file renders .stl files for Mike Nolley's 18650 based USB charger project at Spark Studio Salem <https://sparkstudiosalem.com/>.

The box accomodates an IP5328 charge management board available from:

<https://www.aliexpress.us/item/3256801127506668.html>

<https://www.ebay.com/itm/193381612879>

...as well as many other vendors on EBay and AliExpress.

Sadly, the manufcturer's name and part number are not in evidence.  Match this image for positive identification:

![PCB Image](PCB_Photo.png)

This box can be configured for any number of 18650 cells up to the size limits of
your 3d printer.

The BOSL2 Library is required for this project.  <https://github.com/revarbat/BOSL2>

The SCAD Customizer can be used to set the following variables:

+ part  - The part to be rendered. Possible parts are box, lid, button, window, & test.
        The "test" part is the pcb end of the box to verify that parts printed on a
        particular printer will fit the pcb snugly.

+ battery_count - The number of 18650's the box is intended to hold.  Typically 4 or 6.

+ buffer - The buffer space around each battery for flame-suppressing buffer filler.

+ wall - The box wall thickness. Typically 2mm.

+ corner - The radius of the corner rounding on the outside of the box.

+ iwall_fudge - A fudge factor to adjust the box for a snug fit of the pcb, Initially 1.25.
              Decrease it for a tighter fit, increase it to loosen the fit.

With the exception of the window, parts can be printed with any available filament.
The window must be printed with transparent filament.
Use:

+ 4 perimeters
+ ZERO infill
+ ZERO bottom layers
+ 4 top layers with a rectilinear top fill pattern.
