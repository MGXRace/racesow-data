const uint CMD_ML_FLOODTIME = 1500;
uint[] CMD_ML_TIMES(maxClients);

/**
 * maplist Command
 */
class RS_CMD_MapList : RS_Command
{
	RS_CMD_MapList()
	{
		name = "maplist";
    	description = "List available maps";
    	usage = "maplist <page> - Show page <page> of the maps\n"
              + "maplist <filter> <page> - show page <page> of maps matching <filter>\n"
              + "maplist <filter> <page> <tag>... - show page <page> of maps matching <filter> with tags\n"
              + "Tags can be prependend with \"!\" to exclude, ie. \"!tech\" to return non-tech maps";
    	register();
	}

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( @player is null || @player.client is null )
            return false;

        uint time = CMD_ML_TIMES[player.client.get_playerNum()];
        if( time > realTime )
        {
            sendErrorMessage( @player, "Please wait " + (CMD_ML_FLOODTIME / 1000) + " seconds between maplist calls." );
            return false;
        }
        return true;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( @player is null )
            return false;

        if( argc <= 1 )
        {
            RS_QueryMaps( @player.client, "", "", args.getToken( 0 ).toInt() );
        }
        else if( argc == 2 )
        {
            RS_QueryMaps( @player.client, args.getToken( 0 ), "", args.getToken( 1 ).toInt() );
        }
        else
        {
            String tags = args.substr( args.getToken( 0 ).len() + 1 );
            tags = tags.substr( tags.getToken( 0 ).len() + 1 );

            RS_QueryMaps( @player.client, args.getToken( 0 ), tags, args.getToken( 1 ).toInt() );
        }

        CMD_ML_TIMES[player.client.get_playerNum()] = realTime + CMD_ML_FLOODTIME;
    	return true;
    }
}
