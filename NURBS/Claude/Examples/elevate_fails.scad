

//   knots only, not in [0,1]  // fails with singular matrix error
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,3,5,9,13,14,19,21];
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2);
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16);
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));

*/

/*
//   knots only, knots in [0,1] but don't start and end at 0 and 1  // fails, incorrect result

   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [.9,1,3,5,9,13,14,19,21]/22;
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2);
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16);
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/

//   knots only, in [0,1]  // succeeds
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,3,5,9,13,14,19,21]/21;
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2);
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16);
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/

// mult only  -- succeeds
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   mult = [1,1,1,2,1,1,1,1];
   e = nurbs_elevate_degree(mpts,2,mult=mult,times=2);
   c1 = nurbs_curve(mpts,2,mult=mult,splinesteps=16);
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/

// knots and mult   FAIL
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,3,9,13,14,19,21]/21;
   mult = [1,1,1,2,1,1,1,1];
   e=nurbs_elevate_degree(mpts,2,knots=knots,mult=mult,times=2);
   c1 = nurbs_curve(mpts,2,knots=knots,mult=mult);
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/

   


///////////////////////////////////////////////////////////////////////////////////////////////////
// Doing it again with type "closed:


//   knots only, not in [0,1]  // fails with singular matrix error
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,3,5,9,13,13.5,14,19,21,24];
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2,type="closed");
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16,type="closed");
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/



//   knots only, knots in [0,1] but don't start and end at 0 and 1  // fails, singular matrix
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [1,3,5,9,13,14,17,19,23,29,33]/35;
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2,type="closed");
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16,type="closed");
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
    debug_nurbs(mpts,2,knots=knots,splinesteps=16,type="closed");
*/

//   knots only, in [0,1]  // fails with singular matrix
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,3,5,9,13,14,19,21,24,29]/29;
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2,type="closed");
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16,type="closed");
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/


// mult only  -- fails with singular matrix
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   mult = [1,1,1,2,1,1,2,1,1];
   e = nurbs_elevate_degree(mpts,2,mult=mult,times=2,type="closed");
   c1 = nurbs_curve(mpts,2,mult=mult,splinesteps=16,type="closed");
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/


// knots and mult   FAIL, singular matrix
/*
   mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,4,13,14,19,21]/21;
   mult = [1,1,1,3,1,3,1];
   e=nurbs_elevate_degree(mpts,3,knots=knots,mult=mult,times=2,type="closed");
   c1 = nurbs_curve(mpts,3,knots=knots,mult=mult,type="closed");
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
*/


   
