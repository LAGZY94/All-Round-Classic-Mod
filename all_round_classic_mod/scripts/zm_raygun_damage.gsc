#using scripts\common\callbacks;
#using scripts\common\utility;
#using scripts\common\ai\aitypes\shared\zombie\zombie_utils;
#using scripts\common\ai\aitypes\shared\zombie\zombie_damage;
#using scripts\mp\zm\systems\zm_round_logic;

#namespace raygun_base_damage;

autoexec init()
{
    level callback::add("on_zombie_ai_spawned", &enable);
}

enable(params)
{
    gametype = getdvar(@"ui_gametype");
    if (gametype.size < 2 || getsubstr(gametype, 0, 2) != "zm" || isdefined(level.raygun_base_damage_registered))
    {
        return;
    }
    level zombie_utils::register_zombie_agent_damage_callback(&adjust);
    level.raygun_base_damage_registered = true;
}

is_special_round()
{
    s = level.var_a009ab14ee0d3223;
    if (!isdefined(s) || !isdefined(s.specialroundspawns))
    {
        return false;
    }
    n = zm_round_logic::get_rb_round_number();
    return isdefined(s.specialroundspawns[n]) && isdefined(s.specialroundspawns[n].specialroundname);
}

adjust(dmg_struct)
{
    if (!isdefined(dmg_struct) || !isdefined(dmg_struct.idamage) || dmg_struct.idamage <= 0)
    {
        return -1;
    }
    weapon = dmg_struct.objweapon;
    if (!isdefined(weapon) || !isweapon(weapon) || isnullweapon(weapon))
    {
        weapon = dmg_struct.sweapon;
    }
    if (!isdefined(weapon) || !isweapon(weapon) || isnullweapon(weapon))
    {
        return -1;
    }
    if (!(weapon.basename == %"sat_ww_raygun_mp" || weapon.basename == "sat_ww_raygun_mp" || weapon.basename == %"sat_ww_raygun_zm" || weapon.basename == "sat_ww_raygun_zm"))
    {
        return -1;
    }
    method = dmg_struct.smeansofdeath;
    if (!(method == "MOD_RIFLE_BULLET" || method == "MOD_PISTOL_BULLET" || method == "MOD_HEAD_SHOT" || method == "MOD_PROJECTILE" || method == "MOD_EXPLOSIVE_BULLET" || method == "MOD_GRENADE_SPLASH" || method == "MOD_PROJECTILE_SPLASH"))
    {
        return -1;
    }
    if (isdefined(dmg_struct.idflags) && (dmg_struct.idflags & 65536))
    {
        return -1;
    }
    attacker = dmg_struct.eattacker;
    if (isdefined(attacker) && !isplayer(attacker) && isdefined(attacker.owner))
    {
        attacker = attacker.owner;
    }
    if (!isdefined(attacker) || !isplayer(attacker))
    {
        return -1;
    }
    if (self.killondamage || attacker utility::ent_flag("powerup_insta_kill_active"))
    {
        return -1;
    }

    // ============ ONLY SPECIALS / ELITES OR SPECIAL ROUNDS ============
    // If it is NOT a special round, skip normal zombies ("normal" or undefined)
    if (!is_special_round())
    {
        if (!isdefined(self.aicategory) || self.aicategory == "normal")
        {
            return -1;
        }
    }
    // ============ END ONLY SPECIALS / ELITES OR SPECIAL ROUNDS ============

    if (!utility::issharedfuncdefined(#"zombie", #"get_pap_level"))
    {
        return -1;
    }
    pap = attacker utility::callsharedfunc(#"zombie", #"get_pap_level", weapon);
    if (!isdefined(pap) || pap < 0)
    {
        return -1;
    }
    target = 10000.0; // Non PAP Damage
    pack_multiplier = 1;
    if (pap > 0)
    {
        if (utility::issharedfuncdefined(#"zombie_damage", #"hash_8a5422fcea1951e4"))
        {
            return -1;
        }
        pack_multiplier = zombie_damage::get_weapon_pack_multiplier(weapon, pap);
        if (!isdefined(pack_multiplier))
        {
            pack_multiplier = zombie_damage::get_base_pack_multiplier(pap);
        }
        if (!isdefined(pack_multiplier) || pack_multiplier <= 0)
        {
            return -1;
        }
        target = 85000.0;
    }
    result = ((dmg_struct.idamage / pack_multiplier) * target) / 1200.0;
    if (result >= 2147483647)
    {
        return 2147483647;
    }
    result = int(result);
    if (result < 1)
    {
        return -1;
    }
    return result;
}
