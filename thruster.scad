// modules for creating a single main (bottom) thruster of the Manatee

include <parameters.scad>

use <common_modules.scad>

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

module main_thrusters()
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

main_thrusters();