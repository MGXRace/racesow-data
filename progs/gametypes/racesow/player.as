const uint RS_STATE_PRACTICE = 0;
const uint RS_STATE_PRERACE = 1;
const uint RS_STATE_RACING = 2;

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
     * The clients playerauth
     * @var RS_PlayerAuth
     */
    RS_PlayerAuth @auth;

    /**
     * Player's current racing state
     * @var state
     */
    uint state;

    /**
     * The player's inprogress or just finished race
     * @var RS_Race
     */
    RS_Race @race;

    /**
     * The player's last race, used for sending demo recording cmds
     * @var RS_Race
     */
    RS_Race @lastRace;

    /**
     * The player's best race
     * @var RS_Race
     */
    RS_Race @record;

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
     * Privsay floodprotection timer
     * @var uint[]
     */
    uint[] privsayTimes;

    /**
     * Current privsayTimes index
     * @var uint
     */
    uint privsayCount;

    /**
     * Last gametype entity touched
     * @var Entity
     */
    Entity @triggerEnt;

    /**
     * Time the last entity was touched
     * @var uint
     */
    uint triggerTime;

    /**
     * Constructor
     * @param Client client The client to associate with the player
     */
    RS_Player( Client @client )
    {
        @this.client = @client;
        @this.auth = @client.getAuth();
        position = RS_Position( @this );
        positionPrerace = RS_Position( @this );
        noclipWeapon = WEAP_NONE;
        state = RS_STATE_PRERACE;
        privsayTimes.resize( PRIVSAY_FLOODCOUNT );
    }

    /**
     * Destructor
     */
    ~RS_Player()
    {
    }

    /**
     * Returns the client's name without color tokens and in lowercase
     * @return The client's simplified name
     */
    String simpleNick()
    {
        return client.get_name().removeColorTokens().tolower();
    }

    /**
     * respawn
     * Respawn the player and restore saved state if applicable
     * @return void
     */
    void respawn()
    {
        RS_ResetPjState( client.get_playerNum() );
        cancelRace();
        respawnTime = 0;

        // Did we finish the last race?
        if( @lastRace !is null )
        {
            int time = lastRace.getTime();
            if( @lastRace is @record )
                client.execGameCommand( "dstop " + time + " " + 1 );
            else
                client.execGameCommand( "dstop " + time + " " + 0 );
        }
        else
            client.execGameCommand( "dcancel" );
        @lastRace = null;

        if( @client.getEnt() !is null )
            G_RemoveProjectiles( client.getEnt() );

        if( client.team != TEAM_PLAYERS )
            client.team = TEAM_PLAYERS;

        if( state != RS_STATE_PRACTICE || !inNoClip )
            client.respawn( false );

        if( state == RS_STATE_PRACTICE && position.saved )
            position.load();
        else if( positionPrerace.saved )
            positionPrerace.load();

        if( state == RS_STATE_PRACTICE )
        {
            startRace();
            race.prejumped = false;
        }
        else
        {
            state = RS_STATE_PRERACE;
            client.execGameCommand( "dstart" );
        }
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
                sendErrorMessage( @this, "Can't switch noclip back when in something solid." );
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
        if( @race !is null && state != RS_STATE_PRACTICE )
            return;

        if( state != RS_STATE_PRACTICE )
            state = RS_STATE_RACING;

        @race = @RS_Race( @this );
    }

    /**
     * stopRace
     * The inprogress race was finished
     * @return void
     */
    void stopRace()
    {
        if( @race is null || race.endTime != 0 )
            return;

        specCallback @func = @sendAward;
        race.stopRace();

        if( state == RS_STATE_PRACTICE )
        {
            sendAward( @this, S_COLOR_CYAN + "You completed the map in practicemode, no time was set");
            return;
        }

        if( race.prejumped )
        {
            execSpectators( @func, @this, "Prejump Time: " + TimeToString( race.getTime() ) );
            sendErrorMessage( @this, "Prejumped records are not recorded." );
            respawnTime = realTime + 3000;
            return;
        }

        // Not practicing or prejumped, its a real race
        auth.incrementRace();
        RS_Race @refRace = @getRefRace();
        uint refBest = @refRace is null ? 0 : refRace.getTime();
        uint newTime = race.getTime();
        raceReport( @race );
        respawnTime = realTime + 3000;
        @lastRace = @race;

        // World Record - Beats record loaded from database
        if( auth.id > 0 )
        {
            if( @map.worldRecord is null || map.worldRecord.getTime() > newTime )
            {
                @map.worldRecord = @race;
                execSpectators( @func, @this, S_COLOR_GREEN + "New World record!" );
                G_PrintMsg(null, client.name + " "
                                 + S_COLOR_YELLOW + "made a new world record: "
                                 + TimeToString( newTime ) + "\n");
            }

            // Server record
            if( @map.serverRecord is null || map.serverRecord.getTime() > newTime )
            {
                @map.serverRecord = @race;
                execSpectators( @func, @this, S_COLOR_GREEN + "New server record!" );
                G_PrintMsg(null, client.name + " "
                                 + S_COLOR_YELLOW + "made a new server record: "
                                 + TimeToString( newTime ) + "\n");
            }
        }
        else
        {
            sendErrorMessage( @this, "You are not logged in, race was not recorded." );
        }

        // Personal record
        if( @record is null || record.getTime() > newTime )
        {
            @record = @race;
            auth.reportRace( newTime, race.checkpoints );
            execSpectators( @func, @this, "Personal record!" );
        }

        execSpectators( @func, @this, "Time: " + TimeToString( newTime ) );
        if( refBest != 0 )
            execSpectators( @func, @this, diffString( refBest, newTime ) );
    }

    /**
     * cancelRace
     * Cancel the inprogress race
     * @return void
     */
    void cancelRace()
    {
        // If race was finished, stopRace should have reported it
        if( @race !is null && race.endTime == 0 && state != RS_STATE_PRACTICE )
            raceReport( @race );
        @race = null;
    }

    /**
     * raceReport
     * Print to player's chat the current race report.
     * @param RS_Race The race to report on
     * @return void
     */
    void raceReport( RS_Race @race )
    {
        if( @race is null || client.getUserInfoKey( "rs_raceReport" ) != "1" )
            return;

        RS_Race @refRace = @getRefRace();
        uint newTime = race.getTime();
        uint personalBest = @record is null ? 0 : record.getTime();
        uint refBest = @refRace is null ? 0 : refRace.getTime();

        sendMessage( @this, race.report );

        if( race.endTime == 0 ) // race wasn't finished
            return;

        sendMessage( @this, S_COLOR_ORANGE + "Race finished: " + S_COLOR_WHITE + TimeToString( newTime )
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
        RS_Race @refRace = getRefRace();
        uint newTime = race.checkpoints[cpNum];
        uint refBest = @refRace is null ? 0 : refRace.checkpoints[cpNum];
        uint personalBest = @record is null ? 0 : record.checkpoints[cpNum];
        specCallback @func = @sendAward;

        if( newTime < refBest || refBest == 0 )
            execSpectators( @func, @this, S_COLOR_GREEN + "#" + ( cpNum + 1 ) + " checkpoint record!" );

        else if( newTime < personalBest || personalBest == 0 )
            execSpectators( @func, @this, S_COLOR_YELLOW + "#" + ( cpNum + 1 ) + " checkpoint personal record!" );

        @func = @sendAward;
        execSpectators( @func, @this, "Current: " + TimeToString( newTime ) );
        if( refBest != 0 )
            execSpectators( @func, @this, diffString( refBest, newTime ) );
        return true;
    }

    /**
     * Think
     * Perform think actions for the player.
     * @return void
     */
    void Think()
    {
        // check maxHealth rule
        Entity @ent = client.getEnt();
        if ( ent.health > ent.maxHealth )
            ent.health -= ( frameTime * 0.001f );

        // repawn check
        if( respawnTime != 0 && realTime > respawnTime )
            respawn();

        // update highest speed
        uint hspeed = getSpeed();
        if( ent.team == TEAM_PLAYERS && state != RS_STATE_PRACTICE && hspeed > highestSpeed )
            highestSpeed = hspeed;

        // Update HUD variables
        client.setHUDStat( STAT_RACE_STATE, state );

        if( @record !is null )
            client.setLongHUDStat( STAT_TIME_BEST, bestTime() / 10 );

        if( @race !is null )
        {
            client.setLongHUDStat( STAT_TIME_SELF, race.getTime() / 10 );
            client.setHUDStat( STAT_START_SPEED, race.startSpeed );
            client.setHUDStat( STAT_PREJUMP_STATE, race.prejumped ? 1 : 0 );
        }
        else
            client.setHUDStat( STAT_PREJUMP_STATE, RS_QueryPjState( client.get_playerNum() ) ? 1 : 0 );

        if( @map.serverRecord !is null )
            client.setLongHUDStat( STAT_TIME_RECORD, map.serverRecord.getTime() / 10 );

        if( @map.worldRecord !is null )
            client.setLongHUDStat( STAT_TIME_ALPHA, map.worldRecord.getTime() / 10 );
    }

    /**
     * bestTime
     * Get the players best time
     * @return uint
     */
    uint bestTime()
    {
        if( @record !is null )
            return record.getTime();

        return 0;
    }

    /**
     * getRefRace
     * Return the player's reference race
     * @return @RS_Race
     */
    RS_Race@ getRefRace()
    {
        RS_Race @refRace;
        RS_Player @player;
        String target = client.getUserInfoKey( "rs_diffref" );

        if( target == "world" )
            return @map.worldRecord;

        if( target == "server" )
            return @map.serverRecord;

        if( target == "personal" )
            return @record;

        @player = @RS_getPlayerFromArgs( target );
        if( @player !is null )
            return @player.record;

        return null;
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
        return uint( horizontalSpeed.length() + 0.5 );
    }

    /**
     * getHeight
     * Return the players distance above the closest floor
     * @return int
     */
    int getHeight()
    {
        Vec3 mins, maxs;
        Entity @ent = @client.getEnt();
        ent.getSize( mins, maxs );
        Vec3 down = Vec3( ent.origin.x, ent.origin.y, ent.origin.z - 5000 );
        Trace tr;
        return tr.doTrace( ent.origin, mins, maxs, down, ent.entNum, MASK_PLAYERSOLID ) ?
                     int( ent.origin.z - tr.get_endPos().z ) : -1;
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

    /**
     * Player touched an entity, save info for trigger checking later
     * @param ent The touched entity
     */
    void triggerSet( Entity @ent )
    {
        @triggerEnt = @ent;
        triggerTime = levelTime;
    }

    /**
     * Check if a player can activate an entity
     * @param ent     Entity touched
     * @param timeout Time player must wait to retrigger
     */
    bool triggerCheck( Entity @ent, int timeout )
    {
        if( triggerEnt !is ent )
            return true;

        return triggerTime + timeout < int(levelTime);
    }
}
