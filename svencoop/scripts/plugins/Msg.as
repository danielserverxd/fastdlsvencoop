CCVar@ g_Msg;
CCVar@ g_Interval;

CScheduledFunction@ g_pThinkFunc = null;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  g_Module.ScriptInfo.SetMinimumAdminLevel(ADMIN_YES);
  
  @g_Msg      = CCVar("msg", "Discord del servidor: https://discord.gg/8SvsfkVbx3", "The text to display", ConCommandFlag::AdminOnly);
  @g_Interval = CCVar("interval", 180.0f, "Repeat every x seconds", ConCommandFlag::AdminOnly);

  MapInit();
}

void MapInit() {
  if (g_pThinkFunc !is null) 
    g_Scheduler.RemoveTimer(g_pThinkFunc);
  
  @g_pThinkFunc = g_Scheduler.SetInterval("msgthink", g_Interval.GetFloat());
}

void msgthink() {
  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Anuncio] " + g_Msg.GetString() + "\n");
}
