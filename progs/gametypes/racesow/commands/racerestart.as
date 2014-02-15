/**
 * racerestart Command
 * Restarts the player without a kill event
 */
class RS_CMD_RaceRestart : RS_Command
{
	RS_CMD_RaceRestart()
	{
		name = "racerestart";
    	description = "Go back to the start area";
    	usage = "";
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( @player.client is null )
        	return false;

		player.respawn();
        return true;
    }
}

class RS_CMD_Join : RS_CMD_RaceRestart
{
	RS_CMD_Join()
	{
		name = "join";
		description = "Go back to the start area";
		usage = "";
		register();
	}
}

class RS_CMD_Kill : RS_CMD_RaceRestart
{
	RS_CMD_Kill()
	{
		name = "kill";
		description = "Go back to the start area";
		usage = "";
		register();
	}
}