/**
 * Racesow Race Model
 *
 * @package Racesow
 * @version 1.1.0
 */
class RS_Race
{
    /**
     * The player owning the race or null for anonymous records
     * @var RS_Player
     */
    RS_Player @player;

    /**
     * uCmd timestamp when starting the race
     * @var uint
     */
    uint startTime;

    /**
     * uCmd timestamp when finishing the race
     * @var uint
     */
    uint endTime;

    /**
     * Constructor
     */
    RS_Race()
    {
        @player = null;
    }

    /**
     * Constructor
     * Constructing with a player starts the race automatically
     * @param RS_Player player The owner of the race
     */
    RS_Race( RS_Player @player )
    {
        @this.player = @player;
        startTime = player.client.uCmdTimeStamp;
    }

    /**
     * Destructor
     */
    ~RS_Race()
    {
    }

    /**
     * stopRace
     * Stops the race
     * @return void
     */
    void stopRace()
    {
        endTime = player.client.uCmdTimeStamp;
    }

    /**
     * getTime
     * Returns the race time
     * @return uint
     */
    uint getTime()
    {
        if( endTime != 0 )
            return endTime - startTime;

        return player.client.uCmdTimeStamp - startTime;
    }
}
