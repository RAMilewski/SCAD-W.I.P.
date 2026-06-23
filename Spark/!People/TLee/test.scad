include <BOSL2/std.scad>

a=21; //

b=0.9*a;

k=1;

m=k/b;

module section(y){    

path =[

 for (fi=[0:1:360]) let(

   pt =(a*fi-b*sin(fi))/360, 

   pt2=m*(b-b*cos(fi))

   ) [pt,pt2]

 ];

 yrot(90)zrot(90)left(a/2)linear_extrude(0.01)scale([1,y])polygon(path);

}

hull(){

            #section(1);

    right(5)section(1.2);

}
