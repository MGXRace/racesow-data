/**
 * mapname Command
 */
class RS_CMD_MapName : RS_Command
{
    Cvar mapname( "mapname", "", 0);

	RS_CMD_MapName()
	{
		name = "mapname";
    	description = "Return the name of the current map";
    	usage = "";
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	sendMessage( @player, mapname.string + "\n" );
    	return true;
    }
}