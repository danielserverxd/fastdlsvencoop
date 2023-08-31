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
        g_Game.PrecacheGeneric( "models/player/31Minutos_Juan/31Minutos_Juan.bmp" );
        g_Game.PrecacheModel( "models/player/31Minutos_Juan/31Minutos_Juan.mdl" );
        g_Game.PrecacheGeneric( "models/player/LT_maincraft/LT_maincraft.bmp" );
        g_Game.PrecacheModel( "models/player/LT_maincraft/LT_maincraft.mdl" );
        g_Game.PrecacheGeneric( "models/player/L4D_Bill/L4D_Bill.bmp" );
        g_Game.PrecacheModel( "models/player/L4D_Bill/L4D_Bill.mdl" );
        g_Game.PrecacheGeneric( "models/player/L4D_Francis/L4D_Francis.bmp" );
        g_Game.PrecacheModel( "models/player/L4D_Francis/L4D_Francis.mdl" );
        g_Game.PrecacheGeneric( "models/player/L4D_Louis/L4D_Louis.bmp" );
        g_Game.PrecacheModel( "models/player/L4D_Louis/L4D_Louis.mdl" );
        g_Game.PrecacheModel( "models/player/L4D_Louis/L4D_LouisT.mdl" );
        g_Game.PrecacheGeneric( "models/player/L4D_Zoey/L4D_Zoey.bmp" );
        g_Game.PrecacheModel( "models/player/L4D_Zoey/L4D_Zoey.mdl" );
        g_Game.PrecacheModel( "models/player/L4D2_coach/L4D2_coach.mdl" );
        g_Game.PrecacheModel( "models/player/L4D2_ellis/L4D2_ellis.mdl" );
        g_Game.PrecacheModel( "models/player/L4D2_nick/L4D2_nick.mdl" );
        g_Game.PrecacheModel( "models/player/L4D2_rochelle/L4D2_rochelle.mdl" );
        g_Game.PrecacheGeneric( "models/player/gohan/gohan.bmp" );
        g_Game.PrecacheModel( "models/player/gohan/gohan.mdl" );
        g_Game.PrecacheGeneric( "models/player/goku/Goku.bmp" );
        g_Game.PrecacheModel( "models/player/goku/goku.mdl" );
        g_Game.PrecacheGeneric( "models/player/Gonome/Gonome.bmp" );
        g_Game.PrecacheModel( "models/player/Gonome/Gonome.mdl" );
        g_Game.PrecacheGeneric( "models/player/HL2_combine/HL2_combine.bmp" );
        g_Game.PrecacheModel( "models/player/HL2_combine/HL2_combine.mdl" );
        g_Game.PrecacheGeneric( "models/player/Hunter_L4D/Hunter_L4D.bmp" );
        g_Game.PrecacheModel( "models/player/Hunter_L4D/Hunter_L4D.mdl" );
        g_Game.PrecacheGeneric( "models/player/pacman/pacman.bmp" );
        g_Game.PrecacheModel( "models/player/pacman/pacman.mdl" );
        g_Game.PrecacheGeneric( "models/player/Potal_2_atlas/Potal_2_atlas.bmp" );
        g_Game.PrecacheModel( "models/player/Potal_2_atlas/Potal_2_atlas.mdl" );
        g_Game.PrecacheGeneric( "models/player/Potal_2_P-Body/Potal_2_P-Body.bmp" );
        g_Game.PrecacheModel( "models/player/Potal_2_P-Body/Potal_2_P-Body.mdl" );
        g_Game.PrecacheGeneric( "models/player/alyx_hd/alyx_hd.bmp" );
        g_Game.PrecacheModel( "models/player/alyx_hd/alyx_hd.mdl" );
        g_Game.PrecacheGeneric( "models/player/HL2_metrocop/HL2_metrocop.bmp" );
        g_Game.PrecacheModel( "models/player/HL2_metrocop/HL2_metrocop.mdl" );
        g_Game.PrecacheGeneric( "models/player/th_sheriff/th_sheriff.bmp" );
        g_Game.PrecacheModel( "models/player/th_sheriff/th_sheriff.mdl" );
        g_Game.PrecacheGeneric( "models/player/VortHEV/VortHEV.bmp" );
        g_Game.PrecacheModel( "models/player/VortHEV/VortHEV.mdl" );
        g_Game.PrecacheGeneric( "models/player/chupetin/chupetin.bmp" );
        g_Game.PrecacheModel( "models/player/chupetin/chupetin.mdl" );
        g_Game.PrecacheGeneric( "models/player/colgate/colgate.bmp" );
        g_Game.PrecacheModel( "models/player/colgate/colgate.mdl" );
        g_Game.PrecacheGeneric( "models/player/hl1_Vortigaunt/hl1_Vortigaunt.bmp" );
        g_Game.PrecacheModel( "models/player/hl1_Vortigaunt/hl1_Vortigaunt.mdl" );
       // g_Game.PrecacheGeneric( "models/player/LT_amongus/LT_amongus.mdl" );
       // g_Game.PrecacheGeneric( "models/player/" + g_PlayerModelList[i] + "/" + g_PlayerModelList[i] + ".mdl" );
}
