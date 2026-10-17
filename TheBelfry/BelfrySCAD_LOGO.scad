include <BOSL2/std.scad>

$export_name = "BelfrySCAD_LOGO";

$fn = 288;

 diff() {
    color_this("yellow") cuboid(50) {  
        tag("remove") color_this("yellow")spheroid(32);
        tag("keep") color_this("cyan") spheroid(26)
            tag("keep") attach(FWD) down(2.4) color_this("white") 
                text3d("B", font = "Times New Roman:style=Bold", 
                    size = 27.5, h = 8, center = true  );
    }
      
} 
  //down(30) color("black") square(1000, anchor = CTR);    
      