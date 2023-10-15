/*
* This script implements HLSP survival mode
*/

//#include "beast/checkpoint_spawner"

#include "anti_rush"

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_opfor/vision_nocturna/nvision"
#include "HLSP_opfor/armas/armas_orig_opfor"

#include "HLSP_opfor/classic_mode/HLSPClassicMode"
#include "HLSP_opfor/armas/weapon_hlpython"
#include "HLSP_opfor/armas/weapon_ofeagle"
#include "HLSP_opfor/armas/weapon_ofm249"
#include "HLSP_opfor/armas/weapon_ofsniperrifle"

const bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled

void MapInit()
{
	// Enable SC CheckPoint Support for Survival Mode
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Register original Opposing Force knife weapon
	//RegisterKnife();
	// CPenguin::Register();
	// CShockRifle::Register();

	// Register original Opposing Force knife and Penguin and Shock Rifle
	RegisterOpforClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_OpforClassicWeapons);

	// Enable Nightvision Support
	NightVision::Enable();

	// Enable Classic Weapons
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();

	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	ANTI_RUSH::EntityRegister( blAntiRushEnabled );
	//RegisterCheckPointSpawnerEntity();

	// Enable Classic Mode
	ClassicModeMapInit();
}
