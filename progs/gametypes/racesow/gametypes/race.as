/**
 * Racesow Gametype - Race
 * Normal racing gametype
 *
 * @package Racesow
 * @version 1.0.3
 */
class RS_GT_Race : RS_Gametype
{
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

        if( ent.isGhosting() )
            return;

        // set player movement to pass through other players and remove gunblade auto attacking
        ent.client.set_pmoveFeatures( ent.client.pmoveFeatures & ~PMFEAT_GUNBLADEAUTOATTACK | PMFEAT_GHOSTMOVE );
        ent.client.inventorySetCount( WEAP_GUNBLADE, 1 );
        ent.client.stats.setScore( RS_getPlayer( ent ).bestTime() );
    }
}