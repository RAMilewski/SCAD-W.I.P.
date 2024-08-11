include<BOSL2/std.scad>

height = 45;
sub_base = octagon(d=71, rounding=2, $fn=128);
stroke(sub_base);
echo(sub_base);

base = octagon(d=75, rounding=2, $fn=128);
stroke(base);

interior = regular_ngon(n=len(base), d=60);
stroke(interior);
  //skin([ sub_base, base, base, sub_base, interior], z=[0,2,height, height, 2], slices=0, refine=1, method="reindex");
