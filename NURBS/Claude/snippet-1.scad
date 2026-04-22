ddata = [ repeat([0,0,-15],9),
          for(i=[0:4]) path3d(regular_ngon(n=9, side=i==2?25:15),i*15),
          repeat([0,0,5*15],9)
        ];
x = nurbs_interp_vnf(ddata, 3, splinesteps=32,u_edges=[3],normal2=UP,method="centripetal",type=["clamped","closed"]);
vnf_polyhedron(x);