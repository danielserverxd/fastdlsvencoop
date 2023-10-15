/*
* This script implements HLSP survival mode
*/

//#include "HLSP_hl/point_checkpoint"
//#include "point_checkpoint"

#include "anti_rush"
#include "rc/map_save"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_opfor/vision_nocturna/nvision"

#include "HLSP_blkops/armas/armas_orig"

#include "HLSP_blkops/classic_mode/HLSPClassicMode"
#include "HLSP_blkops/armas/weapon_hlpython"
#include "HLSP_blkops/armas/weapon_ofeagle"
#include "HLSP_blkops/armas/weapon_ofm249"
#include "HLSP_blkops/armas/weapon_ofsniperrifle"

const bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled

void MapInit()
{
	// Enable SC PointCheckPoint Support for Survival Mode
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Nightvision Support
	NightVision::Enable( NightVision::NV_RED ); // Red Nightvision

	// Register original Opposing Force knife weapon and Penguin and Shock Rifle Opfor
	// RegisterKnife();
	// CPenguin::Register();
	// CShockRifle::Register();

	// Register original Opposing Force knife and Penguin and Shock Rifle
	RegisterBlackOpsClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_BlackOpsClassicWeapons);

	// Enable Classic Weapons
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();

	// Enable Anti-Rush
	ANTI_RUSH::RemoveEntities = "countdown_blocker;countdown_start;countdown_end";
	ANTI_RUSH::EntityRegister( blAntiRushEnabled );
	MapSaveRegister( "ss1a2;ss1a3;ss4a2;ss4a3" );

	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_no_akimbo_uzis", 1 );

	// Enable Classic Mode
	ClassicModeMapInit();

	g_EngineFuncs.ServerPrint( "Ultimate Attack Version 1.2 - Download this campaign from scmapdb.com\n" );
}
