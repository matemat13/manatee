// includes/uses

include <parameters.scad>;

use <common_modules.scad>;

use <main_hull.scad>;

use <thruster.scad>;

use <leg.scad>

/// MAIN
// for reference
//translate([100, 0, 15])
//import("glt-3n-6.stl");

// main hull
if (cached_hull)
    import("main_hull.stl");
else
    main_hull();

// legs
for (it = [1 : num_legs])
    rotate([0, 0, it*360/num_legs])
    translate([R_bottom, 0, 0.9*Z_leg_mounts])
    if (cached_legs)
        import("leg.stl");
    else
        leg();

// main thrusters
translate([0, 0, -H_thousing])
{
    if (cached_thrusters)
        import("main_thrusters.stl");
    else
        main_thrusters();
}