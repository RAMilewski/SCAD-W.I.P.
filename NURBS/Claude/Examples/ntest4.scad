include<BOSL2-fork/std.scad>
include<BOSL2-fork/nurbs.scad>
include<nurbs_interp.scad>


method="centripetal";   // [length,centripetal,dynamic,foley]
//method="length";
//method="centripetal";
//method="dynamic";
//method="foley";

blob1 = [ repeat([0,0,-15],9),
           for(i=[0:4]) path3d(regular_ngon(n=9, side=i==2?25:15),i*15),
           repeat([0,0,5*15],9)
        ];


blob1a = [ repeat([0,0,-15],9),
           for(i=[0:6]) path3d(regular_ngon(n=9, side=i==3?20:15),i*15),
           repeat([0,0,7*15],9)
        ];



blob2 = [ repeat([0,0,-15],14),
           for(i=[0:4]) zrot(i*15,path3d(star(or=15,ir=13, n=7),i*15)),
           repeat([0,0,5*15],14)
        ];


blob3 = [ repeat([0,0,-15],18),
           for(i=[0:4]) zrot(i*15,path3d(star(or=20,ir=15, n=9),i*15)),
           repeat([0,0,5*15],18)
        ];

blob4 = scale([.4,.4,1],[[[0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15]], [[79.6339, -4.38058, 0], [40.896, -31.7754, 0], [15.797, -62.5962, 0], [-33.6384, -43.2018, 0], [-59.6584, -13.8224, 0], [-50.4599, 29.7375, 0], [-25.4314, 48.862, 0], [30.9752, 64.4936, 0], [61.4977, 30.8309, 0]], [[52.8004, -0.215007, 15], [33.2748, -43.4591, 15], [4.54383, -61.5553, 15], [-37.5722, -46.7047, 15], [-55.1692, -13.8082, 15], [-65.9607, 40.1661, 15], [-26.1015, 63.9485, 15], [25.579, 54.7833, 15], [55.922, 36.9268, 15]], [[76.687, -12.4395, 30], [44.5794, -47.1241, 30], [6.85852, -50.7097, 30], [-36.0026, -61.2561, 30], [-46.8263, -18.7813, 30], [-50.9768, 12.0165, 30], [-34.5604, 63.8321, 30], [40.8688, 36.6627, 30], [51.9276, 4.57487, 30]], [[49.6378, -13.5445, 45], [33.2348, -45.9035, 45], [2.69676, -54.1991, 45], [-36.675, -50.0375, 45], [-55.6874, -16.5721, 45], [-60.7847, 24.5447, 45], [-39.795, 62.9274, 45], [53.9148, 44.8839, 45], [72.0441, 4.13844, 45]], [[50.1046, -2.34138, 60], [35.5251, -52.9736, 60], [1.57538, -59.2046, 60], [-44.7697, -57.723, 60], [-51.1546, -12.1482, 60], [-65.8805, 44.5606, 60], [-21.5393, 76.6086, 60], [33.8055, 63.7604, 60], [70.9946, 31.7213, 60]], [[79.5069, -7.07851, 75], [40.5506, -37.8521, 75], [19.0471, -74.1246, 75], [-24.0265, -68.1022, 75], [-66.1804, -29.306, 75], [-61.4549, 13.4936, 75], [-23.8468, 49.0886, 75], [38.5531, 36.8168, 75], [76.9179, 15.2508, 75]], [[76.1543, -22.4224, 90], [37.3296, -47.2055, 90], [2.53902, -58.3146, 90], [-37.636, -62.6748, 90], [-48.4727, 24.2751, 90], [-27.9386, 46.5475, 90], [3.89982, 53.5218, 90], [32.0275, 40.4924, 90], [73.0278, 7.00976, 90]], [[0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105]]]);

blob5 = scale([.4,.4,1],[[[0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15], [0, 0, -15]], [[78.5811, -6.96624, 0], [58.1848, -43.8984, 0], [-3.11381, -70.2702, 0], [-41.4628, -59.5639, 0], [-74.6919, -21.0816, 0], [-71.0895, 22.6627, 0], [-22.4439, 69.1978, 0], [24.508, 69.5189, 0], [74.2094, 14.3117, 0]], [[75.6417, -4.62407, 15], [46.867, -60.0078, 15], [-0.768462, -75.1649, 15], [-41.9902, -64.8045, 15], [-64.892, -27.3729, 15], [-68.1894, 26.8653, 15], [-29.0793, 65.9117, 15], [20.3631, 68.3557, 15], [70.5551, 3.04468, 15]], [[74.9649, -13.6835, 30], [53.2483, -56.0514, 30], [14.6974, -69.6416, 30], [-46.914, -58.4944, 30], [-76.4286, -6.94986, 30], [-62.6945, 35.6752, 30], [-32.3297, 63.2722, 30], [7.64532, 69.9655, 30], [62.4899, 38.4406, 30]], [[72.5989, -4.05326, 45], [37.0145, -63.7526, 45], [-11.8341, -69.0013, 45], [-68.9762, -23.4711, 45], [-68.4843, 30.8839, 45], [-35.3875, 68.7556, 45], [5.601, 70.4858, 45], [54.4401, 55.5909, 45], [79.7934, 5.64894, 45]], [[71.5764, -7.62347, 60], [43.8823, -62.183, 60], [-28.735, -70.3047, 60], [-68.5625, -38.9015, 60], [-70.0322, 12.7163, 60], [-38.5166, 67.4788, 60], [4.98143, 76.4446, 60], [44.863, 54.9316, 60], [70.5147, 21.9597, 60]], [[69.2022, -29.3228, 75], [37.3591, -61.6206, 75], [-3.03082, -74.1046, 75], [-41.9116, -57.6762, 75], [-76.7563, -17.6577, 75], [-60.0274, 36.5017, 75], [-21.2919, 67.3926, 75], [41.6384, 58.0172, 75], [71.2437, 0.758665, 75]], [[76.4427, -22.3674, 90], [31.9983, -66.6294, 90], [-10.2953, -71.2025, 90], [-49.7363, -51.042, 90], [-70.7478, 7.64915, 90], [-46.0866, 58.0935, 90], [-5.33875, 71.6092, 90], [42.7719, 65.4892, 90], [71.4377, 27.1609, 90]], [[0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105], [0, 0, 105]]]);


ydistribute(85){

  
xdistribute(75){
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0);
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=3*DOWN, normal2=2*UP);  
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal1=5*DOWN, normal2=7*UP);
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=4*UP+RIGHT,u_edges=[2],normal1=DOWN+LEFT/4);  
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=4*UP+RIGHT,u_edges=3,normal1=DOWN+LEFT/4);  
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=4*UP+RIGHT,u_edges=4,normal1=DOWN+LEFT/4);  
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=UP+RIGHT/4,u_edges=[2,4],normal1=DOWN+LEFT/4);  
  debug_nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
      normal2=UP,u_edges=[2,3],normal1=DOWN);  

}


xdistribute(75){
  debug_nurbs_interp_surface(blob2, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0);
  debug_nurbs_interp_surface(blob2, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=2*UP);  
  debug_nurbs_interp_surface(blob2, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=4*UP);  
}


xdistribute(75){
  debug_nurbs_interp_surface(blob3, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0);
  debug_nurbs_interp_surface(blob3, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=2*UP);  
  debug_nurbs_interp_surface(blob3, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=7*DOWN,normal2=5*UP);  
}


xdistribute(75){
  debug_nurbs_interp_surface(blob4, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0);
  debug_nurbs_interp_surface(blob4, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=2*UP);  
}


xdistribute(75){
  debug_nurbs_interp_surface(blob5, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0);
  debug_nurbs_interp_surface(blob5, 3, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=UP);  
}



}

/*  // Random shape maker
oooordata = [repeat([0,0,-15], 9),
         for(i=[0:6]) path3d(scale(1,random_polygon(n=9,angle_sep=.7,size=[50,80])),i*15),
         repeat([0,0,15*7],9)
        ];
*/

