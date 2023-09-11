#include "nw/respawnwave"

#include "nw/nvision"
#include "nw/weapon_knife"
//Insurgency Stuff
#include "nw/ins2/base"
//assault rifles
#include "nw/ins2/arifl/weapon_ins2l85a2"
//battle rifles
#include "nw/ins2/brifl/weapon_ins2m14ebr"
//handguns
#include "nw/ins2/handg/weapon_ins2deagle"
#include "nw/ins2/handg/weapon_ins2glock17"
//lmgs
#include "nw/ins2/lmg/weapon_ins2m249"
//explosives/launchers
#include "nw/ins2/explo/weapon_ins2mk2"
#include "nw/ins2/explo/weapon_ins2rpg7"
#include "nw/ins2/explo/weapon_ins2law"
#include "nw/ins2/explo/weapon_ins2at4"
//shotguns
#include "nw/ins2/shotg/weapon_ins2m1014"
//smgs
#include "nw/ins2/smg/weapon_ins2mp7"
//carbines
#include "nw/ins2/carbn/weapon_ins2mk18"
//melees
#include "nw/ins2/melee/weapon_ins2kukri"
//sniper rifles
#include "nw/ins2/srifl/weapon_ins2m40a1"
//syringe
#include "nw/ins2/special/weapon_cofsyringe"

bool EnableIns2Replace = true;

array<ItemMapping@> KNIFE = 
{ 
	ItemMapping( "weapon_crowbar", "weapon_knife" ),
	ItemMapping( "weapon_hlcrowbar", "weapon_knife" )
};

void MapInit()
{
	// By Dr.ABC: Enable Wave Revive support
	WAVERESPAWN::Register();
	// Register original Opposing Force knife weapon
	RegisterKnife();
	//Ins2 weapon set
	if(EnableIns2Replace){
		NWINS2BASE::ShouldUseCustomAmmo = true;
		//mp5 3
		INS2_MP7::POSITION = 5;
		INS2_MP7::Register();
		//glock 2
		INS2_GLOCK17::POSITION = 5;
		INS2_GLOCK17::Register();
		//knfie/crowbar 1
		INS2_KUKRI::POSITION = 5;
		INS2_KUKRI::Register();
		//eagle 2
		INS2_DEAGLE::POSITION = 6;
		INS2_DEAGLE::Register();
		//grenade 5
		INS2_MK2GRENADE::POSITION = 6;
		INS2_MK2GRENADE::Register();
		//m16 6 -> 4
		INS2_L85A2::SLOT = 3;
		INS2_L85A2::POSITION = 6;
		INS2_L85A2::Register();
		//m249 8 -> 6
		INS2_M249::SLOT = 5;
		INS2_M249::POSITION = 5;
		INS2_M249::Register();
		//rpg7 5
		INS2_RPG7::POSITION = 5;
		INS2_RPG7::Register();
		//satchel 5 -> 8
		INS2_AT4::SLOT = 7;
		INS2_AT4::POSITION = 5;
		INS2_AT4::Register();
		//shotgun 4 -> 3
		INS2_M1014::SLOT = 2;
		INS2_M1014::POSITION = 6;
		INS2_M1014::Register();
		//sniper 8 -> 7
		INS2_M40A1::SLOT = 6;
		INS2_M40A1::POSITION = 5;
		INS2_M40A1::Register();
		//trip 5 -> 8
		INS2_LAW::SLOT = 7;
		INS2_LAW::POSITION = 6;
		INS2_LAW::Register();
		//uzi 4
		INS2_MK18::POSITION = 5;
		INS2_MK18::Register();
		//crossbow 8 -> 7
		INS2_M14EBR::SLOT = 6;
		INS2_M14EBR::POSITION = 6;
		INS2_M14EBR::Register();
		// medkit
		CoFSYRINGE::POSITION = 7;
		CoFSYRINGE::RegisterCoFSYRINGE();

		// Initialize classic mode (item mapping only)
		g_ClassicMode.SetItemMappings( @NUCLEAR_WINTER::g_Ins2ItemMappings );
		g_ClassicMode.ForceItemRemap( true );
		g_Hooks.RegisterHook( Hooks::PickupObject::Materialize, @NUCLEAR_WINTER::PickupObjectMaterialize );
	}
	else{
		g_ClassicMode.SetItemMappings( @KNIFE );
    	g_ClassicMode.ForceItemRemap( true );
	}
	// Enable Nightvision Support
	g_nv.MapInit();
	g_nv.SetNVColor( Vector(0, 255, 0) );// White Nightvision is 64, 64, 64
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
}

void HosterWeaponsAll(CBaseEntity@ pTriggerScript)
{
	for (int i = 0; i <= g_Engine.maxClients; i++) {
	        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
	        if (pPlayer !is null && pPlayer.IsConnected() && !pPlayer.GetWeaponsBlocked())
	        	pPlayer.BlockWeapons(cast<CBaseEntity@>(pPlayer));
	}
}

void DeployWeaponsAll(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	for (int i = 0; i <= g_Engine.maxClients; i++) {
	        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
	        if (pPlayer !is null && pPlayer.IsConnected() && pPlayer.GetWeaponsBlocked())
	        	pPlayer.UnblockWeapons(cast<CBaseEntity@>(pPlayer));
	}
}

namespace NUCLEAR_WINTER
{

array<array<string>> g_9mmARCandidates = {
	{ INS2_MP7::GetName(), INS2_MP7::GetAmmoName() }
};
const int iARChooser = Math.RandomLong( 0, g_9mmARCandidates.length() - 1 );

array<array<string>> g_9mmHandGunCandidates = {
	{ INS2_GLOCK17::GetName(), INS2_GLOCK17::GetAmmoName() }
};
const int i9mmChooser = Math.RandomLong( 0, g_9mmHandGunCandidates.length() - 1 );

array<string> g_CrowbarCandidates = {
	INS2_KUKRI::GetName()
};
const int iCrowbChooser = Math.RandomLong( 0, g_CrowbarCandidates.length() - 1 );

array<array<string>> g_DeagleCandidates = {
	{ INS2_DEAGLE::GetName(), INS2_DEAGLE::GetAmmoName() }
};
const int iDeagChooser = Math.RandomLong( 0, g_DeagleCandidates.length() - 1 );

array<string> g_GrenadeCandidates = {
	INS2_MK2GRENADE::GetName()
};
const int iGrenChooser = Math.RandomLong( 0, g_GrenadeCandidates.length() - 1 );

array<array<string>> g_M16Candidates = {
	{ INS2_L85A2::GetName(), INS2_L85A2::GetAmmoName(), INS2_L85A2::GetGLName() }
};
const int iM16Chooser = Math.RandomLong( 0, g_M16Candidates.length() - 1 );

array<array<string>> g_M249Candidates = {
	{ INS2_M249::GetName(), INS2_M249::GetAmmoName() }
};
const int iM249Chooser = Math.RandomLong( 0, g_M249Candidates.length() - 1 );

array<array<string>> g_RpgCandidates = {
	{ INS2_RPG7::GetName(), INS2_RPG7::GetAmmoName() }
};
const int iRpgChooser = Math.RandomLong( 0, g_RpgCandidates.length() - 1 );

array<string> g_SatchelCandidates = {
	INS2_AT4::GetName()
};
const int iSatChooser = Math.RandomLong( 0, g_SatchelCandidates.length() - 1 );

array<array<string>> g_ShotgunCandidates = {
	{ INS2_M1014::GetName(), INS2_M1014::GetAmmoName() }
};
const int iShotChooser = Math.RandomLong( 0, g_ShotgunCandidates.length() - 1 );

array<array<string>> g_SniperCandidates = {
	{ INS2_M40A1::GetName(), INS2_M40A1::GetAmmoName() }
};
const int iSnipChooser = Math.RandomLong( 0, g_SniperCandidates.length() - 1 );

array<string> g_TripmineCandidates = {
	INS2_LAW::GetName()
};
const int iTripChooser = Math.RandomLong( 0, g_TripmineCandidates.length() - 1 );

array<array<string>> g_UziCandidates = {
	{ INS2_MK18::GetName(), INS2_MK18::GetAmmoName() }
};
const int iUziChooser = Math.RandomLong( 0, g_UziCandidates.length() - 1 );

array<array<string>> g_UziAkimboCandidates = {
	{ INS2_MK18::GetName(), INS2_MP7::GetGLName() }
};
const int iUziAkimboChooser = Math.RandomLong( 0, g_UziAkimboCandidates.length() - 1 );

array<array<string>> g_BoltCandidates = {
	{ INS2_M14EBR::GetName(), INS2_M14EBR::GetAmmoName() }
};
const int iBoltChooser = Math.RandomLong( 0, g_BoltCandidates.length() - 1 );

array<string> g_MedCandidates = {
	CoFSYRINGE::CoFSYRINGEName()
};
const int iMedChooser = Math.RandomLong( 0, g_MedCandidates.length() - 1 );

array<ItemMapping@> g_Ins2ItemMappings = {
	//mp5
	ItemMapping( "weapon_9mmAR", g_9mmARCandidates[iARChooser][0] ), ItemMapping( "weapon_9mmar", g_9mmARCandidates[iARChooser][0] ), ItemMapping( "weapon_mp5", g_9mmARCandidates[iARChooser][0] ),
		ItemMapping( "ammo_9mmAR", g_9mmARCandidates[iARChooser][1] ),
	//glock
	ItemMapping( "weapon_9mmhandgun", g_9mmHandGunCandidates[i9mmChooser][0] ), ItemMapping( "weapon_glock", g_9mmHandGunCandidates[i9mmChooser][0] ),
		ItemMapping( "ammo_9mmclip", g_9mmHandGunCandidates[i9mmChooser][1] ),
	//crowbar
	ItemMapping( "weapon_crowbar", g_CrowbarCandidates[iCrowbChooser] ), ItemMapping( "weapon_knife", g_CrowbarCandidates[iCrowbChooser] ),
	//eagle
	ItemMapping( "weapon_eagle", g_DeagleCandidates[iDeagChooser][0] ),
		ItemMapping( "ammo_357", g_DeagleCandidates[iDeagChooser][1] ),
	//handgrenade
	ItemMapping( "weapon_handgrenade", g_GrenadeCandidates[iGrenChooser] ), ItemMapping( "weapon_hlhandgrenade", g_GrenadeCandidates[iGrenChooser] ),
	//m16
	ItemMapping( "weapon_m16", g_M16Candidates[iM16Chooser][0] ), ItemMapping( "ammo_556clip", g_M16Candidates[iM16Chooser][1] ),
		ItemMapping( "ammo_ARgrenades", g_M16Candidates[iM16Chooser][2] ), ItemMapping( "ammo_mp5grenades", g_M16Candidates[iM16Chooser][2] ),
	//m249
	ItemMapping( "weapon_m249", g_M249Candidates[iM249Chooser][0] ), ItemMapping( "weapon_saw", g_M249Candidates[iM249Chooser][0] ),
		ItemMapping( "ammo_556", g_M249Candidates[iM249Chooser][1] ),
	//rpg
	ItemMapping( "weapon_rpg", g_RpgCandidates[iRpgChooser][0] ),
		ItemMapping( "ammo_rpgclip", g_RpgCandidates[iRpgChooser][1] ),
	//satchel
	ItemMapping( "weapon_satchel", g_SatchelCandidates[iSatChooser] ),
	//shotgun
	ItemMapping( "weapon_shotgun", g_ShotgunCandidates[iShotChooser][0] ),
		ItemMapping( "ammo_buckshot", g_ShotgunCandidates[iShotChooser][1] ),
	//sniperrifle
	ItemMapping( "weapon_sniperrifle", g_SniperCandidates[iSnipChooser][0] ),
		ItemMapping( "ammo_762", g_SniperCandidates[iSnipChooser][1] ),
	//tripmine
	ItemMapping( "weapon_tripmine", g_TripmineCandidates[iTripChooser] ),
	//uzi
	ItemMapping( "weapon_uzi", g_UziCandidates[iUziChooser][0] ),
		ItemMapping( "ammo_uziclip", g_UziCandidates[iUziChooser][1] ),
	//uziakimbo
	ItemMapping( "weapon_uziakimbo", g_UziAkimboCandidates[iUziAkimboChooser][0] ),
		ItemMapping( "ammo_9mmbox", g_UziAkimboCandidates[iUziAkimboChooser][1] ),
	//crossbow
	ItemMapping( "weapon_crossbow", g_BoltCandidates[iBoltChooser][0] ),
		ItemMapping( "ammo_crossbow", g_BoltCandidates[iBoltChooser][1] ),
	//medkit
	ItemMapping( "item_healthkit", g_MedCandidates[iMedChooser] )
};

//Using Materialize hook for that one guy that thought it would be a good idea to spawn entities using squadmaker
HookReturnCode PickupObjectMaterialize( CBaseEntity@ pEntity ) 
{
	Vector origin, angles;
	string targetname, target, netname;

	for( uint j = 0; j < g_Ins2ItemMappings.length(); ++j )
	{
		if( pEntity.pev.ClassNameIs( g_Ins2ItemMappings[j].get_From() ) )
		{
			origin = pEntity.pev.origin;
			angles = pEntity.pev.angles;
			targetname = pEntity.pev.targetname;
			target = pEntity.pev.target;
			netname = pEntity.pev.netname;

			g_EntityFuncs.Remove( pEntity );
			CBaseEntity@ pNewEnt = g_EntityFuncs.Create( g_Ins2ItemMappings[j].get_To(), origin, angles, true );

			if( targetname != "" )
				g_EntityFuncs.DispatchKeyValue( pNewEnt.edict(), "targetname", targetname );

			if( target != "" )
				g_EntityFuncs.DispatchKeyValue( pNewEnt.edict(), "target", target );

			if( netname != "" )
				g_EntityFuncs.DispatchKeyValue( pNewEnt.edict(), "netname", netname );

			g_EntityFuncs.DispatchSpawn( pNewEnt.edict() );
		}
	}
	return HOOK_HANDLED;
}

}