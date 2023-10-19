// modules for creating the main body of the Manatee

include <parameters.scad>

use <common_modules.scad>

module cap(r, h, minw)
{
    // add the docking collar at the top
    union()
    {
        r_hatch = r/4;
        
        // the main part with panelling
        difference()
        {
            // add the inner smaller main part (so that the cuts do not go completely through)
            union()
            {
                // subtract the panel cuts
                difference()
                {
                    // this is the actual main part
                    ellipsoid(r, h);
                    
                    // bottom panels cuts
                    cylinder(minw, 2*r);    // vertical
                    for (it = [1:3])        // horizontal cuts
                        rotate([0, 0, 360/3*it+40])
                        translate([-minw/2, 0, 0])
                        cube([minw, 100, 2/5*h+minw/2]);
                    
                    // top panels cuts
                    translate([0, 0, 2/5*h])
                    cylinder(1, 2*r);   // vertical
                    for (it = [1:5])    // horizontal cuts
                        rotate([0, 0, 360/5*it])
                        translate([-minw/2, 0, 2/5*h])
                        cube([minw, 100, 100]);
                }
                // inner, smaller version of the main part
                ellipsoid(r-minw, h-minw, $fn=$fn/4);
            }
            // a hole at the top for the docking collar
            translate([0,0,r/2])
            cylinder(h=collar_outer_r, r=r_hatch, $fn=$fn);
        }
        
        // the docking collar itself
        collar_outer_r = r/2;
        lock_dots_r = r_hatch/10;
        // outer ring
        translate([0,0,h-collar_outer_r+2.0*lock_dots_r])
        difference()
        {
            // the outer ring
            sphere(collar_outer_r, $fn=$fn/2);
            // inner cutout from the outer ring
            translate([0,0,0.33*r])
            cylinder(h=r/4, r1=r/8, r2=r/4, $fn=$fn/2);
            
            // locking dots
            for (it = [1:9])
                rotate([0, 0, 360/9*it+32])
                translate([-r/4.5, 0, 0.43*r])
                sphere(lock_dots_r, $fn=$fn/4);
        }
        // the hatch
        translate([0,0,h-0.85*r_hatch])
        difference()
        {
            union()
            {
                difference()
                {
                    // the doors
                    sphere(r_hatch, $fn=$fn/2);
                    for (it = [1:6])    // vertical cuts
                        rotate([0, 0, 360/6*it+19])
                        translate([-0.05, 0, 0])
                        cube([0.1, 100, 100]);
                    // central hole
                    translate([0,0,r_hatch-2*minw])
                    cylinder(h=r_hatch/4, r1=r_hatch/6, r2=r_hatch/4, $fn=$fn/2);
                }
                // inner, smaller version of the hatch
                sphere(r_hatch-minw, $fn=$fn/2);
            }
        }
    }
}

module main_body(h, r, r2)
{
    rotate([180, 0, 0])
    paraboloid(h, r, r2);
}

module bottom_cap(h, r, r2)
{
    rotate([180, 0, 0])
    fillet(h, r, r2);
}

module leg_attachment(h, r)
{
    rotate([0, 4, 0])
    union()
    {
        cylinder(h=h, r=r);
        cylinder(h=h, r=r);
        translate([0,0,h]) sphere(r=r);
        translate([0,0,-h/2]) cylinder(h=h/2, r1=0.9*r, r2=r);
    }
}

// the complete hull
module hull()
{
    h_bottom = 0.1*R_bottom;
    translate([0, 0, h_bottom])
    {
        translate([0, 0, H-(1-cap_squash)*R]) cap(R, (1-cap_squash)*R, minw);
        translate([0, 0, H-(1-cap_squash)*R]) main_body(H - (1-cap_squash)*R, R, R_bottom);
        bottom_cap(h_bottom, R_bottom, R_thousing);
    };
    
    // leg mounts
    H_legmount = H/7;
    R_legmount = R/3;
    for (it = [1: num_legs])
        rotate([0, 0, it*360/num_legs])
        translate([R-1.04*R_legmount, 0, Z_leg_mounts])
        leg_attachment(H_legmount, R_legmount, $fn=50);
}

module main_hull()
{
    difference()
    {
        hull($fn=2*$fn);
        
        // triangle cutouts
        tri_cut_w = 2*PI*R/15;
        tri_cut_d = R/14;
        for (it = [1 : 2*num_legs])
            rotate([0, 0, it*360/num_legs/2])
            translate([R_bottom-tri_cut_d, 0, 0])
            rotate([101, 0, 90])
            linear_extrude(2*tri_cut_d, scale=1.2)
            polygon(points=[
                [-tri_cut_w/2, 0],
                [tri_cut_w/2, 0],
                [0, 1.3*Z_leg_mounts],
            ]
            );
        
        // leg cutouts
        for (it = [1 : num_legs])
            rotate([0, 0, it*360/num_legs])
            translate([R_bottom-(R_bottom-R_thousing)+R_leg, 0, 0])
            cylinder(h=R_leg/2, r=R_leg);
    }
}

main_hull();