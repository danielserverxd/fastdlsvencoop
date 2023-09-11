// Insurgency's Benelli M4 Super 90 (M1014)
/* Model Credits
/ Model: Millenia (Edits by Norman The Loli Pirate), Insurgency Development Team
/ Textures: Millenia, Insurgency Development Team (Edits by Norman The Loli Pirate)
/ Animations: Sinfect (Edits by D.N.I.O. 071)
/ Sounds: New World Interactive, Navaro, KernCore (Conversion to .ogg format)
/ Sprites: D.N.I.O. 071 (Model Render), R4to0 (Vector), KernCore (.spr Compile)
/ Misc: D.N.I.O. 071 (World Model UVs, Compile), Norman The Loli Pirate (World Model)
/ Script: KernCore
*/

#include "../base"

namespace INS2_M1014
{

// Animations
enum INS2_M1014_Animations
{
	IDLE = 0,
	DRAW_FIRST,
	DRAW,
	HOLSTER,
	FIRE1,
	FIRE2,
	DRYFIRE,
	RELOAD_START,
	RELOAD_START_EMPTY,
	RELOAD_INSERT,
	RELOAD_END,
	IRON_IDLE,
	IRON_FIRE1,
	IRON_FIRE2,
	IRON_DRYFIRE,
	IRON_TO,
	IRON_FROM
};

enum INS2_M1014_AmmoType
{
	BUCK_SHOT = 0,
	SINGLE_SLUG
};

// Models
string W_MODEL = "models/ins2/wpn/m1014/w_m1014.mdl";
string V_MODEL = "models/nw/ins2/wpn/m1014/v_m1014.mdl";
string P_MODEL = "models/ins2/wpn/m1014/p_m1014.mdl";
string A_MODEL = "models/ins2/ammo/12gbox.mdl";
string G_MODEL = "models/cof/shotgun/box.mdl";
int MAG_BDYGRP = 2;
int MAG_SKIN   = 0;
// Sprites
string SPR_CAT = "ins2/shg/"; //Weapon category used to get the sprite's location
// Sounds
string SHOOT_S = "ins2/wpn/m1014/shoot.ogg";
string EMPTY_S = "ins2/wpn/m1014/empty.ogg";
// Information
int MAX_CARRY   	= 9000;
int MAX_CLIP    	= 10;
int MAX_CARRY2   	= 9000;
int MAX_CLIP2    	= 10;
int DEFAULT_GIVE 	= MAX_CLIP * 4;
int DEFAULT_GIVE2	= MAX_CLIP2 * 4;
int WEIGHT      	= 20;
int FLAGS       	= ITEM_FLAG_NOAUTORELOAD | ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_ESSENTIAL;
uint DAMAGE     	= 10; //10*1.4 = 14
uint DAMAGESLUG 	= 65; //65*1.4 = 91
uint SLOT       	= 3;
uint POSITION      	= 14;
float RPM_AIR   	= 0.115f; //Rounds per minute in air
float RPM_WTR   	= 0.215f; //Rounds per minute in water
string AMMO_TYPE 	= "ins2_12x70buckshot";
string AMMO_TYPE2 	= "ins2_12x70buckball";
int AMMO_GIVE		= 12;
int AMMO_GIVE2		= 12;
uint PELLETCOUNT 	= 8;
Vector VECTOR_CONE( 0.03490, 0.04362, 0.0 ); //4x5 DEGREES

class weapon_ins2m1014 : ScriptBasePlayerWeaponEntity, NWINS2BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private bool m_WasDrawn, m_fShotgunReload;
	private float m_flNextReload;
	private int m_iAmmoMode;
	private bool m_bIsSwitching;
	private int GetBodygroup()
	{
		return 0;
	}
	private array<string> Sounds = {
		"ins2/wpn/m1014/bltbk.ogg",
		"ins2/wpn/m1014/bltrel.ogg",
		"ins2/wpn/m1014/ins.ogg",
		"ins2/wpn/m1014/sins.ogg",
		"ins2/wpn/m1014/stock.ogg",
		SHOOT_S,
		EMPTY_S
	};

	void Spawn()
	{
		Precache();
		m_WasDrawn = false;
		m_iAmmoMode = BUCK_SHOT;
		self.m_iClip2 = 0;
		m_bIsSwitching = false;
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
		self.m_iDefaultSecAmmo = DEFAULT_GIVE2;
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		g_Game.PrecacheModel( G_MODEL );
		m_iShell = g_Game.PrecacheModel( NWINS2BASE::SHELL_12GREEN );

		g_Game.PrecacheOther( GetAmmoName() );

		NWINS2BASE::PrecacheSound( Sounds );
		NWINS2BASE::PrecacheSound( NWINS2BASE::DeployFirearmSounds );
		
		g_Game.PrecacheGeneric( "sprites/" + SPR_CAT + self.pev.classname + ".txt" );
		g_Game.PrecacheGeneric( "events/" + "muzzle_ins2_DSG.txt" );
		CommonPrecache();
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (NWINS2BASE::ShouldUseCustomAmmo) ? MAX_CARRY : NWINS2BASE::DF_MAX_CARRY_BUCK;
		info.iAmmo1Drop	= MAX_CLIP;
		info.iMaxAmmo2 	= (NWINS2BASE::ShouldUseCustomAmmo) ? MAX_CARRY2 : NWINS2BASE::DF_MAX_CARRY_SPOR;
		info.iAmmo2Drop	= MAX_CLIP2;
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

		//Workaround for a ammo bug
		if( m_iAmmoMode == SINGLE_SLUG )
		{
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip );
			self.m_iClip = 0;
		}

		//Workaround for another ammo bug
		if( m_iAmmoMode == BUCK_SHOT && self.m_iClip2 > 0 )
		{
			m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) + self.m_iClip2 );
			self.m_iClip2 = 0;

			self.m_iClip = MAX_CLIP;
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - self.m_iClip );
		}

		if( m_WasDrawn == false )
		{
			m_WasDrawn = true;
			return Deploy( V_MODEL, P_MODEL, DRAW_FIRST, "shotgun", GetBodygroup(), (56.0/40.0) );
		}
		else
			return Deploy( V_MODEL, P_MODEL, DRAW, "shotgun", GetBodygroup(), (22.0/40.0) );
	}

	void Holster( int skipLocal = 0 )
	{
		m_fShotgunReload = false;
		m_bIsSwitching = false;
		CommonHolster();

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if((m_iAmmoMode == BUCK_SHOT && self.m_iClip <= 0) || (m_iAmmoMode == SINGLE_SLUG && self.m_iClip2 <= 0))
		{
			self.PlayEmptySound();
			self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_DRYFIRE : DRYFIRE, 0, GetBodygroup() );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
			return;
		}

		if( m_pPlayer.m_afButtonPressed & IN_ATTACK == 0 )
			return;

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? WeaponTimeBase() + RPM_WTR : WeaponTimeBase() + RPM_AIR;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;

		if( m_iAmmoMode == BUCK_SHOT )
			ShootWeapon( SHOOT_S, PELLETCOUNT, VECTOR_CONE, (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? 384 : 4096, DAMAGE, false, DMG_LAUNCH | DMG_SHOCK, 0.5, 0.4 );
		else
			ShootWeapon( SHOOT_S, 1, (WeaponADSMode == NWINS2BASE::IRON_IN) ? g_vecZero : VECTOR_CONE_1DEGREES, (m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) ? 1024 : 4096, DAMAGESLUG, false, DMG_LAUNCH | DMG_SHOCK, 0.5, 0.4, true );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		PunchAngle( Vector( Math.RandomFloat( -5.5, -4.75 ), (Math.RandomLong( 0, 1 ) < 0.5) ? -1.0 : 1.25, Math.RandomFloat( -0.5, 0.5 ) ) );

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
			self.SendWeaponAnim( Math.RandomLong( IRON_FIRE1, IRON_FIRE2 ), 0, GetBodygroup() );
		else
			self.SendWeaponAnim( Math.RandomLong( FIRE1, FIRE2 ), 0, GetBodygroup() );


		ShellEject( m_pPlayer, m_iShell, (WeaponADSMode != NWINS2BASE::IRON_IN) ? Vector( 18.5, 8, -8 ) : Vector( 18.5, 1.6, -4 ), false, false, TE_BOUNCE_SHOTSHELL );
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
				EffectsFOVON( 45 );
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

	void TertiaryAttack()
	{
		if(m_bIsSwitching)
			return;
		if( m_iAmmoMode == BUCK_SHOT && m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) <= 0 )
			return;
		else if( m_iAmmoMode == SINGLE_SLUG && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		m_bIsSwitching = true;
		switch( m_iAmmoMode )
		{
			case BUCK_SHOT:
				m_iAmmoMode = SINGLE_SLUG;
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) + self.m_iClip );
				self.m_iClip = 0;
				g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, "Switched to ammo: Single slug" );
				break;

			case SINGLE_SLUG:
				m_iAmmoMode = BUCK_SHOT;
				m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) + self.m_iClip2 );
				self.m_iClip2 = 0;
				g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, "Switched to ammo: Buck shot" );
				break;
		}

		self.Reload();
		self.m_flTimeWeaponIdle = self.m_flNextTertiaryAttack = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1;
	}

	void ItemPreFrame()
	{
		if( m_reloadTimer < g_Engine.time && canReload )
			self.Reload();

		BaseClass.ItemPreFrame();
	}

	void ItemPostFrame()
	{
		// Checks if the player pressed one of the attack buttons, stops the reload and then attack
		if( m_fShotgunReload )
		{
			if( (CheckButton() || ((self.m_iClip >= MAX_CLIP || self.m_iClip2 >= MAX_CLIP2) && m_pPlayer.pev.button & IN_RELOAD != 0)) && m_flNextReload <= g_Engine.time )
			{
				self.SendWeaponAnim( RELOAD_END, 0, GetBodygroup() );

				self.m_flTimeWeaponIdle = g_Engine.time + (21.0/42.0);
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + 0.4;
				m_fShotgunReload = false;
				m_bIsSwitching = false;
			}
		}
		BaseClass.ItemPostFrame();
	}

	void SetAmmo()
	{
		switch( m_iAmmoMode )
		{
			case BUCK_SHOT:
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
				self.m_iClip += 1;
				break;
			case SINGLE_SLUG:
				m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) - 1 );
				self.m_iClip2 += 1;
				break;
		}
	}

	void Reload()
	{
		int iAmmo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		int iAmmo2 = m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType );

		if( m_iAmmoMode == BUCK_SHOT && (iAmmo <= 0 || self.m_iClip >= MAX_CLIP) )
			return;
		else if( m_iAmmoMode == SINGLE_SLUG && (iAmmo2 <= 0 || self.m_iClip2 >= MAX_CLIP2) )
			return;

		if( WeaponADSMode == NWINS2BASE::IRON_IN )
		{
			self.SendWeaponAnim( IRON_FROM, 0, GetBodygroup() );
			m_reloadTimer = g_Engine.time + 0.16;
			m_pPlayer.m_flNextAttack = 0.16;
			EffectsFOVOFF();
			canReload = true;
		}

		if( m_reloadTimer < g_Engine.time )
		{
			if( m_flNextReload > WeaponTimeBase() )
				return;

			// don't reload until recoil is done
			if( self.m_flNextPrimaryAttack > WeaponTimeBase() && !m_fShotgunReload )
			{
				m_fShotgunReload = false;
				return;
			}
			if( !m_fShotgunReload )
			{
				if((m_iAmmoMode == BUCK_SHOT && self.m_iClip <= 0) || (m_iAmmoMode == SINGLE_SLUG && self.m_iClip2 <= 0))
				{
					self.SendWeaponAnim( RELOAD_START_EMPTY, 0, GetBodygroup() );
					SetThink( ThinkFunction( SetAmmo ) );
					self.pev.nextthink = WeaponTimeBase() + (63.0/42.0);

					m_pPlayer.m_flNextAttack = (97.5/42.0); //Always uses a relative time due to prediction
					self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + (97.5/42.0);
				}
				else
				{
					self.SendWeaponAnim( RELOAD_START, 0, GetBodygroup() );

					m_pPlayer.m_flNextAttack = (21.0/42.0); //Always uses a relative time due to prediction
					self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + (21.0/42.0);
				}

				canReload = false;
				m_fShotgunReload = true;
				return;
			}
			else if( m_fShotgunReload )
			{
				if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
					return;

				if( self.m_iClip >= MAX_CLIP || self.m_iClip2 >= MAX_CLIP2 )
				{
					m_fShotgunReload = false;
					return;
				}

				self.SendWeaponAnim( RELOAD_INSERT, 0, GetBodygroup() );

				m_flNextReload = WeaponTimeBase() + (24.0/45.0);
				self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + (24.0/45.0);

				switch( m_iAmmoMode )
				{
					case BUCK_SHOT:
						self.m_iClip += 1;
						iAmmo -= 1;
						break;
					case SINGLE_SLUG:
						self.m_iClip2 += 1;
						iAmmo2 -= 1;
						break;
				}
			}
		}

		switch( m_iAmmoMode )
		{
			case BUCK_SHOT:
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, iAmmo );
				break;
			case SINGLE_SLUG:
				m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, iAmmo2 );
				break;
		}
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle < g_Engine.time )
		{
			if( m_fShotgunReload )
			{
				if( (m_iAmmoMode == BUCK_SHOT && self.m_iClip != MAX_CLIP && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0) || (m_iAmmoMode == SINGLE_SLUG && self.m_iClip2 != MAX_CLIP2 && m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) > 0) )
				{
					self.Reload();
				}
				else
				{
					// reload debounce has timed out
					self.SendWeaponAnim( RELOAD_END, 0, GetBodygroup() );

					m_fShotgunReload = false;
					self.m_flTimeWeaponIdle = g_Engine.time + (21.0/42.0);
					self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + 0.4;
				}
			}
			else
			{
				m_bIsSwitching = false;
				self.SendWeaponAnim( (WeaponADSMode == NWINS2BASE::IRON_IN) ? IRON_IDLE : IDLE, 0, GetBodygroup() );
				self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
			}
		}
	}
}

class M1014_MAG : ScriptBasePlayerAmmoEntity, NWINS2BASE::AmmoBase
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, A_MODEL );
		self.pev.body = MAG_BDYGRP;
		self.pev.skin = MAG_SKIN;
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( A_MODEL );
		CommonPrecache();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return CommonAddAmmo( pOther, AMMO_GIVE, (NWINS2BASE::ShouldUseCustomAmmo) ? MAX_CARRY : NWINS2BASE::DF_MAX_CARRY_BUCK, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : NWINS2BASE::DF_AMMO_BUCK );
	}
}

class M1014_SLUG : ScriptBasePlayerAmmoEntity, NWINS2BASE::AmmoBase
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, G_MODEL );
		self.pev.body = MAG_BDYGRP;
		BaseClass.Spawn();
	}

	void Precache()
	{
		g_Game.PrecacheModel( G_MODEL );
		CommonPrecache();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return CommonAddAmmo( pOther, AMMO_GIVE2, (NWINS2BASE::ShouldUseCustomAmmo) ? MAX_CARRY2 : NWINS2BASE::DF_MAX_CARRY_BUCK, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE2 : NWINS2BASE::DF_AMMO_SPOR );
	}
}

string GetAmmoName()
{
	return "ammo_ins2m1014";
}

string GetGLName()
{
	return "ammo_ins2m1014gl";
}

string GetName()
{
	return "weapon_ins2m1014";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M1014::weapon_ins2m1014", GetName() ); // Register the weapon entity
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M1014::M1014_MAG", GetAmmoName() ); // Register the ammo entity
	g_CustomEntityFuncs.RegisterCustomEntity( "INS2_M1014::M1014_SLUG", GetGLName() );
	g_ItemRegistry.RegisterWeapon( GetName(), SPR_CAT, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : NWINS2BASE::DF_AMMO_BUCK, (NWINS2BASE::ShouldUseCustomAmmo) ? AMMO_TYPE2 : NWINS2BASE::DF_AMMO_SPOR, GetAmmoName(), GetGLName() ); // Register the weapon
}

}