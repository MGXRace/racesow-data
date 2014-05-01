/**
 * Admin command
 */
class RS_CMD_Oneliner : RS_Command
{
	RS_CMD_Oneliner()
	{
		name = "oneliner";
    	description = "Update oneliner message for the map";
    	usage = "oneliner <message>";

    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( @player is null || @player.client is null )
            return false;

        if( !player.oneliner )
        {
            sendErrorMessage( @player, "Make a world record to set the oneliner message" );
            return false;
        }

        if( argc != 1 )
        {
            sendErrorMessage( @player, "Please provide a message" );
            return false;
        }

        return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( @player is null || @player.client is null )
            return false;

        player.oneliner = false;
        RS_ReportMap( "", args );
        return true;
    }
}