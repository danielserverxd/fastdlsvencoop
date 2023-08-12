#include "ph_shot"
#include "p_entity"

const int BOWCASTER_DEFAULT_GIVE		= 50;
const int BOWCASTER_MAX_CARRY			= 250;
const int BOWCASTER_MAX_CLIP			= -1;
const int BOWCASTER_WEIGHT				= 110;
const int BOWCASTER_DAMAGE				= 32;

const string BOWCASTER_SOUND_FIRE		= "portal_house/weapons/fire_minigun01.wav";
const string BOWCASTER_SOUND_EXPLODE	= "portal_house/hit_wallBowcaster.wav";
const string BOWCASTER_SOUND_DRYFIRE	= "portal_house/dryfire.wav";

const string BOWCASTER_MODEL_NULL		= "models/not_precached.mdl";
const string BOWCASTER_MODEL_VIEW		= "models/portal_house/v_768mmvulcan.mdl";
const string BOWCASTER_MODEL_PLAYER		= "models/portal_house/p_768mmvulcan.mdl";
const string BOWCASTER_MODEL_GROUND		= "models/portal_house/w_vulcan.mdl";
const string BOWCASTER_MODEL_CLIP		= "models/portal_house/w_768ammo.mdl";
const string BOWCASTER_MODEL_PROJECTILE	= "models/portal_house/HighPowerBlasterShootRed.mdl";

const Vector VECTOR_CONE_BOWCASTER( 0.15, 0.15, 0.00  );

enum bowcaster_e
{
	BOWCASTER_IDLE1,
	BOWCASTER_FIRE,
	BOWCASTER_DRAW,
	BOWCASTER_HOLSTER,
	BOWCASTER_IDLE2,
	
};

class weapon_vulcan : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	float ATTN_LOW = 0.5;
	int g_iCurrentMode = 0;
	CPEntityController@ pController = null;
	
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, BOWCASTER_MODEL_GROUND );
		self.m_iDefaultAmmo = BOWCASTER_DEFAULT_GIVE;
		self.pev.sequence = 1;
		g_iCurrentMode = 0;
		self.FallInit();

	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( BOWCASTER_MODEL_NULL );
		g_Game.PrecacheModel( BOWCASTER_MODEL_VIEW );
		g_Game.PrecacheModel( BOWCASTER_MODEL_PLAYER );
		g_Game.PrecacheModel( BOWCASTER_MODEL_GROUND );
		g_Game.PrecacheModel( BOWCASTER_MODEL_PROJECTILE );

		g_Game.PrecacheGeneric( "sound/" + BOWCASTER_SOUND_FIRE );
		g_Game.PrecacheGeneric( "sound/" + BOWCASTER_SOUND_EXPLODE );
		g_Game.PrecacheGeneric( "sound/" + BOWCASTER_SOUND_DRYFIRE );
		
		g_SoundSystem.PrecacheSound( BOWCASTER_SOUND_FIRE );
		g_SoundSystem.PrecacheSound( BOWCASTER_SOUND_DRYFIRE );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= BOWCASTER_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= BOWCASTER_MAX_CLIP;
		info.iSlot 		= 2;
		info.iPosition 	= 10;
		info.iFlags 	= ITEM_FLAG_NOAUTORELOAD;
		info.iWeight 	= BOWCASTER_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}
	
	bool Deploy()
	{
		if (@pController == null){
		@pController = SpawnWeaponControllerInPlayer( m_pPlayer, BOWCASTER_MODEL_PLAYER );
		}
		return self.DefaultDeploy( self.GetV_Model( BOWCASTER_MODEL_VIEW ), self.GetP_Model( BOWCASTER_MODEL_PLAYER ), BOWCASTER_DRAW, "mp5" );
		
	}


	void Holster( int skipLocal = 0 )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.7;
		pController.DeletePEntity();
		@pController = null;

	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void PrimaryAttack()
	{

		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, BOWCASTER_SOUND_DRYFIRE, 1.0, ATTN_LOW, 0, PITCH_NORM );
			return;
		}
		
		if (@pController != null){
		pController.SetAnimAttack();
		}
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = BOWCASTER_FIRE;
			break;
			
			case 1: iAnim = BOWCASTER_FIRE;
			break;
		}
		self.SendWeaponAnim( iAnim );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, BOWCASTER_SOUND_FIRE, 1.0, ATTN_LOW, 0, 94 + Math.RandomLong( 0,0xF ) );
		
		Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle);
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		// optimized multiplayer. Widened to make it easier to hit a moving player
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, BOWCASTER_DAMAGE);

		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.1;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
						+ x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right 
						+ y * VECTOR_CONE_4DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_9MM );
			}
		}
		
		Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle);
		Vector vecTemp;
		vecTemp = m_pPlayer.pev.v_angle;

		vecTemp.x -= 0.0f;
		vecTemp.y += 0.0f;
		m_pPlayer.pev.angles = vecTemp;
		m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
		
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
		self.m_flNextPrimaryAttack = g_Engine.time + 0.08;
		self.m_flTimeWeaponIdle = g_Engine.time + 1.0;
				
	}
	
	void SetFOV( int fov )
	{
		m_pPlayer.pev.fov = m_pPlayer.m_iFOV = fov;
	}

	void WeaponIdle()
	{
		
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;


		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = BOWCASTER_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + 2.4;
			break;
			
			case 1: iAnim = BOWCASTER_IDLE2;
			self.m_flTimeWeaponIdle = g_Engine.time + 5;
			break;
		}
		
		self.SendWeaponAnim( iAnim );

			
	}

	void Reload()
	{
		
		if( self.m_iClip != 0 )
			return;
		
		self.DefaultReload( 1, BOWCASTER_HOLSTER, 3.6 );
	}
}

class HighPowerBlasterAmmoBox : ScriptBasePlayerAmmoEntity
{	
	void Spawn()
	{ 
		Precache();
		g_EntityFuncs.SetModel( self, BOWCASTER_MODEL_CLIP );
		self.pev.body = 15;
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( BOWCASTER_MODEL_CLIP );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{ 
		int iGive;

		iGive = BOWCASTER_DEFAULT_GIVE;

		if( pOther.GiveAmmo( iGive, "highpowerblaster", BOWCASTER_MAX_CARRY ) != -1)
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

void RegisterBowcasterBlaster()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_vulcan", "weapon_vulcan" );
	g_ItemRegistry.RegisterWeapon( "weapon_vulcan", "portal_house", "highpowerblaster" );
}

void RegisterHighPowerBlasterAmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HighPowerBlasterAmmoBox", "ammo_highpowerblaster" );
}
