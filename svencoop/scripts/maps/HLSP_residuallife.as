/*
* This script implements HLSP survival mode
*/

#include "HLSP_rl/data_global"
#include "HLSP_rl/env_model_coop"

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_rl/armas/armas_orig_hl"

#include "HLSP_rl/classic_mode/HLSPClassicMode"
#include "HLSP_rl/armas/weapon_hlpython"
#include "HLSP_rl/armas/weapon_ofeagle"
#include "HLSP_rl/armas/weapon_ofm249"
#include "HLSP_rl/armas/weapon_ofsniperrifle"

void MapInit()
{
	RegisterDataGlobal();
	RegisterEnvModelCoop();

	// Enable SC CheckPoint Support for Survival Mode
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Classic Weapons
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();

	// Register original Shock Rifle
	RegisterHLClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_HLClassicWeapons);

	//CShockRifle::Register();
	//RegisterHLMP5();
	//RegisterHLShotgun();

	// Global Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	// Enable Classic Mode
	ClassicModeMapInit();
}