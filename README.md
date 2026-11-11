# Carry-Forward-Unleashed

## Install instructions

Use stock Kronos v1.41 with the supported BO7 CL29269900 executable. The operator companion checks the exact supported files and refuses unsupported versions. If you used the standalone MW Operators mod, remove its `kronos/mods/mw_operators` folder and restore the original Kronos DLL from your backup or the Kronos updater before installing this integration.

1. Go to the [latest release](https://github.com/MasterRDF/Carry-Forward-Unleashed/releases/latest) and download "Carry-Forward-Unleashed-main.zip".
2. Close BO7 and Kronos. Extract the ZIP and move everything inside (`hid.dll` and the `kronos` folder) into your cod25 folder. Replace files if asked, including `hid.dll`.
3. Open the Kronos launcher, go to the Library tab and make sure "Carry Forward Unleashed" is switched on. Enable **BO6 Operators** in Kronos settings for the integrated operators, then start the game.
4. In game, go to Zombies -> Weapons -> Mystery Box (or press Mystery Box Loadout on the Confirm Loadout screen before a match) and check the games you want the Mystery Box to give guns from (Black Ops 7, Black Ops 6, Modern Warfare III, Modern Warfare II). All four are on by default.
5. On the same screen, press **Wall Buys** to switch which game's guns every weapon wall buy sells (Black Ops 7, Black Ops 6, Modern Warfare III, Modern Warfare II). Wall prices stay the same. Black Ops 7 by default.

6. In weapon selection, open **Favorites** to view your favorite guns. Press **1** or click **Toggle Favorite** to add or remove the selected weapon. A gold star appears beside its saved-build counter. Favorites are saved across matches and restarts.

## MWII and MWIII operators

Version 1.6 integrates Maverick's MW Operators work: 128 added operators and 661 skins under the same Carry Forward Unleashed Library entry. Choose an operator in the Operators menu; the integration has been confirmed working in Zombies.

Menu previews may A-pose or reuse BO7 animations. Those preview issues are still being worked on. Check `kronos/Logs/mwcf_operators.log` if operators do not load; the successful startup message includes `enabled 128 added operators / 661 added skins`.

## Turning it off

Switch "Carry Forward Unleashed" off in the Kronos launcher's Library, then restart the game. Switching it back on works the same way.
