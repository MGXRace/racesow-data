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
    Client @client;

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
}
