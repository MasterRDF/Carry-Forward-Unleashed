#using scripts\common\callbacks;
#using scripts\common\utility;
#using scripts\common\weapon;

// MW loadout guns in Zombies (MW side, 2026-11-07). In Zombies the game builds the class loadout at spawn into
// self.var_c7bccb68d21bc6bb (primary weapon in var_94d0f8ea18599de3, secondary in var_c817e40959fa971b; fuzmenu's "My loadout
// primary" gives that one), and Kronos's BO6/MW loadout builder (mp_bo6_loadout.gsc) is not called in Zombies. MW2 and MW3 loadout
// guns (iw9_, jup_) then never reached the player. A few seconds after each spawn this gives an MW2/MW3 primary or secondary the
// class names but the player does not hold: the class's own built weapon if it has one, else one built with the menu's
// blueprint and attachments (kronos_bo6_var), else the class's attachments, else the plain gun. What it saw and did goes to
// kronos\mw_zm_loadout\status.json.
// Version 2: a class with an MW blueprint names the gun with the blueprint's number on the end (jup_jp37_dm_kappa98_v4615 in the
// first test), and neither the game nor version 1 could build a weapon from that name, so the player spawned with no gun. The
// number is now taken off (jup_jp37_dm_kappa98), which is also the name the menu's build is stored under, and each build is tried
// the way fuzmenu builds a gunsmith weapon (with its blueprint bundle) before the shorter forms.
// Kronos style (self fields, while loops): this VM loses locals across waits.

autoexec mw_zl_init()
{
    level.mw_zl_k = 0;
    level callback::add(#"player_spawned", &mw_zl_spawned);
}

mw_zl_spawned(params)
{
    if (!mw_zl_zombies())
    {
        return;
    }
    self thread mw_zl_check();
}

mw_zl_zombies()
{
    if (!isdefined(level.var_dfeae4b8b3d59217))
    {
        return 0;
    }
    level.mw_zl_mapt = strtok(level.var_dfeae4b8b3d59217, "_");
    return level.mw_zl_mapt.size > 0 && level.mw_zl_mapt[0] == "zm";
}

mw_zl_check()
{
    self endon(#"death");
    self endon(#"disconnect");
    self.mw_zl_t = 0;
    while (!isdefined(self.var_c7bccb68d21bc6bb) && self.mw_zl_t < 50)
    {
        self.mw_zl_t = self.mw_zl_t + 1;
        wait 0.1;
    }
    wait 1.5;
    self.mw_zl_s = self.var_c7bccb68d21bc6bb;
    if (!isdefined(self.mw_zl_s))
    {
        mw_zl_say("spawn: no class loadout on the player");
        return;
    }
    mw_zl_say("spawn: class primary " + mw_zl_str(self.mw_zl_s.loadoutPrimary) + " (blueprint " + mw_zl_str(self.mw_zl_s.loadoutPrimaryVariantID) + ") -> " +
              mw_zl_wname(self.mw_zl_s.var_94d0f8ea18599de3) + ", secondary " + mw_zl_str(self.mw_zl_s.loadoutSecondary) + " (blueprint " +
              mw_zl_str(self.mw_zl_s.loadoutSecondaryVariantID) + ") -> " + mw_zl_wname(self.mw_zl_s.var_c817e40959fa971b) + ", melee " +
              mw_zl_str(self.mw_zl_s.loadoutTertiary) + "; holding " + self mw_zl_holding());
    self mw_zl_slot("primary", self.mw_zl_s.loadoutPrimary, self.mw_zl_s.var_94d0f8ea18599de3, self.mw_zl_s.loadoutPrimaryAttachments, self.mw_zl_s.loadoutPrimaryCamo, self.mw_zl_s.loadoutPrimaryVariantID);
    self mw_zl_slot("secondary", self.mw_zl_s.loadoutSecondary, self.mw_zl_s.var_c817e40959fa971b, self.mw_zl_s.loadoutSecondaryAttachments, self.mw_zl_s.loadoutSecondaryCamo, self.mw_zl_s.loadoutSecondaryVariantID);
}

mw_zl_mw(ref)
{
    return isdefined(ref) && function_f20826a3e52aa5cf(ref) && (function_fa12b82454202b8b(ref, "iw9_") || function_fa12b82454202b8b(ref, "jup_"));
}

// jup_jp37_dm_kappa98_v4615 -> jup_jp37_dm_kappa98: a last part of "v" and a number is the blueprint's, not the gun's.
mw_zl_base(ref)
{
    self.mw_zl_bt = strtok(ref, "_");
    if (self.mw_zl_bt.size < 3)
    {
        return ref;
    }
    self.mw_zl_last = self.mw_zl_bt[self.mw_zl_bt.size - 1];
    if (self.mw_zl_last.size < 2 || getsubstr(self.mw_zl_last, 0, 1) != "v" || int(getsubstr(self.mw_zl_last, 1, self.mw_zl_last.size)) <= 0)
    {
        return ref;
    }
    return getsubstr(ref, 0, ref.size - self.mw_zl_last.size - 1);
}

mw_zl_slot(slot, ref, built, attachments, camo, classvariant)
{
    if (!mw_zl_mw(ref))
    {
        return;
    }
    self.mw_zl_slotname = slot;
    self.mw_zl_ref = self mw_zl_base(ref);
    self.mw_zl_name = self.mw_zl_ref;
    if (!issubstr(self.mw_zl_name, "_mp"))
    {
        self.mw_zl_name = self.mw_zl_name + "_mp";
    }
    if (self mw_zl_holds(self.mw_zl_ref))
    {
        mw_zl_say(slot + " " + self.mw_zl_ref + ": already held");
        return;
    }
    // 1. the class's own build, 2. the menu's blueprint and attachments, 3. the menu's blueprint alone, 4. the class's attachments,
    // 5. the plain gun
    self.mw_zl_w = undefined;
    self.mw_zl_how = "";
    if (isdefined(built) && !isnullweapon(built) && isdefined(built.basename) && function_fa12b82454202b8b(built.basename, self.mw_zl_ref))
    {
        self.mw_zl_w = built;
        self.mw_zl_how = "the class's build";
    }
    self mw_zl_picks(self.mw_zl_ref);
    if (!isdefined(self.mw_zl_var) && isdefined(classvariant) && classvariant > 0)
    {
        self.mw_zl_var = classvariant;
    }
    if (!isdefined(self.mw_zl_var))
    {
        self.mw_zl_var = 0;
    }
    if (!mw_zl_ok(self.mw_zl_w) && isdefined(self.mw_zl_atts))
    {
        self mw_zl_build(self.mw_zl_atts, self.mw_zl_camo, self.mw_zl_var, self.mw_zl_attv);
        self.mw_zl_how = "the menu's blueprint " + self.mw_zl_var + " with its " + self.mw_zl_atts.size + " attachments";
    }
    if (!mw_zl_ok(self.mw_zl_w) && self.mw_zl_var > 0)
    {
        self mw_zl_build([], self.mw_zl_camo, self.mw_zl_var, []);
        self.mw_zl_how = "blueprint " + self.mw_zl_var + " only";
    }
    if (!mw_zl_ok(self.mw_zl_w) && isdefined(attachments) && attachments.size > 0)
    {
        self mw_zl_build(attachments, camo, 0, undefined);
        self.mw_zl_how = "the class's " + attachments.size + " attachments";
    }
    if (!mw_zl_ok(self.mw_zl_w))
    {
        self.mw_zl_w = weapon::function_5416d4273f081ce2(self.mw_zl_name);
        self.mw_zl_how = "no attachments";
    }
    if (!mw_zl_ok(self.mw_zl_w))
    {
        mw_zl_say(slot + " " + self.mw_zl_ref + ": the game could not build " + self.mw_zl_name + " (class name " + ref + ")");
        return;
    }
    self loadweaponsforplayer([self.mw_zl_w], 1);
    self.mw_zl_t = 0;
    while (!self hasloadedviewweapons([self.mw_zl_w]) && self.mw_zl_t < 30)
    {
        self.mw_zl_t = self.mw_zl_t + 1;
        wait 0.1;
    }
    self giveweapon(self.mw_zl_w, undefined, 0, -1, 0);
    self assignweaponprimaryslot(self.mw_zl_w);
    self givemaxammo(self.mw_zl_w);
    if (self.mw_zl_slotname == "primary")
    {
        self switchtoweapon(self.mw_zl_w);
    }
    wait 0.25;
    mw_zl_say(self.mw_zl_slotname + " " + self.mw_zl_ref + ": given (" + self.mw_zl_how + "), held now " + self hasweapon(self.mw_zl_w) + "; holding " + self mw_zl_holding());
}

// Builds self.mw_zl_name as fuzmenu builds a gunsmith weapon (with the blueprint's bundle), then without the bundle.
mw_zl_build(atts, camo, variant, attv)
{
    self.mw_zl_bundle = undefined;
    if (variant > 0)
    {
        self.mw_zl_bundle = weapon::function_2374da6f1b4fad4e(self.mw_zl_name, variant);
    }
    self.mw_zl_w = weapon::function_5416d4273f081ce2(self.mw_zl_name, atts, camo, "none", variant, attv, "charm_none", ["sticker_none", "sticker_none", "sticker_none", "sticker_none", "sticker_none"], undefined, undefined, undefined, self.mw_zl_bundle);
    if (!mw_zl_ok(self.mw_zl_w))
    {
        self.mw_zl_w = weapon::function_5416d4273f081ce2(self.mw_zl_name, atts, camo, "none", variant, attv);
    }
}

mw_zl_ok(w)
{
    return isdefined(w) && !isnullweapon(w);
}

// The menu's build of a gun from kronos_bo6_var: ref=variant;ref@a=att,...;ref@v=n,...;ref@c=camo
mw_zl_picks(ref)
{
    self.mw_zl_atts = undefined;
    self.mw_zl_attv = undefined;
    self.mw_zl_camo = "camo_none";
    self.mw_zl_var = undefined;
    self.mw_zl_parts = strtok(getdvar("kronos_bo6_var", ""), ";");
    self.mw_zl_i = 0;
    while (self.mw_zl_i < self.mw_zl_parts.size)
    {
        self.mw_zl_kv = strtok(self.mw_zl_parts[self.mw_zl_i], "=");
        if (self.mw_zl_kv.size == 2)
        {
            if (self.mw_zl_kv[0] == ref)
            {
                self.mw_zl_var = int(self.mw_zl_kv[1]);
            }
            else if (self.mw_zl_kv[0] == ref + "@a")
            {
                self.mw_zl_atts = strtok(self.mw_zl_kv[1], ",");
            }
            else if (self.mw_zl_kv[0] == ref + "@v")
            {
                self.mw_zl_vs = strtok(self.mw_zl_kv[1], ",");
                self.mw_zl_attv = [];
                self.mw_zl_j = 0;
                while (self.mw_zl_j < self.mw_zl_vs.size)
                {
                    self.mw_zl_attv[self.mw_zl_j] = int(self.mw_zl_vs[self.mw_zl_j]);
                    self.mw_zl_j = self.mw_zl_j + 1;
                }
            }
            else if (self.mw_zl_kv[0] == ref + "@c")
            {
                self.mw_zl_camo = self.mw_zl_kv[1];
            }
        }
        self.mw_zl_i = self.mw_zl_i + 1;
    }
    if (isdefined(self.mw_zl_atts) && (!isdefined(self.mw_zl_attv) || self.mw_zl_attv.size != self.mw_zl_atts.size))
    {
        self.mw_zl_attv = [];
        self.mw_zl_j = 0;
        while (self.mw_zl_j < self.mw_zl_atts.size)
        {
            self.mw_zl_attv[self.mw_zl_j] = 0;
            self.mw_zl_j = self.mw_zl_j + 1;
        }
    }
}

mw_zl_holds(ref)
{
    if (!isdefined(self.primaryinventory))
    {
        return 0;
    }
    foreach (w in self.primaryinventory)
    {
        if (isdefined(w) && !isnullweapon(w) && isdefined(w.basename) && function_fa12b82454202b8b(w.basename, ref))
        {
            return 1;
        }
    }
    return 0;
}

mw_zl_holding()
{
    self.mw_zl_list = "";
    if (isdefined(self.primaryinventory))
    {
        foreach (w in self.primaryinventory)
        {
            if (isdefined(w) && !isnullweapon(w) && isdefined(w.basename))
            {
                self.mw_zl_list = self.mw_zl_list + w.basename + " ";
            }
        }
    }
    if (self.mw_zl_list == "")
    {
        return "nothing";
    }
    return self.mw_zl_list;
}

mw_zl_str(v)
{
    if (!isdefined(v))
    {
        return "undefined";
    }
    return "" + v;
}

mw_zl_wname(w)
{
    if (!isdefined(w) || isnullweapon(w))
    {
        return "no weapon";
    }
    if (!isdefined(w.basename))
    {
        return "a weapon";
    }
    return "" + w.basename;
}

mw_zl_say(text)
{
    if (level.mw_zl_k >= 60)
    {
        return;
    }
    level.mw_zl_k = level.mw_zl_k + 1;
    nengine_store_set("mw_zm_loadout", "line" + level.mw_zl_k, text);
    nengine_store_save("mw_zm_loadout", "status");
}
