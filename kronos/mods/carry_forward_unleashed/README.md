# Carry Forward Unleashed (Kronos Library mod)

One folder, switched on and off in the Kronos launcher's Library (or Kronos's in-game mods menu).

- `hid.dll` (loader 4) stays in the cod25 folder. At game start it initializes `mwcf_operators.dll`, then loads the existing `mw2_guns.dll` and `mw2_guns_fixes.dll` from this folder. It loads none of them when the mod is switched off (`kronos\mods.json`). Restart the game after switching.
- `lua\`, `scripts\`, `images\`: loaded by Kronos (MW operators, Mystery Box Loadout, weapon categories, Pack-a-Punch, loadout guns in Zombies, gun icons).
- `mwcf_operators.dll`, `mwcf_operators.dat`, `operators.json`: the integrated operator companion, pinned native roster and source roster. Enable BO6 Operators in Kronos settings. Use stock Kronos v1.41 and the supported BO7 CL29269900 executable; unsupported hashes are refused. The on-disk Kronos DLL stays unchanged.
- `mw2_guns.ini`, `mw2_guns_fixes.ini`: settings. `cache\` is made by mw2_guns.dll.
- Logs: `kronos\Logs\mw2_guns_loader.log`, `mw2_guns.log`, `mw2_guns_fixes.log`, `mwcf_operators.log`.

Maverick's MW Operators integration adds 128 operators and 661 skins and has been confirmed working in Zombies. Menu A-poses/shared preview animations remain known issues. See `MW_OPERATORS_INTEGRATION.txt` for credits and setup details. Remove the separate `mw_operators` mod and restore stock Kronos before migrating from the standalone version.
