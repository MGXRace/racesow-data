const uint CMD_TOPALL_FLOODTIME = 3000;
const uint TOPALL_DEFAULT_ENTRIES = 20;
uint[] CMD_TOPALL_TIMES(maxClients);

/**
 * topall Command
 * Show toplist for the map
 */
class RS_CMD_TopAll : RS_Command
{
	RS_CMD_TopAll()
	{
		name = "topall";
    	description = "Display both new and racesow 1.0 records on a map";
    	usage = "topall - Show new and racesow 1.0 records on the current map\n"
            + "topall <map> - Show " + TOPALL_DEFAULT_ENTRIES + " records on <map>\n"
            + "topall <map> <limit> - Show <limit> records on <map>";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( @player is null || @player.client is null )
            return false;

        uint time = CMD_TOPALL_TIMES[player.client.get_playerNum()];
        if( time > realTime )
        {
            sendErrorMessage( @player, "Please wait " + (CMD_TOPALL_FLOODTIME / 1000) + " seconds between top calls." );
            return false;
        }
        return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( @player.client is null )
    		return false;

        if( argc == 0 )
            RS_QueryTop( @player.client, null, TOPALL_DEFAULT_ENTRIES, RS_MAP_TOPALL );
        else if( argc == 1 )
            RS_QueryTop( @player.client, args.getToken( 0 ), TOPALL_DEFAULT_ENTRIES, RS_MAP_TOPALL );
		else if( argc >= 2 )
		{
			if( !args.getToken( 1 ).isNumerical() )
			{
				sendErrorMessage( @player, "<limit> should be a number" );
				return false;
			}
            RS_QueryTop( @player.client, args.getToken( 0 ), args.getToken( 1 ).toInt(), RS_MAP_TOPALL );
		}

        CMD_TOPALL_TIMES[player.client.get_playerNum()] = realTime + CMD_TOPALL_FLOODTIME;
		return true;
    }
}
