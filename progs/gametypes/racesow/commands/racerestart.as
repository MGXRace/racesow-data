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

        player.cancelRace();
        player.client.team = TEAM_PLAYERS;
        player.client.respawn( false );
        return true;
    }
}