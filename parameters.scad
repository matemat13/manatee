// user-defined parameters
cap_squash = 0.10;
body_diameter = 37;
body_bottom_diameter = 34;
body_height = 34;

num_legs = 6;
num_doors = 5; // should be lower or equal to the number of legs

leg_mounts_z = 0.30*body_height;
leg_height = 12.6;
leg_length = 7;
leg_cover_width = 4.2;
leg_radius = 3.1;
leg_tube_radius = 1.0;

thrusters_housing_diameter = 25;
thrusters_housing_height = 1.5;
thruster_diameter = 5;
thruster_height = 2.5;

minw = 0.8;

scaling = 1000/280; // meters to millimeters (mech scale)
//scaling = 1000/1000; // meters to millimeters (map scale)
$fn=20;

use_cached_models = true;

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

cached_hull = use_cached_models;
cached_legs = use_cached_models;
cached_thrusters = use_cached_models;
