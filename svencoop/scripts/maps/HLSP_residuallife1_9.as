/*
* This script implements HLSP survival mode
*/

#include "HLSP_residuallife1_9/data_global"
#include "HLSP_residuallife1_9/env_model_coop"

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_residuallife1_9/classic_mode/HLSPClassicMode"
#include "HLSP_residuallife1_9/armas/weapon_hlpython"
#include "HLSP_residuallife1_9/armas/weapon_ofeagle"
#include "HLSP_residuallife1_9/armas/weapon_ofm249"
#include "HLSP_residuallife1_9/armas/weapon_ofsniperrifle"
#include "HLSP_residuallife1_9/armas/weapon_ofshockrifle"

void MapInit()
{
	RegisterDataGlobal();
	RegisterEnvModelCoop();

	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Classic Weapons
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();
	CShockRifle::Register();
	//RegisterHLMP5();
	//RegisterHLShotgun();

	// Global Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	// Enable Classic Mode
	ClassicModeMapInit();
}