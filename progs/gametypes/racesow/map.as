/**
 * Racesow Map Model
 *
 * @package Racesow
 * @version 1.0.3
 */
class RS_Map
{
    /**
     * World record race
     * @var RS_Race
     */
    RS_Race @worldRecord;

    /**
     * Server record race
     * @var RS_Race
     */
    RS_Race @serverRecord;

    /**
     * Number of real races finished this session
     * @var uint
     */
    uint races;

    /**
     * Milliseconds the map has been played this session
     * @var uint
     */
    uint playTime;

    /**
     * Constructor
     */
    RS_Map()
    {
    }

    /**
     * Destructor
     */
    ~RS_Map()
    {
    }

    /**
     * Think function for the map
     * @return void
     */
    void Think()
    {
        if( G_GetTeam( TEAM_PLAYERS ).numPlayers > 0 )
            playTime += frameTime;
    }
}
