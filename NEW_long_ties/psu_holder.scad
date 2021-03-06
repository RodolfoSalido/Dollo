include <globals.scad>;
include <include.scad>;

use <long_bow_tie.scad>;
use <mockups.scad>;

psu_height = 50;
psu_width = 114;

psu_cover_width = 119+2*slop;
psu_cover_height = 55+2*slop;

atx_psu_width = 150+2*slop;
atx_psu_height = 86+2*slop;

atx_psu_cover_width = atx_psu_width+4+2*slop;
atx_psu_cover_height = atx_psu_height+2+slop;

thickness = 7;

bolt_hole_down = 11.5;
bolt_hole_up = 13;

module mock_psu() {
    cube([psu_width, 220, psu_height]);
}

module mock_atx_psu(holes=true, slop=0) {
    w = atx_psu_width;
    h = atx_psu_height;

    color("grey") {
        if (holes) {
            minus_atx_psu_holes() {
                translate([-w/2,0.01,0]) cube([w, 140, h]);
            }
        } else {
            translate([-w/2,0,0]) cube([w, 140, h]);
        }
    }
}

module minus_atx_psu_holes(hole=3.2) {
    difference() {
        children();
        translate([-138/2,0,6]) rotate([-90,0,0]) cylinder(d=hole, h=5, $fn=30);
        translate([138/2,0,6]) rotate([-90,0,0]) cylinder(d=hole, h=5, $fn=30);
        translate([138/2,0,6+64]) rotate([-90,0,0]) cylinder(d=hole, h=5, $fn=30);
        translate([-150/2+30,0,atx_psu_height-6]) rotate([-90,0,0]) cylinder(d=hole, h=5, $fn=30);
    }
}

module _front(w, h, dove_pos=26) {
    difference() {
        cube([w+10, thickness, h+10], center=true);
        cube([w, thickness+1, h], center=true);
    }
    difference() {
        translate([-w/2, -thickness+thickness/2, h/2]) cube([25,8,dove_pos+8]);
        translate([-w/2+25,thickness/2+(8-thickness), h/2+dove_pos]) rotate([0,90,180]) male_dovetail(25);
    }
    difference() {
        translate([w/2-25,-thickness+thickness/2, h/2]) cube([25,8,dove_pos+8]);
        translate([w/2,thickness/2+(8-thickness), h/2+dove_pos]) rotate([0,90,180]) male_dovetail(26);
    }
}

module front() {
    _front(psu_cover_width, psu_cover_height);
}

module front_atx() {
    union() {
        difference() {
            _front(atx_psu_cover_width, atx_psu_cover_height, 18);
            translate([0,10/2-2,-atx_psu_cover_height/2-1]) cube([atx_psu_cover_width,10,10],center=true);
        }
    }
}

module _back(w,h) {
    difference() {
        cube([w+10, thickness, h+10], center=true);
        cube([w, thickness+1, h], center=true);
    }
}

module back() {
    union() {
        _back(psu_width, psu_height);
        difference() {
            translate([psu_width/2-0.5+2*slop,-thickness/2,psu_height/2]) cube([8,15,35]);
            translate([psu_width/2+7.5+2*slop,-thickness/2-1,psu_height/2+28.5]) rotate([0,90,90]) male_dovetail(17);
        }
    }
}

module back_atx() {
    union() {
        difference() {
            _back(atx_psu_width, atx_psu_height);
            translate([0,10/2-2,-atx_psu_height/2-1]) cube([atx_psu_width,10,10],center=true);
        }
        difference() {
            translate([atx_psu_width/2-0.5+2*slop,-thickness/2,atx_psu_height/2]) cube([8,15,27]);
            translate([atx_psu_width/2+7.5+2*slop,-thickness/2-1,atx_psu_height/2+18]) rotate([0,90,90]) male_dovetail(17);
        }
    }
}

// unused
module clip() {
    c_len = 20;
    rotate([-90,0,0]) difference() {
        union() { 
            translate([0,0,-scaled_male_dove_depth()]) long_bow_tie_split(c_len);
            translate([11,0,-5-scaled_male_dove_depth()]) long_bow_tie_split(c_len);
            translate([-2.5,-c_len,-scaled_male_dove_depth()]) cube([16,c_len,scaled_male_dove_depth()]);
            translate([8.9,-c_len,-scaled_male_dove_depth()-5]) cube([3,c_len,scaled_male_dove_depth()]);
        }
        translate([11-slop,-c_len-1,-10]) cube([5,c_len+2,11]);
    }
}

module atx_psu_cover() {
    l = 45;
    nob_y = l/2-3;

    minus_atx_psu_holes(3.7) {
        translate([0,45/2+0.01,atx_psu_cover_height/2]) difference() {
            union() {
                cube([atx_psu_cover_width, l,atx_psu_cover_height],center=true);
                translate([-atx_psu_cover_width/2,nob_y,5]) sphere(d=3,$fn=20);
                translate([-atx_psu_cover_width/2,nob_y,-5]) sphere(d=3,$fn=20);
                translate([-atx_psu_cover_width/2,nob_y-thickness-2,5]) sphere(d=3,$fn=20);
                translate([-atx_psu_cover_width/2,nob_y-thickness-2,-5]) sphere(d=3,$fn=20);

                translate([atx_psu_cover_width/2,nob_y,5]) sphere(d=3,$fn=20);
                translate([atx_psu_cover_width/2,nob_y,-5]) sphere(d=3,$fn=20);
                translate([atx_psu_cover_width/2,nob_y-thickness-2,5]) sphere(d=3,$fn=20);
                translate([atx_psu_cover_width/2,nob_y-thickness-2,-5]) sphere(d=3,$fn=20);

            }
            translate([0,2,0]) cube([atx_psu_width, l,atx_psu_cover_height+1],center=true);
            translate([-atx_psu_cover_width,-15,atx_psu_cover_height/2]) rotate([-45,0,0]) cube([atx_psu_cover_width*2,60,60]);
            translate([-atx_psu_cover_width,-15,-atx_psu_cover_height/2]) rotate([-45,0,0]) cube([atx_psu_cover_width*2,60,60]);

            translate([-11/2+1,-0.01,-1]) cube([atx_psu_width-11,l,atx_psu_cover_height-20],center=true);
            translate([1,-0.01,-6]) cube([atx_psu_width-4,l,atx_psu_cover_height-32],center=true);
            translate([0,-0.01,-13]) cube([atx_psu_width-20,l,atx_psu_cover_height-32],center=true);
            translate([12,-0.01,13]) cube([atx_psu_width-44,l,atx_psu_cover_height-32],center=true);
        }
    }
}

module view_proper() {
    translate([psu_width/2+28+2*slop,300/2-(thickness/2+(8-thickness)),psu_cover_height/2-66.5]) front();
    translate([psu_width/2+28+2*slop,-30-(thickness/2+(8-thickness)),psu_height/2-63.5]) back();

    frame_mockup(bed_angle=0, units_x=2, units_y=2, units_z=2);
    %translate([28+2*slop, -60, -63.5 ]) mock_psu();
}

module view_proper_atx() {
    translate([atx_psu_width/2-8,300/2-(thickness/2+(8-thickness)),atx_psu_height/2-90.5]) front_atx();
    translate([atx_psu_width/2-8,60-(thickness/2+(8-thickness)),atx_psu_height/2-89.5]) back_atx();

    frame_mockup(bed_angle=0, units_x=2, units_y=2, units_z=2);
    translate([-8+atx_psu_width/2, 180, -89.5 ]) rotate([0,0,180]) mock_atx_psu();
    translate([-8+atx_psu_width/2, 183, -89.5 ]) rotate([0,0,180]) atx_psu_cover();
}

module psu_clips() {
    translate([0,psu_cover_height,0]) rotate([90,0,0]) front(psu_cover_width, psu_cover_height);
    translate([0,-psu_height/2-17,0]) rotate([90,0,0]) back(psu_width,psu_height);
}

module psu_clips_atx() {
    translate([0,psu_cover_height,0]) rotate([90,0,0]) front_atx();
    translate([0,-psu_height/2-17,0]) rotate([90,0,0]) back_atx();
}

module clip_extension() {
    rotate([0,10,0]) difference() {
        intersection() {
            rotate([0,-10,0]) cube([46,25,15]);
            cube([42,30,25]);
        }
        translate([0,25-15,0]) rotate([0,0,-90]) male_dovetail(25);
        translate([42,25-15,0]) rotate([0,0,90]) male_dovetail(25);
    }
}

view_proper();
//view_proper_atx();
//psu_clips();
//clip();
 //psu_clips_atx();
//rotate([90,0,0]) atx_psu_cover();
//rotate([90,0,0]) front_atx();
//rotate([90,0,0]) back_atx();
//clip_extension();