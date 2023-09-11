// Insurgency's FN M249
/* Model Credits
/ Model: Schmung, Firearms Source Team
/ Textures: Firearms Source Team
/ Animations: New World Interactive, D.N.I.O. 071 (Insane amount of frame edits)
/ Sounds: New World Interactive, D.N.I.O. 071 (Conversion to .ogg format)
/ Sprites: D.N.I.O. 071 (Model Render), R4to0 (Vector), KernCore (.spr Compile)
/ Misc: D.N.I.O. 071 (UV Chop, Compile)
/ Script: KernCore
*/

#include "../base"

namespace INS2_M249
{

// Animations
enum INS2_M249_Animations
{
	IDLE = 0,
	DRAW_FIRST,
	DRAW,
	HOLSTER,
	FIRE,
	DRYFIRE,
	RELOAD,
	RELOAD_HALF,
	RELOAD_EMPTY,
	IRON_IDLE,
	IRON_FIRE,
	IRON_DRYFIRE,
	IRON_TO,
	IRON_FROM,
	BIPOD_IN,
	BIPOD_OUT,
	BIPOD_IDLE,
	BIPOD_FIRE,
	BIPOD_DRYFIRE,
	BIPOD_RELOAD,
	BIPOD_RELOAD_HALF,
	BIPOD_RELOAD_EMPTY,
	BIPOD_IRON_IDLE,
	BIPOD_IRON_FIRE,
	BIPOD_IRON_DRYFIRE,
	BIPOD_IRON_TO,
	BIPOD_IRON_FROM,
	BIPOD_IRON_IN,
	BIPOD_IRON_OUT
};

enum M249_Bodygroups
{
	ARMS = 0,
	M249_STUDIO0,
	M249_STUDIO1,
	M249_STUDIO2,
	MAIN_BULLETS,
	HELPER_BULLETS
};

// Models
string W_MODEL = "models/ins2/wpn/m249/w_m249.mdl";
string V_MODEL = "models/nw/ins2/wpn/m249/v_m249.mdl";
string P_MODEL = "models/ins2/wpn/m249/p_m249.mdl";
string A_MODEL = "models/ins2/ammo/mags.mdl";
int MAG_BDYGRP = 19;
// Sprites
string SPR_CAT = "ins2/lmg/"; //Weapon category used to get the sprite's location
// Sounds
string SHOOT_S = "ins2/wpn/m249/shoot.ogg";
string EMPTY_S = "ins2/wpn/m249/empty.ogg";
// Information
int MAX_CARRY   	= 9000;
int MAX_CLIP    	= 200;
int DEFAULT_GIVE 	= MAX_CLIP * 2;
int WEIGHT      	= 55;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_ESSENTIAL;
uint DAMAGE     	= 20; //20*1.6 = 32
uint SLOT       	= 7;
uint POSITION   	= 14;
float RPM_AIR   	= 900; //Rounds per minute in air def:775
float RPM_WTR   	= 775; //Rounds per minute in water def:600
string AMMO_TYPE 	= "ins2_5.56x45mm";

class weapon_ins2m249 : ScriptBasePlayerWeaponEntity, NWINS2BASE::WeaponBase, NWINS2BASE::BipodWeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private bool m_WasDrawn, m_bInReload;
	private int GetBodygroup()
	{
		if( self.m_iClip >= 16 )
			m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, MAIN_BULLETS, 15 );
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
			//D.N.I.O. 071 edits: setup for the main bullets bodygroup on _EMPTY reloads
			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) >= 16 || (m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip) >= 16 )
			{
				m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, (self.m_iClip <= 0) ? MAIN_BULLETS : HELPER_BULLETS, 15 );
			}
			else if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) < 16 && (m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip) < 16 )
			{
				m_iCurBodyConfig = g_ModelFuncs.SetBodygroup( g_ModelFuncs.ModelIndex( V_MODEL ), m_iCurBodyConfig, (self.m_iClip <= 0) ? MAIN_BULLETS : HELPER_BULLETS, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + (self.m_iClip - 1) );
			}
		}

		return m_iCurBodyConfig;
	}
	private array<string> Sounds = {
		"ins2/wpn/rpk/bdply.ogg",
		"ins2/wpn/rpk/brtrct.ogg",
		"ins2/wpn/m249/bltbk.ogg",
		"ins2/wpn/m249/bltrel.ogg",
		"ins2/wpn/m249/close.ogg",
		"ins2/wpn/m249/open.ogg",
		"ins2/wpn/m249/hit.ogg",
		"ins2/wpn/m249/magin.ogg",
		"ins2/wpn/m249/magemp.ogg",
		"ins2/wpn/m249/magout.ogg",
		"ins2/wpn/m249/throw.ogg",
		"ins2/wpn/uni/align.ogg",
		"ins2/wpn/uni/jingle.ogg",
		SHOOT_S,
		EMPTY_S
	};

	void Spawn()
	{
		Precache();
		m_WasDrawn = false;
		m_bInReload = false;
		WeaponBipodMode = NWINS2BASE::BIPOD_UNDEPLOYED;
		self.pev.body = 1;
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		m_iShell = g_Game.PrecacheModel( NWINS2BASE::BULLET_556AP );

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
		m_bInReload = false;

		SetThink( ThinkFunction( ShowBipodSpriteThink ) );
		self.pev.nextthink = g_Engine.time + 0.2;

		self.pev.body = 0;

		if( m_WasDrawn == false )
		{
			m_WasDrawn = true;
			return Deploy( V_MODEL, P_MODEL, DRAW_FIRST, "saw", GetBodygroup(), (78.0/45.0) );
		}
		else
			return Deploy( V_MODEL, P_MODEL, DRAW, "saw", GetBodygroup(), (30.0/45.0) );
	}

	void Holster( int skipLocal = 0 )
	{
		m_bInReload = false;
		WeaponBipodMode = NWINS2BASE::BIPOD_UNDEPLOYED;
		CommonHolster();

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			if( WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED )
				self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_DRYFIRE : DRYFIRE, 0, GetBodygroup() );
			else if( WeaponBipodMode == NWINS2BASE::BIPOD_DEPLOYED )
				self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? BIPOD_IRON_DRYFIRE : BIPOD_DRYFIRE, 0, GetBodygroup() );

			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
			return;
		}

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? WeaponTimeBase() + GetFireRate( RPM_WTR ) : WeaponTimeBase() + GetFireRate( RPM_AIR );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5f;

		ShootWeapon( SHOOT_S, 1, VecModAcc( VECTOR_CONE_1DEGREES, 1.2f, 0.45f, 1.07f ), (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? 1024 : 8192, DAMAGE, true, DMG_SNIPER | DMG_NEVERGIB, 0.5, 0.6 );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		if( WeaponADSMode != NWINS2BASE::IRON_IN && WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED )
		{
			if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				KickBack( 2.0, 0.65, 0.45, 0.125, 5.0, 3.5, 7 );
			}
			else if( m_pPlayer.pev.velocity.Length2D() > 0 )
			{
				KickBack( 1.1, 0.5, 0.3, 0.06, 4.0, 2.5, 8 );
			}
			else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				KickBack( 0.7, 0.325, 0.25, 0.025, 3.5, 2.0, 9 );
			}
			else
			{
				KickBack( 0.9, 0.35, 0.3, 0.03, 3.75, 3.0, 9 );
			}
		}
		else
		{
			PunchAngle( Vector( Math.RandomFloat( -1.875, -2.475 ), (Math.RandomLong( 0, 1 ) < 0.5) ? -0.6f : 0.6f, Math.RandomFloat( -0.5, 0.5 ) ) );
		}

		if( WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED )
		{
			if( WeaponADSMode == NWINS2BASE::IRON_IN )
				self.SendWeaponAnim( IRON_FIRE, 0, GetBodygroup() );
			else
				self.SendWeaponAnim( FIRE, 0, GetBodygroup() );
		}
		else if( WeaponBipodMode == NWINS2BASE::BIPOD_DEPLOYED )
		{
			if( WeaponADSMode == NWINS2BASE::IRON_IN )
				self.SendWeaponAnim( BIPOD_IRON_FIRE, 0, GetBodygroup() );
			else
				self.SendWeaponAnim( BIPOD_FIRE, 0, GetBodygroup() );
		}

		ShellEject( m_pPlayer, m_iShell, (WeaponADSMode != NWINS2BASE::IRON_IN) ? Vector( 16, 7, -12 ) : Vector( 16, 2.5, -6.5 ) );
	}

	void SecondaryAttack()
	{
		self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.2;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.13;
		
		switch( WeaponADSMode )
		{
			case NWINS2BASE::IRON_OUT:
			{
				self.SendWeaponAnim( (WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED) ? IRON_TO : BIPOD_IRON_TO, 0, GetBodygroup() );
				EffectsFOVON( 40 );
				break;
			}
			case NWINS2BASE::IRON_IN:
			{
				self.SendWeaponAnim( (WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED) ? IRON_FROM : BIPOD_IRON_FROM, 0, GetBodygroup() );
				EffectsFOVOFF();
				break;
			}
		}
	}

	void TertiaryAttack()
	{
		if( WeaponADSMode == NWINS2BASE::IRON_IN )
			DeployBipod( BIPOD_IRON_IN, BIPOD_IRON_OUT, GetBodygroup(), (45.0/30.0), (58.0/30.0) );
		else
			DeployBipod( BIPOD_IN, BIPOD_OUT, GetBodygroup(), (45.0/30.0), (58.0/30.0) );
	}

	void ItemPostFrame()
	{
		BaseClass.ItemPostFrame();
	}

	void ItemPreFrame()
	{
		if( m_reloadTimer < g_Engine.time && canReload )
			self.Reload();

		if( m_bInReload )
			m_bInReload = false;

		BaseClass.ItemPreFrame();
	}

	void Reload()
	{
		if( self.m_iClip >= MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
		{
			self.SendWeaponAnim( (WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED) ? IRON_FROM : BIPOD_IRON_FROM, 0, GetBodygroup() );
			m_reloadTimer = g_Engine.time + 0.16;
			m_pPlayer.m_flNextAttack = 0.16;
			canReload = true;
			EffectsFOVOFF();
		}

		if( m_reloadTimer < g_Engine.time )
		{
			m_bInReload = true;
			if( WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED )
			{
				if( self.m_iClip > 16 )
					Reload( MAX_CLIP, RELOAD, (142.0/23.0), SetBodygroup() );
				else if( self.m_iClip <= 0 )
					Reload( MAX_CLIP, RELOAD_EMPTY, (174.0/23.0), SetBodygroup() );
				else
					Reload( MAX_CLIP, RELOAD_HALF, (155.0/23.0), SetBodygroup() );
			}
			else if( WeaponBipodMode == NWINS2BASE::BIPOD_DEPLOYED )
			{
				if( self.m_iClip > 16 )
					Reload( MAX_CLIP, BIPOD_RELOAD, (142.0/23.0), SetBodygroup() );
				else if( self.m_iClip <= 0 )
					Reload( MAX_CLIP, BIPOD_RELOAD_EMPTY, (171.0/23.0), SetBodygroup() );
				else
					Reload( MAX_CLIP, BIPOD_RELOAD_HALF, (155.0/23.0), SetBodygroup() );
			}
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

		if( WeaponBipodMode == NWINS2BASE::BIPOD_UNDEPLOYED )
		{
			self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_IDLE : IDLE, 0, GetBodygroup() );
		}
		else if( WeaponBipodMode == NWINS2BASE::BIPOD_DEPLOYED )
		{
			self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? BIPOD_IRON_IDLE : BIPOD_IDLE, 0, GetBodygroup() );
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class M249_MAG : ScriptBasePlayerAmmoEntity, NWINS2BASE::AmmoBase
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
	return "ammo_ins2m249";
}

string GetName()
{
	return "weapon_ins2m249";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M249::weapon_ins2m249", GetName() ); // Register the weapon entity
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M249::M249_MAG", GetAmmoName() ); // Register the ammo entity
	g_ItemRegistry.RegisterWeapon( GetName(), SPR_CAT, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : NWINS2BASE::DF_AMMO_556, "", GetAmmoName() ); // Register the weapon
}

}