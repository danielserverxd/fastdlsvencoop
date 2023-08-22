/*======================================*/
/*==== Ragemap 2022 Script - v 1.00 ====*/
/*======================================*/



/*
 * -------------------------------------------------------------------------
 * Includes
 * -------------------------------------------------------------------------
 */

#include "weapon_slugger"
#include "CustomHUD"
#include "../weapon_custom/v9/weapon_custom"



namespace Ragemap2022
{
    /*
     * -------------------------------------------------------------------------
     * Constants & enumerators
     * -------------------------------------------------------------------------
     */

    /** @const bool Play parts in a random order. */
    const bool RANDOM_PART_ORDER    = true;

    /** @const bool Enable debug messages printed to console, enable '/part mappername' and '/skip' chat commands. */
    const bool DEBUG_MODE           = false;

    /** @const int Delay in seconds until the next part starts. */
    const int PART_TRANSITION_DELAY = 0;



    /*
     * -------------------------------------------------------------------------
     * Variables
     * -------------------------------------------------------------------------
     */

    array<uint> partOrder;

    uint partActive             = 0;
    uint partTransitionTimer    = 0;

    HUDTextParams sTransitionParams;



    /*
     * -------------------------------------------------------------------------
     * Life cycle functions
     * -------------------------------------------------------------------------
     */

    /**
     * Map initialisation handler.
     * @return void
     */
    void MapInit()
    {
        // Register the hook to monitor chat for chat commands
        g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

        // Precache mapper HUD icons
        for (uint i = 0; i < ::mapperTags.length(); i++) {
            g_Game.PrecacheModel("sprites/ragemap2022/channelicon_" + ::mapperTags[i] + ".spr");
        }

        // Slugger weapon
        RegisterSlugger();

        // Custom entity: weapon_custom
        WeaponCustomMapInit();
    }

    /**
     * Map activation handler.
     * @return void
     */
    void MapActivate()
    {
        if (::mappers.length() < 1) {
            g_Game.AlertMessage(at_error, "[Ragemap2022::MapActivate] Mappers not defined.\n");
            return;
        }

        if (::mappers.length() != ::mapperTags.length()) {
            g_Game.AlertMessage(at_error, "[Ragemap2022::MapActivate] Mappers length doesn't match mapper tags length.\n");
            return;
        }

        GeneratePartOrder();
        SetUpMapTransitions();
        partTransitionTimer = PART_TRANSITION_DELAY;

        sTransitionParams.x             = -1;
        sTransitionParams.y             = 0.8;
        sTransitionParams.effect        = 0;
        sTransitionParams.r1            = 255;
        sTransitionParams.g1            = 255;
        sTransitionParams.b1            = 255;
        sTransitionParams.a1            = 0;
        sTransitionParams.r2            = 255;
        sTransitionParams.g2            = 255;
        sTransitionParams.b2            = 255;
        sTransitionParams.a2            = 0;
        sTransitionParams.fadeinTime    = 0;
        sTransitionParams.fadeoutTime   = 1;
        sTransitionParams.holdTime      = 1;
        sTransitionParams.fxTime        = 0;
        sTransitionParams.channel       = 3;

        g_Scheduler.SetInterval("UpdateHud", 1.0);

        // Custom entity: weapon_custom
        WeaponCustomMapActivate();
    }



    /*
     * -------------------------------------------------------------------------
     * Functions
     * -------------------------------------------------------------------------
     */

    /**
     * Generate map part ordering.
     * @return void
     */
    void GeneratePartOrder()
    {
        if (RANDOM_PART_ORDER) {
            if (DEBUG_MODE) {
                g_Game.AlertMessage(at_console, "[Ragemap2022::GeneratePartOrder] Generating random part order ..\n");
            }

            while (partOrder.length() < ::mappers.length() - 2) {
                uint nextPart = Math.RandomLong(1, ::mappers.length() - 2);

                if (partOrder.find(nextPart) >= 0) {
                    continue; // Already inserted
                }

                partOrder.insertLast(nextPart);
            }

            // Intro is first
            partOrder.insertAt(0, 0);
            // Outro is last
            partOrder.insertLast(::mappers.length() - 1);
        } else {
            if (DEBUG_MODE) {
                g_Game.AlertMessage(at_console, "[Ragemap2022::GeneratePartOrder] Generating part order ..\n");
            }

            for (uint i = 0; i < ::mappers.length(); i++) {
                partOrder.insertLast(i);
            }
        }

        // Disable spawnpoint
        for (uint i = 0; i < ::mappers.length(); i++) {
            g_EntityFuncs.FireTargets("spawn_" + ::mapperTags[i], null, null, USE_OFF);
        }

        // Enable first spawnpoint
        g_EntityFuncs.FireTargets("spawn_" + ::mapperTags[0], null, null, USE_ON);

        if (DEBUG_MODE) {
            g_Game.AlertMessage(at_console, "[Ragemap2022::GeneratePartOrder] Part order decided: ");
            for (uint i = 1; i < partOrder.length() - 1; i++) {
                g_Game.AlertMessage(at_console, ::mapperTags[partOrder[i]] + " ");
            }
            g_Game.AlertMessage(at_console, "\n");
        }

        // Respawn players
        g_PlayerFuncs.RespawnAllPlayers(true, true);
    }

    /**
     * Set up map transitions.
     * @return void
     */
    void SetUpMapTransitions()
    {
        if (DEBUG_MODE) {
            g_Game.AlertMessage(at_console, "[Ragemap2022::SetUpMapTransitions] Starting ..\n");
        }
        CBaseEntity@ eTeleporter;

        for (uint i = 0; i < ::mappers.length(); i++) {
            string teleporterName = "teleporter_" + ::mapperTags[partOrder[i]];
            @eTeleporter = g_EntityFuncs.FindEntityByTargetname(null, teleporterName);

            if (DEBUG_MODE) {
                g_Game.AlertMessage(at_console, "[Ragemap2022::SetUpMapTransitions] Setting up target for " + teleporterName + "\n");
            }

            if (eTeleporter !is null) {
                if (DEBUG_MODE) {
                    g_Game.AlertMessage(at_console, "[Ragemap2022::SetUpMapTransitions] " + eTeleporter.pev.targetname + " now linked to destination_" + ::mapperTags[partOrder[i + 1]] + ".\n");
                }
                g_EntityFuncs.DispatchKeyValue(eTeleporter.edict(), "target", "destination_" + ::mapperTags[partOrder[i + 1]]);
            }
        }
    }

    /**
     * Begin thinker for when a part is finished.
     * @return void
     */
    void PartFinishedThink()
    {
        if (partTransitionTimer >= 1) {
            partTransitionTimer--;
            g_PlayerFuncs.HudMessageAll(sTransitionParams, "Next part will start in " + partTransitionTimer + " seconds.");
            g_Scheduler.SetTimeout("PartFinishedThink", 1.0);
            return;
        }

        if (DEBUG_MODE) {
            g_Game.AlertMessage(at_console, "[Ragemap2022::PartFinished] " + ::mappers[partOrder[partActive]] + "'s part is finishing.\n");
        }

        partActive++;
        partTransitionTimer = PART_TRANSITION_DELAY;

        if (partActive > partOrder.length()) {
            if (DEBUG_MODE) {
                g_Game.AlertMessage(at_console, "[Ragemap2022::PartFinished] All parts complete.\n");
            }
            return;
        }

        if (DEBUG_MODE) {
            g_Game.AlertMessage(at_console, "[Ragemap2022::PartFinished] " + ::mappers[partOrder[partActive]] + "'s part is now active.\n");
        }

        // Disable old spawnpoints
        g_EntityFuncs.FireTargets("spawn_" + ::mapperTags[partOrder[partActive - 1]], null, null, USE_OFF);

        // Turn off all ambient music -- This should ideally be part of a part's end/teardown MM entity (lesson for 2023)
        CBaseEntity@ pMusic = null;
        while ((@pMusic = g_EntityFuncs.FindEntityByClassname(pMusic, "ambient_music")) !is null) {
            pMusic.Use(null, null, USE_OFF);
        }

        // Fully re-equip all players
        for (int i = 1; i <= g_Engine.maxClients; i++) {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if (
                pPlayer is null
                or !pPlayer.IsPlayer()
                or !pPlayer.IsConnected()
            ) {
                continue;
            }

            g_PlayerFuncs.ApplyMapCfgToPlayer(pPlayer, true);
        }

        // Enable new spawnpoints
        g_EntityFuncs.FireTargets("spawn_" + ::mapperTags[partOrder[partActive]], null, null, USE_ON);

        // Respawn players
        g_PlayerFuncs.RespawnAllPlayers(true, true);
    }

    /**
     * Update player HUD.
     * @return void
     */
    void UpdateHud()
    {
        CBasePlayer@ pPlayer = null;

        HUDSpriteParams params;
        params.channel      = 0;
        params.flags        = HUD_ELEM_NO_BORDER;
        // params.width        = 0;
        // params.height       = 0;
        params.x            = 0.01;
        params.y            = 0.01;
        // params.left         = 0;
        // params.top          = 0;
        params.color1       = RGBA_WHITE;
        params.color2       = RGBA_WHITE;
        params.fadeinTime   = 0.0;
        params.fadeoutTime  = 0.0;
        params.holdTime     = 9999.0;
        params.fxTime       = 1;
        params.effect       = HUD_EFFECT_NONE;
        params.spritename   = "ragemap2022/channelicon_" + ::mapperTags[partOrder[partActive]] + ".spr";

        g_PlayerFuncs.HudCustomSprite(pPlayer, params);
    }

    /**
     * Handle client say.
     * @param  SayParameters@ pParams Say parameters
     * @return HookReturnCode         Hook return code
     */
    HookReturnCode ClientSay(SayParameters@ pParams)
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        const CCommand@ args = pParams.GetArguments();

        if (
            !pPlayer.IsConnected()
            || (
                !DEBUG_MODE
                && g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES
            )
        ) {
            return HOOK_CONTINUE;
        }

        if (args[0] == "/part" && args.ArgC() == 2) {
            for (uint i = 0; i < ::mappers.length(); i++) {
                if (args[1] == ::mappers[i] || args[1] == ::mapperTags[i]) {
                    g_Game.AlertMessage(at_console, "[Ragemap2022] Changing to" + ::mappers[i] + "'s part.\n");

                    // Update part
                    partActive = partOrder.find(::mapperTags.find(args[1]));

                    // Disable all spawnpoints
                    for (uint j = 0; j < ::mappers.length(); j++) {
                        g_EntityFuncs.FireTargets("spawn_" + ::mapperTags[j], null, null, USE_OFF);
                    }

                    // Turn off all ambient music
                    CBaseEntity@ pMusic = null;
                    while ((@pMusic = g_EntityFuncs.FindEntityByClassname(pMusic, "ambient_music")) !is null) {
                        pMusic.Use(null, null, USE_OFF);
                    }

                    // Activate spawnpoints in chosen part
                    g_EntityFuncs.FireTargets("spawn_" + ::mapperTags[i], null, null, USE_ON);

                    // Respawn players
                    g_PlayerFuncs.RespawnAllPlayers(true, true);

                    return HOOK_CONTINUE;
                }
            }

            g_Game.AlertMessage(at_console, "[Ragemap2022] Invalid mapper name (Usage: /part mappername. Mapper's name should be spelled as stored in the map script.\n");

            return HOOK_CONTINUE;
        }

        if (args[0] == "/skip") {
            PartFinished(null, null, USE_ON, 0);

            g_Game.AlertMessage(at_console, "[Ragemap2022] Skipping current part.\n");

            return HOOK_CONTINUE;
        }

        return HOOK_CONTINUE;
    }
}

/**
 * Bridge function for map hook to namespaced "PartFinishedThink" function.
 * @return void
 */
void PartFinishedThinkBridge()
{
    Ragemap2022::PartFinishedThink();
}

/**
 * Map hook: Begin thinker for when a part is finished.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void PartFinished(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    g_Scheduler.SetTimeout("PartFinishedThinkBridge", 1.0);
}

/**
 * Map hook: Ticket system start.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TicketStart(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    CustomHUD::TicketStart();
}

/**
 * Map hook: Ticket system update.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void UpdateTickets(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    CustomHUD::UpdateTickets();
}

/**
 * Map hook: Ticket system end.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TicketEnd(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    CustomHUD::TicketEnd();
}
