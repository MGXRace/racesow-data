const uint CMD_TOPOLD_FLOODTIME = 3000;
uint[] CMD_TOPOLD_TIMES(maxClients);

/**
 * topold Command
 * Show toplist for the map
 */
class RS_CMD_TopOld : RS_Command
{
	RS_CMD_TopOld()
	{
		name = "topold";
    	description = "Display the racesow 1.0 records on a map";
    	usage = "topold - Show racesow 1.0 records on the current map\n"
            + "topold <map> <limit> - Show <limit> records on <map>";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( @player is null || @player.client is null )
            return false;

        uint time = CMD_TOPOLD_TIMES[player.client.get_playerNum()];
        if( time > realTime )
        {
            sendErrorMessage( @player, "Please wait " + (CMD_TOPOLD_FLOODTIME / 1000) + " seconds between top calls." );
            return false;
        }
        return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( @player.client is null )
    		return false;

        if( argc != 2 )
            RS_QueryTop( @player.client, null, 30, true );
        else
            RS_QueryTopOld( @player.client, args.getToken( 0 ), args.getToken( 1 ).toInt(), true );

        CMD_TOPOLD_TIMES[player.client.get_playerNum()] = realTime + CMD_TOPOLD_FLOODTIME;
		return true;
    }
}
