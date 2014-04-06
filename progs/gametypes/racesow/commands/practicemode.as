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

        int state;

        // Which state do we want to move to
        // 0 for race, 1 for practicemode
        if( argc == 1 )
        {
            state = args.getToken( 0 ).toInt();
            if( state == 1 && player.state == RS_STATE_PRACTICE )
                    return true;
            else if( state == 0 && player.state != RS_STATE_PRACTICE )
                    return true;
        }
        else
        {
            if( player.state == RS_STATE_PRACTICE )
                state = 0;
            else
                state = 1;
        }

        // Change the player's state
    	if( state == 0 )
        {
            if( player.inNoClip )
            {
                // put the player in a location that is safe to un-noclip
                player.client.respawn( false );
                player.noclip();
            }
            // Set state to racing and let respawn() correct it
            player.state = RS_STATE_RACING;
            player.respawn();
        }
        else
        {
            if( player.client.team != TEAM_PLAYERS )
                player.respawn();
            player.state = RS_STATE_PRACTICE;
            player.startRace();
        }

		return true;
    }
}