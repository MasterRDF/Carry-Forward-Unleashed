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
It hooks and patches nothing. It only rewrites the guns' animation packages in memory while the game runs. It changes
no game, Kronos or mod file.

FILES
hid.dll                         Loader 2: loads mw2_guns\mw2_guns.dll as before, then mw2_guns\mw2_guns_fixes.dll if it is there.
mw2_guns\mw2_guns_fixes.dll     The add-on.
mw2_guns\mw2_guns_fixes.ini     sprintfire=on (or strict, or off) and bo6sprintfire=on (or off).
mw2_guns.ini (Carry-Forward-Unleashed's) must keep sprintfire=off, so that its own older sprint-fire code (build 20) does
not change the same packages.

SWITCHES (mw2_guns\mw2_guns_fixes.ini)
sprintfire=strict   exactly the DG-2's way: the BO7 gun's timers too (reload and swap times become the BO7 gun's), and
                    nothing only the MW2/BO6 gun has. Try it if the view still jitters.
sprintfire=off      the add-on changes nothing.
bo6sprintfire=off   the BO6 guns are left alone.
To remove it: delete mw2_guns\mw2_guns_fixes.dll (loader 2 then loads only mw2_guns.dll). If a later release puts back its
own hid.dll, the add-on is simply not loaded.

LOG
kronos\Logs\mw2_guns_fixes.log: one "sprint fire:" line per gun (how many packages changed, how many of its own
animations it kept). The previous launch's is mw2_guns_fixes.prev.log.

SOURCE
mw2_guns.cpp built with /DMW2_GUNS_FIXES (build.bat), from the same source as mw2_guns build 21: section 5b and the end of
the file. zips\mw2_guns_source_build21.zip has it.
