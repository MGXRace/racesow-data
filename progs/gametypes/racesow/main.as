/**
 * Racesow Gametype Interface
 * @version 1.1.0
 */

RS_Player@[] players( maxClients );
RS_Map @map;
RS_Gametype @rsGametype;
RS_Race @serverRecord;

int numCheckpoints;

Cvar g_gametype( "g_gametype", "race", CVAR_ARCHIVE );
Cvar g_warmup_timelimit( "g_warmup_timelimit", "0", CVAR_ARCHIVE);

/**
 * GT_Command
 *
 * @param Client @client,
 * @param String &cmdString
 * @param String &argsString
 * @param int argc
 * @return void
 */
bool GT_Command( Client @client, const String &cmdString, const String &argsString, int argc )
{
    return rsGametype.Command( @client, cmdString, argsString, argc );
}

/**
 * GT_UpdateBotStatus (maybe we can use this for race record display using a bot? :o)
 *
 * When this function is called the weights of items have been reset to their default values,
 * this means, the weights *are set*, and what this function does is scaling them depending
 * on the current bot status.
 * Player, and non-item entities don't have any weight set. So they will be ignored by the bot
 * unless a weight is assigned here.
 *
 * @param Entity @self
 * @return bool
 */
bool GT_UpdateBotStatus( Entity @self )
{
    return rsGametype.UpdateBotStatus( @self );
}

/**
 * GT_SelectSpawnPoint
 *
 * select a spawning point for a player
 * @param Entity @self
 * @return Entity
 */
Entity @GT_SelectSpawnPoint( Entity @self )
{
    return @rsGametype.SelectSpawnPoint( @self );
}

/**
 * GT_ScoreboardMessage
 * @param int maxlen
 * @return String
 */
String @GT_ScoreboardMessage( uint maxlen )
{
    return @rsGametype.ScoreboardMessage( maxlen );
}

/**
 * GT_scoreEvent
 *
 * handles different game events
 *
 * @param Client @client
 * @param String &score_event
 * @param String &args
 * @return void
 */
void GT_ScoreEvent( Client @client, const String &score_event, const String &args )
{
    rsGametype.ScoreEvent( @client, score_event, args );
}

/**
 * GT_playerRespawn
 *
 * a player is being respawned. This can happen from several ways, as dying, changing team,
 * being moved to ghost state, be placed in respawn queue, being spawned from spawn queue, etc
 *
 * @param Entity @ent
 * @param int old_team
 * @param int new_team
 * @return void
 */
void GT_PlayerRespawn( Entity @ent, int old_team, int new_team )
{
    rsGametype.PlayerRespawn( @ent, old_team, new_team );
}

/**
 * GT_ThinkRules
 *
 * Thinking function. Called each frame
 * @return void
 */
void GT_ThinkRules()
{
    rsGametype.ThinkRules();
}

/**
 * GT_MatchStateFinished
 *
 * The game has detected the end of the match state, but it
 * doesn't advance it before calling this function.
 * This function must give permission to move into the next
 * state by returning true.
 *
 * @param int incomingMatchState
 * @return void
 */
bool GT_MatchStateFinished( int incomingMatchState )
{
    return rsGametype.MatchStateFinished( incomingMatchState );
}

/**
 * GT_MatchStateStarted
 *
 * the match state has just moved into a new state. Here is the
 * place to set up the new state rules
 *
 * @return void
 */
void GT_MatchStateStarted()
{
    rsGametype.MatchStateStarted();
}

/**
 * GT_Shutdown
 * the gametype is shutting down cause of a match restart or map change
 * @return void
 */
void GT_Shutdown()
{
    rsGametype.Shutdown();
}

/**
 * GT_SpawnGametype
 * The map entities have just been spawned. The level is initialized for
 * playing, but nothing has yet started.
 *
 * @return void
 */
void GT_SpawnGametype()
{
    rsGametype.SpawnGametype();
}

/**
 * GT_InitGametype
 *
 * Important: This function is called before any entity is spawned, and
 * spawning entities from it is forbidden. If you want to make any entity
 * spawning at initialization do it in GT_SpawnGametype, which is called
 * right after the map entities spawning.
 *
 * @return void
 */
void GT_InitGametype()
{
    gametype.title = "Racesow";
    gametype.version = "1.1.0";
    gametype.author = "inc.mgxrace.net";

    if( g_gametype.string == "race" )
    {
        @rsGametype = @RS_GT_Race();
    }
    else
    {
        @rsGametype = @RS_GT_Race();
    }

    rsGametype.InitGametype();
}