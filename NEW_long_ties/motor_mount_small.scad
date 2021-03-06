///////// NEED TO REDO THE MATH BECUASE OF THE SNAP ON RAILS, WELL WORTH IT

$fn = 30;
include <globals.scad>;
include <include.scad>;


frame_width = 35.5;
tail_depth = 11;
rack_height = 12.5;
rack_slide_height = 8;
mount_max = 62.5;
wabble = 1.5;
not_tooth_gap = 0;
rack_gap = 2.5;
tower_height = 17.5+3;

text = "Dollo";
font = "Liberation Sans";

hole_length = 0.5;

//$fn=220;

// for rounded cube
diameter = 2;

module y_mount_added(){    
    //base
    translate([0,-5.75+rack_gap/2,-1]) rounded_cube(y=38.5+rack_gap*2, x=frame_width+35+1, z=4, center=true, corner=diameter);
    
    // lower slide
    slide_depth = 11;
    slide_pos_y = frame_width-24.5+rack_gap;
    
    module slide() {
        difference() {
            rotate([45,0,0]) rounded_cube(z=15, x=17, y=15, corner=2.5, center=true);
            translate([0,0,-8]) cube([60,30,30], center=true);
        }
    }
    
    translate([-27.25,slide_pos_y,-4.65]) slide();
    translate([0,slide_pos_y,-4.65]) slide();
    translate([27.25,slide_pos_y,-4.65]) slide();
    
    translate([0,slide_pos_y-7.25,0.6]) rounded_cube(z=5, x=frame_width+35+1, y=22, corner=diameter,center=true);
    
    translate([0,slide_pos_y,0.05]) rounded_cube(z=6.1, x=30, y=28, corner=diameter, center=true);
    
    //towers

    //top tower
	translate([0-21,-25.75,0.625]) cube([42,18,tower_height]);
    
    tower_pos_y = -2;

    // right tower
	translate([17,tower_pos_y,(17.5+4.25)/2]) rounded_cube(26,15,tower_height,diameter,center=true);
    translate([(32-21-4)+19-4.5,tower_pos_y+15/2-4.8,tower_height]) cylinder(d=7,h=2);
    
    // left tower
    difference() {
        translate([-17,tower_pos_y,(17.5+4.25)/2]) rounded_cube(26,15,tower_height, diameter,center=true);
        translate([(-21-4)+3.5,tower_pos_y+15/2-4.8,tower_height-1.5]) cylinder(d=7.25,h=2.5);
    }
}

module bolt_hole() {
    hull() {
        cylinder(d=bolt_hole_dia, h=70);
        translate([hole_length,hole_length,0]) cylinder(d=bolt_hole_dia, h=70);
    }
}

module bolt_head_hole() {
    hull() {
        cylinder(d=6.5, h=3);
        translate([hole_length,hole_length,0]) cylinder(d=6.5, h=3);
    }
}

module tapered_bolt_head_hole() {
    hull() {
        cylinder(d1=bolt_hole_dia, d2=6.5, h=3);
        translate([hole_length,hole_length,0]) cylinder(d1=bolt_hole_dia, d=6.5, h=3);
    }
}

module y_mount_taken(){
	halign = [
	   [0, "center"]
	 ];
	 
		 rotate([0,0,-90]) for (a = halign) {
		   translate([-7, 12.5,-3]) {
			 linear_extrude(height = 1) {
			   text(text = str(text), font = font, size = 6, halign = a[1]);
			 }
		   }
		 }
		 rotate([0,0,90]) for (a = halign) {
		   translate([7,12.5,-3]) {
			 linear_extrude(height = 1) {
			   text(text = str(text), font = font, size = 6, halign = a[1]);
			 }
		   }
		 }
		 
	rotate([0,0,45]) {
        // bolt holes. leave 0.2 = one layer which can be easily drilled out
        translate([5.65-21,5.65-21,0.2]) bolt_hole();
		translate([5.65+31-21,5.65-21,0.2]) bolt_hole();
		translate([5.65-21,5.65+31-21,0.2]) bolt_hole();
		translate([5.65+31-21,5.65+31-21,-10]) bolt_hole();

		//counter sink

        translate([5.65-21,5.65-21,-3]) bolt_head_hole();
		translate([5.65+31-21,5.65-21,-3]) bolt_head_hole();
		translate([5.65-21,5.65+31-21,-3]) bolt_head_hole();
		translate([5.65+31-21,5.65+31-21,0.5]) tapered_bolt_head_hole();

		translate([-70,-30,-5]) cube([50,70,50]);
		translate([-30,-70,-5]) cube([70,50,50]);

		translate([0,0,-5]) cylinder(d=motor_center_hole, h=20);
        translate([hole_length,hole_length,-5]) cylinder(d=motor_center_hole, h=20);

		rotate([90,0,-45]) translate([-8,-3,-53+tail_depth]) male_dovetail(height=30);
		rotate([90,0,-45]) translate([8,-3,-53+tail_depth]) male_dovetail(height=30);

		rotate([90,0,-45]) translate([-8,-3,22-tail_depth]) male_dovetail(height=30);
		rotate([90,0,-45]) translate([8,-3,22-tail_depth]) male_dovetail(height=30);
	}
}

module motor_mount( ){
	difference(){
		y_mount_added();
		y_mount_taken();
	}
}

module translated_mount(){
translate([(-obj_leg/2)-2.5,0,0]) rotate([0,90,0]) motor_mount();
}

module screw_driver(){
translated_mount();
}

module do_motor_mount() {
    translate([0,0,20.5]) rotate([0,-90,0]) difference(){
        screw_driver();
        translate([-15,0,0]) rotate([0,90,0]) union(){
            translate([5.65,5.65,-1]) cylinder(d=3.5, h=40);
            translate([5.65+31,5.65,-1]) cylinder(d=3.5, h=40);
            translate([5.65,5.65+31,-1]) cylinder(d=9, h=40);
            translate([5.65+31,5.65+31,-1]) cylinder(d=9, h=40);

            translate([-20,20,15]) rotate([90,0,45]) cylinder(h=70, d=22);
            translate([20,20,15]) rotate([90,0,-45]) cylinder(h=70, d=22);
        }
    }
}

do_motor_mount();
