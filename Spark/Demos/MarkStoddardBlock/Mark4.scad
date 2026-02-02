s = 50;
p = [for(x=[-s, s], y=[-s, s], z=[-s, s]) if(!(x==50&&y==50&&z==50))
[x,y,z]];

echo(p);
hull()  polyhedron(p, [[0,1,2,3,4,5,6]]);