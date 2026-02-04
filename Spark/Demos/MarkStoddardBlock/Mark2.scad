include<BOSL2/std.scad>

s1 = square(1);
s2 = select(s1,0,2);
skin([s1,s2],z=[0,1],slices=0);
left(1)skin([s1,s1,s2],z=[0,1,2],slices=0);
back(1.5)prismoid([2,1],[1,1],h=1,shift=[-1/2,0]);
