/*
* This script implements HLSP survival mode
*/

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_bshift/classic_mode/HLSPClassicMode"
#include "HLSP_bshift/armas/weapon_hlpython"
#include "HLSP_bshift/armas/weapon_ofeagle"
#include "HLSP_bshift/armas/weapon_ofm249"
#include "HLSP_bshift/armas/weapon_ofsniperrifle"
#include "HLSP_bshift/armas/weapon_ofshockrifle"


void MapInit()
{
	// Enable Classic Weapons
	CShockRifle::Register();
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();

	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Global Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	// Enable Classic Mode
	ClassicModeMapInit();
}