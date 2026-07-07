# CrosshairsPlus

![CrosshairsPlus Logo]
<img width="1024" height="1024" alt="603670895-b40c1bfb-b8c6-4c52-ae2d-a6fd1aec6779" src="https://github.com/user-attachments/assets/06bcfdb5-19f2-4bae-be95-729858b1c225" />


> Animated target crosshair overlay for **World of Warcraft 3.3.5a** (Warmane / WotLK private servers)
> **Made by xLT69x**

---
<img width="342" height="557" alt="603672348-5b22441e-2e5c-4784-b206-0dfdd99dd299" src="https://github.com/user-attachments/assets/2fda4d11-e7ad-40c7-ba12-94d81da28529" />

## What It Does

CrosshairsPlus draws a glowing animated crosshair directly on your current target's nameplate the moment you select them. The crosshair fades in when you gain a target and fades out the instant you lose one — keeping your screen clean while making sure you always know exactly what you're hitting.

**Features at a glance:**
- Crosshair circle snaps to the nameplate of your current target
- Four directional crosshair lines extend from the center
- Rotating arrow ring spins around the target
- All elements fade smoothly in and out on target gain/loss
- Colors automatically match your target (class color or reaction color)
- Fully customizable settings panel via `/chp`

---

## Installation

1. Download **CrosshairsPlus.zip**
2. Extract the zip — you should get a **`CrosshairsPlus`** folder
3. Place that folder inside your AddOns directory:
   ```
   World of Warcraft\Interface\AddOns\CrosshairsPlus\
   ```
   Verify the path looks like this:
   ```
   AddOns\CrosshairsPlus\CrosshairsPlus.toc   ✔
   AddOns\CrosshairsPlus\CrosshairsPlus\...   ✘  (double folder — move it up one level)
   ```
4. Launch WoW and click **AddOns** on the character select screen — **CrosshairsPlus** will appear in blue/cyan
5. Log in. You will see in chat:
   ```
   CrosshairsPlus loaded!  Type /chp to open settings.
   ```

---

## Slash Commands

| Command | Action |
|---|---|
| `/chp` | Open / close the settings panel |
| `/chp reset` | Reset all settings back to defaults |

---

## Settings Panel

Open with **`/chp`**. The panel can be dragged anywhere on screen.

---

### Circle Style
Choose from **6 visually distinct** crosshair circle designs.
Press `<` or `>` to cycle through them live while in-game.

| Style | Name |
|---|---|
| 1 | Original |
| 2 | Style 2 |
| 3 | Style 3 |
| 4 | Style 4 |
| 5 | Style 5 |
| 6 | Glow |

---

### Scale
Adjusts the overall size of the crosshair from **0.5×** (compact) to **3.0×** (large).

---

### Opacity
Controls how visible the crosshair circle and arrows are.
- `0.05` = barely visible
- `1.0` = fully opaque

---

### Lines

| Setting | Description |
|---|---|
| **Show Lines** | Toggles the four directional crosshair lines on/off |
| **Line Opacity** | Separate opacity slider for lines only — lets you dim lines independently of the circle |

---

### Arrows

| Setting | Description |
|---|---|
| **Show Arrows** | Toggles the rotating arrow ring around the target on/off |
| **Clockwise** | Switches rotation direction to clockwise (default is counter-clockwise) |
| **Rotation Speed** | How many seconds one full rotation takes — `1s` = very fast spin, `30s` = very slow drift |

---

### Color Mode

| Mode | How it works |
|---|---|
| **Class Color** | When targeting a **player**, the crosshair uses that player's class color — Paladin = pink, Mage = cyan, Warrior = tan, etc. On NPCs it automatically falls back to reaction color. |
| **Reaction Color** | Always uses WoW's standard hostile/neutral/friendly colors — **red** for enemies, **yellow** for neutral, **green** for friendly. Works the same on both players and NPCs. |

---

## Changelog

### v1.0 — Initial Release
- Crosshair circle with 6 distinct styles
- Smooth fade-in / fade-out on target change
- Four directional crosshair lines with independent opacity
- Rotating arrow ring with speed and direction control
- Class Color and Reaction Color modes
- Futuristic dark-HUD settings panel (`/chp`)
- Fixed: settings panel requiring two `/chp` commands to open
- Fixed: duplicate-looking circle styles removed; Glow style added

---

## Compatibility

| Item | Details |
|---|---|
| WoW version | **3.3.5a** (Interface 30300) |
| Server | Tested on **Warmane** (Icecrown / Lordaeron) |
| Nameplate addons | Compatible with default nameplates, Aloft, TidyPlates, caelNameplates |
| Other crosshair addons | Do **not** run CrosshairsPlus alongside the original Crosshairs addon at the same time |

---

## Bundled Libraries

CrosshairsPlus ships with the following open-source libraries — no separate installation needed:

| Library | Purpose |
|---|---|
| **LibStub** | Lightweight library versioning stub |
| **CallbackHandler-1.0** | Callback event system |
| **LibNameplates-1.0** | Nameplate detection and GUID tracking (by Kader) |

---

## Credits

**Made by xLT69x**

---

## License

Free to use, modify, and redistribute for private server use.
