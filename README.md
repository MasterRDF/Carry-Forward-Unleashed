# Carry-Forward-Unleashed

## Install instructions

Use stock Kronos v1.41 with the supported BO7 CL29269900 executable. The operator companion checks the exact supported files and refuses unsupported versions.

1. Go to the [latest release](https://github.com/MasterRDF/Carry-Forward-Unleashed/releases/latest) and download "Carry-Forward-Unleashed-main.zip".
2. Close BO7 and Kronos. **Updating from 1.6.x:** delete the old `kronos/mods/carry_forward_unleashed` folder first.
3. Extract the ZIP and move everything inside (`hid.dll` and the `kronos` folder) into your cod25 folder. Replace files if asked, including `hid.dll`.
4. Open the Kronos launcher, go to the Library tab and make sure **CFU Core** and the modules you want are switched on. In Kronos settings, turn on **Carry Forward**, and **BO6 Operators** for the MW operators. Then start the game.
5. In game, go to Zombies -> Weapons -> Mystery Box (or press Mystery Box Loadout on the Confirm Loadout screen before a match) and check the games you want the Mystery Box to give guns from. Press **Wall Buys** on the same screen to choose which game's guns the weapon walls sell.
6. In weapon selection, open **Favorites** to view your favorite guns. Press **1** or click **Toggle Favorite** to add or remove the selected weapon.

`INSTALL.txt` in the download has the same steps in plain text.

## Core and modules (1.7)

Version 1.7 splits the mod into Library entries you can switch separately:

| Library entry | What it adds |
| --- | --- |
| CFU Core | Required. Mystery Box and wall-buy game selection, the BO7 / BO6 / MWIII / MWII / Vanguard game buttons, Favorites, Weapon Renames, BO6 sorting |
| CFU - MWII Weapons | Modern Warfare II guns |
| CFU - MWIII Weapons | Modern Warfare III guns |
| CFU - MWII Operators | Modern Warfare II operators and skins |
| CFU - MWIII Operators | Modern Warfare III operators and skins |

A game whose module is off shows a gray, locked button with a padlock. Switching an MW weapons module off removes that game's guns from the weapon lists, the Mystery Box and wall buys. Switching an operators module off locks its operator button. Vanguard Weapons is a separate download. BO6 weapons and operators come from Kronos's own Carry Forward and BO6 Operators settings.

## Weapon names

Click the **Weapon Renames** radio beside **Toggle Favorite** to switch between the custom real firearm names and the original game names. Let the guns finish loading before using it, and avoid pressing it repeatedly while it applies.

## MWII and MWIII operators

Maverick's MW Operators work: 128 added operators and 661 skins. Menu previews may A-pose or reuse BO7 animations. Check `kronos/Logs/mwcf_operators.log` if operators do not load; the successful startup message includes `enabled 128 added operators / 661 added skins`.

## Turning it off

Switch "CFU Core" off in the Kronos launcher's Library (or just a module), then restart the game.
