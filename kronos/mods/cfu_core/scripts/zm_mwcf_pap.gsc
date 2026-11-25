#using scripts\common\utility;
#namespace mwcf_pap_v1;

// Independent metadata registration. The normal machine owns all purchases,
// weapon reconstruction, PaP levels, damage scaling, ammo and callbacks.
autoexec mwcf_pap_init()
{
    if (!utility::iszm() || isdefined(level.mwcf_pap_v1))
        return;
    level.mwcf_pap_v1 = function_5c418f65db2e25e8();
    level.mwcf_pap_v1.rows = [];
    level.mwcf_pap_v1.tick = 0;
    level.mwcf_pap_v1.repairs = 0;
    level.mwcf_pap_v1.dirty = 1;
    level.mwcf_pap_v1.table_ready = 0;
    mwcf_pap_seed();
    nengine_store_clear("mwcf_pap_v1");
    level thread mwcf_pap_main();
}

function mwcf_pap_add_row(name, base, pack)
{
    row = function_5c418f65db2e25e8();
    row.name = name;
    row.base = base;
    row.pack = pack;
    row.next_attempt = 0;
    row.owns_allow = 0;
    row.status = "waiting_for_metadata";
    level.mwcf_pap_v1.rows[level.mwcf_pap_v1.rows.size] = row;
}

function mwcf_pap_main()
{
    // This is the only worker. State that survives waits lives on level.
    // No weapon polling, grants, swaps, effect loops, or native hooks.
    for (;;)
    {
        if (isdefined(level.var_d06db1f300d5fe3b))
        {
            if (!level.mwcf_pap_v1.table_ready)
            {
                level.mwcf_pap_v1.table_ready = 1;
                level.mwcf_pap_v1.dirty = 1;
            }
            level.mwcf_pap_v1.i = 0;
            while (level.mwcf_pap_v1.i < level.mwcf_pap_v1.rows.size)
            {
                mwcf_pap_reconcile(level.mwcf_pap_v1.rows[level.mwcf_pap_v1.i]);
                level.mwcf_pap_v1.i++;
            }
        }
        else if (level.mwcf_pap_v1.table_ready)
        {
            level.mwcf_pap_v1.table_ready = 0;
            level.mwcf_pap_v1.dirty = 1;
        }
        if (level.mwcf_pap_v1.dirty)
            mwcf_pap_report();
        level.mwcf_pap_v1.tick++;
        wait 2;
    }
}

function mwcf_pap_status(row, status)
{
    if (row.status != status)
    {
        row.status = status;
        level.mwcf_pap_v1.dirty = 1;
    }
}

function mwcf_pap_resolve(row)
{
    if (isdefined(row.root))
        return 1;
    if (level.mwcf_pap_v1.tick < row.next_attempt)
        return 0;
    row.next_attempt = level.mwcf_pap_v1.tick + 5;
    weapon = function_c95bf1a14134f45c(row.name);
    // A fallback weapon is not evidence that the requested asset is loaded.
    if (!isdefined(weapon) || weapon.var_1b57e3034f84a054 != row.name)
    {
        mwcf_pap_status(row, "weapon_unavailable");
        return 0;
    }
    root = weapon.var_1616e6fbba9a722d;
    if (!isdefined(root) || root == "" || root == %"none")
    {
        mwcf_pap_status(row, "invalid_root");
        return 0;
    }
    // The stock PaP code uses this same builtin to validate attachments.
    if (!(weapon function_a6d6987298fb8f4a(row.base)) || !(weapon function_a6d6987298fb8f4a(row.pack)))
    {
        mwcf_pap_status(row, "attachment_unavailable");
        return 0;
    }
    row.root = root;
    return 1;
}

function mwcf_pap_reconcile(row)
{
    if (!mwcf_pap_resolve(row))
        return;
    if (!isdefined(level.var_d06db1f300d5fe3b[row.root]))
    {
        entry = function_5c418f65db2e25e8();
        entry.weapon = row.name;
        entry.var_6c2dc03affad7ce0 = row.base;
        entry.var_6ec5e9b28d8ba1f4 = row.pack;
        entry.var_a0f67da9669fe547 = [];
        entry.var_c942da1b8e4b67f5 = 1;
        // Ordinary weapon defaults present in the decoded BO6 XM4 bundle.
        entry.var_6dc1e3a72bccce3f = "none";
        entry.var_aea604e17ece5fb2 = -1;
        // No invented pack2/pack3/max attachment, item bundle or special tuning.
        level.var_d06db1f300d5fe3b[row.root] = entry;
        level.mwcf_pap_v1.repairs++;
        level.mwcf_pap_v1.dirty = 1;
    }
    entry = level.var_d06db1f300d5fe3b[row.root];
    // Preserve prior registrations, including an explicit opt-out by another mod.
    if (!istrue(entry.var_c942da1b8e4b67f5) || entry.weapon != row.name ||
        entry.var_6c2dc03affad7ce0 != row.base || entry.var_6ec5e9b28d8ba1f4 != row.pack)
    {
        mwcf_pap_withdraw(row);
        mwcf_pap_status(row, "existing_metadata_preserved");
        return;
    }
    // Never create the table early: the stock initializer owns its lifecycle.
    if (!isdefined(level.var_b6377f00348c4d99))
    {
        row.owns_allow = 0;
        mwcf_pap_status(row, "metadata_ready_waiting_for_allowlist");
        return;
    }
    if (!isdefined(level.var_b6377f00348c4d99[row.root]))
    {
        level.var_b6377f00348c4d99[row.root] = row.root;
        row.owns_allow = 1;
        level.mwcf_pap_v1.repairs++;
        level.mwcf_pap_v1.dirty = 1;
    }
    mwcf_pap_status(row, "eligible");
}

function mwcf_pap_withdraw(row)
{
    // Withdraw only a contribution this instance actually made. Pre-existing
    // allow-list entries and all foreign metadata are preserved.
    if (row.owns_allow && isdefined(level.var_b6377f00348c4d99) &&
        isdefined(level.var_b6377f00348c4d99[row.root]) &&
        level.var_b6377f00348c4d99[row.root] == row.root)
    {
        level.var_b6377f00348c4d99[row.root] = undefined;
        level.mwcf_pap_v1.dirty = 1;
    }
    row.owns_allow = 0;
}

function mwcf_pap_report()
{
    eligible = 0;
    foreach (row in level.mwcf_pap_v1.rows)
    {
        if (level.mwcf_pap_v1.table_ready && row.status == "eligible")
            eligible++;
        nengine_store_set("mwcf_pap_v1", row.name, row.status);
    }
    nengine_store_set("mwcf_pap_v1", "version", "1.0.0-candidate");
    nengine_store_set("mwcf_pap_v1", "expected", level.mwcf_pap_v1.rows.size);
    nengine_store_set("mwcf_pap_v1", "table_ready", level.mwcf_pap_v1.table_ready);
    nengine_store_set("mwcf_pap_v1", "eligible", eligible);
    nengine_store_set("mwcf_pap_v1", "repairs", level.mwcf_pap_v1.repairs);
    nengine_store_set("mwcf_pap_v1", "iw9_me_buzzsaw_mp", "unsupported_no_verified_pap_attachments");
    nengine_store_save("mwcf_pap_v1", "status");
    level.mwcf_pap_v1.dirty = 0;
}

// The build appends mwcf_pap_seed() from the hash-verified research map.

function mwcf_pap_seed()
{
    mwcf_pap_add_row("iw9_ar_mike4_mp", "zm_ar_mike4", "zm_ar_mike4_pack");
    mwcf_pap_add_row("iw9_ar_mike16_mp", "zm_ar_mike16", "zm_ar_mike16_pack");
    mwcf_pap_add_row("iw9_ar_scharlie_mp", "zm_ar_scharlie", "zm_ar_scharlie_pack");
    mwcf_pap_add_row("iw9_ar_akilo_mp", "zm_ar_akilo", "zm_ar_akilo_pack");
    mwcf_pap_add_row("iw9_ar_akilo105_mp", "zm_ar_akilo105", "zm_ar_akilo105_pack");
    mwcf_pap_add_row("iw9_ar_akilo74_mp", "zm_ar_akilo74", "zm_ar_akilo74_pack");
    mwcf_pap_add_row("iw9_ar_kilo53_mp", "zm_ar_kilo53", "zm_ar_kilo53_pack");
    mwcf_pap_add_row("iw9_ar_augolf_mp", "zm_ar_augolf", "zm_ar_augolf_pack");
    mwcf_pap_add_row("iw9_ar_mcbravo_mp", "zm_ar_mcbravo", "zm_ar_mcbravo_pack");
    mwcf_pap_add_row("iw9_ar_mcharlie_mp", "zm_ar_mcharlie", "zm_ar_mcharlie_pack");
    mwcf_pap_add_row("iw9_ar_acharlie300_mp", "zm_ar_acharlie300", "zm_ar_acharlie300_pack");
    mwcf_pap_add_row("iw9_ar_helima_mp", "zm_ar_helima", "zm_ar_helima_pack");
    mwcf_pap_add_row("iw9_ar_fecho_mp", "zm_ar_fecho", "zm_ar_fecho_pack");
    mwcf_pap_add_row("iw9_ar_falpha_mp", "zm_ar_falpha", "zm_ar_falpha_pack");
    mwcf_pap_add_row("iw9_ar_malima_mp", "zm_ar_malima", "zm_ar_malima_pap");
    mwcf_pap_add_row("iw9_sm_mpapa7_mp", "zm_sm_mpapa7", "zm_sm_mpapa7_pack");
    mwcf_pap_add_row("iw9_sm_apapa_mp", "zm_sm_apapa", "zm_sm_apapa_pack");
    mwcf_pap_add_row("iw9_sm_mpapa5_mp", "zm_sm_mpapa5", "zm_sm_mpapa5_pack");
    mwcf_pap_add_row("iw9_sm_aviktor_mp", "zm_sm_aviktor", "zm_sm_aviktor_pack");
    mwcf_pap_add_row("iw9_sm_alpha57_mp", "zm_sm_alpha57", "zm_sm_alpha57_pack");
    mwcf_pap_add_row("iw9_sm_beta_mp", "zm_sm_beta", "zm_sm_beta_pack");
    mwcf_pap_add_row("iw9_sm_papa90_mp", "zm_sm_papa90", "zm_sm_papa90_pack");
    mwcf_pap_add_row("iw9_sm_victor_mp", "zm_sm_victor", "zm_sm_victor_pack");
    mwcf_pap_add_row("iw9_sm_mpapax_mp", "zm_sm_mpapax", "zm_sm_mpapax_pack");
    mwcf_pap_add_row("iw9_sm_acharlie45_mp", "zm_sm_acharlie45", "zm_sm_acharlie45_pack");
    mwcf_pap_add_row("iw9_sm_sdelta_mp", "zm_sm_sdelta", "zm_sm_sdelta_pap");
    mwcf_pap_add_row("iw9_sm_acharlie9_mp", "zm_sm_acharlie9", "zm_sm_acharlie9_pap");
    mwcf_pap_add_row("iw9_lm_ahotel_mp", "zm_lm_ahotel", "zm_lm_ahotel_pack");
    mwcf_pap_add_row("iw9_lm_foxtrot_mp", "zm_lm_foxtrot", "zm_lm_foxtrot_pack");
    mwcf_pap_add_row("iw9_lm_kilo21_mp", "zm_lm_kilo21", "zm_lm_kilo21_pack");
    mwcf_pap_add_row("iw9_lm_ngolf7_mp", "zm_lm_ngolf7", "zm_lm_ngolf7_pack");
    mwcf_pap_add_row("iw9_lm_rkilo_mp", "zm_lm_rkilo", "zm_lm_rkilo_pack");
    mwcf_pap_add_row("iw9_lm_slima_mp", "zm_lm_slima", "zm_lm_slima_pack");
    mwcf_pap_add_row("iw9_pi_papa220_mp", "zm_pi_papa220", "zm_pi_papa220_pack");
    mwcf_pap_add_row("iw9_pi_golf17_mp", "zm_pi_golf17", "zm_pi_golf17_pack");
    mwcf_pap_add_row("iw9_pi_golf18_mp", "zm_pi_golf18", "zm_pi_golf18_pack");
    mwcf_pap_add_row("iw9_pi_decho_mp", "zm_pi_decho", "zm_pi_decho_pack");
    mwcf_pap_add_row("iw9_pi_swhiskey_mp", "zm_pi_swhiskey", "zm_pi_swhiskey_pack");
    mwcf_pap_add_row("iw9_pi_tango9_mp", "zm_pi_tango9", "zm_pi_tango9_pack");
    mwcf_pap_add_row("iw9_pi_dechoauto_mp", "zm_pi_dechoauto", "zm_pi_dechoauto_pack");
    mwcf_pap_add_row("iw9_pi_mike2011_mp", "zm_pi_mike2011", "zm_pi_mike2011_pap");
    mwcf_pap_add_row("iw9_sh_mbravo_mp", "zm_sh_mbravo", "zm_sh_mbravo_pack");
    mwcf_pap_add_row("iw9_sh_mviktor_mp", "zm_sh_mviktor", "zm_sh_mviktor_pack");
    mwcf_pap_add_row("iw9_sh_charlie725_mp", "zm_sh_charlie725", "zm_sh_charlie725_pack");
    mwcf_pap_add_row("iw9_sh_mike1014_mp", "zm_sh_mike1014", "zm_sh_mike1014_pack");
    mwcf_pap_add_row("iw9_sh_vecho_mp", "zm_sh_vecho", "zm_sh_vecho_pack");
    mwcf_pap_add_row("iw9_sh_tsierra12_mp", "zm_sh_tsierra12", "zm_sh_tsierra12_pack");
    mwcf_pap_add_row("iw9_sn_mromeo_mp", "zm_sn_mromeo", "zm_sn_mromeo_pack");
    mwcf_pap_add_row("iw9_sn_alpha50_mp", "zm_sn_alpha50", "zm_sn_alpha50_pack");
    mwcf_pap_add_row("iw9_dm_la700_mp", "zm_dm_la700", "zm_dm_la700_pack");
    mwcf_pap_add_row("iw9_dm_xmike2010_mp", "zm_dm_xmike2010", "zm_dm_xmike2010_pack");
    mwcf_pap_add_row("iw9_sn_limax_mp", "zm_sn_limax", "zm_sn_limax_pack");
    mwcf_pap_add_row("iw9_sn_india_mp", "zm_sn_india", "zm_sn_india_pack");
    mwcf_pap_add_row("iw9_sn_walpha_mp", "zm_sn_walpha", "zm_sn_walpha_pack");
    mwcf_pap_add_row("iw9_dm_mike14_mp", "zm_dm_mike14", "zm_dm_mike14_pack");
    mwcf_pap_add_row("iw9_dm_mike24_mp", "zm_dm_mike24", "zm_dm_mike24_pack");
    mwcf_pap_add_row("iw9_dm_sbeta_mp", "zm_dm_sbeta", "zm_dm_sbeta_pack");
    mwcf_pap_add_row("iw9_dm_pgolf1_mp", "zm_dm_pgolf1", "zm_dm_pgolf1_pack");
    mwcf_pap_add_row("iw9_dm_sa700_mp", "zm_dm_sa700", "zm_dm_sa700_pack");
    mwcf_pap_add_row("iw9_dm_scromeo_mp", "zm_dm_scromeo", "zm_dm_scromeo_pack");
    mwcf_pap_add_row("iw9_dm_stango25_mp", "zm_dm_stango25", "zm_dm_stango25_pack");
    mwcf_pap_add_row("iw9_ar_golf3_mp", "zm_br_golf3", "zm_br_golf3_pack");
    mwcf_pap_add_row("iw9_ar_schotel_mp", "zm_ar_schotel", "zm_ar_schotel_pack");
    mwcf_pap_add_row("iw9_br_msecho_mp", "zm_br_msecho", "zm_br_msecho_pack");
    mwcf_pap_add_row("iw9_br_ngsierra_mp", "zm_br_ngsierra", "zm_br_ngsierra_pack");
    mwcf_pap_add_row("iw9_br_soscar14_mp", "zm_br_soscar14", "zm_br_soscar14_pack");
    mwcf_pap_add_row("iw9_dm_crossbow_mp", "zm_dm_crossbow", "zm_dm_crossbow_pack");
    mwcf_pap_add_row("iw9_la_gromeo_mp", "zm_la_gromeo", "zm_la_gromeo_pack");
    mwcf_pap_add_row("iw9_la_kgolf_mp", "zm_la_kgolf", "zm_la_kgolf_pack");
    mwcf_pap_add_row("iw9_la_juliet_mp", "zm_la_juliet", "zm_la_juliet_pack");
    mwcf_pap_add_row("iw9_la_rpapa7_mp", "zm_la_rpapa7", "zm_la_rpapa7_pack");
    mwcf_pap_add_row("iw9_la_mike32_mp", "zm_la_mike32", "zm_la_mike32_pack");
    mwcf_pap_add_row("iw9_me_knife_mp", "zm_me_iw9_knife", "zm_me_iw9_knife_pap");
    mwcf_pap_add_row("iw9_me_sword01_mp", "zm_me_sword01", "zm_me_sword01_pap");
    mwcf_pap_add_row("iw9_me_tonfa_mp", "zm_me_tonfa", "zm_me_tonfa_pap");
    mwcf_pap_add_row("iw9_me_pickaxe_mp", "zm_me_jup_pickaxe", "zm_me_jup_pickaxe_pap");
    mwcf_pap_add_row("iw9_me_kamas_mp", "zm_me_kamas", "zm_me_kamas_pap");
}
