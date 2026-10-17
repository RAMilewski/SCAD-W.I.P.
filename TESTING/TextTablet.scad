include <BOSL2/std.scad>


$fn = 72;
$export_name = "TextTablet";

thickness = 3;  // [1:1:10]
size = [50,50,thickness];



text1 = "Twas brillig and the slithy toves,";
text2 = "did gyre and gymbal in the wabe.";




block();


module content() {

}    

module block(){
    cuboid(size, chamfer = thickness/2, edges = TOP);  
}