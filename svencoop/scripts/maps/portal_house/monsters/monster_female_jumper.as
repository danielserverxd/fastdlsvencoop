#include "../ph_shot"

namespace AssassinCustom
{

const int ASSASSIN_AE_SHOOT1 = 1;
const int ASSASSIN_AE_TOSS1 = 2;
const int ASSASSIN_AE_JUMP = 3;

const int bits_MEMORY_BADJUMP = bits_MEMORY_CUSTOM1;

const int ASSASSIN_HEALTH = 50;
const string ASSASSIN_MODEL = "models/portal_house/hassassin.mdl";
//const string ASSASSIN_MODEL = "models/portal_house/hassassin.mdl";

class monster_female_jumper : ScriptBaseMonsterEntity
{
	private float	m_flLastShot;
	private float	m_flDiviation;
	private float	m_flNextJump;
	private Vector	m_vecJumpVelocity;
	private float	m_flNextGrenadeCheck;
	private Vector	m_vecTossVelocity;
	private bool	m_fThrowGrenade;
	private int		m_iTargetRanderamt;
	private int		m_iFrustration;
	private int		m_iShell;

	monster_female_jumper()
	{
		@this.m_Schedules = @custom_hassassin_schedules;
	}

	void Spawn()
	{
		Precache();

		g_EntityFuncs.SetModel( self, ASSASSIN_MODEL );
		g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );

		self.pev.solid			= SOLID_SLIDEBOX;
		self.pev.movetype		= MOVETYPE_STEP;
		self.m_bloodColor		= BLOOD_COLOR_RED;
		self.pev.effects		= 0;
		self.pev.health			= 150;
		self.m_flFieldOfView	= VIEW_FIELD_WIDE; // indicates the width of this monster's forward view cone ( as a dotproduct result )
		self.m_MonsterState		= MONSTERSTATE_NONE;
		self.m_afCapability		= bits_CAP_MELEE_ATTACK1 | bits_CAP_DOORS_GROUP;
		self.pev.friction		= 1;

		self.m_HackedGunPos		= Vector(0, 24, 48);

		m_iTargetRanderamt		= 20;
		self.pev.renderamt		= 20;
		self.pev.rendermode		= kRenderTransTexture;

		if( string(self.m_FormattedName).IsEmpty() )
				self.m_FormattedName = "Female Assassin";

		self.MonsterInit();
	}

	void Precache()
	{
		g_Game.PrecacheModel( ASSASSIN_MODEL );

		g_SoundSystem.PrecacheSound( "weapons/pl_gun1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/pl_gun2.wav" );

		g_SoundSystem.PrecacheSound( "debris/beamstart1.wav" );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );// brass shell
	}

	void SetYawSpeed()
	{
		int ys;

		switch( self.m_Activity )
		{
			case ACT_TURN_LEFT:
			case ACT_TURN_RIGHT: ys = 360; break;
			default: ys = 360; break;
		}

		self.pev.yaw_speed = ys;
	}

	int	Classify()
	{
		return CLASS_HUMAN_MILITARY;
	}

	int ISoundMask()
	{
		return	bits_SOUND_WORLD	|
				bits_SOUND_COMBAT	|
				bits_SOUND_DANGER	|
				bits_SOUND_PLAYER;
	}

	void Shoot()
	{
		if( self.m_hEnemy.GetEntity() is null )
			return;

		Vector vecShootOrigin = self.GetGunPosition();
		Vector vecShootDir = self.ShootAtEnemy( vecShootOrigin );

		if( m_flLastShot + 2 < g_Engine.time )
			m_flDiviation = 0.10f;
		else
		{
			m_flDiviation -= 0.01f;

			if( m_flDiviation < 0.02f )
				m_flDiviation = 0.02f;
		}

		m_flLastShot = g_Engine.time;

		Math.MakeVectors( self.pev.angles );

		Vector vecShellVelocity = g_Engine.v_right * Math.RandomFloat(40,90) + g_Engine.v_up * Math.RandomFloat(75,200) + g_Engine.v_forward * Math.RandomFloat(-40, 40);
		g_EntityFuncs.EjectBrass( self.pev.origin + g_Engine.v_up * 32 + g_Engine.v_forward * 12, vecShellVelocity, self.pev.angles.y, m_iShell, TE_BOUNCE_SHELL );
		//self.FireBullets( 1, vecShootOrigin, vecShootDir, Vector(m_flDiviation, m_flDiviation, m_flDiviation), 2048, BULLET_MONSTER_9MM ); // shoot +-8 degrees
  g_EntityFuncs.CreateDisplacerPortal( vecShootOrigin, vecShootDir + g_Engine.v_forward * 750.0f, self.edict(), 256.0f, 256.0f );
		
        switch( Math.RandomLong(0,1) )
		{
			case 0: g_SoundSystem.EmitSound( self.edict(), CHAN_WEAPON, "weapons/displacer_fire.wav", Math.RandomFloat(0.6f, 0.8f), ATTN_NORM ); break;
			case 1: g_SoundSystem.EmitSound( self.edict(), CHAN_WEAPON, "weapons/displacer_teleport_player.wav", Math.RandomFloat(0.6f, 0.8f), ATTN_NORM ); break;
		}

		self.pev.effects |= EF_MUZZLEFLASH;

		Vector angDir = Math.VecToAngles( vecShootDir );
		self.SetBlending( 0, angDir.x );

		self.m_cAmmoLoaded--;
	}

	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		switch( pEvent.event )
		{
			case ASSASSIN_AE_SHOOT1: Shoot(); break;

			case ASSASSIN_AE_TOSS1:
			{
				Math.MakeVectors( self.pev.angles );
				g_EntityFuncs.ShootTimed( self.pev, self.pev.origin + g_Engine.v_forward * 34 + Vector(0, 0, 32), m_vecTossVelocity, 2.0f );

				m_flNextGrenadeCheck = g_Engine.time + 6;// wait six seconds before even looking again to see if a grenade can be thrown.
				m_fThrowGrenade = false;
				// !!!LATER - when in a group, only try to throw grenade if ordered.
				break;
			}

			case ASSASSIN_AE_JUMP:
			{
				// g_Game.AlertMessage( at_console, "jumping" );
				Math.MakeAimVectors( self.pev.angles );
				self.pev.movetype = MOVETYPE_TOSS;
				self.pev.flags &= ~FL_ONGROUND;
				self.pev.velocity = m_vecJumpVelocity;
				m_flNextJump = g_Engine.time + 3.0f;

				return;
			}

			default: BaseClass.HandleAnimEvent( pEvent ); break;
		}
	}

	Schedule@ GetSchedule()
	{
		switch( self.m_MonsterState )
		{
			case MONSTERSTATE_IDLE:
			case MONSTERSTATE_ALERT:
			{
				if( self.HasConditions(bits_COND_HEAR_SOUND) )
				{
					CSound@ pSound;
					@pSound = self.PBestSound();

					//ASSERT( pSound != NULL );
					if( pSound !is null && (pSound.m_iType & bits_SOUND_DANGER) == 1 )
						return GetScheduleOfType( SCHED_TAKE_COVER_FROM_BEST_SOUND );

					if( pSound !is null && (pSound.m_iType & bits_SOUND_COMBAT) == 1 )
						return GetScheduleOfType( SCHED_INVESTIGATE_SOUND );
				}

				break;
			}

			case MONSTERSTATE_COMBAT:
			{
				// dead enemy
				if( self.HasConditions(bits_COND_ENEMY_DEAD) )
				{
					// call base class, all code to handle dead enemies is centralized there.
					return BaseClass.GetSchedule();
				}

				// flying?
				if( self.pev.movetype == MOVETYPE_TOSS )
				{
					if( self.pev.flags & FL_ONGROUND != 0 )
					{
						// g_Game.AlertMessage( at_console, "landed\n" );
						// just landed
						self.pev.movetype = MOVETYPE_STEP;
						return GetScheduleOfType( SCHED_ASSASSIN_JUMP_LAND );
					}
					else
					{
						// g_Game.AlertMessage( at_console, "jump\n" );
						// jump or jump/shoot
						if( self.m_MonsterState == MONSTERSTATE_COMBAT )
							return GetScheduleOfType( SCHED_ASSASSIN_JUMP );
						else
							return GetScheduleOfType( SCHED_ASSASSIN_JUMP_ATTACK );
					}
				}

				if( self.HasConditions(bits_COND_HEAR_SOUND) )
				{
					CSound@ pSound;
					@pSound = self.PBestSound();

					//ASSERT( pSound != NULL );
					if( pSound !is null && (pSound.m_iType & bits_SOUND_DANGER) == 1 )
						return GetScheduleOfType( SCHED_TAKE_COVER_FROM_BEST_SOUND );
				}

				if( self.HasConditions(bits_COND_LIGHT_DAMAGE) )
					m_iFrustration++;

				if( self.HasConditions(bits_COND_HEAVY_DAMAGE) )
					m_iFrustration++;

				// jump player!
				if( self.HasConditions(bits_COND_CAN_MELEE_ATTACK1) )
				{
					// g_Game.AlertMessage( at_console, "melee attack 1\n" );
					return GetScheduleOfType( SCHED_MELEE_ATTACK1 );
				}

				// throw grenade
				if( self.HasConditions(bits_COND_CAN_RANGE_ATTACK2) )
				{
					// g_Game.AlertMessage( at_console, "range attack 2\n" );
					return GetScheduleOfType( SCHED_RANGE_ATTACK2 );
				}

				// spotted
				if( self.HasConditions(bits_COND_SEE_ENEMY) && self.HasConditions(bits_COND_ENEMY_FACING_ME) )
				{
					// g_Game.AlertMessage( at_console, "exposed\n" );
					m_iFrustration++;
					return GetScheduleOfType( SCHED_ASSASSIN_EXPOSED );
				}

				// can attack
				if( self.HasConditions(bits_COND_CAN_RANGE_ATTACK1) )
				{
					// g_Game.AlertMessage( at_console, "range attack 1\n" );
					m_iFrustration = 0;
					return GetScheduleOfType( SCHED_RANGE_ATTACK1 );
				}

				if( self.HasConditions(bits_COND_SEE_ENEMY) )
				{
					// g_Game.AlertMessage( at_console, "face\n" );
					return GetScheduleOfType( SCHED_COMBAT_FACE );
				}

				// new enemy
				if( self.HasConditions(bits_COND_NEW_ENEMY) )
				{
					// g_Game.AlertMessage( at_console, "take cover\n" );
					return GetScheduleOfType( SCHED_TAKE_COVER_FROM_ENEMY );
				}

				// g_Game.AlertMessage( at_console, "stand\n" );
				return GetScheduleOfType( SCHED_ALERT_STAND );
			}
		}

		return BaseClass.GetSchedule();
	}

	Schedule@ GetScheduleOfType( int Type )
	{
		// g_Game.AlertMessage( at_console, "%d\n", m_iFrustration );
		switch( Type )
		{
			case SCHED_TAKE_COVER_FROM_ENEMY:
			{
				if( self.pev.health > 30 )
					return slAssassinTakeCoverFromEnemy;
				else
					return slAssassinTakeCoverFromEnemy2;
			}

			case SCHED_TAKE_COVER_FROM_BEST_SOUND: return slAssassinTakeCoverFromBestSound;

			case SCHED_ASSASSIN_EXPOSED: return slAssassinExposed;

			case SCHED_FAIL: if( self.m_MonsterState == MONSTERSTATE_COMBAT ) return slAssassinFail;

			case SCHED_ALERT_STAND: if( self.m_MonsterState == MONSTERSTATE_COMBAT ) return slAssassinHide;

			case SCHED_CHASE_ENEMY: return slAssassinHunt;

			case SCHED_MELEE_ATTACK1:
			{
				if( self.pev.flags & FL_ONGROUND != 0 )
				{
					if( m_flNextJump > g_Engine.time )
					{
						// can't jump yet, go ahead and fail
						return slAssassinFail;
					}
					else
						return slAssassinJump;
				}
				else
					return slAssassinJumpAttack;
			}

			case SCHED_ASSASSIN_JUMP:
			case SCHED_ASSASSIN_JUMP_ATTACK: return slAssassinJumpAttack;

			case SCHED_ASSASSIN_JUMP_LAND: return slAssassinJumpLand;
		}

		return BaseClass.GetScheduleOfType( Type );
	}

	//=========================================================
	// CheckMeleeAttack1 - jump like crazy if the enemy gets too close. 
	//=========================================================
	bool CheckMeleeAttack1( float flDot, float flDist )
	{
		if( m_flNextJump < g_Engine.time && (flDist <= 128 || self.HasMemory(bits_MEMORY_BADJUMP)) && self.m_hEnemy.GetEntity() !is null )
		{
			TraceResult	tr;

			Vector vecDest = self.pev.origin + Vector( Math.RandomFloat(-64, 64), Math.RandomFloat(-64, 64), 160 );

			g_Utility.TraceHull( self.pev.origin + Vector(0, 0, 36), vecDest + Vector(0, 0, 36), dont_ignore_monsters, human_hull, self.edict(), tr);

			if( tr.fStartSolid != 0 || tr.flFraction < 1.0f )
				return false;

			float flGravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" );

			float time = sqrt( 160 / (0.5f * flGravity) );
			float speed = flGravity * time / 160;
			m_vecJumpVelocity = (vecDest - self.pev.origin) * speed;

			return true;
		}

		return false;
	}

	//=========================================================
	// CheckRangeAttack1  - drop a cap in their ass
	//
	//=========================================================
	bool CheckRangeAttack1( float flDot, float flDist )
	{
		if( !self.HasConditions(bits_COND_ENEMY_OCCLUDED) && flDist > 64 && flDist <= 2048 /* && flDot >= 0.5f */ /* && NoFriendlyFire() */ )
		{
			TraceResult	tr;

			Vector vecSrc = self.GetGunPosition();

			// verify that a bullet fired from the gun will hit the enemy before the world.
			g_Utility.TraceLine( vecSrc, self.m_hEnemy.GetEntity().BodyTarget(vecSrc), dont_ignore_monsters, self.edict(), tr);

			if( tr.flFraction == 1 || tr.pHit is self.m_hEnemy.GetEntity().edict() )
				return true;
		}

		return false;
	}

	//=========================================================
	// CheckRangeAttack2 - toss grenade is enemy gets in the way and is too close. 
	//=========================================================
	bool CheckRangeAttack2( float flDot, float flDist )
	{
		m_fThrowGrenade = false;

		//if( self.m_hEnemy.GetEntity().pev.flags & FL_ONGROUND == 0 )
		if( !self.m_hEnemy.GetEntity().pev.FlagBitSet(FL_ONGROUND) )
		{
			// don't throw grenades at anything that isn't on the ground!
			return false;
		}

		// don't get grenade happy unless the player starts to piss you off
		if( m_iFrustration <= 2 )
			return false;

		if( m_flNextGrenadeCheck < g_Engine.time && !self.HasConditions(bits_COND_ENEMY_OCCLUDED) && flDist <= 512 /* && flDot >= 0.5f */ /* && NoFriendlyFire() */ )
		{
			Vector vecToss = VecCheckThrow( self.pev, self.GetGunPosition(), self.m_hEnemy.GetEntity().Center(), flDist, 0.5f ); // use dist as speed to get there in 1 second

			if( vecToss != g_vecZero )
			{
				m_vecTossVelocity = vecToss;

				// throw a hand grenade
				m_fThrowGrenade = true;

				return true;
			}
		}

		return false;
	}

	void StartTask( Task@ pTask )
	{
		switch( pTask.iTask )
		{
			case TASK_RANGE_ATTACK2:
			{
				if( !m_fThrowGrenade )
					self.TaskComplete();
				else
					BaseClass.StartTask( pTask );

				break;
			}

			case TASK_ASSASSIN_FALL_TO_GROUND: break;

			default: BaseClass.StartTask( pTask ); break;
		}
	}

	void RunAI()
	{
		BaseClass.RunAI();

		// always visible if moving
		// always visible is not on hard
		if( /*g_iSkillLevel != SKILL_HARD ||*/ self.m_hEnemy.GetEntity() is null || self.pev.deadflag != DEAD_NO || self.m_Activity == ACT_RUN || self.m_Activity == ACT_WALK || !(self.pev.flags & FL_ONGROUND != 0) )
			m_iTargetRanderamt = 255;
		else
			m_iTargetRanderamt = 20;

		if( self.pev.renderamt > m_iTargetRanderamt )
		{
			if( self.pev.renderamt == 255 )
				g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "debris/beamstart1.wav", 0.2f, ATTN_NORM );

			self.pev.renderamt = Math.max( self.pev.renderamt - 50, m_iTargetRanderamt );
			self.pev.rendermode = kRenderTransTexture;
		}
		else if( self.pev.renderamt < m_iTargetRanderamt )
		{
			self.pev.renderamt = Math.min( self.pev.renderamt + 50, m_iTargetRanderamt );

			if( self.pev.renderamt == 255 )
				self.pev.rendermode = kRenderNormal;
		}

		if( self.m_Activity == ACT_RUN || self.m_Activity == ACT_WALK )
		{
			int iStep = 0;
			//iStep = ! iStep;
			//if( iStep > 0 )
			if( (iStep++ % 2) == 1 )
			{
				switch( Math.RandomLong(0, 3) )
				{
					case 0:	g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "player/pl_step1.wav", 0.5f, ATTN_NORM );	break;
					case 1:	g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "player/pl_step3.wav", 0.5f, ATTN_NORM );	break;
					case 2:	g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "player/pl_step2.wav", 0.5f, ATTN_NORM );	break;
					case 3:	g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "player/pl_step4.wav", 0.5f, ATTN_NORM );	break;
				}
			}
		}
	}

	void RunTask( Task@ pTask )
	{
		switch( pTask.iTask )
		{
			case TASK_ASSASSIN_FALL_TO_GROUND:
			{
				self.MakeIdealYaw( self.m_vecEnemyLKP );
				self.ChangeYaw( int(self.pev.yaw_speed) );

				if( self.m_fSequenceFinished )
				{
					if( self.pev.velocity.z > 0 )
						self.pev.sequence = self.LookupSequence( "fly_up" );
					else if( self.HasConditions(bits_COND_SEE_ENEMY) )
					{
						self.pev.sequence = self.LookupSequence( "fly_attack" );
						self.pev.frame = 0;
					}
					else
					{
						self.pev.sequence = self.LookupSequence( "fly_down" );
						self.pev.frame = 0;
					}

					self.ResetSequenceInfo();
					SetYawSpeed();
				}

				if( self.pev.flags & FL_ONGROUND != 0 )
				{
					// g_Game.AlertMessage( at_console, "on ground\n" );
					self.TaskComplete();
				}

				break;
			}

			default: BaseClass.RunTask( pTask ); break;
		}
	}

	void DeathSound()
	{
	}

	void IdleSound()
	{
	}

	//
	// VecCheckThrow - returns the velocity vector at which an object should be thrown from vecspot1 to hit vecspot2.
	// returns g_vecZero if throw is not feasible.
	// 
	Vector VecCheckThrow( entvars_t@ pev, const Vector& in vecSpot1, Vector vecSpot2, float flSpeed, float flGravityAdj )
	{
		float flGravity = g_EngineFuncs.CVarGetFloat("sv_gravity") * flGravityAdj;

		Vector vecGrenadeVel = (vecSpot2 - vecSpot1);

		// throw at a constant time
		float time = vecGrenadeVel.Length() / flSpeed;
		vecGrenadeVel = vecGrenadeVel * (1.0f / time);

		// adjust upward toss to compensate for gravity loss
		vecGrenadeVel.z += flGravity * time * 0.5f;

		Vector vecApex = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5f;
		vecApex.z += 0.5f * flGravity * (time * 0.5f) * (time * 0.5f);

		TraceResult tr;
		g_Utility.TraceLine( vecSpot1, vecApex, dont_ignore_monsters, pev.get_pContainingEntity(), tr );
		if( tr.flFraction != 1.0f )
		{
			// fail!
			return g_vecZero;
		}

		g_Utility.TraceLine( vecSpot2, vecApex, ignore_monsters, pev.get_pContainingEntity(), tr );
		if( tr.flFraction != 1.0f )
		{
			// fail!
			return g_vecZero;
		}

		return vecGrenadeVel;
	}
}

array<ScriptSchedule@>@ custom_hassassin_schedules;

ScriptSchedule slAssassinFail
(
	bits_COND_LIGHT_DAMAGE		|
	bits_COND_HEAVY_DAMAGE		|
	bits_COND_PROVOKED			|
	bits_COND_CAN_RANGE_ATTACK1 |
	bits_COND_CAN_RANGE_ATTACK2 |
	bits_COND_CAN_MELEE_ATTACK1 |
	bits_COND_HEAR_SOUND,

	bits_SOUND_DANGER |
	bits_SOUND_PLAYER,
	"AssassinFail"
);

ScriptSchedule slAssassinExposed
(
	bits_COND_CAN_MELEE_ATTACK1,
	0,
	"AssassinExposed"
);

ScriptSchedule slAssassinTakeCoverFromEnemy
(
	bits_COND_NEW_ENEMY |
	bits_COND_CAN_MELEE_ATTACK1		|
	bits_COND_HEAR_SOUND,
	
	bits_SOUND_DANGER,
	"AssassinTakeCoverFromEnemy"
);

ScriptSchedule slAssassinTakeCoverFromEnemy2
(
	bits_COND_NEW_ENEMY |
	bits_COND_CAN_MELEE_ATTACK2		|
	bits_COND_HEAR_SOUND,
	
	bits_SOUND_DANGER,
	"AssassinTakeCoverFromEnemy2"
);

ScriptSchedule slAssassinTakeCoverFromBestSound
(
	bits_COND_NEW_ENEMY,
	0,
	"AssassinTakeCoverFromBestSound"
);

ScriptSchedule slAssassinHide
(
	bits_COND_NEW_ENEMY				|
	bits_COND_SEE_ENEMY				|
	bits_COND_SEE_FEAR				|
	bits_COND_LIGHT_DAMAGE			|
	bits_COND_HEAVY_DAMAGE			|
	bits_COND_PROVOKED		|
	bits_COND_HEAR_SOUND,
	
	bits_SOUND_DANGER,
	"AssassinHide"
);

ScriptSchedule slAssassinHunt
(
	bits_COND_NEW_ENEMY			|
	// bits_COND_SEE_ENEMY			|
	bits_COND_CAN_RANGE_ATTACK1	|
	bits_COND_HEAR_SOUND,
	
	bits_SOUND_DANGER,
	"AssassinHunt"
);

ScriptSchedule slAssassinJump
(
	0, 
	0, 
	"AssassinJump"
);

ScriptSchedule slAssassinJumpAttack
(
	0, 
	0,
	"AssassinJumpAttack"
);

ScriptSchedule slAssassinJumpLand
(
	0, 
	0,
	"AssassinJumpLand"
);

void InitSchedules()
{
	slAssassinFail.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinFail.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
	slAssassinFail.AddTask( ScriptTask(TASK_WAIT_FACE_ENEMY, 2.0f) );
	//slAssassinFail.AddTask( ScriptTask(TASK_WAIT_PVS) );
	slAssassinFail.AddTask( ScriptTask(TASK_SET_SCHEDULE, float(SCHED_CHASE_ENEMY)) );

	slAssassinExposed.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinExposed.AddTask( ScriptTask(TASK_RANGE_ATTACK1) );
	slAssassinExposed.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_ASSASSIN_JUMP)) );
	slAssassinExposed.AddTask( ScriptTask(TASK_SET_SCHEDULE, float(SCHED_TAKE_COVER_FROM_ENEMY)) );

	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_WAIT, 0.2f) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_RANGE_ATTACK1)) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_FIND_COVER_FROM_ENEMY) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_RUN_PATH) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_WAIT_FOR_MOVEMENT) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_REMEMBER, float(bits_MEMORY_INCOVER)) );
	slAssassinTakeCoverFromEnemy.AddTask( ScriptTask(TASK_FACE_ENEMY) );

	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_WAIT, 0.2f) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_FACE_ENEMY) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_RANGE_ATTACK1) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_RANGE_ATTACK2)) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_FIND_FAR_NODE_COVER_FROM_ENEMY, 384.0f) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_RUN_PATH) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_WAIT_FOR_MOVEMENT) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_REMEMBER, float(bits_MEMORY_INCOVER)) );
	slAssassinTakeCoverFromEnemy2.AddTask( ScriptTask(TASK_FACE_ENEMY) );

	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_MELEE_ATTACK1)) );
	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_FIND_COVER_FROM_BEST_SOUND) );
	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_RUN_PATH) );
	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_WAIT_FOR_MOVEMENT) );
	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_REMEMBER, float(bits_MEMORY_INCOVER)) );
	slAssassinTakeCoverFromBestSound.AddTask( ScriptTask(TASK_TURN_LEFT, 179.0f) );

	slAssassinHide.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinHide.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
	slAssassinHide.AddTask( ScriptTask(TASK_WAIT, 2.0f) );
	slAssassinHide.AddTask( ScriptTask(TASK_SET_SCHEDULE, float(SCHED_CHASE_ENEMY)) );

	slAssassinHunt.AddTask( ScriptTask(TASK_GET_PATH_TO_ENEMY) );
	slAssassinHunt.AddTask( ScriptTask(TASK_RUN_PATH) );
	slAssassinHunt.AddTask( ScriptTask(TASK_WAIT_FOR_MOVEMENT) );

	slAssassinJump.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slAssassinJump.AddTask( ScriptTask(TASK_PLAY_SEQUENCE, float(ACT_HOP)) );
	slAssassinJump.AddTask( ScriptTask(TASK_SET_SCHEDULE, float(SCHED_ASSASSIN_JUMP_ATTACK)) );

	slAssassinJumpAttack.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_ASSASSIN_JUMP_LAND)) );
	//slAssassinJumpAttack.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_FLY)) );
	slAssassinJumpAttack.AddTask( ScriptTask(TASK_ASSASSIN_FALL_TO_GROUND) );

	slAssassinJumpLand.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_ASSASSIN_EXPOSED)) );
	//slAssassinJumpLand.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_MELEE_ATTACK1)) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_REMEMBER, float(bits_MEMORY_BADJUMP)) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_FIND_NODE_COVER_FROM_ENEMY) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_RUN_PATH) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_FORGET, float(bits_MEMORY_BADJUMP)) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_WAIT_FOR_MOVEMENT) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_REMEMBER, float(bits_MEMORY_INCOVER)) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_FACE_ENEMY) );
	slAssassinJumpLand.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_RANGE_ATTACK1)) );

	array<ScriptSchedule@> scheds =
	{
		slAssassinFail,
		slAssassinExposed,
		slAssassinTakeCoverFromEnemy,
		slAssassinTakeCoverFromEnemy2,
		slAssassinTakeCoverFromBestSound,
		slAssassinHide,
		slAssassinHunt,
		slAssassinJump,
		slAssassinJumpAttack,
		slAssassinJumpLand
	};
	
	@custom_hassassin_schedules = @scheds;
}

enum eHassassinSchedules
{
	SCHED_ASSASSIN_EXPOSED = LAST_COMMON_SCHEDULE + 1,// cover was blown.
	SCHED_ASSASSIN_JUMP,	// fly through the air
	SCHED_ASSASSIN_JUMP_ATTACK,	// fly through the air and shoot
	SCHED_ASSASSIN_JUMP_LAND // hit and run away
};

enum eHassinTasks
{
	TASK_ASSASSIN_FALL_TO_GROUND = LAST_COMMON_TASK + 1 // falling and waiting to hit ground
};

void Register()
{
	InitSchedules();
	g_CustomEntityFuncs.RegisterCustomEntity( "AssassinCustom::monster_female_jumper", "monster_female_jumper" );
	g_CustomEntityFuncs.RegisterCustomEntity( "AssassinCustom::monster_female_jumper", "npc_hassassin" );
}

} // end of namespace AssassinCustom
