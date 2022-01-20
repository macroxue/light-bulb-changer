f = 10;      // finger width
r = 50;      // finger radius
wrist = 20;  // wrist radius
// 3/4 in. x 10 ft. PVC Schedule 40 Plain-End Pipe, $6.46 at Home Depot.
rod = 11;  // rod radius
socket_height = 20;
screw = 3;  // m3
inf = 199;
d = 0.01;
$fn = 100;

module arc(r1, r2, a1, a2) {
  difference() {
    difference() {
      polygon([
        [ 0, 0 ], [ cos(a1) * (r1 + 50), sin(a1) * (r1 + 50) ],
        [ cos(a2) * (r1 + 50), sin(a2) * (r1 + 50) ]
      ]);
      circle(r = r2);
    }
    difference() {
      circle(r = r1 + 100);
      circle(r = r1);
    }
  }
}

module finger_original(end = 22.5) {
  linear_extrude(f) {
    difference() {
      union() {
        translate([ 0, 0, 0 ]) arc(r + f, r, -45, end);
        translate([ (r + f / 2) * cos(-45), (r + f / 2) * sin(-45), 0 ])
            circle(d = f * 1.2);
        translate([ (r + f / 2) * cos(end), (r + f / 2) * sin(end), 0 ])
            circle(d = f * 1);
      }
      mid = (end - 45) / 2;
      translate([ (r + f / 2) * cos(mid), (r + f / 2) * sin(mid), 0 ]) circle(d = 4);
      translate([ (r + f / 2) * cos(-45), (r + f / 2) * sin(-45), 0 ]) circle(d = 4);
      translate([ (r + f / 2) * cos(end), (r + f / 2) * sin(end), 0 ]) circle(d = 4);
    }
  }
}

module finger(end = 22.5) {
  difference() {
    finger_original(end);
    translate([ (r + f / 2) * cos(-45), (r + f / 2) * sin(-45) + 2, -d ])
        rotate([ 0, 0, -90 ]) cube([ 1.5, f, f + d * 2 ]);
  }
}

module wrist() {
  difference() {
    union() {
      difference() {
        cylinder(r = wrist + f / 2, h = f * 1.2);
        for (i = [0:60:360]) {
          rotate([ 0, 0, i ]) translate([ 0, -f / 2 - 0.5, -d ])
              cube([ inf, f + 1, f * 1.2 + d * 2 ]);
        }
        translate([ 0, 0, -d ]) cylinder(r = f * 1.5, h = f * 1.2 + d * 2);
        translate([ 0, 0, f * 1.2 / 2 ]) rotate_extrude() translate([ wrist, 0, 0 ])
            circle(d = 4);
      }
      translate([ 0, 0, -f / 2 ]) cylinder(r = wrist + f / 2, h = f / 2);
      translate([ 0, 0, -socket_height ]) rod_socket();
    }
    cylinder(d = f, h = inf, center = true);
  }
}

module rod_socket() {
  difference() {
    cylinder(r = rod + f / 2, h = socket_height);
    translate([ 0, 0, -f / 2 ]) cylinder(r = rod, h = socket_height);
    translate([ 0, 0, socket_height / 3 ]) rotate([ 0, 90, 0 ])
        cylinder(d = screw, h = inf, center = true);
  }
}

module router_socket(male) {
  difference() {
    union() {
      rotate([ 180, 0, 0 ]) rod_socket();

      // Thread router
      translate([ 0, 0, -4 ]) difference() {
        cylinder(r = rod + f * 1.5, h = 4);
        translate([ 0, 0, -d ]) cylinder(r = rod, h = 4 + d * 2);
        // Thread holes
        for (i = [30:60:360])
          rotate([ 0, 0, i ]) translate([ rod + f, 0, -d ])
              cylinder(d = 4, h = 4 + d * 2);
      }

      // Joint
      translate([ 0, 0, -socket_height - rod - f / 2 ]) difference() {
        union() {
          difference() { sphere(r = rod); }
          cylinder(r = rod, h = rod + f);
        }
        // Screw hole
        translate([ 0, inf / 2, 0 ]) rotate([ 90, 0, 0 ]) cylinder(r = 4, h = inf);
        // Joint
        if (male) {
          translate([ -inf / 2, -(rod / 1.5 + 1) / 2, -inf + rod + f - d ])
              cube([ inf, (rod / 1.5 + 1), inf ]);
        } else {
          translate([ -inf / 2, -rod / 3 - rod / 1.5, -inf + rod + f - d ])
              cube([ inf, rod / 1.5, inf ]);
          translate([ -inf / 2, -rod / 3 + rod / 1.5, -inf + rod + f - d ])
              cube([ inf, rod / 1.5, inf ]);
        }
      }
    }
  }
}

t = 5;
l = 50;

module tee() {
  difference() {
    union() {
      cylinder(r = rod + t, h = l, center = true);
      difference() {
        translate([ 0, -l * 0.375, 0 ]) rotate([ 90, 0, 0 ]) {
          difference() {
            cylinder(r = rod + t, h = l * 0.75, center = true);
            translate([ 0, 0, l * 0.15 ]) rotate([ 0, 90, 0 ])
                cylinder(d = screw, h = inf, center = true);
          }
        }
        translate([ 0, -l / 2, 0 ]) rotate([ 90, 0, 0 ])
            cylinder(r = rod, h = l + d, center = true);
      }
    }
    cylinder(r = rod + 0.25, h = l + d, center = true);
  }
}

module tee2() {
  translate([ rod * 2 + t + 0.25, 0, 0 ]) difference() {
    cylinder(r = rod + t, h = l, center = true);
    cylinder(r = rod + 0.25, h = l + d, center = true);
  }
  rotate([ 90, 0, 0 ]) {
    difference() {
      cylinder(r = rod + t, h = rod * 2 + t * 2, center = true);
      cylinder(r = rod, h = inf, center = true);
      rotate([ 90, 0, 0 ]) cylinder(d = screw, h = inf, center = true);
    }
  }
}

module stopper(height = socket_height / 2) {
  difference() {
    cylinder(r = rod + f / 2, h = height);
    translate([ 0, 0, -d ]) cylinder(r = rod, h = height + d * 2);
    translate([ 0, 0, height * 0.5 ]) rotate([ 0, 90, 0 ])
        cylinder(d = screw, h = inf, center = true);
  }
}

module pulley(radius, height) {
  outer_radius = radius + height * 1.6;
  difference() {
    cylinder(r = outer_radius, h = height, center = true);
    cylinder(r = radius, h = height + d, center = true);
    rotate_extrude() translate([ outer_radius, 0, 0 ]) rotate([ 0, 0, 45 ])
        square(height * .5, center = true);
  }
  for (i = [0:3:360]) {
    rotate([ 0, 0, i ]) translate([ outer_radius - 3, 0, 0 ]) rotate([ 0, 0, 45 ])
        cube([ 2, 2, height ], center = true);
  }
  translate([ 0, 0, height / 2 ]) stopper();
}

module pvc(length) {
  color("#abcdef") difference() {
    cylinder(r = rod, h = length, center = true);
    cylinder(r = rod - 3, h = length + d, center = true);
  }
}

module bulb() {
  color("#fedcba") translate([ 0, 0, 10 ]) {
    sphere(d = 65);
    translate([ 0, 0, 30 ]) rotate([ 0, 180, 0 ])
        linear_extrude(height = 20, scale = 1.5, center = true) {
      circle(r = 15);
    }
  }
}

module candle() {
  color("#fedcba") translate([ 0, 0, 20 ]) cylinder(d = 30, h = 80, center = true);
}

module assembly(degree = 0) {
  // T1
  tee();
  translate([ 0, 0, -f / 2 ]) pvc(l * 2);
  translate([ 0, 0, l * .6 ]) rotate([ 0, 0, degree ]) stopper();

  // T2
  translate([ 0, -l * 4, 0 ]) {
    rotate([ 180, 0, 0 ]) tee2();
    translate([ rod * 2 + t, 0, -f / 2 ]) pvc(l * 2);
    translate([ rod * 2 + t, 0, l * .6 ]) rotate([ 0, 0, degree ]) stopper();
  }

  // Rod connecting T1 and T2
  translate([ 0, -l * 3, 0 ]) rotate([ 90, 0, 0 ]) pvc(l * 5);

  // Pulley1
  pulley_z = -rod - t * 3 - socket_height;
  translate([ 0, 0, pulley_z ]) rotate([ 0, 0, degree ]) pulley(rod, t * 2);

  // Pulley2
  translate([ rod * 2 + t, -l * 4, pulley_z ]) rotate([ 0, 0, degree ])
      pulley(rod, t * 2);

  // Belt
  rotate([ 0, 0, 8 ]) color("#abcdef") {
    translate([ rod + t * 3, 0, pulley_z ]) rotate([ 90, 0, 0 ])
        cylinder(d = t, h = l * 4);
    translate([ -rod - t * 3, 0, pulley_z ]) rotate([ 90, 0, 0 ])
        cylinder(d = t, h = l * 4);
    translate([ 0, 0, pulley_z ]) rotate_extrude(angle = 180)
        translate([ rod + t * 3, 0, 0 ]) circle(d = t);
    translate([ 0, -l * 4, pulley_z ]) rotate([ 180, 0, 0 ]) rotate_extrude(angle = 180)
        translate([ rod + t * 3, 0, 0 ]) circle(d = t);
  }

  // Claw
  translate([ 0, 0, l * 2 + 10 ]) rotate([ 0, 0, degree ]) {
    scale([ 0.8, 0.8, 0.8 ]) bulb();
    for (i = [0:60:360]) rotate([ 0, 0, i ]) {
        translate([ -r * 0.707 + wrist - f / 2, f / 2, 0 ]) rotate([ 90, 0, 0 ]) finger();
      }
    translate([ 0, 0, -r + f / 2 ]) wrist();
  }
}

module pieces() {
  // 6x fingers.
  finger();
  // 1x wrist.
  translate([ t * 3, 0, 0 ]) rotate([ 180, 0, 0 ]) wrist();
  // 2x pulleys.
  translate([ -wrist * 2, 0, 0 ]) pulley(rod, t * 2);
  // 1x tee.
  translate([ t * 2, -wrist * 2 - t, 0 ]) tee();
  // 1x tee2.
  translate([ -wrist * 3, -wrist * 3, 0 ]) tee2();
  // 2x stoppers.
  translate([ wrist * 3 - t, -wrist * 3 - t, 0 ]) stopper(socket_height / 2);
}

module animation() { assembly($t * 360); }

// Uncomment to see the assembly of pieces.
assembly();

// Uncomment to see the rotating plate with OpenScad's "Animate" view.
// animation();

// Uncomment to see pieces to print.
// pieces();

