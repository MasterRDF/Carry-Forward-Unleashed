# MW2 Mystery Box: M4 integration probe

This is a temporary, limited diagnostic build. **MW2 Mystery Box On tests only the M4**, while the complete 78-weapon catalogue remains available to the loadout and PaP addons. The full box roster is gated until the complete model and pickup path passes live testing. The existing standalone Off/On row remains directly below Mystery Box Weapons; no mixed MW2 pools are added.

## How to test

1. Close and restart the game completely after installation.
2. Set **MW2 Mystery Box to On in the lobby before launching a fresh match**.
3. Start with a BO6/BO7 weapon or another MW2 weapon, **not the M4**. An owned M4 is deliberately excluded. Spin an ordinary box and check its final collectible, then pick up the M4. The spinning carousel still uses stock previews.
4. Confirm the weapon model, firing and reloading, and that your other weapon remains available. Pack-a-Punch the M4 afterward if the base pickup works.
5. If the reward stays stock, the readiness or assembly gate may have rejected it; diagnostics distinguish those cases. This diagnostic fallback protects the original reward rather than substituting an unready weapon. Special/wonder results remain on their stock path.

Off returns control to the separate BO6/BO7 dropdown. Saved loadout files, DLLs, other mods and stock Kronos files are not replaced by this addon.

## Implementation

The early box-selection observer first resolves the player's saved M4 through the stock saved-build helper. The native mod has already checked that saved configuration. A valid saved build goes directly to the exact-weapon streaming and readiness path; the addon no longer requires an unrelated authored-base construction to succeed first.

If the player-specific saved helper has no M4, the observer registers the weapon reference even if the root-name lookup fails, matching native zm_bo6_zb_register. It then reconstructs the native mod's validated M4 configuration using the same full asset name and all builder fields as zm_bo6_zb_try. The configuration is read without modification. If no validated native configuration exists, the observer uses the alias registration and explicit stock builder arguments used by the working loadout code. That fallback assembly includes the M4's eight authored default parts and its verified base Zombies attachment. Invalid saved builds are rejected without silently substituting a different build. Variant reporting/comparison uses the stock native query.

The restored Lua menu/launcher layer is unchanged from box-08. The recursive box-09 menu rewrapping is retired.

The exact candidate is stored on its box and requested through the stock native weapon-streaming API for the spinner and nearby clients. The observer deduplicates recursive same-frame calls. At roulette end, the native readiness predicate must confirm the candidate for those clients. The common-item callback checks readiness again before replacing only the matched placement. No bulk preloading of the roster, direct weapon grants, or recurring weapon-loading loops are used.

After stock item creation, the reveal callback verifies the actual collectible under preview.item, including its name, attachment set and variant. It updates the outer display only after those checks. The purchase callback checks the weapon actually handed onward, then performs a bounded, two-second inventory verification. The stock bundle remains the rarity/item-services carrier, so its loot identity and other metadata remain a known integration limitation. This build is intended to expose whether that carrier changes the weapon at any stage.

## Diagnostics

The addon writes cod25/kronos/mwcf_box/status.json, identified by **build=box-12-field-storage-m4-probe**. Important fields:

- test_pool_size=1 and probe_weapon=iw9_ar_mike4_mp identify the limited pool.
- build_source is authored_base or saved_build; variant and assembled_part_N describe what the engine built.
- prepared and stream_requests count early preparation and client requests.
- preparation_stage records the latest native-call checkpoint; first_preparation_failure and last_preparation_failure retain rejection reasons across later events.
- preparation_attempts, preparation_failures, missing_players, off_picks, duplicate_picks and owned_skips distinguish guard exits from construction failures.
- When no candidate exists, roulette preserves that box's preparation result instead of replacing it with the generic early_probe_missing message.
- probe_client_not_ready / probe_readiness_lost indicate a rejected unready replacement.
- collectible_missing, collectible_weapon_mismatch and collectible_parts_mismatch reject invalid real items.
- collectibles_verified counts verified real collectibles; it does not mean the player picked them up.
- purchase_weapon_mismatch / purchase_parts_mismatch identify a changed pickup result.
- pickups_verified counts subsequent inventory confirmation. It does not prove rendering, firing or reloading.
- pickup_inventory_missing records a purchase that did not produce the expected inventory weapon within two seconds.

The previous ambiguous mw2_spins counter is retired. Status storage is cleared at map initialization to remove stale fields; the independent settings store is preserved.

## Build and verification

From the workspace root, choose a new output directory:

```powershell
python tools/carry-forward/box-addon/build.py --out output/mw2-box-12-field-storage-m4-probe-final --update-owned
```

The build validates source asset hashes, extracts the authored M4 parts, runs Lua regressions and a source-level lifecycle simulation, compiles for BO7 and checks native/script call identities in the disassembly. The simulation includes delayed client readiness, stock event ordering, duplicate callbacks, missing/wrong collectibles, assembly failures and empty pickups. These checks are not a live GSC VM, renderer or gameplay test. Live acceptance is performed by the user.

## Compiler compatibility

The friend handoff documents ACTS local-variable storage incompatibility in this BO7 setup. This script stores assigned temporaries and loop indices on distinct function-specific level fields, matching the working native scripts. It uses no foreach-generated local stores. Waiting inventory checks retain state on the player. The builder rejects SetLocalVariableCached and EvalLocalVariableRefCached in the actual compiled bytecode. Source-level JavaScript tests cannot establish VM storage compatibility or live gameplay success.
