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
     * Checkpoints of the race
     * @var uint
     */
    uint[] checkpoints;

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
        checkpoints.resize( numCheckpoints );
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
     * addCheckpoint
     * Add a checkpoint to the race
     * @param int cpNum Number of the checkpoint to add
     * @return bool True if the checkpoint was saved, false otherwise
     */
    bool addCheckpoint( int cpNum )
    {
        if( checkpoints[cpNum] != 0 || @player is null )
            return false;

        checkpoints[cpNum] = player.client.uCmdTimeStamp - startTime;
        return true;
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
