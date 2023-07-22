//public plugin_precache()
//{
//        precache_model("models/player/LT_PedroCastillo/LT_PedroCastillo.mdl")
//        precache_model("models/player/Penguin_v4/Penguin_v4.mdl")
//        precache_generic("models/player/Penguin_v4/Penguin_v4.bmp")
//        precache_model("models/player/bills_tc/bills_tc.mdl")
//        precache_generic("models/player/bills_tc/bills_tc.bmp")
//}

const array<string> g_PlayerModelList =
{
'Penguin_v4',
'bills_tc'
};
 

const array<string> g_PlayerModelList2 =
{
'LT_PedroCastillo'
};

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Nero");
    g_Module.ScriptInfo.SetContactInfo("Nero @ Svencoop forums");
}
 
void MapInit()
{
    for ( uint i = 0; i < g_PlayerModelList.length(); ++i )
    {
        // bitmap/models array
        g_Game.PrecacheGeneric( "models/player/" + g_PlayerModelList[i] + "/" + g_PlayerModelList[i] + ".bmp" );
        g_Game.PrecacheGeneric( "models/player/" + g_PlayerModelList[i] + "/" + g_PlayerModelList[i] + ".mdl" );
        g_Game.PrecacheModel( "models/player/" + g_PlayerModelList[i] + "/" + g_PlayerModelList[i] + ".mdl" );
    }
    for ( uint i = 0; i < g_PlayerModelList2.length(); ++i )
    {
        // bitmap/models array
        g_Game.PrecacheGeneric( "models/player/" + g_PlayerModelList2[i] + "/" + g_PlayerModelList2[i] + ".mdl" );
        g_Game.PrecacheModel( "models/player/" + g_PlayerModelList2[i] + "/" + g_PlayerModelList2[i] + ".mdl" );
    }
}
