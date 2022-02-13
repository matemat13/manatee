cap_squash = 0.25;
body_diameter = 37;
body_bottom_diameter = 34;
body_height = 35;

thrusters_housing_diameter = 25;
thrusters_housing_height = 2;
thruster_diameter = 5;
thruster_height = 2.5;

minw = 0.8;

scaling = 1000/280; // meters to millimeters (mech scale)
//scaling = 1000/1000; // meters to millimeters (map scale)
$fn=100;

D = scaling*body_diameter;
R = D/2;
H = scaling*body_height;

D_bottom = scaling*body_bottom_diameter;
R_bottom = D_bottom/2;

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

module cap(r, r2)
{
    // add the docking collar at the top
    union()
    {
        r_thingie = r/4;
        
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
                    ellipsoid(r, r2);
                    
                    // bottom panels cuts
                    cylinder(minw, 2*r);    // vertical
                    for (it = [1:3])        // horizontal cuts
                        rotate([0, 0, 360/3*it+40])
                        translate([-minw/2, 0, 0])
                        cube([minw, 100, 2/5*r2+minw/2]);
                    
                    // top panels cuts
                    translate([0, 0, 2/5*r2])
                    cylinder(1, 2*r);   // vertical
                    for (it = [1:5])    // horizontal cuts
                        rotate([0, 0, 360/5*it])
                        translate([-minw/2, 0, 2/5*r2])
                        cube([minw, 100, 100]);
                }
                // inner, smaller version of the main part
                ellipsoid(r-minw, r2-minw, $fn=$fn/4);
            }
            // a hole at the top for the docking collar
            translate([0,0,r/2])
            cylinder(h=r2/2, r=r_thingie, $fn=$fn/4);
        }
        
        // the docking collar itself
        // outer ring
        translate([0,0,0.3*r])
        difference()
        {
            // the outer ring
            sphere(r/2, $fn=$fn/2);
            // inner cutout from the outer ring
            translate([0,0,0.33*r])
            cylinder(h=r/4, r1=r/8, r2=r/4, $fn=$fn/2);
            
            // locking dots
            for (it = [1:9])
                rotate([0, 0, 360/9*it+32])
                translate([-r/4.5, 0, 0.43*r])
                sphere(r_thingie/10, $fn=$fn/4);
        }
        // the hatch
        translate([0,0,r2-0.85*r_thingie])
        difference()
        {
            union()
            {
                difference()
                {
                    // the doors
                    sphere(r_thingie, $fn=$fn/2);
                    for (it = [1:6])    // vertical cuts
                        rotate([0, 0, 360/6*it+19])
                        translate([-0.05, 0, 0])
                        cube([0.1, 100, 100]);
                    // central hole
                    translate([0,0,r_thingie-2*minw])
                    cylinder(h=r_thingie/4, r1=r_thingie/6, r2=r_thingie/4, $fn=$fn/2);
                }
                // inner, smaller version of the hatch
                sphere(r_thingie-minw, $fn=$fn/2);
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
    rotate([0, 5, 0])
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
    n_legs = 5;
    H_legmount = H/7;
    R_legmount = R/3;
    for (it = [1: n_legs])
        rotate([0, 0, it*360/n_legs])
        translate([R-1.05*R_legmount, 0, H/4])
        leg_attachment(H_legmount, R_legmount, $fn=50);
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

// for reference
translate([100, 0, 15])
import("glt-3n-6.stl");

// main hull
difference()
{
    hull();
    
    tri_cut_w = 2*PI*R/15;
    tri_cut_d = R/25;
    for (it = [1: 10])
    rotate([0, 0, it*360/10])
    translate([R_bottom-tri_cut_d, 0, 0])
    rotate([98, 0, 90])
    linear_extrude(2*tri_cut_d, scale=1.2)
    polygon(points=[
        [-tri_cut_w/2, 0],
        [tri_cut_w/2, 0],
        [0, 1.3*tri_cut_w],
    ]
    );
}


// main thrusters
translate([0, 0, -H_thousing])
{
    thrusters_housing(H_thousing, R_thousing, 5);

    // main thrusters
    n_thrusters = 10;
    R_thrusters = R_thousing-R_thruster;
    for (it = [1: n_thrusters])
        rotate([0, 0, it*360/n_thrusters])
        translate([R_thrusters, 0, -H_thruster])
        thruster(H_thruster, R_thruster);
}