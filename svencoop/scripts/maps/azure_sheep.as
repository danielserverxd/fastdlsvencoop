/*
* This script implements HLSP survival mode
*/

//#include "HLSP_hl/point_checkpoint"
//#include "point_checkpoint"

#include "HLSP_hl/custom/point_checkpoint"
#include "HLSP_hl/trigger_suitcheck"

#include "anti_rush"

#include "azuresheep/monster_barniel"
#include "azuresheep/monster_kate"

#include "anggaranothing/trigger_sound"
#include "beast/replace_weapon_sprites"

#include "HLSP_hl/armas/armas_orig_hl"

#include "HLSP_hl/classic_mode/HLSPClassicMode"
#include "HLSP_hl/armas/weapon_hlpython"
#include "HLSP_hl/armas/weapon_ofeagle"
#include "HLSP_hl/armas/weapon_ofm249"
#include "HLSP_hl/armas/weapon_ofsniperrifle"

const bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();

	// Enable Anti-Rush
	ANTI_RUSH::RemoveEntities = "models/cubemath/*;percent_lock*;kill_antirush*";
	ANTI_RUSH::EntityRegister( blAntiRushEnabled );
	REPLACE_WEAPON_SPRITES::SetReplacements( "azuresheep", "640hudas1;640hudas3;640hudas4;640hudas6;640hudas7", "weapon_crowbar;weapon_m16;weapon_snark" );

	// Enable this fucking catastrophe
	RegisterTriggerSoundEntity();

	// Enable Classic Weapons
	CPython::Register();
	CEagle::Register();
	CM249::Register();
	CSniperRifle::Register();

	// Register original MP5 and SHOTGUN and Shock Rifle
	RegisterHLClassicWeapons();
	g_ClassicMode.SetItemMappings(@g_HLClassicWeapons);

	// Register these bitches
	barnielCustom::Register();
	kateCustom::Register();

	// Global CVars: Uncomment the line below if you want to disable monsterinfo on all maps
	//g_EngineFuncs.CVarSetFloat( "mp_allowmonsterinfo", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_modelselection", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	// Enable Classic Mode
	ClassicModeMapInit();
}