#using scripts\common\utility;
#using script_4c770a9a4ad7659c;
#using script_74f99c09414692fa;
#using script_3b3991e0b89ff57b;
#using script_2b867a98ca762b0a;
#using script_724b8f06df0c96b1;
#namespace mwcf_box_v1;

// ACTS/BO7 local stores are incompatible in this setup (friend handoff, line 152).
// Assigned temporaries and loop indices use distinct function-specific level fields.
// No scratch field crosses a wait; waiting verification state lives on its player.

autoexec mwcf_box_init()
{
    if (!utility::iszm() || isdefined(level.mwcf_box_v1))
        return;
    level.mwcf_box_v1 = function_5c418f65db2e25e8();
    level.mwcf_box_v1.names = [];
    level.mwcf_box_v1.loaded = [];
    level.mwcf_box_v1.pending_boxes = [];
    level.mwcf_box_v1.mode = -1;
    level.mwcf_box_v1.spins = 0;
    level.mwcf_box_v1.pickups = 0;
    level.mwcf_box_v1.purchases = 0;
    level.mwcf_box_v1.prepared = 0;
    level.mwcf_box_v1.stream_requests = 0;
    level.mwcf_box_v1.not_ready = 0;
    level.mwcf_box_v1.roll_calls = 0;
    level.mwcf_box_v1.item_calls = 0;
    level.mwcf_box_v1.reveal_calls = 0;
    level.mwcf_box_v1.pick_calls = 0;
    level.mwcf_box_v1.registrations = 0;
    level.mwcf_box_v1.preparation_attempts = 0;
    level.mwcf_box_v1.preparation_failures = 0;
    level.mwcf_box_v1.missing_players = 0;
    level.mwcf_box_v1.off_picks = 0;
    level.mwcf_box_v1.duplicate_picks = 0;
    level.mwcf_box_v1.owned_skips = 0;
    level.mwcf_box_v1.loot_attempts = 0;
    level.mwcf_box_v1.collectible_parts_differ = 0;
    level.mwcf_box_v1.backup_used = 0;
    level.mwcf_box_v1.not_ready_substituted = 0;
    level.mwcf_box_v1.purchase_parts_differ = 0;
    level.mwcf_box_v1.refs = [];
    level.mwcf_box_v1.parts = [];
    level.mwcf_box_v1.likes = [];
    level.mwcf_box_v1.groups = [];
    level.mwcf_box_v1.failed = [];
    level.mwcf_box_v1.failed_list = [];
    mwcf_box_seed();
    nengine_store_clear("mwcf_box");
    level thread mwcf_box_start();
}

function mwcf_box_start()
{
    while (!isdefined(level.var_d06db1f300d5fe3b) || !isdefined(level.var_2500f362153f0a30) || !isdefined(level.zm_bo6_box_mode))
        wait 0.5;
    level.mwcf_box_v1.mode = getdvarint(@"mwcf_box_mode", -1);
    if (level.mwcf_box_v1.mode < 0 || level.mwcf_box_v1.mode > 3)
    {
        if (nengine_store_load("mwcf_boxcfg", "settings"))
            level.mwcf_box_v1.mode = nengine_store_get("mwcf_boxcfg", "mode");
        if (!isdefined(level.mwcf_box_v1.mode) || level.mwcf_box_v1.mode < 0 || level.mwcf_box_v1.mode > 3)
            level.mwcf_box_v1.mode = getdvarint(@"zm_box_weapons", 0);
        setdvar(@"mwcf_box_mode", "" + level.mwcf_box_v1.mode);
    }
    mwcf_box_load();
    mwcf_box_save_mode();
    mwcf_box_hooks();
    mwcf_box_report("probe_ready");
    for (;;)
    {
        wait 2;
        mwcf_box_hooks();
    }
}

function mwcf_box_hooks()
{
    mwcf_box_register("magicbox_weapon_roulette_ended", &mwcf_box_roll_ended);
    mwcf_box_register(#"hash_c6570893b1c63e14", &mwcf_box_before_item_spawn);
    mwcf_box_register("magicbox_item_revealed", &mwcf_box_revealed);
    mwcf_box_register("magicbox_purchase", &mwcf_box_purchased);
    if (!isdefined(level.var_cb8cece2b97f9dc))
        level.var_cb8cece2b97f9dc = [];
    level.mwcf_box_v1.s_hooks_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_hooks_mwcf_index_0 < level.var_cb8cece2b97f9dc.size)
    {
        level.mwcf_box_v1.s_hooks_callback = level.var_cb8cece2b97f9dc[level.mwcf_box_v1.s_hooks_mwcf_index_0];
        level.mwcf_box_v1.s_hooks_mwcf_index_0++;
        if (level.mwcf_box_v1.s_hooks_callback == &mwcf_box_pick_observer)
            return;
    }
    level.var_cb8cece2b97f9dc[level.var_cb8cece2b97f9dc.size] = &mwcf_box_pick_observer;
}

function mwcf_box_register(event, callback)
{
    if (level namespace_42ffbe510c7bd5b1::function_be99bc58750c61fa(event, callback, undefined, true))
        return;
    level namespace_42ffbe510c7bd5b1::function_3e93ae4f7823fe81(event, callback);
    level.mwcf_box_v1.registrations++;
}

function mwcf_box_load()
{
    level.mwcf_box_v1.loaded = [];
    level.mwcf_box_v1.s_load_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_load_mwcf_index_0 < level.mwcf_box_v1.names.size)
    {
        level.mwcf_box_v1.s_load_name = level.mwcf_box_v1.names[level.mwcf_box_v1.s_load_mwcf_index_0];
        level.mwcf_box_v1.s_load_mwcf_index_0++;
        level.mwcf_box_v1.s_load_w = function_c95bf1a14134f45c(level.mwcf_box_v1.s_load_name);
        if (isdefined(level.mwcf_box_v1.s_load_w) && level.mwcf_box_v1.s_load_w.var_1b57e3034f84a054 == level.mwcf_box_v1.s_load_name)
            level.mwcf_box_v1.loaded[level.mwcf_box_v1.loaded.size] = level.mwcf_box_v1.s_load_name;
    }
}

function mwcf_box_save_mode()
{
    nengine_store_set("mwcf_boxcfg", "mode", level.mwcf_box_v1.mode);
    nengine_store_save("mwcf_boxcfg", "settings");
}

function mwcf_box_mode()
{
    level.mwcf_box_v1.s_mode_mode = getdvarint(@"mwcf_box_mode", level.mwcf_box_v1.mode);
    if (level.mwcf_box_v1.s_mode_mode < 0 || level.mwcf_box_v1.s_mode_mode > 3)
        return -1;
    if (level.mwcf_box_v1.s_mode_mode != level.mwcf_box_v1.mode)
    {
        level.mwcf_box_v1.mode = level.mwcf_box_v1.s_mode_mode;
        mwcf_box_save_mode();
    }
    return level.mwcf_box_v1.s_mode_mode;
}

function mwcf_box_owns(player, name)
{
    if (!isdefined(player))
        return 0;
    level.mwcf_box_v1.s_owns_weapons = player function_764725998ad94fc3();
    if (!isdefined(level.mwcf_box_v1.s_owns_weapons))
        return 0;
    level.mwcf_box_v1.s_owns_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_owns_mwcf_index_0 < level.mwcf_box_v1.s_owns_weapons.size)
    {
        level.mwcf_box_v1.s_owns_w = level.mwcf_box_v1.s_owns_weapons[level.mwcf_box_v1.s_owns_mwcf_index_0];
        level.mwcf_box_v1.s_owns_mwcf_index_0++;
        if (isdefined(level.mwcf_box_v1.s_owns_w) && level.mwcf_box_v1.s_owns_w.var_1b57e3034f84a054 == name)
            return 1;
    }
    return 0;
}

// Keep the preparation outcome on its box as well as in the session report.
// Later reveal/roulette reports must not erase why this candidate was rejected.
function mwcf_box_preparation_status(status, failed)
{
    level.mwcf_box_v1.preparation_stage = status;
    self.mwcf_box_preparation_result = status;
    if (failed)
    {
        level.mwcf_box_v1.preparation_failures++;
        level.mwcf_box_v1.last_preparation_failure = status;
        if (!isdefined(level.mwcf_box_v1.first_preparation_failure))
            level.mwcf_box_v1.first_preparation_failure = status;
    }
    mwcf_box_report(status);
}

function mwcf_box_describe_probe(built, source)
{
    level.mwcf_box_v1.build_source = source;
    level.mwcf_box_v1.last_attempt = built.var_1b57e3034f84a054;
    level.mwcf_box_v1.variant = function_8bb694abbe150671(built);
    level.mwcf_box_v1.assembled_parts = function_18230039fad6de43(built);
    return built;
}

function mwcf_box_build_probe(player, name)
{
    // Match the registration used by the working zm_bo6_zb_register path.
    level.mwcf_box_v1.s_build_probe_name = name;
    level.mwcf_box_v1.s_build_probe_ref = level.mwcf_box_v1.refs[name];
    level.mwcf_box_v1.s_build_probe_parts = level.mwcf_box_v1.parts[name];
    // The native addon has already validated the player's saved build. Resolve
    // it first, as the stock box does, without gating it on a separate base M4.
    mwcf_box_preparation_status("probe_saved_build_lookup", 0);
    level.mwcf_box_v1.s_build_probe_saved = player namespace_d06db1f300d5fe3b::function_c68204eff69ed046(level.mwcf_box_v1.s_build_probe_name);
    if (isdefined(level.mwcf_box_v1.s_build_probe_saved))
    {
        if (!function_4250476d9240b18e(level.mwcf_box_v1.s_build_probe_saved) || level.mwcf_box_v1.s_build_probe_saved.var_1b57e3034f84a054 != level.mwcf_box_v1.s_build_probe_name)
        {
            mwcf_box_preparation_status("probe_saved_build_invalid", 1);
            return undefined;
        }
        return mwcf_box_describe_probe(level.mwcf_box_v1.s_build_probe_saved, "saved_build");
    }
    mwcf_box_preparation_status("probe_root_lookup", 0);
    level.mwcf_box_v1.s_build_probe_root = weapon::function_f541f60718130d5d(level.mwcf_box_v1.s_build_probe_name);
    if (!isdefined(level.mwcf_box_v1.s_build_probe_root) || !function_f20826a3e52aa5cf(level.mwcf_box_v1.s_build_probe_root) || level.mwcf_box_v1.s_build_probe_root == "" || level.mwcf_box_v1.s_build_probe_root == "none")
    {
        // Stock zm_bo6_zb_register still registers ref when this lookup fails.
        // The lookup depends on registration; it is not an asset-readiness test.
        level.mwcf_box_v1.s_build_probe_root = undefined;
        level.mwcf_box_v1.root_lookup_missing = 1;
    }
    level.mwcf_box_v1.s_build_probe_entry = level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_ref];
    if (!isdefined(level.mwcf_box_v1.s_build_probe_entry) && isdefined(level.mwcf_box_v1.s_build_probe_root))
        level.mwcf_box_v1.s_build_probe_entry = level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_root];
    if (!isdefined(level.mwcf_box_v1.s_build_probe_entry))
    {
        level.mwcf_box_v1.s_build_probe_entry = function_5c418f65db2e25e8();
        level.mwcf_box_v1.s_build_probe_entry.var_f8983e5049a6b2cd = level.mwcf_box_v1.s_build_probe_name;
        // Same class mapping as the native zm_bo6_zb_group.
        level.mwcf_box_v1.s_build_probe_entry.group = level.mwcf_box_v1.groups[name];
        level.mwcf_box_v1.s_build_probe_like = level.mwcf_box_v1.likes[name];
        if (isdefined(level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_like]) && isdefined(level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_like].group))
            level.mwcf_box_v1.s_build_probe_entry.group = level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_like].group;
    }
    // Preserve existing loadout aliases and saved builds.
    if (!isdefined(level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_ref]))
        level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_ref] = level.mwcf_box_v1.s_build_probe_entry;
    if (isdefined(level.mwcf_box_v1.s_build_probe_root) && !isdefined(level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_root]))
        level.var_2500f362153f0a30[level.mwcf_box_v1.s_build_probe_root] = level.mwcf_box_v1.s_build_probe_entry;
    // Read the native mod's validated configuration without altering it. This
    // reproduces zm_bo6_zb_try with the full MW2 asset name and all build fields.
    if (isdefined(level.zm_bo6_zb) && isdefined(level.zm_bo6_zb[level.mwcf_box_v1.s_build_probe_ref]) &&
        isdefined(level.zm_bo6_zb[level.mwcf_box_v1.s_build_probe_ref].zm_bo6_zb_built))
    {
        level.mwcf_box_v1.s_build_probe_config = level.zm_bo6_zb[level.mwcf_box_v1.s_build_probe_ref];
        mwcf_box_preparation_status("probe_native_build_assembly", 0);
        level.mwcf_box_v1.s_build_probe_built = weapon::function_5416d4273f081ce2(level.mwcf_box_v1.s_build_probe_name, level.mwcf_box_v1.s_build_probe_config.attachments,
            level.mwcf_box_v1.s_build_probe_config.var_8c62817f313fe0f7, level.mwcf_box_v1.s_build_probe_config.reticle, level.mwcf_box_v1.s_build_probe_config.variantID,
            level.mwcf_box_v1.s_build_probe_config.var_3bef5d07b66ae6b2, level.mwcf_box_v1.s_build_probe_config.cosmeticAttachment,
            level.mwcf_box_v1.s_build_probe_config.var_d32f152210d120b6, undefined, undefined, undefined,
            weapon::function_2374da6f1b4fad4e(level.mwcf_box_v1.s_build_probe_name, level.mwcf_box_v1.s_build_probe_config.variantID));
        if (!isdefined(level.mwcf_box_v1.s_build_probe_built) || !function_4250476d9240b18e(level.mwcf_box_v1.s_build_probe_built) || level.mwcf_box_v1.s_build_probe_built.var_1b57e3034f84a054 != level.mwcf_box_v1.s_build_probe_name)
        {
            mwcf_box_preparation_status("probe_native_build_failed", 1);
            return undefined;
        }
        return mwcf_box_describe_probe(level.mwcf_box_v1.s_build_probe_built, "native_validated_build");
    }
    mwcf_box_preparation_status("probe_base_asset_lookup", 0);
    level.mwcf_box_v1.s_build_probe_bare = function_c95bf1a14134f45c(level.mwcf_box_v1.s_build_probe_name);
    if (!isdefined(level.mwcf_box_v1.s_build_probe_bare) || level.mwcf_box_v1.s_build_probe_bare.var_1b57e3034f84a054 != level.mwcf_box_v1.s_build_probe_name)
    {
        mwcf_box_preparation_status("probe_asset_missing", 1);
        return undefined;
    }
    mwcf_box_preparation_status("probe_authored_parts_check", 0);
    // Generated from the verified M4 definition, plus its verified base tuning.
    level.mwcf_box_v1.s_build_probe_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_build_probe_mwcf_index_0 < level.mwcf_box_v1.s_build_probe_parts.size)
    {
        level.mwcf_box_v1.s_build_probe_attachment = level.mwcf_box_v1.s_build_probe_parts[level.mwcf_box_v1.s_build_probe_mwcf_index_0];
        level.mwcf_box_v1.s_build_probe_mwcf_index_0++;
        if (!(level.mwcf_box_v1.s_build_probe_bare function_a6d6987298fb8f4a(level.mwcf_box_v1.s_build_probe_attachment)))
        {
            level.mwcf_box_v1.rejected_part = level.mwcf_box_v1.s_build_probe_attachment;
            mwcf_box_preparation_status("probe_part_unavailable", 1);
            return undefined;
        }
    }
    level.mwcf_box_v1.s_build_probe_variations = [];
    level.mwcf_box_v1.s_build_probe_mwcf_index_1 = 0;
    while (level.mwcf_box_v1.s_build_probe_mwcf_index_1 < level.mwcf_box_v1.s_build_probe_parts.size)
    {
        level.mwcf_box_v1.s_build_probe_attachment = level.mwcf_box_v1.s_build_probe_parts[level.mwcf_box_v1.s_build_probe_mwcf_index_1];
        level.mwcf_box_v1.s_build_probe_mwcf_index_1++;
        level.mwcf_box_v1.s_build_probe_variations[level.mwcf_box_v1.s_build_probe_variations.size] = 0;
    }
    mwcf_box_preparation_status("probe_authored_assembly", 0);
    // Explicit arguments match the existing working loadout constructor.
    level.mwcf_box_v1.s_build_probe_built = weapon::function_5416d4273f081ce2(level.mwcf_box_v1.s_build_probe_name, level.mwcf_box_v1.s_build_probe_parts,
        "camo_none", "none", 0, level.mwcf_box_v1.s_build_probe_variations, undefined, undefined, undefined,
        undefined, undefined, weapon::function_2374da6f1b4fad4e(level.mwcf_box_v1.s_build_probe_name, 0));
    if (!isdefined(level.mwcf_box_v1.s_build_probe_built) || !function_4250476d9240b18e(level.mwcf_box_v1.s_build_probe_built) || level.mwcf_box_v1.s_build_probe_built.var_1b57e3034f84a054 != level.mwcf_box_v1.s_build_probe_name)
    {
        mwcf_box_preparation_status("probe_assembly_failed", 1);
        return undefined;
    }
    return mwcf_box_describe_probe(level.mwcf_box_v1.s_build_probe_built, "authored_base");
}

function mwcf_box_same_parts(actual, expected)
{
    level.mwcf_box_v1.s_same_parts_actual_parts = function_18230039fad6de43(actual);
    level.mwcf_box_v1.s_same_parts_expected_parts = function_18230039fad6de43(expected);
    if (!isdefined(level.mwcf_box_v1.s_same_parts_actual_parts) || !isdefined(level.mwcf_box_v1.s_same_parts_expected_parts) || level.mwcf_box_v1.s_same_parts_actual_parts.size != level.mwcf_box_v1.s_same_parts_expected_parts.size)
        return 0;
    level.mwcf_box_v1.s_same_parts_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_same_parts_mwcf_index_0 < level.mwcf_box_v1.s_same_parts_expected_parts.size)
    {
        level.mwcf_box_v1.s_same_parts_part = level.mwcf_box_v1.s_same_parts_expected_parts[level.mwcf_box_v1.s_same_parts_mwcf_index_0];
        level.mwcf_box_v1.s_same_parts_mwcf_index_0++;
        level.mwcf_box_v1.s_same_parts_found = 0;
        level.mwcf_box_v1.s_same_parts_mwcf_index_1 = 0;
        while (level.mwcf_box_v1.s_same_parts_mwcf_index_1 < level.mwcf_box_v1.s_same_parts_actual_parts.size)
        {
            level.mwcf_box_v1.s_same_parts_actual_part = level.mwcf_box_v1.s_same_parts_actual_parts[level.mwcf_box_v1.s_same_parts_mwcf_index_1];
            level.mwcf_box_v1.s_same_parts_mwcf_index_1++;
            if (level.mwcf_box_v1.s_same_parts_actual_part == level.mwcf_box_v1.s_same_parts_part)
                level.mwcf_box_v1.s_same_parts_found = 1;
        }
        if (!level.mwcf_box_v1.s_same_parts_found)
            return 0;
    }
    return function_8bb694abbe150671(actual) == function_8bb694abbe150671(expected);
}

function mwcf_box_pick_observer(player, arg1, arg2)
{
    level.mwcf_box_v1.pick_calls++;
    mwcf_box_hooks();
    if (mwcf_box_mode() != 3)
    {
        level.mwcf_box_v1.off_picks++;
        mwcf_box_report("probe_mode_off_at_pick");
        return undefined;
    }
    if (!isdefined(player))
    {
        level.mwcf_box_v1.missing_players++;
        mwcf_box_preparation_status("probe_player_missing", 1);
        return undefined;
    }
    // Ztron asks the override list recursively in the same frame. Prepare once.
    if (isdefined(self.mwcf_box_prepared_at) && self.mwcf_box_prepared_at == function_83bf4b34fbbe124b())
    {
        level.mwcf_box_v1.duplicate_picks++;
        return undefined;
    }
    level.mwcf_box_v1.preparation_attempts++;
    self.mwcf_box_preparation_result = undefined;
    self.mwcf_box_prepared_at = function_83bf4b34fbbe124b();
    self.mwcf_box_weapon = undefined;
    self.mwcf_box_applied = 0;
    self.mwcf_box_pending = 0;
    self.mwcf_box_clients = [];
    // Random start, then walk the roster: skip owned guns and guns that already failed
    // to build this match; try at most four builds per spin. Failure keeps the stock reward.
    level.mwcf_box_v1.s_pick_observer_built = undefined;
    level.mwcf_box_v1.s_pick_observer_count = level.mwcf_box_v1.loaded.size;
    if (!level.mwcf_box_v1.s_pick_observer_count)
    {
        mwcf_box_preparation_status("pool_empty", 1);
        return undefined;
    }
    level.mwcf_box_v1.s_pick_observer_start = randomint(level.mwcf_box_v1.s_pick_observer_count);
    level.mwcf_box_v1.s_pick_observer_step = 0;
    level.mwcf_box_v1.s_pick_observer_tries = 0;
    level.mwcf_box_v1.s_pick_observer_backup = undefined;
    // Build a primary and a backup gun; both stream during the roulette and roll end
    // uses whichever is loaded (build 16 live: 1 in 5 spins kept stock when one model was late).
    while (level.mwcf_box_v1.s_pick_observer_step < level.mwcf_box_v1.s_pick_observer_count && level.mwcf_box_v1.s_pick_observer_tries < 6)
    {
        level.mwcf_box_v1.s_pick_observer_name = level.mwcf_box_v1.loaded[(level.mwcf_box_v1.s_pick_observer_start + level.mwcf_box_v1.s_pick_observer_step) % level.mwcf_box_v1.s_pick_observer_count];
        level.mwcf_box_v1.s_pick_observer_step++;
        if (isdefined(level.mwcf_box_v1.failed[level.mwcf_box_v1.s_pick_observer_name]))
            continue;
        if (mwcf_box_owns(player, level.mwcf_box_v1.s_pick_observer_name))
        {
            level.mwcf_box_v1.owned_skips++;
            continue;
        }
        level.mwcf_box_v1.s_pick_observer_tries++;
        level.mwcf_box_v1.s_pick_observer_candidate = mwcf_box_build_probe(player, level.mwcf_box_v1.s_pick_observer_name);
        if (isdefined(level.mwcf_box_v1.s_pick_observer_candidate))
        {
            if (!isdefined(level.mwcf_box_v1.s_pick_observer_built))
            {
                level.mwcf_box_v1.s_pick_observer_built = level.mwcf_box_v1.s_pick_observer_candidate;
                continue;
            }
            level.mwcf_box_v1.s_pick_observer_backup = level.mwcf_box_v1.s_pick_observer_candidate;
            break;
        }
        level.mwcf_box_v1.failed[level.mwcf_box_v1.s_pick_observer_name] = level.mwcf_box_v1.preparation_stage;
        level.mwcf_box_v1.failed_list[level.mwcf_box_v1.failed_list.size] = level.mwcf_box_v1.s_pick_observer_name + ":" + level.mwcf_box_v1.preparation_stage;
    }
    if (!isdefined(level.mwcf_box_v1.s_pick_observer_built))
    {
        // After failed builds the status keeps the last real failure stage.
        if (!level.mwcf_box_v1.s_pick_observer_tries)
            mwcf_box_preparation_status("no_eligible_weapon", 0);
        else
            mwcf_box_report(level.mwcf_box_v1.preparation_stage);
        return undefined;
    }
    self.mwcf_box_weapon = level.mwcf_box_v1.s_pick_observer_built;
    self.mwcf_box_backup = level.mwcf_box_v1.s_pick_observer_backup;
    self.mwcf_box_stream = [level.mwcf_box_v1.s_pick_observer_built];
    if (isdefined(level.mwcf_box_v1.s_pick_observer_backup))
        self.mwcf_box_stream[1] = level.mwcf_box_v1.s_pick_observer_backup;
    self.mwcf_box_player = player;
    self.mwcf_box_clients = [player];
    if (isdefined(self.var_97c6497c84d770a))
    {
        level.mwcf_box_v1.s_pick_observer_nearby = function_35d45993c544928d(self.var_97c6497c84d770a.origin, 700);
        if (isdefined(level.mwcf_box_v1.s_pick_observer_nearby))
        {
            level.mwcf_box_v1.s_pick_observer_mwcf_index_0 = 0;
            while (level.mwcf_box_v1.s_pick_observer_mwcf_index_0 < level.mwcf_box_v1.s_pick_observer_nearby.size)
            {
                level.mwcf_box_v1.s_pick_observer_client = level.mwcf_box_v1.s_pick_observer_nearby[level.mwcf_box_v1.s_pick_observer_mwcf_index_0];
                level.mwcf_box_v1.s_pick_observer_mwcf_index_0++;
                if (isdefined(level.mwcf_box_v1.s_pick_observer_client) && level.mwcf_box_v1.s_pick_observer_client != player)
                    self.mwcf_box_clients[self.mwcf_box_clients.size] = level.mwcf_box_v1.s_pick_observer_client;
            }
        }
    }
    mwcf_box_preparation_status("probe_requesting_stream", 0);
    // Same native API/priority as the stock box, during the roulette lead time.
    level.mwcf_box_v1.s_pick_observer_mwcf_index_1 = 0;
    while (level.mwcf_box_v1.s_pick_observer_mwcf_index_1 < self.mwcf_box_clients.size)
    {
        level.mwcf_box_v1.s_pick_observer_client = self.mwcf_box_clients[level.mwcf_box_v1.s_pick_observer_mwcf_index_1];
        level.mwcf_box_v1.s_pick_observer_mwcf_index_1++;
        level.mwcf_box_v1.s_pick_observer_client function_5ce8c8e4b2d4a34b(self.mwcf_box_stream, 1);
        level.mwcf_box_v1.stream_requests++;
    }
    level.mwcf_box_v1.prepared++;
    mwcf_box_report("probe_stream_requested");
    return undefined;
}

function mwcf_box_clients_ready(box)
{
    if (!isdefined(box.mwcf_box_clients) || !box.mwcf_box_clients.size)
        return 0;
    level.mwcf_box_v1.s_clients_ready_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_clients_ready_mwcf_index_0 < box.mwcf_box_clients.size)
    {
        level.mwcf_box_v1.s_clients_ready_client = box.mwcf_box_clients[level.mwcf_box_v1.s_clients_ready_mwcf_index_0];
        level.mwcf_box_v1.s_clients_ready_mwcf_index_0++;
        if (!isdefined(level.mwcf_box_v1.s_clients_ready_client) || !istrue(level.mwcf_box_v1.s_clients_ready_client function_7924a38b0be8c8bb([box.mwcf_box_weapon])))
            return 0;
    }
    return 1;
}

function mwcf_box_queue(box)
{
    level.mwcf_box_v1.s_queue_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_queue_mwcf_index_0 < level.mwcf_box_v1.pending_boxes.size)
    {
        level.mwcf_box_v1.s_queue_pending = level.mwcf_box_v1.pending_boxes[level.mwcf_box_v1.s_queue_mwcf_index_0];
        level.mwcf_box_v1.s_queue_mwcf_index_0++;
        if (isdefined(level.mwcf_box_v1.s_queue_pending) && level.mwcf_box_v1.s_queue_pending == box)
            return;
    }
    level.mwcf_box_v1.pending_boxes[level.mwcf_box_v1.pending_boxes.size] = box;
}

function mwcf_box_roll_ended(params)
{
    level.mwcf_box_v1.roll_calls++;
    if (mwcf_box_mode() != 3)
    {
        mwcf_box_report("stock_pool_selected");
        return;
    }
    if (!isdefined(params.magicbox))
        return;
    level.mwcf_box_v1.s_roll_ended_box = params.magicbox;
    if (istrue(level.mwcf_box_v1.s_roll_ended_box.var_402ae5c3e018c97f) || istrue(level.mwcf_box_v1.s_roll_ended_box.var_2e2b82eaf9ffc45f) ||
        istrue(level.mwcf_box_v1.s_roll_ended_box.var_5875ea9ebe2e7c9d) || istrue(level.mwcf_box_v1.s_roll_ended_box.var_33270db3d4d4b6c3) ||
        istrue(level.mwcf_box_v1.s_roll_ended_box.var_70598bcf767c22b6) || istrue(level.mwcf_box_v1.s_roll_ended_box.var_c472ba9c1811f8cf))
    {
        // 1.4.1: wonder weapon (var_70598bcf767c22b6) and "ultra_red" (var_c472ba9c1811f8cf) results are kept like the other special
        // results: they carry a special rarity, which an MW gun would otherwise inherit from the carrier item.
        mwcf_box_report("special_result_preserved");
        return;
    }
    if (!isdefined(level.mwcf_box_v1.s_roll_ended_box.mwcf_box_weapon) || !isdefined(level.mwcf_box_v1.s_roll_ended_box.mwcf_box_prepared_at) ||
        function_83bf4b34fbbe124b() - level.mwcf_box_v1.s_roll_ended_box.mwcf_box_prepared_at > 30000)
    {
        if (isdefined(level.mwcf_box_v1.s_roll_ended_box.mwcf_box_preparation_result))
            mwcf_box_report(level.mwcf_box_v1.s_roll_ended_box.mwcf_box_preparation_result);
        else
            mwcf_box_report("early_probe_missing");
        return;
    }
    // Prefer a loaded model; if neither is loaded, substitute anyway like the stock box,
    // which streams its reward only after spawning it (the model may pop in late).
    level.mwcf_box_v1.s_roll_ended_status = "probe_client_ready";
    if (!mwcf_box_clients_ready(level.mwcf_box_v1.s_roll_ended_box))
    {
        level.mwcf_box_v1.not_ready++;
        level.mwcf_box_v1.s_roll_ended_status = "probe_substituted_not_ready";
        if (isdefined(level.mwcf_box_v1.s_roll_ended_box.mwcf_box_backup))
        {
            level.mwcf_box_v1.s_roll_ended_primary = level.mwcf_box_v1.s_roll_ended_box.mwcf_box_weapon;
            level.mwcf_box_v1.s_roll_ended_box.mwcf_box_weapon = level.mwcf_box_v1.s_roll_ended_box.mwcf_box_backup;
            if (mwcf_box_clients_ready(level.mwcf_box_v1.s_roll_ended_box))
            {
                level.mwcf_box_v1.backup_used++;
                level.mwcf_box_v1.s_roll_ended_status = "probe_backup_ready";
            }
            else
                level.mwcf_box_v1.s_roll_ended_box.mwcf_box_weapon = level.mwcf_box_v1.s_roll_ended_primary;
        }
        if (level.mwcf_box_v1.s_roll_ended_status == "probe_substituted_not_ready")
            level.mwcf_box_v1.not_ready_substituted++;
    }
    if (!isdefined(level.mwcf_box_v1.s_roll_ended_box.var_aaebed696583903c))
    {
        mwcf_box_report("roll_missing_preview");
        return;
    }
    level.mwcf_box_v1.s_roll_ended_bundle = function_6071eb16b74b2e99(level.mwcf_box_v1.s_roll_ended_box.var_182083fc5337ebe9);
    if (!isdefined(level.mwcf_box_v1.s_roll_ended_bundle) || !isdefined(level.mwcf_box_v1.s_roll_ended_bundle.var_9b52b5f3085ca117))
        return;
    level.mwcf_box_v1.s_roll_ended_box.mwcf_box_source_name = level.mwcf_box_v1.s_roll_ended_bundle.var_9b52b5f3085ca117;
    level.mwcf_box_v1.s_roll_ended_box.mwcf_box_applied = 0;
    level.mwcf_box_v1.s_roll_ended_box.mwcf_box_time = function_83bf4b34fbbe124b();
    level.mwcf_box_v1.s_roll_ended_box.mwcf_box_pending = 1;
    mwcf_box_queue(level.mwcf_box_v1.s_roll_ended_box);
    level.mwcf_box_v1.s_roll_ended_box.mwcf_box_player.mwcf_box_pending = level.mwcf_box_v1.s_roll_ended_box;
    mwcf_box_report(level.mwcf_box_v1.s_roll_ended_status);
}

function mwcf_box_before_item_spawn(params)
{
    level.mwcf_box_v1.item_calls++;
    if (!isdefined(params.var_2e6e9a693fc8e85d) || !isdefined(params.var_667bd6c04dd0ccb9))
        return;
    level.mwcf_box_v1.s_before_item_spawn_placement = params.var_2e6e9a693fc8e85d;
    level.mwcf_box_v1.s_before_item_spawn_mwcf_index_0 = 0;
    while (level.mwcf_box_v1.s_before_item_spawn_mwcf_index_0 < level.mwcf_box_v1.pending_boxes.size)
    {
        level.mwcf_box_v1.s_before_item_spawn_box = level.mwcf_box_v1.pending_boxes[level.mwcf_box_v1.s_before_item_spawn_mwcf_index_0];
        level.mwcf_box_v1.s_before_item_spawn_mwcf_index_0++;
        if (!isdefined(level.mwcf_box_v1.s_before_item_spawn_box) || !istrue(level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_pending))
            continue;
        if (function_83bf4b34fbbe124b() - level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_time > 1000)
        {
            level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_pending = 0;
            continue;
        }
        if (!isdefined(level.mwcf_box_v1.s_before_item_spawn_box.var_aaebed696583903c) || level.mwcf_box_v1.s_before_item_spawn_placement.var_6ec84655139369c9 != level.mwcf_box_v1.s_before_item_spawn_box.var_aaebed696583903c.origin)
            continue;
        level.mwcf_box_v1.s_before_item_spawn_bundle = params.var_667bd6c04dd0ccb9;
        if (function_5bcadc7363faf452(level.mwcf_box_v1.s_before_item_spawn_bundle))
            level.mwcf_box_v1.s_before_item_spawn_bundle = function_6071eb16b74b2e99(level.mwcf_box_v1.s_before_item_spawn_bundle);
        if (!isdefined(level.mwcf_box_v1.s_before_item_spawn_bundle) || !isdefined(level.mwcf_box_v1.s_before_item_spawn_bundle.var_9b52b5f3085ca117) || level.mwcf_box_v1.s_before_item_spawn_bundle.var_9b52b5f3085ca117 != level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_source_name)
            continue;
        if (mwcf_box_mode() != 3)
        {
            level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_pending = 0;
            mwcf_box_report("probe_mode_off_before_spawn");
            return;
        }
        // Build 12 live result: without a loot ID for the M4, stock tried the generic
        // custom-weapon scriptable (never configured in ZM), then fell back to an item
        // with no weapon stamped on it. Map this exact weapon to the carrier's loot ID so
        // stock takes its normal gunsmith-weapon spawn path instead.
        mwcf_box_register_loot(level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_weapon, level.mwcf_box_v1.s_before_item_spawn_bundle, params.var_667bd6c04dd0ccb9);
        level.mwcf_box_v1.s_before_item_spawn_placement.weapon = level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_weapon;
        level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_applied = 1;
        level.mwcf_box_v1.s_before_item_spawn_box.mwcf_box_pending = 0;
        mwcf_box_report("probe_placement_applied");
        return;
    }
}

// Stock namespace_91497aa03504c5ba::function_a23ea7289efe03ed resolves a weapon's loot ID
// from level.var_721d42b2281bab28.var_6a851b11370a0472[weapon.var_e3eef737461ed674] first.
// Keep at most one addon entry per key; stock entries are never removed or changed.
function mwcf_box_register_loot(weapon, bundle, raw)
{
    level.mwcf_box_v1.loot_attempts++;
    level.mwcf_box_v1.loot_gametype_bundle = isdefined(level.var_7ebad24685cd9f8c);
    level.mwcf_box_v1.loot_key_defined = isdefined(weapon.var_e3eef737461ed674);
    if (!isdefined(level.var_721d42b2281bab28) || !isdefined(level.var_721d42b2281bab28.var_6a851b11370a0472) || !isdefined(weapon.var_e3eef737461ed674))
    {
        level.mwcf_box_v1.loot_stage = "registry_unavailable";
        return;
    }
    level.mwcf_box_v1.s_register_loot_list = level.var_721d42b2281bab28.var_6a851b11370a0472[weapon.var_e3eef737461ed674];
    level.mwcf_box_v1.s_register_loot_kept = [];
    if (isdefined(level.mwcf_box_v1.s_register_loot_list))
    {
        level.mwcf_box_v1.s_register_loot_index = 0;
        while (level.mwcf_box_v1.s_register_loot_index < level.mwcf_box_v1.s_register_loot_list.size)
        {
            level.mwcf_box_v1.s_register_loot_entry = level.mwcf_box_v1.s_register_loot_list[level.mwcf_box_v1.s_register_loot_index];
            level.mwcf_box_v1.s_register_loot_index++;
            if (isdefined(level.mwcf_box_v1.s_register_loot_entry) && !istrue(level.mwcf_box_v1.s_register_loot_entry.mwcf_box))
                level.mwcf_box_v1.s_register_loot_kept[level.mwcf_box_v1.s_register_loot_kept.size] = level.mwcf_box_v1.s_register_loot_entry;
        }
    }
    level.var_721d42b2281bab28.var_6a851b11370a0472[weapon.var_e3eef737461ed674] = level.mwcf_box_v1.s_register_loot_kept;
    // What stock resolves for this weapon on its own, before the addon entry exists.
    level.mwcf_box_v1.loot_before = isdefined(namespace_91497aa03504c5ba::function_a23ea7289efe03ed(weapon, bundle.var_f6e1f2e6a08ade5d, weapon.variantID));
    if (isdefined(raw) && function_5bcadc7363faf452(raw))
        level.mwcf_box_v1.s_register_loot_carrier = raw;
    else
        level.mwcf_box_v1.s_register_loot_carrier = namespace_49c55e3e8683c53f::function_aa1699f78ccb3f3d(bundle);
    if (!isdefined(level.mwcf_box_v1.s_register_loot_carrier))
    {
        level.mwcf_box_v1.loot_stage = "carrier_loot_missing";
        return;
    }
    level.mwcf_box_v1.s_register_loot_new = function_5c418f65db2e25e8();
    level.mwcf_box_v1.s_register_loot_new.var_ed89abfa6253e992 = level.mwcf_box_v1.s_register_loot_carrier;
    level.mwcf_box_v1.s_register_loot_new.var_683845b1a62814eb = weapon;
    level.mwcf_box_v1.s_register_loot_new.mwcf_box = 1;
    level.var_721d42b2281bab28.var_6a851b11370a0472[weapon.var_e3eef737461ed674][level.var_721d42b2281bab28.var_6a851b11370a0472[weapon.var_e3eef737461ed674].size] = level.mwcf_box_v1.s_register_loot_new;
    level.mwcf_box_v1.s_register_loot_after = namespace_91497aa03504c5ba::function_a23ea7289efe03ed(weapon, bundle.var_f6e1f2e6a08ade5d, weapon.variantID);
    level.mwcf_box_v1.loot_after = isdefined(level.mwcf_box_v1.s_register_loot_after) && level.mwcf_box_v1.s_register_loot_after == level.mwcf_box_v1.s_register_loot_carrier;
    if (level.mwcf_box_v1.loot_after)
        level.mwcf_box_v1.loot_stage = "registered";
    else
        level.mwcf_box_v1.loot_stage = "registered_not_resolved";
}

// Record what stock actually put on the collectible, so a mismatch names its cause.
function mwcf_box_describe_item(item)
{
    level.mwcf_box_v1.item_weapon = "undefined";
    if (isdefined(item.var_683845b1a62814eb))
    {
        level.mwcf_box_v1.item_weapon = "unnamed";
        if (isdefined(item.var_683845b1a62814eb.var_1b57e3034f84a054))
            level.mwcf_box_v1.item_weapon = item.var_683845b1a62814eb.var_1b57e3034f84a054;
    }
    level.mwcf_box_v1.item_loot_defined = isdefined(item.var_6b09472177ca8529);
    level.mwcf_box_v1.item_custom_root_defined = isdefined(item.var_fc1c2de76c69721a);
    level.mwcf_box_v1.item_data_defined = isdefined(item.var_6828becb300b1c44);
}

function mwcf_box_revealed(params)
{
    level.mwcf_box_v1.reveal_calls++;
    if (!isdefined(self) || !isdefined(self.mwcf_box_pending))
        return;
    level.mwcf_box_v1.s_revealed_box = self.mwcf_box_pending;
    self.mwcf_box_pending = undefined;
    if (!isdefined(level.mwcf_box_v1.s_revealed_box) || !istrue(level.mwcf_box_v1.s_revealed_box.mwcf_box_applied))
    {
        mwcf_box_report("item_callback_not_applied");
        return;
    }
    if (!isdefined(level.mwcf_box_v1.s_revealed_box.var_aaebed696583903c) || !isdefined(level.mwcf_box_v1.s_revealed_box.var_aaebed696583903c.item))
    {
        mwcf_box_report("collectible_missing");
        return;
    }
    level.mwcf_box_v1.s_revealed_item = level.mwcf_box_v1.s_revealed_box.var_aaebed696583903c.item;
    mwcf_box_describe_item(level.mwcf_box_v1.s_revealed_item);
    if (!isdefined(level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb) || level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb.var_1b57e3034f84a054 != level.mwcf_box_v1.s_revealed_box.mwcf_box_weapon.var_1b57e3034f84a054)
    {
        mwcf_box_report("collectible_weapon_mismatch");
        return;
    }
    // Default-attachment builds come back from the item spawn with a different part list
    // (saved builds do not). The gun is still correct, so record the difference and continue;
    // returning here skipped pickup tracking and left those guns grey.
    if (!mwcf_box_same_parts(level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb, level.mwcf_box_v1.s_revealed_box.mwcf_box_weapon))
    {
        level.mwcf_box_v1.collectible_parts_differ++;
        level.mwcf_box_v1.last_parts_expected = level.mwcf_box_v1.s_same_parts_expected_parts.size;
        level.mwcf_box_v1.last_parts_actual = level.mwcf_box_v1.s_same_parts_actual_parts.size;
    }
    self.mwcf_box_expected = function_5c418f65db2e25e8();
    self.mwcf_box_expected.weapon = level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb;
    self.mwcf_box_expected.source_name = level.mwcf_box_v1.s_revealed_box.mwcf_box_source_name;
    self.mwcf_box_expected.revealed_at = function_83bf4b34fbbe124b();
    // The rarity the box shows comes from the carrier item. Stock builds new weapon
    // data from weapon.var_e4de3f79b4ac164f, which MW2 builds lack, so it would be grey.
    if (isdefined(level.mwcf_box_v1.s_revealed_item.var_6828becb300b1c44) && isdefined(level.mwcf_box_v1.s_revealed_item.var_6828becb300b1c44.var_f6e1f2e6a08ade5d))
        self.mwcf_box_expected.rarity = level.mwcf_box_v1.s_revealed_item.var_6828becb300b1c44.var_f6e1f2e6a08ade5d;
    else
    {
        level.mwcf_box_v1.s_revealed_bundle = function_6071eb16b74b2e99(level.mwcf_box_v1.s_revealed_box.var_182083fc5337ebe9);
        if (isdefined(level.mwcf_box_v1.s_revealed_bundle))
            self.mwcf_box_expected.rarity = level.mwcf_box_v1.s_revealed_bundle.var_f6e1f2e6a08ade5d;
    }
    level.mwcf_box_v1.item_rarity = self.mwcf_box_expected.rarity;
    level.mwcf_box_v1.s_revealed_box.var_aaebed696583903c.var_2e08e94c9cb1747c = level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb.var_1b57e3034f84a054;
    level.mwcf_box_v1.s_revealed_box.var_aaebed696583903c.var_683845b1a62814eb = level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb;
    level.mwcf_box_v1.spins++;
    level.mwcf_box_v1.last_weapon = level.mwcf_box_v1.s_revealed_item.var_683845b1a62814eb.var_1b57e3034f84a054;
    mwcf_box_report("collectible_verified");
}

function mwcf_box_purchased(params)
{
    if (!isdefined(self.mwcf_box_expected))
        return;
    if (function_83bf4b34fbbe124b() - self.mwcf_box_expected.revealed_at > 60000)
    {
        self.mwcf_box_expected = undefined;
        return;
    }
    if (!isdefined(params.var_667bd6c04dd0ccb9) || params.var_667bd6c04dd0ccb9.var_9b52b5f3085ca117 != self.mwcf_box_expected.source_name)
        return;
    level.mwcf_box_v1.purchases++;
    if (!isdefined(params.var_b575eda3d8d8533b) || !function_4250476d9240b18e(params.var_b575eda3d8d8533b) ||
        params.var_b575eda3d8d8533b.var_1b57e3034f84a054 != self.mwcf_box_expected.weapon.var_1b57e3034f84a054)
    {
        mwcf_box_report("purchase_weapon_mismatch");
        self.mwcf_box_expected = undefined;
        return;
    }
    if (!mwcf_box_same_parts(params.var_b575eda3d8d8533b, self.mwcf_box_expected.weapon))
        level.mwcf_box_v1.purchase_parts_differ++;
    self.mwcf_box_expected.deadline = function_83bf4b34fbbe124b() + 2000;
    self thread mwcf_box_verify_inventory();
}

function mwcf_box_verify_inventory()
{
    self endon(#"disconnect");
    // State that survives waits lives on the player, and the check is bounded.
    while (isdefined(self.mwcf_box_expected))
    {
        if (mwcf_box_owns(self, self.mwcf_box_expected.weapon.var_1b57e3034f84a054))
        {
            // mwcf_box_owns leaves the matching inventory weapon in s_owns_w (no wait since).
            self.mwcf_box_rarity_weapon = level.mwcf_box_v1.s_owns_w;
            if (isdefined(self.mwcf_box_expected.rarity) && self.mwcf_box_expected.rarity > 0)
            {
                self namespace_91497aa03504c5ba::function_40e1cbd0e1f47d1a(self.mwcf_box_rarity_weapon, self.mwcf_box_expected.rarity);
                level.mwcf_box_v1.rarity_applied = self.mwcf_box_expected.rarity;
                level.mwcf_box_v1.rarity_after = self namespace_91497aa03504c5ba::function_fb81bd2fe070faa6(self.mwcf_box_rarity_weapon);
            }
            self.mwcf_box_rarity_weapon = undefined;
            level.mwcf_box_v1.pickups++;
            self.mwcf_box_expected = undefined;
            mwcf_box_report("pickup_inventory_verified");
            return;
        }
        if (function_83bf4b34fbbe124b() >= self.mwcf_box_expected.deadline)
        {
            self.mwcf_box_expected = undefined;
            mwcf_box_report("pickup_inventory_missing");
            return;
        }
        wait 0.1;
    }
}

function mwcf_box_report(status)
{
    nengine_store_set("mwcf_box", "status", status);
    nengine_store_set("mwcf_box", "build", "box-18-mw3");
    nengine_store_set("mwcf_box", "pool_size", level.mwcf_box_v1.loaded.size);
    nengine_store_set("mwcf_box", "failed_weapon_count", level.mwcf_box_v1.failed_list.size);
    level.mwcf_box_v1.s_report_failed_index = 0;
    while (level.mwcf_box_v1.s_report_failed_index < level.mwcf_box_v1.failed_list.size)
    {
        nengine_store_set("mwcf_box", "failed_" + level.mwcf_box_v1.s_report_failed_index, level.mwcf_box_v1.failed_list[level.mwcf_box_v1.s_report_failed_index]);
        level.mwcf_box_v1.s_report_failed_index++;
    }
    nengine_store_set("mwcf_box", "mode", level.mwcf_box_v1.mode);
    nengine_store_set("mwcf_box", "stock_mode", getdvarint(@"zm_box_weapons", -1));
    nengine_store_set("mwcf_box", "loaded", level.mwcf_box_v1.loaded.size);
    nengine_store_set("mwcf_box", "prepared", level.mwcf_box_v1.prepared);
    nengine_store_set("mwcf_box", "stream_requests", level.mwcf_box_v1.stream_requests);
    nengine_store_set("mwcf_box", "not_ready", level.mwcf_box_v1.not_ready);
    nengine_store_set("mwcf_box", "roll_calls", level.mwcf_box_v1.roll_calls);
    nengine_store_set("mwcf_box", "item_calls", level.mwcf_box_v1.item_calls);
    nengine_store_set("mwcf_box", "reveal_calls", level.mwcf_box_v1.reveal_calls);
    nengine_store_set("mwcf_box", "pick_calls", level.mwcf_box_v1.pick_calls);
    nengine_store_set("mwcf_box", "registrations", level.mwcf_box_v1.registrations);
    nengine_store_set("mwcf_box", "preparation_attempts", level.mwcf_box_v1.preparation_attempts);
    nengine_store_set("mwcf_box", "preparation_failures", level.mwcf_box_v1.preparation_failures);
    nengine_store_set("mwcf_box", "missing_players", level.mwcf_box_v1.missing_players);
    nengine_store_set("mwcf_box", "off_picks", level.mwcf_box_v1.off_picks);
    nengine_store_set("mwcf_box", "duplicate_picks", level.mwcf_box_v1.duplicate_picks);
    nengine_store_set("mwcf_box", "owned_skips", level.mwcf_box_v1.owned_skips);
    nengine_store_set("mwcf_box", "loot_attempts", level.mwcf_box_v1.loot_attempts);
    nengine_store_set("mwcf_box", "collectible_parts_differ", level.mwcf_box_v1.collectible_parts_differ);
    nengine_store_set("mwcf_box", "backup_used", level.mwcf_box_v1.backup_used);
    nengine_store_set("mwcf_box", "not_ready_substituted", level.mwcf_box_v1.not_ready_substituted);
    nengine_store_set("mwcf_box", "purchase_parts_differ", level.mwcf_box_v1.purchase_parts_differ);
    if (isdefined(level.mwcf_box_v1.last_parts_expected))
    {
        nengine_store_set("mwcf_box", "last_parts_expected", level.mwcf_box_v1.last_parts_expected);
        nengine_store_set("mwcf_box", "last_parts_actual", level.mwcf_box_v1.last_parts_actual);
    }
    if (isdefined(level.mwcf_box_v1.loot_stage))
    {
        nengine_store_set("mwcf_box", "loot_stage", level.mwcf_box_v1.loot_stage);
        nengine_store_set("mwcf_box", "loot_gametype_bundle", level.mwcf_box_v1.loot_gametype_bundle);
        nengine_store_set("mwcf_box", "loot_key_defined", level.mwcf_box_v1.loot_key_defined);
    }
    if (isdefined(level.mwcf_box_v1.item_rarity))
        nengine_store_set("mwcf_box", "item_rarity", level.mwcf_box_v1.item_rarity);
    if (isdefined(level.mwcf_box_v1.rarity_applied))
    {
        nengine_store_set("mwcf_box", "rarity_applied", level.mwcf_box_v1.rarity_applied);
        nengine_store_set("mwcf_box", "rarity_after", level.mwcf_box_v1.rarity_after);
    }
    if (isdefined(level.mwcf_box_v1.loot_before))
        nengine_store_set("mwcf_box", "loot_before", level.mwcf_box_v1.loot_before);
    if (isdefined(level.mwcf_box_v1.loot_after))
        nengine_store_set("mwcf_box", "loot_after", level.mwcf_box_v1.loot_after);
    if (isdefined(level.mwcf_box_v1.item_weapon))
    {
        nengine_store_set("mwcf_box", "item_weapon", level.mwcf_box_v1.item_weapon);
        nengine_store_set("mwcf_box", "item_loot_defined", level.mwcf_box_v1.item_loot_defined);
        nengine_store_set("mwcf_box", "item_custom_root_defined", level.mwcf_box_v1.item_custom_root_defined);
        nengine_store_set("mwcf_box", "item_data_defined", level.mwcf_box_v1.item_data_defined);
    }
    if (isdefined(level.mwcf_box_v1.root_lookup_missing))
        nengine_store_set("mwcf_box", "root_lookup_missing", level.mwcf_box_v1.root_lookup_missing);
    if (isdefined(level.mwcf_box_v1.preparation_stage))
        nengine_store_set("mwcf_box", "preparation_stage", level.mwcf_box_v1.preparation_stage);
    if (isdefined(level.mwcf_box_v1.first_preparation_failure))
        nengine_store_set("mwcf_box", "first_preparation_failure", level.mwcf_box_v1.first_preparation_failure);
    if (isdefined(level.mwcf_box_v1.last_preparation_failure))
        nengine_store_set("mwcf_box", "last_preparation_failure", level.mwcf_box_v1.last_preparation_failure);
    nengine_store_set("mwcf_box", "collectibles_verified", level.mwcf_box_v1.spins);
    nengine_store_set("mwcf_box", "purchase_events", level.mwcf_box_v1.purchases);
    nengine_store_set("mwcf_box", "pickups_verified", level.mwcf_box_v1.pickups);
    if (isdefined(level.mwcf_box_v1.last_attempt))
        nengine_store_set("mwcf_box", "last_attempt", level.mwcf_box_v1.last_attempt);
    if (isdefined(level.mwcf_box_v1.last_weapon))
        nengine_store_set("mwcf_box", "last_weapon", level.mwcf_box_v1.last_weapon);
    if (isdefined(level.mwcf_box_v1.rejected_part))
        nengine_store_set("mwcf_box", "rejected_part", level.mwcf_box_v1.rejected_part);
    if (isdefined(level.mwcf_box_v1.build_source))
        nengine_store_set("mwcf_box", "build_source", level.mwcf_box_v1.build_source);
    if (isdefined(level.mwcf_box_v1.variant))
        nengine_store_set("mwcf_box", "variant", level.mwcf_box_v1.variant);
    if (isdefined(level.mwcf_box_v1.assembled_parts))
    {
        nengine_store_set("mwcf_box", "assembled_part_count", level.mwcf_box_v1.assembled_parts.size);
        level.mwcf_box_v1.s_report_mwcf_index_0 = 0;
        while (level.mwcf_box_v1.s_report_mwcf_index_0 < level.mwcf_box_v1.assembled_parts.size)
        {
            level.mwcf_box_v1.s_report_i = level.mwcf_box_v1.s_report_mwcf_index_0;
            level.mwcf_box_v1.s_report_part = level.mwcf_box_v1.assembled_parts[level.mwcf_box_v1.s_report_mwcf_index_0];
            level.mwcf_box_v1.s_report_mwcf_index_0++;
            nengine_store_set("mwcf_box", "assembled_part_" + level.mwcf_box_v1.s_report_i, level.mwcf_box_v1.s_report_part);
        }
    }
    nengine_store_save("mwcf_box", "status");
}

function mwcf_box_seed()
{
    level.mwcf_box_v1.names = [
        "iw9_ar_mike4_mp",
        "iw9_ar_mike16_mp",
        "iw9_ar_scharlie_mp",
        "iw9_ar_akilo_mp",
        "iw9_ar_akilo105_mp",
        "iw9_ar_akilo74_mp",
        "iw9_ar_kilo53_mp",
        "iw9_ar_augolf_mp",
        "iw9_ar_mcbravo_mp",
        "iw9_ar_mcharlie_mp",
        "iw9_ar_acharlie300_mp",
        "iw9_ar_helima_mp",
        "iw9_ar_fecho_mp",
        "iw9_ar_falpha_mp",
        "iw9_ar_malima_mp",
        "iw9_sm_mpapa7_mp",
        "iw9_sm_apapa_mp",
        "iw9_sm_mpapa5_mp",
        "iw9_sm_aviktor_mp",
        "iw9_sm_alpha57_mp",
        "iw9_sm_beta_mp",
        "iw9_sm_papa90_mp",
        "iw9_sm_victor_mp",
        "iw9_sm_mpapax_mp",
        "iw9_sm_acharlie45_mp",
        "iw9_sm_sdelta_mp",
        "iw9_sm_acharlie9_mp",
        "iw9_lm_ahotel_mp",
        "iw9_lm_foxtrot_mp",
        "iw9_lm_kilo21_mp",
        "iw9_lm_ngolf7_mp",
        "iw9_lm_rkilo_mp",
        "iw9_lm_slima_mp",
        "iw9_pi_papa220_mp",
        "iw9_pi_golf17_mp",
        "iw9_pi_golf18_mp",
        "iw9_pi_decho_mp",
        "iw9_pi_swhiskey_mp",
        "iw9_pi_tango9_mp",
        "iw9_pi_dechoauto_mp",
        "iw9_pi_mike2011_mp",
        "iw9_sh_mbravo_mp",
        "iw9_sh_mviktor_mp",
        "iw9_sh_charlie725_mp",
        "iw9_sh_mike1014_mp",
        "iw9_sh_vecho_mp",
        "iw9_sh_tsierra12_mp",
        "iw9_sn_mromeo_mp",
        "iw9_sn_alpha50_mp",
        "iw9_dm_la700_mp",
        "iw9_dm_xmike2010_mp",
        "iw9_sn_limax_mp",
        "iw9_sn_india_mp",
        "iw9_sn_walpha_mp",
        "iw9_dm_mike14_mp",
        "iw9_dm_mike24_mp",
        "iw9_dm_sbeta_mp",
        "iw9_dm_pgolf1_mp",
        "iw9_dm_sa700_mp",
        "iw9_dm_scromeo_mp",
        "iw9_dm_stango25_mp",
        "iw9_ar_golf3_mp",
        "iw9_ar_schotel_mp",
        "iw9_br_msecho_mp",
        "iw9_br_ngsierra_mp",
        "iw9_br_soscar14_mp",
        "iw9_dm_crossbow_mp",
        "iw9_la_gromeo_mp",
        "iw9_la_kgolf_mp",
        "iw9_la_juliet_mp",
        "iw9_la_rpapa7_mp",
        "iw9_la_mike32_mp",
        "iw9_me_knife_mp",
        "iw9_me_sword01_mp",
        "iw9_me_tonfa_mp",
        "iw9_me_pickaxe_mp",
        "iw9_me_kamas_mp",
        "jup_cp06_ar_falpha_mp",
        "jup_cp08_br_xmike5_mp",
        "jup_jp01_ar_golf36_mp",
        "jup_jp02_ar_bromeo805_mp",
        "jup_jp02_br_bromeo2_mp",
        "jup_jp03_br_aromeo200_mp",
        "jup_jp05_ar_foxtrot2000_mp",
        "jup_jp08_ar_qbravo97_mp",
        "jup_jp19_ar_acharlie_mp",
        "jup_jp19_br_acharlie450_mp",
        "jup_jp25_ar_talpha95_mp",
        "jup_jp34_ar_balpha27_mp",
        "jup_jp36_ar_anov94_mp",
        "jup_jp40_br_hcharlie36_mp",
        "jup_jp44_ar_stango44_mp",
        "jup_jp01_dm_slima8_mp",
        "jup_jp02_dm_bromeop_mp",
        "jup_jp10_sn_cdelta50_mp",
        "jup_jp13_dm_svictork_mp",
        "jup_jp13_sn_svictor_mp",
        "jup_jp17_sn_hsierra_mp",
        "jup_jp19_dm_acharlied_mp",
        "jup_jp31_dm_compound_mp",
        "jup_jp35_sn_moscar_mp",
        "jup_jp36_sn_boscar_mp",
        "jup_jp37_dm_kappa98_mp",
        "jup_cp01_sh_aromeo410_mp",
        "jup_cp05_lm_halpha_mp",
        "jup_cp15_lm_mkilo3_mp",
        "jup_jp01_lm_mgolf36_mp",
        "jup_jp06_lm_pkilop_mp",
        "jup_jp08_lm_qbravo95lsw_mp",
        "jup_jp09_sh_oromeo12_mp",
        "jup_jp16_sh_recho870_mp",
        "jup_jp20_lm_evictor_mp",
        "jup_jp28_lm_rpapa20_mp",
        "jup_jp38_sh_spapa12_mp",
        "jup_jp23_me_kalpha_mp",
        "jup_jp23_me_pdango_mp",
        "jup_jp23_me_shotel_mp",
        "jup_jp23_me_spear_mp",
        "jup_jp23_me_swhiskey_mp",
        "jup_me_glassshiv_mp",
        "jup_cp24_pi_glima21_mp",
        "jup_jp07_pi_uzulum_mp",
        "jup_jp12_pi_mike93_mp",
        "jup_jp14_pi_rsierra12_mp",
        "jup_jp22_la_dromeo_mp",
        "jup_jp32_pi_mpapa9_mp",
        "jup_la_plasmagun_mp",
        "jup_cp01_sm_coscar635_mp",
        "jup_cp01_sm_pcharlie9_mp",
        "jup_jp02_sm_scharlie3_mp",
        "jup_jp03_sm_pmike_mp",
        "jup_jp04_sm_lwhiskey_mp",
        "jup_jp04_sm_umike_mp",
        "jup_jp07_sm_uzulu_mp",
        "jup_jp07_sm_uzulup_mp",
        "jup_jp25_sm_talpham_mp",
        "jup_jp41_sm_kpappa50_mp"
    ];
    level.mwcf_box_v1.refs["iw9_ar_mike4_mp"] = "iw9_ar_mike4";
    level.mwcf_box_v1.groups["iw9_ar_mike4_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_mike4_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_mike4_mp"] = ["iw9_rec_mike4", "bar_ar_p01", "stock_ar_p01_mike4", "mag_ar_p01", "pgrip_p01", "iw9_ironsdefault_mike4", "selectsemi_mike4", "ammo_556n", "zm_ar_mike4"];
    level.mwcf_box_v1.refs["iw9_ar_mike16_mp"] = "iw9_ar_mike16";
    level.mwcf_box_v1.groups["iw9_ar_mike16_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_mike16_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_mike16_mp"] = ["rec_mike16", "bar_ar_longhvy_p01_mike16", "stock_ar_assault_p01_mike16", "mag_ar_p01", "pgrip_p01", "ironsdefault_mike16", "selectsemi_mike16", "ammo_556n", "zm_ar_mike16"];
    level.mwcf_box_v1.refs["iw9_ar_scharlie_mp"] = "iw9_ar_scharlie";
    level.mwcf_box_v1.groups["iw9_ar_scharlie_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_scharlie_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_scharlie_mp"] = ["iw9_rec_scharlie", "bar_ar_p05", "stock_ar_p05_scharlie", "mag_ar_p05", "pgrip_p05", "iw9_ironsdefault_scharlie", "iw9_selectsemi", "ammo_556n", "zm_ar_scharlie"];
    level.mwcf_box_v1.refs["iw9_ar_akilo_mp"] = "iw9_ar_akilo";
    level.mwcf_box_v1.groups["iw9_ar_akilo_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_akilo_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_akilo_mp"] = ["rec_akilo", "bar_ar_long_p04_akilo", "stock_ar_p04_akilo", "mag_ar_p04_akilo", "pgrip_p04", "ironsdefault_akilo", "selectsemi_akilo", "ammo_762s", "zm_ar_akilo"];
    level.mwcf_box_v1.refs["iw9_ar_akilo105_mp"] = "iw9_ar_akilo105";
    level.mwcf_box_v1.groups["iw9_ar_akilo105_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_akilo105_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_akilo105_mp"] = ["rec_akilo105", "bar_ar_p04_akilo105", "stock_ar_p04_akilo105", "mag_ar_light_p04_akilo105", "pgrip_p04_akilo105", "ironsdefault_akilo105", "selectsemi_akilo", "ammo_545s", "zm_ar_akilo105"];
    level.mwcf_box_v1.refs["iw9_ar_akilo74_mp"] = "iw9_ar_akilo74";
    level.mwcf_box_v1.groups["iw9_ar_akilo74_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_akilo74_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_akilo74_mp"] = ["rec_akilo74", "bar_ar_short_p04", "stock_sm_p04_akilo74", "mag_ar_light_p04_akilo74", "pgrip_p04", "ironsdefault_akilo74", "selectsemi_akilo", "ammo_545s", "zm_ar_akilo74"];
    level.mwcf_box_v1.refs["iw9_ar_kilo53_mp"] = "iw9_ar_kilo53";
    level.mwcf_box_v1.groups["iw9_ar_kilo53_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_kilo53_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_kilo53_mp"] = ["rec_kilo53", "bar_ar_short_p02_kilo53", "stock_ar_assault_p02_kilo53", "mag_ar_p02", "pgrip_ar_ass_p02", "ironsdefault_kilo53", "selectsemi_kilo53", "ammo_556n", "zm_ar_kilo53"];
    level.mwcf_box_v1.refs["iw9_ar_augolf_mp"] = "iw9_ar_augolf";
    level.mwcf_box_v1.groups["iw9_ar_augolf_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_augolf_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_augolf_mp"] = ["iw9_rec_augolf", "bar_ar_p03_augolf", "stock_ar_p03_augolf", "mag_ar_p03_augolf", "pgrip_p03", "iw9_ironsdefault_augolf", "iw9_selectsemi", "ammo_556n", "bgrip_hvy_p03", "zm_ar_augolf"];
    level.mwcf_box_v1.refs["iw9_ar_mcbravo_mp"] = "iw9_ar_mcbravo";
    level.mwcf_box_v1.groups["iw9_ar_mcbravo_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_mcbravo_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_mcbravo_mp"] = ["rec_mcbravo", "barsil_ar_p08", "stock_ar_light_p08", "mag_ar_heavy_p08", "pgrip_ar2_p08", "ironsdefault_mcbravo", "selectsemi_mcbravo", "ammo_blk", "zm_ar_mcbravo"];
    level.mwcf_box_v1.refs["iw9_ar_mcharlie_mp"] = "iw9_ar_mcharlie";
    level.mwcf_box_v1.groups["iw9_ar_mcharlie_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_mcharlie_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_mcharlie_mp"] = ["iw9_rec_mcharlie", "bar_ar_p08", "stock_ar_p08", "mag_ar_p08", "pgrip_ar_p08", "iw9_ironsdefault_mcharlie", "iw9_selectsemi", "ammo_556n", "zm_ar_mcharlie"];
    level.mwcf_box_v1.refs["iw9_ar_acharlie300_mp"] = "iw9_ar_acharlie300";
    level.mwcf_box_v1.groups["iw9_ar_acharlie300_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_acharlie300_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_acharlie300_mp"] = ["rec_acharlie300", "bar_ar_p43", "stock_ar_p43", "mag_ar_p43", "pgrip_p43", "ironsdefault_acharlie300", "iw9_selectsemi", "ammo_556n_p43", "zm_ar_acharlie300"];
    level.mwcf_box_v1.refs["iw9_ar_helima_mp"] = "iw9_ar_helima";
    level.mwcf_box_v1.groups["iw9_ar_helima_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_helima_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_helima_mp"] = ["rec_helima", "bar_ar_p52", "stock_ar_p52", "mag_ar_p52", "comb_p52", "pgrip_p52", "ironsdefault_helima", "iw9_selectsemi", "ammo_556n", "zm_ar_helima"];
    level.mwcf_box_v1.refs["iw9_ar_fecho_mp"] = "iw9_ar_fecho";
    level.mwcf_box_v1.groups["iw9_ar_fecho_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_fecho_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_fecho_mp"] = ["rec_fecho", "bar_ar_p06", "stock_ar_heavy_p06", "mag_ar_p06", "comb_p06", "pgrip_p06", "ironsdefault_fecho", "iw9_selectsemi", "ammo_556n", "rail_ar_large_p06", "zm_ar_fecho"];
    level.mwcf_box_v1.refs["iw9_ar_falpha_mp"] = "iw9_ar_falpha";
    level.mwcf_box_v1.groups["iw9_ar_falpha_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_falpha_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_falpha_mp"] = ["iw9_rec_falpha", "bar_ar_p06", "stock_ar_heavy_p06", "mag_ar_p06", "comb_p06", "pgrip_p06", "iw9_ironsdefault_falpha", "iw9_selectsemi_falpha", "ammo_556n", "rail_ar_large_p06", "zm_ar_falpha"];
    level.mwcf_box_v1.refs["iw9_ar_malima_mp"] = "iw9_ar_malima";
    level.mwcf_box_v1.groups["iw9_ar_malima_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_malima_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_malima_mp"] = ["rec_malima", "bar_ar_p56", "stock_ar_p56", "mag_ar_p56", "comb_p56", "pgrip_p56", "ironsdefault_malima", "selectsemi_malima", "ammo_762s", "zm_ar_malima"];
    level.mwcf_box_v1.refs["iw9_sm_mpapa7_mp"] = "iw9_sm_mpapa7";
    level.mwcf_box_v1.groups["iw9_sm_mpapa7_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_mpapa7_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_mpapa7_mp"] = ["rec_mpapa7", "bar_sm_p09", "stock_sm_light_p09", "mag_sm_p09", "pgrip_p09", "ironsdefault_mpapa7", "iw9_selectsemi", "ammo_4x30", "zm_sm_mpapa7"];
    level.mwcf_box_v1.refs["iw9_sm_apapa_mp"] = "iw9_sm_apapa";
    level.mwcf_box_v1.groups["iw9_sm_apapa_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_apapa_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_apapa_mp"] = ["rec_apapa", "bar_sm_short_p03", "stock_sm_p03_apapa", "mag_sm_p03", "pgrip_p03", "ironsdefault_apapa", "iw9_selectsemi", "ammo_9s", "zm_sm_apapa"];
    level.mwcf_box_v1.refs["iw9_sm_mpapa5_mp"] = "iw9_sm_mpapa5";
    level.mwcf_box_v1.groups["iw9_sm_mpapa5_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_mpapa5_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_mpapa5_mp"] = ["rec_mpapa5_mp", "bar_sm_p02", "stock_sm_p02_mpapa5", "mag_sm_p02", "pgrip_sm_tac_p02", "ironsdefault_mpapa5", "selectburst_mpapa5", "ammo_9p", "zm_sm_mpapa5"];
    level.mwcf_box_v1.refs["iw9_sm_aviktor_mp"] = "iw9_sm_aviktor";
    level.mwcf_box_v1.groups["iw9_sm_aviktor_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_aviktor_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_aviktor_mp"] = ["rec_aviktor", "bar_sm_p04", "stock_sm_p04_aviktor", "mag_sm_p04", "pgrip_p04", "ironsdefault_aviktor", "iw9_selectsemi", "ammo_9p", "zm_sm_aviktor"];
    level.mwcf_box_v1.refs["iw9_sm_alpha57_mp"] = "iw9_sm_alpha57";
    level.mwcf_box_v1.groups["iw9_sm_alpha57_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_alpha57_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_alpha57_mp"] = ["rec_alpha57", "bar_sm_p01", "stock_sm_p01_alpha57", "mag_sm_p01", "pgrip_p01", "ironsdefault_alpha57", "iw9_selectsemi", "ammo_5x28", "zm_sm_alpha57"];
    level.mwcf_box_v1.refs["iw9_sm_beta_mp"] = "iw9_sm_beta";
    level.mwcf_box_v1.groups["iw9_sm_beta_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_beta_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_beta_mp"] = ["iw9_rec_beta", "bar_sm_lgtshort_p04", "stock_sm_p04_beta", "magheli_sm_p04", "pgrip_p04", "iw9_ironsdefault_beta", "iw9_selectsemi", "ammo_9m", "zm_sm_beta"];
    level.mwcf_box_v1.refs["iw9_sm_papa90_mp"] = "iw9_sm_papa90";
    level.mwcf_box_v1.groups["iw9_sm_papa90_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_papa90_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_papa90_mp"] = ["iw9_rec_papa90", "bar_sm_p07", "stock_sm_light_p07", "mag_sm_p07", "rail_sm_p07", "pgrip_p07", "iw9_ironsdefault_papa90", "ammo_5x28", "zm_sm_papa90"];
    level.mwcf_box_v1.refs["iw9_sm_victor_mp"] = "iw9_sm_victor";
    level.mwcf_box_v1.groups["iw9_sm_victor_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_victor_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_victor_mp"] = ["iw9_rec_victor", "bar_sm_p10", "stock_sm_light_p10", "mag_p10", "pgrip_p10", "iw9_ironsdefault_victor", "iw9_selectsemi", "ammo_45acp", "zm_sm_victor"];
    level.mwcf_box_v1.refs["iw9_sm_mpapax_mp"] = "iw9_sm_mpapax";
    level.mwcf_box_v1.groups["iw9_sm_mpapax_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_mpapax_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_mpapax_mp"] = ["rec_mpapax", "bar_sm_p08", "stock_sm_light_p08", "mag_sm_p08", "pgrip_sm_p08", "ironsdefault_mpapax", "iw9_selectsemi", "ammo_9p", "zm_sm_mpapax"];
    level.mwcf_box_v1.refs["iw9_sm_acharlie45_mp"] = "iw9_sm_acharlie45";
    level.mwcf_box_v1.groups["iw9_sm_acharlie45_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_acharlie45_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_acharlie45_mp"] = ["rec_acharlie45", "bar_sm_p43", "stock_sm_p43", "mag_sm_p43", "pgrip_sm_p43", "ironsdefault_acharlie45", "selectsemi_acharlie45", "ammo_45acp", "zm_sm_acharlie45"];
    level.mwcf_box_v1.refs["iw9_sm_sdelta_mp"] = "iw9_sm_sdelta";
    level.mwcf_box_v1.groups["iw9_sm_sdelta_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_sdelta_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_sdelta_mp"] = ["rec_sdelta", "barsil_sm_p02", "stock_sm_p02_sdelta", "mag_sm_p02_sdelta", "pgrip_sm_tac_p02_sdelta", "ironsdefault_sdelta", "selectauto_sdelta", "ammo_9s", "zm_sm_sdelta"];
    level.mwcf_box_v1.refs["iw9_sm_acharlie9_mp"] = "iw9_sm_acharlie9";
    level.mwcf_box_v1.groups["iw9_sm_acharlie9_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["iw9_sm_acharlie9_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["iw9_sm_acharlie9_mp"] = ["rec_acharlie9", "bar_sm_short_p43_acharlie9", "stock_sm_lgt_tactical_p43_acharlie9", "mag_sm2_p43", "pgrip_sm2_p43", "ironsdefault_acharlie9", "selectsemi_acharlie9", "ammo_9p", "zm_sm_acharlie9"];
    level.mwcf_box_v1.refs["iw9_lm_ahotel_mp"] = "iw9_lm_ahotel";
    level.mwcf_box_v1.groups["iw9_lm_ahotel_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["iw9_lm_ahotel_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["iw9_lm_ahotel_mp"] = ["rec_ahotel", "bar_lm_p03", "stock_lm_p03_ahotel", "drum_lm_p03", "pgrip_p03", "ironsdefault_ahotel", "iw9_selectsemi", "ammo_556n", "bgrip_hvy_p03", "zm_lm_ahotel"];
    level.mwcf_box_v1.refs["iw9_lm_foxtrot_mp"] = "iw9_lm_foxtrot";
    level.mwcf_box_v1.groups["iw9_lm_foxtrot_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["iw9_lm_foxtrot_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["iw9_lm_foxtrot_mp"] = ["rec_foxtrot", "bar_lm_p01", "stock_ar_p01_foxtrot", "belt_lm_p01", "pgrip_p01_foxtrot", "ironsdefault_foxtrot", "iw9_selectsemi", "ammo_556n", "zm_lm_foxtrot"];
    level.mwcf_box_v1.refs["iw9_lm_kilo21_mp"] = "iw9_lm_kilo21";
    level.mwcf_box_v1.groups["iw9_lm_kilo21_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["iw9_lm_kilo21_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["iw9_lm_kilo21_mp"] = ["rec_kilo21", "bar_lm_p02_kilo21", "stock_lm_p02_kilo21", "belt_lm_p02", "pgrip_lm_aim_p02", "ironsdefault_kilo21", "selectsemi_kilo21", "ammo_762n", "zm_lm_kilo21"];
    level.mwcf_box_v1.refs["iw9_lm_ngolf7_mp"] = "iw9_lm_ngolf7";
    level.mwcf_box_v1.groups["iw9_lm_ngolf7_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["iw9_lm_ngolf7_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["iw9_lm_ngolf7_mp"] = ["rec_ngolf7", "bar_lm_p17", "stock_lm_p17", "belt_lm_p17", "pgrip_p17", "ironsdefault_ngolf7", "ammo_762n", "zm_lm_ngolf7"];
    level.mwcf_box_v1.refs["iw9_lm_rkilo_mp"] = "iw9_lm_rkilo";
    level.mwcf_box_v1.groups["iw9_lm_rkilo_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["iw9_lm_rkilo_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["iw9_lm_rkilo_mp"] = ["rec_rkilo", "bar_lm_p04", "stock_lmg_p04_rkilo", "drum_lm_p04", "pgrip_p04", "ironsdefault_rkilo", "ammo_762s", "zm_lm_rkilo"];
    level.mwcf_box_v1.refs["iw9_lm_slima_mp"] = "iw9_lm_slima";
    level.mwcf_box_v1.groups["iw9_lm_slima_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["iw9_lm_slima_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["iw9_lm_slima_mp"] = ["rec_slima", "bar_lm_p16", "stock_lm_p16", "belt_lm_p16", "pgrip_p16", "ironsdefault_slima", "selectsemi_slima", "ammo_338nm", "zm_lm_slima"];
    level.mwcf_box_v1.refs["iw9_pi_papa220_mp"] = "iw9_pi_papa220";
    level.mwcf_box_v1.groups["iw9_pi_papa220_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_papa220_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_papa220_mp"] = ["rec_papa220", "bar_pi_p27", "mag_pi_p27", "pgrip_p27", "ironsdefault_papa220", "ammo_45acp", "hammer_sa_p27", "zm_pi_papa220"];
    level.mwcf_box_v1.refs["iw9_pi_golf17_mp"] = "iw9_pi_golf17";
    level.mwcf_box_v1.groups["iw9_pi_golf17_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_golf17_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_golf17_mp"] = ["rec_golf17", "bar_pi_p24", "stockno_pi_p24", "mag_pi_p24", "pgrip_p24", "trigger_p24", "ironsdefault_golf17", "ammo_9p", "zm_pi_golf17"];
    level.mwcf_box_v1.refs["iw9_pi_golf18_mp"] = "iw9_pi_golf18";
    level.mwcf_box_v1.groups["iw9_pi_golf18_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_golf18_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_golf18_mp"] = ["rec_golf18", "bar_sm_p24", "stockno_pi_p24", "mag_pi_p24", "pgrip_p24", "trigger_p24", "ironsdefault_golf17", "ammo_9p", "zm_pi_golf18"];
    level.mwcf_box_v1.refs["iw9_pi_decho_mp"] = "iw9_pi_decho";
    level.mwcf_box_v1.groups["iw9_pi_decho_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_decho_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_decho_mp"] = ["rec_decho", "bar_pi_p25", "stockno_pi_p25", "mag_pi_p25", "pgrip_p25", "trigger_p25", "ironsdefault_decho", "ammo_50p", "zm_pi_decho"];
    level.mwcf_box_v1.refs["iw9_pi_swhiskey_mp"] = "iw9_pi_swhiskey";
    level.mwcf_box_v1.groups["iw9_pi_swhiskey_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_swhiskey_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_swhiskey_mp"] = ["rec_swhiskey", "bar_pi_p26", "cylinder_pi_p26", "pgrip_p26", "trigger_p26", "ironsdefault_swhiskey", "ammo_500sw", "zm_pi_swhiskey"];
    level.mwcf_box_v1.refs["iw9_pi_tango9_mp"] = "iw9_pi_tango9";
    level.mwcf_box_v1.groups["iw9_pi_tango9_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_tango9_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_tango9_mp"] = ["rec_tango9", "bar_pi_p49", "stockpno_pi_heavy_p49", "mag_pi_p49", "pgrip_p49", "ironsdefault_tango9", "ammo_9p", "zm_pi_tango9"];
    level.mwcf_box_v1.refs["iw9_pi_dechoauto_mp"] = "iw9_pi_dechoauto";
    level.mwcf_box_v1.groups["iw9_pi_dechoauto_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_dechoauto_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_dechoauto_mp"] = ["rec_dechoauto", "bar_pi_p25_dechoauto", "stockno_pi_p25", "mag_pi_p25_dechoauto", "pgrip_p25_dechoauto", "trigger_p25_dechoauto", "ironsdefault_dechoauto", "ammo_50p", "zm_pi_dechoauto"];
    level.mwcf_box_v1.refs["iw9_pi_mike2011_mp"] = "iw9_pi_mike2011";
    level.mwcf_box_v1.groups["iw9_pi_mike2011_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["iw9_pi_mike2011_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["iw9_pi_mike2011_mp"] = ["rec_mike2011", "bar_pi_p55", "mag_pi_p55", "pgrip_p55", "trigger_p55", "ironsdefault_mike2011", "ammo_9p", "zm_pi_mike2011"];
    level.mwcf_box_v1.refs["iw9_sh_mbravo_mp"] = "iw9_sh_mbravo";
    level.mwcf_box_v1.groups["iw9_sh_mbravo_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["iw9_sh_mbravo_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["iw9_sh_mbravo_mp"] = ["rec_mbravo", "bartube_sh_p13", "stockr_sh_p13_mbravo", "tube_6_12g_mbravo", "guard_p13", "ironsdefault_mbravo", "ammo_12g", "zm_sh_mbravo"];
    level.mwcf_box_v1.refs["iw9_sh_mviktor_mp"] = "iw9_sh_mviktor";
    level.mwcf_box_v1.groups["iw9_sh_mviktor_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["iw9_sh_mviktor_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["iw9_sh_mviktor_mp"] = ["rec_mviktor", "bar_sh_short_p13", "stock_sh_tactical_p13_mviktor", "mag_sh_p13", "guard_p13", "ironsdefault_mviktor", "ammo_12g", "zm_sh_mviktor"];
    level.mwcf_box_v1.refs["iw9_sh_charlie725_mp"] = "iw9_sh_charlie725";
    level.mwcf_box_v1.groups["iw9_sh_charlie725_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["iw9_sh_charlie725_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["iw9_sh_charlie725_mp"] = ["iw9_rec_charlie725", "bar_sh_p14", "stockr_sh_p14", "tube_2_12g_charlie725", "guard_p14", "iw9_ironsdefault_charlie725", "trigger_sh_p14", "ammo_12g", "zm_sh_charlie725"];
    level.mwcf_box_v1.refs["iw9_sh_mike1014_mp"] = "iw9_sh_mike1014";
    level.mwcf_box_v1.groups["iw9_sh_mike1014_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["iw9_sh_mike1014_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["iw9_sh_mike1014_mp"] = ["rec_mike1014", "bar_sh_p12", "stock_sh_p12", "tube_7_12g_mike1014", "guard_p12", "pgrip_p12", "bolt_p12", "ironsdefault_mike1014", "ammo_12g", "zm_sh_mike1014"];
    level.mwcf_box_v1.refs["iw9_sh_vecho_mp"] = "iw9_sh_vecho";
    level.mwcf_box_v1.groups["iw9_sh_vecho_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["iw9_sh_vecho_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["iw9_sh_vecho_mp"] = ["rec_vecho", "bar_sh_p04", "stock_sh_light_p04_vecho", "mag_sh_p04", "pgrip_p04_vecho", "bolt_p04", "ironsdefault_vecho", "ammo_12g", "zm_sh_vecho"];
    level.mwcf_box_v1.refs["iw9_sh_tsierra12_mp"] = "iw9_sh_tsierra12";
    level.mwcf_box_v1.groups["iw9_sh_tsierra12_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["iw9_sh_tsierra12_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["iw9_sh_tsierra12_mp"] = ["rec_tsierra12", "bar_sh_p44", "stock_sh_p44", "mag_sh_p44", "pgrip_sh_p44", "trig_sh_p44", "ironsdefault_tsierra12", "ammo_12g", "zm_sh_tsierra12"];
    level.mwcf_box_v1.refs["iw9_sn_mromeo_mp"] = "iw9_sn_mromeo";
    level.mwcf_box_v1.groups["iw9_sn_mromeo_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["iw9_sn_mromeo_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["iw9_sn_mromeo_mp"] = ["rec_mromeo", "bar_sn_p21", "stock_sn_p21", "mag_sn_p21", "bolt_p21", "pgrip_p21", "snprscope_mromeo", "ammo_300nm", "zm_sn_mromeo"];
    level.mwcf_box_v1.refs["iw9_sn_alpha50_mp"] = "iw9_sn_alpha50";
    level.mwcf_box_v1.groups["iw9_sn_alpha50_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["iw9_sn_alpha50_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["iw9_sn_alpha50_mp"] = ["rec_alpha50", "bar_sn_p23", "stock_sn_p23", "mag_sn_p23", "bgrip_sn_p23", "iw9_snprscope_alpha50", "ammo_50b", "zm_sn_alpha50"];
    level.mwcf_box_v1.refs["iw9_dm_la700_mp"] = "iw9_dm_la700";
    level.mwcf_box_v1.groups["iw9_dm_la700_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_la700_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_la700_mp"] = ["rec_la700", "bar_sn_p20_la700", "stockr_sn_heavy_p20", "mag_sn_p20", "bolt_p20", "mike24_scope", "ammo_300wm", "zm_dm_la700"];
    level.mwcf_box_v1.refs["iw9_dm_xmike2010_mp"] = "iw9_dm_xmike2010";
    level.mwcf_box_v1.groups["iw9_dm_xmike2010_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_xmike2010_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_xmike2010_mp"] = ["rec_xmike2010", "bar_sn_light_p20_xmike2010", "stock_sn_p20", "mag_sn_p20_xmike2010", "bolt_p20", "pgrip_p20_xmike2010", "mike24_scope", "ammo_300wm", "zm_dm_xmike2010"];
    level.mwcf_box_v1.refs["iw9_sn_limax_mp"] = "iw9_sn_limax";
    level.mwcf_box_v1.groups["iw9_sn_limax_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["iw9_sn_limax_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["iw9_sn_limax_mp"] = ["rec_limax", "bar_sn_p22", "stock_sn_p22", "mag_sn_p22", "pgrip_p22", "limax_snprscope", "ammo_50b", "zm_sn_limax"];
    level.mwcf_box_v1.refs["iw9_sn_india_mp"] = "iw9_sn_india";
    level.mwcf_box_v1.groups["iw9_sn_india_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["iw9_sn_india_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["iw9_sn_india_mp"] = ["rec_india", "bar_sn_p53", "stock_sn_p53", "mag_sn_p53", "guard_p53", "pgrip_p53", "bolt_p53", "iw9_snprscope_india", "ammo_408c", "zm_sn_india"];
    level.mwcf_box_v1.refs["iw9_sn_walpha_mp"] = "iw9_sn_walpha";
    level.mwcf_box_v1.groups["iw9_sn_walpha_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["iw9_sn_walpha_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["iw9_sn_walpha_mp"] = ["rec_walpha", "bar_sn_p54", "stock_sn_p54", "mag_sn_p54", "guard_p54", "pgrip_p54", "snscope_walpha", "ammo_300wm", "zm_sn_walpha"];
    level.mwcf_box_v1.refs["iw9_dm_mike14_mp"] = "iw9_dm_mike14";
    level.mwcf_box_v1.groups["iw9_dm_mike14_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_mike14_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_mike14_mp"] = ["iw9_rec_mike14", "bar_dm_p18_mike14", "stock_dm_light_p18_mike14", "mag_sn_p18", "pgrip_dm_p18", "iw9_ironsdefault_mike14", "ammo_762n", "zm_dm_mike14"];
    level.mwcf_box_v1.refs["iw9_dm_mike24_mp"] = "iw9_dm_mike24";
    level.mwcf_box_v1.groups["iw9_dm_mike24_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_mike24_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_mike24_mp"] = ["rec_mike24", "bar_dm_p20_mike24", "stockr_dm_p20", "mag_dm_p20_mike24", "bolt_p20", "ironsdefault_mike24", "ammo_762n", "zm_dm_mike24"];
    level.mwcf_box_v1.refs["iw9_dm_sbeta_mp"] = "iw9_dm_sbeta";
    level.mwcf_box_v1.groups["iw9_dm_sbeta_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_sbeta_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_sbeta_mp"] = ["iw9_rec_sbeta", "bar_dm_p19", "stockr_dm_p19", "tube_6_45gvt", "guard_p19", "lever_p19", "iw9_ironsdefault_sbeta", "ammo_45gvt", "zm_dm_sbeta"];
    level.mwcf_box_v1.refs["iw9_dm_pgolf1_mp"] = "iw9_dm_pgolf1";
    level.mwcf_box_v1.groups["iw9_dm_pgolf1_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_pgolf1_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_pgolf1_mp"] = ["rec_pgolf1", "bar_sn_p02", "stock_sn_p02_pgolf1", "mag_sn_p02_pgolf1", "pgrip_dm_snp_p02", "ironsdefault_pgolf1", "ammo_762n", "zm_dm_pgolf1"];
    level.mwcf_box_v1.refs["iw9_dm_sa700_mp"] = "iw9_dm_sa700";
    level.mwcf_box_v1.groups["iw9_dm_sa700_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_sa700_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_sa700_mp"] = ["rec_sa700", "bar_dm_short_p20_sa700", "stock_dm_p20", "mag_dm_large_p20_sa700", "pgrip_p20_sa700", "bolt_p20", "ironsdefault_sa700", "ammo_308w", "zm_dm_sa700"];
    level.mwcf_box_v1.refs["iw9_dm_scromeo_mp"] = "iw9_dm_scromeo";
    level.mwcf_box_v1.groups["iw9_dm_scromeo_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_scromeo_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_scromeo_mp"] = ["rec_scromeo", "bar_sn_p05", "stock_sn_p05_scromeo", "mag_sn_p05", "pgrip_p05", "ironsdefault_scromeo", "ammo_65cm", "zm_dm_scromeo"];
    level.mwcf_box_v1.refs["iw9_dm_stango25_mp"] = "iw9_dm_stango25";
    level.mwcf_box_v1.groups["iw9_dm_stango25_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_stango25_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_stango25_mp"] = ["rec_stango25", "bar_dm_p01", "stock_dm_p01_stango25", "mag_dm_p01", "guard_p01", "pgrip_p01", "ironsdefault_stango25", "ammo_762n", "zm_dm_stango25"];
    level.mwcf_box_v1.refs["iw9_ar_golf3_mp"] = "iw9_ar_golf3";
    level.mwcf_box_v1.groups["iw9_ar_golf3_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_golf3_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_golf3_mp"] = ["rec_golf3", "bar_br_p02_golf3", "stock_ar_p02_golf3", "mag_br_p02_golf3", "pgrip_br_p02", "ironsdefault_golf3", "selectauto_golf3", "ammo_762n", "zm_br_golf3"];
    level.mwcf_box_v1.refs["iw9_ar_schotel_mp"] = "iw9_ar_schotel";
    level.mwcf_box_v1.groups["iw9_ar_schotel_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_ar_schotel_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_ar_schotel_mp"] = ["rec_schotel", "bar_br_p05", "stock_ar_p05_schotel", "mag_br_p05", "pgrip_p05", "ironsdefault_schotel", "selectsemi_schotel", "ammo_762n", "zm_ar_schotel"];
    level.mwcf_box_v1.refs["iw9_br_msecho_mp"] = "iw9_br_msecho";
    level.mwcf_box_v1.groups["iw9_br_msecho_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_br_msecho_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_br_msecho_mp"] = ["rec_msecho", "bar_ar_p01_msecho", "stock_sn_p01_msecho", "mag_br_p01", "pgrip_p01", "ironsdefault_msecho", "selectauto_msecho", "ammo_458s", "zm_br_msecho"];
    level.mwcf_box_v1.refs["iw9_br_ngsierra_mp"] = "iw9_br_ngsierra";
    level.mwcf_box_v1.groups["iw9_br_ngsierra_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_br_ngsierra_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_br_ngsierra_mp"] = ["rec_ngsierra", "bar_br_p42", "stock_br_p42", "mag_br_p42", "comb_p42", "pgrip_p42", "ironsdefault_ngsierra", "selectsemi_ngsierra", "ammo_277f", "zm_br_ngsierra"];
    level.mwcf_box_v1.refs["iw9_br_soscar14_mp"] = "iw9_br_soscar14";
    level.mwcf_box_v1.groups["iw9_br_soscar14_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["iw9_br_soscar14_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["iw9_br_soscar14_mp"] = ["rec_soscar14", "bar_br_p18_soscar14", "stockr_dm_p18_soscar14", "mag_br_p18_soscar14", "ironsdefault_soscar14", "selectauto_soscar", "ammo_762n", "zm_br_soscar14"];
    level.mwcf_box_v1.refs["iw9_dm_crossbow_mp"] = "iw9_dm_crossbow";
    level.mwcf_box_v1.groups["iw9_dm_crossbow_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["iw9_dm_crossbow_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["iw9_dm_crossbow_mp"] = ["iw9_rec_crossbow", "bar_dm_p38", "stock_dm_p38", "mag_dm_p38", "bgrip_p38", "wire_dm_p38", "iw9_ironsdefault_crossbow", "ammo_bolt_std", "zm_dm_crossbow"];
    level.mwcf_box_v1.refs["iw9_la_gromeo_mp"] = "iw9_la_gromeo";
    level.mwcf_box_v1.groups["iw9_la_gromeo_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["iw9_la_gromeo_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["iw9_la_gromeo_mp"] = ["rec_gromeo", "iw9_lnchrscope_gromeo", "dynamic_null_gromeo", "zm_la_gromeo"];
    level.mwcf_box_v1.refs["iw9_la_kgolf_mp"] = "iw9_la_kgolf";
    level.mwcf_box_v1.groups["iw9_la_kgolf_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["iw9_la_kgolf_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["iw9_la_kgolf_mp"] = ["rec_kgolf", "iw9_lnchrscope_kgolf", "zm_la_kgolf"];
    level.mwcf_box_v1.refs["iw9_la_juliet_mp"] = "iw9_la_juliet";
    level.mwcf_box_v1.groups["iw9_la_juliet_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["iw9_la_juliet_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["iw9_la_juliet_mp"] = ["rec_juliet", "iw9_lnchrscope_juliet", "dynamic_null_juliette", "zm_la_juliet"];
    level.mwcf_box_v1.refs["iw9_la_rpapa7_mp"] = "iw9_la_rpapa7";
    level.mwcf_box_v1.groups["iw9_la_rpapa7_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["iw9_la_rpapa7_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["iw9_la_rpapa7_mp"] = ["rec_rpapa7", "dynamic_null_rpapa7", "zm_la_rpapa7"];
    level.mwcf_box_v1.refs["iw9_la_mike32_mp"] = "iw9_la_mike32";
    level.mwcf_box_v1.groups["iw9_la_mike32_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["iw9_la_mike32_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["iw9_la_mike32_mp"] = ["rec_mike32", "iw9_lnchrscope_mike32", "dynamic_null_mike32", "zm_la_mike32"];
    level.mwcf_box_v1.refs["iw9_me_knife_mp"] = "iw9_me_knife";
    level.mwcf_box_v1.groups["iw9_me_knife_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["iw9_me_knife_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["iw9_me_knife_mp"] = ["zm_me_iw9_knife"];
    level.mwcf_box_v1.refs["iw9_me_sword01_mp"] = "iw9_me_sword01";
    level.mwcf_box_v1.groups["iw9_me_sword01_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["iw9_me_sword01_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["iw9_me_sword01_mp"] = ["iw9_me_sword01", "zm_me_sword01"];
    level.mwcf_box_v1.refs["iw9_me_tonfa_mp"] = "iw9_me_tonfa";
    level.mwcf_box_v1.groups["iw9_me_tonfa_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["iw9_me_tonfa_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["iw9_me_tonfa_mp"] = ["rec_tonfa", "zm_me_tonfa"];
    level.mwcf_box_v1.refs["iw9_me_pickaxe_mp"] = "iw9_me_pickaxe";
    level.mwcf_box_v1.groups["iw9_me_pickaxe_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["iw9_me_pickaxe_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["iw9_me_pickaxe_mp"] = ["rec_pickaxe", "zm_me_jup_pickaxe"];
    level.mwcf_box_v1.refs["iw9_me_kamas_mp"] = "iw9_me_kamas";
    level.mwcf_box_v1.groups["iw9_me_kamas_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["iw9_me_kamas_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["iw9_me_kamas_mp"] = ["rec_kamas", "zm_me_kamas"];
    level.mwcf_box_v1.refs["jup_cp06_ar_falpha_mp"] = "jup_cp06_ar_falpha";
    level.mwcf_box_v1.groups["jup_cp06_ar_falpha_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_cp06_ar_falpha_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_cp06_ar_falpha_mp"] = ["jup_falpha_rec", "jup_cp06_ar_falpha_bar", "jup_cp06_ar_falpha_stock_heavy", "jup_cp06_ar_falpha_mag", "jup_cp06_ar_falpha_comb", "jup_cp06_ar_falpha_pgrip", "jup_falpha_ironsdefault", "jup_selectburst_single", "ammo_556n", "rail_ar_large_p06", "zm_ar_falpha"];
    level.mwcf_box_v1.refs["jup_cp08_br_xmike5_mp"] = "jup_cp08_br_xmike5";
    level.mwcf_box_v1.groups["jup_cp08_br_xmike5_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_cp08_br_xmike5_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_cp08_br_xmike5_mp"] = ["jup_xmike5_rec", "jup_cp08_br_xmike5_bar", "jup_cp08_br_xmike5_stock", "jup_cp08_br_xmike5_mag_20_277f", "jup_cp08_br_xmike5_pgrip", "jup_xmike5_ironsdefault", "jup_xmike5_selectsemi", "jup_ammo_277f", "zm_br_xmike5"];
    level.mwcf_box_v1.refs["jup_jp01_ar_golf36_mp"] = "jup_jp01_ar_golf36";
    level.mwcf_box_v1.groups["jup_jp01_ar_golf36_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp01_ar_golf36_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp01_ar_golf36_mp"] = ["jup_golf36_rec", "jup_jp01_ar_golf36_bar", "jup_jp01_ar_golf36_stock_tac", "jup_jp01_ar_golf36_mag_30_556n", "jup_jp01_ar_golf36_pgrip", "jup_golf36_ironsdefault", "iw9_selectsemi", "ammo_556n", "zm_ar_golf36"];
    level.mwcf_box_v1.refs["jup_jp02_ar_bromeo805_mp"] = "jup_jp02_ar_bromeo805";
    level.mwcf_box_v1.groups["jup_jp02_ar_bromeo805_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp02_ar_bromeo805_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp02_ar_bromeo805_mp"] = ["jup_bromeo805_rec", "jup_jp02_ar_bromeo805_bar", "jup_jp02_ar_bromeo805_stock_folding", "jup_jp02_ar_bromeo805_mag_30_556n", "jup_jp02_ar_bromeo805_pgrip", "jup_bromeo805_ironsdefault", "iw9_selectsemi", "ammo_556n", "zm_ar_bromeo805"];
    level.mwcf_box_v1.refs["jup_jp02_br_bromeo2_mp"] = "jup_jp02_br_bromeo2";
    level.mwcf_box_v1.groups["jup_jp02_br_bromeo2_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp02_br_bromeo2_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp02_br_bromeo2_mp"] = ["jup_bromeo2_rec", "jup_jp02_br_bromeo2_bar_heavy_xlong", "jup_jp02_br_bromeo2_stock_heavy", "jup_jp02_br_bromeo2_mag_20_762n", "jup_jp02_br_bromeo2_pgrip_ass", "jup_bromeo2_ironsdefault", "jup_bromeo2_selectauto", "ammo_762n", "zm_br_bromeo2"];
    level.mwcf_box_v1.refs["jup_jp03_br_aromeo200_mp"] = "jup_jp03_br_aromeo200";
    level.mwcf_box_v1.groups["jup_jp03_br_aromeo200_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp03_br_aromeo200_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp03_br_aromeo200_mp"] = ["jup_aromeo200_rec", "jup_jp03_br_aromeo200_bar", "jup_jp03_br_aromeo200_stock", "jup_jp03_br_aromeo200_mag_20_762n", "jup_jp03_pgrip", "jup_aromeo200_ironsdefault", "jup_aromeo200_selectsemi", "ammo_762n", "zm_br_aromeo200"];
    level.mwcf_box_v1.refs["jup_jp05_ar_foxtrot2000_mp"] = "jup_jp05_ar_foxtrot2000";
    level.mwcf_box_v1.groups["jup_jp05_ar_foxtrot2000_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp05_ar_foxtrot2000_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp05_ar_foxtrot2000_mp"] = ["jup_foxtrot2000_rec", "jup_jp05_ar_foxtrot2000_bar", "jup_jp05_ar_foxtrot2000_stock", "jup_jp05_ar_foxtrot2000_mag_30_556n", "jup_jp05_ar_foxtrot2000_pgrip", "jup_foxtrot2000_ironsdefault", "iw9_selectsemi", "ammo_556n", "zm_ar_f2000"];
    level.mwcf_box_v1.refs["jup_jp08_ar_qbravo97_mp"] = "jup_jp08_ar_qbravo97";
    level.mwcf_box_v1.groups["jup_jp08_ar_qbravo97_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp08_ar_qbravo97_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp08_ar_qbravo97_mp"] = ["jup_qbravo97_rec", "jup_jp08_ar_qbravo97_bar", "jup_jp08_ar_qbravo97_stock", "jup_jp08_ar_qbravo97_mag_30_556n", "jup_jp08_ar_qbravo97_pgrip", "jup_qbravo97_ironsdefault", "jup_selectburst_single", "jup_ammo_556n", "zm_ar_qbravo97"];
    level.mwcf_box_v1.refs["jup_jp19_ar_acharlie_mp"] = "jup_jp19_ar_acharlie";
    level.mwcf_box_v1.groups["jup_jp19_ar_acharlie_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp19_ar_acharlie_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp19_ar_acharlie_mp"] = ["jup_acharlie_rec", "jup_jp19_ar_acharlie_bar", "jup_jp19_ar_acharlie_stock_assault", "jup_jp19_ar_acharlie_mag_30_556n", "jup_jp19_ar_acharlie_pgrip", "jup_acharlie_ironsdefault", "iw9_selectsemi", "ammo_556n", "zm_ar_acharlie"];
    level.mwcf_box_v1.refs["jup_jp19_br_acharlie450_mp"] = "jup_jp19_br_acharlie450";
    level.mwcf_box_v1.groups["jup_jp19_br_acharlie450_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp19_br_acharlie450_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp19_br_acharlie450_mp"] = ["jup_acharlie450_rec", "jup_jp19_br_acharlie450_bar_hvylong2", "jup_jp19_br_acharlie450_stock_assault", "jup_jp19_br_acharlie450_mag_20_450b", "jup_jp19_br_acharlie450_pgrip_ass", "jup_acharlie450_ironsdefault", "jup_acharlie450_selectauto", "jup_ammo_450b", "zm_br_acharlie450"];
    level.mwcf_box_v1.refs["jup_jp25_ar_talpha95_mp"] = "jup_jp25_ar_talpha95";
    level.mwcf_box_v1.groups["jup_jp25_ar_talpha95_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp25_ar_talpha95_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp25_ar_talpha95_mp"] = ["jup_talpha95_rec", "jup_jp25_ar_talpha95_bar", "jup_jp25_ar_talpha95_stock", "jup_jp25_ar_talpha95_mag_30_556n", "jup_jp25_pgrip", "jup_talpha95_ironsdefault", "iw9_selectsemi", "ammo_556n", "zm_ar_talpha95"];
    level.mwcf_box_v1.refs["jup_jp34_ar_balpha27_mp"] = "jup_jp34_ar_balpha27";
    level.mwcf_box_v1.groups["jup_jp34_ar_balpha27_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp34_ar_balpha27_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp34_ar_balpha27_mp"] = ["jup_balpha27_rec", "jup_jp34_ar_balpha27_bar", "jup_jp34_ar_balpha27_stock", "jup_jp25_ar_balpha27_mag", "jup_jp34_pgrip", "jup_balpha27_ironsdefault", "ammo_5x28", "zm_ar_balpha27"];
    level.mwcf_box_v1.refs["jup_jp36_ar_anov94_mp"] = "jup_jp36_ar_anov94";
    level.mwcf_box_v1.groups["jup_jp36_ar_anov94_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp36_ar_anov94_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp36_ar_anov94_mp"] = ["jup_anov94_rec", "jup_jp36_ar_anov94_bar_heavy", "jup_jp36_ar_anov94_stock_comptac", "jup_jp36_ar_anov94_mag_30_545", "jup_jp36_ar_anov94_pgrip", "jup_anov94_ironsdefault", "iw9_selectsemi", "ammo_545s", "zm_ar_anov94"];
    level.mwcf_box_v1.refs["jup_jp40_br_hcharlie36_mp"] = "jup_jp40_br_hcharlie36";
    level.mwcf_box_v1.groups["jup_jp40_br_hcharlie36_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp40_br_hcharlie36_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp40_br_hcharlie36_mp"] = ["jup_hcharlie36_rec", "jup_jp40_br_hcharlie36_bar", "jup_jp40_br_hcharlie36_stock", "jup_jp40_br_hcharlie36_mag_20_36s", "jup_jp40_br_hcharlie36_pgrip", "jup_hcharlie36_ironsdefault", "iw9_selectsemi", "jup_ammo_30_06"];
    level.mwcf_box_v1.refs["jup_jp44_ar_stango44_mp"] = "jup_jp44_ar_stango44";
    level.mwcf_box_v1.groups["jup_jp44_ar_stango44_mp"] = "weapon_assault";
    level.mwcf_box_v1.likes["jup_jp44_ar_stango44_mp"] = "sat_ar_kiwi";
    level.mwcf_box_v1.parts["jup_jp44_ar_stango44_mp"] = ["jup_stango44_rec", "jup_jp44_ar_stango44_bar", "jup_jp44_ar_stango44_stock", "jup_jp44_ar_stango44_mag_30", "jup_jp44_ar_stango44_pgrip", "jup_stango44_ironsdefault", "iw9_selectsemi", "jup_ammo_792"];
    level.mwcf_box_v1.refs["jup_jp01_dm_slima8_mp"] = "jup_jp01_dm_slima8";
    level.mwcf_box_v1.groups["jup_jp01_dm_slima8_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp01_dm_slima8_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp01_dm_slima8_mp"] = ["jup_slima8_rec", "jup_jp01_dm_slima8_bar_heavy_long", "jup_jp01_dm_slima8_stock_marksman_padded", "jup_jp01_dm_slima8_mag_20_556n", "jup_jp01_dm_slima8_comb_default", "jup_slima8_ironsdefault", "ammo_556n", "zm_dm_slima8"];
    level.mwcf_box_v1.refs["jup_jp02_dm_bromeop_mp"] = "jup_jp02_dm_bromeop";
    level.mwcf_box_v1.groups["jup_jp02_dm_bromeop_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp02_dm_bromeop_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp02_dm_bromeop_mp"] = ["jup_bromeop_rec", "jup_jp02_dm_bromeop_bar_precision", "jup_jp02_dm_bromeop_stock_precision", "jup_jp02_dm_bromeop_mag_10_762n", "jup_jp02_dm_bromeop_pgrip_aim", "jup_bromeop_ironsdefault", "ammo_762n", "zm_dm_bromeop"];
    level.mwcf_box_v1.refs["jup_jp10_sn_cdelta50_mp"] = "jup_jp10_sn_cdelta50";
    level.mwcf_box_v1.groups["jup_jp10_sn_cdelta50_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["jup_jp10_sn_cdelta50_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["jup_jp10_sn_cdelta50_mp"] = ["jup_cdelta50_rec", "jup_jp10_sn_cdelta50_bar_hvylong", "jup_jp10_sn_cdelta50_stock_skel", "jup_jp10_sn_cdelta50_mag_5_50b", "jup_jp10_sn_cdelta50_guard", "jup_jp10_sn_cdelta50_pgrip_ass", "jup_jp10_sn_cdelta50_bolt", "jup_cdelta50_scope", "ammo_50b", "zm_sn_cdelta50"];
    level.mwcf_box_v1.refs["jup_jp13_dm_svictork_mp"] = "jup_jp13_dm_svictork";
    level.mwcf_box_v1.groups["jup_jp13_dm_svictork_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp13_dm_svictork_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp13_dm_svictork_mp"] = ["jup_svictork_rec", "jup_jp13_dm_svictork_bar", "jup_jp13_dm_svictork_stock_tac", "jup_jp13_dm_svictork_mag_10_762r", "jup_jp13_dm_svictork_pgrip", "jup_svictork_ironsdefault", "jup_ammo_762r", "zm_dm_svictork"];
    level.mwcf_box_v1.refs["jup_jp13_sn_svictor_mp"] = "jup_jp13_sn_svictor";
    level.mwcf_box_v1.groups["jup_jp13_sn_svictor_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["jup_jp13_sn_svictor_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["jup_jp13_sn_svictor_mp"] = ["jup_svictor_rec", "jup_jp13_sn_svictor_bar", "jup_jp13_sn_svictor_stock_mm", "jup_jp13_sn_svictor_mag_10_338lmp", "jup_jp13_sn_svictor_pgrip", "jup_svictor_scope", "jup_ammo_338lp", "zm_sn_svictor"];
    level.mwcf_box_v1.refs["jup_jp17_sn_hsierra_mp"] = "jup_jp17_sn_hsierra";
    level.mwcf_box_v1.groups["jup_jp17_sn_hsierra_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["jup_jp17_sn_hsierra_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["jup_jp17_sn_hsierra_mp"] = ["jup_hsierra_rec", "jup_jp17_sn_hsierra_bar", "jup_jp17_sn_hsierra_stock", "jup_jp17_sn_hsierra_mag_5_50b", "jup_jp17_sn_hsierra_bolt", "jup_jp17_sn_hsierra_pgrip", "jup_hsierra_scope", "jup_hsierra_bipod", "ammo_50b", "zm_sn_hsierra"];
    level.mwcf_box_v1.refs["jup_jp19_dm_acharlied_mp"] = "jup_jp19_dm_acharlied";
    level.mwcf_box_v1.groups["jup_jp19_dm_acharlied_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp19_dm_acharlied_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp19_dm_acharlied_mp"] = ["jup_acharlied_rec", "jup_jp19_dm_acharlied_bar_hvymarksman", "jup_jp19_dm_acharlied_stock_heavy", "jup_jp19_dm_acharlied_mag_10_68r", "jup_jp19_dm_acharlied_pgrip_snp", "jup_acharlied_ironsdefault", "jup_ammo_68r", "zm_dm_acharlied"];
    level.mwcf_box_v1.refs["jup_jp31_dm_compound_mp"] = "jup_jp31_dm_compound";
    level.mwcf_box_v1.groups["jup_jp31_dm_compound_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp31_dm_compound_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp31_dm_compound_mp"] = ["jup_compound_rec", "jup_reflex_compound", "jup_ammo_arrow_std"];
    level.mwcf_box_v1.refs["jup_jp35_sn_moscar_mp"] = "jup_jp35_sn_moscar";
    level.mwcf_box_v1.groups["jup_jp35_sn_moscar_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["jup_jp35_sn_moscar_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["jup_jp35_sn_moscar_mp"] = ["jup_moscar_rec", "jup_jp35_sn_moscar_bar", "jup_jp35_sn_moscar_stock", "jup_jp35_sn_moscar_bolt", "jup_jp35_sn_moscar_pgrip", "jup_moscar_bipod", "jup_moscar_scope", "jup_ammo_rail_std", "zm_sn_moscar"];
    level.mwcf_box_v1.refs["jup_jp36_sn_boscar_mp"] = "jup_jp36_sn_boscar";
    level.mwcf_box_v1.groups["jup_jp36_sn_boscar_mp"] = "weapon_sniper";
    level.mwcf_box_v1.likes["jup_jp36_sn_boscar_mp"] = "sat_sn_aden";
    level.mwcf_box_v1.parts["jup_jp36_sn_boscar_mp"] = ["jup_rec_boscar", "jup_jp36_sn_boscar_bar", "jup_jp36_sn_boscar_stock_ass", "jup_jp36_sn_boscar_mag_30_762s", "jup_jp36_sn_boscar_bolt", "jup_jp36_sn_boscar_pgrip", "jup_boscar_scope", "ammo_762s", "zm_sn_boscar"];
    level.mwcf_box_v1.refs["jup_jp37_dm_kappa98_mp"] = "jup_jp37_dm_kappa98";
    level.mwcf_box_v1.groups["jup_jp37_dm_kappa98_mp"] = "weapon_dmr";
    level.mwcf_box_v1.likes["jup_jp37_dm_kappa98_mp"] = "sat_dm_kara";
    level.mwcf_box_v1.parts["jup_jp37_dm_kappa98_mp"] = ["jup_kappa98_rec", "jup_jp37_dm_kappa98_bar", "jup_jp37_dm_kappa98_stock", "jup_jp37_dm_kappa98_mag_stripper", "jup_jp37_dm_kappa98_irons", "jup_ammo_8mm", "zm_dm_kappa98"];
    level.mwcf_box_v1.refs["jup_cp01_sh_aromeo410_mp"] = "jup_cp01_sh_aromeo410";
    level.mwcf_box_v1.groups["jup_cp01_sh_aromeo410_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["jup_cp01_sh_aromeo410_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["jup_cp01_sh_aromeo410_mp"] = ["jup_aromeo410_rec", "jup_cp01_sh_aromeo410_bar", "jup_cp01_sh_aromeo410_stock", "jup_cp01_sh_aromeo410_mag_16_410g", "jup_cp01_sh_aromeo410_pgrip", "jup_aromeo410_ironsdefault", "jup_ammo_410g", "zm_sh_aromeo410"];
    level.mwcf_box_v1.refs["jup_cp05_lm_halpha_mp"] = "jup_cp05_lm_halpha";
    level.mwcf_box_v1.groups["jup_cp05_lm_halpha_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_cp05_lm_halpha_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_cp05_lm_halpha_mp"] = ["jup_rec_halpha", "jup_cp05_lm_halpha_bar", "jup_cp05_lm_halpha_stock", "jup_cp05_lm_halpha_drum_75_762n", "jup_cp05_lm_halpha_pgrip", "ironsdefault_schotel", "selectsemi_schotel", "ammo_762n", "zm_lm_halpha"];
    level.mwcf_box_v1.refs["jup_cp15_lm_mkilo3_mp"] = "jup_cp15_lm_mkilo3";
    level.mwcf_box_v1.groups["jup_cp15_lm_mkilo3_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_cp15_lm_mkilo3_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_cp15_lm_mkilo3_mp"] = ["jup_mkilo3_rec", "jup_cp15_lm_mkilo3_bar_sm", "jup_cp15_lm_mkilo3_stock_heavy", "jup_cp15_lm_mkilo3_belt", "jup_cp15_lm_mkilo3_pgrip", "jup_mkilo3_ironsdefault", "ammo_556n", "zm_lm_mkilo3"];
    level.mwcf_box_v1.refs["jup_jp01_lm_mgolf36_mp"] = "jup_jp01_lm_mgolf36";
    level.mwcf_box_v1.groups["jup_jp01_lm_mgolf36_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_jp01_lm_mgolf36_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_jp01_lm_mgolf36_mp"] = ["jup_mgolf36_rec", "jup_jp01_lm_mgolf36_bar_short_heavy", "jup_jp01_lm_mgolf36_stock_tacheavy", "jup_jp01_lm_mgolf36_drum_50_556n", "jup_jp01_lm_mgolf36_pgrip", "jup_mgolf36_ironsdefault", "iw9_selectsemi", "ammo_556n", "zm_lm_mgolf36"];
    level.mwcf_box_v1.refs["jup_jp06_lm_pkilop_mp"] = "jup_jp06_lm_pkilop";
    level.mwcf_box_v1.groups["jup_jp06_lm_pkilop_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_jp06_lm_pkilop_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_jp06_lm_pkilop_mp"] = ["jup_pkilop_rec", "jup_jp06_lm_pkilop_bar", "jup_jp06_lm_pkilop_stock_heavy", "jup_jp06_lm_pkilop_belt_100_762n", "jup_jp06_lm_pkilop_pgrip", "jup_pkilop_ironsdefault", "jup_ammo_762r", "zm_lm_pkilop"];
    level.mwcf_box_v1.refs["jup_jp08_lm_qbravo95lsw_mp"] = "jup_jp08_lm_qbravo95lsw";
    level.mwcf_box_v1.groups["jup_jp08_lm_qbravo95lsw_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_jp08_lm_qbravo95lsw_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_jp08_lm_qbravo95lsw_mp"] = ["jup_qbravo95lsw_rec", "jup_jp08_lm_qbravo95lsw_bar", "jup_jp08_lm_qbravo95lsw_stock_padded", "jup_jp08_lm_qbravo95lsw_drum_60_58h", "jup_jp08_lm_qbravo95lsw_pgrip", "jup_qbravo95lsw_ironsdefault", "iw9_selectsemi", "jup_ammo_58h", "zm_lm_qbravo95lsw"];
    level.mwcf_box_v1.refs["jup_jp09_sh_oromeo12_mp"] = "jup_jp09_sh_oromeo12";
    level.mwcf_box_v1.groups["jup_jp09_sh_oromeo12_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["jup_jp09_sh_oromeo12_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["jup_jp09_sh_oromeo12_mp"] = ["jup_oromeo12_rec", "jup_jp09_sh_oromeo12_bar", "jup_jp09_sh_oromeo12_stock", "jup_jp09_sh_oromeo12_mag_8_12g", "jup_jp09_sh_oromeo12_pgrip", "jup_oromeo12_ironsdefault", "ammo_12g", "zm_sh_oromeo12"];
    level.mwcf_box_v1.refs["jup_jp16_sh_recho870_mp"] = "jup_jp16_sh_recho870";
    level.mwcf_box_v1.groups["jup_jp16_sh_recho870_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["jup_jp16_sh_recho870_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["jup_jp16_sh_recho870_mp"] = ["jup_recho870_rec", "jup_jp16_sh_recho870_bartube", "jup_jp16_sh_recho870_stock", "jup_jp16_sh_recho870_tube_6_12g", "jup_jp16_sh_recho870_guard", "jup_recho870_ironsdefault", "jup_jp16_sh_recho870_bolt", "ammo_12g", "zm_sh_recho870"];
    level.mwcf_box_v1.refs["jup_jp20_lm_evictor_mp"] = "jup_jp20_lm_evictor";
    level.mwcf_box_v1.groups["jup_jp20_lm_evictor_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_jp20_lm_evictor_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_jp20_lm_evictor_mp"] = ["jup_evictor_rec", "jup_jp20_lm_evictor_bar_short", "jup_jp20_lm_evictor_stock", "jup_jp20_lm_evictor_belt_100_762n", "jup_jp20_lm_evictor_pgrip", "jup_evictor_ironsdefault", "jup_selectsemi", "ammo_762n", "zm_lm_evictor"];
    level.mwcf_box_v1.refs["jup_jp28_lm_rpapa20_mp"] = "jup_jp28_lm_rpapa20";
    level.mwcf_box_v1.groups["jup_jp28_lm_rpapa20_mp"] = "weapon_lmg";
    level.mwcf_box_v1.likes["jup_jp28_lm_rpapa20_mp"] = "sat_lm_hades";
    level.mwcf_box_v1.parts["jup_jp28_lm_rpapa20_mp"] = ["jup_rec_rpapa20", "jup_jp28_lm_rpapa20_bar", "jup_jp28_lm_rpapa20_stock", "jup_jp28_lm_rpapa20_belt_100_545", "jup_jp28_lm_rpapa20_pgrip", "jup_rpapa20_ironsdefault", "ammo_545s"];
    level.mwcf_box_v1.refs["jup_jp38_sh_spapa12_mp"] = "jup_jp38_sh_spapa12";
    level.mwcf_box_v1.groups["jup_jp38_sh_spapa12_mp"] = "weapon_shotgun";
    level.mwcf_box_v1.likes["jup_jp38_sh_spapa12_mp"] = "sat_sh_akita";
    level.mwcf_box_v1.parts["jup_jp38_sh_spapa12_mp"] = ["jup_spapa12_rec", "jup_jp38_sh_spapa12_bar", "jup_jp38_sh_spapa12_stock", "jup_jp38_sh_spapa12_tube_std_12g", "jup_jp38_sh_spapa12_pgrip", "jup_jp38_sh_spapa12_irons", "jup_spapa12_selectsemi", "ammo_12g", "zm_sh_spapa12"];
    level.mwcf_box_v1.refs["jup_jp23_me_kalpha_mp"] = "jup_jp23_me_kalpha";
    level.mwcf_box_v1.groups["jup_jp23_me_kalpha_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["jup_jp23_me_kalpha_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["jup_jp23_me_kalpha_mp"] = ["jup_me_kalpha", "zm_me_kalpha"];
    level.mwcf_box_v1.refs["jup_jp23_me_pdango_mp"] = "jup_jp23_me_pdango";
    level.mwcf_box_v1.groups["jup_jp23_me_pdango_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["jup_jp23_me_pdango_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["jup_jp23_me_pdango_mp"] = ["jup_me_pdango", "zm_me_pdango"];
    level.mwcf_box_v1.refs["jup_jp23_me_shotel_mp"] = "jup_jp23_me_shotel";
    level.mwcf_box_v1.groups["jup_jp23_me_shotel_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["jup_jp23_me_shotel_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["jup_jp23_me_shotel_mp"] = ["jup_me_shotel", "zm_me_shotel"];
    level.mwcf_box_v1.refs["jup_jp23_me_spear_mp"] = "jup_jp23_me_spear";
    level.mwcf_box_v1.groups["jup_jp23_me_spear_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["jup_jp23_me_spear_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["jup_jp23_me_spear_mp"] = ["jup_me_spear", "jup_axefist"];
    level.mwcf_box_v1.refs["jup_jp23_me_swhiskey_mp"] = "jup_jp23_me_swhiskey";
    level.mwcf_box_v1.groups["jup_jp23_me_swhiskey_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["jup_jp23_me_swhiskey_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["jup_jp23_me_swhiskey_mp"] = ["jup_jp23_me_swhiskey_rec", "zm_me_jup_swhiskey"];
    level.mwcf_box_v1.refs["jup_me_glassshiv_mp"] = "jup_me_glassshiv";
    level.mwcf_box_v1.groups["jup_me_glassshiv_mp"] = "weapon_melee";
    level.mwcf_box_v1.likes["jup_me_glassshiv_mp"] = "sat_me_knife";
    level.mwcf_box_v1.parts["jup_me_glassshiv_mp"] = ["zm_me_glass_shiv"];
    level.mwcf_box_v1.refs["jup_cp24_pi_glima21_mp"] = "jup_cp24_pi_glima21";
    level.mwcf_box_v1.groups["jup_cp24_pi_glima21_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["jup_cp24_pi_glima21_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["jup_cp24_pi_glima21_mp"] = ["jup_glima21_rec", "jup_cp24_pi_glima21_bar", "jup_cp24_pi_glima21_mag_13_45acp", "jup_cp24_pi_glima21_trigger", "jup_glima21_ironsdefault", "ammo_45acp", "zm_pi_glima21"];
    level.mwcf_box_v1.refs["jup_jp07_pi_uzulum_mp"] = "jup_jp07_pi_uzulum";
    level.mwcf_box_v1.groups["jup_jp07_pi_uzulum_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["jup_jp07_pi_uzulum_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["jup_jp07_pi_uzulum_mp"] = ["jup_uzulum_rec", "jup_jp07_pi_uzulum_bar_short", "jup_jp07_pi_uzulum_stockno", "jup_jp07_pi_uzulum_mag_20_9mm", "jup_jp07_pi_uzulum_pgrip", "jup_uzulum_ironsdefault", "ammo_9p", "zm_pi_uzulum"];
    level.mwcf_box_v1.refs["jup_jp12_pi_mike93_mp"] = "jup_jp12_pi_mike93";
    level.mwcf_box_v1.groups["jup_jp12_pi_mike93_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["jup_jp12_pi_mike93_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["jup_jp12_pi_mike93_mp"] = ["jup_mike93_rec", "jup_jp12_pi_mike93_bar", "jup_jp12_pi_mike93_stockno", "jup_jp12_pi_mike93_mag_15_9mm", "jup_jp12_pi_mike93_pgrip", "jup_jp12_pi_mike93_trigger", "jup_mike93_ironsdefault", "ammo_9p", "zm_pi_mike93"];
    level.mwcf_box_v1.refs["jup_jp14_pi_rsierra12_mp"] = "jup_jp14_pi_rsierra12";
    level.mwcf_box_v1.groups["jup_jp14_pi_rsierra12_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["jup_jp14_pi_rsierra12_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["jup_jp14_pi_rsierra12_mp"] = ["jup_rsierra12_rec", "jup_jp14_pi_rsierra12_bar", "jup_jp14_pi_rsierra12_cylinder_5_12", "jup_jp14_pi_rsierra12_pgrip", "jup_jp14_pi_rsierra12_trigger", "jup_rsierra12_ironsdefault", "jup_ammo_127", "zm_pi_rsierra12"];
    level.mwcf_box_v1.refs["jup_jp22_la_dromeo_mp"] = "jup_jp22_la_dromeo";
    level.mwcf_box_v1.groups["jup_jp22_la_dromeo_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["jup_jp22_la_dromeo_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["jup_jp22_la_dromeo_mp"] = ["jup_dromeo_rec", "jup_reflex_dromeo", "dynamic_null_rpapa7", "zm_la_dromeo"];
    level.mwcf_box_v1.refs["jup_jp32_pi_mpapa9_mp"] = "jup_jp32_pi_mpapa9";
    level.mwcf_box_v1.groups["jup_jp32_pi_mpapa9_mp"] = "weapon_pistol";
    level.mwcf_box_v1.likes["jup_jp32_pi_mpapa9_mp"] = "sat_pi_alcor";
    level.mwcf_box_v1.parts["jup_jp32_pi_mpapa9_mp"] = ["jup_mpapa9_rec", "jup_jp32_pi_mpapa9_bar", "jup_jp32_pi_mpapa9_stock_skel", "jup_jp32_pi_mpapa9_mag", "jup_jp32_pgrip", "jup_mpapa9_ironsdefault", "ammo_9p", "zm_pi_mpapa9"];
    level.mwcf_box_v1.refs["jup_la_plasmagun_mp"] = "jup_la_plasmagun";
    level.mwcf_box_v1.groups["jup_la_plasmagun_mp"] = "weapon_projectile";
    level.mwcf_box_v1.likes["jup_la_plasmagun_mp"] = "sat_la_fang";
    level.mwcf_box_v1.parts["jup_la_plasmagun_mp"] = ["zm_la_ub_plasmagun", "zm_la_plasmagun"];
    level.mwcf_box_v1.refs["jup_cp01_sm_coscar635_mp"] = "jup_cp01_sm_coscar635";
    level.mwcf_box_v1.groups["jup_cp01_sm_coscar635_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_cp01_sm_coscar635_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_cp01_sm_coscar635_mp"] = ["jup_coscar635_rec", "jup_cp01_sm_coscar635_bar_shorthvy2", "jup_cp01_sm_coscar635_stock_assault", "jup_cp01_sm_coscar635_mag_30_9mm", "jup_cp01_sm_coscar635_pgrip", "jup_coscar635_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_coscar635"];
    level.mwcf_box_v1.refs["jup_cp01_sm_pcharlie9_mp"] = "jup_cp01_sm_pcharlie9";
    level.mwcf_box_v1.groups["jup_cp01_sm_pcharlie9_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_cp01_sm_pcharlie9_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_cp01_sm_pcharlie9_mp"] = ["jup_pcharlie9_rec", "jup_cp01_sm_pcharlie9_bar", "jup_cp01_sm_pcharlie9_stock", "jup_cp01_sm_pcharlie9_mag_30_4x30", "jup_cp01_sm_pcharlie9_pgrip", "jup_pcharlie9_ironsdefault", "iw9_selectsemi", "ammo_4x30", "zm_sm_pcharlie9"];
    level.mwcf_box_v1.refs["jup_jp02_sm_scharlie3_mp"] = "jup_jp02_sm_scharlie3";
    level.mwcf_box_v1.groups["jup_jp02_sm_scharlie3_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp02_sm_scharlie3_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp02_sm_scharlie3_mp"] = ["jup_scharlie3_rec", "jup_jp02_sm_scharlie3_bar_light", "jup_jp02_sm_scharlie3_stock_skeltac", "jup_jp02_sm_scharlie3_mag_30_9mm", "jup_jp02_sm_scharlie3_pgrip_smg", "jup_scharlie3_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_scharlie3"];
    level.mwcf_box_v1.refs["jup_jp03_sm_pmike_mp"] = "jup_jp03_sm_pmike";
    level.mwcf_box_v1.groups["jup_jp03_sm_pmike_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp03_sm_pmike_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp03_sm_pmike_mp"] = ["jup_pmike_rec", "jup_jp03_sm_pmike_bar", "jup_jp03_sm_pmike_stock", "jup_jp03_sm_pmike_mag_30_9mm", "jup_jp03_sm_pmike_pgrip", "jup_pmike_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_pmike"];
    level.mwcf_box_v1.refs["jup_jp04_sm_lwhiskey_mp"] = "jup_jp04_sm_lwhiskey";
    level.mwcf_box_v1.groups["jup_jp04_sm_lwhiskey_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp04_sm_lwhiskey_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp04_sm_lwhiskey_mp"] = ["jup_lwhiskey_rec", "jup_jp04_sm_lwhiskey_bar", "jup_jp04_sm_lwhiskey_stock_hvyskel", "jup_jp04_sm_lwhiskey_mag_30_9mm", "jup_jp04_sm_lwhiskey_pgrip", "jup_lwhiskey_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_lwhiskey"];
    level.mwcf_box_v1.refs["jup_jp04_sm_umike_mp"] = "jup_jp04_sm_umike";
    level.mwcf_box_v1.groups["jup_jp04_sm_umike_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp04_sm_umike_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp04_sm_umike_mp"] = ["jup_umike_rec", "jup_jp04_sm_umike_bar", "jup_jp04_sm_umike_stock_folding", "jup_jp04_sm_umike_mag_25_45acp", "jup_jp04_sm_umike_pgrip", "jup_umike_ironsdefault", "iw9_selectsemi", "ammo_45acp", "zm_sm_umike"];
    level.mwcf_box_v1.refs["jup_jp07_sm_uzulu_mp"] = "jup_jp07_sm_uzulu";
    level.mwcf_box_v1.groups["jup_jp07_sm_uzulu_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp07_sm_uzulu_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp07_sm_uzulu_mp"] = ["jup_uzulu_rec", "jup_jp07_sm_uzulu_bar_long", "jup_jp07_sm_uzulu_stock_light", "jup_jp07_sm_uzulu_mag_25_9mm", "jup_jp07_sm_uzulu_pgrip", "jup_uzulu_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_uzulu"];
    level.mwcf_box_v1.refs["jup_jp07_sm_uzulup_mp"] = "jup_jp07_sm_uzulup";
    level.mwcf_box_v1.groups["jup_jp07_sm_uzulup_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp07_sm_uzulup_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp07_sm_uzulup_mp"] = ["jup_uzulup_rec", "jup_jp07_sm_uzulup_bar", "jup_jp07_sm_uzulup_stock_skelbrace", "jup_jp07_sm_uzulup_mag_32_9mm", "jup_jp07_sm_uzulup_pgrip", "jup_uzulup_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_uzulup"];
    level.mwcf_box_v1.refs["jup_jp25_sm_talpham_mp"] = "jup_jp25_sm_talpham";
    level.mwcf_box_v1.groups["jup_jp25_sm_talpham_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp25_sm_talpham_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp25_sm_talpham_mp"] = ["jup_talpham_rec", "jup_jp25_sm_talpham_bar", "jup_jp25_sm_talpham_stock", "jup_jp25_sm_talpham_mag_9p", "jup_jp25_pgrip", "jup_talpham_ironsdefault", "iw9_selectsemi", "ammo_9p", "zm_sm_talpham"];
    level.mwcf_box_v1.refs["jup_jp41_sm_kpappa50_mp"] = "jup_jp41_sm_kpappa50";
    level.mwcf_box_v1.groups["jup_jp41_sm_kpappa50_mp"] = "weapon_smg";
    level.mwcf_box_v1.likes["jup_jp41_sm_kpappa50_mp"] = "sat_sm_bear";
    level.mwcf_box_v1.parts["jup_jp41_sm_kpappa50_mp"] = ["jup_kpappa50_rec", "jup_jp41_sm_kpappa50_bar", "jup_jp41_sm_kpappa50_stock", "jup_jp41_sm_kpappa50_mag_50", "jup_jp41_sm_kpappa50_pgrip", "jup_kpappa50_ironsdefault", "ammo_5x28"];
}
