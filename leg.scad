// modules for creating the landing legs of the Manatee

include <parameters.scad>

use <common_modules.scad>

module leg_cover(l, w, small_cover_h, small_cover_a)
{
    cover_d = w/10;
    cover_f = 2*cover_d;
    
    translate([cos(small_cover_a)*small_cover_h-cover_f, 0, -sin(small_cover_a)*small_cover_h])
    {
        translate([cover_f, 0, 0])
        rotate([0, small_cover_a, 0])
        translate([-small_cover_h, 0, 0])
        difference()
        {
            translate([0, -w/2, 0])
            linear_extrude(cover_d)
            polygon(points=[
                [small_cover_h-cover_f, 0],
                [small_cover_h, cover_f],
                [small_cover_h, w-cover_f],
                [small_cover_h-cover_f, w],
                [0, w],
                [0, 0],
            ]
            );
            
            translate([l/2, 0, cover_d])
            cube([l, minw/2, minw], center=true);
        }
        
        difference()
        {
            translate([0, -w/2, 0])
            linear_extrude(cover_d)
            polygon(points=[
                [l-cover_f, 0],
                [l, cover_f],
                [l, w-cover_f],
                [l-cover_f, w],
                [0, w],
                [0, 0],
            ]
            );
            
            translate([l/2, 0, cover_d])
            cube([l, minw/2, minw], center=true);
        }
    }
}

module leg(h, l, w, leg_r, tube_r)
{
    h = H_leg;
    l = L_leg;
    w = W_leg_cover;
    leg_r = R_leg;
    tube_r = R_leg_tube;
    
    cover_a = 40;
    small_cover_a = 30;
    small_cover_h = h/4;
    
    rotate([0, cover_a, 0])
    leg_cover(l, w, small_cover_h, small_cover_a);
    
    tube1_l = 0.5*l;
    tube1_a = 120;
    tube2_l = 0.6*l;
    tube2_a = 160;
    
    small_r = 0.7*tube_r;
    
    leg_small_r = leg_r/3;
    
    tubes_h = 0.45*h;
    leg_end_h = 0.2*h;
    
    translate([0, 0, -tubes_h])
    rotate([0, tube1_a, 0])
    {
        // tube 1
        cylinder(h=2*tube1_l, r=tube_r, center=true);
        
        translate([0, 0, tube1_l])
        {
            // tube 1 to tube 2 connector
            rotate([90, 0, 0])
            cylinder(h=2*tube_r+small_r, r=tube_r, center=true);
                        
            rotate([0, tube2_a-tube1_a, 0])
            {
                // tube 2
                cylinder(h=tube2_l, r=tube_r);
                
                translate([0, 0, tube2_l])
                {
                    // tube 2 to leg ending connector
                    rotate([90, 0, 0])
                    cylinder(h=2*tube_r, r=tube_r, center=true);
                    
                    // spheres at the ends of the connector
                    for (it = [0 : 1])
                    translate([0, tube_r-2*it*tube_r, 0])
                    sphere(tube_r);
                    
                    // the leg ending
                    rotate([0, -tube2_a, 0])
                    {
                        ell_part_h = 0.4*leg_end_h;
                        difference()
                        {
                            translate([0, 0, -ell_part_h])
                            ellipsoid(leg_r, ell_part_h);
                         
                            groove_width = scaling*0.2;   
                            for (it = [1 : 5])
                            {
                                rotate([0, 0, it*360/5])
                                translate([-groove_width/2, 0, -0.8*ell_part_h])
                                cube([groove_width, 0.95*leg_r, ell_part_h]);
                            }
                        }
                        difference()
                        {
                            translate([0, 0, -1.1*ell_part_h])
                            ellipsoid(leg_r, ell_part_h);
                            translate([0, 0, -1.5*ell_part_h])
                            cube([2*leg_r, 2*leg_r, ell_part_h], center=true);
                        }
                        
                        round_part_h = leg_end_h-ell_part_h;
                        translate([0, 0, -round_part_h-ell_part_h])
                        {
                            groove_width = scaling*0.1;
                            cylinder(h=round_part_h, r=leg_r-groove_width);
                            difference()
                            {
                                cylinder(h=round_part_h, r=leg_r);
                                                                
                                for (it = [1 : $fn])
                                {
                                    rotate([0, 0, it*360/$fn])
                                    translate([-groove_width/2, leg_r-groove_width/2,0])
                                    cube([groove_width, groove_width, round_part_h]);
                                }
                                translate([0, 0, round_part_h-groove_width])
                                cylinder(h=2*groove_width, r=leg_r+groove_width);
                            }
                        }
                    }
                }
            }
        }
    }
    
    // cover connectors
    difference()
    {
        translate([0, 0, -tubes_h])
        rotate([0, tube1_a, 0])
        translate([0, 0, tube1_l])
        {
            for (it = [0 : 1])
            {
                translate([0, tube_r+small_r/2-it*(2*tube_r+small_r), 0])
                {
                    sphere(tube_r);
                    
                    rotate([0, -tube1_a, 0])
                    cylinder(h=tubes_h, r=small_r);
                    
                    rotate([0, -tube1_a-80, 0])
                    cylinder(h=3*tube1_l, r=small_r);
                }
            }
        }
        
        rotate([0, cover_a, 0])
        translate([cos(small_cover_a)*small_cover_h, 0, -sin(small_cover_a)*small_cover_h])
        translate([tube1_l, 0, h/2])
        cube([h, h, h], center=true);
    }
}

leg();