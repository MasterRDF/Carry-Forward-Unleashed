MW2 guns: Modern Warfare II weapons in Kronos's BO6 loadouts, gunsmith and Zombies builds
For cod25-cod.exe sha256 starting b0b12b0e7ec25ce8, run with Kronos's own files (made against Kronos v1.41).
mw2_guns.dll is build 28, hid.dll is loader 1, from 2026-11-08. Made from the MW-Carry-Forward-0.7.0-test package.

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
                           Lockwood 300's attachment animation packages alone (see BUILD 11). sprintfire=states or
                           =off: see BUILD 20.
kronos\settings.json       server.disableGsc must stay false, or the scripts do not load.
To remove the mod, delete hid.dll and the mw2_guns folder.

LOGS
kronos\Logs\mw2_guns.log: which Kronos files were changed and read ("Kronos reads the changed copy of ..."), the
compile, the weapon list change, and for each gun with borrowed effects whether they were applied. The previous
launch's log is mw2_guns.prev.log. kronos\Logs\mw2_guns_loader.log shows when hid.dll loaded the DLL.
mw2_guns\cache\kronos\custom_scripts\compiled\*.compile.txt has acts.exe's output.

BUILD 21: STARTUP CHECK
Build 20 with one change. The menu changes are kept on only when Kronos's menu script reports in within two minutes.
On some PCs Kronos writes its "requirexhash hook ok" line only during map loading, later than that, so the menus
turned off. This mod's own gunsmith line ("mw2 guns gunsmith: hidden categories watched for MW2 guns"), written from
inside the changed copy, now counts as well. The two-minute check and what happens when it fails are unchanged.

BUILD 20: PACK-A-PUNCH DAMAGE, AND FIRING WHILE SPRINTING
Build 18's Pack-a-Punch works; the tiers felt too weak, and firing from a sprint with Stamin-Up's augment dropped the
camera under the map with every MW2 gun.
- Pack-a-Punch damage. The game's damage step multiplies a packed gun's damage by its tier's multiplier: the gun's own
  per-tier value, or the mode's (2, 2.5, 3, 4). The MW2 guns have no values of their own. In Zombies, this mod's copy of
  zm_bo6_builds.gsc now wraps that step: a packed MW2 gun's damage is scaled by a same-class BO7 gun's tier multiplier
  over the one it got (assault rifles and battle rifles: sat_ar_kiwi; SMGs sat_sm_bear; LMGs sat_lm_hades; snipers
  sat_sn_aden; marksman sat_dm_kara; shotguns sat_sh_akita; pistols sat_pi_alcor; launchers sat_la_fang). Where those match,
  nothing changes. The first packed hit per gun and tier, for every gun, is written to poi_reg.log as
  "k1 mw2guns: zm: <gun> tier N hit <damage> (xM)", so MW2 and BO7 guns can be compared at the same tier (open the
  pause menu now and then to have them written).
- Firing while sprinting. Stamin-Up's augment lets you fire from a sprint; the game then plays the gun's sprint-fire
  animation states and their timers. The MW2 guns' animation packages predate sprint fire: they number the states the old
  way and leave the sprint-fire states and timers empty, which is what dropped the camera (the Ztron guns' DG-2 had the
  same fault). Each MW2 gun's packages now get the missing sprint-fire states, played with the gun's own walk and sprint
  motions (it is held as when walking while it fires from a sprint), and the timers they leave blank from a BO7 gun of the
  same class. kronos\Logs\mw2_guns.log lines start "sprint fire:". mw2_guns.ini: sprintfire=states adds the states
  but leaves the timers, sprintfire=off changes nothing.
Not yet tried in the game.

BUILD 19: A LOOK AT THE BUILD WEAPON BUTTON'S CODE (LOGS)
Build 18's log: the MW2 guns' loot items now count as owned ("loot 11313 owned true" for the Super Shotgun's gun), and
the gunsmith and BUILD WEAPON still cannot be used. The WEAPON PREVIEW menu disables the button through a button helper
that disables a button whose command it cannot run. Neither script is in the zones on disk, and this game's Lua has no
debug.getinfo, so build 18 could not reach their code. Build 19 logs ("k1 mw2guns: ..." in poi_reg.log) which debug
functions there are, and dumps as hex the WeaponPreview menu's functions, the menu builder's weaponpreview function, and
the command functions of each button disabled right after the BUILD WEAPON text is asked for, with that button's
fields. Logs only.

BUILD 18: PACK-A-PUNCH FOR THE MW2 GUNS
The Pack-a-Punch machine only takes guns on its allow-list, which the game builds from its Zombies weapon metadata
(entries that allow Pack-a-Punch). This game's Zombies lists hold only its own guns, and Kronos's zm_bo6_pap.gsc adds the
BO6 ones, so the MW2 guns were refused. They still carry their MW3 Zombies attachments: zm_<gun> and zm_<gun>_pack (for
the Lockwood 300, zm_sh_charlie725 and zm_sh_charlie725_pack). In Zombies, this mod's copy of zm_bo6_builds.gsc now
gives each of the 72 MW2 guns (melee weapons left out) a metadata entry that allows Pack-a-Punch, with its own
zm_<gun>_pack as the Pack-a-Punch attachment (also for the top tier), and keeps them on the allow-list (every 2
seconds, as the game can rebuild it). A gun the game already has an entry for keeps it. Packing then rebuilds the gun
with its Pack-a-Punch attachment and camo, as for the game's own guns. 67 guns have a Pack-a-Punch attachment; the
other 5 (iw9_ar_malima, iw9_sm_sdelta, iw9_sm_acharlie9, iw9_pi_mike2011, iw9_ar_golf3) get the camo and the level only.
There is only one Pack-a-Punch attachment per MW2 gun, so tiers 2 and 3 keep it and change the camo and level.
Not yet tried in the game.

BUILD 17: MW2 GUNS COUNT AS OWNED (GUNSMITH AND BUILD WEAPON)
Build 16's log: the BUILD WEAPON text is asked for while the WEAPON PREVIEW menu is built, by a menu script that is not in
the zones on disk, and the gunsmith's attachment data was never asked for an MW2 gun (in no saved log at all). The menus
decide whether a gun is unlocked by asking whether its loot item is owned; a locked gun gets no gunsmith and no BUILD
WEAPON, though it can still be equipped. The MW2 guns' loot items and their blueprints' are not in this game's inventory.
- Kronos's own two ownership hooks (in the menu script copy this mod already makes) now ask this mod first: the 78 MW2
  guns' loot items and the loot items of their blueprints (as the armory lists them) count as owned. An MW2 gun that has
  no weapon data of its own counts as unlocked.
- Logs now go through the game's DebugPrint: poi_reg.log lines "k1 mw2guns: ...". Kronos's own log line keeps only the
  last 10 lines between reads, which lost most of build 16's. "before: iw9_sh_charlie725: loot ... owned ..." is the
  game's answer before the change; "N MW2 guns' loot items count as owned" the change. If the WEAPON PREVIEW still asks
  for the BUILD WEAPON text, the calling functions' values and their compiled code ("dump"/"hex" lines) are logged once,
  to be read offline.

BUILD 16: WHY BUILD WEAPON IS GREYED OUT (LOGS)
Build 15 ran: the game's equip now puts the barrel with the DOOM look (bar_sh_xlong_p14/4) into the Super Shotgun's class, and
the DOOM animations' attachment and the 12 gauge shells go into empty slots. The BUILD WEAPON button on its WEAPON PREVIEW
screen is still greyed out and its attachments cannot be changed. Build 16 finds out why and tries one fix:
- An MW2 blueprint that the game's blueprint list marks locked, restricted or not owned is shown as unlocked (these
  blueprints cannot be earned in this game). Logged as "mw2 guns gunsmith: list entry marked locked, shown as unlocked".
- poi_reg.log lines starting "mw2 guns probe:" show where the game's code asks for the BUILD WEAPON text, with its call
  stack, the button calls that follow it, every field of the Super Shotgun's blueprint list entry (and two other
  Lockwood 300 entries to compare), and which lock or block flags the gunsmith's attachment data carries for each MW2 gun.
  These only log; nothing else is changed.
Open the Super Shotgun's WEAPON PREVIEW (where BUILD WEAPON is) and its gunsmith once, then send poi_reg.log.

BUILD 15: THE SUPER SHOTGUN'S SHORT DOOM BARREL AND DOOM ANIMATIONS
Build 14 got the DOOM barrel into the class, and the gun still had the long barrels everywhere. The cause is in the
carry-forward data: the DOOM barrel (bar_sh_xlong_p14_doom) has no looks of its own (its variant list is empty), so "DOOM
barrel, variant 4", which the blueprint asks for, is built with the plain extra long barrel's model. Only the blueprint's own
preview shows the short barrel, because it takes the look from the blueprint itself. The short DOOM barrel
(bar_sh_short_p14_charlie725_v10) is variant 4 of the plain extra long barrel, bar_sh_xlong_p14. The DOOM barrel also brings in a
hidden attachment, charlie725_doom_blueprint_tuning, and that is what switches the gun to its DOOM animations (the DOOM
animation package matches it in the laser slot).
So the Super Shotgun now gets bar_sh_xlong_p14 at variant 4 in place of the DOOM barrel, plus charlie725_doom_blueprint_tuning:
- in the build the game equips (the class, so the Weapons tab and the firing range), with build 14's empty-slot fill for any
  part the game leaves out;
- in the blueprint list the armory reads (its preview and its BUILD WEAPON button), barrel only;
- in Kronos's hand-off to the match and in Zombies builds, including ones saved with the DOOM barrel before this build. A
  Zombies build the game refuses with the tuning attachment is built without it, so it keeps its other parts.
Custom builds made from the blueprint (the barrel keeps its DOOM look) get the tuning attachment too. poi_reg.log lines
starting "mw2 guns doom:" show the parts the gun was equipped with; "mw2 guns class:" lines show which slot each part went
into. Equip the Super Shotgun again after installing. Not yet tried in the game.

BUILD 14: THE SUPER SHOTGUN'S PARTS KEPT IN THE CLASS
Build 13's log showed where the parts go missing: the game's equip writes a build's parts into the class one slot at a time and
simply leaves out the ones it has no slot for. For the Super Shotgun it set the receiver, choke, tactical guard, heavy trigger
and no-stock, and never the DOOM barrel or the 12 gauge shells. The class is what the Weapons tab and the firing range build the
gun from, so they had the long barrels; the validity check build 13 added never fired (the game never marked it invalid).
Build 14 watches the slots the game sets while an MW2 blueprint is equipped; afterwards each part of the build it left out goes
into a slot the game left empty, with the same slot call the game uses, and is read back. poi_reg.log lines starting
"mw2 guns class:" say what the game set and whether each added part stuck ("... gets bar_sh_xlong_p14_doom/4 in an empty slot:
set, the slot now holds ..."). Matches already get all seven parts through Kronos's handoff (build 13: "attachments 7").
Equip the Super Shotgun again after installing. Not yet tried in the game.

BUILD 13: THE GAME NO LONGER STRIPS THE SUPER SHOTGUN
Build 12's log showed the game's own equip already carries all seven Super Shotgun parts with their variants
(bar_sh_xlong_p14_doom/4, charlie725_choke01/1, guard_tactical_p14/3, trigger_heavy_p14/1, ammo_12g/15, stockno_sh_p14/3,
iw9_rec_charlie725/12), so there was nothing to fill; the parts were changed afterwards. The game checks every loadout weapon
(WEAPON 871e97b3cc3ed8b7) and, when that says invalid, strips the parts it lists as duplicate, excess or unsupported from the
class, and deletes such custom builds. The Super Shotgun has more parts than this game usually allows and a barrel this game
does not list for the gun, so it lost its DOOM barrel. Build 13:
- an MW2 gun's build counts as valid to that check, so the game keeps its parts; poi_reg.log says what the game objected to
  ("mw2 guns gunsmith: the game marked ...'s build invalid (...); kept as it is");
- Kronos hands the match scripts an MW2 blueprint's own parts with their variants (it did so only for custom builds); the
  tactical guard's variant 3 is what switches on the Super Shotgun's _v10_guardtac animations;
- each part the game sets in an MW2 gun's class is logged ("mw2 guns class: ... slot ... set to ...").
Equip the Super Shotgun again after installing. Not yet tried in the game.

BUILD 12: THE SUPER SHOTGUN'S PARTS IN THE CLASS
Build 11 ran in the firing range: Kronos's ingame_br loaded, the Super Shotgun's own animation packages filled in place
(_v10 149 animations, _v10_guardtac 111) and the gun's entries stayed on them, but the gun still had the long barrels and
no DOOM animations. The firing range runs no match scripts (Kronos links only mp_bo6_store.gsc there), so build 11's script
fix never ran; the gun was built from what the menus stored in the class, and for an MW2 blueprint that was no attachments.
Without the DOOM barrel the Super Shotgun never switches to its own package: the _v10 package (its DOOM animations) goes with
the barrel slot's DOOM barrel, and _v10_guardtac with the tactical guard on its variant 3 (seen in the weapon data).
Build 12: when an MW2 blueprint is equipped with no attachments, it takes the blueprint's own attachments (with their
variants) from the game's blueprint list, the one the armory shows, and puts them in the build as a modified blueprint, so
the game stores them in the class: the firing range, the Weapons tab and matches then build it with them, and Kronos hands
them to the match scripts. poi_reg.log lines starting "mw2 guns blueprint:" show what the build and the blueprint held and
whether it was stored ("... is stored with its N attachments as a modified blueprint"). Equip the Super Shotgun again after
installing, so it is stored. Not yet tried in the game.

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
  launches where Kronos's filter does not install and builds 19 and 20 (BUILD WEAPON code dump, Pack-a-Punch damage, sprint fire) have not been tried in the game yet (build 11's animation packages
  fill; builds 14 and 15 put the Super Shotgun's parts in its class).
- Checked offline against Kronos v1.41's own files: the edits give the package's files plus this mod's own parts
  (the menu script compiles in LuaJIT, Lua 5.1 and 5.4, and its gunsmith and blueprint parts were run against
  stand-ins for the game), acts.exe compiles both scripts (with this mod's own changes since build 11), the weapon list
  test is found at the same place the package changed, and the effects code was run on test copies of the effect data
  for each kind of gun. The game's asset lookup it uses for the effects has only been called this way by
  ztron_share.dll so far.
- From the package: the crossbow, the launchers and the melee weapons have not been tried in a match (projectiles,
  guidance, explosions, reloads, melee attacks and damage). Try the Crossbow, RPG-7, JOKR, RGL-80 and Combat Knife
  first: menu, gunsmith attachment, movement, ADS, firing, reload, sounds, muzzle flash and tracers, and a saved
  Zombies build.
- mp_bo6_loadout.gsc keeps the package's loadout trace: the first 40 loadout lines with an MW2 gun are saved to the
  "mw_carry_forward01" store.

BUILD 24: ZOMBIES BALANCE (balance=on in mw2_guns.ini; balance=off turns it off)
- MW2/MW3 guns get BO7 rarity damage (x1 grey up to x5, x6 once Pack-a-Punched) and Pack-a-Punch tiers (x2 x4 x8 x12).
- Headshot multipliers match the BO7 average for each class; body damage is trimmed toward BO7 class averages
  (about 25% for ARs, SMGs and shotguns, 19% for LMGs, 30-34% for pistols, about 60% for snipers; marksman rifles unchanged).
- Lockwood 300 and Expedite 12: broken Pack-a-Punch range value fixed. BO6 guns: 4th Pack-a-Punch tier x10 -> x12.
- Zombies only: multiplayer and Warzone stats are not changed. Wonder weapons are not changed.

BUILD 25 (release 1.3)
- Balance pass reads memory with FastRead and takes the game lock per attachment (build 24 could stall a frame for ~0.9 s at zone loads).
- The old BUILD WEAPON menu probes are removed (they filled poi_reg.log).
- This DLL no longer runs its own sprint-fire code: mw2_guns_fixes.dll (loaded by hid.dll) does the sprint-fire fix.

BUILD 26 (release 1.3.1)
- Every memory read uses FastRead: the effects and Lockwood threads made hundreds of slow reads a second, some while holding the game lock (packet bursts, menu lag).
- effects=off by default: the MW2 muzzle-flash swap never applies on this game version (every gun logs "packages differ").

BUILD 27 (release 1.4)
- Zombie builds keep their camo: the served bo6_zombie_builds_post.lua now stores a custom gunsmith build's camo (and a blueprint's,
  when no camo was set on the gun) as <gun>@c, so Mystery Box and wall-buy guns come with it. Existing builds need to be set once more.

BUILD 28
- MW guns no longer vanish mid-session. Builds 6 to 27 turned the MW guns off two minutes into a launch when Kronos's menu
  script had not reported in to poi_reg.log, and after two such launches kept them off for good (mw2_guns\cache\menus_failed.txt).
  Kronos's Lua log drops lines (its L() keeps only the last 10 lines for Kronos to copy to the log), so on some PCs the check
  failed even though the menus were fine: the guns left the loadouts after the next menu reload, the box and the starting weapon
  stopped giving them, and loading in with an MW gun could crash. The check now only writes a note to mw2_guns.log, and a
  menus_failed.txt left by an older build is deleted at start.
- FastRead skips addresses below 64 KB, so the crash logger no longer writes caught faults as "CRASH ... mw2_guns.dll+138a6".
