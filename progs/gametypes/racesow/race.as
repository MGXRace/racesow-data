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
     * Speed when starting the race
     * @var uint
     */
    int startSpeed;

    /**
     * Speed when finishing the race
     * @var uint
     */
    int endSpeed;

    /**
     * Checkpoints of the race
     * @var uint
     */
    int[] checkpoints;

    /**
     * Report message for the race
     * @var String
     */
    String report;

    /**
     * True if the race was prejumped
     * @var bool
     */
    bool prejumped;

    /**
     * True if the race was preshot
     * @var bool
     */
    bool preshot;

    /**
     * Constructor
     */
    RS_Race()
    {
        @player = null;
        checkpoints.resize( numCheckpoints );
        startSpeed = 0;
        prejumped = false;
        preshot = false;
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
        startSpeed = player.getSpeed();
        prejumped = RS_QueryPjState( player.client.get_playerNum() );
        preshot = RS_QueryPsState( player.client.get_playerNum() );

        report = ( prejumped || preshot ? S_COLOR_RED + "PREJUMPED " : "" ) + S_COLOR_ORANGE 
            + "Start speed: " + S_COLOR_WHITE + player.getSpeed() + "\n";
    }

    /**
     * Construct a race from a string of the form
     * "time cp1 cp2 cp3... cpN"
     * @param args The argstring
     */
    RS_Race( String &args )
    {
        endTime = args.getToken( 0 ).toInt();
        checkpoints.resize( numCheckpoints );
        for( int i = 0; i < numCheckpoints; i++ )
            checkpoints[i] = args.getToken( i + 1 ).toInt();
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
        endSpeed = player.getSpeed();
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

        RS_Race @refRace = player.getRefRace();
        int newTime = checkpoints[cpNum];
        int personalBest = @player.record is null ? 0 : player.record.checkpoints[cpNum];
        int refBest = @refRace is null ? 0 : refRace.checkpoints[cpNum];
        if( player.state == RS_STATE_PRACTICE )
        {
            newTime -= lastCheckpoint( cpNum );
            refBest -= @refRace is null ? 0 : refRace.lastCheckpoint( cpNum );
            personalBest -= @player.record is null ? 0 : player.record.lastCheckpoint( cpNum );
        }

        report += S_COLOR_ORANGE + "#" + ( cpNum + 1 ) + ": "
                + S_COLOR_WHITE + TimeToString( newTime )
                + S_COLOR_ORANGE + " Speed: " + S_COLOR_WHITE + player.getSpeed()
                + S_COLOR_ORANGE + " Personal: " + S_COLOR_WHITE + diffString( personalBest, newTime )
                + S_COLOR_ORANGE + " Server: " + S_COLOR_WHITE + diffString( refBest, newTime ) + "\n";
        return true;
    }

    /**
     * lastCheckpoint
     * Get the first non-zero checkpoint time before cpNum
     * @param cpNum Number of checkpoint to limit by
     * @return  The time of the checkpoint
     */
    int lastCheckpoint( int cpNum )
    {
        int i;
        for( i = cpNum - 1; i >= 0; i-- )
        {
            if( checkpoints[i] > 0 )
                return checkpoints[i];
        }
        return 0;
    }

    /**
     * getTime
     * Returns the race time
     * @return uint
     */
    uint getTime()
    {
        if( endTime != 0 || @player is null )
            return endTime - startTime;

        return player.client.uCmdTimeStamp - startTime;
    }
}
