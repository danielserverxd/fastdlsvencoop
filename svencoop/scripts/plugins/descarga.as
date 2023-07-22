//public plugin_precache()
//{
//        precache_model("models/player/LT_PedroCastillo/LT_PedroCastillo.mdl")
//        precache_model("models/player/Penguin_v4/Penguin_v4.mdl")
//        precache_generic("models/player/Penguin_v4/Penguin_v4.bmp")
//        precache_model("models/player/bills_tc/bills_tc.mdl")
//        precache_generic("models/player/bills_tc/bills_tc.bmp")
//}


void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Nero");
    g_Module.ScriptInfo.SetContactInfo("Nero @ Svencoop forums");
}
 
void MapInit()
{
        // bitmap/models array
        g_Game.PrecacheModel( "models/player/LT_amongus/LT_amongus.mdl" );
        g_Game.PrecacheGeneric( "models/player/LT_amongus/LT_amongus.bmp" );
        g_Game.PrecacheModel( "models/player/bills_tc/bills_tc.mdl" );
        g_Game.PrecacheGeneric( "models/player/bills_tc/bills_tc.bmp" );
        g_Game.PrecacheModel( "models/player/LT_Cobra/LT_Cobra.mdl" );
        g_Game.PrecacheModel( "models/player/LT_dekatin/LT_dekatin.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Dragon/LT_Dragon.mdl" );
        g_Game.PrecacheModel( "models/player/LT_estudiaSonso/LT_estudiaSonso.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Forsyth/LT_Forsyth.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Ghost/LT_Ghost.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Gonzalete/LT_Gonzalete.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Lapadula/LT_Lapadula.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Machin/LT_Machin.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Mandril/LT_Mandril.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Monchi/LT_Monchi.mdl" );
        g_Game.PrecacheModel( "models/player/LT_orejaFlores/LT_orejaFlores.mdl" );
        g_Game.PrecacheModel( "models/player/LT_PaltaEmocionada/LT_PaltaEmocionada.mdl" );
        g_Game.PrecacheModel( "models/player/LT_PedroCastillo/LT_PedroCastillo.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Porky/LT_Porky.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Queca/LT_Queca.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Tony/LT_Tony.mdl" );
        g_Game.PrecacheModel( "models/player/LT_TonyBlades/LT_TonyBlades.mdl" );
        g_Game.PrecacheModel( "models/player/LT_uganda/LT_uganda.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Urresti/LT_Urresti.mdl" );
        g_Game.PrecacheModel( "models/player/LT_Wendy/LT_Wendy.mdl" );
       // g_Game.PrecacheGeneric( "models/player/LT_amongus/LT_amongus.mdl" );
       // g_Game.PrecacheGeneric( "models/player/" + g_PlayerModelList[i] + "/" + g_PlayerModelList[i] + ".mdl" );
}
