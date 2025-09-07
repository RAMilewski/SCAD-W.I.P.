include<BOSL2/std.scad>

label_text = "Text";
font = "Phosphate:style=solid";  // ["Phosphate:style=solid","Righteous","Arial Black","Impact"]
font_size = 14;
layer = 0.2;
  
$fn = 72;

block(); 
//label(layer);


module block() {
    difference(){
        cuboid([40,20,5], rounding = 1, anchor = BOT);
        label(layer * 1.5);
    }
}


module label(label_depth) {
    xscale(-1) text3d(label_text, font = font, size = font_size, h = label_depth, center = true, atype = "ycenter", anchor = BOT);
}