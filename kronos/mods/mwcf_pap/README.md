# MW Carry Forward - Pack-a-Punch candidate

This independent addon registers the verified Zombies and Pack-a-Punch attachment pairs for 77 MW2 weapons. The normal Zombies machine retains control of price, weapon reconstruction, tier state, damage scaling, ammunition and callbacks. The DOOM Chainsaw is excluded because its inspected weapon record has no verified Zombies/PaP attachments.

No new DLL is needed for this registration layer. It requires the existing weapon provider to make the MW2 assets available. It contains no Ztron dependency and does not replace BO6 or other stock scripts.

## Build and current status

From the workspace root:

```powershell
python tools/carry-forward/pap-addon/build.py --out output/mw2-pap-addon-03
```

Use a new output directory for each build. The build verifies the 78 source weapon records, the build-11 roster, and all 77 decoded attachment pairs; generates the roster function; runs control-flow tests against the generated source with mocked engine APIs; compiles for BO7; and disassembles the output. Offline tests do not establish successful live gameplay.

This is a candidate, not a gameplay-certified release. Do not claim verified damage, magazine sizes, camos, upgraded names, blueprint retention or successful purchases until those have been observed in game.

## Installation layout and protection

The staged `addon/` maps to the new folder `cod25/kronos/mods/mwcf_pap/`. It contains `mod.json`, this README, the separately named `scripts/zm_mwcf_pap.gsc`, and its precompiled `scripts/compiled/zm_mwcf_pap.gscc`. The engine may write its own diagnostics to `cod25/kronos/mwcf_pap_v1/status.json`.

On November 6, 2026 the user explicitly retired and requested deletion of the outdated root AGENTS.md, authorizing completion on the working build. Deployment is additive: verify the current launcher manifest, reject every destination overlapping a managed file, create only the new addon folder, and verify all managed files afterward. Preserve the existing MW2 INI, DLLs, other mods and saved state. No reset or fabricated stock baseline is involved. The game must be closed before copying the addon.

Kronos runtime logs confirm it scans mod-owned `scripts` folders. The addon waits for the stock metadata and allow-list tables and does not assume alphabetical loading. It neither initializes nor replaces those shared tables. On a map change the level state starts fresh. One worker checks all entries every two seconds, with no per-frame weapon/effect loop. Missing assets are retried every ten seconds. Diagnostics save only after a state change or repair.

Existing metadata is preserved. An existing registration is accepted only if the weapon name, both attachment names and `canpap` match. Conflicts and explicit opt-outs are reported. The addon only withdraws an allow-list entry it previously added if it still holds that same value; it does not remove pre-existing or differently valued foreign entries. Two mods writing the same value to the same key have no engine-provided ownership identity.

## Live acceptance checks

1. Start a Zombies map. Confirm `poi_reg.log` links `zm_mwcf_pap.gsc` without unknown builtin or unresolved import errors. Check the addon diagnostic status: `expected=77`, `table_ready=1`, and per-weapon status `eligible` for loaded, unclaimed weapons. `eligible` establishes registration, not a successful upgrade.
2. Use a plain M4 at the normal machine. Verify the advertised price, exact Essence charge, PaP I/II/III state and persistence after switching weapons. Check magazine capacity, reserve and reload, and compare damage at the same rarity/round/target type. No debug grant or free upgrade is used by this addon.
3. Repeat for .50 GS, a launcher, Combat Knife or Dual Kodachis, Lockwood 300, and the Super Shotgun blueprint. Check custom attachments/blueprint appearance before and after all three tiers; document any asset-specific incompatibility.
4. Confirm a BO6 weapon and a Ztron weapon still use their original behavior. Change maps, restart a match and repeat one ordinary purchase. Watch for duplicated worker symptoms or repeated diagnostic writes.
5. Confirm the DOOM Chainsaw is reported as unsupported by this addon. It must not be enabled using an arbitrary attachment from another weapon.

Normal-machine tier code attempts tier-specific attachments only when supported by the weapon. This addon does not invent pack2, pack3 or a maximum-tier attachment. Generic tier scaling remains stock behavior; its effectiveness on these legacy weapons requires the gameplay checks above.
