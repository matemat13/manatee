// modules for creating the main body of the Manatee

include <parameters.scad>

use <common_modules.scad>

module hatch_hole(r_hole, r_hatch, offset_angle, axial_angle)
{
    R = r_hatch;
    A1 = axial_angle;
    A2 = offset_angle;
    /* translate([cos(A1)*sin(A2), sin(A1)*sin(A2), cos(A2)]) */
    rotate([-A2, 0, A1])
    translate([0, 0, R])
    cylinder(h=2*minw, r=r_hole, center=true);
}

module cap(r, h, large_cut_h, minw)
{
    // add the docking collar at the top
    union()
    {
        r_hatch = r/4;
        collar_outer_r = r/2;
        lock_dots_r = r/50;
        
        // the main part with panelling
        difference()
        {
            /* cap_h = 1.05*h; */
            cap_h = h;
            // add the inner smaller main part (so that the cuts do not go completely through)
            union()
            {
                // subtract the panel cuts
                difference()
                {
                    top_cut_h = 2/5*h;
                    // this is the actual main part
                    ellipsoid(r, cap_h);
                    
                    // bottom panels cuts
                    cylinder(large_cut_h, 2*r);    // vertical
                    for (it = [1:3])        // horizontal cuts
                        rotate([0, 0, 360/3*it+40])
                        translate([-minw/2, 0, 0])
                        cube([minw, 100, 2/5*h+minw/2]);
                    
                    // top panels cuts
                    translate([0, 0, top_cut_h])
                    cylinder(large_cut_h, 2*r);   // vertical
                    for (it = [1:5])    // horizontal cuts
                        rotate([0, 0, 360/5*it])
                        translate([-minw/2, 0, 2/5*h])
                        cube([minw, 100, 100]);
                }
                // inner, smaller version of the main part
                ellipsoid(r-minw, cap_h-minw);
            }
            // a hole at the top for the docking collar
            translate([0,0,r/2])
            cylinder(h=collar_outer_r, r=r_hatch, $fn=$fn);
        }
        
        // the docking collar itself
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
        translate([0,0,h-0.9*r_hatch])
        difference()
        {
            N = 6;
            split_off = 19;
            union()
            {
                difference()
                {
                    // the doors
                    sphere(r_hatch, $fn=$fn/2);
                    for (it = [0:N])    // vertical cuts
                        rotate([0, 0, 360/N*it+split_off])
                        translate([-0.05, 0, 0])
                        cube([0.1, 100, 100]);
                }
                // inner, smaller version of the hatch
                sphere(0.9*r_hatch, $fn=$fn);
            }
            // central hole
            translate([0,0,0.8*r_hatch])
            cylinder(h=r_hatch/4, r1=r_hatch/6, r2=r_hatch/4, $fn=$fn/2);

            r_small_hole = r_hatch/15;
            r_large_hole = r_hatch/9;
            hatch_hole(r_small_hole, r_hatch, 25, 5*360/N/2 + split_off);
            hatch_hole(r_large_hole, r_hatch, 25, 360/N/2 + split_off);
            hatch_hole(r_large_hole, r_hatch, -25, 360/N/2 + split_off);
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

module leg_attachment(w, h, r)
{
    R = 1.2*r;
    H_tot = 1.5*h + R;
    rotate([0, 2.0, 0])
    difference()
    {
      union()
      {
          cylinder(h=h, r=r);
          // the cap
          translate([0,0,h])
          ellipsoid(r, R);

          translate([0,0,-h/2])
          cylinder(h=h/2, r1=0.8*r, r2=r);

      }

      /* translate([0, w/2 + r/2, H_tot/2 - h/2]) */
      /* cube([2*r, r, 1.1*H_tot], center=true); */

      /* translate([0, -w/2 - r/2, H_tot/2 - h/2]) */
      /* cube([2*r, r, 1.1*H_tot], center=true); */

      cutout_h = 1.5*h;
      cube([2*r, minw, 2*cutout_h], center=true);
      translate([0, 0, cutout_h])
      cube([2*r, 2*r, minw], center=true);
    }
}

// the complete hull
module hull()
{
    h_bottom = 0.1*R_bottom;
    large_cut_h = 0.06*R_bottom;
    translate([0, 0, h_bottom])
    {
        translate([0, 0, H-(1-cap_squash)*R])
        cap(R, (1-cap_squash)*R, large_cut_h, minw);

        translate([0, 0, H-(1-cap_squash)*R])
        main_body(H - (1-cap_squash)*R, R, R_bottom);

        bottom_cap(h_bottom, R_bottom, R_thousing);
    };
    
    // leg mounts
    H_legmount = H/10;
    W_legmount = 0.8*H_legmount;
    R_legmount = R/6;
    for (it = [1: num_legs])
        rotate([0, 0, it*360/num_legs])
        translate([R-0.85*R_legmount, 0, 1.4*Z_leg_mounts])
        leg_attachment(W_legmount, H_legmount, R_legmount, $fn=50);
}

module main_hull()
{
    difference()
    {
        hull($fn=2*$fn);
        
        // triangle cutouts
        tri_cut_w = 2*PI*R/15;
        tri_cut_d = R/20;
        for (it = [1 : 2*num_legs])
            rotate([0, 0, it*360/num_legs/2])
            translate([R_bottom-tri_cut_d, 0, 0])
            rotate([98, 0, 90])
            linear_extrude(2*tri_cut_d, scale=1.5)
            polygon(points=[
                [-tri_cut_w/2, 0],
                [tri_cut_w/2, 0],
                [0, 1.5*Z_leg_mounts],
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
