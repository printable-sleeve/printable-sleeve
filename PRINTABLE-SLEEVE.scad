include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* ============================================================================
   printable-sleeve v1.2 – Open Source Sexual Wellness Device
   ============================================================================
   License  : CC BY-SA 4.0
   Project  : https://github.com/printable-sleeve
   Author   : uknawn
   Printer  : Bambu Lab A1 Mini (settings below)
   Support  : https://buymeacoffee.com/uknawn

   WHAT IT IS:
     A parametric, vacuum-enabled masturbation sleeve for FDM 3D printing.
     Two materials. Five parts. No proprietary components required.
     Designed to be printed at home, privately, at minimal cost.

   PARTS:
     A) shell   (RENDER = "shell")   – PETG rigid outer housing
     B) cap     (RENDER = "cap")     – PETG screw cap with vacuum port
     C) plug    (RENDER = "plug")    – TPU vacuum seal plug
     D) inlay   (RENDER = "inlay")   – TPU sleeve, protrudes from front
     E) cushion (RENDER = "cushion") – TPU optional air cushion ring

   HOW TO CUSTOMISE:
     1. Measure your girth in mm, divide by 3.14 → enter as BORE_D
     2. Set SHRINK_COMP based on your TPU brand (start at 1.00, tune up)
     3. Render each part separately → export as STL → slice → print

   ASSEMBLY:
     1. Push inlay into shell from front until it seats on the rim
     2. Screw cap onto rear thread
     3. Push plug into cap vacuum port → vacuum builds up inside
     4. To remove inlay: pull straight out

   ============================================================================
   PRINT SETTINGS — BAMBU LAB A1 MINI
   ============================================================================

   PETG (shell + cap):
     Nozzle temperature     : 250–255°C
     Bed temperature        : 70°C, textured PEI plate + glue stick
     Layer height           : 0.20mm
     Wall lines             : 4 or more
     Infill density         : 40%
     AMS                    : compatible

   TPU Shore 95A (inlay + plug + cushion):
     Nozzle temperature     : 230–235°C
     Bed temperature        : 35–45°C, smooth PEI plate
     Layer height           : 0.15mm  (smoother inner surface)
     Wall lines             : 2
     Infill density         : 10% gyroid
     AMS Lite               : DO NOT USE — feed from external spool only
                              TPU jams the AMS Lite hub reliably

   FILAMENT PROFILE (left sidebar → filament → pencil icon):
     Retraction length      : 0 mm  ← CRITICAL — TPU strings with retraction
     Flow rate              : 95%   ← compensates TPU over-extrusion
     Max volumetric speed   : 2.0 mm³/s  ← prevents pressure spikes

   PROCESS PROFILE (right sidebar → Process):
     Seam position          : Nearest
     Wall order             : outer/inner
     Avoid crossing walls   : ON  ← CRITICAL — prevents stringing
     Outer wall speed       : 15 mm/s
     Inner wall speed       : 20 mm/s
     Surface speed          : 15 mm/s
     Reduce infill retract  : ON

   PRINTER SETTINGS (printer profile → Extruder tab):
     Retraction length      : 0 mm
     Z-hop on retract       : 0.2 mm
     Retraction speed       : 15 mm/s

   AIR CUSHION (RENDER = "cushion") — special settings:
     Infill density         : 0%  ← hollow = the function
     Top/Bottom layers      : 4   ← airtight seal

   PRINT ORIENTATION:
     Shell   → upright, open end facing up (no supports needed)
     Cap     → flat side on bed, threads face up (no supports needed)
     Plug    → grip head on bed, pin faces up (no supports needed)
     Inlay   → insertion end on bed (z=0 down), opening faces up (no supports)

   POST-PROCESSING (optional but recommended):
     Sand inner bore of inlay: 400 → 800 → 1200 grit wet/dry paper
     Takes 2–3 minutes. Removes seam ridge and any surface artifacts.

   ============================================================================
   HYGIENE & SAFETY
   ============================================================================
     - ALWAYS use a condom + water-based lubricant
     - DO NOT use silicone lubricant — it degrades TPU
     - Remove inlay after use, rinse with warm soapy water, dry completely
     - Replace inlay if surface shows cracks or permanent deformation
     - PETG shell: wipe clean with damp cloth, do not submerge

   ============================================================================
   TROUBLESHOOTING
   ============================================================================
     Inlay too loose in shell  → increase SHRINK_COMP by 0.005
     Inlay won't fit in shell  → decrease SHRINK_COMP by 0.005
     Stringing inside bore     → confirm: retraction OFF, crossing walls OFF
     Surface bumps inside      → reduce flow rate to 92%, speed to 12 mm/s
     Vacuum won't hold         → push plug in further, tighten cap

   REQUIRED LIBRARY — BOSL2:
     Install: https://github.com/BelfrySCAD/BOSL2
     Download ZIP → unpack → rename folder to BOSL2 → copy to:
       Windows : Documents/OpenSCAD/libraries/
       Linux   : ~/.local/share/OpenSCAD/libraries/
       Mac     : ~/Documents/OpenSCAD/libraries/
   ============================================================================ */


// ============================================================================
//  RENDER CONTROL
// ============================================================================

RENDER = "all";
// Which part to render and export as STL:
//   "shell"   → PETG outer housing
//   "cap"     → PETG screw cap
//   "plug"    → TPU vacuum plug
//   "inlay"   → TPU sleeve (main part — print this first)
//   "cushion" → TPU air cushion ring (optional, insert before inlay)
//   "all"     → all parts laid out on print bed (preview only)


// ============================================================================
//  USER PARAMETERS — edit these to customise for your body
// ============================================================================

BORE_D = 39.5;
// Inner bore diameter [mm].
// How to measure: wrap a soft tape around your shaft, note girth in mm,
// divide by 3.14 → that is your diameter.
// Example: 124mm girth ÷ 3.14 = 39.5mm
// Tip: match your measurement exactly — TPU wall gives ~2mm of flex.

SHELL_LENGTH = 100.0;
// Total shell length [mm].
// Recommended values:
//   80mm  → compact, discreet
//   100mm → standard (recommended)
//   120mm → extended

SHRINK_COMP = 1.00;
// TPU shrinkage compensation factor.
// TPU shrinks slightly when cooling. This factor scales outer dimensions up
// so the printed part ends up the right size.
//   1.00 = no compensation (good starting point — tune from here)
//   1.01 = +1% (try if inlay is too loose in shell)
//   1.06 = +6% (high-shrink brands)
// Tune in steps of 0.005. Print the plug first as a test piece.

WALL_T = 5.5;
// Inlay wall thickness [mm].
// This single value controls:
//   - How thick the tube wall is
//   - The size of the rounded entry ring (LIP_R = WALL_T / 2)
//   - The inner bore diameter (BODY_ID = BODY_OD - 2 × WALL_T)
// Thicker = stiffer, more structure. Thinner = softer, more flex.
// Minimum safe value: 3.0mm (below this, texture may cut through wall)
// Recommended: 4.0–6.0mm for Shore 95A TPU

RESOLUTION = 64;
// Circle resolution ($fn). Higher = smoother curves, slower render.
//   32  = fast preview
//   64  = recommended (good quality, reasonable render time)
//   128 = high quality, slow


// ============================================================================
//  DERIVED GEOMETRY — do not edit below this line
// ============================================================================

$fn = RESOLUTION;

// Shell geometry
SHELL_BORE    = BORE_D + 2*2.2 + 0.4; // PETG inner bore = bore + 2×wall + clearance
SHELL_OD      = SHELL_BORE + 10.0;    // shell outer diameter (10mm wall)
THREAD_LENGTH = 22.0;                  // rear thread length [mm]
THREAD_PITCH  = 4.0;                   // thread pitch [mm/turn]

// Inlay geometry — all derived from BORE_D, WALL_T, SHRINK_COMP
INLAY_LENGTH  = 30.0;                  // total inlay length [mm]
INLAY_INSIDE  = 10.0;                  // mm inside shell bore (friction fit)
// INLAY_LENGTH - INLAY_INSIDE = 20mm protrudes from shell front

BODY_OD       = (SHELL_BORE - 0.2) * SHRINK_COMP;  // outer Ø (shrink-compensated)
BODY_ID       = BODY_OD - 2 * WALL_T;               // inner bore Ø
RING_R        = WALL_T / 2;                          // entry ring torus radius
RING_CENTER   = BODY_OD/2 - RING_R;                 // torus centre from axis

// Cushion geometry
CUSHION_OD    = SHELL_BORE - 0.4;     // fits inside shell bore
CUSHION_ID    = BORE_D + 0.3;         // open bore (same as inlay)
CUSHION_L     = 20.0;                  // cushion length [mm]


// ============================================================================
//  PART A — PETG SHELL
// ============================================================================
module shell() {
    difference() {
        union() {
            // Main body (unthreaded section)
            cylinder(h=SHELL_LENGTH - THREAD_LENGTH, d=SHELL_OD);
            // Rear thread (BOSL2 trapezoidal profile)
            translate([0, 0, SHELL_LENGTH - THREAD_LENGTH])
                threaded_rod(d=SHELL_OD, l=THREAD_LENGTH,
                             pitch=THREAD_PITCH, anchor=BOTTOM);
        }
        // Inner bore
        translate([0, 0, -0.1])
            cylinder(h=SHELL_LENGTH + 0.5, d=SHELL_BORE);
        // Front entry chamfer — eases inlay insertion
        translate([0, 0, -0.1])
            cylinder(h=6, d1=SHELL_BORE + 10, d2=SHELL_BORE);
        // Front outer chamfer — removes sharp front rim
        translate([0, 0, -0.1])
            cylinder(h=2, d1=SHELL_OD + 5, d2=SHELL_OD);
        // Rear outer chamfer — thread run-out
        translate([0, 0, SHELL_LENGTH - 1.5])
            cylinder(h=1.6, d1=SHELL_OD, d2=SHELL_OD + 4);
    }
}


// ============================================================================
//  PART B — PETG CAP
// ============================================================================
module cap() {
    cap_od = SHELL_OD + 15.0; // cap outer diameter — larger than shell for grip
    difference() {
        union() {
            cylinder(h=32, d=cap_od);
            // Grip ribs (8 evenly spaced)
            for (i = [0:7])
                rotate([0, 0, i*45])
                    translate([cap_od/2 - 1.5, 0, 4])
                        cylinder(h=20, d=4, $fn=16);
        }
        // Vacuum port (Ø7mm press-fit for plug)
        translate([0, 0, -0.1]) cylinder(h=37, d=7.0);
        // Internal thread — mates with shell rear thread
        translate([0, 0, 7.9])
            threaded_rod(d=SHELL_OD + 1.2, l=21.0, pitch=THREAD_PITCH,
                         internal=true, anchor=BOTTOM);
        // Thread lead-in chamfers
        translate([0, 0, 28])
            cylinder(h=4.5, d1=SHELL_OD + 1.2, d2=SHELL_OD + 8);
        translate([0, 0, 7.5])
            cylinder(h=0.8, d1=SHELL_OD + 5, d2=SHELL_OD + 1.2);
    }
}


// ============================================================================
//  PART C — TPU VACUUM PLUG
// ============================================================================
module plug() {
    pin_d = (7.0 - 0.2) * SHRINK_COMP; // press-fit pin (shrink-compensated)
    union() {
        // Grip head with anti-slip notches
        difference() {
            cylinder(h=4.5, d=17, $fn=32);
            for (i = [0:7])
                rotate([0, 0, i*45])
                    translate([7, 0, -0.1])
                        cylinder(h=4.8, d=3, $fn=16);
        }
        // Tapered seal pin — tighter the deeper it goes
        translate([0, 0, 4.4])
            cylinder(h=15, d1=pin_d, d2=pin_d - 0.7, $fn=32);
    }
}


// ============================================================================
//  PART D — TPU INLAY
// ============================================================================
//
//  GEOMETRY:
//    z = 0 .. INLAY_INSIDE  → sits inside shell bore (friction fit)
//    z = INLAY_INSIDE .. IL → protrudes from front (user-facing zone)
//
//  WALL CONCEPT:
//    WALL_T defines wall thickness throughout — top to bottom, uniform.
//    The entry ring at z=IL is a torus whose cross-section radius = WALL_T/2.
//    The torus centre sits on the wall midpoint → ring inner Ø = bore Ø,
//    ring outer Ø = cylinder Ø. No step, no gap. One continuous surface.
//
//  BORE:
//    Smooth and straight from z=0 to z=IL. No internal protrusions.
//    Seam artefacts are minimal at 15mm/s with retraction OFF.
//    Sand lightly (400→1200 grit) for best surface if needed.
//
module inlay() {
    union() {
        difference() {
            // Outer cylinder — uniform diameter, full length
            cylinder(h=INLAY_LENGTH, d=BODY_OD, $fn=64);

            // Inner bore — smooth, straight, no texture
            translate([0, 0, -0.1])
                cylinder(h=INLAY_LENGTH + 5, d=BODY_ID, $fn=64);

            // Bottom inner chamfer — softens inner edge at z=0
            // Prevents sharp rim that would be felt on first contact.
            translate([0, 0, -0.1])
                cylinder(h=2, d1=BODY_ID + 2, d2=BODY_ID);
        }

        // ── ENTRY RING ─────────────────────────────────────────────
        // Single torus at top of cylinder (z=INLAY_LENGTH).
        // Cross-section radius = WALL_T/2 → ring has same inner and
        // outer diameter as the cylinder below. Geometrically continuous.
        // Rounded profile = soft first contact at glans on entry.
        // Clipped to BODY_OD by intersection() → no outer protrusion.
        intersection() {
            translate([0, 0, INLAY_LENGTH])
                rotate_extrude($fn=64)
                    translate([RING_CENTER, 0])
                        circle(r=RING_R, $fn=64);
            cylinder(h=INLAY_LENGTH + RING_R + 1, d=BODY_OD, $fn=64);
        }
    }
}


// ============================================================================
//  PART E — TPU AIR CUSHION RING (optional)
// ============================================================================
//
//  PURPOSE:
//    Optional ring inserted into shell bore before the inlay.
//    Acts as a soft spring: compresses when inlay is pushed in,
//    springs back when pressure releases.
//    Use 0, 1 or 2 rings to tune resistance and rebound feel.
//
//  HOW IT WORKS:
//    The wall cavity traps air. Thin walls (1.2mm) compress easily.
//    Rounded inner bore edges → smooth contact at both ends.
//    Friction fit in shell bore — no snap, no adhesive needed.
//
//  PLACEMENT:
//    Push into shell bore first, before inserting inlay.
//    Remove with tweezers or a thin rod if needed.
//
//  PRINT SETTINGS (critical):
//    Infill: 0% — hollow space is what creates the spring effect
//    Top/Bottom layers: 4 — airtight seal required
//    Speed: 15mm/s
//
module cushion() {
    WALL     = 1.2;   // cushion wall thickness [mm]
    RND      = 2.0;   // bore edge rounding radius [mm]
    RING_OR  = 3.5;   // inner ring torus radius [mm]
    RING_OFF = 2.5;   // inner ring centre offset outside bore wall [mm]

    union() {
        difference() {
            // Outer shell
            cylinder(h=CUSHION_L, d=CUSHION_OD, $fn=64);
            // Open bore — all the way through
            translate([0, 0, -0.1])
                cylinder(h=CUSHION_L + 0.2, d=CUSHION_ID, $fn=64);
            // Bore edge rounding (bottom) — no sharp inner rim
            translate([0, 0, RND])
                rotate_extrude($fn=64)
                    translate([CUSHION_ID/2, 0])
                        circle(r=RND, $fn=40);
            // Bore edge rounding (top)
            translate([0, 0, CUSHION_L - RND])
                rotate_extrude($fn=64)
                    translate([CUSHION_ID/2, 0])
                        circle(r=RND, $fn=40);
            // Outer chamfers — no sharp outside edges
            translate([0, 0, -0.1])
                cylinder(h=1.5, d1=CUSHION_OD - 3, d2=CUSHION_OD, $fn=64);
            translate([0, 0, CUSHION_L - 1.4])
                cylinder(h=1.5, d1=CUSHION_OD, d2=CUSHION_OD - 3, $fn=64);
        }
        // Inner rings — at rounding positions, clipped to outer wall
        for (rz = [RND, CUSHION_L - RND])
            intersection() {
                translate([0, 0, rz])
                    rotate_extrude($fn=64)
                        translate([CUSHION_ID/2 + RING_OFF, 0])
                            circle(r=RING_OR, $fn=48);
                cylinder(h=CUSHION_L, d=CUSHION_OD, $fn=64);
            }
    }
}


// ============================================================================
//  OUTPUT — PRINT BED LAYOUT
// ============================================================================

_gap = SHELL_OD + 20; // spacing between parts in "all" mode

if      (RENDER == "shell")   { shell(); }
else if (RENDER == "cap")     { cap(); }
else if (RENDER == "plug")    { plug(); }
else if (RENDER == "inlay")   { inlay(); }
else if (RENDER == "cushion") { cushion(); }
else {
    color("ivory")     shell();
    color("royalblue") translate([_gap, 0, 0])    cap();
    color("peachpuff") translate([0, _gap, 0])     inlay();
    color("tomato")    translate([_gap, _gap, 0])  plug();
    color("lightblue") translate([0, _gap*2, 0])   cushion();
}
