/**
 * Racesow Gametype interface
 * Base class that all race gametypes should inherit from.
 *
 * @package Racesow
 * @version 1.1.0
 */
class RS_Gametype
{
    /**
     * Leveltime of last scoreboard update
     * @var uint
     */
    uint scoreboardUpdate;

    /**
     * Flag to push the updated scoreboard in the next Think
     * @var bool
     */
    bool scoreboardSend;

    /**
     * List of spectators in the form "(int)id (int)ping"
     * @var String
     */
    String spectatorList;

    /**
     * Main Scoreboard message string
     * @var String
     */
    String playerList;

    /**
     * InitGametype
     * Setup the gametype
     * @return void
     */
    void InitGametype()
    {
        gametype.title = "Racesow";
        gametype.version = "1.1.0";
        gametype.author = "inc.mgxrace.net";

        gametype.spawnableItemsMask = ( IT_WEAPON | IT_AMMO | IT_ARMOR | IT_POWERUP | IT_HEALTH );
        if ( gametype.isInstagib )
          gametype.spawnableItemsMask &= ~uint(G_INSTAGIB_NEGATE_ITEMMASK);

        gametype.respawnableItemsMask = gametype.spawnableItemsMask;
        gametype.dropableItemsMask = gametype.spawnableItemsMask;
        gametype.pickableItemsMask = gametype.spawnableItemsMask;

        gametype.isRace = true;

        gametype.ammoRespawn = 0;
        gametype.armorRespawn = 0;
        gametype.weaponRespawn = 0;
        gametype.healthRespawn = 0;
        gametype.powerupRespawn = 0;
        gametype.megahealthRespawn = 0;
        gametype.ultrahealthRespawn = 0;

        gametype.readyAnnouncementEnabled = false;
        gametype.scoreAnnouncementEnabled = false;
        gametype.countdownEnabled = false;
        gametype.mathAbortDisabled = true;
        gametype.shootingDisabled = false;
        gametype.infiniteAmmo = true;
        gametype.canForceModels = true;
        gametype.canShowMinimap = false;
        gametype.teamOnlyMinimap = true;

        // set spawnsystem type
        for ( int team = TEAM_PLAYERS; team < GS_MAX_TEAMS; team++ )
          gametype.setTeamSpawnsystem( team, SPAWNSYSTEM_INSTANT, 0, 0, false );

        // Initialize Commands common to all race gametypes
        // Until angelscript supports static class members/methods or better
        // namespacing we can't make a proper plugin achitecture
        RS_CMD_RaceRestart cmd_racerestart;
        RS_CMD_Join cmd_join;
        RS_CMD_Kill cmd_kill;
        RS_CMD_Help cmd_help;
        RS_CMD_Position cmd_position;
        RS_CMD_PracticeMode cmd_practicemode;
        RS_CMD_Machinegun cmd_machinegun;
        RS_CMD_NoClip cmd_noclip;
        RS_CMD_Privsay cmd_privsay;
        RS_CMD_MapName cmd_mapname;
        RS_CMD_WhoIsGod cmd_whoisgod;
        RS_CMD_WeaponDefs cmd_weapondefs;
        RS_CMD_Give cmd_give;
    }

    void SpawnGametype()
    {
        for( int i = 0; i < numEntities; i++ )
        {
            Entity @ent = @G_GetEntity( i );
            if( @ent is null )
                continue;

            if( ent.classname == "trigger_multiple" && entityTargets( @ent, "target_startTimer" ) )
            {
                ent.wait = 0;
            }

            else if( ent.classname == "target_give" )
            {
                array<Entity@> targets = ent.findTargets();
                for( uint i = 0; i < targets.length(); i++ )
                {
                    Entity @target = targets[i];
                    if( @target is null )
                    {
                        G_Print( S_COLOR_ORANGE  + "Warning: " + S_COLOR_WHITE + "target_give is missing targets\n" );
                        ent.unlinkEntity();
                        ent.freeEntity();
                        break;
                    }
                }
            }

            else if( ent.type == ET_ITEM )
            {
                Item @item = @ent.item;
                if( @item !is null && 
                    ent.classname == item.classname && 
                    ent.solid != SOLID_NOT &&
                    !entityTargetedBy( @ent, "target_give" ) )
                {
                    ent.classname = "AS_" + item.classname;
                    replacementItem( @ent );
                }
            }
        }
    }

    void Shutdown()
    {
    }

    bool MatchStateFinished( int incomingMatchState )
    {
        return true;
    }

    /**
     * Perform setup for a match state
     * @return void
     */
    void MatchStateStarted()
    {
        switch( match.getState() )
        {
        case MATCH_STATE_WARMUP:
            match.launchState( MATCH_STATE_PLAYTIME );
            break;

        case MATCH_STATE_PLAYTIME:
            break;

        case MATCH_STATE_POSTMATCH:
            gametype.pickableItemsMask = 0;
            gametype.dropableItemsMask = 0;
            GENERIC_SetUpEndMatch();
            break;
        }
    }

    void ThinkRules()
    {
        if ( match.timeLimitHit() )
            match.launchState( match.getState() + 1 );

        if ( match.getState() >= MATCH_STATE_POSTMATCH )
            return;

        RS_Player @player;

        for( int i = 0; i < maxClients; i++ )
        {
            @player = @players[i];
            if( @player is null )
                continue;

            player.Think();

            if( scoreboardSend && player.challengerList != "" )
            {
                String cmd = "scb \"" + playerList + " "
                           + "&s " + spectatorList + " "
                           + "&w " + player.challengerList + "\"";
                player.client.execGameCommand( cmd );
            }
        }
    }

    void PlayerRespawn( Entity @ent, int old_team, int new_team )
    {
        RS_Player @player = RS_getPlayer( @ent );
        if( @player !is null )
            player.cancelRace();
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

    /**
     * ScoreboardMessage
     * Generate the scoreboard message
     * @param uint maxlen Maximum length of the message
     * @return String
     */
    String @ScoreboardMessage( uint maxlen )
    {
        RS_Player @player;

        if( levelTime > scoreboardUpdate + 1800 )
        {
            for( int i = 0; i < maxClients; i++ )
            {
                if( players[i] is null )
                    continue;
                players[i].challengerList = "";
            }

            Team @spectators = @G_GetTeam( TEAM_SPECTATOR );
            Entity @other;
            spectatorList = "";

            for( int i = 0; @spectators.ent( i ) !is null; i++ )
            {
                @other = @spectators.ent( i );
                if( @other.client is null )
                    continue;

                if( !other.client.connecting && other.client.state() >= CS_SPAWNED )
                    spectatorList += other.client.get_playerNum() + " " + other.client.ping + " ";

                else if( other.client.connecting )
                    spectatorList += other.client.get_playerNum() + " -1 ";

                if( other.client.chaseActive && other.client.chaseTarget != 0 )
                {
                    @player = players[other.client.chaseTarget - 1];
                    player.challengerList += other.client.get_playerNum() + " " + other.client.ping + " ";
                }
            }

            scoreboardUpdate = levelTime;
            scoreboardSend = true;
        }

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

    /**
     * GT_Command
     * Find and execute a matching command
     *
     * @param cClient client,
     * @param String cmdString
     * @param String args
     * @param int argc
     * @return void
     */
    bool Command( Client @client, String &cmdString, String &args, int argc )
    {
        RS_Player @player = RS_getPlayer( @client );
        RS_Command @command;
        if( @player is null )
            return false;

        if( !RS_CommandByName.get( cmdString, @command ) )
            return false;

        if( !command.validate( @player, args, argc ) )
            return false;

        return command.execute( @player, args, argc );
    }
}
