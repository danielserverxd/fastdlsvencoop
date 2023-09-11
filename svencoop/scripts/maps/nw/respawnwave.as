// Plugin By Dr.Abc
// Modified by NoobLCH for Nuclear Winter Co-op

namespace WAVERESPAWN{
const string RESPAWN_ITEMNAME = "info_respawnwave";
const string RESPAWN_MANAGERNAME = "info_respawnmanager";
const string RESPAWN_TEXT_TEMPLATE = "WAVE: {WAVE} {ADDED} {SEPRATE} {NEXTTIME}";
const string RESPAWN_TEXT_SEPRATE = "|";

void Alert(string message){
	g_Game.AlertMessage(at_error, "!!!!" + message + "!!!!\n");
}
class info_respawnwave_item : ScriptBaseAnimating {
	private int m_iWave = 1;
	private string m_szSound = "../media/valve.mp3";
	bool KeyValue( const string& in szKey, const string& in szValue ){
		if(szKey == "iWave"){
			m_iWave = atoi(szValue);
			return true;
		}
		else if(szKey == "szSound"){
			m_szSound = szValue;
			return true;
		}
		return BaseClass.KeyValue(szKey, szValue);
	}
	void Precache(){
		BaseClass.Precache();
		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( "models/common/lambda.mdl" );
		else
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound( m_szSound );
		g_Game.PrecacheGeneric( "sound/" + m_szSound );
	}
	void Spawn(){
		Precache();
		BaseClass.Spawn();
		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel(self, "models/common/lambda.mdl");
		else
			g_EntityFuncs.SetModel(self, self.pev.model);
		g_EntityFuncs.SetSize(self.pev, self.pev.mins, self.pev.maxs);
        self.pev.movetype = MOVETYPE_FLY;
        self.pev.solid = SOLID_TRIGGER;
		SetAnim( 0 );
		SetThink( ThinkFunction( SurvivalThink ) );
		self.pev.nextthink = g_Engine.time + 1.5f;
	}
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
		CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, RESPAWN_MANAGERNAME);
		if(@pEntity is null)
			Alert("找不到"  + RESPAWN_MANAGERNAME + "实体");
		else
			pEntity.Use(@pActivator, @pCaller, useType, m_iWave);
	}
	void Touch( CBaseEntity@ pOther ){
		if( !pOther.IsPlayer())
			return;
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, m_szSound, 1.0f, ATTN_NONE );
		Use( @pOther, @pOther, USE_TOGGLE, 0 );
		self.SUB_Remove();
	}
	// If youre gonna use this in your script, make sure you don't try
	// to access invalid animations. -zode
	void SetAnim( int animIndex ){
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}
	void SurvivalThink(){
		if(g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsActive()){
			self.pev.effects &= ~EF_NODRAW;
			self.pev.solid = SOLID_TRIGGER;
		}
		else{
			self.pev.effects |= EF_NODRAW;
			self.pev.solid = SOLID_NOT;
		}
		self.pev.nextthink = g_Engine.time + 0.5f;
	}
}

class info_respawnmanager : ScriptBaseEntity {
	private int m_iIntialWave = 5;
	private float m_flRespawnTime = 30.0f;
	private float m_flThinkTime = 1.0f;

	private int m_iPretendingWave = 0;
	private int m_iAllWave = 0;
	private float m_flNextRespawnTime = 0;
	private HUDTextParams m_hHUD;

	private string m_szSound = "radio/bootcamp0.wav";
	private bool m_bIsDoomed = false; //If all players died?
	private float m_flRespawnDoomed = 5.0f;
	
	void Precache(){
		g_SoundSystem.PrecacheSound( m_szSound );
		g_Game.PrecacheGeneric( "sound/" + m_szSound );
	}
	bool KeyValue( const string& in szKey, const string& in szValue ){
		if(szKey == "iIntialWave"){
			m_iIntialWave = atoi(szValue);
			return true;
		}
		else if(szKey == "flRespawnTime"){
			m_flRespawnTime = atof(szValue);
			return true;
		}
		else if(szKey == "flThinkTime"){
			m_flThinkTime = atof(szValue);
			return true;
		}
		else if(szKey == "szSound"){
			m_szSound = szValue;
			return true;
		}
		else if(szKey == "iHudX"){
			m_hHUD.x = atof(szValue);
			return true;
		}
		else if(szKey == "iHudY"){
			m_hHUD.y = atof(szValue);
			return true;
		}
		else if(szKey == "iHudEffect"){
			m_hHUD.effect = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudR1"){
			m_hHUD.r1 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudG1"){
			m_hHUD.g1 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudB1"){
			m_hHUD.b1 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudA1"){
			m_hHUD.a1 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudR2"){
			m_hHUD.r2 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudG2"){
			m_hHUD.g2 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudB2"){
			m_hHUD.b2 = atoi(szValue);
			return true;
		}
		else if(szKey == "iHudA2"){
			m_hHUD.a2 = atoi(szValue);
			return true;
		}
		else if(szKey == "flHudFadeInTime"){
			m_hHUD.fadeinTime = atof(szValue);
			return true;
		}
		else if(szKey == "flHudFadeOutTime"){
			m_hHUD.fadeoutTime = atof(szValue);
			return true;
		}
		else if(szKey == "flHudHoldTime"){
			m_hHUD.holdTime = atof(szValue);
			return true;
		}
		else if(szKey == "flHudFxTime"){
			m_hHUD.fxTime = atof(szValue);
			return true;
		}
		else if(szKey == "iHudChannel"){
			m_hHUD.channel = atoi(szValue);
			return true;
		}
		return BaseClass.KeyValue(szKey, szValue);
	}
	int CountDeadPlayer(){
		int temp = 0;
		for (int i = 0; i <= g_Engine.maxClients; i++) {
	        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
	        if (pPlayer !is null && pPlayer.IsConnected() && !pPlayer.IsAlive())
	        	temp++;
	    }
	    return temp;
	}
	void Think(){
		if(g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsActive()){
		string szMessage = RESPAWN_TEXT_TEMPLATE;
		szMessage = szMessage.Replace("{ADDED}", m_iPretendingWave > 0 ? "+" + m_iPretendingWave : "");
		szMessage = szMessage.Replace("{WAVE}", string(m_iAllWave));
		if(m_iAllWave > 0){
			int iDeadPlayer = CountDeadPlayer();
			if(iDeadPlayer > 0){
				if(m_flNextRespawnTime <= 0)
					m_flNextRespawnTime = g_Engine.time + m_flRespawnTime;
				if(g_PlayerFuncs.GetNumPlayers() <= iDeadPlayer && !m_bIsDoomed && (m_flNextRespawnTime - g_Engine.time > m_flRespawnDoomed)){
					m_bIsDoomed = true;
					m_flNextRespawnTime = g_Engine.time + m_flRespawnDoomed;
				}
				float flLeftTime = m_flNextRespawnTime - g_Engine.time;
				szMessage = szMessage.Replace("{SEPRATE}", RESPAWN_TEXT_SEPRATE);
				if(flLeftTime <= 0){
					m_flNextRespawnTime = 0;
					g_PlayerFuncs.RespawnAllPlayers(false, true);
					szMessage = szMessage.Replace("{ADDED}", "-" + "1");
					szMessage = szMessage.Replace("{NEXTTIME}", "Respawned!");
					m_iAllWave--;
					g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, m_szSound, 1.0f, ATTN_NONE );
					m_bIsDoomed = false;
				}
				else
					szMessage = szMessage.Replace("{NEXTTIME}", string(int(flLeftTime)));
			}
			else{
				m_flNextRespawnTime = 0;
				szMessage = szMessage.Replace("{SEPRATE}", "");
				szMessage = szMessage.Replace("{NEXTTIME}", "");
			}
		}
		else{ //LCH: fixed 0 wave display bugs.
			szMessage = szMessage.Replace("{SEPRATE}", "");
			szMessage = szMessage.Replace("{NEXTTIME}", "");
		}
		if(m_iPretendingWave > 0){
			m_iAllWave += m_iPretendingWave;
			m_iPretendingWave = 0;
		}
		g_PlayerFuncs.HudMessageAll(m_hHUD, szMessage);
		}
		self.pev.nextthink = g_Engine.time + m_flThinkTime;
	}
	void Spawn(){
		Precache();
		BaseClass.Spawn();
		self.pev.nextthink = g_Engine.time + m_flThinkTime;
		m_iAllWave = m_iIntialWave;
	}
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ){
		m_iPretendingWave += int(value);
	}
}

void Register(){
	g_CustomEntityFuncs.RegisterCustomEntity( "WAVERESPAWN::info_respawnwave_item", RESPAWN_ITEMNAME );
	g_CustomEntityFuncs.RegisterCustomEntity( "WAVERESPAWN::info_respawnmanager", RESPAWN_MANAGERNAME );
	g_Game.PrecacheOther(RESPAWN_ITEMNAME);
}
}