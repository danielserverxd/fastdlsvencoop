/*
* This script implements HLSP survival mode
*/

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_hl/armas/armas_orig_hl"

#include "HLSP_hl/classic_mode/HLSPClassicMode"
#include "HLSP_hl/armas/weapon_hlpython"
#include "HLSP_hl/armas/weapon_ofeagle"
#include "HLSP_hl/armas/weapon_ofm249"
#include "HLSP_hl/armas/weapon_ofsniperrifle"

void MapInit()
{
	// Enable SC CheckPoint Support for Survival Mode
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Classic Weapons
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();

	// Register original MP5 and SHOTGUN and Shock Rifle
	RegisterHLClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_HLClassicWeapons);

	// Global Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );

	// Enable Classic Mode
	ClassicModeMapInit();
}