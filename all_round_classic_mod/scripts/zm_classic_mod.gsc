/////////////////////////////////////////////////////////
/// ALL ROUND CLASSIC MOD BROUGHT TO YOU BY LAGZY ///////
/////////////////////CREDITS/////////////////////////////
/// - @rak FOR WONDER WEAPON DAMAGE /////////////////////
/// - @grum FOR BO3 HEALTH //////////////////////////////
/// - @Shlogbobble FOR MONKEYS & KAZMIR IN BOX //////////
/// - @lagzy (me) INSTA KILL ROUNDS & Omni Toggle ///////
/// - @taylor FOR CLASSIC PERK STUFF ////////////////////
/////////////////////////////////////////////////////////
/// IF YOU USE ANY OF THESE CODES PLEASE GIVE CREDIT ////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////

#using scripts\common\callbacks;
#using scripts\common\system;
#using scripts\common\utility;
#using scripts\common\ai\aitypes\shared\zombie\zombie_utils;
#using scripts\common\ai\aitypes\shared\zombie\zombie_damage;
#using scripts\mp\zm\systems\zm_round_logic;
#using scripts\mp\interaction;
#using scripts\mp\common\utility\dvars;
#using scripts\mp\common\utility\outline;
#using scripts\mp\common\utility\player;
#using scripts\mp\currency;
#using scripts\mp\equipment;
#using scripts\mp\gametypes\common;
#using scripts\mp\health_overcharge;
#using scripts\mp\loot\common_item;
#using scripts\mp\magicbox;
#using scripts\mp\playerhealth;
#using scripts\mp\weapons;
#using scripts\common\values;
#using script_4c770a9a4ad7659c;
#using script_692b19b8e5f8f9e8;
#using script_3b64eb40368c1450;
#using script_25a8fa2ac8997425;
#using script_3a9d7a7cfee99885;

#namespace zm_classic_mod;

function zm_ss_count( nround, real_players ) { return 10; }
function zm_ss_delay() { return 0.05; }

// ============> BO1 INSTA-KILL ROUNDS <============
autoexec init()
{
    level callback::add("on_zombie_ai_spawned", &enable);
    level callback::add( #"player_spawned", &on_player_spawned_instakill );
	level thread zm_ss_init();
    install_ww_instakill();
}

function on_player_spawned_instakill( params )
{
    player = params.player;
    player endon( #"disconnect" );
    wait 9.0;
    if ( isalive( player ) )
    {
        player iPrintLnBold( "^5ALL ROUND CLASSIC MOD ^1V1.0 ^2BY LAGZY" );
    }
}

enable(params)
{
    if ( isdefined( level.zm_instakill_registered ) )
    {
        return;
    }
    level zombie_utils::register_zombie_agent_damage_callback(&adjust);
    level.zm_instakill_registered = true;
}

function getCurrentRound()
{
    if ( isdefined( level.round_number ) )
    {
        return level.round_number;
    }
    else if ( isdefined( level.zombie_round ) )
    {
        return level.zombie_round;
    }
    return 1;
}

function isInstaKillRound()
{
    round = getCurrentRound();
    if ( round < 163 )
    {
        return false;
    }
    if ( ( round % 2 ) == 0 )
    {
        return false;
    }
    return true;
}

adjust(dmg_struct)
{
    if ( !isdefined( dmg_struct ) || !isdefined( dmg_struct.idamage ) || dmg_struct.idamage <= 0 )
    {
        return -1;
    }
    attacker = dmg_struct.eattacker;
    if ( isdefined( attacker ) && !isplayer( attacker ) && isdefined( attacker.owner ) )
    {
        attacker = attacker.owner;
    }
    if ( !isdefined( attacker ) || !isplayer( attacker ) )
    {
        return -1;
    }
    if ( !isInstaKillRound() )
    {
        return -1;
    }
    return 2000000;
}

// ============> OMNIMOVEMENT TOGGLE <============
autoexec omnimovement_init()
{
    setdvar( "sprintleap_enabled", "0" );
    setdvar( "scr_test_suit", "sat_defaultsuit_mp_vint" );

    level callback::add( #"player_spawned", &on_player_spawned_omni );
}

function on_player_spawned_omni( params )
{
    player = params.player;
    player endon( #"disconnect" );
    
    wait 13.0;
    
    if ( isalive( player ) )
    {
        if ( !isdefined( player.omni_enabled ) )
        {
            player.omni_enabled = false;
        }

        if ( !isdefined( player.original_spawn_suit ) && isdefined( player.suit ) )
        {
            player.original_spawn_suit = player.suit;
        }

        player apply_player_omni_state( player.omni_enabled );
        player iprintlnbold( "^2ADS + Melee to toggle Omnimovement" );
    }
    
    player thread watch_player_omni_button();
}

function apply_player_omni_state( enabled )
{
    if ( enabled )
    {
        setdvar( "sprintleap_enabled", "1" );
        setdvar( "scr_test_suit", "" );
        self allowsupersprint( 1 );
        
        if ( isdefined( self.original_spawn_suit ) && self.original_spawn_suit != "sat_defaultsuit_mp_vint" )
        {
            self player::_setsuit( self.original_spawn_suit );
        }
        else
        {
            self player::_setsuit( "sat_defaultsuit_mp" );
        }
        
        self iprintlnbold( "Omnimovement: ^2ON" );
    }
    else
    {
        setdvar( "sprintleap_enabled", "0" );
        setdvar( "scr_test_suit", "sat_defaultsuit_mp_vint" );
        self allowsupersprint( 0 );
        self player::_setsuit( "sat_defaultsuit_mp_vint" );
        
        self iprintlnbold( "Omnimovement: ^1OFF" );
    }
}

function watch_player_omni_button()
{
    self endon( #"disconnect" );
    level endon( #"game_ended" );
    
    while ( true )
    {
        wait 0.05;
        
        // Hold Aim (ADS) + press Melee to toggle ON and OFF
        if ( self adsbuttonpressed() && self meleebuttonpressed() )
        {
            self.omni_enabled = !self.omni_enabled;
            self apply_player_omni_state( self.omni_enabled );
            
            while ( self adsbuttonpressed() || self meleebuttonpressed() )
            {
                wait 0.05;
            }
        }
    }
}

// ============> BO3 HEALTH <============
autoexec bo3_health_init()
{
    setdvar( "zombie_melee_damage_override", "50" );
    setdvar( "zombie_melee_damage_multiplier", "1.0" );
    setdvar( "zombie_melee_trace_range", "24" );
    setdvar( "zombie_melee_moving_trace_range", "24" );
    setdvar( "zombie_melee_vertical_trace_range", "120" );
    setdvar( "zombie_melee_sweep_trace_range", "24" );
    level.var_3f27e31a208b760f = 1.0;
    level.allowarmor = false;
    setdvar( "scr_player_allowarmoroverride", "0" );
    level.zm_mode_modifiers = level.zm_mode_modifiers ?? {};
    level.zm_mode_modifiers.zmmodenoarmor = 1;
    setdvar( "scr_armor_plate_amount", "0" );
    setdvar( "scr_armor_helmet_pop", "0" );
    setdvar( "scr_armor_platepouchcount", "0" );
    level.zombie_vars[ "zombie_perk_juggernaut_health" ] = 100;
    level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ] = 150;
    level.var_9209eecc9aff21ad = true;
    level.var_a009ab14ee0d3223 = level.var_a009ab14ee0d3223 ?? spawnstruct();
    level.var_a009ab14ee0d3223.aitypeoverridemap = level.var_a009ab14ee0d3223.aitypeoverridemap ?? [];
    overrides = [];
    overrides[0] = "zombie_base_armored_light";
    overrides[1] = "zombie_base_armored_heavy";
    overrides[2] = "zombie_base_armored_agni";
    overrides[3] = "zombie_base_armored_metabones";
    overrides[4] = "zombie_armored_light";
    overrides[5] = "zombie_armored_heavy";
    overrides[6] = "zombie_armored";
    overrides[7] = "armored_zombie_light";
    overrides[8] = "armored_zombie_heavy";
    overrides[9] = "armored_zombie";
    overrides[10] = "zombie_base_armored";
    overrides[11] = "zombie_armored_elite";
    overrides[12] = "zombie_armored_boss";
    foreach( override in overrides )
    {
        level.var_a009ab14ee0d3223.aitypeoverridemap[override] = [ "zombie_base" ];
    }
    level thread bo3_health_disable_jugg_augments();
    level callback::add( #"player_spawned", &on_player_spawned_health );
    level callback::add( #"on_zombie_ai_spawned", &on_zombie_ai_spawned );
    level callback::add( #"zm_perk_purchased", &on_zm_perk_purchased );
    level thread bo3_health_think();
    level thread bo3_watch_bundle();
}

function on_player_spawned_health( params )
{
    player = params.player;
    player endon( #"disconnect" );
    wait 0.05;
    if ( isalive( player ) )
    {
        if ( isdefined( player.health_overcharge_data ) )
        {
            player.health_overcharge_data.max_health_overcharge = 0;
            player.health_overcharge_data.overcharge_sources = [];
        }
    }
}

function on_zombie_ai_spawned( params )
{
    zombie = self;
    if ( isdefined( zombie ) && isai( zombie ) )
    {
        zombie_type = zombie.targetname ?? zombie.scriptmodelname ?? zombie.subclass ?? "";
        if ( zombie_type == "zombie_base_armored_light" ||
             zombie_type == "zombie_base_armored_heavy" ||
             zombie_type == "zombie_base_armored_agni" ||
             zombie_type == "zombie_base_armored_metabones" ||
             zombie_type == "zombie_armored_light" ||
             zombie_type == "zombie_armored_heavy" ||
             zombie_type == "zombie_armored" ||
             zombie_type == "armored_zombie_light" ||
             zombie_type == "armored_zombie_heavy" ||
             zombie_type == "armored_zombie" ||
             zombie_type == "zombie_base_armored" ||
             zombie_type == "zombie_armored_elite" ||
             zombie_type == "zombie_armored_boss" )
        {
            zombie.targetname = "zombie_base";
            zombie.scriptmodelname = "zombie_base";
            zombie.subclass = "zombie_base";
        }
    }
}

function on_zm_perk_purchased( params )
{
    player = params.player ?? params.attacker;
    perk = params.perk ?? params.perk_name ?? params.perk_ref;
    if ( perk == "specialty_armorvest" )
    {
        level.zombie_vars[ "zombie_perk_juggernaut_health" ] = 100;
        level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ] = 150;
    }
}

function bo3_health_think()
{
    for(;;)
    {
        level.allowarmor = false;
        level.zm_mode_modifiers.zmmodenoarmor = 1;
        level.zombie_augments[ #"juggernog_juggernaut" ] = level.zombie_augments[ #"juggernog_juggernaut" ] ?? spawnstruct();
        level.zombie_augments[ #"juggernog_juggernaut" ].var_bb0cb5f15169b37c = 0;
        level.zombie_augments[ #"juggernog_iron_core" ] = level.zombie_augments[ #"juggernog_iron_core" ] ?? spawnstruct();
        level.zombie_augments[ #"juggernog_iron_core" ].var_f903e697469224a4 = 0;
        level.var_a009ab14ee0d3223.aitypeoverridemap = level.var_a009ab14ee0d3223.aitypeoverridemap ?? [];
        overrides = [];
        overrides[0] = "zombie_base_armored_light";
        overrides[1] = "zombie_base_armored_heavy";
        overrides[2] = "zombie_base_armored_agni";
        overrides[3] = "zombie_base_armored_metabones";
        overrides[4] = "zombie_armored_light";
        overrides[5] = "zombie_armored_heavy";
        overrides[6] = "zombie_armored";
        overrides[7] = "armored_zombie_light";
        overrides[8] = "armored_zombie_heavy";
        overrides[9] = "armored_zombie";
        overrides[10] = "zombie_base_armored";
        overrides[11] = "zombie_armored_elite";
        overrides[12] = "zombie_armored_boss";
        foreach( override in overrides )
        {
            level.var_a009ab14ee0d3223.aitypeoverridemap[override] = [ "zombie_base" ];
        }
        if ( isdefined( level.var_a009ab14ee0d3223 ) )
        {
            level.var_a009ab14ee0d3223.supersprintinground = 9999;
        }
        level.gametypebundle.disablezombiesupersprint = true;
        level.zombie_vars[ "zombie_perk_juggernaut_health" ] = 100;
        level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ] = 150;
        wait 0.05;
    }
}

function bo3_health_disable_jugg_augments()
{
    level endon( #"game_ended" );
    level waittill( #"zm_augments_init" );
    level.zombie_augments[ #"juggernog_juggernaut" ] = level.zombie_augments[ #"juggernog_juggernaut" ] ?? {};
    level.zombie_augments[ #"juggernog_juggernaut" ].var_bb0cb5f15169b37c = 0;
    level.zombie_augments[ #"juggernog_iron_core" ] = level.zombie_augments[ #"juggernog_iron_core" ] ?? {};
    level.zombie_augments[ #"juggernog_iron_core" ].var_f903e697469224a4 = 0;
    level.zombie_augments[ #"juggernog_perfect_counter" ] = level.zombie_augments[ #"juggernog_perfect_counter" ] ?? {};
    level.zombie_augments[ #"juggernog_perfect_counter" ].var_54b7d92dead9a8c9 = 0;
    level.zombie_augments[ #"juggernog_perfect_counter" ].var_b76a05c80f58dfe8 = 50;
    level.zombie_augments[ #"juggernog_well_constructed" ] = level.zombie_augments[ #"juggernog_well_constructed" ] ?? {};
    level.zombie_augments[ #"juggernog_well_constructed" ].var_855d075ee4c2b737 = 0;
    level.zombie_augments[ #"juggernog_thicker_plates" ] = level.zombie_augments[ #"juggernog_thicker_plates" ] ?? {};
    level.zombie_augments[ #"juggernog_thicker_plates" ].var_fcd4c396ce615ccc = 0;
    level.zombie_augments[ #"juggernog_reactive_armor" ] = level.zombie_augments[ #"juggernog_reactive_armor" ] ?? {};
    level.zombie_augments[ #"juggernog_reactive_armor" ].var_6b758a388f5e7961 = 0;
    level.zombie_augments[ #"juggernog_reactive_armor" ].var_4962fba8ce615ccc = 0;
    level.zombie_augments[ #"juggernog_shielded" ] = level.zombie_augments[ #"juggernog_shielded" ] ?? {};
    level.zombie_augments[ #"juggernog_shielded" ].var_195cd02958ed876 = 0;
    level.zombie_augments[ #"juggernog_shielded" ].var_840d64e41ac5801a = 0;
    level.zombie_augments[ #"juggernog_retaliation" ] = level.zombie_augments[ #"juggernog_retaliation" ] ?? {};
    level.zombie_augments[ #"juggernog_retaliation" ].retaliationduration = 0;
}

function bo3_watch_bundle()
{
    for(;;)
    {
        wait 0.05;
        if ( isdefined( level.var_a009ab14ee0d3223 ) )
        {
		    level.gametypebundle.disablezombiesupersprint = true;
        }
    }
}

// ============> CYMBAL MONKEY & KAZIMIR <============
autoexec zm_tu_autoexec()
{
    level.zm_tu_debug = 0;
    setdvarifuninitialized( @"zm_tu_saved", "" );
    level callback::add( #"player_spawned", &zm_tu_spawned );
    level thread zm_tu_allow_standins();
    level.zm_tu_box = 1;
    level.zm_tu_box_monkey = -1;
    level.zm_tu_box_kazimir = -1;
    level.zm_tu_box_rarity = 3;
    level.zm_tu_box_item = "zm_sat_item_combataxe";
    level.zm_tu_box_debug = 0;
}

function zm_tu_allow_standins()
{
    for ( i = 0; i < 600; i++ )
    {
        if ( isdefined( level.zm_mode_modifiers ) && isdefined( level.equipment ) && isdefined( level.equipment.table ) && isdefined( level.equipment.table[ "equip_blackhole_bomb" ] ) )
        {
            break;
        }
        waitframe();
    }
    if ( !isdefined( level.equipment ) || !isdefined( level.equipment.table ) || !isdefined( level.zm_mode_modifiers ) )
    {
        return;
    }
    kaz = level.equipment.table[ "equip_blackhole_bomb" ];
    kaz.isselectable = 1;
    if ( isdefined( level.equipment.table[ "equip_monkey_bomb" ] ) )
    {
        level.equipment.table[ "equip_monkey_bomb" ].isselectable = 1;
    }
    refs = [ "equip_smoke_gl", "equip_mini_sentry", "equip_drone_launcher", "equip_europa_remote_control", "equip_carrier", "equip_snowball", "equip_trophy" ];
    level.zm_tu_allowed = "";
    foreach ( ref in refs )
    {
        e = level.equipment.table[ ref ];
        if ( !isdefined( e ) )
        {
            if ( ref == "equip_smoke_gl" )
            {
                continue;
            }
            level.equipment.table[ ref ] = kaz;
            level.zm_tu_allowed = level.zm_tu_allowed + ref + "(kaz) ";
            continue;
        }
        level.zm_tu_allowed = level.zm_tu_allowed + ref + "(kept) ";
    }
    logstring( "ZM_TACUNLOCK stand-ins allowed: " + level.zm_tu_allowed );
}

function zm_tu_real_for( ref )
{
    if ( !isdefined( ref ) )
    {
        return undefined;
    }
    r = "" + ref;
    if ( r == "equip_smoke_gl" )
    {
        return "equip_monkey_bomb";
    }
    if ( r == "equip_mini_sentry" || r == "equip_drone_launcher" || r == "equip_europa_remote_control" )
    {
        return "equip_blackhole_bomb";
    }
    if ( r == "equip_carrier" || r == "equip_snowball" || r == "equip_trophy" )
    {
        return "equip_blackhole_bomb";
    }
    return undefined;
}

function zm_tu_s( v )
{
    if ( !isdefined( v ) )
    {
        return "none";
    }
    return "" + v;
}

function zm_tu_spawned( params )
{
    if ( !isdefined( level.zm_mode_modifiers ) )
    {
        return;
    }
    if ( !istrue( level.zm_tu_box_hooked ) && istrue( level.zm_tu_box ) )
    {
        level.zm_tu_box_hooked = 1;
        magicbox::function_1b154b89e87377fa( &zm_tu_box_roll );
        level thread zm_tu_item_hook();
    }
    self thread zm_tu_give();
}

function zm_tu_saved_for_class()
{
    cls = undefined;
    if ( isdefined( self.pers ) && isdefined( self.pers[ "class" ] ) && isstring( self.pers[ "class" ] ) )
    {
        cls = self.pers[ "class" ];
    }
    else if ( isdefined( self.lastclass ) && isstring( self.lastclass ) )
    {
        cls = self.lastclass;
    }
    if ( !isdefined( cls ) || !issubstr( cls, "custom" ) || cls.size <= 6 )
    {
        return undefined;
    }
    n = int( getsubstr( cls, 6, cls.size ) );
    self.zm_tu_dbg = "class " + cls;
    if ( n < 1 )
    {
        return undefined;
    }
    lootid = undefined;
    if ( isdefined( self.loadoutdata ) )
    {
        lootid = self getplayerdata( self.loadoutdata, "loadouts", n - 1, "equipmentSetups", 1, "equipmentLootID" );
        self.zm_tu_dbg = self.zm_tu_dbg + " | lootid " + zm_tu_s( lootid );
    }
    else
    {
        self.zm_tu_dbg = self.zm_tu_dbg + " | no self.loadoutdata";
        if ( isdefined( level.loadoutdata ) )
        {
            ref = self getplayerdata( level.loadoutdata, "squadMembers", "loadouts", n - 1, "equipmentSetups", 1, "equipment" );
            self.zm_tu_dbg = self.zm_tu_dbg + " | saved " + zm_tu_s( ref );
            if ( isstring( ref ) )
            {
                if ( ref == "equip_monkey_bomb" || ref == "equip_blackhole_bomb" )
                {
                    return ref;
                }
                return zm_tu_real_for( ref );
            }
        }
    }
    if ( isdefined( lootid ) && isstring( lootid ) )
    {
        lootid = undefined;
    }
    if ( !isdefined( lootid ) )
    {
        key = "" + ( n - 1 );
        for ( t = 0; t < 12; t++ )
        {
            list = getdvar( @"zm_tu_saved", "" );
            if ( isstring( list ) && list != "" )
            {
                self.zm_tu_dbg = self.zm_tu_dbg + " | menu " + list;
                parts = strtok( list, "," );
                for ( i = 0; i < parts.size; i++ )
                {
                    kv = strtok( parts[ i ], ":" );
                    if ( kv.size == 2 && kv[ 0 ] == key && ( kv[ 1 ] == "equip_monkey_bomb" || kv[ 1 ] == "equip_blackhole_bomb" ) )
                    {
                        return kv[ 1 ];
                    }
                }
                return undefined;
            }
            wait 0.5;
        }
        self.zm_tu_dbg = self.zm_tu_dbg + " | menu list empty";
        return undefined;
    }
    if ( lootid == 99680 || lootid == 84439 )
    {
        return "equip_monkey_bomb";
    }
    if ( lootid == 99681 || lootid == 87702 || lootid == 107161 || lootid == 99682 || lootid == 136418 || lootid == 84432 || lootid == 84405 )
    {
        return "equip_blackhole_bomb";
    }
    return undefined;
}

function zm_tu_give()
{
    self endon( #"disconnect" );
    self endon( #"death" );
    self.zm_tu_dbg = "no class";
    for ( i = 0; i < 60; i++ )
    {
        if ( isdefined( equipment_mp::getcurrentequipment( "secondary" ) ) )
        {
            break;
        }
        wait 0.5;
    }
    wait 1;
    cur = equipment_mp::getcurrentequipment( "secondary" );
    if ( istrue( level.zm_tu_debug ) )
    {
        self iprintlnbold( "TU: tactical " + zm_tu_s( cur ) + " | allowed " + zm_tu_s( level.zm_tu_allowed ) );
    }
    want = zm_tu_real_for( cur );
    if ( !isdefined( want ) )
    {
        want = self zm_tu_saved_for_class();
    }
    if ( istrue( level.zm_tu_debug ) )
    {
        msg = "TU: had " + zm_tu_s( cur ) + " | " + self.zm_tu_dbg + " | give " + zm_tu_s( want ) + " | allowed " + zm_tu_s( level.zm_tu_allowed );
        logstring( msg );
        self iprintlnbold( msg );
    }
    if ( !isdefined( want ) )
    {
        return;
    }
    tries = 0;
    for ( i = 0; i < 20 && tries < 3; i++ )
    {
        cur = equipment_mp::getcurrentequipment( "secondary" );
        if ( isdefined( cur ) && issubstr( "" + cur, "grappling_hook" ) )
        {
            return;
        }
        if ( !isdefined( cur ) || ( "" + cur ) != want )
        {
            if ( isdefined( cur ) )
            {
                equipment_mp::takeequipment( "secondary" );
            }
            self enableoffhandweapons();
            equipment_mp::giveequipment( want, "secondary" );
            tries++;
            logstring( "ZM_TACUNLOCK gave " + want );
            if ( istrue( level.zm_tu_debug ) )
            {
                self iprintlnbold( "TU: gave " + want + " (now " + zm_tu_s( equipment_mp::getcurrentequipment( "secondary" ) ) + ")" );
            }
        }
        wait 0.5;
    }
}

function zm_tu_box_wonder_count()
{
    if ( isdefined( level.zm_tu_box_wonders ) )
    {
        return level.zm_tu_box_wonders;
    }
    n = 0;
    if ( isdefined( level.var_8b6bf63f61fe01f9 ) )
    {
        b = getscriptbundle( level.var_8b6bf63f61fe01f9 );
        if ( isdefined( b ) && isarray( b.itementries ) )
        {
            foreach ( e in b.itementries )
            {
                if ( isdefined( e.weight ) && e.weight > 0 )
                {
                    n++;
                }
            }
        }
    }
    if ( n < 1 )
    {
        n = 1;
    }
    level.zm_tu_box_wonders = n;
    return n;
}

function zm_tu_box_wonder_pct()
{
    if ( !isdefined( level.s_magicbox_scaling ) || !isdefined( level.s_magicbox_scaling.var_e706c54ff9d8cadc ) )
    {
        return 0;
    }
    n_round = 1;
    if ( isdefined( level.round_number ) )
    {
        n_round = level.round_number;
    }
    foreach ( sc in level.s_magicbox_scaling.var_e706c54ff9d8cadc )
    {
        if ( isdefined( sc.minround ) && isdefined( sc.maxround ) && n_round >= sc.minround && n_round <= sc.maxround )
        {
            if ( isdefined( sc.ultrachance ) )
            {
                return sc.ultrachance;
            }
            return 0;
        }
    }
    return 0;
}

function zm_tu_box_odds( pct )
{
    if ( pct >= 0 )
    {
        return pct;
    }
    return zm_tu_box_wonder_pct() / ( zm_tu_box_wonder_count() + 1 );
}

function zm_tu_box_roll( player, str_override_rarity, var_4b076b5c2a1741db )
{
    if ( isdefined( self.var_63e8ca608d91f693 ) )
    {
        return undefined;
    }
    r = randomfloat( 25 );
    k = zm_tu_box_odds( level.zm_tu_box_monkey );
    m = zm_tu_box_odds( level.zm_tu_box_kazimir );
    ref = undefined;
    if ( r < k )
    {
        ref = "equip_monkey_bomb";
    }
    else if ( r < k + m )
    {
        ref = "equip_blackhole_bomb";
    }
    if ( !isdefined( ref ) )
    {
        return undefined;
    }
    if ( isdefined( level.zm_tu_box_live ) )
    {
        zm_tu_box_remove( level.zm_tu_box_live );
    }
    level.zm_tu_box_log = "";
    self.var_63e8ca608d91f693 = level.zm_tu_box_item;
    setdvar( @"hash_6965cd369482e004", "0" );
    level.zm_tu_box_mode_set = 1;
    self thread zm_tu_box_show( ref );
    return undefined;
}

function zm_tu_box_show( ref )
{
    token = gettime();
    self.zm_tu_box_token = token;
    holder = undefined;
    for ( i = 0; i < 400; i++ )
    {
        waitframe();
        if ( self.zm_tu_box_token != token )
        {
            return;
        }
        if ( isdefined( self.mdl_current_weapon ) && isdefined( self.mdl_current_weapon.interact ) && isdefined( self.mdl_current_weapon.var_9ff2f93ccbf71b93 ) )
        {
            holder = self.mdl_current_weapon;
            break;
        }
    }
    self.var_63e8ca608d91f693 = undefined;
    if ( istrue( level.zm_tu_box_mode_set ) )
    {
        setdvar( @"hash_6965cd369482e004", "1" );
        level.zm_tu_box_mode_set = undefined;
    }
    if ( !isdefined( holder ) || holder.var_9ff2f93ccbf71b93.ref != "equip_combataxe" )
    {
        return;
    }
    holder.str_weapon_rarity = "epic";
    display = holder zm_tu_box_display( ref );
    if ( !isdefined( display ) )
    {
        return;
    }
    holder thread zm_tu_box_hide_prompt();
    holder thread zm_tu_box_outline();
    if ( isdefined( self.mdl_magicbox ) )
    {
        self.mdl_magicbox setscriptablepartstate( "base", "opened_epic" );
    }
    level.zm_tu_box_live = display;
    level.zm_tu_melee_dvar_set = 1;
    setdvar( @"hash_9ad1473010eec536", "0" );
    setdvar( @"hash_6965cd369482e004", "0" );
    level thread zm_tu_box_restore_melee( self, holder );
    for ( i = 0; i < 300; i++ )
    {
        wait 0.1;
        if ( !isdefined( display ) || istrue( display.zm_tu_taken ) )
        {
            break;
        }
        if ( !isdefined( holder ) || !isdefined( holder.interact ) || self.zm_tu_box_token != token )
        {
            break;
        }
        if ( !isdefined( self.mdl_current_weapon ) || self.mdl_current_weapon != holder )
        {
            break;
        }
        if ( holder zm_tu_box_melee_check( self ) )
        {
            zm_tu_box_say( "melee seen" );
            holder zm_tu_box_melee_drop( self, display, ref );
            return;
        }
        if ( display.origin[ 2 ] < holder.origin[ 2 ] - 24 )
        {
            zm_tu_box_say( "item knocked down" );
            display.zm_tu_box_display = undefined;
            display.zm_tu_kept = 1;
            display.zm_tu_fullstock = 1;
            self.var_4da360839b7baec4 = 1;
            level thread zm_tu_box_close( holder );
            display thread common_item::items_scriptable_waitandcleanup( 30 );
            break;
        }
    }
    zm_tu_box_remove( display );
}

function zm_tu_box_restore_melee( box, holder )
{
    for ( i = 0; i < 400; i++ )
    {
        if ( !isdefined( holder ) || !isdefined( holder.interact ) || !isdefined( box.mdl_current_weapon ) || box.mdl_current_weapon != holder )
        {
            break;
        }
        wait 0.1;
    }
    if ( istrue( level.zm_tu_melee_dvar_set ) )
    {
        level.zm_tu_melee_dvar_set = undefined;
        setdvar( @"hash_9ad1473010eec536", "1" );
        setdvar( @"hash_6965cd369482e004", "1" );
    }
}

function zm_tu_box_melee_check( box )
{
    roller = box.var_37f3a4cd8252c9f0;
    if ( !isplayer( roller ) || istrue( roller.var_432159241a2f9367 ) )
    {
        return 0;
    }
    if ( !( roller ismeleeing() || istrue( roller.var_23c08b8d00196b63 ) ) )
    {
        return 0;
    }
    if ( distance2dsquared( roller.origin, self.origin ) >= 10000 )
    {
        return 0;
    }
    return utility::within_fov( roller.origin, roller.angles, self.origin, cos( 70 ) );
}

function zm_tu_box_melee_drop( box, display, ref )
{
    if ( isdefined( display ) )
    {
        display.zm_tu_dead = 1;
    }
    box.var_4da360839b7baec4 = 1;
    level zm_tu_box_melee_spawn( box, self, display, ref );
    level thread zm_tu_box_close( self );
}

function zm_tu_box_melee_spawn( box, holder, display, ref )
{
    dropped = undefined;
    how = "";
    roller = box.var_37f3a4cd8252c9f0;
    boxopts = magicbox::function_535a73eae8edf8b7( roller, holder, box );
    pos = undefined;
    ang = ( 0, 0, 0 );
    if ( isdefined( boxopts ) && isdefined( boxopts.baseorigin ) )
    {
        pos = boxopts.baseorigin;
        if ( isdefined( boxopts.baseangles ) )
        {
            ang = boxopts.baseangles;
        }
    }
    else if ( isdefined( box.origin ) )
    {
        pos = box.origin + anglestoforward( box.angles + ( 0, 90, 0 ) ) * 60;
    }
    spawnoptions = boxopts;
    how = "box drop spot";
    if ( !isdefined( spawnoptions ) && isdefined( pos ) )
    {
        spawnoptions = common_item::items_initspawnoptions_spawnfromposition( pos, ang );
        how = "in front of the box";
    }
    if ( isdefined( spawnoptions ) )
    {
        spawnoptions.var_90cdc5dbcd319e5d = 1;
        spawnoptions.rarity = level.zm_tu_box_rarity;
        bundle = common_item::function_cf68ad18114498b2( ref );
        if ( isdefined( bundle ) )
        {
            dropped = common_item::function_61c2c0251e742ffd( bundle, undefined, spawnoptions );
        }
        else
        {
            dropped = common_item::function_325e28c0fb65c36a( ref, 1, spawnoptions );
        }
        if ( isdefined( dropped ) && isarray( dropped ) )
        {
            dropped = dropped[ 0 ];
        }
    }
    if ( !isdefined( dropped ) && isdefined( spawnoptions ) )
    {
        zm_tu_box_say( "drop gave nothing back (" + how + ")" );
        zm_tu_box_remove( display );
        return;
    }
    if ( isdefined( dropped ) )
    {
        zm_tu_box_say( "dropped (" + how + ")" );
        dropped.zm_tu_fullstock = 1;
        dropped.zm_tu_ref = ref;
        zm_tu_box_remove( display );
        dropped thread common_item::items_scriptable_waitandcleanup( 30 );
        return;
    }
    zm_tu_box_say( "drop failed: the floating one stays (still takeable)" );
    if ( isdefined( display ) )
    {
        display.zm_tu_dead = undefined;
        display.zm_tu_box_display = undefined;
        display.zm_tu_kept = 1;
        display.zm_tu_fullstock = 1;
        display thread common_item::items_scriptable_waitandcleanup( 30 );
    }
}

function zm_tu_box_close( holder )
{
    if ( !isdefined( holder ) )
    {
        return;
    }
    box = holder.var_349a0723ed9ac19c;
    zm_tu_box_say( "close: prompt " + isdefined( holder.interact ) + " open " + zm_tu_box_open( box ) );
    live = level.zm_tu_box_live;
    if ( isdefined( live ) && !istrue( live.zm_tu_kept ) )
    {
        zm_tu_box_remove( live );
    }
    prompt = holder.interact;
    if ( isdefined( prompt ) )
    {
        prompt delete();
    }
    if ( isdefined( holder ) )
    {
        holder delete();
    }
    wait 0.1;
    if ( isdefined( live ) && !istrue( live.zm_tu_kept ) && !istrue( live.zm_tu_taken ) )
    {
        zm_tu_box_say( "floating one still there: removing" );
        common_item::function_869d7676e359a627( live, 0 );
    }
    for ( i = 0; i < 50; i++ )
    {
        if ( !isdefined( box ) || !istrue( zm_tu_box_open_flag( box ) ) )
        {
            zm_tu_box_say( "closed " + ( i * 0.1 ) + "s" );
            return;
        }
        wait 0.1;
    }
    zm_tu_box_say( "still open 5s: open " + zm_tu_box_open( box ) );
}

function zm_tu_box_open_flag( box )
{
    if ( !isdefined( box ) || !isdefined( box.mdl_magicbox ) || !isdefined( box.mdl_magicbox.interact ) )
    {
        return 0;
    }
    return istrue( box.mdl_magicbox.interact.b_opened_magicbox );
}

function zm_tu_box_open( box )
{
    if ( !isdefined( box ) || !isdefined( box.mdl_magicbox ) || !isdefined( box.mdl_magicbox.interact ) )
    {
        return "?";
    }
    return "" + istrue( box.mdl_magicbox.interact.b_opened_magicbox );
}

function zm_tu_box_say( text )
{
    logstring( "ZM_TACUNLOCK box: " + text );
    if ( !isdefined( level.zm_tu_box_log ) )
    {
        level.zm_tu_box_log = "";
    }
    level.zm_tu_box_log = level.zm_tu_box_log + " > " + text;
    if ( istrue( level.zm_tu_box_debug ) && isdefined( level.players ) && level.players.size > 0 && isdefined( level.players[ 0 ] ) )
    {
        level.players[ 0 ] iprintlnbold( "TU box:" + level.zm_tu_box_log );
    }
}

function zm_tu_full_stock( ref )
{
    self endon( #"disconnect" );
    waitframe();
    waitframe();
    if ( !isdefined( ref ) )
    {
        return;
    }
    cur = equipment_mp::getcurrentequipment( "secondary" );
    if ( !isdefined( cur ) || ( "" + cur ) != ref )
    {
        return;
    }
    base = undefined;
    bundle = common_item::function_cf68ad18114498b2( ref );
    if ( isdefined( bundle ) )
    {
        base = common_item::function_5f3f8e423378acd6( bundle );
    }
    if ( !isdefined( base ) || base < 1 )
    {
        base = equipment_mp::getequipmentmaxammo( ref );
    }
    if ( !isdefined( base ) || base < 1 )
    {
        return;
    }
    have = equipment_mp::getequipmentslotammo( "secondary" );
    if ( isdefined( have ) && have >= base )
    {
        return;
    }
    equipment_mp::setequipmentammo( ref, base );
}

function zm_tu_box_remove( display )
{
    if ( !isdefined( display ) || istrue( display.zm_tu_taken ) )
    {
        return;
    }
    if ( istrue( display.zm_tu_removed ) || istrue( display.zm_tu_kept ) )
    {
        return;
    }
    display.zm_tu_dead = 1;
    display.zm_tu_removed = 1;
    common_item::function_869d7676e359a627( display, 0 );
}

function zm_tu_box_display( ref )
{
    item = undefined;
    for ( attempt = 0; attempt < 2 && !isdefined( item ); attempt++ )
    {
        if ( attempt == 0 )
        {
            spawnoptions = common_item::function_bc5ff2958b71a708( self.origin, self.angles );
        }
        else
        {
            spawnoptions = common_item::items_initspawnoptions_spawnfromposition( self.origin, self.angles );
            spawnoptions.var_9161cf0784b6951d = 1;
            spawnoptions.var_8d4f327170228364 = 1;
            spawnoptions.var_23d3495c57d61bdf = 1;
            spawnoptions.var_90cdc5dbcd319e5d = 1;
        }
        spawnoptions.var_f35b5b18b029c493 = 0;
        spawnoptions.var_fd47e835523b473f = 1;
        spawnoptions.rarity = level.zm_tu_box_rarity;
        item = common_item::function_325e28c0fb65c36a( ref, 1, spawnoptions );
        if ( isdefined( item ) && isarray( item ) )
        {
            if ( item.size > 0 )
            {
                item = item[ 0 ];
            }
            else
            {
                item = undefined;
            }
        }
    }
    if ( !isdefined( item ) )
    {
        logstring( "ZM_TACUNLOCK box: " + ref + " item could not spawn" );
        return undefined;
    }
    item.zm_tu_box_display = 1;
    item.zm_tu_box_holder = self;
    item.zm_tu_ref = ref;
    item utility::scriptable_clearparententity();
    item utility::scriptable_setparententity( self );
    return item;
}

function zm_tu_box_hide_prompt()
{
    for ( i = 0; i < 40 && isdefined( self ); i++ )
    {
        if ( isdefined( self.interact ) )
        {
            self.interact disableplayeruseforallplayers();
        }
        wait 0.2;
    }
}

function zm_tu_box_outline()
{
    if ( isdefined( self.n_outline_id ) )
    {
        outline::outlinedisable( self.n_outline_id, self );
        self.n_outline_id = undefined;
    }
    self.n_outline_id = outline::outlineenableforall( self, "outline_depth_purple", "level_script" );
}

function zm_tu_item_hook()
{
    level endon( #"game_ended" );
    for ( i = 0; i < 120; i++ )
    {
        if ( isdefined( level.commonitem ) && isdefined( level.commonitem.itemcallbacks ) && isdefined( level.commonitem.itemcallbacks[ "tactical" ] ) && isdefined( level.commonitem.itemcallbacks[ "tactical" ].funcs ) && isdefined( level.commonitem.itemcallbacks[ "tactical" ].funcs[ #"use" ] ) )
        {
            f = level.commonitem.itemcallbacks[ "tactical" ].funcs[ #"use" ];
            if ( f != &zm_tu_tactical_use )
            {
                level.zm_tu_tactical_use = f;
                level.commonitem.itemcallbacks[ "tactical" ].funcs[ #"use" ] = &zm_tu_tactical_use;
            }
            g = level.commonitem.itemcallbacks[ "tactical" ].funcs[ #"canautouse" ];
            if ( isdefined( g ) && g != &zm_tu_tactical_canautouse )
            {
                level.zm_tu_tactical_canautouse = g;
                level.commonitem.itemcallbacks[ "tactical" ].funcs[ #"canautouse" ] = &zm_tu_tactical_canautouse;
            }
            return;
        }
        wait 1;
    }
}

function zm_tu_tactical_canautouse( itembundle, item, autouse, allowswap )
{
    if ( isdefined( item ) && istrue( item.zm_tu_box_display ) )
    {
        return 0;
    }
    return self [[ level.zm_tu_tactical_canautouse ]]( itembundle, item, autouse, allowswap );
}

function zm_tu_tactical_use( itembundle, item, autouse, spawnoptions )
{
    if ( isdefined( item ) && istrue( item.zm_tu_box_display ) )
    {
        if ( istrue( autouse ) || istrue( item.zm_tu_taken ) )
        {
            return 1;
        }
        holder = item.zm_tu_box_holder;
        if ( istrue( item.zm_tu_dead ) || !isdefined( holder ) || !isdefined( holder.interact ) )
        {
            level thread zm_tu_box_remove( item );
            return 1;
        }
        if ( isdefined( holder ) && isdefined( holder.var_349a0723ed9ac19c ) )
        {
            box = holder.var_349a0723ed9ac19c;
            if ( isplayer( box.var_37f3a4cd8252c9f0 ) && !istrue( box.var_4da360839b7baec4 ) && self != box.var_37f3a4cd8252c9f0 )
            {
                return 1;
            }
        }
        if ( self zm_tu_swap_same( zm_tu_item_ref( item, itembundle ) ) )
        {
            item.zm_tu_taken = 1;
            if ( isdefined( holder ) && isdefined( holder.interact ) )
            {
                holder.interact notify( #"picked_up_weapon" );
            }
            return 0;
        }
        left = 0;
        if ( isdefined( level.zm_tu_tactical_use ) )
        {
            left = self [[ level.zm_tu_tactical_use ]]( itembundle, item, autouse, spawnoptions );
        }
        if ( isdefined( left ) && left > 0 )
        {
            return left;
        }
        item.zm_tu_taken = 1;
        zm_tu_box_say( "taken from the box: telling the box (interact " + ( isdefined( holder ) && isdefined( holder.interact ) ) + ")" );
        self thread zm_tu_full_stock( zm_tu_item_ref( item, itembundle ) );
        if ( isdefined( holder ) && isdefined( holder.interact ) )
        {
            holder.interact notify( #"picked_up_weapon" );
        }
        return 0;
    }
    if ( isdefined( item ) && istrue( item.zm_tu_fullstock ) && !istrue( autouse ) && self zm_tu_swap_same( zm_tu_item_ref( item, itembundle ) ) )
    {
        item.zm_tu_fullstock = undefined;
        return 0;
    }
    if ( isdefined( item ) && istrue( item.zm_tu_fullstock ) && isdefined( level.zm_tu_tactical_use ) )
    {
        left = self [[ level.zm_tu_tactical_use ]]( itembundle, item, autouse, spawnoptions );
        if ( !isdefined( left ) || left == 0 )
        {
            self thread zm_tu_full_stock( zm_tu_item_ref( item, itembundle ) );
        }
        return left;
    }
    if ( isdefined( level.zm_tu_tactical_use ) )
    {
        return self [[ level.zm_tu_tactical_use ]]( itembundle, item, autouse, spawnoptions );
    }
    return 0;
}

function zm_tu_swap_same( ref )
{
    if ( !isdefined( ref ) )
    {
        return 0;
    }
    cur = equipment_mp::getcurrentequipment( "secondary" );
    if ( !isdefined( cur ) || ( "" + cur ) != ref )
    {
        return 0;
    }
    have = equipment_mp::getequipmentslotammo( "secondary" );
    if ( !isdefined( have ) || have < 1 )
    {
        have = 1;
    }
    spawnoptions = common_item::items_initspawnoptions_spawnfromentity( self );
    spawnoptions.var_90cdc5dbcd319e5d = 1;
    spawnoptions.originalowner = self;
    common_item::function_325e28c0fb65c36a( ref, have, spawnoptions );
    equipment_mp::takeequipment( "secondary" );
    self enableoffhandweapons();
    equipment_mp::giveequipment( ref, "secondary" );
    self thread zm_tu_full_stock( ref );
    return 1;
}

function zm_tu_item_ref( item, itembundle )
{
    if ( isdefined( itembundle ) && isdefined( itembundle.ref ) )
    {
        r = "" + itembundle.ref;
        if ( r == "equip_monkey_bomb" || r == "equip_blackhole_bomb" )
        {
            return r;
        }
    }
    if ( isdefined( item ) && isdefined( item.zm_tu_ref ) )
    {
        return item.zm_tu_ref;
    }
    return undefined;
}

// ============> Wonder Weapons Infinite Damange <============
function private install_ww_instakill()
{
    level.cursed_ww_min_pap = 3;
    level.cursed_ww_double_pap = 4;
    level.cursed_ww_family = [];
    level.cursed_ww_family[ "sat_ww_firefly_zm" ] = "sat_ww_firefly";
    level.cursed_ww_family[ "sat_ww_firefly_ee_zm" ] = "sat_ww_firefly";
    level.cursed_ww_family[ "sat_ww_firefly_liquid_zm" ] = "sat_ww_firefly";
    level.cursed_ww_family[ "sat_ww_hornet_zm" ] = "sat_ww_hornet";
    level.cursed_ww_family[ "sat_ww_locust_zm" ] = "sat_ww_locust";
    level.cursed_ww_family[ "sat_ww_locust_fireball" ] = "sat_ww_locust";
    level.cursed_ww_family[ "sat_ww_mantis_zm" ] = "sat_ww_mantis";
    level.cursed_ww_family[ "sat_ww_ruby_zm" ] = "sat_ww_ruby";
    level.cursed_ww_family[ "sat_ww_scarab_zm" ] = "sat_ww_scarab";
    foreach ( weapon_name, family in level.cursed_ww_family )
    {
        level zombie_utils::register_zombie_weapon_damage_callback( weapon_name, &ww_instakill_damage );
    }
    level.cursed_ww_armored_subclass = [];
    level.cursed_ww_armored_subclass[ "zombie_base_armored_light" ] = 1;
    level.cursed_ww_armored_subclass[ "zombie_base_armored_heavy" ] = 1;
    level.cursed_ww_armored_subclass[ "zombie_base_armored_heavy_no_armor" ] = 1;
}

function private ww_family_pap_level( player, family )
{
    best = 0;
    if ( !isdefined( player.a_n_current_pap_level ) )
    {
        return best;
    }
    foreach ( papstruct in player.a_n_current_pap_level )
    {
        if ( !isdefined( papstruct ) || !isweapon( papstruct.weapon ) )
        {
            continue;
        }
        if ( issubstr( papstruct.weapon.basename, family ) && ( papstruct.n_level ?? 0 ) > best )
        {
            best = papstruct.n_level;
        }
    }
    return best;
}

function private ww_instakill_damage( dmg_struct )
{
    if ( !supported_mode() )
    {
        return -1;
    }
    if ( !isdefined( dmg_struct.idamage ) || dmg_struct.idamage <= 0 )
    {
        return -1;
    }
    if ( dmg_struct.smeansofdeath === "MOD_MELEE" )
    {
        return -1;
    }
    attacker = dmg_struct.eattacker;
    if ( isdefined( attacker ) && !isplayer( attacker ) && isdefined( attacker.owner ) && isplayer( attacker.owner ) )
    {
        attacker = attacker.owner;
    }
    if ( !isdefined( attacker ) || !isplayer( attacker ) )
    {
        return -1;
    }
    if ( istrue( self.damageshield ) )
    {
        return -1;
    }
    if ( !isdefined( dmg_struct.sweapon ) || !isdefined( self.health ) )
    {
        return -1;
    }
    family = level.cursed_ww_family[ dmg_struct.sweapon.basename ];
    if ( !isdefined( family ) )
    {
        return -1;
    }
    n_pap = ww_family_pap_level( attacker, family );
    is_armored = isdefined( self.subclass ) && isdefined( level.cursed_ww_armored_subclass[ self.subclass ] ) && !( self.aicategory === "boss" ) && !( self.aicategory === "hvt" );
    is_plain_normal = self.aicategory === "normal" && !issubstr( self.subclass ?? "", "armored" ) && !( isdefined( self.armorhealth ) && self.armorhealth > 0 );
    if ( ( is_armored || is_plain_normal ) && n_pap >= level.cursed_ww_min_pap )
    {
        dmg_struct.bskipexposedhead = 1;
        if ( is_armored )
        {
            if ( !istrue( self.killondamage ) )
            {
                self.killondamage = 1;
                self thread ww_killondamage_restore();
            }
        }
        return int( self.health ) + 1;
    }
    if ( n_pap >= level.cursed_ww_double_pap && !( self.aicategory === "boss" ) )
    {
        return int( dmg_struct.idamage * 1.7 );
    }
    return -1;
}

// helpers that were missing from your snippet - needed to compile
function supported_mode()
{
    return isdefined( level.zm_mode_modifiers );
}

function ww_killondamage_restore()
{
    self endon( #"death" );
    waitframe();
    waitframe();
    self.killondamage = 0;
}

// ============> Classic Perks & Wonderfiz <============
autoexec zm_classic_perks_init()
{
    level thread zm_classic_perks_start();
}

zm_classic_perks_ids()
{
    if (!isdefined(level.zm_cp_perk_ids))
    {
        ids = [];
        ids[ids.size] = "specialty_juggernog";
        ids[ids.size] = "specialty_quickrevive";
        ids[ids.size] = "specialty_speedcola";
        ids[ids.size] = "specialty_staminup";
        ids[ids.size] = "specialty_deadshot";
        ids[ids.size] = "specialty_death_perception";
        ids[ids.size] = "specialty_phd_flopper";
        ids[ids.size] = "specialty_vulture_aid";
        ids[ids.size] = "specialty_elemental_pop";
        ids[ids.size] = "specialty_d_mod";
        ids[ids.size] = "specialty_m_mod";
        ids[ids.size] = "specialty_w_mod";
        ids[ids.size] = "specialty_y_mod";
        ids[ids.size] = "specialty_z_mod";
        level.zm_cp_perk_ids = ids;
    }
    return level.zm_cp_perk_ids;
}

zm_classic_perks_start()
{
    level endon(#"game_ended");

    while (!isdefined(level.perk_machine_func))
    {
        waitframe();
    }

    zm_classic_perks_price("specialty_juggernog");

    level utility::registersharedfunc(#"perk_machine", #"hash_dfdcc3fdc88af90c", &zm_classic_perks_machine_price);

    level.perk_machine_func["on_use_choice"] = &zm_classic_perks_wunderfizz_use;
    level.perk_machine_func["per_player_hint_choice"] = &zm_classic_perks_wunderfizz_hint;

    level thread zm_classic_perks_wunderfizz_watch();

    while (!isdefined(level._custom_perks) || !isdefined(level._custom_perks["specialty_choice"]))
    {
        waitframe();
    }
    level._custom_perks["specialty_choice"].cost = 1500;
}

zm_classic_perks_perk_from_hint(hint)
{
    if (!isstruct(hint) || !isarray(level._custom_perks))
    {
        return undefined;
    }

    ids = zm_classic_perks_ids();
    foreach (perk_id in ids)
    {
        info = level._custom_perks[perk_id];
        if (!isdefined(info))
        {
            continue;
        }
        if (isdefined(hint.title) && isdefined(info.hint_name) && hint.title == info.hint_name)
        {
            return perk_id;
        }
        if (isdefined(hint.description) && isdefined(info.buy_description) && hint.description == info.buy_description)
        {
            return perk_id;
        }
        if (isdefined(hint.icon) && isdefined(info.icon) && hint.icon == info.icon)
        {
            return perk_id;
        }
    }
    return undefined;
}

zm_classic_perks_machine_price(usable)
{
    perk = undefined;

    if (isdefined(usable))
    {
        if (isdefined(usable.zm_cp_perk))
        {
            perk = usable.zm_cp_perk;
        }

        if (!isdefined(zm_classic_perks_price(perk)))
        {
            candidate = zm_classic_perks_normalize_perk(usable.script_notify);
            if (isdefined(zm_classic_perks_price(candidate)))
            {
                perk = candidate;
            }
        }
        if (!isdefined(zm_classic_perks_price(perk)) && isdefined(usable.s_perk_machine))
        {
            candidate = zm_classic_perks_normalize_perk(usable.s_perk_machine.script_noteworthy);
            if (isdefined(zm_classic_perks_price(candidate)))
            {
                perk = candidate;
            }
        }
    }

    return zm_classic_perks_price(perk);
}

zm_classic_perks_normalize_perk(perk)
{
    if (!isdefined(perk))
    {
        return undefined;
    }
    if (!isstring(perk))
    {
        return perk;
    }

    if (perk == "talent_juggernog" || perk == "specialty_juggernog" || perk == "juggernog" || perk == "perk_juggernog")
    {
        return "specialty_juggernog";
    }

    if (perk == "talent_quickrevive" || perk == "talent_quick_revive" || perk == "specialty_quickrevive" || perk == "quickrevive" || perk == "quick_revive" || perk == "perk_quickrevive")
    {
        return "specialty_quickrevive";
    }

    if (perk == "talent_speedcola" || perk == "talent_speed_cola" || perk == "specialty_speedcola" || perk == "speedcola" || perk == "speed_cola" || perk == "perk_speedcola")
    {
        return "specialty_speedcola";
    }

    if (perk == "talent_staminup" || perk == "talent_stamin_up" || perk == "specialty_staminup" || perk == "staminup" || perk == "stamin_up" || perk == "perk_staminup")
    {
        return "specialty_staminup";
    }

    if (perk == "talent_deadshot" || perk == "talent_dead_shot" || perk == "specialty_deadshot" || perk == "deadshot" || perk == "dead_shot" || perk == "perk_deadshot")
    {
        return "specialty_deadshot";
    }

    if (perk == "talent_death_perception" || perk == "specialty_death_perception" || perk == "death_perception" || perk == "perk_death_perception")
    {
        return "specialty_death_perception";
    }

    if (perk == "talent_phd_flopper" || perk == "talent_phdflopper" || perk == "specialty_phd_flopper" || perk == "phd_flopper" || perk == "phdflopper" || perk == "perk_phd_flopper")
    {
        return "specialty_phd_flopper";
    }

    if (perk == "talent_vulture_aid" || perk == "talent_vultureaid" || perk == "specialty_vulture_aid" || perk == "vulture_aid" || perk == "vultureaid" || perk == "perk_vulture_aid")
    {
        return "specialty_vulture_aid";
    }

    if (perk == "talent_elemental_pop" || perk == "talent_elementalpop" || perk == "specialty_elemental_pop" || perk == "elemental_pop" || perk == "elementalpop" || perk == "perk_elemental_pop")
    {
        return "specialty_elemental_pop";
    }

    if (perk == "talent_d_mod" || perk == "specialty_d_mod" || perk == "d_mod" || perk == "perk_d_mod")
    {
        return "specialty_d_mod";
    }
    if (perk == "talent_m_mod" || perk == "specialty_m_mod" || perk == "m_mod" || perk == "perk_m_mod")
    {
        return "specialty_m_mod";
    }
    if (perk == "talent_w_mod" || perk == "specialty_w_mod" || perk == "w_mod" || perk == "perk_w_mod")
    {
        return "specialty_w_mod";
    }
    if (perk == "talent_y_mod" || perk == "specialty_y_mod" || perk == "y_mod" || perk == "perk_y_mod")
    {
        return "specialty_y_mod";
    }
    if (perk == "talent_z_mod" || perk == "specialty_z_mod" || perk == "z_mod" || perk == "perk_z_mod")
    {
        return "specialty_z_mod";
    }

    return perk;
}

zm_classic_perks_price(perk)
{
    if (!isdefined(perk))
    {
        return undefined;
    }

    if (!isdefined(level.zm_classic_perk_prices))
    {
        level.zm_classic_perk_prices = [];
        level.zm_classic_perk_prices["specialty_juggernog"] = 2500;
        level.zm_classic_perk_prices["specialty_quickrevive"] = 500;
        level.zm_classic_perk_prices["specialty_speedcola"] = 3000;
        level.zm_classic_perk_prices["specialty_staminup"] = 2000;
        level.zm_classic_perk_prices["specialty_deadshot"] = 1500;
        level.zm_classic_perk_prices["specialty_death_perception"] = 1500;
        level.zm_classic_perk_prices["specialty_phd_flopper"] = 2000;
        level.zm_classic_perk_prices["specialty_vulture_aid"] = 3000;
        level.zm_classic_perk_prices["specialty_elemental_pop"] = 3500;
        level.zm_classic_perk_prices["specialty_d_mod"] = 2000;
        level.zm_classic_perk_prices["specialty_m_mod"] = 2000;
        level.zm_classic_perk_prices["specialty_w_mod"] = 2000;
        level.zm_classic_perk_prices["specialty_y_mod"] = 4000;
        level.zm_classic_perk_prices["specialty_z_mod"] = 4000;
        level.zm_classic_perk_prices["specialty_choice"] = 1500;
    }

    if (!isstring(perk))
    {
        foreach (key, value in level.zm_classic_perk_prices)
        {
            hashed = key;
            if (isstring(key))
            {
                hashed = getxhash(key);
            }
            if (hashed == perk)
            {
                return value;
            }
        }
        return undefined;
    }

    return level.zm_classic_perk_prices[perk];
}

zm_classic_perks_at_limit(player)
{
    if (level.gametypebundle.perklimit > 0 && isdefined(player.var_468836e5e67e15b4) && player.var_468836e5e67e15b4 >= level.gametypebundle.perklimit)
    {
        return true;
    }
    return false;
}

zm_classic_perks_wunderfizz_watch()
{
    level endon(#"game_ended");
    while (!isdefined(level.a_s_perk_machines))
    {
        waitframe();
    }

    while (true)
    {
        foreach (s_machine in level.a_s_perk_machines)
        {
            if (!isdefined(s_machine) || !isdefined(s_machine.mdl_perk_machine))
            {
                continue;
            }

            interact = s_machine.mdl_perk_machine.interact;
            if (!isdefined(interact))
            {
                continue;
            }
            if (isdefined(interact.zm_classic_perks_bound) && interact.zm_classic_perks_bound)
            {
                continue;
            }

            if (isdefined(s_machine.is_wunderfizz) && s_machine.is_wunderfizz)
            {
                interact interaction::set_interact_use_callback(&zm_classic_perks_wunderfizz_use);
                interact interaction::set_interact_hint_callback(&zm_classic_perks_wunderfizz_hint);
            }
            else
            {
                if (isfunction(interact.interact_hint_callback))
                {
                    interact.zm_cp_orig_hint = interact.interact_hint_callback;
                    interact interaction::set_interact_hint_callback(&zm_classic_perks_hint_wrapper);
                }
                if (isarray(interact.var_d8e3b07237845727) && interact.var_d8e3b07237845727.size > 0 && isfunction(interact.var_d8e3b07237845727[0]))
                {
                    interact.zm_cp_orig_use = interact.var_d8e3b07237845727[0];
                    interact interaction::set_interact_use_callback(&zm_classic_perks_use_wrapper);
                }
            }
            interact.zm_classic_perks_bound = 1;
        }

        wait 0.1;
    }
}

zm_classic_perks_hint_wrapper(usable, player)
{
    orig = usable.zm_cp_orig_hint;
    if (!isfunction(orig))
    {
        return {#string:&"", #type:"HINT_NOBUTTON"};
    }

    hint = [[ orig ]](usable, player);

    if (!isstruct(hint))
    {
        return hint;
    }

    perk = usable.zm_cp_perk;
    if (!isdefined(perk))
    {
        perk = zm_classic_perks_perk_from_hint(hint);
        if (isdefined(perk))
        {
            usable.zm_cp_perk = perk;
        }
        else
        {
            return hint;
        }
    }

    price = zm_classic_perks_price(perk);
    if (!isdefined(price))
    {
        return hint;
    }

    if (!isdefined(hint.icon_text_value))
    {
        return hint;
    }
    hint.icon_text_value = price;

    if (isdefined(player) && (!isdefined(hint.interactable) || hint.interactable != 0))
    {
        if (!player currency::can_afford(currency::get_perk_machine_currency(perk), price))
        {
            hint.aux_text = &"shared_hintstrings/not_enough_essence";
            hint.var_776a268784e089af = &"shared_hintstrings/cost_essence_not_enough";
            hint.interactable = 0;
        }
    }
    else if (isdefined(player) && isdefined(hint.aux_text) && hint.aux_text == &"shared_hintstrings/not_enough_essence")
    {
        if (player currency::can_afford(currency::get_perk_machine_currency(perk), price))
        {
            hint.aux_text = undefined;
            hint.var_776a268784e089af = &"shared_hintstrings/cost_essence";
            hint.interactable = 1;
        }
    }

    return hint;
}

zm_classic_perks_use_wrapper(player)
{
    orig = self.zm_cp_orig_use;
    if (!isfunction(orig))
    {
        return;
    }

    if (isdefined(level.gametypebundle.var_5fca731c160ce025) && level.gametypebundle.var_5fca731c160ce025 && isdefined(player))
    {
        perk = self.script_notify;
        s_machine = self.s_perk_machine;
        price = zm_classic_perks_machine_price(self);

        if (isdefined(perk) && isdefined(price) && isdefined(s_machine) && isdefined(s_machine.script_currency) && isdefined(level._custom_perks[perk]))
        {
            if (self getscriptablepartstate("base") == "power_off")
            {
                return;
            }
            if (player zombie_perks::has_perk(level._custom_perks[perk].str_perk_root))
            {
                return;
            }
            if (level.var_c139731c583cae6b || !player val::get("allow_zm_perks") || player.interactions_disabled)
            {
                return;
            }
            if (zm_classic_perks_at_limit(player) || player zombie_perks::function_cda78d45986a51a0())
            {
                return;
            }
            if (!player currency::attempt_purchase(s_machine.script_currency, price, 1, undefined, #"perk", perk))
            {
                return;
            }
        }
    }

    self [[ orig ]](player);
}

zm_classic_perks_wunderfizz_use(player)
{
    if (!isdefined(player))
    {
        return;
    }
    if (player.interactions_disabled)
    {
        return;
    }
    if (!isdefined(self.s_perk_machine) || !isdefined(self.s_perk_machine.mdl_perk_machine))
    {
        return;
    }
    if (zm_classic_perks_has_all(player))
    {
        zm_classic_perks_eternal_use(self, player, "specialty_choice");
        return;
    }
    if (zm_classic_perks_at_limit(player))
    {
        return;
    }

    mdl = self.s_perk_machine.mdl_perk_machine;
    if (mdl getscriptablepartstate("base") == "power_off")
    {
        return;
    }
    if (level.var_c139731c583cae6b || !player val::get("allow_zm_perks"))
    {
        return;
    }

    valid = zombie_perks::get_perks_str_array();
    active = player zombie_perks::get_active_perks_str_array();
    if (isarray(active))
    {
        valid = arrayremove(valid, active);
    }
    if (isdefined(player.disallow_zombie_perks) && player.disallow_zombie_perks.size > 0)
    {
        valid = arrayremove(valid, player.disallow_zombie_perks);
    }
    if (!isarray(valid) || valid.size == 0)
    {
        return;
    }

    perk = zombie_perks::get_random_perk_str(valid);
    if (!isdefined(perk))
    {
        return;
    }

    cost = zm_classic_perks_price("specialty_choice");
    currency = self.s_perk_machine.script_currency;
    if (!isdefined(currency))
    {
        currency = #"essence";
    }
    if (!player currency::attempt_purchase(currency, cost, 1, undefined, #"perk"))
    {
        return;
    }
    if (mdl getscriptablehaspart("use") && mdl getscriptablepartstate("use") == "default")
    {
        mdl setscriptablepartstate("use", "purchase");
    }

    params = spawnstruct();
    params.perk_machine = self;
    player callback::callback("zm_perk_machine_used", params);

    playing = 0;
    gesture = undefined;
    if (isdefined(level._custom_perks[perk]))
    {
        gesture = level._custom_perks[perk].perk_bottle_weapon;
    }
    if (isdefined(gesture))
    {
        player thread zombie_perks::function_13cc8b1c31dda8c4(gesture);
        playing = 1;
    }
    player zombie_perks::give_perk(perk, 1, playing);
    bought = spawnstruct();
    bought.perkref = perk;
    bought.cost = cost;
    bought.currency = currency;
    bought.source = #"wunderfizz";
    player callback::callback("zm_perk_purchased", bought);
}

zm_classic_perks_wunderfizz_hint(usable, player)
{

    if (!isdefined(player) || !isdefined(usable))
    {
        return {#string:&"", #type:"HINT_NOICON"};
    }

    info = level._custom_perks["specialty_choice"];
    if (!isdefined(info))
    {
        return {#string:&"", #type:"HINT_NOICON"};
    }

    cost = zm_classic_perks_price("specialty_choice");
    hint = {#icon_text_value:cost, #var_776a268784e089af:&"shared_hintstrings/cost_essence", #buttoncallout:&"shared_hintstrings/perk_machine_buy", #icon:info.icon, #description:info.buy_description, #title:info.hint_name, #type:"HINT_BUTTON"};

    if (usable getscriptablepartstate("base") == "power_off")
    {
        hint.aux_text = usable.var_4256b14b47d5e763 ?? &"shared_hintstrings/need_power_red";
        hint.interactable = 0;
        return hint;
    }
    if (zm_classic_perks_has_all(player))
    {
        return zm_classic_perks_eternal_hint(usable, player, hint, "specialty_choice");
    }
    if (zm_classic_perks_at_limit(player))
    {
        return {#string:&"", #type:"HINT_NOBUTTON"};
    }
    if (player.interactions_disabled)
    {
        return {#string:&"", #type:"HINT_NOICON"};
    }
    if (!player currency::can_afford(currency::get_perk_machine_currency("specialty_choice"), cost))
    {
        hint.aux_text = &"shared_hintstrings/not_enough_essence";
        hint.var_776a268784e089af = &"shared_hintstrings/cost_essence_not_enough";
        hint.interactable = 0;
    }

    return hint;
}

zm_classic_perks_eternal_price()
{
    return 8000;
}

zm_classic_perks_has_all(player)
{
    if (!isdefined(player))
    {
        return false;
    }
    return player zombie_perks::function_cda78d45986a51a0();
}

zm_classic_perks_can_go_eternal(player)
{
    if (!zm_classic_perks_has_all(player))
    {
        return false;
    }

    active = player zombie_perks::get_active_perks_str_array();
    if (!isarray(active))
    {
        return false;
    }
    if (isdefined(player.perma_perks))
    {
        active = arrayremove(active, player.perma_perks);
    }
    if (active.size == 0)
    {
        return false;
    }
    return true;
}

zm_classic_perks_eternal_hint(usable, player, orig_hint, perk)
{
    if (usable getscriptablepartstate("base") == "power_off")
    {
        return orig_hint;
    }
    if (player.interactions_disabled || !zm_classic_perks_can_go_eternal(player))
    {
        return {#string:&"", #type:"HINT_NOBUTTON"};
    }

    cost = zm_classic_perks_eternal_price();
    hint = {#icon_text_value:cost, #var_776a268784e089af:&"shared_hintstrings/cost_essence", #buttoncallout:&"shared_hintstrings/perk_machine_buy", #title:&"ZM_RB_ECHO/PORTAL_TITLE_PERMANENT_PERK", #type:"HINT_BUTTON"};

    info = undefined;
    if (isdefined(perk) && isarray(level._custom_perks))
    {
        info = level._custom_perks[perk];
    }
    if (isdefined(info))
    {
        hint.icon = info.icon;
        hint.description = info.buy_description;
    }

    currency = #"essence";
    if (isdefined(perk) && isdefined(level._custom_perks[perk]))
    {
        currency = currency::get_perk_machine_currency(perk);
    }
    if (!player currency::can_afford(currency, cost))
    {
        hint.aux_text = &"shared_hintstrings/not_enough_essence";
        hint.var_776a268784e089af = &"shared_hintstrings/cost_essence_not_enough";
        hint.interactable = 0;
    }

    return hint;
}

zm_classic_perks_eternal_use(usable, player, perk)
{
    if (!isdefined(usable) || !isdefined(player))
    {
        return;
    }
    if (player.interactions_disabled || player.insertingarmorplate)
    {
        return;
    }
    if (usable getscriptablepartstate("base") == "power_off")
    {
        return;
    }
    if (level.var_c139731c583cae6b || !player val::get("allow_zm_perks"))
    {
        return;
    }
    if (!zm_classic_perks_can_go_eternal(player))
    {
        return;
    }

    cost = zm_classic_perks_eternal_price();
    currency = #"essence";
    if (isdefined(usable.s_perk_machine) && isdefined(usable.s_perk_machine.script_currency))
    {
        currency = usable.s_perk_machine.script_currency;
    }
    if (!player currency::attempt_purchase(currency, cost, 1, undefined, #"perk"))
    {
        return;
    }

    mdl = usable;
    if (isdefined(usable.s_perk_machine) && isdefined(usable.s_perk_machine.mdl_perk_machine))
    {
        mdl = usable.s_perk_machine.mdl_perk_machine;
    }
    if (mdl getscriptablehaspart("use") && mdl getscriptablepartstate("use") == "default")
    {
        mdl setscriptablepartstate("use", "purchase");
    }

    params = spawnstruct();
    params.perk_machine = usable;
    player callback::callback("zm_perk_machine_used", params);

    before = 0;
    if (isdefined(player.perma_perks))
    {
        before = player.perma_perks.size;
    }

    player zombie_perks::function_ab9b4123275d6153(undefined, 1, 0, 1);

    if (isdefined(player.perma_perks) && player.perma_perks.size > before)
    {
        bought = spawnstruct();
        bought.perkref = player.perma_perks[player.perma_perks.size - 1];
        bought.cost = cost;
        bought.currency = currency;
        bought.source = #"perk_machine";
        player callback::callback("zm_perk_purchased", bought);
    }
}

// ========> MAP WONDER WEAPONS: AVAILABLE AT MATCH START <========
function private unlock_map_wonder_weapons()
{
    level endon( #"game_ended" );
    utility::flag_wait( "setup_magicbox_weapons" );
    utility::flag_wait( "magicbox_ready" );

    ensure_map_wonder_list();
    level thread unlock_map_wonder_loop();
}


function private ensure_map_wonder_list()
{
    bundle = getscriptbundle( "magicbox:magicbox_sat_zm" );
    if ( !isdefined( bundle ) || !isdefined( bundle.magicboxmapwonderweapons ) )
    {
        return;
    }
    map_list = undefined;
    foreach ( wonderweaponliststruct in bundle.magicboxmapwonderweapons )
    {
        if ( isdefined( wonderweaponliststruct.wonderweaponlist ) && wonderweaponliststruct.mapname == getxhash( level.mapname ) )
        {
            map_list = wonderweaponliststruct.wonderweaponlist;
            break;
        }
    }
    if ( !isdefined( map_list ) || level.var_8b6bf63f61fe01f9 === map_list )
    {
        return; // map has no Wonder Weapon list, or it is already in use
    }
    level.var_8b6bf63f61fe01f9 = map_list;
    list_bundle = getscriptbundle( map_list );
    if ( isdefined( list_bundle ) && isarray( list_bundle.itementries ) )
    {
        if ( !isdefined( level.var_c5111f0d24e5789a ) )
        {
            level.var_c5111f0d24e5789a = [];
        }
        foreach ( s_itementry in list_bundle.itementries )
        {
            if ( isdefined( s_itementry.itemspawnentry ) )
            {
                level.var_c5111f0d24e5789a = arraycombineunique( level.var_c5111f0d24e5789a, [ s_itementry.itemspawnentry ] );
            }
        }
    }
	
    logstring( "" );
}

function private set_map_wonder_limit( item_name, limit )
{
    if ( !isdefined( level.a_magicbox_item_limits ) )
    {
        return;
    }
    if ( isdefined( level.a_magicbox_item_limits[ item_name ] ) &&
         level.a_magicbox_item_limits[ item_name ].itemmax < limit )
    {
        level.a_magicbox_item_limits[ item_name ].itemmax = limit;
    }
}

function private unlock_map_wonder_loop()
{
    level endon( #"game_ended" );
    b_rebuilt = 0;
    while ( supported_mode() )
    {
        // Restore the map's own Wonder Weapon list when quest scripts lock it.
        b_changed = 0;
        if ( isdefined( level.var_20cf5eda0c956d52 ) && level.var_20cf5eda0c956d52 )
        {
            magicbox::function_2e49cd8681e36211( 0 );
            b_changed = 1;
        }
        if ( isdefined( level.var_641b7c91f663ea4f ) && level.var_641b7c91f663ea4f )
        {
            magicbox::function_6f00dd035f2d8f9a( 0, 0 );
            b_changed = 1;
        }
        switch ( level.mapname )
        {
            case "zm_sat_firefly":
                set_map_wonder_limit( %"itemspawnentry:zm_sat_item_weapon_ww_firefly", 4 );
                break;
            case "zm_sat_hornet":
                set_map_wonder_limit( %"itemspawnentry:zm_sat_item_weapon_ww_hornet", 4 );
                break;
            case "zm_sat_locust":
                set_map_wonder_limit( %"itemspawnentry:zm_sat_item_weapon_ww_locust", 3 );
                break;
            case "zm_sat_scarab":
                set_map_wonder_limit( %"itemspawnentry:zm_sat_item_weapon_ww_scarab", 1 );
                break;
            case "zm_sat_ruby":
                set_map_wonder_limit( %"itemspawnentry:zm_sat_item_weapon_ww_ruby", 1 );
                break;
        }
		
        if ( ( !b_rebuilt || b_changed ) && isdefined( level.var_8b6bf63f61fe01f9 ) )
        {
            magicbox::function_b787d845dbbfa18e();
            b_rebuilt = 1;
        }
        wait 0.25;
    }
}

//========> Special Rounds <========
function zm_ss_init()
{
    level endon( #"game_ended" );
    wait 1;

    if ( !utility::iszm() ) return;

    while ( !isdefined( level.var_a009ab14ee0d3223 ) )
    {
        wait 0.5;
    }

    s = level.var_a009ab14ee0d3223;
    for ( ;; )
    {
        n = zm_round_logic::get_rb_round_number();
        is_spec = isdefined( s.specialroundspawns ) && isdefined( s.specialroundspawns[ n ] ) && isdefined( s.specialroundspawns[ n ].specialroundname );

        level.var_4be693528db27813 = is_spec ? &zm_ss_count : undefined;
        level.var_7f29a2c7fe5ec0ef = is_spec ? &zm_ss_delay : undefined;

        wait 0.5;
    }
}
