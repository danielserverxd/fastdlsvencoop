#include "hl_weapons/weapon_ofm249"
#include "hl_weapons/weapon_ofeagle"
#include "opfor/weapon_knife"
#include "HLSP_opfor/vision_nocturna/nvision"
bool IsMultiplayer = false;
void MapInit()
{
	OF_EAGLE::Register();
	OF_M249::Register();
	RegisterKnife();
	NightVision::Enable();
}