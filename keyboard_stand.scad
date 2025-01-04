include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <BOSL2/shapes2d.scad>

$fn=180;

x = [1, 0, 0];
y = [0, 1, 0];
z = [0, 0, 1];
e = 0.1;
m = 0.5;

kallax_depth = 390;
kallax_top_thickness = 38;
kallax_cell_thickness = 16;
kallax_cell_height = 335;

bit_d = 5 + m;

d1_height = 104;
d1_depth = 263;
d1_feet_height = 14;
d1_length = 1327;

gap_between_kallax_and_d1 = 20;


/////////////////////////////////////////////////

shelf_depth = d1_depth;
shelf_height = kallax_cell_height + kallax_top_thickness - d1_height - d1_feet_height;
shelf_thickness = 18;
shelf_length = d1_length - 50;

joint_position_1 = shelf_depth / 3;
joint_position_2 = shelf_depth * 2 / 3;

module mirrored(axis) {
    children();
    mirror(axis) children();
}

module kallax() {
    total_length = 1465;
    a = kallax_top_thickness;
    b = kallax_cell_height;
    th = (total_length - 4 * b - 2 * a) / 3;

    difference() {
        cube([kallax_depth, 1465, 2 * a + 2 * b + th]);
        for (i = [0:1]) {
            for (j = [0:3]) {
                translate([-e, a + j * (b + th), a + i * (b + th)]) cube([kallax_depth + 2 * e, kallax_cell_height, kallax_cell_height]);
            }
        }
    }
}

module d1_2d() {
    translate([0, d1_feet_height]) rect([d1_depth, d1_height], rounding=5, anchor=[-1, -1, 0]);
    translate([35 - 15, 0]) square([30, d1_feet_height]);
    translate([d1_depth - 45 - 15, 0]) square([30, d1_feet_height]);
}


module bit_hole() {
    rotate(45 * z) square([bit_d, bit_d], center=true);
}


module key_hole_2d(length) {
    mirrored(x) mirrored(y)  {
        square([shelf_thickness / 2 + m, length / 2 + m]);
        translate([shelf_thickness / 2 + m, length / 2 + m]) bit_hole();
    }
}

module key_2d(length, width, key_hole_length) {
    difference() {
        square([width, length], center=true);
        mirrored(x) mirrored(y) {
            translate([key_hole_length / 2, length / 2 - shelf_thickness - m]) {
                bit_hole();
                square([100, 100]);
            }
        }
        
    }
}

module key() {
    translate(-shelf_thickness / 2 * z)
    linear_extrude(height=shelf_thickness)
    key_2d(kallax_cell_height - 2 * m, 120, 100);

}

module frame_2d() {
    base_r = 100;

    difference() {
        union() {
            a = [0, kallax_cell_height + 30];
            b = [kallax_depth - m, 0];
            c = [kallax_depth + shelf_depth, shelf_height - shelf_thickness];
            bez = [a, a + [-120, -40], [50, 50], b + [-150, 0],
                b, b + [0, 200], b + [150, 200], c + [0, -50],
                c];
                path = bezpath_curve(bez, N=4, splinesteps=100);
                polygon(path);
            translate([0, kallax_cell_height-50]) square([kallax_depth, kallax_top_thickness+50]);
        }

        translate([0, kallax_cell_height]) bit_hole();

        translate([kallax_depth, kallax_cell_height + kallax_top_thickness])
            mirror(y) square([1000, d1_height + d1_feet_height]);
        minkowski() {
            translate([0, kallax_cell_height]) square([kallax_depth, kallax_top_thickness]);
            square([m, m], center=true);
        }
        
        difference() {
            translate([kallax_depth, shelf_height - shelf_thickness]) square([shelf_depth + e, shelf_thickness + e]);
            translate([kallax_depth + joint_position_1 - m, shelf_height - shelf_thickness]) square([shelf_depth / 3 + 2 * m, shelf_thickness + 2 * e]);
        }
        translate([kallax_depth, shelf_height - shelf_thickness]) bit_hole();
        translate([kallax_depth + joint_position_1, shelf_height - shelf_thickness]) bit_hole();
        translate([kallax_depth + joint_position_2, shelf_height - shelf_thickness]) bit_hole();

        translate([70, 250])
        key_hole_2d(100);

        translate([320, 250])
        key_hole_2d(100);
    }
}

module d1() {
    difference() {
        translate(d1_feet_height * z)
            mirror(y)
            rotate(90 * x)
            linear_extrude(height=d1_length)
            rect([d1_depth, d1_height], rounding=5, anchor=[-1, -1, 0]);
    }

    for (p = [[35, 200], [35, d1_length - 200], [d1_depth / 2, d1_length / 2], [d1_depth - 45, 100], [d1_depth - 45, d1_length - 100]]) {
        translate([p[0], p[1], 0]) cylinder(d=25, h=d1_feet_height);
    }

}

module shelf_board_2d() {
    kallax_total_length = 1465;
    a = kallax_top_thickness;
    b = kallax_cell_height;
    th = (kallax_total_length - 4 * b - 2 * a) / 3;
    
    translate([0, shelf_depth / 2])
    difference() {
        squircle([shelf_length, shelf_depth], 0.9, $fn=720);
        mirrored(x)
        {
            translate((th + shelf_thickness) / 2 * x) key_hole_2d(shelf_depth / 3);
            translate((kallax_cell_height - m) * x) key_hole_2d(shelf_depth / 3);
        }
    }

    echo (th);
}

module assembly() {
    %kallax();

    kallax_total_length = 1465;
    a = kallax_top_thickness;
    b = kallax_cell_height;
    th = (kallax_total_length - 4 * b - 2 * a) / 3;

    module frame() {
        rotate(90 * x) linear_extrude(height=shelf_thickness) frame_2d();
    }

    module frame_pair() {
        mirror(y) frame();
        translate(kallax_cell_height * y) frame();
    }
    translate([0, a + b + th, a + b + th]) frame_pair();
    translate([0, a + (b + th) * 2, a + b + th]) frame_pair();

    translate([kallax_depth, kallax_total_length / 2, a + b + th + shelf_height - shelf_thickness])
    rotate(90 * z)
    mirror(y)
    linear_extrude(height=shelf_thickness) shelf_board_2d();

    echo (a + b + th + shelf_height)
    translate([kallax_depth + gap_between_kallax_and_d1, kallax_total_length / 2 - d1_length / 2, a + b + th + shelf_height]) 
    %d1();

    
    for (pos = [
            [70, a + b + th + b / 2],
            [320, a + b + th + b / 2],
            [70, a + (b + th) * 2 + b / 2],
            [320, a + (b + th) * 2 + b / 2] ]) {
        translate((250 + a + b + th) * z)
        translate(pos)
        rotate(90 * y) key();
    }

    
}

module export_2d() {
    module frame_key_pair() {
        frame_2d();
        translate([650, 80])
        rotate(90 * z) key_2d(kallax_cell_height - 2 * m, 120, 100);
    }

    module frame_key_pair_2() {
        frame_key_pair();
        translate([800, 620]) rotate(180 * z) frame_key_pair();
    }

    translate([5, 50]) mirror(x - y) {
        frame_key_pair_2();
        translate([0, shelf_length]) mirror(y) frame_key_pair_2();

        translate([850, shelf_length / 2])
        rotate(-90 * z) shelf_board_2d();
    }
}

//export_2d();
assembly();
