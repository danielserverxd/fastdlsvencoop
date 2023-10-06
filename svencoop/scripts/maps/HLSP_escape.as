/*
* This script implements HLSP survival mode
*/

//#include "HLSP_hl/point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "HLSP_escape/classic_mode/armas_orig_hl_hd"
#include "HLSP_escape/classic_mode/armas_reemplazo"

void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Classic Weapons
	RegisterHDClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_HDClassicWeapons);

	// Global Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	// Enable Classic Mode
	//ClassicModeMapInit();
}