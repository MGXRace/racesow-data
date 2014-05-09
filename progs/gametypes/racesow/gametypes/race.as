/**
 * Racesow Gametype - Race
 * Normal racing gametype
 *
 * @package Racesow
 * @version 1.0.3
 */
class RS_GT_Race : RS_Gametype
{
    Cvar rs_dash_speed( "rs_dash_speed", "451", CVAR_ARCHIVE );

    /**
     * Constructor Method
     */
    RS_GT_Race()
    {
    }

    /**
     * Destructor Method
     */
    ~RS_GT_Race()
    {
    }

    /**
     * InitGametype
     * Setup the gametype
     * @return void
     */
    void InitGametype()
    {
        RS_Gametype::InitGametype();
        gametype.title = "Race";
        gametype.isTeamBased = false;
        gametype.hasChallengersQueue = false;
        gametype.maxPlayersPerTeam = 0;
        gametype.spawnpointRadius = 0;
        gametype.autoInactivityRemove = true;
        gametype.playerInteraction = false;
        gametype.freestyleMapFix = false;
        gametype.enableDrowning = true;

        // disallow warmup, no matter what config files say, because it's bad for racesow timelimit.
        g_warmup_timelimit.set("0");

        // Set scoreboard config
        G_ConfigString( CS_SCB_PLAYERTAB_LAYOUT, "%n 112 %s 52 %t 96 %i 48 %l 48 %s 85" );
        G_ConfigString( CS_SCB_PLAYERTAB_TITLES, "Name Clan Time Speed Ping State" );

        RS_CMD_Oneliner cmd_oneliner;
        RS_CMD_Top cmd_top;
        RS_CMD_TopOld cmd_topold;
        RS_InitCommands();
    }

    /**
     * PlayerRespawn
     * Respawn a player
     * @param Entity @ent The player being respawned
     * @int old_team Team flag for the old team
     * @int new_team Team flag for the new team
     */
    void PlayerRespawn( Entity @ent, int old_team, int new_team )
    {
        RS_Gametype::PlayerRespawn( @ent, old_team, new_team );
        RS_Player @player = RS_getPlayer( @ent );

        if( @player is null || ent.isGhosting() )
            return;

        player.cancelRace();
        if( player.state == RS_STATE_PRACTICE )
        {
            player.startRace();
            player.race.prejumped = false;
        }

        // set player movement to pass through other players and remove gunblade auto attacking
        ent.client.set_pmoveFeatures( ent.client.pmoveFeatures & ~PMFEAT_GUNBLADEAUTOATTACK | PMFEAT_GHOSTMOVE );
        ent.client.set_pmoveDashSpeed( rs_dash_speed.get_value() );
        ent.client.inventorySetCount( WEAP_GUNBLADE, 1 );
        ent.client.selectWeapon( -1 );
        ent.client.stats.setScore( RS_getPlayer( ent ).bestTime() );
    }

    /**
     * ScoreboardMessage
     * Generate the scoreboard message
     * @param uint maxlen Maximum length of the message
     * @return String
     */
    String @ScoreboardMessage( uint maxlen )
    {
        RS_Gametype::ScoreboardMessage( maxlen );
        String scoreboardMessage, entry;
        Team @team;
        Entity @ent;
        int i, playerID;
        int racing;
        //int readyIcon;

        @team = @G_GetTeam( TEAM_PLAYERS );

        // &t = team tab, team tag, team score (doesn't apply), team ping (doesn't apply)
        entry = "&t " + int( TEAM_PLAYERS ) + " 0 " + team.ping + " ";
        if ( scoreboardMessage.len() + entry.len() < maxlen )
            scoreboardMessage += entry;

        // "Name Time Ping State"
        for ( i = 0; @team.ent( i ) != null; i++ )
        {
            @ent = @team.ent( i );
            RS_Player @player = @RS_getPlayer( ent );

            int playerID = ( ent.isGhosting() && ( match.getState() == MATCH_STATE_PLAYTIME ) ) ? -( ent.get_playerNum() + 1 ) : ent.get_playerNum();

            String playerState;
            switch( player.state )
            {
            case RS_STATE_PRACTICE:
                playerState = "^5practicing";
                break;

            case RS_STATE_RACING:
                playerState = "^2racing";
                break;
                
            case RS_STATE_PRERACE:
                playerState = "^3prerace";
                break;
            }
            
            entry = "&p " + playerID + " " + ent.client.clanName + " "
                + player.bestTime() + " "
                + player.highestSpeed + " "
                + ent.client.ping + " " + playerState + " ";
            if ( scoreboardMessage.len() + entry.len() < maxlen )
                scoreboardMessage += entry;
        }

        playerList = scoreboardMessage;
        return @scoreboardMessage;
    }

    /**
     * Think rules specific to the race gametype
     * @return void
     */
    void ThinkRules()
    {
        RS_Gametype::ThinkRules();
        map.Think();
    }

    /**
     * ScoreEvent
     * @param Client client The client associated with the event
     * @param String score_event The name of the event
     * @param String args Arguments associated with the event
     */
    void ScoreEvent( Client @client, const String &score_event, const String &args )
    {
        if( score_event == "rs_loadmap" )
            @map.worldRecord = @RS_Race( args );

        else if( score_event == "rs_loadplayer" )
        {
            RS_Player @player = RS_getPlayer( client );
            if( @player is null )
                return;

            @player.record = @RS_Race( args );
        }

        RS_Gametype::ScoreEvent( client, score_event, args );
    }

    void Shutdown()
    {
        RS_Gametype::Shutdown();
    }
}
