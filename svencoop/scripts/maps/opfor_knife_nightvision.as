#include "opfor/nvision"
#include "opfor/weapon_knife"

void MapInit()
{
	// Register original Opposing Force knife weapon
	RegisterKnife();
	// Enable Nightvision Support
	NightVision::Enable();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
}
