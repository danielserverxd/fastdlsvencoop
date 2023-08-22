#include "../../custom_weapons/weapon_P904"
#include "../../custom_weapons/weapon_vulcan"
#include "../../custom_weapons/weapon_plasma"
#include "data_global"
//#include "monster_race"

void MapInit()
{
	Registervulcan();
	RegisterP904();
	RegisterA768mmBox();
	Registerplasma();
	RegisterPlasmaProjectile();
	RegisterPlasmaProjectile2();
	RegisterPlasmaCell();
	RegisterDataGlobal();
	//RegisterMonsterRace();
}

