/*
This script enables the final boss level in Opposing Force to be playable.
Geneworm monster script is built by CubeMath - https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/geneworm.as
Notable changes:
- Added a spore above the healing pool to allow players to grapple up, since the original env_rope doesn't work
-Outerbeast
*/
#include "cubemath/geneworm"

#include "opfor/nvision"
#include "opfor/weapon_knife"

const string 
	strFinalLevel = "of6a4b", // Last level before final boss
	strBossLevel = "of6a5"; // Final boss

const Vector vecGrappleSporePos = Vector( 1037, -492, 522 );
CScheduledFunction@ fnMoveSpawn;
EHandle hSpawn, hLift;
// Some mapping needed to make levels playable in SC
void LevelSetup()
{	
	CBaseEntity@ pLift;
	// Level before final boss
	if( g_Engine.mapname == strFinalLevel )
	{
		CBaseEntity@ pEndTrigger = g_EntityFuncs.FindEntityByString( pEndTrigger, "target", "endrelay" );
		@pLift = g_EntityFuncs.FindEntityByTargetname( pLift, "biglift" );
		// Change lift control
		if( pEndTrigger !is null )
		{
			pEndTrigger.pev.target = "biglift";
			g_EntityFuncs.DispatchKeyValue( pEndTrigger.edict(), "wait", "-1" );
			g_EntityFuncs.DispatchKeyValue( pEndTrigger.edict(), "delay", "3" );
		}
		
		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "cue_music18" ) ); //Remove ending music
	}// Boss level ft. Geneworm
	else if( g_Engine.mapname == strBossLevel )
	{
		CBaseEntity@
			pLiftPath = g_EntityFuncs.FindEntityByTargetname( pLiftPath, "biglift2" ),
			pLevelRestart = g_EntityFuncs.FindEntityByString( null, "target", "fallblack" ),
			pXenPush = g_EntityFuncs.FindEntityByString( null, "model", "*114" );

		@pLift = g_EntityFuncs.FindEntityByTargetname( pLift, "biglift" );

		if( pLift !is null && pLiftPath !is null )
		{
			pLiftPath.pev.origin.z -= 353.0f;
			g_EntityFuncs.SetOrigin( pLift, Vector( 0, 0, -353 ) );
			hLift = pLift;
			hSpawn = g_EntityFuncs.FindEntityByClassname( null, "info_player_start" );

			if( hLift.IsValid() && hSpawn.IsValid() )
			{
				hSpawn.GetEntity().pev.angles.y = 180;
				@fnMoveSpawn = g_Scheduler.SetInterval( "MoveSpawn", 0.1f, -1 );
			}
		}

		dictionary
			dictStartLift =
			{
				{ "targetname", "game_playerspawn" },
				{ "target", pLift.GetTargetname() },
				{ "delay", "0.5" },
				{ "triggerstate", "1" },
				{ "spawnflags", "1" }
			},
			dictSplat =
			{
				{ "model", string( pLevelRestart.pev.model ) },
				{ "origin", ( pLevelRestart.pev.origin - Vector( 0, 0, 1664 ) ).ToString() },
				{ "dmg", "100000" },
				{ "damagetype", "" + DMG_FALL }
			},
			dictXenGravity =
			{
				{ "model", "*114" },
				{ "origin", "0 0 2550" },
				{ "gravity", "0.6" }
			},
			dictEarthGravity =
			{
				{ "model", "*100" },
				{ "origin", "-1030 1078 -1870" },
				{ "gravity", "1" }
			};

		g_EntityFuncs.CreateEntity( "trigger_relay", dictStartLift );
		g_EntityFuncs.CreateEntity( "trigger_gravity", dictEarthGravity );

		if( g_EntityFuncs.CreateEntity( "trigger_gravity", dictXenGravity ) !is null )
			g_EntityFuncs.Remove( pXenPush );

		if( g_EntityFuncs.CreateEntity( "trigger_hurt", dictSplat ) !is null )
			g_EntityFuncs.Remove( pLevelRestart );
		// No env_rope to get to the healing pool, so use grapple
		g_EntityFuncs.Create( "ammo_spore", vecGrappleSporePos, Vector( 275, 270, 0 ), false );

		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByClassname( null, "player_loadsaved" ) );
		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByString( null, "target", "falldeath_mm" ) );
		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "falldeath_mm" ) );
		// ??? Don't know what these are for but the are getting erased
		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "GeneWormTeleport" ) );
		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "tele_exit" ) );
	}
	// Reset lift speed to original
	if( pLift !is null )
		pLift.pev.speed = 48;
}

void MoveSpawn()
{
	if( !hSpawn || !hLift )
		return;

	hSpawn.GetEntity().pev.origin = hLift.GetEntity().Center() + Vector( 0, 0, 32.0f );

	if( hLift.GetEntity().pev.origin == Vector( 3072, -160, 238 ) )
		g_Scheduler.RemoveTimer( fnMoveSpawn );
}

void EnableOpforFinalBoss()
{
	if( g_Engine.mapname == strBossLevel )
		RegisterGenewormCustomEntity();

	g_Scheduler.SetTimeout( "LevelSetup", 0.5f );
}

void MapInit()
{
	EnableOpforFinalBoss();
	// Register original Opposing Force knife weapon
	RegisterKnife();
	// Enable Nightvision Support
	NightVision::Enable();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
}