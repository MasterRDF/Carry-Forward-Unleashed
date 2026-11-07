MW2 guns: Modern Warfare II weapons in Kronos's BO6 loadouts, gunsmith and Zombies builds
For cod25-cod.exe sha256 starting b0b12b0e7ec25ce8, run with Kronos's own files (made against Kronos v1.41).
mw2_guns.dll is build 11, hid.dll is loader 1, from 2026-11-05. Made from the MW-Carry-Forward-0.7.0-test package.

78 weapons: 15 assault rifles, 12 SMGs, 6 LMGs, 8 pistols, 6 shotguns, 7 sniper rifles, 13 marksman rifles (the battle
rifles and the crossbow are listed with them), 5 launchers and 6 melee weapons. Each keeps its own name, model, sounds,
damage and fire modes. The riot shield is left out, and MWIII weapons are not in this version.

INSTALL
1. Install or update Kronos and close the game.
2. Kronos's carry-forward must be on (the launcher setting, on by default), with its Warzone carry-forward content
   installed (global_stream_cfwd_mp and its eng_, ens_, srv_, techsets_ and ww_ files). The guns come from there; this
   zip does not contain any game files.
3. Extract this zip into the cod25 folder, the one holding cod25-cod.exe. It adds hid.dll there and a mw2_guns folder.
4. Start the game from the Kronos launcher as usual.
If you installed MW-Carry-Forward-0.7.0-test with "node setup.mjs install", restore that first with
"node setup.mjs restore" from its folder, or press "Update now" in the Kronos launcher and delete
kronos_pipeline_original.dll. Until then this mod stays off and shows a box saying so.

A MOD OF ITS OWN
Everything is in the mw2_guns folder except hid.dll, which has to sit next to the game. No file is shared with another
mod, and no other mod's file is changed. hid.dll is a small loader: the game loads it from its own folder, it passes
every call on to Windows' own hid.dll (controllers work as before), and it loads mw2_guns\mw2_guns.dll as soon as the
game starts.

KRONOS AND ITS UPDATES
This mod does not change any Kronos file, and it needs no installer or Node.js. Kronos can be updated with "Update now"
as usual, and the mod stays in place. The 0.7.0-test package changed Kronos's files; this DLL makes the same changes
while the game runs:
- Zombies weapon list. In Zombies, Kronos cuts the carry-forward weapons down to BO6 ones. The DLL finds that test in
  Kronos and lets the 78 MW2 guns through as well. Kronos's log (poi_reg.log) then says "carry-forward weapon list
  401 -> 153 names" (75 without this mod).
- Menus, gunsmith and Zombies builds. The changes the package made to four Kronos files (ui\LUIFPSCounter.lua,
  bo6_zombie_builds_post.lua, mp_bo6_loadout.gsc and zm_bo6_builds.gsc) are kept in the DLL as small find-and-replace
  edits, plus two of this mod's own in ui\LUIFPSCounter.lua for the gunsmith's Trigger Action slot (see BUILD 8). At each
  launch it makes changed copies of Kronos's files in mw2_guns\cache, compiles the two scripts with
  Kronos's own kronos\tools\acts.exe, and when Kronos opens one of those files it is given the copy. Kronos's own files
  are not touched. The first launch takes about 2 seconds for the compile; later launches reuse it.
  A newer Kronos keeps working as long as the lines these edits change are still in its files. If one is not, this
  part stays off (the guns are not offered) and kronos\Logs\mw2_guns.log says which file and which line.
- Firing effects. 64 of the guns use a BO6 gun's muzzle flash and tracer, as in the package: before swapping, the DLL
  checks that both guns' effect data is exactly what was tested, swaps with a compare-and-swap, and undoes a partial
  swap. It finds the guns with the game's own asset lookup a few times a second, so it hooks no game function.
  The Chimera and the Lachmann Shroud keep their own suppressed effects, and the crossbow, launchers and melee weapons
  keep all of theirs.
A game update (a new cod25-cod.exe) needs a new build of this mod, as it does of Kronos.

WITH OTHER MODS (ZTRON GUNS AND OTHERS)
This mod works on its own and next to other mods; it needs none of them, none of them need it, and it changes none of
their files. kronos\Logs\mw2_guns.log lists the other mods it finds at each start.
- The Ztron guns mod loads with pdh.dll, this one with hid.dll, so both can be installed. Its ztron_share.dll cuts
  Kronos's Zombies weapon list to BO6 guns only; this mod puts the MW2 guns back when the game registers that list, so
  they are in Zombies and the firing range (the firing range loads as the Zombies lobby). The log says "MW2 guns put back
  after another cut". The Zombies lobby then holds 78 more weapons than with the Ztron guns mod alone.
- The one game function this mod hooks is that list registration. If another mod has already put its own jump there,
  this mod goes in front of it, so both run. Anything else there is left alone, and the log says so.
- Kronos mods in kronos\mods (HUDs, Blood Burner and so on) are not touched; their Lua and scripts run as before.
- Another mod that changes Kronos's own files (ui\LUIFPSCounter.lua, bo6_zombie_builds_post.lua, mp_bo6_loadout.gsc,
  zm_bo6_builds.gsc) works as long as the lines this mod edits are still there; if not, this mod's menu part stays off.
- If Kronos's menu script does not start (for any reason, including another mod), this mod quietly switches its menu
  changes off for that start. Only after two such starts in a row does it stay off; any good start resets that.
- Another mod that also needs a hid.dll in the game folder cannot be installed together with this one.

SWITCHES
mw2_guns\mw2_guns.ini      mode=off turns the whole mod off. menus=off keeps Kronos's own files and lists (the guns
                           are not offered). effects=off leaves every gun's own effects alone. anims=off leaves the
                           Lockwood 300's attachment animation packages alone (see BUILD 11).
kronos\settings.json       server.disableGsc must stay false, or the scripts do not load.
To remove the mod, delete hid.dll and the mw2_guns folder.

LOGS
kronos\Logs\mw2_guns.log: which Kronos files were changed and read ("Kronos reads the changed copy of ..."), the
compile, the weapon list change, and for each gun with borrowed effects whether they were applied. The previous
launch's log is mw2_guns.prev.log. kronos\Logs\mw2_guns_loader.log shows when hid.dll loaded the DLL.
mw2_guns\cache\kronos\custom_scripts\compiled\*.compile.txt has acts.exe's output.

BUILD 11: THE SUPER SHOTGUN'S OWN ANIMATIONS AND PARTS
The Super Shotgun is the Lockwood 300's blueprint iw9_sh_charlie725_v10 (its number in the menus changes between launches:
12 one time, 13 the next). Its own first-person animations (the DOOM style reload, inspect and so on) and its two
animation packages come from Warzone's ingame_br, which Kronos loads with its carry-forward content ("ingame_br
force-loaded in request 9" in poi_reg.log), after the carry-forward weapons. Until then the game keeps empty slots for
those packages and fills them in place when ingame_br arrives; the gun uses them while the parts that call for them are
on. Two things kept them from playing:
- The menus store none of an MW2 blueprint's attachments, so the match built the Super Shotgun with only its look: the
  Lockwood 300's long barrels, and none of the parts that switch it to its own animations. Build 11 gives it its six
  attachments in the loadout script and in saved Zombies builds (the DOOM barrel, which on this blueprint is the short
  sawed-off pair, no stock, the tactical guard, choke, heavy trigger and 12 gauge shells), when it arrives with none.
  Which blueprint the number is comes from the game's own list, as the game's class code reads it. A build you make in
  the gunsmith keeps its own attachments.
- Build 10 pointed the gun's attachment entries at its normal package for good, so even then the Super Shotgun could not
  reach its own animations. Build 11 keeps each entry on its own package and only lends it the normal one while that
  package is still empty, so nothing ever plays an empty package; once ingame_br has filled it, the entry uses it.
kronos\Logs\mw2_guns.log lines starting "anims:" show which Lockwood 300 packages have animations ("animpackage_v10_guardtac
(n)"), how many attachment entries are on their own package, and whether the Super Shotgun's animations are loaded (yyy).
The Weapons tab in the menus still draws the class from what the menus stored, so it can still show the long barrels.
If ingame_br has not loaded when a match starts (Kronos re-adds it when the game empties it), the Super Shotgun moves like
the Lockwood 300 until it has. Not yet tried in the game.

BUILD 10
The Super Shotgun's attachments by its number (12) in the menu script; replaced by build 11, since the number changes.
Also removed then: build 9's change to the Dual Kodachis, and build 8's "trigger_action" gunsmith slot.

BUILD 9
A first try at the Super Shotgun's animations; replaced by build 10.

BUILD 8: THE TRIGGER SLOT
The in-game gunsmith hides each category the game marks hidden. For MW2 guns a trigger slot marked hidden is shown.
In the game the trigger slot was not marked hidden for any MW2 gun so far, so this only logs ("mw2 guns gunsmith:" in
poi_reg.log, with the categories the game hides for each gun).

FIXED IN BUILD 7
On launches where Kronos's own Zombies weapon filter does not install (poi_reg.log says "netconst register hook
FAILED", a Kronos start-up problem the Ztron guns readme also describes), the MW2 guns were not put back after the
Ztron guns mod's cut. An MW2 gun in the loadout then ended in DEV ERROR 0x05466E03 when loading the firing range (the
game's check that a carried weapon matches its slot in the weapon table). Build 7 puts all 78 back on such launches
too, and kronos\Logs\mw2_guns.log notes the Kronos problem. Matches on those launches can still fail in other ways
(see the Ztron guns readme); restart the game if one does.

BUILD 6
Works next to other mods without needing them: see WITH OTHER MODS.

FIXED IN BUILD 5
With the Ztron guns mod installed, the MW2 guns showed as the M15 in the firing range: its cut removed them from the
Zombies list. See WITH THE ZTRON GUNS MOD.

FIXED IN BUILD 4
Builds 1 to 3 broke Kronos's menus (no BO6 operators, missing BO6 weapon menus, no MW2 guns). When Kronos lists its Lua
folder it opens each file for its attributes and real path, and those opens were given this mod's copy, so Kronos filed
its menu script under the wrong name and the game never ran it. Build 4 only hands out the copy when Kronos reads a
file's contents. If Kronos's menu script ever does not start, the mod quietly switches its menu changes off for that
launch (Kronos's own menus come back after the next loading screen) and says so in kronos\Logs\mw2_guns.log; there is
no message box. The firing-effects check also runs less often and only re-checks guns whose data changed.

KNOWN LIMITS
- In the game so far: the menus work since build 4, and build 6 put the MW2 guns back after the Ztron guns mod's cut
  (logged on each Zombies lobby load), and build 8's gunsmith part ran (it found nothing to change). Build 7's fix for
  launches where Kronos's filter does not install and build 11's Super Shotgun work have not been tried in the game yet.
- Checked offline against Kronos v1.41's own files: the edits give the package's files plus this mod's own parts
  (the menu script compiles in LuaJIT, Lua 5.1 and 5.4, and its gunsmith and blueprint parts were run against
  stand-ins for the game), acts.exe compiles both scripts to exactly the package's compiled files, the weapon list
  test is found at the same place the package changed, and the effects code was run on test copies of the effect data
  for each kind of gun. The game's asset lookup it uses for the effects has only been called this way by
  ztron_share.dll so far.
- From the package: the crossbow, the launchers and the melee weapons have not been tried in a match (projectiles,
  guidance, explosions, reloads, melee attacks and damage). Try the Crossbow, RPG-7, JOKR, RGL-80 and Combat Knife
  first: menu, gunsmith attachment, movement, ADS, firing, reload, sounds, muzzle flash and tracers, and a saved
  Zombies build.
- mp_bo6_loadout.gsc keeps the package's loadout trace: the first 40 loadout lines with an MW2 gun are saved to the
  "mw_carry_forward01" store.
