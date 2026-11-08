# MW Carry Forward - Mystery Box 1.5.0

**Zombies > Weapons > Mystery Box** (a fifth button after Firing Range) opens four checkboxes: Black Ops 7, Black Ops 6,
Modern Warfare III and Modern Warfare II. The box then gives guns only from the checked games, each gun as likely as any
other (about 56 BO7, 55 BO6, 60 MW3 and 77 MW2 guns). At least one game always stays checked. Wonder weapons and the
other special box results are unchanged.

How it works: the choice is the dvar `mwcf_box_pools` (1 BO7 + 2 BO6 + 4 MW3 + 8 MW2; all four by default), saved with
`seta` and added to every Zombies launch. Each spin the mod script rolls once over the checked games' guns. A BO7 or BO6
roll points the box at that game's stock list (as Kronos's own box script does); an MW3 or MW2 roll builds that MW gun and
swaps it in when the box finishes, as before.

Change it in the menu before starting a match. The old Debug Options "MW2 Mystery Box" toggle is gone; Kronos's own
"Mystery Box Weapons" dropdown no longer decides the pool while this mod is installed.

Diagnostics: `cod25/kronos/mwcf_box/status.json` (build `box-19-pools`): `pools`, `mw3_loaded`, `mw2_loaded`, and
`draws_bo7/bo6/mw3/mw2` (how many spins went to each game).

Source: `tools/carry-forward/box-addon` (`build.py` builds and tests it).
