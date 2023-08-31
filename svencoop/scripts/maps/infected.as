#include "hlsp/trigger_suitcheck"

#include "anti_rush"
#include "beast/checkpoint_spawner"
#include "anggaranothing/trigger_sound"
#include "rc/map_save"

const bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled
const bool blTramCrushEnabled = false; /* Change to "true" to enable tram crush damage for the intro levels if your server has a lot of 12 year old trolls that like to block things
(WARNING: accidental gibbage highly likely, enable at your peril) */
void MapInit()
{
	RegisterCheckPointSpawnerEntity();
	RegisterTriggerSuitcheckEntity();
	RegisterTriggerSoundEntity();
	MapSaveRegister( "n1a7;n1a7b;n1a7c;n1a8;n1a9;n1a9b;n1a9c;n2a0;n2a1;n2a1a" );
	ANTI_RUSH::EntityRegister( blAntiRushEnabled );

	if( ( g_Engine.mapname == "n0a0" || g_Engine.mapname == "n0a0b" ) && blTramCrushEnabled )
		IntroTramCrusher();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	g_EngineFuncs.ServerPrint( "The Infected SC Version 1.1 - Download this campaign from scmapdb.com\n" );
}
// Enable crush damage to tram if players are trolling and stalling the tram by blocking it - Optional feature
void IntroTramCrusher()
{
	CBaseEntity@ pTrackTrain;
	while( ( @pTrackTrain = g_EntityFuncs.FindEntityByClassname( pTrackTrain, "func_tracktrain" ) ) !is null )
	{
		if( pTrackTrain.pev.model == "*54" ) // This tram has npcs in it, would be a shame if they got crushed :c
			continue;

		if( pTrackTrain.pev.dmg == 0.0f )
			pTrackTrain.pev.dmg = 500000.0f;
	}

	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, PlayerTramCrushed );
}

HookReturnCode PlayerTramCrushed(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
{
	if( pPlayer is null || pAttacker is null )
		return HOOK_CONTINUE;

	if( pAttacker.GetClassname() == "func_tracktrain" )
		g_PlayerFuncs.SayText( pPlayer, "You died because you were blocking the tram." );
	
	return HOOK_CONTINUE;
}
