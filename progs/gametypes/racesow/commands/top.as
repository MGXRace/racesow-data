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
