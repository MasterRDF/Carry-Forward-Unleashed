MW2 guns fixes: an add-on to Carry-Forward-Unleashed's mw2_guns.dll, with changes not in that release yet
Made 2026-11-07 from mw2_guns build 21. For cod25-cod.exe sha256 starting b0b12b0e7ec25ce8 with Kronos v1.41.

WHAT IT DOES
Firing from a sprint with Stamin-Up's Guns Up augment made the view jitter (and before that dropped the camera) with the
MW2 guns and the BO6 guns. The Ztron guns' DG-2 had the same fault. It was fixed by taking a BO7 gun's animation package
and keeping only the DG-2's own firing, reload, melee, swap, aim and inspect animations.
This add-on does the same for the MW2 guns (the 78 of build 20) and for 56 BO6 guns:
- Each gun's animation packages take a same-class BO7 gun's (sat_ar_kiwi, sat_sm_bear, sat_lm_hades, sat_sn_aden,
  sat_dm_kara, sat_sh_akita, sat_pi_alcor, sat_la_fang; sat_ar_eagle if that one is not loaded). That brings its movement
  (walk, sprint, sprint fire).
- Each gun keeps its own firing, reload, melee, pull out and put away, aim and inspect animations, and its own reload
  and swap times.
- Not included: melee weapons, the BO6 special weapons (wonder weapons and the like), BO6's DG-2, and the MW3 guns.
The BO7 guns whose packages are taken are never changed.

BUILD 21g (2026-11-07, untested in game): KAR98K FIRING TOO FAST AND NO RELOAD MOTION AGAIN
With 21f the Kar98k was back to 21d's problem. Its round-by-round reload, other reload parts and the bolt's second timers
were among the timers 21f took from the BO7 gun. 21g keeps those as the gun's own too, and any timer the BO7 gun does not
have at all (blank) also stays the gun's own.

BUILD 21f (2026-11-07): BO6 GUNS, MW MARKSMAN RIFLES AND SNIPERS STILL SHAKING
After 21e, BO6 guns and the MW marksman rifles and snipers still shook when firing from a sprint.
- First-person values: the DG-2's fix also takes its rifle's view-motion values. Every BO7 gun, and the MW guns that no longer
  shake, have the same values there. The BO6 guns, the MW3 Kar98k and the Spear have their own. Each changed gun now takes
  the BO7 gun's (weapon def +0x508-0x5d8, block +0x5b04-0x5b9c, and block +0x5530-0x5594 where a BO6 gun has nothing set).
  Recoil, damage, ammo and handling stay the gun's own.
- Snipers, marksman rifles, shotguns and launchers now take the BO7 gun's timers like the rifles do (21d), apart from the ones
  that time their own firing, bolt, reload, pull out/put away and inspect (found in the game's code). 21d's Kar98k problem (fast
  shots, no reload motion) came from those. Melee weapons keep all their own timers.
- Every firing, bolt (rechamber) and reload animation of the gun is kept now: alternating shots, the high-priority bolt, fast,
  twin, tri and quad reloads, reload start/loop/end, checkpoint reloads. Before, the BO7 gun's replaced the gun's own wherever
  the BO7 gun had one.

BUILD 21e (2026-11-07): KAR98K AND SPEAR
- Snipers, marksman rifles, shotguns, launchers and melee kept their own timers again (21d's donor timers made the Kar98k fire
  too fast and lose its reload motion).
- The MW3 Spear is changed too; melee weapons take the BO7 knife (sat_me_knife).
- Once per launch, kronos\Logs\mw2_guns_weapon_dump.bin gets the weapon data of 14 weapons (read only, for the MW3 melee slot).

BUILD 21d (2026-11-07): THE GUN AND ARMS SHAKING WHEN FIRING FROM A SPRINT
With Guns Up, the gun and arms of MW2, MW3 and BO6 guns shook when firing from a sprint. BO7 guns did not.
- The MW3 guns of the Carry-Forward-Unleashed release get the same change now: 53 guns in their classes. Not included: melee
  weapons, the Ray Gun and the plasma gun. mw2_guns_fixes.ini mw3sprintfire=off leaves them alone.
- sprintfire=on now also takes the BO7 gun's timers, as the DG-2's fix does. Timers set how long each animation state lasts.
  The guns' own timers were driving the BO7 movement and sprint-fire motion they now play. Reloads and swaps of these guns now
  take as long as the BO7 gun of their class.
- sprintfire=owntimers keeps each gun's own timers (21c's behaviour).

BUILD 21c (2026-11-07): NO MORE CRASH WHEN A MATCH LOADS
The BO7 guns it borrows from are loaded with the front end and with each match, and freed when you switch between the lobby and
a match, while the MW2 and BO6 guns stay loaded. The game checks every loaded gun while it frees a zone. A gun still pointing at
a freed BO7 gun crashed it there (13:22, 13:49 and 15:30 on Nov 7).
Now every changed gun gets its own animations back right before any zone that can hold weapons is unloaded. The change is made
again once the unload is over, from the BO7 guns loaded then. Nothing is changed while an unload runs, and nothing at all until
the add-on watches unloads.
The Ztron guns mod watches the same game function. The add-on waits for its hook and runs in front of it, so both work, in
whichever order they load. Without Ztron it hooks the game's function directly. kronos\Logs\mw2_guns_fixes.log says which:
"zone unloads watched (...)", and "... packages given their own animations back before a zone unload" at each lobby/match
change.
Apart from that one unload hook it patches nothing. It only rewrites the changed guns' animation packages and (21f) their
first-person values in memory while the game runs. It changes no game, Kronos or mod file.

FILES
hid.dll                         Loader 2: loads mw2_guns\mw2_guns.dll as before, then mw2_guns\mw2_guns_fixes.dll if it is there.
mw2_guns\mw2_guns_fixes.dll     The add-on.
mw2_guns\mw2_guns_fixes.ini     sprintfire=on (or strict, owntimers, off), bo6sprintfire=on and mw3sprintfire=on (or off).
mw2_guns.ini (Carry-Forward-Unleashed's) must keep sprintfire=off, so that its own older sprint-fire code (build 20) does
not change the same packages.

SWITCHES (mw2_guns\mw2_guns_fixes.ini)
sprintfire=strict   the BO7 gun's timers (as "on" since 21d), and
                    nothing only the MW2/BO6 gun has. Try it if the view still jitters.
sprintfire=owntimers  every gun keeps its own timers (21c).
sprintfire=off      the add-on changes nothing.
bo6sprintfire=off   the BO6 guns are left alone.
mw3sprintfire=off   the MW3 guns are left alone.
To remove it: delete mw2_guns\mw2_guns_fixes.dll (loader 2 then loads only mw2_guns.dll). If a later release puts back its
own hid.dll, the add-on is simply not loaded.

LOG
kronos\Logs\mw2_guns_fixes.log: one "sprint fire:" line per gun (how many packages changed, how many of its own
animations it kept). The previous launch's is mw2_guns_fixes.prev.log.

SOURCE
mw2_guns.cpp built with /DMW2_GUNS_FIXES (build.bat), from the same source as mw2_guns build 21: section 5b and the end of
the file. zips\mw2_guns_source_build21.zip has it.

BUILD 22a: MUZZLE FLASHES (muzzleflash=on in mw2_guns_fixes.ini; off turns it off)
MW2 guns use the firing effects (muzzle flash, smoke) of the closest BO6 gun, MW3 guns those of the closest BO7 gun; Pack-a-Punched guns too.
The swap is undone before every zone unload and redone after, so no gun points at a freed BO7 gun.

BUILD 22b: PACK-A-PUNCH MUZZLE FLASHES (papmuzzleflash=on in mw2_guns_fixes.ini; off turns it off)
A Pack-a-Punched MW gun shows its donor's Pack-a-Punch flash (the pink one). BO6/BO7 guns get it from a VFX override entry keyed
on their Pack-a-Punch attachment; each MW gun gets a copy of its override list with the donor's entry added. It goes after the
gun's blueprint entries, where BO6/BO7 guns keep theirs, so a blueprint with its own flash keeps that flash.
Before every zone unload the added entry is switched off, and the next pass switches it on again.

BUILD 22c: PACK-A-PUNCH 4 EFFECTS (pap4effects=on in mw2_guns_fixes.ini; off turns it off; needs kronos\mods\mwcf_pap4)
At PaP 4 the game gives a BO7 gun its _pack4 attachment: purple impacts, a new tracer and, on some guns, a PaP 4 muzzle flash.
BO6, MW2 and MW3 guns have no _pack4. Each of 179 of them now gets <pack>4: a copy of its own _pack attachment (same stats) with
the impacts, tracer and PaP 4 effect group of a similar BO7 gun (output\pack4-01\pack4_donors.json), plus that gun's PaP 4 flash.
The mwcf_pap4 Kronos script swaps <pack>4 in at PaP 4, but only if a weapon built with it really has it.
The donor's effects are taken out before every zone unload and put back after.

BUILD 22d (2026-11-08): FINDING THE MOVEMENT-ONLY SWAP
Sprint fire's allow-list keeps only some of a gun's own animations; every other state with a BO7 animation plays the BO7 one on the
MW/BO6 gun. Reid saw arms and camera warp after firing, the magazine's rounds stack above the gun (FSS Hurricane, Static-HV), and
bolt and pump guns fire too fast; sprintfire=off fixed all three. 22d changes nothing by default; it logs and adds test switches:
- kronos\Logs\mw2_guns_fixes.log "sprint diag:" lines: per gun, the states whose own animation now plays the BO7 gun's; for the
  sprintdiag guns each of those animations and the timers that differ (byte offset: own/BO7).
- sprintdonorstates=  state ids/ranges (hex): only these, and states the gun has no animation for, take the BO7 gun's animation.
- sprintdonortimers=  timer byte ranges (hex, end not included): the gun's own timers apart from these.
- sprintview=off      no first-person values from the BO7 gun.
- sprintdiag=         guns logged in detail (default iw9_ar_mike4_mp,jup_jp37_dm_kappa98_mp).

BUILD 22e (2026-11-08): FIRST MOVEMENT-ONLY TEST
From the 22d log (names found by hashing: vm_p01_ar_mike4_<action>, sat_vm_ar_kiwi_<action>; FNV-1a 64, basis 0x47F5817A5EF961BA):
- Every changed gun replaces the same block of states 0x84-0x87, 0x96-0xa4, 0xf4-0xf8 (walk_loop, jog_loop, sprint_loop) and 0x118
  (super_sprint_loop). Per-gun extras outside it: 0x561 fire_settle, 0x1ad ads_down_settle, 0x562-0x564 retracted in/idle/out,
  0x52c/0x52e (next to mainToAlt/altToMain), 0x41, 0x1c3, 0x1fd, 0x207, 0x873-0x878, 0x1264 and others.
- The Kar98k took the BO7 rifle's 0 for its round-by-round reload timers (0x4ac-0x4dc) and 0x53c (350 ms, the bolt).
22e: a timer the BO7 gun leaves at 0 stays the gun's own (not in the sprint timers 0x4e0-0x53a).
Test ini: sprintdonorstates=0x5d-0x11e (only the movement block takes the BO7 gun's animation).

BUILD 22f (2026-11-08): MOVEMENT-ONLY SWAP BY DEFAULT
Reid's 22e test: animations all fixed with sprintdonorstates=0x5d-0x11e, and Guns Up still works. Timers were still off: the MCW's
inspect played slow and per-shell shotguns (Reclaimer 18, Marine SP showing a 26.1 s reload, Lockwood) reloaded slowly. Cause:
blank timers (0xffff, "the animation's own length") were filled from the BO7 gun; the MCW's inspect timer at 0x54c became the BO7
rifle's 6700 ms, and attachment packages, which are mostly blank, took the BO7 gun's reload timers (2816 changes on the Reclaimer).
22f defaults: only states 0x5d-0x11e take the BO7 gun's animation, and only timer bytes 0x4e0-0x53a its timers; every other
animation and timer stays the gun's own, blank ones too. sprintdonorstates / sprintdonortimers: empty = these defaults, "off" = 22c's
allow-list rules, a list replaces them. sprintfire=strict ignores the lists. The "sprint diag" lines are only written for sprintdiag guns.

BUILD 22g (2026-11-09): SPEED COLA ONLY SPEEDS UP THE MW GUNS' RELOADS
With Speed Cola an MW gun played its fast-magazine reload animation on top of the perk's speed-up; BO7 and BO6 guns only speed up.
The game asks exe +0x46ae5d0 whether a reload state should play its fast twin: yes when the gun's animation table has the twin and
a perk (specialty_fastreload = Speed Cola, specialty_fastreload_empty and three others) or something about the gun or the player
says so. BO7 guns' tables have no fast twins without a fast magazine; the MW guns' have them. 22g hooks that check: for an MW gun
the perks no longer count, so the twin is used only when the gun or an attachment asks for it. Every other gun is left to the game.
The speed-up is another function and is not touched. mw2_guns_fixes.ini perkfastreloads=on gives the old behaviour.
Log lines "speed cola: ...": how many MW guns are in the weapon table, and per pass how many fast reloads a perk alone asked for
(normal reload used) and how many the gun or an attachment asked for (kept).
