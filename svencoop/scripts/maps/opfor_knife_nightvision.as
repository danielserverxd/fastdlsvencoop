#include "opfor_unlock/nvision"
#include "opfor_unlock/weapon_knife"
#include "opfor_unlock/weapon_penguin"
#include "opfor_unlock/shockrifle/weapon_ofshockrifle"

void MapInit()
{
	// Register original Opposing Force knife weapon
	RegisterKnife();
	// Enable Nightvision Support
	NightVision::Enable();
	// Enable Penguin
	CPenguin::Register();
	// Enable Shock Rifle
	CShockRifle::Register();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
}