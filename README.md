# CrosshairsPlus
<img width="1024" height="1024" alt="Crosshairplus Logo" src="https://github.com/user-attachments/assets/b40c1bfb-b8c6-4c52-ae2d-a6fd1aec6779" />

> Animated target crosshair overlay for **World of Warcraft 3.3.5a** (Warmane / WotLK private servers)
> Made by **xLT69x**
<img width="342" height="557" alt="CrosshairPlus Demo" src="https://github.com/user-attachments/assets/5b22441e-2e5c-4784-b206-0dfdd99dd299" />

---

## What It Does

CrosshairsPlus draws a glowing animated crosshair directly on your target's nameplate the moment you select them. The crosshair fades in when you gain a target and fades out when you lose one — keeping your screen clean while making sure you always know exactly what you're hitting.

- Crosshair circle snaps to the nameplate of your current target
- Four directional crosshair lines extend from the center
- Rotating arrow ring spins around the target
- All elements fade smoothly in and out
- Colors automatically match your target (class color or reaction color)
- Fully customizable via `/chp`

---

## Installation

1. Download **CrosshairsPlus.zip**
2. Extract it — you should get a **`CrosshairsPlus`** folder
3. Place that folder inside:
   ```
   World of Warcraft\Interface\AddOns\CrosshairsPlus\
   ```
   Make sure the path looks like this:
   ```
   AddOns\CrosshairsPlus\CrosshairsPlus.toc   ✔
   AddOns\CrosshairsPlus\CrosshairsPlus\...   ✘  (double folder — move it up one level)
   ```
4. Launch WoW, click **AddOns** on the character select screen, and make sure **CrosshairsPlus** is enabled (it will appear in blue)
5. Log in — you should see in chat:
   ```
   CrosshairsPlus loaded!  Type /chp to open settings.
   ```

---

## Slash Commands

| Command | Action |
|---|---|
| `/chp` | Open or close the settings panel |
| `/chp reset` | Reset all settings back to defaults |

---

## Settings Panel

Open with **`/chp`**. The panel can be dragged anywhere on screen.

### Circle Style
Cycles through 7 different crosshair circle designs.
Use `<` and `>` to switch between them live.

### Scale
Adjusts the overall size of the crosshair from **0.5×** (small) to **3.0×** (large).

### Opacity
Controls how visible the circle and arrows are. Lower values are more subtle; `1.0` is fully opaque.

### Lines

| Setting | Description |
|---|---|
| **Show lines** | Toggles the four directional crosshair lines on/off |
| **Line Opacity** | Independent opacity slider for the lines only — set to `0` to hide lines while keeping the circle |

### Arrows

| Setting | Description |
|---|---|
| **Show arrows** | Toggles the rotating arrow ring around the target |
| **Clockwise** | Changes rotation direction to clockwise (default is counter-clockwise) |
| **Rotation Speed** | How many seconds one full rotation takes — `1s` = very fast, `30s` = very slow |

### Color Mode

| Mode | How it works |
|---|---|
| **Class Color** | When targeting a **player**, the crosshair takes that player's class color (e.g. Paladin = pink, Mage = cyan, Warrior = tan). On NPCs it automatically falls back to reaction color. |
| **Reaction Color** | Always uses WoW's standard hostile/neutral/friendly colors — **red** for enemies, **yellow** for neutral, **green** for friendly. Works the same on both players and NPCs. |

---

## Compatibility

| Item | Details |
|---|---|
| WoW version | **3.3.5a** (Interface 30300) |
| Server | Tested on **Warmane** (Icecrown / Lordaeron) |
| Nameplate addons | Works alongside default nameplates, Aloft, TidyPlates, caelNameplates |
| Other crosshair addons | Do not run both CrosshairsPlus and the original Crosshairs at the same time |

---

## Bundled Libraries

CrosshairsPlus includes the following open-source libraries (no separate installation needed):

- **LibStub** — lightweight library versioning stub
- **CallbackHandler-1.0** — callback event system
- **LibNameplates-1.0** by Kader — nameplate detection and GUID tracking

---

## Credits

**Made by xLT69x**

---

## License

Free to use, modify, and redistribute for private server use.
