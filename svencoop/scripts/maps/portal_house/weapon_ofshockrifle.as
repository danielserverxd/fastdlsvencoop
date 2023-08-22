/*  
* The original Half-Life Opposing force version
// Author: NERO-SAN
*/

const bool bMultiplayer				= true;
const float OFW_DELAY				= bMultiplayer ? 0.1f : 0.2f;
const float OFW_DELAY_RECHARGE		= bMultiplayer ? 0.25f : 0.50f;
const int OFW_MAX_CARRY				= 30;
const int OPFORSHOCK_SLOT			= 7;
const int OPFORSHOCK_POSITION		= 12;

enum ofw_e
{
	ANIM_IDLE1 = 0,
	ANIM_FIRE,
	ANIM_DRAW,
	ANIM_HOLSTER,
	ANIM_IDLE3
};

const array<string> pIdleSounds =
{
	"shockroach/shock_idle1.wav",
	"shockroach/shock_idle2.wav",
	"shockroach/shock_idle3.wav"
};

class weapon_ofshockrifle : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	private bool m_bShouldUpdateEffects;
	private float m_flBeamLifeTime;
	private float m_flRechargeTime;

	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, "models/w_shock_rifle.mdl" );
		self.m_iDefaultAmmo = OFW_MAX_CARRY;
		m_bShouldUpdateEffects = false;
		m_flBeamLifeTime = 0.0f;
		self.FallInit();

		pev.sequence = 0;
		pev.animtime = g_Engine.time;
		pev.framerate = 1;
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( "models/v_shock.mdl" );
		g_Game.PrecacheModel( "models/w_shock_rifle.mdl" );
		g_Game.PrecacheModel( "models/p_shock.mdl" );

		g_Game.PrecacheModel( "sprites/lgtning.spr" );
		for( uint i = 0; i < pIdleSounds.length(); i++ )
			g_SoundSystem.PrecacheSound( pIdleSounds[i] );

		g_SoundSystem.PrecacheSound( "weapons/shock_discharge.wav" );
		g_SoundSystem.PrecacheSound( "weapons/shock_draw.wav" );
		g_SoundSystem.PrecacheSound( "weapons/shock_fire.wav" );
		g_SoundSystem.PrecacheSound( "weapons/shock_impact.wav" );
		g_SoundSystem.PrecacheSound( "weapons/shock_recharge.wav" );

		//g_Game.PrecacheOther( "opfor_shock" );
		g_Game.PrecacheOther( "shock_beam" );

		//Precache these for downloading
		g_Game.PrecacheGeneric( "sprites/portal_house/weapon_ofshockrifle.txt" );
		g_Game.PrecacheGeneric( "sprites/portal_house/640hud7.spr" ); //from opfor
		g_Game.PrecacheGeneric( "sprites/portal_house/640hudof03.spr" ); //from opfor
		g_Game.PrecacheGeneric( "sprites/portal_house/640hudof04.spr" ); //from opfor
		g_Game.PrecacheGeneric( "sprites/portal_house/ofch1.spr" ); //from opfor
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= OFW_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= WEAPON_NOCLIP; //0 to enable Reload()?
		info.iSlot			= OPFORSHOCK_SLOT - 1;
		info.iPosition		= OPFORSHOCK_POSITION - 1;
		info.iFlags			= ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_NOAUTORELOAD;
		info.iWeight		= 10;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer(pPlayer) )
		{
			@m_pPlayer = pPlayer;

			pPlayer.m_rgAmmo(self.PrimaryAmmoIndex(), OFW_MAX_CARRY);

			NetworkMessage m( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				m.WriteLong( g_ItemRegistry.GetIdForName("weapon_ofshockrifle") );
			m.End();

			return true;
		}

		return false;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;

			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_AUTO, "shockroach/shock_angry.wav", 0.8f, ATTN_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model("models/v_shock.mdl"), self.GetP_Model("models/p_shock.mdl"), ANIM_DRAW, "bow" );
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 1.0f;

			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false;
		SetThink( null );

		self.SendWeaponAnim(ANIM_HOLSTER);
		m_pPlayer.m_flNextAttack = g_Engine.time + 0.8f;

		if( m_pPlayer.m_rgAmmo(self.PrimaryAmmoIndex()) <= 0 )
			m_pPlayer.m_rgAmmo(self.PrimaryAmmoIndex(), 1);
	}

	void PrimaryAttack()
	{
		Reload();

		if( m_pPlayer.pev.waterlevel != WATERLEVEL_HEAD )
		{
			int ammo = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
			if( ammo <= 0 )
				return;

			Math.MakeVectors( m_pPlayer.pev.v_angle );

			Vector vecSrc;
			vecSrc = m_pPlayer.GetGunPosition();
			vecSrc = vecSrc + g_Engine.v_forward * 8;
			vecSrc = vecSrc + g_Engine.v_right * 8;
			vecSrc = vecSrc + g_Engine.v_up * -12;

			CBaseEntity@ pShock = g_EntityFuncs.Create( "shock_beam", vecSrc, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() ); //opfor_shock
			pShock.pev.velocity = g_Engine.v_forward * 1500;
			pShock.pev.angles.x = -m_pPlayer.pev.v_angle.x; //to get the projectile to face the direction it's travelling in

			m_flRechargeTime = g_Engine.time + 1.0f;

			--ammo;
			m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, ammo);

			m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;

			m_pPlayer.pev.punchangle.x = Math.RandomLong(0, 2);
			self.SendWeaponAnim(ANIM_FIRE);
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/shock_fire.wav", 1, ATTN_NORM, 0, 100 );

			if( !m_bShouldUpdateEffects or g_Engine.time >= m_flBeamLifeTime )
			{
				m_bShouldUpdateEffects = true;
				m_flBeamLifeTime = g_Engine.time + 0.3f;
				UpdateEffects();
			}

			m_pPlayer.SetAnimation(PLAYER_ATTACK1);

			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + OFW_DELAY;

			self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
		}
		else
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + OFW_DELAY;
		}
	}

	void SecondaryAttack()
	{
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) >= OFW_MAX_CARRY)
			return;

		while( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) < OFW_MAX_CARRY and m_flRechargeTime < g_Engine.time )
		{
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_ITEM, "weapons/shock_recharge.wav", 0.8f, ATTN_NORM );
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) + 1 );
			m_flRechargeTime += OFW_DELAY_RECHARGE;
		}
	}

	void WeaponIdle()
	{
		Reload();

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flRand = Math.RandomFloat(0, 1);
		if( flRand <= 0.5f )
		{
			iAnim = ANIM_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + 3.3f;

			if( Math.RandomFloat(0, 10) >= 5 )
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0, pIdleSounds.length()-1)], 0.8f, ATTN_IDLE, 0, 90 + Math.RandomLong(-1, 5) );

			self.SendWeaponAnim(iAnim);
		}
		else if( flRand >= 0.7f )
		{
			iAnim = ANIM_IDLE3;
			self.m_flTimeWeaponIdle = g_Engine.time + 3.4f;

			if( Math.RandomFloat(0, 10) >= 5 )
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0, pIdleSounds.length()-1)], 0.8f, ATTN_IDLE, 0, 90 + Math.RandomLong(-1, 5) );

			self.SendWeaponAnim(iAnim);
		}
		else
			self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat(10, 15);
	}

	void ItemPostFrame()
	{
		BaseClass.ItemPostFrame();

		if( (m_pPlayer.pev.button & IN_ATTACK) == 0 )
		{
			if( m_bShouldUpdateEffects )
			{
				if( g_Engine.time <= m_flBeamLifeTime )
					UpdateEffects();
				else
				{
					m_bShouldUpdateEffects = false;
					m_flBeamLifeTime = 0.0f;
				}
			}
		}
	}

	void UpdateEffects()
	{
		//PLAYBACK_EVENT_FULL(0, m_pPlayer.edict(), m_usShockFire, 0.0, (float *)&g_vecZero,(float *)&g_vecZero, 0.0, 0.0, TRUE, 0, 0, 0);
		//int iBeamModelIndex = g_EngineFuncs.ModelIndex( "sprites/lgtning.spr" );

		if( !string(m_pPlayer.pev.viewmodel).IsEmpty() )
		{/*
			for (int i = 1; i < 4; i++)
			{
			 float * start, float * end, int modelIndex, float life, float width, float amplitude, float brightness, float speed, int startFrame, float framerate, float r, float g, float b ); 
				BEAM* pBeam = gEngfuncs.pEfxAPI.
R_BeamPoints( (float*)&vm.attachment[0], (float*)&vm.attachment[i], iBeamModelIndex, 0.01f, 1.1f, 0.3f, 230 + gEngfuncs.pfnRandomFloat(20, 30), 10, 0, 10, 0.0f, 1.0f, 1.0f);*/
/*
				CBeam@ pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 1 );
				if( pBeam !is null )
				{
					pBeam.SetType(BEAM_POINTS);
					//pBeam.flags |= (FBEAM_SHADEIN | FBEAM_SHADEOUT);
					pBeam.SetFlags( BEAM_FSHADEIN | BEAM_FSHADEOUT );
					//pBeam.SetStartAttachment(0);
					//pBeam.SetEndAttachment(i);
					Vector startOrigin, endOrigin;
					{
						Vector dummy;
						self.GetAttachment(0, startOrigin, dummy);
						self.GetAttachment(i, endOrigin, dummy);
					}

					pBeam.SetStartPos(startOrigin);
					pBeam.SetEndPos(endOrigin);
					pBeam.LiveForTime(0.01f);
					pBeam.SetNoise(int(0.3f));
					pBeam.SetBrightness( 230 + Math.RandomLong(20, 30) );
					pBeam.SetScrollRate(10);
					pBeam.SetFrame(0);
					pBeam.SetColor(0, 255, 255);
				}

/*
				Vector startOrigin, endOrigin;
				{
					Vector dummy;
					self.GetAttachment(0, startOrigin, dummy);
					self.GetAttachment(i, endOrigin, dummy);
				}

				NetworkMessage beam( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, endOrigin );
					beam.WriteByte( TE_BEAMPOINTS );
					beam.WriteCoord( startOrigin.x );//start position
					beam.WriteCoord( startOrigin.y );
					beam.WriteCoord( startOrigin.z );
					beam.WriteCoord( endOrigin.x );//end position
					beam.WriteCoord( endOrigin.y );
					beam.WriteCoord( endOrigin.z );
					beam.WriteShort( iBeamModelIndex );//sprite index
					beam.WriteByte( 0 );//starting frame
					beam.WriteByte( 10 );//framerate in 0.1's
					beam.WriteByte( 1 );//life in 0.1's
					beam.WriteByte( 11 );//width in 0.1's
					beam.WriteByte( 3 );//noise amplitude in 0.1's
					beam.WriteByte( 0 );//red
					beam.WriteByte( 255 );//green
					beam.WriteByte( 255 );//blue
					beam.WriteByte( 230 + Math.RandomLong(20, 30) );//brightness
					beam.WriteByte( 10 );//scroll speed
				beam.End(); 
			}*/

			Vector origin = m_pPlayer.pev.origin;
			NetworkMessage muzflash( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
				muzflash.WriteByte( TE_DLIGHT );
				muzflash.WriteCoord( origin.x );
				muzflash.WriteCoord( origin.y );
				muzflash.WriteCoord( origin.z );
				muzflash.WriteByte( int(1.5f + Math.RandomFloat(-0.2f, 0.2f)) );
				muzflash.WriteByte( 0 );
				muzflash.WriteByte( 255 );
				muzflash.WriteByte( 255 );
				muzflash.WriteByte( int(g_Engine.time + 0.01f) );
				muzflash.WriteByte( 10 );
			muzflash.End();
		}
	}
}

string GetOPSHOCKName()
{
	return "weapon_ofshockrifle";
}

void RegisterOPSHOCK()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_ofshockrifle", GetOPSHOCKName() );
	g_ItemRegistry.RegisterWeapon( GetOPSHOCKName(), "portal_house", "opfor_shocks" );

}
