/**
 * RS_getPlayer
 * Get the RS_Player associated with a given entity
 *
 * @param Entity ent The player entity
 * @return RS_Player The player associated with the entity or null
 */
RS_Player@ RS_getPlayer( Entity @ent )
{
    if( @ent is null || ent.get_playerNum() < 0 )
        return null;

    return @players[ent.get_playerNum()];
}

/**
 * RS_getPlayer
 * Get the RS_Player associated with a given client
 *
 * @param Client client The player client
 * @return RS_Player The player associated with the client or null
 */
RS_Player@ RS_getPlayer( Client @client )
{
    if( @client is null || client.get_playerNum() < 0 )
        return null;

    return @players[client.get_playerNum()];
}

/**
 * Racesow Player Model
 *
 * @package Racesow
 * @version 1.1.0
 */
class RS_Player
{
    /**
     * The client associated with the player
     * @var Client
     */
    Client @client;

    /**
     * The player's inprogress or just finished race
     * @var RS_Race
     */
    RS_Race @race;

    /**
     * The player's best race
     * @var RS_Race
     */
    RS_Race @recordRace;

    /**
     * Constructor
     * @param Client client The client to associate with the player
     */
    RS_Player( Client @client )
    {
        @this.client = @client;
    }

    /**
     * Destructor
     */
    ~RS_Player()
    {
    }

    /**
     * startRace
     * Starts a new race iff the player is not currently racing
     * @return void
     */
    void startRace()
    {
        if( @race !is null )
            return;

        @race = @RS_Race( @this );
    }

    /**
     * stopRace
     * The inprogress race was finished
     * @return void
     */
    void stopRace()
    {
        if( @race is null )
            return;

        // stop the race and save its time to the HUD
        race.stopRace();

        if( @recordRace is null || recordRace.getTime() > race.getTime() )
        {
            // First record or New record
            @recordRace = @race;
            @race = null;
        }
    }

    /**
     * cancelRace
     * Cancel the inprogress race
     * @return void
     */
    void cancelRace()
    {
        @race = null;
    }

    /**
     * setHUD
     * Sets the HUD variables for a player
     * @return void
     */
    void setHUD()
    {
        if( @race !is null )
            client.setHUDStat( STAT_TIME_SELF, race.getTime() / 100 );
        client.setHUDStat( STAT_TIME_BEST, bestTime() / 100 );
    }

    /**
     * bestTime
     * Get the players best time
     * @return uint
     */
    uint bestTime()
    {
        if( @recordRace !is null )
            return recordRace.getTime();

        return 0;
    }
}
