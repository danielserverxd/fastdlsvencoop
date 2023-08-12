#include "../../maps/mikk/utils/CUtils"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

bool MapBlackListed;

void MapInit()
{
    if( g_SurvivalMode.MapSupportEnabled() )
    {
        MapBlackListed = g_Util.IsStringInFile( 'scripts/plugins/mikk/survival_respawn.txt', string( g_Engine.mapname ) );

        if( !MapBlackListed )
        {
            g_SurvivalMode.SetDelayBeforeStart( 0.0f );
        }
    }
}

dictionary TrackPlayers;

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        g_Scheduler.SetTimeout( "DelayedCheck", 0.1f, @pPlayer );
    }
    return HOOK_CONTINUE;
}

void DelayedCheck( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        if( !TrackPlayers.exists( string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ) )
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Modo de Supervivencia activado. No se permiten mas reapariciones para los jugadores conectados.\n" );
            g_PlayerFuncs.RespawnPlayer(pPlayer, true, true);
            TrackPlayers[ string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ] = 'Joined';
        }
        else
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Has reaparecido antes, no se permite reaparecer al volver a unirte.\n" );
        }
    }
}

HookReturnCode MapChange()
{
    TrackPlayers.deleteAll();
    return HOOK_CONTINUE;
}