// Insurgency's MK-18 MOD 1
/* Model Credits
/ Model: Twinke Masta (Body, Stock, Rail Cover), TheLama (EOTech), Milo (Folding Iron Sights), B0T (PMag), Norman The Loli Pirate
/ Textures: Millenia (Body, Stock), Thanez (Rail Cover), Flamshmizer (EOTech), End of Days (Folding Iron Sights), Thanez (PMag), Norman The Loli Pirate
/ Animations: New World Interactive, D.N.I.O. 071 (Edits)
/ Sounds: New World Interactive, D.N.I.O. 071 (Conversion to .ogg format)
/ Sprites: D.N.I.O. 071 (Model Render), R4to0 (Vector), KernCore (.spr Compile)
/ Misc: Norman The Loli Pirate (World Model), D.N.I.O. 071 (World Model UVs, Compile)
/ Script: KernCore
*/

#include "../base"

namespace INS2_MK18
{

// Animations
enum INS2_MK18_Animations
{
	IDLE = 0,
	DRAW_FIRST,
	DRAW,
	HOLSTER,
	FIRE1,
	FIRE2,
	DRYFIRE,
	FIRESELECT,
	RELOAD,
	RELOAD_EMPTY,
	IRON_IDLE,
	IRON_FIRE1,
	IRON_FIRE2,
	IRON_FIRE3,
	IRON_DRYFIRE,
	IRON_FIRESELECT,
	IRON_TO,
	IRON_FROM
};

enum MK18_Bodygroups
{
	ARMS = 0,
	MK18_STUDIO0,
	MK18_STUDIO1,
	MAIN_BULLETS,
	HELPER_BULLETS,
	MK18_STUDIO2
};

// Models
string W_MODEL = "models/ins2/wpn/mk18/w_mk18.mdl";
string V_MODEL = "models/nw/ins2/wpn/mk18/v_mk18.mdl";
string P_MODEL = "models/ins2/wpn/mk18/p_mk18.mdl";
string A_MODEL = "models/ins2/ammo/mags.mdl";
int MAG_BDYGRP = 18;
// Sprites
string SPR_CAT = "ins2/cbn/"; //Weapon category used to get the sprite's location
// Sounds
string SHOOT_S = "ins2/wpn/mk18/shoot.ogg";
string EMPTY_S = "ins2/wpn/mk18/empty.ogg";
// Information
int MAX_CARRY   	= 9000;
int MAX_CLIP    	= 30;
int DEFAULT_GIVE 	= MAX_CLIP * 4;
int WEIGHT      	= 20;
int FLAGS       	= ITEM_FLAG_ESSENTIAL | ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 24; //24* 1.375 = 33
uint SLOT       	= 3;
uint POSITION   	= 5;
float RPM_AIR   	= 825; //Rounds per minute in air
float RPM_WTR   	= 750; //Rounds per minute in water
string AMMO_TYPE 	= "ins2_5.56x45mm";

class weapon_ins2mk18 : ScriptBasePlayerWeaponEntity, NWINS2BASE::WeaponBase
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
		if( self.m_iClip >= (MAX_CLIP + 1) )
			m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, MAIN_BULLETS, 30 );
		else if( self.m_iClip >= MAX_CLIP )
			m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, MAIN_BULLETS, 29 );
		else if( self.m_iClip <= 1 )
			m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, MAIN_BULLETS, 0 );
		else
			m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, MAIN_BULLETS, self.m_iClip - 1 );

		return m_iCurBodyConfig;
	}
	private int SetBodygroup()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			if( (m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip) >= (MAX_CLIP + 1) && self.m_iClip > 0 )
				m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, HELPER_BULLETS, 30 );
			else if( (m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip) >= MAX_CLIP )
				m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, HELPER_BULLETS, 29 );
			else if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) < MAX_CLIP && (m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip) < MAX_CLIP )
				m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, HELPER_BULLETS, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + (self.m_iClip - 1) );
		}

		return m_iCurBodyConfig;
	}
	private array<string> Sounds = {
		"ins2/wpn/mk18/bltbk.ogg",
		"ins2/wpn/mk18/bltrel.ogg",
		"ins2/wpn/mk18/bltfd.ogg",
		"ins2/wpn/mk18/rof.ogg",
		"ins2/wpn/mk18/hit.ogg",
		"ins2/wpn/mk18/magin.ogg",
		"ins2/wpn/mk18/magout.ogg",
		"ins2/wpn/mk18/magrel.ogg",
		EMPTY_S,
		SHOOT_S
	};
	// LCH modify
	private int fastReloadCount	= 0;
	private bool isLeagleReload = false;

	void Spawn()
	{
		Precache();
		WeaponSelectFireMode = NWINS2BASE::SELECTFIRE_AUTO;
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
		m_iShell = g_Game.PrecacheModel( NWINS2BASE::BULLET_556x45 );

		g_Game.PrecacheOther( GetAmmoName() );

		NWINS2BASE::PrecacheSound( Sounds );
		NWINS2BASE::PrecacheSound( NWINS2BASE::DeployFirearmSounds );
		NWINS2BASE::PrecacheSound( NWINS2BASE::DeployPistolSounds );
		
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
		DispFastReloadTxt();
		canReload = true;
		isLeagleReload = true;
		if( m_WasDrawn == false && self.m_iClip >= MAX_CLIP + 1 )
		{
			m_WasDrawn = true;
			return Deploy( V_MODEL, P_MODEL, DRAW, "m16", GetBodygroup(), (22.0/35.0) );
		}
		else if( m_WasDrawn == false )
		{
			m_WasDrawn = true;
			return Deploy( V_MODEL, P_MODEL, DRAW_FIRST, "m16", GetBodygroup(), (90.0/55.0) );
		}
		else
			return Deploy( V_MODEL, P_MODEL, DRAW, "m16", GetBodygroup(), (22.0/35.0) );
	}

	void Holster( int skipLocal = 0 )
	{
		isLeagleReload = false;
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
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.33f;

		ShootWeapon( SHOOT_S, 1, VecModAcc( VECTOR_CONE_1DEGREES, 1.25f, 0.5f, 1.0f ), (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? 1024 : 8192, DAMAGE, true, DMG_SNIPER | DMG_NEVERGIB, 0.5, 0.375 );

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		if( WeaponADSMode != NWINS2BASE::IRON_IN )
		{
			if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
				KickBack( 0.8, 0.3, 0.225, 0.03, 3.5, 2.5, 5 );
			else if( m_pPlayer.pev.velocity.Length2D() > 0 )
				KickBack( 0.5, 0.275, 0.2, 0.03, 3.0, 2.0, 7 );
			else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
				KickBack( 0.225, 0.15, 0.1, 0.015, 2.0, 1.0, 10 );
			else
				KickBack( 0.35, 0.175, 0.125, 0.02, 2.5, 1.5, 8 );
		}
		else
		{
			PunchAngle( Vector( Math.RandomFloat( -1.875, -1.9 ), (Math.RandomLong( 0, 1 ) < 0.5) ? -0.50f : 0.50f, Math.RandomFloat( -0.5, 0.5 ) ) );
		}

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
			self.SendWeaponAnim( Math.RandomLong( IRON_FIRE1, IRON_FIRE3 ), 0, GetBodygroup() );
		else
			self.SendWeaponAnim( Math.RandomLong( FIRE1, FIRE2 ), 0, GetBodygroup() );

		ShellEject( m_pPlayer, m_iShell, (WeaponADSMode != NWINS2BASE::IRON_IN) ? Vector( 18.5, 5.75, -8.5 ) : Vector( 18.5, 1.6, -4.5 ) );
	}

	void SecondaryAttack()
	{
		self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.13;
		
		switch( WeaponADSMode )
		{
			case NWINS2BASE::IRON_OUT:
			{
				self.SendWeaponAnim( IRON_TO, 0, GetBodygroup() );
				EffectsFOVON( 35 );
				break;
			}
			case NWINS2BASE::IRON_IN:
			{
				self.SendWeaponAnim( IRON_FROM, 0, GetBodygroup() );
				EffectsFOVOFF();
				break;
			}
		}
	}

	void ItemPreFrame()
	{
		/*if( m_reloadTimer < g_Engine.time && canReload )
			self.Reload();*/

		BaseClass.ItemPreFrame();
	}

	void DoReload()
	{
		if(self.m_iClip == 0){
			Reload( MAX_CLIP , RELOAD_EMPTY, (136.0/45.0), SetBodygroup() );
		}
		else if(fastReloadCount >= 2){ // LCH: Do fastReload
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + (self.m_iClip - 1) );
			self.m_iClip = 1; // LCH: Drop Current Mag.
			Reload( MAX_CLIP + 1, RELOAD_EMPTY, (74.0/45.0), SetBodygroup() );
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_VOICE, NWINS2BASE::DeployPistolSounds[ Math.RandomLong( 0, NWINS2BASE::DeployPistolSounds.length() - 1 )], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		else{
			Reload( MAX_CLIP + 1, RELOAD, (142.0/48.0), SetBodygroup() );
		}
		fastReloadCount = 0;
		canReload = true;

		BaseClass.Reload();
	}

	void Reload()
	{
		ChangeFireMode( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_FIRESELECT : FIRESELECT, GetBodygroup(), NWINS2BASE::SELECTFIRE_AUTO, NWINS2BASE::SELECTFIRE_SEMI, (25.0/30.0) );

		if( self.m_iClip >= MAX_CLIP + 1 || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || m_pPlayer.pev.button & IN_USE != 0 )
			return;

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
		{
			self.SendWeaponAnim( IRON_FROM, 0, GetBodygroup() );
			EffectsFOVOFF();
		}

		m_reloadTimer = g_Engine.time + 0.16;

		if(self.m_iClip > 0 && isLeagleReload){
			isLeagleReload = false;
			fastReloadCount++;
		}

		if(canReload){
			canReload = false;
			SetThink( ThinkFunction( this.DoReload ) );
			self.pev.nextthink = m_reloadTimer;
		}
	}

	void WeaponIdle()
	{
		if( self.m_flNextPrimaryAttack < g_Engine.time )
			m_iShotsFired = 0;

		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if(!isLeagleReload)	isLeagleReload = true;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
			self.SendWeaponAnim( IRON_IDLE, 0, GetBodygroup() );
		else
			self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class MK18_MAG : ScriptBasePlayerAmmoEntity, NWINS2BASE::AmmoBase
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
	return "ammo_ins2mk18";
}

string GetName()
{
	return "weapon_ins2mk18";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_MK18::weapon_ins2mk18", GetName() ); // Register the weapon entity
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_MK18::MK18_MAG", GetAmmoName() ); // Register the ammo entity
	g_ItemRegistry.RegisterWeapon( GetName(), SPR_CAT, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : NWINS2BASE::DF_AMMO_556, "", GetAmmoName() ); // Register the weapon
}

}