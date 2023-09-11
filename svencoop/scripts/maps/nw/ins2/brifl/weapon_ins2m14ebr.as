// Insurgency's M14-EBR
/* Model Credits
/ Model: Project Reality Team, Hellspike (Aimpoint), Norman The Loli Pirate (Edits)
/ Textures: Project Reality Team, Thanez (Aimpoint), Norman The Loli Pirate (Edits)
/ Animations: MyZombieKillerz (Minor edits by D.N.I.O. 071)
/ Sounds: New World Interactive, D.N.I.O. 071 (Conversion to .ogg format)
/ Sprites: D.N.I.O. 071 (Model Render), R4to0 (Vector), KernCore (.spr Compile)
/ Misc: KernCore (World Model UVs), D.N.I.O. 071 (World Model UVs, Compile), Norman The Loli Pirate (World Model)
/ Script: KernCore
*/

#include "../base"

namespace INS2_M14EBR
{

// Animations
enum INS2_M14EBR_Animations
{
	IDLE = 0,
	IDLE_EMPTY,
	DRAW_FIRST,
	DRAW,
	DRAW_EMPTY,
	HOLSTER,
	HOLSTER_EMPTY,
	FIRE,
	FIRE_LAST,
	DRYFIRE,
	FIRESELECT,
	FIRESELECT_EMPTY,
	RELOAD,
	RELOAD_EMPTY,
	IRON_IDLE,
	IRON_IDLE_EMPTY,
	IRON_FIRE,
	IRON_FIRE_LAST,
	IRON_DRYFIRE,
	IRON_FIRESELECT,
	IRON_FIRESELECT_EMPTY,
	IRON_TO,
	IRON_TO_EMPTY,
	IRON_FROM,
	IRON_FROM_EMPTY
};

// Models
string W_MODEL = "models/ins2/wpn/m14ebr/w_m14ebr.mdl";
string V_MODEL = "models/nw/ins2/wpn/m14ebr/v_m14ebr.mdl";
string P_MODEL = "models/ins2/wpn/m14ebr/p_m14ebr.mdl";
string A_MODEL = "models/ins2/ammo/mags.mdl";
int MAG_BDYGRP = 22;
// Sprites
string SPR_CAT = "ins2/brf/"; //Weapon category used to get the sprite's location
// Sounds
string SHOOT_S = "ins2/wpn/m14ebr/shoot.ogg";
string EMPTY_S = "ins2/wpn/m14ebr/empty.ogg";
// Information
int MAX_CARRY   	= 9000;
int MAX_CLIP    	= 20;
int DEFAULT_GIVE 	= MAX_CLIP * 4;
int WEIGHT      	= 20;
int FLAGS       	= ITEM_FLAG_ESSENTIAL | ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 50; //50*1.4 = 70 + Toxic, underwater dmg * 1.5 = 105
uint SLOT       	= 6;
uint POSITION   	= 11;
float RPM_AIR   	= 710; //Rounds per minute in air def:710
float RPM_WTR   	= 650; //Rounds per minute in water def:550
string AMMO_TYPE 	= "ins2_7.62x51mm";
// LCH modify
bool isLeagleReload = false;

class weapon_ins2m14ebr : ScriptBasePlayerWeaponEntity, NWINS2BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private bool m_WasDrawn;
	private int GetBodygroup()
	{
		return 0;
	}
	private array<string> Sounds = {
		"ins2/wpn/m14ebr/bltbk.ogg",
		"ins2/wpn/m14ebr/bltrel.ogg",
		"ins2/wpn/m14ebr/rof.ogg",
		"ins2/wpn/m14ebr/magin.ogg",
		"ins2/wpn/m14ebr/magout.ogg",
		"ins2/wpn/m14ebr/magrel.ogg",
		EMPTY_S,
		SHOOT_S
	};

	void Spawn()
	{
		Precache();
		WeaponSelectFireMode = NWINS2BASE::SELECTFIRE_SEMI;
		m_WasDrawn = false;
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		m_iShell = g_Game.PrecacheModel( NWINS2BASE::BULLET_762x51 );

		g_Game.PrecacheOther( GetAmmoName() );

		NWINS2BASE::PrecacheSound( Sounds );
		NWINS2BASE::PrecacheSound( NWINS2BASE::DeployFirearmSounds );
		
		g_Game.PrecacheGeneric( "sprites/" + SPR_CAT + self.pev.classname + ".txt" );
		g_Game.PrecacheGeneric( "events/" + "muzzle_ins2_MGs.txt" );
		CommonPrecache();
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (NWINS2BASE::ShouldUseCustomAmmo) ? MAX_CARRY : NWINS2BASE::DF_MAX_CARRY_556;
		info.iAmmo1Drop	= MAX_CLIP;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip 	= MAX_CLIP;
		info.iSlot  	= SLOT;
		info.iPosition 	= POSITION;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= FLAGS;
		info.iWeight 	= WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( EMPTY_S );
	}

	bool Deploy()
	{
		PlayDeploySound( 3 );
		DisplayFiremodeSprite();
		if( m_WasDrawn == false && self.m_iClip >= MAX_CLIP + 1 )
		{
			m_WasDrawn = true;
			return Deploy( V_MODEL, P_MODEL, DRAW, "sniper", GetBodygroup(), (22.0/35.0) );
		}
		else if( m_WasDrawn == false )
		{
			m_WasDrawn = true;
			return Deploy( V_MODEL, P_MODEL, DRAW_FIRST, "sniper", GetBodygroup(), (45.0/31.0) );
		}
		else
			return Deploy( V_MODEL, P_MODEL, (self.m_iClip == 0) ? DRAW_EMPTY : DRAW, "sniper", GetBodygroup(), (21.0/35.0) );
	}

	void Holster( int skipLocal = 0 )
	{
		CommonHolster();

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_DRYFIRE : DRYFIRE, 0, GetBodygroup() );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
			return;
		}

		if( WeaponSelectFireMode == NWINS2BASE::SELECTFIRE_SEMI && m_pPlayer.m_afButtonPressed & IN_ATTACK == 0 )
			return;

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? WeaponTimeBase() + GetFireRate( RPM_WTR ) : WeaponTimeBase() + GetFireRate( RPM_AIR );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;

		ShootWeapon( SHOOT_S, 1, VecModAcc( VECTOR_CONE_1DEGREES, 2.15f, 0.55f, 1.85f ), (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? 1024 : 10240, DAMAGE, true, DMG_RADIATION | DMG_SNIPER, 0.5, 0.4 );

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		if( WeaponADSMode != NWINS2BASE::IRON_IN )
		{
			if( m_pPlayer.pev.velocity.Length2D() > 0 )
				KickBack( 1.95, 0.35, 0.225, 0.05, 7.0, 1.5, 7 );
			else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
				KickBack( 2.25, 0.9, 0.5, 0.35, 10.0, 6.0, 5 );
			else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
				KickBack( 1.25, 0.25, 0.15, 0.025, 5.0, 0.95, 9 );
			else
				KickBack( 1.45, 0.275, 0.175, 0.0375, 6.0, 1.25, 8 );
		}
		else
		{
			PunchAngle( Vector( Math.RandomFloat( -3.4, -2.6 ), (Math.RandomLong( 0, 1 ) < 0.5) ? -0.3f : 0.5f, Math.RandomFloat( -0.5, 0.5 ) ) );
		}

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
			self.SendWeaponAnim( (self.m_iClip == 0) ? IRON_FIRE_LAST : IRON_FIRE, 0, GetBodygroup() );
		else
			self.SendWeaponAnim( (self.m_iClip == 0) ? FIRE_LAST : FIRE, 0, GetBodygroup() );

		ShellEject( m_pPlayer, m_iShell, (WeaponADSMode != NWINS2BASE::IRON_IN) ? Vector( 18.5, 7, -7.1 ) : Vector( 18.5, 2, -3.55 ) );
	}

	void SecondaryAttack()
	{
		self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.13;
		
		switch( WeaponADSMode )
		{
			case NWINS2BASE::IRON_OUT:
			{
				m_pPlayer.m_szAnimExtension = "sniperscope";
				self.SendWeaponAnim( (self.m_iClip > 0) ? IRON_TO : IRON_TO_EMPTY, 0, GetBodygroup() );
				EffectsFOVON( 30 );
				break;
			}
			case NWINS2BASE::IRON_IN:
			{
				m_pPlayer.m_szAnimExtension = "sniper";
				self.SendWeaponAnim( (self.m_iClip > 0) ? IRON_FROM : IRON_FROM_EMPTY, 0, GetBodygroup() );
				EffectsFOVOFF();
				break;
			}
		}
	}

	void ItemPreFrame()
	{
		if( m_reloadTimer < g_Engine.time && canReload )
			self.Reload();

		BaseClass.ItemPreFrame();
	}

	void Reload()
	{
		if( self.m_iClip > 0 )
			ChangeFireMode( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_FIRESELECT : FIRESELECT, GetBodygroup(), NWINS2BASE::SELECTFIRE_AUTO, NWINS2BASE::SELECTFIRE_SEMI, (25.0/30.0) );
		else
			ChangeFireMode( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_FIRESELECT_EMPTY : FIRESELECT_EMPTY, GetBodygroup(), NWINS2BASE::SELECTFIRE_AUTO, NWINS2BASE::SELECTFIRE_SEMI, (25.0/30.0) );

		if( self.m_iClip >= MAX_CLIP + 1 || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || m_pPlayer.pev.button & IN_USE != 0 )
			return;

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
		{
			m_pPlayer.m_szAnimExtension = "sniper";
			self.SendWeaponAnim( (self.m_iClip > 0) ? IRON_FROM : IRON_FROM_EMPTY, 0, GetBodygroup() );
			m_reloadTimer = g_Engine.time + 0.16;
			m_pPlayer.m_flNextAttack = 0.16;
			canReload = true;
			EffectsFOVOFF();
		}

		if( m_reloadTimer < g_Engine.time )
		{
			(self.m_iClip == 0) ? Reload( MAX_CLIP, RELOAD_EMPTY, (150.0/40.0), GetBodygroup() ) : Reload( MAX_CLIP + 1, RELOAD, (105.0/40.0), GetBodygroup() );
			canReload = false;
		}

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		if( self.m_flNextPrimaryAttack < g_Engine.time )
			m_iShotsFired = 0;

		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
			self.SendWeaponAnim( (self.m_iClip == 0) ? IRON_IDLE_EMPTY : IRON_IDLE, 0, GetBodygroup() );
		else
			self.SendWeaponAnim( (self.m_iClip == 0) ? IDLE_EMPTY : IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class M14EBR_MAG : ScriptBasePlayerAmmoEntity, NWINS2BASE::AmmoBase
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, A_MODEL );
		self.pev.body = MAG_BDYGRP;
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( A_MODEL );
		CommonPrecache();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return CommonAddAmmo( pOther, MAX_CLIP, (NWINS2BASE::ShouldUseCustomAmmo) ? MAX_CARRY : NWINS2BASE::DF_MAX_CARRY_556, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : NWINS2BASE::DF_AMMO_556 );
	}
}

string GetAmmoName()
{
	return "ammo_ins2m14ebr";
}

string GetName()
{
	return "weapon_ins2m14ebr";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M14EBR::weapon_ins2m14ebr", GetName() ); // Register the weapon entity
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M14EBR::M14EBR_MAG", GetAmmoName() ); // Register the ammo entity
	g_ItemRegistry.RegisterWeapon( GetName(), SPR_CAT, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : NWINS2BASE::DF_AMMO_556, "", GetAmmoName() ); // Register the weapon
}

}