include <globals.scad>;
include <include.scad>;

use <extention.scad>;
use <mockups.scad>;
use <z_coupler.scad>;
use <z_screw.scad>;

module _plate(length=40, height=10) {
    hull() {
        translate([0,0,0]) cube([30,length,height/2]);
        translate([7.5,0,height/2]) cube([15,length,height/2]);
    }
}

module _leg() {
    intersection() {
        translate([0,30,-5]) extention_finished(units=3);
        cube([31,31,90]);
    }
}

module leg(plate_len=45) {
    difference() {
        union() {
            translate([0, 20, 0]) _plate(plate_len);
            translate([20, 30, 0]) rotate([0,0,-90]) _plate(plate_len);
            _leg();
            // hole bridge
            translate([10,10,male_dove_depth+0.2]) cube([10,10,0.2]);
        }
        dove_len = plate_len+30;

        translate([15,plate_len+20,0]) rotate([90,0,0]) male_dovetail(dove_len, bridge_extra=0.2);
        translate([0,15,0]) rotate([90,0,90]) male_dovetail(dove_len, bridge_extra=0.2);
    }
}

module leg_motor_mount() {
    difference() {
        union() {
            difference() {
                translate([-13.5,0,50/2]) cube([60,50,50], center=true);
                translate([56,0,0]) rotate([0,-45,0]) cube([50,55,500], center=true);
                translate([0,0,50/2]) cube([43,43,51], center=true);
                translate([-38,0,50/2]) cube([30,15,51], center=true);
                translate([-35.4,27,50/2]) rotate([0,0,25]) cube([30,15,51], center=true);
                translate([-35.4,-27,50/2]) rotate([0,0,-25]) cube([30,15,51], center=true);
            }
            difference() {
                translate([0,0,5]) rotate([0,180,0]) motor_plate(5, bolt_head_cones=true);
                hull() {
                    translate([20,0,5/2]) cube([40,motor_center_hole-1,5.01], center=true);
                    translate([20,0,-1/2]) cube([40,motor_center_hole+3,1], center=true);
                }
            }
            difference() {
                translate([-30-z_screw_d/2-1,-15,0]) _leg();
                difference() {
                    cube([43,43,139], center=true);
                    translate([-44,0,60]) rotate([0,45,0]) cube([30,60,80], center=true);
                }
            }
            translate([-30/2-10/2-z_screw_d/2-1,-10/2,male_dove_depth]) cube([10,10,0.2]);
        }
        #translate([-30/2-z_screw_d/2-1,55/2,0]) rotate([90,0,0]) male_dovetail(55);
    }

    // debug
    %translate([0,-42/2,40/2+5]) rotate([-90,0,0]) mock_stepper_motor();
    %translate([-30-z_screw_d/2-1,-30,-30]) extention();
    %translate([0,0,1]) rotate([180,0,0]) motor_shaft_adapter();
    %translate([0,0,-16]) rotate([180,0,0]) z_screw_motor_flex_coupler(fast_render=true);
}

function bottom_hole_x_pos(dia) = dia/2-(dia/2/3);

module _bottom_holes(dia=60, sphere_d=6) {

    x_pos = bottom_hole_x_pos(dia);
    union() {
        for(i=[0:3]) {
                rotate([0,0,i*360/4]) translate([x_pos,0,-1]) cylinder(d=sphere_d-1, h=3, $fn=20);
                rotate([0,0,i*360/4]) translate([x_pos,0,2]) sphere(d=sphere_d, $fn=20);
        }
        difference() {
            cylinder(d=x_pos*2+1,h=1.5,$fn=40);
            cylinder(d=x_pos*2-1,h=1.6,$fn=40);
        }
    }
}

module foot(dia=60) {

    z = 20 - dia/2;
    difference() {
        intersection() {
            translate([0,0,z]) sphere(d=dia, $fn=90);
            translate([0,0,6]) cube([80,80,12], center=true);
        }
        cylinder(d=metal_rod_size,h=40, $fn=40);
        translate([0,0,12]) rotate([-90,0,0]) tie_end(30);

        for(i=[0:3]) {
            rotate([0,0,45+i*360/4]) translate([0,-15,0]) male_dovetail(30);
        }
        _bottom_holes(dia);
        %translate([0,0,30]) rotate([90,0,45]) translate([-15,-15,-15]) extention(1);
    }
}

module foot_small() {
    foot(dia=45);
}

pitch = 3;
dia_adjustable_inner = sqrt(30*30*2) + pitch+0.5;
dia_adjustable_outer = dia_adjustable_inner + slop;
screw_steps = 100;

module foot_adjustable_core() {

    difference() {
        v_screw(h=15, screw_d=dia_adjustable_inner, pitch=pitch, direction=0, steps=screw_steps);
        cylinder(d=metal_rod_size,h=40, $fn=40);
        translate([0,0,15]) rotate([-90,0,0]) tie_end(30);
        for(i=[0:3]) {
            rotate([0,0,45+i*360/4]) translate([0,-15,0]) male_dovetail(30);
        }
    }
    %translate([0,0,30]) rotate([90,0,45]) translate([-15,-15,-15]) extention(1);
}

module foot_adjustable() {
    difference() {
        intersection() {
            translate([0,0,6]) sphere(d=dia_adjustable_outer+12,$fn=60);
            translate([0,0,22/2]) cube([100,100,22],center=true);
        }
        translate([0,0,5]) v_screw(h=20, screw_d=dia_adjustable_outer, pitch=pitch, direction=0, steps=screw_steps);
        cylinder(d=(dia_adjustable_outer+10)/2, h=10, $fn=60);

        x_offset = (dia_adjustable_outer+10)/2 + 5;
        _bottom_holes();
    }
}

module foot_dampener(dia=60) {
    x_pos = bottom_hole_x_pos(dia);

    difference() {
        union() {
            _bottom_holes(dia, sphere_d=5.5);
            translate([0,0,-1]) cylinder(d=dia*0.9,h=1,$fn=50);
        }
        translate([0,0,-1]) cylinder(d=x_pos*2-6,h=1,$fn=40);
        for(i = [0:3]) {
            rotate([0,0,i*360/4]) translate([x_pos,0,0]) cylinder(d=2, h=10, $fn=10);
        }
    }
}

//leg();
//leg_motor_mount();
//foot();
//foot_small();
//foot_adjustable_core();
//foot_adjustable();
foot_dampener();
