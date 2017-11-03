include <dim.scad>
use <buttress.scad>
use <../shapes.scad>
use <vents.scad>
use <emitter.scad>
use <swoop.scad>

$fn=90;
EPS = 0.01;
EPS2 = EPS * 2;

AFT_HOLDER   = false;
AFT          = false;
MAIN_DISPLAY = false;
MAIN_CRYSTAL = false;
MAIN_MC      = true;
MAIN_EMITTER = false;
EMITTER      = false;

DISPLAY_INNER_W = (DISPLAY_W - DISPLAY_MOUNT_W)/2;
DISPLAY_INNER_L = (DISPLAY_L - DISPLAY_MOUNT_L)/2;

M_SPEAKER_FRONT 	= M_SPEAKER_BACK + H_SPEAKER_HOLDER;
M_BATTERY_BACK 		= M_SPEAKER_FRONT;
M_DISPLAY_BUTTRESS 	= M_DISPLAY + DISPLAY_L - DISPLAY_INNER_L - H_BUTTRESS / 2;

R_DISPLAY_THREAD = 0.8; // M2 bolt
R_DISPLAY_THREAD_HEAD = 2.0;
DEPTH_DISPLAY_THREAD = 4;

module battery() {
    color("yellow") translate([0, 0, M_BATTERY_BACK - EPS]) {
        cylinder(d=D_BATTERY, h = H_BATTERY + EPS2);
    }
}

module crystal() {
    translate([0, Y_CRYSTAL, M_ZONE_1 + H_BUTTRESS + DZ_BUTTRESS + EPS]) {
        color("Aquamarine") {
            cylinder(h=Z_CRYSTAL, d=H_CRYSTAL-2);
        }
    }
    translate([0, Y_CRYSTAL, M_CRYSTAL_VIEW_CENTER-10]) {
        color("MediumTurquoise") {
            cylinder(h=20, d=H_CRYSTAL);
        }
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
            rotate([-90, 0, 0]) {
                translate([0, 0, Y_SWITCH]) {
                    //cylinder(h = H_TOP, r1 = D_OUTER_TOP / 2, r2 = D_INNER_TOP / 2);
                    cylinder(h=5, d=D_OUTER_TOP+1);
                    translate([0, 0, -H_BODY]) {
                        cylinder(h = H_BODY, d=D_SWITCH);
                    }            
                }
            }
        }
    }
}

module mainRod() {
	color("yellow") {
        translate([X_ROD, Y_ROD, M_0 - 10]) {
    		cylinder(d=D_ROD, h=H_FAR);
            translate([0, 0, -5])
                cylinder(h=5, d1=0, d2=D_ROD);
        }
        translate([-X_ROD, Y_ROD, M_0 - 10]) {
            cylinder(d=D_ROD, h=H_FAR);
            translate([0, 0, -5])
                cylinder(h=5, d1=0, d2=D_ROD);
        }
    }
}

module mainRodSupport(h) {
    translate([X_ROD, Y_ROD, 0]) {
        difference() {
            cylinder(d=D_ROD + 3, h=h);
            cylinder(d=D_ROD, h=h);
        }
    }
    translate([-X_ROD, Y_ROD, 0]) {
        difference() {
            cylinder(d=D_ROD + 3, h=h);
            cylinder(d=D_ROD, h=h);
        }
    }
}

module innerTube() {
	translate([0, 0, M_WAY_BACK]) cylinder(r=R_INNER, h=H_FAR);
}


module displayBolt() 
{
    // Pins are challenging to print small & accurate.
    // Trying holes for M2 bolts instead.
    translate([0, -DEPTH_DISPLAY_THREAD, 0]) {
        rotate([-90, 0, 0]) cylinder(r=R_DISPLAY_THREAD, h=20);
    }
}

function displayBoltX(vec) = vec * DISPLAY_MOUNT_W / 2;
function displayBoltZ(vec) = (DISPLAY_L - DISPLAY_MOUNT_L) / 2 + vec * DISPLAY_MOUNT_L;

module displayBolts()
{
    translate([DISPLAY_INNER_W, 0, DISPLAY_INNER_L])                            displayBolt();
    translate([DISPLAY_W - DISPLAY_INNER_W, 0, DISPLAY_INNER_L])                displayBolt();
    translate([DISPLAY_W - DISPLAY_INNER_W, 0, DISPLAY_L - DISPLAY_INNER_L])    displayBolt();
    translate([DISPLAY_INNER_W, 0, DISPLAY_L - DISPLAY_INNER_L])                displayBolt();
}


module display()
{
    EXTRA = 1;

    translate([-DISPLAY_W/2, Y_DISPLAY, M_DISPLAY]) {

	    translate([-EXTRA/2, 0, 0]) {
	        cube(size=[DISPLAY_W + EXTRA, 10, DISPLAY_L+1.0]);
	    }
	    displayBolts();
	    
	    translate([0, -1, 6]) {
	        cube(size=[DISPLAY_W, 1, DISPLAY_L - 12]);
	    }
	}
    translate([0, Y_DISPLAY, M_DISPLAY]) {
        X_CABLE = 12;
        Y_CABLE = 2;
        Z_CABLE = 3 + 1;    // cheat so we don't get a super thin piece in the locking ring.
        translate([-X_CABLE/2, -Y_CABLE, -Z_CABLE]) {
            cube(size=[X_CABLE, 10, Z_CABLE + 7]);
        }
    }
}

module aftLock()
{
    difference() {
        union() {
            translate([0, 0, M_AFT_STOP]) {
                color("red") {
                    cylinder(d=D_AFT_RING, h = H_AFT_RING);
                }
                translate([0, 0, H_AFT_RING]) {
                    cylinder(d=D_INNER, h = H_AFT_LIP);
                }
            }
        }
        battery();
    }
}

module aftPowerHoles()
{
	translate([D_AFT/2 - 1.8, 0, M_WAY_BACK]) cylinder(h=H_FAR, d=2.5);
	translate([-D_AFT/2 + 1.8, 0, M_WAY_BACK]) cylinder(h=H_FAR, d=2.5);
}

 module batteryHolder()
 {
 	H = M_AFT_STOP - M_BATTERY_BACK;

    translate([0, 0, M_BATTERY_BACK]) {
	    difference() {
        	cylinder(h=H, d=D_AFT);

	    	translate([0, 0, H - 4]) {
	        	//rotate([180, 0, 0]) vent1(3, H-8, 6, 20);
                rotate([180, 0, 1]) vent1(3, H-8, 8, 20);
        	}
        }
    } 	
 }

module speakerHolder()
{
    DELTA = 0.8;
    translate([0, 0, M_SPEAKER_BACK]) {
        difference() 
        {
            cylinder(h=H_SPEAKER_HOLDER, d=D_AFT);
            translate([-X_SPEAKER/2, -Y_SPEAKER/2, -EPS]) {
                cube(size=[X_SPEAKER, Y_SPEAKER, H_SPEAKER + EPS]);
            }
            translate([-20, -Y_SPEAKER_INNER/2, -EPS]) {
                cube(size=[40, Y_SPEAKER_INNER, H_SPEAKER + EPS]);
            }
            // Sound trough.
            translate([-2, -9, -EPS]) {
                cube(size=[4, 18, 20]);	//H_SPEAKER + 1]);
            }
        }
    }     
}


module speakerBolt()
{
    cylinder(h=10, r=R_DISPLAY_THREAD);
    cylinder(h=2, r=R_DISPLAY_THREAD_HEAD);
}

module speakerBolts()
{
    translate([0, 0, M_SPEAKER_BACK]) {
        translate([ 4.5,  9.9, -EPS]) speakerBolt();
        translate([-4.5,  9.9, -EPS]) speakerBolt();
        translate([ 4.5, -9.9, -EPS]) speakerBolt();
        translate([-4.5, -9.9, -EPS]) speakerBolt();
    }
}

// USB in front
module mc(cutoutLow=false)
{
    color("blue") {
        // lower
        translate([-W_MC/2, 0, 0])
            cube(size=[W_MC, 5.5, 61.5]);
        // Under space
        SOLDER = 2.2;
        UNDER = cutoutLow ? 20 : 3;
        translate([-W_MC/2 + SOLDER, -UNDER, 0])
            cube(size=[W_MC - SOLDER*2, UNDER, 61.5]);
        // sd
        translate([-6, 0, -3.6])
            cube(size=[12, 5.5, 3.6]);
        // shield
        translate([-W_MC/2, 5.5, 14])
            cube(size=[W_MC, H_MC - 5.5, 53]);
    }
}

module usbPort()
{
    TZ = 5;
    TBOTTOM = 3;
    TX = 3;
    Z = M_SWITCH_CENTER - 15;
    translate([0, R_INNER - DY_USB - TBOTTOM, Z]) {
        difference() {
            translate([-DX_USB/2 - TX, 0, 0])
                cube(size=[DX_USB + TX*2, DY_USB, TZ]);
            translate([-DX_USB_INNER/2, -EPS, -EPS])
                cube(size=[DX_USB_INNER, 100, TZ+EPS2]);
            translate([-DX_USB/2, TBOTTOM, TZ/2 - SLOT_USB/2])
                cube(size=[DX_USB, 100, SLOT_USB]);
        }
    }
    hull() {
        RAILX = (DX_USB + TX*2 - DX_USB_INNER) / 2;
        translate([0, 0, Z]) railCube();
        translate([DX_USB/2 + TX - RAILX, 3, Z])
            cube(size=[RAILX, 1, TZ]);        
    }
    mirror([1,0,0]) hull() {
        RAILX = (DX_USB + TX*2 - DX_USB_INNER) / 2;
        translate([0, 0, Z]) railCube();
        translate([DX_USB/2 + TX - RAILX, 3, Z])
            cube(size=[RAILX, 1, TZ]);        
    }
}

BODY_Z = M_EMITTER_BASE - M_AFT_STOP_FRONT - H_BUTTRESS;
T = 4;
DISPLAY_TROUGH = 13;

module arches()
{
    STEPS = 18;
    for(i=[0:STEPS-1]) {
        translate([0, 0, buttressZ(i)])
            buttress(bridge=DZ_BUTTRESS, rail=true);
    }
}

module Zone0()
{
    intersection() {
       translate([0, 0, M_ZONE_0]) cylinder(h=M_ZONE_1 - M_ZONE_0, d=D_INNER);
        union() {
            difference() {
                arches();

                // Display cut outs
                display();
                translate([-DISPLAY_TROUGH/2, FLOOR_Y, M_DISPLAY]) 
                    cube(size=[DISPLAY_TROUGH, 100, M_PORT_CENTER - M_ZONE_0 - D_PORT/2 - M_DISPLAY]);
                translate([0, 0, M_DISPLAY + (DISPLAY_L - DISPLAY_PINS)/2]) {
                    cube(size=[DISPLAY_MOUNT_W/2 + 2, 100, DISPLAY_PINS]);
                }
                // Access to display wiring
                translate([0, -8, M_AFT_STOP_FRONT]) {
                    cube(size=[100, 100, H_BUTTRESS * 2 + DZ_BUTTRESS * 3]);
                }
            } 

            POWER_PAD_DX = 18;
            POWER_PAD_DY = 12;

            difference() {
                translate([-POWER_PAD_DX/2, Y_SWITCH - 5, M_PORT_CENTER - POWER_PAD_DY/2 ]) {
                    cube(size=[POWER_PAD_DX, 5, POWER_PAD_DY]);
                }
                translate([0, 0, M_PORT_CENTER]) rotate([-90, 0, 0]) cylinder(h=100, d=D_PORT);
            }

            // MC holder
            difference() {
                translate([-10, Y_FLATTEN, M_MC-6]) cube(size=[20, 7, 10]);
                translate([0, FLOOR_Y, M_MC]) mc();     
            }

            // Battery stop
            M_BAT = M_BATTERY_BACK + H_BATTERY + 2.5;    // space for padding
            BW = 6;
            BZ = 10;
            hull() {
                translate([-BW/2, Y_FLATTEN, M_BAT]) cube(size=[BW, 13, 1]);
                translate([-BW/4, Y_FLATTEN, M_BAT + BZ]) cube(size=[BW/2, 8, 1]);
            }

            
            difference() {
                PAD = 5;  
                union() {
                    hull() {
                        translate([3, 0, buttressZ(2)]) railCube();
                        translate([ displayBoltX(1) - PAD/2, Y_DISPLAY - 1, M_DISPLAY + displayBoltZ(1) - PAD/2 ])
                            cube(size=[PAD + 3, 1, PAD]);
                    }
                    mirror([1, 0, 0]) hull() {
                        translate([3, 0, buttressZ(2)]) railCube();
                        translate([ displayBoltX(1) - PAD/2, Y_DISPLAY - 1, M_DISPLAY + displayBoltZ(1) - PAD/2 ])
                            cube(size=[PAD + 3, 1, PAD]);
                    }
                }              
                display();
            }
        }
    }
}


// Crystal and Microcontroller

SPLIT_Y = -3;

module mcSection() {
    translate([-50, -R_INNER, M_ZONE_1]) {
        cube(size=[100, R_INNER + SPLIT_Y, M_ZONE_2 - M_ZONE_1]);
    }
}

module oneLockRail() {
    //translate([0, 2, 0]) 
    color("yellow") translate([13.5, SPLIT_Y-2, M_ZONE_1]) {
        difference() 
        {
            cube(size=[1, 4, M_ZONE_2 - M_ZONE_1]);
            for(i=[0:7]) {
                translate([0, -1, DZ_BUTTRESS*(i+1) + H_BUTTRESS*i]) {
                    cube(size=[2, 2, H_BUTTRESS]);
                }
            }
        }
    }
}

module lockRail() {
    oneLockRail();
    mirror([1, 0, 0]) oneLockRail();
}

module Zone1()
{
    intersection() {
        translate([0, 0, M_ZONE_1]) cylinder(h=M_ZONE_2 - M_ZONE_1, d=D_INNER);
        union() {
            difference() {
                union() {
                    arches();
                    translate([-20, -R_INNER, M_ZONE_1])
                        cube(size=[40, 5, M_ZONE_2 - M_ZONE_1]);
                }

                // MC cut out
                translate([-W_MC/2, FLOOR_Y + H_MC/2, M_MC]) 
                    cube(size=[W_MC, H_MC/2 + 2, Z_MC_35]);
                translate([0, FLOOR_Y, M_MC]) 
                    mc(true);
            }    
        }
    }
}

module Zone1Crystal()
{
    DOT = X_DOTSTAR + 4;
    intersection() {
        translate([0, 0, M_ZONE_1]) cylinder(h=M_ZONE_2 - M_ZONE_1, d=D_INNER);
        difference() {
            union() {
                for(i=[0:7]) {
                    translate([0, 0, M_ZONE_1 + DZ_BUTTRESS*(i+1) + H_BUTTRESS*i]) {
                        difference() {
                            cylinder(h=H_BUTTRESS, d=D_INNER);
                            //translate([0, 0, -EPS]) cylinder(h=H_BUTTRESS + EPS2, d=D_INNER_CORE);

                        }
                    }
                }
                translate([-DOT/2, Y_CRYSTAL-DOT/2, M_ZONE_1 + DZ_BUTTRESS - H_BUTTRESS])
                    cube(size=[DOT, DOT, H_BUTTRESS + EPS]);
            }
            translate([0, Y_CRYSTAL, M_ZONE_1 + H_BUTTRESS + DZ_BUTTRESS + EPS]) 
            {
                scale([W_CRYSTAL, H_CRYSTAL, 1])
                    cylinder(h=H_FAR, d=1);
                translate([0, -1, 0])
                    scale([1.5, 1, 1])
                        rotate([0, 0, 45])
                            cube(size=[20, 20, H_FAR]);
                translate([0, -Y_CRYSTAL + SPLIT_Y, 0])
                scale([2.7, 1, 1])
                    cylinder(h=H_FAR, d=9);
            }
            translate([-X_DOTSTAR/2, Y_CRYSTAL-X_DOTSTAR/2, M_ZONE_1])
                cube(size=[X_DOTSTAR, X_DOTSTAR, H_BUTTRESS + DZ_BUTTRESS + EPS2]);
        }
    }  
}


module Zone2()
{
    SWITCH_DX = 14;
    SWITCH_DZ = 15;

    intersection() {
        translate([0, 0, M_ZONE_2]) cylinder(h=M_ZONE_3 - M_ZONE_2, d=D_INNER);
        union() {
            difference() {
                arches();

                // Switch cut-out
                translate([0, 0,  M_SWITCH_CENTER - SWITCH_DZ]) cylinder(h=100, d=D_INNER_CORE);

            }    
            // Switch plate.
            PAD = 4;
            difference() {
                translate([-D_SWITCH/2 - PAD, Y_SWITCH-T, M_SWITCH_CENTER - D_SWITCH/2 - 3]) 
                    cube(size=[D_SWITCH + PAD * 2, T + 2, D_SWITCH + 6]);
                switch();
            }

            // Hardpoint; in case a rotation set needs to be inserted.
            PLATE = 12;
            translate([-PLATE/2, -R_INNER, M_SWITCH_CENTER - PLATE/2]) 
                cube(size=[PLATE, 4, PLATE]);
 
            usbPort();

            translate([13, 4, M_ZONE_2 + H_BUTTRESS*3 + DZ_BUTTRESS*3]) {
                cube(size=[2, 100, DZ_BUTTRESS]);
            }
            mirror([1,0,0]) translate([13, 4, M_ZONE_2 + H_BUTTRESS*3 + DZ_BUTTRESS*3]) {
                cube(size=[2, 100, DZ_BUTTRESS]);
            }
        }
    }
}

//---------------------------//

// Speaker holder.
if (AFT_HOLDER) {
    difference() {
        speakerHolder();
        speakerBolts();
        aftPowerHoles();
    }
}

// Aft battery holder.
if (AFT) {
    difference() {
        batteryHolder();
        battery();
        mainRod();
        speakerBolts();
        aftPowerHoles();
    }
}

// Aft lock
if (MAIN_DISPLAY)
{
    difference() {
        aftLock();
        display();
        mainRod();
        aftPowerHoles();
        translate([-20, Y_FLATTEN-20, -20]) cube(size=[40, 20, 100]);
    }
}

if (EMITTER) {
    color("white") translate([0, 0, M_EMITTER]) emitter();
}


module mainBody() 
{
    if (MAIN_DISPLAY || MAIN_MC || MAIN_CRYSTAL || MAIN_EMITTER) {
        difference() {
            union() {
                if (MAIN_DISPLAY) Zone0();
                if (MAIN_CRYSTAL) {
                    difference() {
                        Zone1Crystal();
                        mcSection();
                    }
                    lockRail(); 
                }
                if (MAIN_MC) {
                    difference() {
                        intersection() {
                            mcSection();
                            Zone1();
                        }
                        lockRail();
                    }
                }
                if (MAIN_EMITTER) {
                   difference() {
                        translate([0, 0, M_EMITTER_BASE]) emitterBase();
                        translate([-20, Y_FLATTEN-20, M_EMITTER_BASE - 5]) cube(size=[40, 20, 20]);
                    }
                    Zone2();
                }
            }
            mainRod();
            translate([-20, Y_FLATTEN-20, M_AFT_STOP_FRONT]) cube(size=[40, 20, BODY_Z]);
        }
    }
}

mainBody();

//mainRod();
//translate([0, FLOOR_Y, M_MC]) mc();
//translate([0, 0, -20]) switch();
//battery();
//lockRail();
//crystal();
