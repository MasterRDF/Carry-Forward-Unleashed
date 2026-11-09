# Carry Forward Unleashed (Kronos Library mod)

One folder, switched on and off in the Kronos launcher's Library (or Kronos's in-game mods menu).

- `hid.dll` (loader 3) stays in the cod25 folder. At game start it loads `mw2_guns.dll` and `mw2_guns_fixes.dll` from this folder, and nothing when the mod is switched off (`kronos\mods.json`). Restart the game after switching.
- `lua\`, `scripts\`, `images\`: loaded by Kronos (Mystery Box Loadout, weapon categories, Pack-a-Punch, loadout guns in Zombies, gun icons).
- `mw2_guns.ini`, `mw2_guns_fixes.ini`: settings. `cache\` is made by mw2_guns.dll.
- Logs: `kronos\Logs\mw2_guns_loader.log`, `mw2_guns.log`, `mw2_guns_fixes.log`.
