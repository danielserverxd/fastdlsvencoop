#include "weapon_e11blaster"
#include "weapon_dl44blaster"
#include "weapon_vulcan"
#include "weapon_plasmagun"
#include "weapon_t21blaster"
#include "weapon_9mmm41a"
#include "weapon_p904"
#include "weapon_ofshockrifle"
#include "weapon_sawedoff"
#include "weapon_beretta"
#include "weapon_mp5hl"
#include "weapon_shotgunhl"
#include "weapon_knife"

//Monsters
#include "monsters/monster_race"
#include "monsters/monster_female_jumper"

void PHRegister()
{
	RegisterE11Blaster();
	RegisterBlaster();
	RegisterBlasterAmmoBox();
	RegisterDL44Blaster();
	RegisterHighPowerBlasterAmmoBox();
	RegisterHPBlaster();
	RegisterBowcasterBlaster();
	RegisterHREPEATER();
	RegisterFlechetteAmmoBox();
	RegisterCShoot();
	RegisterT21Blaster();
	RegisterBlasterNpc();
	RegisterPEntity();
	RegisterM41A();
	RegisterP904();
	RegisterOPSHOCK();
	RegisterSawedOff();
	Registerberetta();
	RegisterMP5HL();
	RegisterShotgunHL();
	RegisterKnife();

	//Monsters
	
	race::Register();
	AssassinCustom::Register();
	
}
