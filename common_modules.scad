// common helper modules for the Manatee project

module toroid(R, r)
{
    rotate_extrude()
    translate([R, 0, 0])
    circle(r = r);
}

module paraboloid(h, r_bottom, r_top)
{
    r1 = r_bottom;
    r2 = r_top;
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