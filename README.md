# PRINTABLE-SLEEVE

**Open Source Sexual Wellness Device — CC BY-SA 4.0**

A parametric, vacuum-enabled masturbation sleeve for FDM 3D printing.
Two materials. Five parts. No proprietary components. Fully open source.

> ⚠️ **Adult use only.** This project contains technical documentation
> for a personal wellness device intended for adults.

---

## What you need

| | |
|---|---|
| 3D printer | FDM — e.g. Bambu Lab A1 Mini |
| Material A | PETG (shell + cap) |
| Material B | TPU Shore 95A, body-safe, phthalate-free |
| Software | [OpenSCAD](https://openscad.org) + [BOSL2 library](https://github.com/BelfrySCAD/BOSL2) |
| Accessories | Water-based lubricant, condom (recommended) |

---

## How it works

The device consists of five printed parts:

```
A) shell   → PETG rigid housing
B) cap     → PETG screw cap with vacuum port
C) plug    → TPU vacuum seal
D) inlay   → TPU sleeve with soft entry ring
E) cushion → TPU air cushion ring (optional)
```

The inlay protrudes from the front of the shell. The cap screws onto the rear.
Inserting the plug creates a vacuum inside — which applies gentle pressure
from all sides and holds the inlay in place.

---

## Step 1 — Measure yourself

Wrap a soft tape around your shaft. Note the girth in mm.
Divide by 3.14 → that is your diameter. Enter it as `BORE_D`.

**Example:** 124 mm girth ÷ 3.14 = **39.5 mm**

> **Note:** `BORE_D` sets the housing size, not the inlay bore directly.  
> The actual bore inside the inlay is always approximately:  
> **BORE_D − (2 × WALL_T − 4.6)**  
> With defaults (WALL_T = 5.5): **BORE_D − 6.4 mm**  
> Example: BORE_D 39.5 → actual bore ≈ **33.1 mm**  
> TPU Shore 95A stretches to accommodate — this is intentional.  
> Reduce WALL_T for a looser fit, increase for a tighter one.

---

## Step 2 — Install BOSL2

1. [Download BOSL2](https://github.com/BelfrySCAD/BOSL2/archive/refs/heads/master.zip)
2. Unzip, rename the folder to `BOSL2`
3. Copy to your OpenSCAD libraries folder:
   - **Windows:** `Documents/OpenSCAD/libraries/`
   - **Linux:** `~/.local/share/OpenSCAD/libraries/`
   - **Mac:** `~/Documents/OpenSCAD/libraries/`

---

## Step 3 — Customise the file

Open `printable-sleeve.scad` in OpenSCAD. Change these values near the top:

```openscad
BORE_D      = 39.5;  // ← your diameter (girth ÷ 3.14)
SHRINK_COMP = 1.00;  // ← start here, tune if inlay is too loose or tight
WALL_T      = 5.5;   // ← wall thickness (increase for firmer feel)
SHELL_LENGTH = 100.0; // ← 80 / 100 / 120 mm
```

---

## Step 4 — Export each part as STL

Set `RENDER = "..."` → **Design → Export → Export as STL**

| RENDER | Material | Print time |
|---|---|---|
| `"shell"` | PETG | ~90 min |
| `"cap"` | PETG | ~60 min |
| `"plug"` | TPU | ~15 min |
| `"inlay"` | TPU | ~120 min |
| `"cushion"` | TPU | ~60 min (optional) |

Use `RENDER = "all"` to preview all parts together (not for printing).

---

## Step 5 — Print settings

### PETG — shell + cap

| Setting | Value |
|---|---|
| Nozzle | 250–255°C |
| Bed | 70°C, textured PEI + glue stick |
| Layer height | 0.20 mm |
| Walls | 4 |
| Infill | 40% |

### TPU Shore 95A — inlay + plug + cushion

**Filament profile** (filament → pencil icon → tabs):

| Setting | Tab | Value |
|---|---|---|
| Nozzle | Temperature | 230–235°C |
| Bed | Temperature | 35–45°C, smooth PEI |
| **Retraction length** | Retraction | **0 mm** ← critical |
| Flow rate | Advanced | 95% |
| Max volumetric speed | Advanced | 2.0 mm³/s |
| AMS Lite | — | **DO NOT USE** — external spool only |

**Process profile:**

| Setting | Location | Value |
|---|---|---|
| Layer height | Quality | 0.15 mm |
| Seam position | Quality | Nearest |
| Wall order | Quality → Advanced | outer/inner |
| **Avoid crossing walls** | Quality → Advanced | **ON** ← critical |
| Outer wall speed | Speed | 15 mm/s |
| Inner wall speed | Speed | 20 mm/s |
| Surface speed | Speed | 15 mm/s |

**Printer settings** (printer profile → Extruder tab):

| Setting | Value |
|---|---|
| Retraction length | 0 mm |
| Z-hop | 0.2 mm |
| Retraction/feed speed | 15 mm/s |

> **Air cushion only:** set infill to **0%** and top/bottom layers to **4**.

### Print orientation

| Part | Place on bed |
|---|---|
| Shell | upright, open end up |
| Cap | flat side down |
| Plug | grip head down, pin up |
| Inlay | insertion end down (z=0), opening up |

---

## Step 6 — Assembly

1. (Optional) Push air cushion ring into shell bore
2. Push inlay into shell from front until it seats on the rim
3. Screw cap onto rear thread
4. Push plug into cap vacuum port → vacuum builds up inside

---

## Step 7 — Use

- **Water-based lubricant only** — silicone lubricant degrades TPU
- Condom recommended (improves hygiene and feel)
- Apply lubricant to inlay bore before use

---

## Cleaning

1. Pull inlay straight out
2. Rinse with warm soapy water
3. Dry completely before reinserting
4. Shell: wipe with damp cloth — do not submerge
5. Replace inlay if you see cracks or permanent deformation

---

## Post-processing (optional)

Sand the inner bore of the inlay with wet/dry paper:
**400 grit → 800 grit → 1200 grit**
Takes 2–3 minutes. Removes seam ridges for a smoother surface.

---

## Parameters

| Parameter | Default | What it controls |
|---|---|---|
| `BORE_D` | 39.5 | Inner bore diameter [mm] — your girth ÷ 3.14 |
| `SHELL_LENGTH` | 100 | Shell length [mm] |
| `SHRINK_COMP` | 1.00 | TPU shrinkage factor — tune in 0.005 steps |
| `WALL_T` | 5.5 | Wall thickness [mm] — thicker = firmer |
| `RENDER` | "inlay" | Which part to export as STL |
| `RESOLUTION` | 64 | Render quality (64 recommended) |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Inlay too loose in shell | Increase `SHRINK_COMP` by 0.005 |
| Inlay won't fit in shell | Decrease `SHRINK_COMP` by 0.005 |
| Stringing inside bore | Retraction OFF + Avoid crossing walls ON |
| Surface bumps inside bore | Flow rate 92%, speed 12 mm/s |
| Vacuum won't hold | Push plug in further, tighten cap |

---

## Optional: Air Cushion Ring

Set `RENDER = "cushion"`. Insert into shell bore before the inlay.
Acts as a soft spring — compresses under load, rebounds when released.
Stack 1 or 2 rings to tune resistance.

**Critical:** infill **0%** — the hollow wall is the spring.

---

## License

**Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)**

Free to use, modify, and share — including commercially.
Attribution required. Derivatives must carry the same license.

Full text: https://creativecommons.org/licenses/by-sa/4.0/

---

## Contributing

Pull requests welcome. Please keep changes parametric and document
any new parameters in the file header and in this README.

---

*printable-sleeve — Open Source Sexual Wellness*
*https://github.com/printable-sleeve*
