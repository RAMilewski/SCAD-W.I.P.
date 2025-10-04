include<BOSL2/std.scad>
//Bottle Volume
bottle = 2; //[0:200,1:375,2:500,3:700,4:750]
wall = 3;

/* [Hidden] */
$fn = 72;
d_cork = bottle>2 ? 21.5 : 18.5;
dia = [66,77,84,90,92];
h = [148,175,197,218,220];

path = turtle([
    "move",dia[bottle]/2 - 3, 
    "arcleft",3,90, 
    "untily",0.6*h[bottle], 
    "arcleft", dia[bottle]/3,70, 
    "untilx",d_cork/2+wall,
    "arcrightto",1,90, 
    "untily",h[bottle]-14, 
    "arcright",2,90, 
    "arcleft",2,90, 
    "move",8, 
    "arcleft",2,90, 
    "untilx",d_cork/2
    ]);

path2 = turtle([
    "move",dia[bottle]/2-3-wall, 
    "arcleft",3,90, 
    "untily",0.6*h[bottle]-2*wall, 
    "arcleft", dia[bottle]/3,70,
    "untilx", d_cork/2, 
    "arcrightto",1,90, 
    "untily", h[bottle]- wall
    ]);

//stroke(path);
//back(wall) color("blue") stroke(path2);

back_half(s = 450)
diff() {
    rotate_sweep(path,360);
    tag("remove") up(wall) rotate_sweep(path2,360);
}
