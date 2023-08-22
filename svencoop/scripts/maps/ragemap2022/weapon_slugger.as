//custom weapon script for the double barrel shotgun by BonkTurnip
enum SluggerAnimation {
	SLUGGER_IDLE = 0,
	SLUGGER_DRAW_FIRST,
	SLUGGER_DRAW_FIRST_ALT,
	SLUGGER_DRAW,
	SLUGGER_HOLSTER,
	SLUGGER_FIRE,
	SLUGGER_FIRE_LAST,
	SLUGGER_FIRE_BOTH,
	SLUGGER_DRY_FIRE,
	SLUGGER_RELOAD,
	SLUGGER_RELOAD_EMPTY
};

class weapon_slugger : ScriptBasePlayerWeaponEntity {
	private CBasePlayer@ m_pPlayer = null;
	float m_flNextAnimTime;
	int m_iShell;

	void Spawn() {
		Precache();
		g_EntityFuncs.SetModel(self, "models/ragemap2022/w_slugger.mdl");
		self.m_iDefaultAmmo = 20;
		self.FallInit();
	}

	void Precache() {
		self.PrecacheCustomModels();
		g_Game.PrecacheModel("models/ragemap2022/v_slugger.mdl");
		g_Game.PrecacheModel("models/ragemap2022/w_slugger.mdl");
		g_Game.PrecacheModel("models/ragemap2022/p_slugger.mdl");
		m_iShell = g_Game.PrecacheModel("models/shotgunshell.mdl");
		g_Game.PrecacheModel("models/w_shotbox.mdl");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_close.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_eject.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_empty.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_grab.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_ins1.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_ins2.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_open.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_sboth.ogg");
		g_SoundSystem.PrecacheSound("ragemap2022/slugger_shoot.ogg");
	}

	bool GetItemInfo(ItemInfo& out info) {
		info.iMaxAmmo1 = 125;
		info.iAmmo1Drop = 12;
		info.iMaxAmmo2 = -1;
		info.iMaxClip = 2;
		info.iSlot = 2;
		info.iPosition = 4;
		info.iFlags = 0;
		info.iWeight = 5;

		return true;
	}

	bool AddToPlayer(CBasePlayer@ pPlayer) {
		if(!BaseClass.AddToPlayer(pPlayer))
			return false;
		@m_pPlayer = pPlayer;
		NetworkMessage message(MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict());
			message.WriteLong(self.m_iId);
		message.End();
		return true;
	}

	bool PlayEmptySound() {
		if(self.m_bPlayEmptySound) {
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn(m_pPlayer.edict(), CHAN_WEAPON, "ragemap2022/slugger_empty.ogg", 0.8, ATTN_NORM, 0, PITCH_NORM);
		}
		return false;
	}

	bool Deploy() {
		return self.DefaultDeploy(self.GetV_Model("models/ragemap2022/v_slugger.mdl"), self.GetP_Model("models/ragemap2022/p_slugger.mdl"), SLUGGER_DRAW, "shotgun");
	}

	float WeaponTimeBase() {
		return g_Engine.time;
	}

	void CreatePelletDecals( const Vector& in vecSrc, const Vector& in vecAiming, const Vector& in vecSpread, const uint uiPelletCount ) {
		TraceResult tr;
		float x, y;
		for( uint uiPellet = 0; uiPellet < uiPelletCount; ++uiPellet ) {
			g_Utility.GetCircularGaussianSpread( x, y );
			Vector vecDir = vecAiming
							+ x * vecSpread.x * g_Engine.v_right
							+ y * vecSpread.y * g_Engine.v_up;
			Vector vecEnd	= vecSrc + vecDir * 4096;
			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
			if( tr.flFraction < 1.0 ) {
				if( tr.pHit !is null ) {
					CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );

					if( pHit is null || pHit.IsBSPModel() )
						g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_SNIPER );
				}
			}
		}
	}

	void PrimaryAttack() {
		if(m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) {
			self.PlayEmptySound();
			self.SendWeaponAnim(SLUGGER_DRY_FIRE, 0, 0);
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.53;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.53;
			return;
		}
		if(self.m_iClip <= 0) {
			self.PlayEmptySound();
			self.SendWeaponAnim(SLUGGER_DRY_FIRE, 0, 0);
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.53;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.53;
			return;
		}
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		if(self.m_iClip >= 2) {
			self.SendWeaponAnim(SLUGGER_FIRE, 0, 0);
		} else {
			self.SendWeaponAnim(SLUGGER_FIRE_LAST, 0, 0);
		}
		--self.m_iClip;
		g_SoundSystem.EmitSoundDyn(m_pPlayer.edict(), CHAN_WEAPON, "ragemap2022/slugger_shoot.ogg", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong(0, 10));
		m_pPlayer.SetAnimation(PLAYER_ATTACK1);
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector(AUTOAIM_5DEGREES);
		m_pPlayer.FireBullets(1, vecSrc, vecAiming, Vector(0.01, 0.01, 0.01), 8192, BULLET_PLAYER_SNIPER);
		if(self.m_iClip == 0 && m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0)
			m_pPlayer.SetSuitUpdate("!HEV_AMO0", false, 0);
		m_pPlayer.pev.punchangle.x = -7.0;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
		CreatePelletDecals(vecSrc, vecAiming, Vector(0.01, 0.01, 0.01), 1);
	}

	void SecondaryAttack() {
		if(m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD) {
			self.PlayEmptySound();
			self.SendWeaponAnim(SLUGGER_DRY_FIRE, 0, 0);
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.53;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.53;
			return;
		}
		if(self.m_iClip < 2) {
			self.PlayEmptySound();
			self.SendWeaponAnim(SLUGGER_DRY_FIRE, 0, 0);
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.53;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.53;
			return;
		}
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		self.SendWeaponAnim(SLUGGER_FIRE_BOTH, 0, 0);
		g_SoundSystem.EmitSoundDyn(m_pPlayer.edict(), CHAN_WEAPON, "ragemap2022/slugger_sboth.ogg", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong(0, 10));
		self.m_iClip = 0;
		m_pPlayer.SetAnimation(PLAYER_ATTACK1);
		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector(AUTOAIM_5DEGREES);
		m_pPlayer.FireBullets(2, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_SNIPER);
		if(self.m_iClip == 0 && m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0) {
			m_pPlayer.SetSuitUpdate("!HEV_AMO0", false, 0);
		}
		m_pPlayer.pev.punchangle.x = -10.0;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
		CreatePelletDecals(vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 2);
	}

	void Reload() {
		if(self.m_iClip == 1) {
			self.DefaultReload(2, SLUGGER_RELOAD, 3.54);
		} else {
			self.DefaultReload(2, SLUGGER_RELOAD_EMPTY, 4.81);
		}
		BaseClass.Reload();
	}

	void WeaponIdle() {
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector(AUTOAIM_5DEGREES);
		if(self.m_flTimeWeaponIdle > WeaponTimeBase())
			return;
		self.SendWeaponAnim(SLUGGER_IDLE);
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
	}
}

void RegisterSlugger() {
		g_CustomEntityFuncs.RegisterCustomEntity("weapon_slugger", "weapon_slugger");
		g_ItemRegistry.RegisterWeapon("weapon_slugger", "ragemap2022", "buckshot");
}