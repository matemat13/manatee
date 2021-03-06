// user-defined parameters
cap_squash = 0.05;
body_diameter = 37;
body_bottom_diameter = 34;
body_height = 36;

num_legs = 6;
num_doors = 5; // should be lower or equal to the number of legs

leg_mounts_z = 0.26*body_height;
leg_height = 12.6;
leg_length = 7;
leg_cover_width = 3;
leg_radius = 3.1;
leg_tube_radius = 0.7;

thrusters_housing_diameter = 25;
thrusters_housing_height = 1.5;
thruster_diameter = 5;
thruster_height = 2.5;

minw = 0.8;

scaling = 1000/280; // meters to millimeters (mech scale)
//scaling = 1000/1000; // meters to millimeters (map scale)
$fn=20;


// calculated parameters
D = scaling*body_diameter;
R = D/2;
H = scaling*body_height;

D_bottom = scaling*body_bottom_diameter;
R_bottom = D_bottom/2;

Z_leg_mounts = scaling*leg_mounts_z;
H_leg = scaling*leg_height;
L_leg = scaling*leg_length;
W_leg_cover = scaling*leg_cover_width;
R_leg = scaling*leg_radius;
R_leg_tube = scaling*leg_tube_radius;

D_thousing = scaling*thrusters_housing_diameter;
R_thousing = D_thousing/2;
H_thousing = scaling*thrusters_housing_height;

D_thruster = scaling*thruster_diameter;
R_thruster = D_thruster/2;
H_thruster = scaling*thruster_height;

module toroid(R, r)
{
    rotate_extrude()
    translate([R, 0, 0])
    circle(r = r);
}

module paraboloid(h, r1, r2)
{
    dr = r1 - r2;
    fn = 20;
    rotate_extrude()
    polygon(points=[
        [0, 0],
        for (it = [0:1:fn]) [r1-it*it/fn/fn*dr, h*(it/fn)],
        [0, h],
    ]);
}

module ellipsoid(r1, r2)
{
    dr = r1 - r2;
    fn = 20;
    dang = 90/fn;
    rotate_extrude()
    polygon(points=[
        for (it = [0:1:fn]) [r1*cos(it*dang), (r1-dr)*sin(it*dang)],
        [0, 0]
    ]);
}

module fillet(h, r1, r2)
{
    dr = r1 - r2;
    fn = 20;
    dang = 90/fn;
    rotate_extrude()
    polygon(points=[
        [0, 0],
        for (it = [0:1:fn]) [r1-dr+dr*cos(it*dang), h*sin(it*dang)],
        [0, h],
    ]);
}

module rcube(size, r)
{
    minkowski()
    {
        cube(size);
        sphere(r);
    }
}

module cap(r, h)
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
            cylinder(h=h/2, r=r_hatch, $fn=$fn/4);
        }
        
        // the docking collar itself
        collar_outer_r = r/2;
        lock_dots_r = r_hatch/10;
        // outer ring
        translate([0,0,h-collar_outer_r+2*lock_dots_r])
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
        translate([0, 0, H-(1-cap_squash)*R]) cap(R, (1-cap_squash)*R);
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

module leg_cover(l, w, small_cover_h, small_cover_a)
{
    cover_d = w/10;
    cover_f = 2*cover_d;
    
    translate([cos(small_cover_a)*small_cover_h-cover_f, 0, -sin(small_cover_a)*small_cover_h])
    {
        translate([cover_f, 0, 0])
        rotate([0, small_cover_a, 0])
        translate([-small_cover_h, -w/2, 0])
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
    }
}

module leg(h, l, w, leg_r, tube_r)
{
    cover_a = 40;
    small_cover_a = 30;
    small_cover_h = h/4;
    
    rotate([0, cover_a, 0])
    leg_cover(l, w, small_cover_h, small_cover_a);
    
    tube1_l = 0.5*l;
    tube1_a = 120;
    tube2_l = 0.6*l;
    tube2_a = 160;
    
    small_r = 0.5*tube_r;
    
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
                        translate([0, 0, -ell_part_h])
                        ellipsoid(leg_r, ell_part_h);
                        
                        round_part_h = leg_end_h-ell_part_h;
                        translate([0, 0, -round_part_h-ell_part_h])
                        cylinder(h=round_part_h, r=leg_r);
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

module thrusters_housing(h, r, n)
{
    cylinder(h=h, r=r);
}

module thruster(h, r)
{
    h1 = 0.5*h;
    r1 = 0.8*r;
    dr = 0.02*r1;
    
    h2 = h-h1;
    
    n = 80;
    N = 2*n;
    dang = 360/N;
    
    // nozzle body
    translate([0, 0, h2])
    linear_extrude(h1)
    polygon(points=[
      for (it = [0:N]) [(r1-dr*(it%2))*cos(it*dang), (r1-dr*(it%2))*sin(it*dang)],
      [0, 0]
    ]);
    
    // piping
    r_pipe = 0.15*r;
    translate([0, 0, h2+r_pipe])
    toroid(r1, r_pipe, $fn=30);
    translate([0, r1, h2+r_pipe])
    cylinder(h=h1, r=r_pipe, $fn=30);
    
    // nozzle ending
    difference()
    {
        paraboloid(h2, r, r1);
        translate([0,0,-0.1*h2])
        paraboloid(h2, r-minw, r1-minw);
    }
}

/// MAIN
// for reference
//translate([100, 0, 15])
//import("glt-3n-6.stl");

// main hull
difference()
{
    hull($fn=100);
    
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

// legs
for (it = [1 : num_legs])
    rotate([0, 0, it*360/num_legs])
    translate([R_bottom, 0, 0.9*Z_leg_mounts])
    leg(H_leg, L_leg, W_leg_cover, R_leg, R_leg_tube);

// main thrusters
translate([0, 0, -H_thousing])
{
    thrusters_housing(H_thousing, R_thousing, 5, $fn=100);

    // main thrusters
    n_thrusters = 10;
    R_thrusters = R_thousing-R_thruster;
    for (it = [1: n_thrusters])
        rotate([0, 0, it*360/n_thrusters])
        translate([R_thrusters, 0, -H_thruster])
        thruster(H_thruster, R_thruster);
}