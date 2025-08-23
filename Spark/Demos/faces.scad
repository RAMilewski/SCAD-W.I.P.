include<BOSL2/std.scad>

//spheroid(30) show_anchors();

echo("TOP ",TOP);
echo("BOT ",BOT);
echo("LEFT ",LEFT);
echo("RIGHT ",RIGHT);
echo("FWD ",FWD);
echo("BACK ",BACK);
echo("TOP+LEFT+BACK ",TOP+LEFT+BACK);


cyl(h=10, r=20, circum=true, $fn=5);