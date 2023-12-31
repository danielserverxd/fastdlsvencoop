/*
	Infectable Monsters
*/
#include "monster_infected"
#include "../unstuck"

void Infectable_Process() {
	//Find all monsters
	array<CBaseEntity@>Monsters(500);
	g_EntityFuncs.MonstersInSphere(Monsters, Vector(0,0,0), 99999.0);
	
	for(uint i=0;i<Monsters.length();i++) {
		CBaseEntity@ ent = Monsters[i];
		CBaseMonster@ monster;
		//Check if the entity is not NULL
		if(ent !is null) {
			if(ent.IsMonster())
				@monster = ent.MyMonsterPointer();
			//Check if this monster is Infectable
			for(uint i1=0;i1<Infectable.length();i1++) {
				if(ent.pev.classname == Infectable[i1] && ent.IsAlive()) {
					//Make sure this scientist is not infected
					CustomKeyvalues@ KeyValues = ent.GetCustomKeyvalues();
					int infect_value = atoui(KeyValues.GetKeyvalue("$i_infected").GetString());
					if(infect_value != 1) {
						Infect_Process(monster);
					} else {
						Infected_Process_NoOwner(monster);
					}
				}
			}
		}
	}
	
	//Performance Fix
	g_Scheduler.SetTimeout( "Infectable_Process", 0.1);
}

void Infect_Process(CBaseMonster@ monster) {
	if(monster is null) {
		return;
	}
	
	array<CBaseEntity@>Enemies(25);
	//g_EntityFuncs.MonstersInSphere(Enemies,monster.m_vecEnemyLKP, 1500.0);
	g_EntityFuncs.MonstersInSphere(Enemies,monster.pev.origin, 500.0);
	
	for(uint i1=0;i1<Enemies.length();i1++) {
		CBaseEntity@ enemy = Enemies[i1];
		if(enemy !is null) {
			CBaseMonster@ hc_monster = enemy.MyMonsterPointer();
			
			CustomKeyvalues@ KeyValues = monster.GetCustomKeyvalues();
			//If Attacker is headcrab
			if(hc_monster.pev.classname == "monster_headcrab") {
				//If Headcrab is in 'COMBAT' mode
				if(hc_monster.m_MonsterState == MONSTERSTATE_COMBAT) {
					//Check the distance between the headcrab and the infectable target
					//And if heardcrab performs one of these animations
					array<int>attack_anims = {
						5, //'angry'
						10, //'jump'
						11, //'jump_variation1'
						12 //'jump_variation2'
					};
					
					float target_dist = (hc_monster.pev.origin - monster.pev.origin).Length();
					float hc_size_max = hc_monster.pev.size.Length()/2.0;
					float hc_size = (hc_monster.pev.size + Vector(hc_size_max,hc_size_max,hc_size_max)).Length();
					
					bool isWall = Unstuck::is_wall_between_points(hc_monster.pev.origin,monster.pev.origin,hc_monster);
					
					if(target_dist <= hc_size && !isWall) {
						for(uint i=0;i<attack_anims.length();i++) {
							if(hc_monster.pev.sequence == attack_anims[i]) {
								monster.KeyValue("$i_infected",true);
								Infected_Process(monster,enemy);
								g_EntityFuncs.Remove(hc_monster);
								break;
							}
						}
					}
				}
			}
		}
	}
}

void Infected_Process(CBaseMonster@ monster, CBaseEntity@ hc) {
	if(monster is null) {
		return;
	}
	monster.KeyValue("$i_infected",false);

	Vector createOrigin = monster.pev.origin;
	
	Vector createAngles = monster.pev.angles;
	g_EntityFuncs.Remove(monster);
	
	CBaseEntity@ entBase = g_EntityFuncs.CreateEntity("monster_infected");
	Infected@ ent = cast<Infected@>(CastToScriptClass(entBase));

	g_EntityFuncs.SetOrigin( ent.self, createOrigin );
	g_EntityFuncs.DispatchSpawn( ent.self.edict() );
	@ent.Infector = hc;
	ent.pev.angles = createAngles;
	
	ent.infected_class = monster.pev.classname;

	if(monster.pev.classname == Infectable[2]) {
		monster.SetBodygroup(2,3);
		monster.SetBodygroup(1,0);//Remove Weapon
	} else if(monster.pev.classname == Infectable[3]) {
		if(monster.GetBodygroup(1) != 0) {
			ent.zombie_isMaskLess = true;
		}

		monster.SetBodygroup(2,2);//Remove Weapon
	}
	ent.infected_first_body = monster.pev.body;
	ent.BigProcess();
}

void Infected_Process_NoOwner(CBaseMonster@ monster) {
	if(monster is null) {
		return;
	}
	monster.KeyValue("$i_infected",false);

	Vector createOrigin = monster.pev.origin;
	
	Vector createAngles = monster.pev.angles;
	g_EntityFuncs.Remove(monster);
	
	CBaseEntity@ entBase = g_EntityFuncs.CreateEntity("monster_infected");
	Infected@ ent = cast<Infected@>(CastToScriptClass(entBase));

	g_EntityFuncs.SetOrigin( ent.self, createOrigin );
	g_EntityFuncs.DispatchSpawn( ent.self.edict() );
	ent.pev.angles = createAngles;
	
	ent.infected_class = monster.pev.classname;

	if(monster.pev.classname == Infectable[2]) {
		monster.SetBodygroup(2,3);
		monster.SetBodygroup(1,0);//Remove Weapon
	} else if(monster.pev.classname == Infectable[3]) {
		if(monster.GetBodygroup(1) != 0) {
			ent.zombie_isMaskLess = true;
		}

		monster.SetBodygroup(2,2);//Remove Weapon
	}
	ent.infected_first_body = monster.pev.body;
	ent.BigProcess();
}

void Infected_Process_Player(CBaseMonster@ monster, CBasePlayer@ m_pPlayer) {
	if(monster is null) {
		return;
	}
	monster.KeyValue("$i_infected",false);

	//Remove Player's Velocity
	m_pPlayer.pev.velocity = Vector(0.0,0.0,0.0);
	
	CBaseEntity@ playerEnt = cast<CBaseEntity@>(m_pPlayer);
	
	Vector createOrigin = monster.pev.origin;
	
	Vector createAngles = monster.pev.angles;
	g_EntityFuncs.Remove(monster);
	
	CBaseEntity@ entBase = g_EntityFuncs.CreateEntity("monster_infected");
	Infected@ ent = cast<Infected@>(CastToScriptClass(entBase));

	g_EntityFuncs.SetOrigin( ent.self, createOrigin );
	g_EntityFuncs.DispatchSpawn( ent.self.edict() );
	
	@ent.Infector = playerEnt;
	
	ent.infected_class = monster.pev.classname;
	
	if(monster.pev.classname == Infectable[2]) {
		monster.SetBodygroup(2,3);
		monster.SetBodygroup(1,0);//Remove Weapon
	} else if(monster.pev.classname == Infectable[3]) {
		if(monster.GetBodygroup(1) != 0) {
			ent.zombie_isMaskLess = true;
		}

		monster.SetBodygroup(2,2);//Remove Weapon
	}
	ent.infected_first_body = monster.pev.body;
	
	ent.isInfectedByPlayer = true;
	@ent.InfectorPlayer = m_pPlayer;
	
	ent.pev.angles = createAngles;

	ent.BigProcess();
	
	//Relocate Player
	TraceResult tr;
	g_Utility.TraceLine(m_pPlayer.GetOrigin(),m_pPlayer.GetOrigin()-Vector(0,0,36),ignore_monsters,m_pPlayer.edict(),tr);
	Vector relocateOrigin = tr.vecEndPos;
	relocateOrigin = relocateOrigin + Vector(0,0,18);
	if((m_pPlayer.pev.flags & FL_DUCKING) == 0) {
		relocateOrigin = relocateOrigin + Vector(0,0,18);
	}

	m_pPlayer.pev.origin = relocateOrigin;
	//Lock the Player
	m_pPlayer.pev.flags |= FL_FROZEN;
	//Make Player Invisible
	m_pPlayer.pev.rendermode = kRenderTransAlpha;
	m_pPlayer.pev.renderamt = 0;
	//Toggle Thirdperson Mode
	NetworkMessage m(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, m_pPlayer.edict());
		m.WriteString("thirdperson;");
	m.End();
}