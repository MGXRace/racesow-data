/**
 * Helper functions
 */

/**
 * Print the diff string beteween two times.
 * The diff colors change according to which time is best.
 * If the first time is 0 then we consider that the diff doesn't make sense
 * and print dashes instead
 *
 * @param oldTime The old time, the one you compare to
 * @param newTime The new time, the one you want to compare
 * @return The diff string between the two times
 */
String diffString( uint oldTime, uint newTime )
{
    if ( oldTime == 0 )
    {
        return "--:--:---";
    }
    else if ( oldTime < newTime )
    {
        return S_COLOR_RED + "+" + TimeToString( newTime - oldTime );
    }
    else if ( oldTime == newTime )
    {
        return S_COLOR_YELLOW + "+-" + TimeToString( 0 );
    }
    else
    {
        return S_COLOR_GREEN + "-" + TimeToString( oldTime - newTime );
    }
}

/**
 * TimeToString
 * @param uint time
 * @return String
 */
String TimeToString( uint time )
{
    // convert times to printable form
    String minsString, secsString, millString;
    uint min, sec, milli;

    milli = time;
    min = milli / 60000;
    milli -= min * 60000;
    sec = milli / 1000;
    milli -= sec * 1000;

    if ( min == 0 )
        minsString = "00";
    else if ( min < 10 )
        minsString = "0" + min;
    else
        minsString = min;

    if ( sec == 0 )
        secsString = "00";
    else if ( sec < 10 )
        secsString = "0" + sec;
    else
        secsString = sec;

    if ( milli == 0 )
        millString = "000";
    else if ( milli < 10 )
        millString = "00" + milli;
    else if ( milli < 100 )
        millString = "0" + milli;
    else
        millString = milli;

    return minsString + ":" + secsString + "." + millString;
}

/**
 * Function signature to use for execSpectators
 * @var funcdef
 */
funcdef void specCallback( RS_Player @, String );

/**
 * execSpectators
 * Execute a function for a player and all his spectators
 * @param execSpec callback Callback function to execute
 * @param RS_Player player Player to execute for and their spectators
 * @param String arg Argument to pass to the callback
 * @return void
 */
void execSpectators( specCallback @func, RS_Player @player, String arg )
{
    if( @player.client is null )
        return;

    func( @player, arg );

    Team @spectators = @G_GetTeam( TEAM_SPECTATOR );
    RS_Player @other;
    for( int i = 0; @spectators.ent( i ) != null; i++ )
    {
        @other = @RS_getPlayer( spectators.ent( i ) );
        if( @other !is null && other.client.chaseActive && other.client.chaseTarget == player.client.get_playerNum() + 1 )
        {
            func( @other, arg );
        }
    }
}

/**
 * sendAward
 * Send an award to a given player
 * @param RS_Player player
 * @param String message
 * @return void
 */
void sendAward( RS_Player @player, String message )
{
    if( @player.client is null )
        return;

    player.client.execGameCommand( "aw \"" + message + "\"" );
}


/**
 * sendCenterMessage
 * Send an award to a given player
 * @param RS_Player player
 * @param String message
 * @return void
 */
void sendCenterMessage( RS_Player @player, String message )
{
    if( @player.client is null )
        return;

    G_CenterPrintMsg( player.client.getEnt(), message );
}

/**
 * sendMessage
 * Send a message to a player's chat
 * @param RS_Player player
 * @param String message
 * @return void
 */
 void sendMessage( RS_Player @player, String message )
 {
    if( @player.client is null )
        return;

    G_PrintMsg( player.client.getEnt(), message );
 }

/**
 * sendErrorMessage
 * Send an error message to a player's chat
 * @param RS_Player player
 * @param String message
 * @return void
 */
 void sendErrorMessage( RS_Player @player, String message )
 {
    if( @player.client is null )
        return;

    G_PrintMsg( player.client.getEnt(), S_COLOR_RED + "Error: " + S_COLOR_WHITE + message + "\n" );
 }