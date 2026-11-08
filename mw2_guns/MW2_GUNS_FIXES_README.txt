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
