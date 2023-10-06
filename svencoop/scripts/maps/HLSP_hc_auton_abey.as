/*
* This script implements HLSP survival mode
*/

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_hc_auton_abey/anti_rush"
#include "HLSP_opfor/vision_nocturna/nvision"
#include "HLSP_hc_auton_abey/armas/armas_orig_opfor"
#include "HLSP_hc_auton_abey/armas/armas_reemplazo"

#include "HLSP_hc_auton_abey/classic_mode/HLSPClassicMode"
#include "HLSP_hc_auton_abey/armas/weapon_hlpython"
#include "HLSP_hc_auton_abey/armas/weapon_ofeagle"
#include "HLSP_hc_auton_abey/armas/weapon_ofm249"

#include "HLSP_hc_auton_abey/beast/changesolid_zone"

bool IsMultiplayer = false;

const bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled
const float flSurvivalVoteAllow = g_EngineFuncs.CVarGetFloat( "mp_survival_voteallow" );

void MapInit()
{
	Precache();

	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Nightvision Support
	NightVision::Enable();
	ANTI_RUSH::EntityRegister( blAntiRushEnabled );

	// Register original Opposing Force knife and Shock Rifle
	RegisterOpforClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_OpforClassicWeapons);

	// Enable SD Classic Weapons in classic mode
	CPython::Register();
	CEagle::Register();
	CM249::Register();

	// Global Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	// Enable Classic Mode
	ClassicModeMapInit();

	g_EngineFuncs.ServerPrint( "Hunt the Cunt Version 1.0 - Download this campaign from scmapdb.com\n" );
}

void Precache()
{
	if( g_Engine.mapname == "htc_1" )
		g_Game.PrecacheModel( "models/cubemath/key.mdl" );
}

void TurnOnSurvival(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_EngineFuncs.CVarSetFloat( "mp_survival_voteallow", flSurvivalVoteAllow ); // Revert to the original cvar setting as per server

	if( g_SurvivalMode.IsEnabled() && g_SurvivalMode.MapSupportEnabled() && !g_SurvivalMode.IsActive() )
		g_SurvivalMode.Activate( true );
}

void DisableSurvival(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    g_SurvivalMode.Disable();
}

void HideFallEnts(CBaseEntity@ pTriggerScript)
{
	CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "xen_fall_splat" );
	array<CBaseEntity@> P_ENTITIES( 128 );

	if( pEntity is null || g_EntityFuncs.EntitiesInBox( @P_ENTITIES, pEntity.pev.absmin - Vector( 0, 0, 64 ), pEntity.pev.absmax + Vector( 0, 0, 64 ), 0 ) < 1 )
		return;

	for( uint i = 0; i < P_ENTITIES.length(); i++ )
	{
		if( P_ENTITIES[i] is null || P_ENTITIES[i].IsBSPModel() )
			continue;

		if( P_ENTITIES[i].IsPlayer() )
			P_ENTITIES[i].pev.effects |= EF_NODRAW;
		else
			g_EntityFuncs.Remove( P_ENTITIES[i] );
	}
}