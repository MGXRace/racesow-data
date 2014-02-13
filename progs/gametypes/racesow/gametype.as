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

    void PlayerRespawn( Entity @ent, int old_team, int new_team )
    {
    }

    /**
     * ScoreEvent
     * Called by the game when one of the following events occurs (taken from
     * the warsow wiki page)
     * TODO: check this is up to date with 1.1
     * TODO: gather the arguments associated with the event
     *  - "enterGame" - A client has finished connecting and enters the level
     *  - "connect" - A client just connected
     *  - "disconnect" - A client just disconnected
     *  - "dmg" - A client has inflicted some damage
     *  - "kill" - A client has killed some other entity
     *  - "award" - A client receives an award
     *  - "pickup" - A client picked up an item (use args.getToken( 0 ) to get
     *    the item's classname)
     *  - "projectilehit" - A client is hit by a projectile
     *
     * @param Client client The client associated with the event
     * @param String score_event The name of the event
     * @param String args Arguments associated with the event
     */
    void ScoreEvent( Client @client, const String &score_event, const String &args )
    {
        if( @client is null )
            return;

        if( score_event == "enterGame" )
        {
            // Make a RS_Player for the client.
            @players[client.get_playerNum()] = @RS_Player( @client );
        }
        else if( score_event == "disconnect" )
        {
            // Release the associated RS_Player object
            @players[client.get_playerNum()] = null;
        }
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

    bool Command( Client @client, const String @cmdString, const String @argsString, int argc )
    {
        return false;
    }
}
