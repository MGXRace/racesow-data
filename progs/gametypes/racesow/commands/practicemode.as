/**
 * practicemode Command
 * Toggle the player's practicemode state
 */
class RS_CMD_PracticeMode : RS_Command
{
	RS_CMD_PracticeMode()
	{
		name = "practicemode";
    	description = "Enable or disable practicemode";
    	usage = "practicemode\nAllows usage of the position and noclip commands";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
		return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( @player.client is null )
    		return false;

    	player.cancelRace();

    	switch ( player.getState() )
    	{
    	case RS_STATE_PRACTICE:
    		player.practicing = false;
            if( player.inNoClip )
                // put the player in a location that is safe to un-noclip
                player.client.respawn( false );
    		player.respawn();
    		sendAward( @player, S_COLOR_GREEN + "Leaving practice mode" );
    		break;

    	case RS_STATE_RACING:
    	case RS_STATE_PRERACE:
            if( player.client.team != TEAM_PLAYERS )
                player.respawn();
    		sendAward( @player, S_COLOR_GREEN + "You have entered practice mode" );
    		player.practicing = true;
    		player.startRace();
    		break;
    	}

		return true;
    }
}