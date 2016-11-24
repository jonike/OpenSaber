use <../threads.scad>
use <../shapes.scad>
use <../vents.scad>
include <dim.scad>
use <buttress.scad>

M_DOTSTAR_EDGE = M_DOTSTAR - X_DOTSTAR / 2;

INCHES_TO_MM = 25.4;
MM_TO_INCHES = 1 / 25.4;
$fn = 90;
EPS = 0.01;
EPS2 = EPS * 2;

H_HEAT_SINK_THREAD = 10.0;
D_HEAT_SINK_THREAD = 20.4;
R_DOTSTAR          = 90;

DOTSTAR_WALL       = Y_DOTSTAR + 0.5;

module innerTube()
{
    translate([0, 0, M_WAY_BACK]) {
        cylinder(d=D_AFT, h=M_TRANSITION - M_WAY_BACK);
    }
    translate([0, 0, M_TRANSITION]) {
        cylinder(d=D_FORWARD, h = H_FAR);
    }
}

module heatSink()
{
    translate([0, 0, M_LED_HOLDER_FRONT - H_HEAT_SINK_THREAD]) {
        cylinder(h=H_HEAT_SINK_THREAD + 0.2, d=D_HEAT_SINK_THREAD);
    }
}

// LED / button positive (above axis)
// thread negative (below axis)
//
module switch()
{
    D_OUTER_TOP = 13.8;
    D_INNER_TOP = 11.0;
    H_TOP       =  1.5;
    H_BODY      = 13;   // approx. connections below.

    color("yellow") {
        translate([0, 0, M_SWITCH_CENTER]) {
            rotate([R_DOTSTAR, 0, 0]) {
                translate([0, 0, Y_SWITCH]) {
                    cylinder(h = H_TOP, r1 = D_OUTER_TOP / 2, r2 = D_INNER_TOP / 2);
                    translate([0, 0, -H_BODY]) {
                        cylinder(h = H_BODY, d=D_SWITCH);
                    }            
                }
            }

        }
    }
}

module dotstars(y, strip)
{
    translate([-X_DOTSTAR/2, -y, 0]) {
        for(i=[0:3]) {
            PAD = 0.4;
            translate([-PAD/2, 0, DOTSTAR_SPACE * i - PAD/2]) {
                cube(size=[X_DOTSTAR + PAD, y, X_DOTSTAR + PAD]);
            }
        }
    }   
    if (strip) {
        X_PAD = 7;  // min 7
        END_PAD = 2.5;
        X_STRIP = X_DOTSTAR + X_PAD;
        Z_STRIP = DOTSTAR_SPACE * 3 + X_DOTSTAR + END_PAD;
        T = 3;

        translate([-X_DOTSTAR/2 - X_PAD/2, 0, 0]) {
            cube(size=[X_STRIP, T, Z_STRIP]);
        }
    }
}

module dotstarsPositioned(y, strip)
{
    rotate([0, 0, R_DOTSTAR]) {
        translate([0, -R_FORWARD + DOTSTAR_WALL + EPS, M_DOTSTAR_EDGE]) {
            dotstars(y, strip);
        }
    }    
}

module ledHolder()
{
    H = M_LED_HOLDER_FRONT - M_LED_HOLDER_BACK;
    difference() {
        translate([0, 0, M_LED_HOLDER_BACK]) cylinder(h=H, d=D_FORWARD);
        heatSink();
        dotstarsPositioned(20, true);
    }
}

module speaker()
{
    cylinder(h=H_SPKR_PLASTIC, d=D_SPKR_PLASTIC);
    translate([0, 0, H_SPKR_PLASTIC]) cylinder(h=H_SPKR_METAL, d=D_SPKR_METAL);
}

module speakerHolder()
{
    FORWARD_SPACE = 2;
    AFT_SPACE = 2;
    H = H_SPKR_METAL + H_SPKR_PLASTIC + FORWARD_SPACE + AFT_SPACE;
    T = 2;

    translate([0, 0, -H]) {
        intersection() {
            cylinder(h=H, d=D_POMMEL);
            difference() {
                union() {
                    translate([-T/2, -20, 0]) cube(size=[T, 40, H]);
                    translate([-20, -T/2, 0]) cube(size=[40, T, H]);
                }
                translate([0, 0, T]) {
                    speaker();
                }
                cylinder(h=T*2, d=D_SPKR_METAL);
            }
        }
        translate([0, 0, H - T]) {
            difference() {
                cylinder(h=T, d=D_POMMEL);
                cylinder(h=T, d=D_SPKR_PLASTIC - 4);
            }
        }    
    }
}

module switchAndPortHolder()
{
    POWER_X         = 11;
    POWER_Y         = 14.5;
    POWER_Z         = 10;
    POWER_OFFSET_Y  = 0.2;
    POWER_OFFSET_X  = -1;

    H = (M_LED_HOLDER_BACK - M_TRANSITION + T_TRANSITION_RING);
    T = 3;

    intersection() {
        innerTube();

        difference() {
            union() {
                translate([-10, Y_SWITCH - T, M_TRANSITION - T_TRANSITION_RING]) {
                    cube(size=[20, T+1.5, H]);
                }
                
                W = 2 * (M_PORT_CENTER - M_TRANSITION); // fancy; snaps into ring.
                difference() 
                {
                    translate([-W/2, Y_SWITCH, M_PORT_CENTER - W/2]) {
                        cube(size=[W, 6 - T, W]);
                    }
                    // Slope the front.
                    translate([-W/2, Y_SWITCH, M_PORT_CENTER + W/2]) {
                        rotate([-45, 0, 0]) {
                            cube(size=[W, W, W]);
                        }
                    }
                }
                
            }
            // switch
            translate([0, 0, M_SWITCH_CENTER]) {
                rotate([-90, 0, 0]) {
                    cylinder(h=20, d=D_SWITCH);
                    translate([0, 0, Y_SWITCH]) cylinder(h=20, d=D_SWITCH_TOP);
                }        
            }

            // Port (std)
            translate([0, 0, M_PORT_CENTER]) {
                rotate([-90, 0, 0]) {
                    cylinder(h=20, d=D_SMALL_PORT);
                }
            }
            transitionRing();
            heatSink();
        }
    }
}


module dotstarHolder() {
    intersection()
    {
        innerTube();

        rotate([0, 0, R_DOTSTAR]) 
        {
            difference()
            {
                OFFSET = 34;
                translate([-10, -R_FORWARD, M_TRANSITION - T_TRANSITION_RING + OFFSET]) {
                    cube(size=[20, DOTSTAR_WALL, M_LED_HOLDER_BACK - M_TRANSITION + T_TRANSITION_RING - OFFSET]);
                }
                translate([0, -R_FORWARD + DOTSTAR_WALL + EPS, M_DOTSTAR_EDGE]) {
                    dotstars(10);
               }
               //transitionRing();
            }
        }
    } 
}

module forwardRail()
{
    intersection()
    {
        translate([0, 0, M_TRANSITION - T_TRANSITION_RING]) {
            cylinder(d=D_FORWARD, h=M_LED_HOLDER_BACK - M_TRANSITION + T_TRANSITION_RING);
        }
        translate([-4, -R_FORWARD, M_TRANSITION - T_TRANSITION_RING]) {
            cube(size=[8, 2.5, 100]);
        }
    }
}

module transitionRing()
{
    intersection() {
        cylinder(h=H_FAR, d=D_AFT);
        union() {
            translate([0, 0, M_TRANSITION - T_TRANSITION_RING]) {
                tube(T_TRANSITION_RING, D_FORWARD/2, D_AFT/2);
            }
            difference() {
                translate([-20, -R_FORWARD, M_TRANSITION - T_TRANSITION_RING]) {
                    cube(size=[40, 4, T_TRANSITION_RING]);
                }            
                translate([-4, -R_FORWARD, M_TRANSITION - T_TRANSITION_RING]) {
                    cube(size=[8, 2.5, T_TRANSITION_RING]);
                }
            }
            translate([-20, Y_SWITCH - 5, M_TRANSITION - T_TRANSITION_RING]) {
                cube(size=[40, 2, T_TRANSITION_RING]);
            }            
        }
    }    
}

module rail(r)
{
    intersection() {
        H = M_TRANSITION - T_TRANSITION_RING - M_SPKR;

        innerTube();
        M = [M_BUTTRESS_0, M_BUTTRESS_1, M_BUTTRESS_2];

        rotate([0, 0, r]) {
            difference() {
                translate([-W_RAIL/2, R_AFT - RAIL_OUTER_NOTCH, M_SPKR]) {
                   cube(size=[W_RAIL, 10, H]);
                }
                for(m=M) {
                    translate([-W_RAIL/2, R_AFT - RAIL_OUTER_NOTCH, m]) {
                       cube(size=[W_RAIL, RAIL_INNER_NOTCH, W_RAIL]);
                    }
                }
            }
        }
    }    
}

*switch();
*union() {
    ledHolder();
    switchAndPortHolder();
    dotstarHolder();
    forwardRail();
}
*transitionRing();
translate([0, 0, M_SPKR]) speakerHolder();
rail(RAIL_ANGLE_0);
rail(RAIL_ANGLE_1);
translate([0, 0, M_BUTTRESS_2]) buttress();
translate([0, 0, M_BUTTRESS_1]) buttress();
translate([0, 0, M_BUTTRESS_0]) buttress();

*color("yellow") heatSink();
*color("yellow") speaker();
*color("yellow") speakerHolder();
