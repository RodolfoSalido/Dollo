
include <globals.scad>;
include <include.scad>;

use <extention.scad>;
use <corner.scad>;
use <rail.scad>;
use <z_screw.scad>;
use <long_tie.scad>;
use <endstop.scad>;
use <z_motor_mount.scad>;
use <mockups.scad>;

// 1 unit = 30mm
z_units = 4; 

// de facto settings
rail_width = 15;
rail_offset = 30;

// for Dollo rework
//rail_width = 20;
//rail_offset = 35;

module bed_rail() {
    rail(rail_width, 120);
}

module bed_rail_short() {
    // 60 mm = 2x30mm from corners
    intersection() {
        translate([0,0,-60]) bed_rail();
        cylinder(d=rail_width*1.5, h=120);
    }
}

module bed_rail_center() {
    rail_center(length=120, width=rail_width/2);
}

module bed_rail_center_short() {
    intersection() {
        translate([0,0,-1]) bed_rail_center();
        cylinder(d=rail_width,h=120);
    }
}

module debug_bed_rail() {
    intersection() {
        union() {
            bed_rail_short();
            translate([0,0,60-2]) bed_rail();
            translate([0,0,120+60-2]) bed_rail();
            bed_rail_center_short();
            translate([0,0,120-1]) bed_rail_center();
        }
        translate([0,15,0]) cube([30,30,400], center=true); 
    }
}

module bed_rail_frame_mount() {
    
    h = 139;
    hx_w = rail_width-slop;
    
    module rail_hole() {
        intersection() {
            hull() {
                hexagon(hx_w+9,0.01);
                hexagon(hx_w+6,2);
            }
            cube([30,60,10],center=true);
        }
    }
    
    difference() {
        union() {
            translate([0,0,3.5/2]) cube([30,h,3.5], center=true);
            hull() {
                translate([0,h/2-15,7/2]) cube([14,30,7],center=true);
                translate([0,h/2-15,1/2]) cube([18,30,1],center=true);
            }
            hull() {
                translate([0,-h/2+15,7/2]) cube([14,30,7],center=true);
                translate([0,-h/2+15,1/2]) cube([18,30,1],center=true);
            }
            hull() {
                translate([0,0,3.5+2/2]) cube([12,90,2], center=true);
                translate([0,0,1/2]) cube([16,90,1], center=true);
            }
            translate([0,rail_offset,3.5]) rail_hole();
            translate([0,-rail_offset,3.5]) rail_hole();
        }
        
        translate([0,h/2-30,-0.01]) rotate([90,0,180]) male_dovetail(31,bridge_extra=0.3);
        translate([0,-h/2-1,-0.01]) rotate([90,0,180]) male_dovetail(31,bridge_extra=0.3);

        translate([-15,0,3.5/2]) cube([1,1,10], center=true);
        translate([15,0,3.5/2]) cube([1,1,10], center=true);

        translate([0,rail_offset,0]) hexagon(hx_w);
        translate([0,-rail_offset,0]) hexagon(hx_w);
        translate([0,rail_offset-rail_width/2-12/2+slop,0]) cube([1,12,20],center=true);
        translate([0,-rail_offset+rail_width/2+12/2-slop,0]) cube([1,12,20],center=true);
    }
    
    %translate([-15,60,0]) rotate([90,0,0]) extention(support=false);
    %translate([-28.5,33,-35]) rotate([90,180,0]) z_motor_mount();
}

module bed_rail_frame_mount_top() {
    screw_pos = -30/2-z_screw_d/2-1;
    difference() {
        union() {
            bed_rail_frame_mount();
            hull() {
                translate([-1,0,3.5/2]) cube([1,z_screw_d+10,3.5],center=true);
                translate([screw_pos,0,0]) cylinder(d=z_screw_d+10,h=3.5,$fn=50);
            }
        }
        translate([screw_pos,0,-1]) cylinder(d=z_screw_d+3,h=10,$fn=50);
    }
}

module _slide_hull(width=rail_width, height=20, bewel=2.1) {
    slide_w = width+9;
    hull() {
        translate([0,0,bewel]) hexagon(slide_w, height=height-2*bewel);
        hexagon(slide_w-bewel, height=height);
    }
}

module bed_rail_slide(beweled=false, slop=0, render_thread=true) {
    h = 50;
    difference() {
        intersection() {
            rail_slide(width=rail_width, height=h, wiggles=11,slop=slop);
            if (beweled) {
                _slide_hull(height=h);
            }
        }
        translate([0,0,14]) _slide_hull(width=rail_width-5, height=h-28, bewel=5);
        if (render_thread) {
            translate([0,0,-3/2]) _v_thread(thread_d=hexagon_dia_to_cylinder(rail_width+9), pitch=3, rounds=h/3+1, direction=0, steps=100);
        }
    }
}

module bed_rail_slide_nut() {
    d = hexagon_dia_to_cylinder(rail_width+9) + 5;
    screw_d = hexagon_dia_to_cylinder(rail_width+9) + 3*slop;
    round_length = d*PI;
    notches = floor(round_length/2.7);
    
    intersection() {
        difference() {
            union() {
                cylinder(d=d,h=6,$fn=50);
                translate([0,0,6]) cylinder(d1=d,d2=d-6,h=3,$fn=50);
            }
            v_screw(screw_d=screw_d, pitch=3, h=12, direction=0, steps=100);
            
            for(i = [0:notches-1]) {
                rotate([0,0,360/notches*i]) translate([d/2+0.3,0,0]) rotate([0,0,45]) cube([2,2,20],center=true);
            }
        }
        cylinder(d=d+1,h=8.4,$fn=60);
    }
}

module _bed_rail_slide_arm() {
    
    difference() {
        union() {
            cube([20,25,15]);
            translate([0,25,15]) intersection() {
                translate([0,0,15]) rotate([0,0,-25]) rotate([-90,0,0]) chamfered_cube_side(20,30,60,4);
                translate([0,-10,-15]) cube([50,60,15]);
            }
            intersection() {
                translate([20,53,0]) chamfered_cube(30,35,30,4);
                translate([20,53,0]) cube([30,35,15]);
            }
        }

        translate([0,10,15]) rotate([90,0,0]) rotate([0,90,0]) _slide_hull(width=rail_width+slop);
        translate([10,65,-0.1]) cube([30,40,20]);
        translate([25,65,-0.1]) rotate([0,0,180]) male_dovetail(20);
        translate([40,80,-0.1]) rotate([0,0,-90]) male_dovetail(20);
    }

}

module bed_rail_slide_arm_1() {
    difference() {
        _bed_rail_slide_arm();
        translate([13.4,30,-1]) _threads(d=8, h=20, z_step=1.8, depth=0.5, direction=0);
        translate([20,45,15]) rotate([0,0,-25]) rotate([0,45,0]) cube([5,20,5],center=true);
    }
}

module bed_rail_slide_arm_2() {
    rotate([0,180,0]) mirror([0,0,1]) union() {
        difference() {
            _bed_rail_slide_arm();
            translate([13.4,30,-1]) cylinder(d=8,h=17, $fn=30);
        }
        translate([20,45,15-slop]) rotate([0,0,-25]) rotate([0,45,0]) cube([5,20-slop,5],center=true);
    }
}

module bed_screw_housing(render_threads=true) {
    
    slide_holder_d = hexagon_dia_to_cylinder(rail_width + 9) + 6;
    
    union() {
        difference() {
            union() {
                translate([4.5,0,25/2]) cube([65,60,25], center=true);
                translate([29,rail_offset,0]) cylinder(d=slide_holder_d,h=30, $fn=50);
                translate([29,-rail_offset,0]) cylinder(d=slide_holder_d,h=30, $fn=50);
            }
            translate([0,0,1.2]) intersection() {
                difference() {
                    union() {
                        translate([0,0,13]) cylinder(d=25+28+2*slop, h=30, $fn=100);
                        cylinder(d=25+28-2, h=13.1, $fn=100);
                    }
                    rotate([0,0,12]) screw_housing_bottom(frame_width=28,render_threads=render_threads);
                }
                translate([3,-1,0]) cube([25+26, 25+23, 100],center=true);
            }
            translate([0,0,-30]) rotate([0,0,12]) cylinder(d=25+1,h=40, $fn=50);

            translate([29,rail_offset,-5]) _slide_hull(width=rail_width + 2*slop, height=40);
            translate([29,-rail_offset,-5]) _slide_hull(width=rail_width + 2*slop, height=40);

            translate([-41,0,30/2-5]) cube([30,61,30],center=true);
            
            translate([65/2+4.5,0,-0.01]) rotate([0,0,90]) male_dovetail(25-2);
            
            //translate([-19,30,-0.01]) rotate([0,0,180]) male_dovetail(25-2);
            translate([-19,26,-0.01]) hull() {
                cylinder(d=11,h=17.01,$fn=30);
                translate([0,8/2,17.02/2]) cube([10,0.1,17.02],center=true);
            }

            //translate([-19,-30,-0.01]) rotate([0,0,0]) male_dovetail(25-2);
            translate([-19,-26,-0.01]) hull() {
                cylinder(d=11,h=17.01,$fn=30);
                translate([0,-8/2,17.02/2]) cube([10,0.1,17.02],center=true);
            }
            
            if (render_threads) {
                translate([-19,-26,17.2]) v_screw(screw_d=7,h=9,pitch=1.8, direction=0, steps=30);
                translate([-19,26,17.2]) v_screw(screw_d=7,h=9,pitch=1.8, direction=0, steps=30);
            } else {
                translate([-19,-26,17.2]) cylinder(d=7,h=9,$fn=30);
                translate([-19,26,17.2]) cylinder(d=7,h=9,$fn=30);
            }
            
            translate([29,rail_offset,0]) cylinder(d1=slide_holder_d-2,d2=slide_holder_d-14,h=6,$fn=50);
            translate([29,-rail_offset,0]) cylinder(d1=slide_holder_d-2,d2=slide_holder_d-14,h=6,$fn=50);
            translate([29,rail_offset,30-6]) cylinder(d2=slide_holder_d-2,d1=slide_holder_d-14,h=6,$fn=50);
            translate([29,-rail_offset,30-6]) cylinder(d2=slide_holder_d-2,d1=slide_holder_d-14,h=6,$fn=50);
        }
    }
    %translate([-14,60,40]) rotate([-90,0,180]) bed_housing_coupler();
}

module bed_screw_housing_top() {
    intersection() {
        rotate([0,0,-12+1/3*360]) screw_housing_top(frame_width=27.5);
        difference() {
            translate([3,1,0]) cube([25+25.5, 25+22.5, 100],center=true);
            for (i = [0:2]) {
                rotate([0,0,-12+i*1/3*360]) translate([27.5,0,0]) cylinder(d=10,h=40, $fn=30);
            }
        }
    }
}

module bed_housing_coupler() {
    union() {
        difference() {
            union() {
                cube([12,40,30]);
                translate([12,0,0]) cube([25,10,60]);
                translate([5,40,34]) rotate([90,0,0]) hull() {
                    cylinder(d=11-slop,h=17,$fn=50);
                    translate([0,-8/2,17/2]) cube([10-slop,0.1,17],center=true);
                }
            }
            translate([12,25,0]) rotate([0,0,90]) male_dovetail(29);
            translate([27,10,0]) rotate([0,0,180]) male_dovetail(61);

            rotate([0,78,0]) cube([60,100,10],center=true);
            
            translate([37,0,0]) rotate([0,-60,0]) cube([60,100,8],center=true);
            translate([37,0,60]) rotate([0,60,0]) cube([60,100,8],center=true);
            
            translate([12,0,60]) rotate([0,-60,0]) cube([30,50,8],center=true);
            
            translate([0,40,0]) rotate([65,0,0]) cube([60,40,15],center=true);
            
            rotate([0,0,45]) cube([9,9,125],center=true);
            translate([37,0,0]) rotate([0,0,45]) cube([9,9,125],center=true);
            
            translate([5,40.01,34]) rotate([90,0,0]) {
                cylinder(d=7+slop,h=20,$fn=40);
                cylinder(d1=7+slop+4,d2=7+slop,h=2,$fn=40);
            }
        }
    }
}

module endstop_screw_mount() {
    difference() {
        union() {
            translate([-5,-0.01,0]) cube([10,3,23]);
            translate([-5,0,0]) cube([10,14,8]);
            translate([0,14.5,0]) cylinder(d=12,h=8, $fn=40);
            rotate([-90,0,180]) long_tie(23);
        }
        translate([0,14.5,0]) _threads(h=15);
    }
}

module _screw_knob(h=10) {
    h1 = h/5;
    h2 = h-2*h1;
    difference() {
            union() {
                cylinder(d1=15-2*h1, d2=15,h=h1, $fn=40);
                translate([0,0,h1]) cylinder(d=15,h=h2, $fn=40);
                translate([0,0,h-h1]) cylinder(d2=15-2*h1, d1=15,h=h1, $fn=40);
            }
            for (i=[0:11]) {
                rotate([0,0,i*360/12]) translate([15/2,0,0]) cylinder(d=2,h=10,$fn=20);
            }
    }
}

module endstop_screw() {
    
    union() {
        translate([0,0,9.99]) _threads(8-2*slop, 38);
        _screw_knob();
    }
}

module endstop_screw_nut() {
    difference() {
        _screw_knob(h=7);
        _threads(h=15);
    }
}

module _bed_attach_body() {
    difference() {
        union() {
            cube([70,30,10]);
            translate([44,20,0]) cube([26,10,50]);
        }
        translate([70-15,30,0]) rotate([0,0,180]) male_dovetail(50);
        translate([0,15,10]) rotate([-90,0,-90]) male_dovetail(40);

        translate([74-30,0,10]) rotate([0,-45,0]) cube([50,50,50]);
        translate([70/2,0,0]) rotate([45,0,0]) cube([70,10,10],center=true);
        translate([70/2,30,0]) rotate([45,0,0]) cube([70,10,10],center=true);
    }
}

module _spring() {
    module spring_half() {
        intersection() {
            translate([-100/2+6,0,0]) difference() {
                cylinder(d=100,h=15,$fn=100);
                cylinder(d=100-3,h=15.1,$fn=100);
            }
            translate([0,-100,0]) cube([200,200,200]);
        }
    }

    spring_half();
    mirror([1,0,0]) spring_half();
}

//_spring();


module bed_attachment_spring() {
    //%translate([0,0,3]) cube([200,213,3], center=true);
    //%view_bed_frame();

    module triangle(h=15) {
        intersection() {
            linear_extrude(h) polygon(points=[[0,0],[0,4],[4,0]]);
            cube([3,3,h]);
        }
    }

    module clip() {
        difference() {
            union() {
                _spring();
                translate([6-1.5,-15/2,0]) cube([2, 15, 30]);
                translate([6+.5,-15/2,0]) cube([3, 22, 30]);
                translate([6+3.5,-2,18.5]) rotate([-90,0,0]) triangle();
                translate([6+3.5,10,18.5]) rotate([0,0,0]) triangle(11.5);

                translate([-22+6,-17/2,0]) cube([22-6-6+1.5,17, 15]);
                translate([8,-50,0]) rotate([0,0,90])difference() {
                    translate([0,0,5]) _bed_attach_body();
                    translate([25,0,0]) cube([50,15,15]);
                }
            }
            translate([-22+8,0,15/2]) rotate([0,90,0]) cylinder(d=8,h=40,$fn=40);

            translate([-22+8,-12/2,0]) cube([7,12,16]);
            translate([6-1.5,-15/2,15]) rotate([45,0,0]) cube([6,30,20]);
        }
    }

    clip();
    //translate([90,-125,-8]) rotate([0,-90,-90]) clip();
    //translate([90,-125+15/2,5]) rotate([180,0,0]) bed_attachment_spring_screw(true);
}

module bed_attachment_spring_screw(render_threads=true) {
    h = 21;
    union() {
        difference() {
            _screw_knob(3);
            cube([1.3, 5, 3], center=true);
        }
        translate([0,0,3]) {
            if (render_threads) {
                _threads(8-3*slop, h);
            } else {
                cylinder(d=8,h=h, $fn=40);
            }
        }
    }
}

module bed_attachment_spring_nut() {
    difference() {
        translate([0,0,6.8/2]) chamfered_cube(14.5,11.5,6.5,1, center=true);
        _threads(h=15);
    }
}

module bed_attachment(brim=false, wall=false) {
    difference() {
        union() {
            _bed_attach_body();
            translate([64.5,6,15.5]) rotate([-90,0,0]) cylinder(d=10,h=24,$fn=30);
            translate([64.5,15/2+6,11]) cube([7,15,8],center=true);
        }

        translate([64.5,0,15.5]) rotate([-90,0,0]) cylinder(d=8,h=7,$fn=30);
        translate([64.5,29,15.5]) rotate([-90,0,0]) cylinder(d=7,h=2,$fn=30);

        translate([64.5,0,15.5]) rotate([-90,0,0]) cylinder(d=3.2,h=30,$fn=30);
        translate([64.5,8,15.5]) rotate([-90,0,0]) cylinder(d1=3.2,d2=4,h=25,$fn=30);
    }

    if (brim) {
        translate([-5,-2.5,0]) rounded_cube_side(80,35,0.2,5);
    }

    if (wall) {
        translate([-5,-2.5,0]) difference() {
            rounded_cube_side(80,35,20,5);
            translate([0.5, 0.5]) rounded_cube_side(80-1,35-1,20,5-1);
        }
    }
}

module bed_adjustment_nut() {
    nubs = 14;
    difference() {
        union() {
            cylinder(d=6.9, h=10,$fn=30);
            intersection() {
                for(i=[0:nubs-1]) {
                    rotate([0,0,360/nubs*i]) translate([12,0,6/2]) sphere(d=8,$fn=30);
                }
                cylinder(d=34,h=6,$fn=30);
            }
            cylinder(d=24,h=6,$fn=30);
        }
        nut();
        cylinder(d=3.2,h=12,$fn=20);
    }
}

module view_bed_frame() {
    translate([-97,97,0]) rotate([90,0,45]) corner_90(corner_len=20, support=false, extra_stiff=true);
    translate([-97,-97,0]) rotate([90,0,135]) corner_90(corner_len=20, support=false, extra_stiff=true);
    translate([97,97,0]) rotate([90,0,-45]) corner_90(corner_len=20, support=false, extra_stiff=true);
    translate([97,-97,0]) rotate([90,0,225]) corner_90(corner_len=20, support=false, extra_stiff=true);

    translate([-60,110,0]) rotate([0,90,0]) extention(support=false);
    translate([-60,-80,0]) rotate([0,90,0]) extention(support=false);
    translate([80,60,0]) rotate([90,0,0]) extention(support=false);
    translate([-110,60,0]) rotate([90,0,0]) extention(support=false);

    color("white") {
        translate([40,-120]) rotate([-90,0,0]) bed_attachment();
        mirror([1,0,0]) translate([40,-120]) rotate([-90,0,0]) bed_attachment();
        translate([-40,120]) rotate([-90,0,180]) bed_attachment();
        mirror([1,0,0]) translate([-40,120]) rotate([-90,0,180]) bed_attachment();
    }

    %translate([0,0,10]) bed_mk2();
}

module view_proper() {
    
    bed_position = 160;
    
    frame_mockup(bed_angle=0, units_x=2, units_y=2, units_z=1);
    
    //translate([0,0,bed_position+40]) view_bed_frame();

    translate([-120-45,0,30-6.5]) rotate([-90,0,0]) bed_rail_frame_mount();
    translate([-120-45,0,210]) rotate([180,0,0]) bed_rail_frame_mount_top()

    translate([-120-45,-30,32]) bed_rail_short();
    translate([-120-45,30,32]) bed_rail_short();
    translate([-120-45,-30,88]) bed_rail();
    translate([-120-45,30,88]) bed_rail();

    translate([-120-16,0,-5]) cylinder(d=25,h=120+89);
    translate([-120-16,0,bed_position+40]) rotate([180,0,180]) bed_screw_housing(render_threads=false);

    translate([-120,60,bed_position]) rotate([90,0,0]) bed_housing_coupler();
    translate([-120,-60,bed_position]) mirror([0,1,0]) rotate([90,0,0]) bed_housing_coupler();

    translate([-120-45,30,bed_position+15]) bed_rail_slide(true, slop=0, render_thread=false);

    translate([-120-60,15,225]) rotate([0,180,90]) z_endstop();
    translate([-120-53.1,0,bed_position+40]) rotate([180,0,-90]) endstop_screw_mount();
    //translate([-120-53.1-14.5,0,bed_position+40-25]) endstop_screw();
}

module slide_test_parts() {
    intersection() {
        bed_rail_slide(true);
        cube([40,40,20], center=true);
    }
    translate([30,0,0]) intersection() {
        bed_rail_slide(true, slop=0.1);
        cube([40,40,20], center=true);
    }
    translate([0,30,0]) intersection() {
        bed_rail_slide(true, slop=0.2);
        cube([40,40,20], center=true);
    }
}

//debug_bed_rail();
//intersection() {
//    bed_screw_housing(render_threads=false);
//    translate([10.5,-22,0])cube([50,50,50]);
//}

//view_proper();
//view_bed_frame();

//slide_test_parts();

//bed_rail();
//bed_rail_short();
//bed_rail_center();

//bed_rail_frame_mount();
//bed_rail_frame_mount_top();

//bed_rail_slide(true);
//bed_rail_slide_nut();

//bed_screw_housing(render_threads=false);
//bed_screw_housing(render_threads=true);
//bed_screw_housing_top();

//translate([5,0,0]) bed_housing_coupler();
//mirror([1,0,0]) bed_housing_coupler();

endstop_screw_mount();
//endstop_screw();
//endstop_screw_nut();

//bed_attachment_spring();
//mirror([1,0,0]) bed_attachment_spring();

//bed_attachment();
//mirror([1,0,0]) bed_attachment();
//bed_attachment(brim=true, wall=true);
//mirror([1,0,0]) bed_attachment(brim=true, wall=true);

//bed_adjustment_nut();

//bed_attachment_spring_screw();
//bed_attachment_spring_nut();
