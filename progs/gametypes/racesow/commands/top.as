const uint CMD_TOP_FLOODTIME = 3000;
uint[] CMD_TOP_TIMES(maxClients);

/**
 * top Command
 * Register the user with his current login credentials
 */
class RS_CMD_Top : RS_Command
{
	RS_CMD_Top()
	{
		name = "top";
    	description = "Display the top records on a map";
    	usage = "top - Show top records on the current map\n"
            + "top <map> <limi> - Show top <limit> records on <map>";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( @player is null || @player.client is null )
            return false;

        uint time = CMD_TOP_TIMES[player.client.get_playerNum()];
        if( time > realTime )
        {
            sendErrorMessage( @player, "Please wait " + (CMD_TOP_FLOODTIME / 1000) + " seconds between top calls." );
            return false;
        }
        return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( @player.client is null )
    		return false;

        if( argc != 2 )
            RS_QueryTop( @player.client, null, 30 );
        else
            RS_QueryTop( @player.client, args.getToken( 0 ), args.getToken( 1 ).toInt() );

        CMD_TOP_TIMES[player.client.get_playerNum()] = realTime + CMD_TOP_FLOODTIME;
		return true;
    }
}

/**
 * Callback handler
 * @return void
 */
void RS_QueryTop_Done( int status, Client @client, Json @data )
{
    RS_Player @player = RS_getPlayer( @client );
    if( @player is null )
        return;

    if( status != 200 )
    {
        sendErrorMessage( @player, "Top query failed" );
        if( @data !is null )
            sendErrorMessage( @player, data.getItem("error").getString() );
        return;
    }

    int count = data.getItem("count").valueint;
    int top, time, i = 0;
    String msg = S_COLOR_ORANGE + "Top " + count + " times on map '" + data.getItem("map").getString() + "'\n";
    Json @node = data.getItem("races").child;
    while( @node !is null )
    {
        if( i == 0 )
        {
            top = node.getItem("time").valueint;
            time = top;
        }
        else
            time = node.getItem("time").valueint;

        msg += S_COLOR_WHITE + (i+1) + ". "
            + S_COLOR_GREEN + TimeToString( time ) + " "
            + S_COLOR_YELLOW + "[" + diffString( top, time ).substr( 2 ) + "] "
            + S_COLOR_WHITE + node.getItem("playerName").getString() + " "
            + S_COLOR_WHITE + node.getItem( "created" ).getString() + "\n";

        i++;
        @node = node.next;
    }
    sendMessage( @player, msg );

}