const int RS_STATE_PRERACE = 1;
const int RS_STATE_RACING = 2;
const int RS_STATE_PRACTICE = 4;

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
     * The players highest speed
     * @var uint
     */
    uint highestSpeed;

    /**
     * Position object for position command
     * @var RS_Position
     */
    RS_Position position;

    /**
     * Position object for position prerace command
     * @var RS_Position
     */
    RS_Position positionPrerace;

    /**
     * Stores all spectators of the player in a list "(int)id (int)ping"
     * @var String
     */
    String challengerList;

    /**
     * True if player is in practicemode
     * @var bool
     */
    bool practicing;

    /**
     * Time the player should respawn at
     * @var uint
     */
    uint respawnTime;

    /**
     * True if player is in noclip state
     * @var bool
     */
    bool inNoClip;

    /**
     * Weapon selected before entering noclip mode
     * @var int
     */
    int noclipWeapon;

    /**
     * Constructor
     * @param Client client The client to associate with the player
     */
    RS_Player( Client @client )
    {
        @this.client = @client;
        position = RS_Position( @this );
        positionPrerace = RS_Position( @this );
        noclipWeapon = WEAP_NONE;
    }

    /**
     * Destructor
     */
    ~RS_Player()
    {
    }

    /**
     * respawn
     * Respawn the player and restore saved state if applicable
     * @return void
     */
    void respawn()
    {
        cancelRace();
        respawnTime = 0;

        if( @client.getEnt() !is null )
            G_RemoveProjectiles( client.getEnt() );

        if( client.team != TEAM_PLAYERS )
            client.team = TEAM_PLAYERS;

        if( !inNoClip )
            client.respawn( false );

        if( practicing && position.saved )
            position.load();
        else if( positionPrerace.saved )
            positionPrerace.load();

        if( practicing )
            startRace();
    }

    /**
     * noclip
     * Toggles the noclip state for the player
     * @return bool Success boolean
     */
    bool noclip()
    {
        Entity @ent = @client.getEnt();
        if( @ent is null )
            return false;

        if( ent.moveType == MOVETYPE_NOCLIP )
        {
            // Disable noclip - only if we are in free space
            Vec3 mins, maxs;
            ent.getSize( mins, maxs );
            Trace tr;
            uint contentMask;

            if( client.pmoveFeatures & PMFEAT_GHOSTMOVE == 0 )
                contentMask = MASK_PLAYERSOLID;
            else
                contentMask = MASK_DEADSOLID;

            if( tr.doTrace( ent.origin, mins, maxs, ent.origin, 0, contentMask ) )
            {
                sendErrorMessage( @this, "Can't switch noclip back when in something solid.\n" );
                return false;
            }

            ent.moveType = MOVETYPE_PLAYER;
            ent.solid = SOLID_YES;
            client.selectWeapon( noclipWeapon );
            inNoClip = false;
        }
        else
        {
            // Enable noclip - always possible
            ent.moveType = MOVETYPE_NOCLIP;
            ent.solid = SOLID_NOT;
            noclipWeapon = client.weapon;
            inNoClip = true;
        }

        return true;
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

        if( practicing )
        {
            race.stopRace();
            sendAward( @this, S_COLOR_CYAN + "You completed the map in practicemode, no time was set");
            @race = null;
            return;
        }

        uint refBest = @serverRecord is null ? 0 : serverRecord.getTime();
        uint newTime = race.getTime();

        // stop the race and save its time to the HUD
        race.stopRace();
        raceReport();
        respawnTime = realTime + 3000;

        if( race.prejumped )
        {
            @race = null;
            specCallback @func = @sendCenterMessage;
            execSpectators( @func, @this, "Prejump Time: " + TimeToString( newTime ) );
            sendMessage( @this, "Prejump records are not recorded.");
            return;
        }

        if( @serverRecord is null || serverRecord.getTime() > race.getTime() )
        {
            // new server record
            @serverRecord = @race;

            // Send record award to player and spectators
            specCallback @func = @sendAward;
            execSpectators( @func, @this, S_COLOR_GREEN + "New server record!" );

            // Print record message to chat
            G_PrintMsg(null, client.name + " "
                             + S_COLOR_YELLOW + "made a new server record: "
                             + TimeToString( race.getTime() ) + "\n");
        }

        if( @recordRace is null || recordRace.getTime() > race.getTime() )
        {
            // First record or New record
            @recordRace = @race;
            @race = null;

            // Send record award to player and spectators
            specCallback @func = @sendAward;
            execSpectators( @func, @this, "Personal record!" );
        }

        specCallback @func = @sendCenterMessage;
        String message = "Time: " + TimeToString( newTime ) + ( refBest == 0 ? "" : ( "\n" + diffString( refBest, newTime ) ) );
        execSpectators( @func, @this, message );
    }

    /**
     * cancelRace
     * Cancel the inprogress race
     * @return void
     */
    void cancelRace()
    {
        raceReport();
        @race = null;
    }

    /**
     * raceReport
     * Print to player's chat the current race report.
     * @return void
     */
    void raceReport()
    {
        if( @race is null )
            return;

        uint newTime = race.getTime();
        uint personalBest = @recordRace is null ? 0 : recordRace.getTime();
        uint refBest = @serverRecord is null ? 0 : serverRecord.getTime();

        sendMessage( @this, race.report );

        if( race.endTime == 0 ) // race wasn't finished
            return;

        sendMessage( @this, S_COLOR_WHITE + "Race finished: " + TimeToString( newTime )
                + S_COLOR_ORANGE + " Speed: " + S_COLOR_WHITE + race.endSpeed // finish speed
                + S_COLOR_ORANGE + " Personal: " + S_COLOR_WHITE + diffString(personalBest, newTime) // personal best
                + S_COLOR_ORANGE + " Server: " + S_COLOR_WHITE + diffString(refBest, newTime) // server best
                + "\n");
    }

    /**
     * addCheckpoint
     * Add a checkpoint if we are in a race
     * @param int cpNum Number of the checkpoint to add
     * @return bool True if the checkpoint was saved, False otherwise.
     */
    bool addCheckpoint( int cpNum )
    {
        if( @race is null || !race.addCheckpoint( cpNum ) )
            return false;

        // Make the checkpoint message
        RS_Race @refRace = @serverRecord;
        uint newTime = race.checkpoints[cpNum];
        uint refBest = @refRace is null ? 0 : refRace.checkpoints[cpNum];
        uint personalBest = @recordRace is null ? 0 : recordRace.checkpoints[cpNum];
        specCallback @func = @sendAward;

        if( newTime < refBest || refBest == 0 )
            execSpectators( @func, @this, S_COLOR_GREEN + "#" + ( cpNum + 1 ) + " checkpoint record!" );

        else if( newTime < personalBest || personalBest == 0 )
            execSpectators( @func, @this, S_COLOR_YELLOW + "#" + ( cpNum + 1 ) + " checkpoint personal record!" );

        @func = @sendCenterMessage;
        String message = "Current: " + TimeToString( newTime ) + ( refBest == 0 ? "" : ( "\n" + diffString( refBest, newTime ) ) );
        execSpectators( @func, @this, message );
        return true;
    }

    /**
     * Think
     * Perform think actions for the player.
     * @return void
     */
    void Think()
    {
        // repawn check
        if( respawnTime != 0 && realTime > respawnTime)
            respawn();

        // update highest speed
        uint hspeed = getSpeed();
        if( hspeed > highestSpeed )
            highestSpeed = hspeed;

        // Update HUD variables
        if( @race !is null )
            client.setHUDStat( STAT_TIME_SELF, race.getTime() / 100 );
        if( @serverRecord !is null )
            client.setHUDStat( STAT_TIME_RECORD, serverRecord.getTime() / 100 );
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

    /**
     * getSpeed
     * Return the player's current speed
     * @return uint
     */
    uint getSpeed()
    {
        Vec3 globalSpeed = client.getEnt().velocity;
        Vec3 horizontalSpeed = Vec3( globalSpeed.x, globalSpeed.y, 0 );
        return uint( horizontalSpeed.length() );
    }

    /**
     * getState
     * The current racing state of the player
     * @return int
     */
    int getState()
    {
        if( practicing )
            return RS_STATE_PRACTICE;

        return @race is null ? RS_STATE_PRERACE : RS_STATE_RACING;
    }

    /**
     * teleport
     * Teleport the player to a given location
     * @param Vec3 origin The target location
     * @param Vec3 origin The target facing
     * @param bool keepVelocity Whether to maintain velocity
     * @param bool keepVelocity Whether to telefrag on exit
     * @param bool keepVelocity Whether to show a teleport effect
     * @return bool True if successful
     */
    bool teleport( Vec3 origin, Vec3 angles, bool keepVelocity, bool kill, bool effects )
    {
        Entity @ent = @this.client.getEnt();
        if( @ent is null )
            return false;

        if( ent.team != TEAM_SPECTATOR )
        {
            Vec3 mins, maxs;
            ent.getSize(mins, maxs);
            Trace tr;
            if( tr.doTrace( origin, mins, maxs, origin, 0, MASK_PLAYERSOLID ) )
            {
                Entity @other = @G_GetEntity( tr.entNum );
                if( @other !is null && @other == @ent && kill && other.type == ET_PLAYER )
                {
                    // FIXME: return false if both players clip?
                    // Maybe that case won't even show in the trace
                    other.sustainDamage( @other, null, Vec3(0,0,0), 9999, 0, 0, MOD_TELEFRAG );
                    Entity @gravestone = @G_SpawnEntity( "gravestone" );
                    gravestone.origin = other.origin + Vec3( 0.0f, 0.0f, 50.0f );
                    // RS_getPlayer( other ).setupTelekilled( @gravestone ); TODO
                }
            }
        }

        if( effects && ent.team != TEAM_SPECTATOR )
            ent.teleportEffect( true );

        if(!keepVelocity)
            ent.velocity = Vec3(0,0,0);

        ent.origin = origin;
        ent.angles = angles;

        if( effects && ent.team != TEAM_SPECTATOR )
            ent.teleportEffect( false );

        return true;
    }
}