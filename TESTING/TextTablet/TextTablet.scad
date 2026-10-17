include <BOSL2/std.scad>
include <text.scad>


$fn = 72;
$export_name = "TextTablet";

z_size = 3;  // [1:1:10]
board = [100,25,z_size];
z_text = 0.6;

mytext = "Twas brillig and the slithy toves, \n did gyre and gymbal in the wabe.";

 recolor("white") cuboid(board, rounding = z_size/2, clip_angle = 60)
   attach(TOP,BOT,overlap=z_text * 0.999)
       recolor("blue")
           write3d(mytext, font = "Baskerville:style=Bold Italic", thickness=z_text, 
               block_spacing = 0.85, max_height = 20, max_width=90,
               text_align="center");
               
               