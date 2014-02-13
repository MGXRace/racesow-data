/**
 * Racesow Gametype interface
 * Base class that all race gametypes should inherit from.
 *
 * @package Racesow
 * @version 1.1.0
 */
class RS_Gametype
{
    void InitGametype()
    {
    }

    void SpawnGametype()
    {
    }

    void Shutdown()
    {
    }

    bool MatchStateFinished( int incomingMathState )
    {
        return true;
    }

    void MatchStateStarted()
    {
    }

    void ThinkRules()
    {
    }

    void playerRespawn( Entity @ent, int old_team, int new_team )
    {
    }

    void scoreEvent( Client @client, String &score_event, String &args )
    {
    }

    String @ScoreboardMessage( uint maxlen )
    {
        return null;
    }

    Entity @SelectSpawnPoint( Entity @self )
    {
        return null;
    }

    bool UpdateBotStatus( Entity @self )
    {
        return false;
    }

    bool Command( Client @client, String @cmdString, String @argsString, int argc )
    {
        return false;
    }
}
