/**
 * position Command
 * Save the players position, facing, and speed
 */
class RS_CMD_Position : RS_Command
{
	RS_CMD_Position()
	{
		name = "position";
    	description = "Commands to store and load position";
    	usage = "position <command> where command is one of :\n"
            + "position save - Save current position\n"
            + "position speed <speed> - Set saved position speed\n"
            + "position load - Teleport to saved position\n"
            + "position prerace - Set the prerace spawn point\n"
			+ "position player <id> - Teleport to a player\n"
			+ "position cp <id> - Teleport to a checkpoint (id order may vary)\n"
            + "position set <x> <y> <z> <pitch> <yaw> - Teleport to specified position\n"
            + "position store <id> <name> - Store a position for another session\n"
            + "position restore <id> - Restore a stored position from another session\n"
            + "position storedlist <limit> - Sends you a list of your stored positions\n";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
		return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        bool success;
    	if( args.getToken( 0 ) == "save" )
        {
			success = player.position.save();
            if( success )
                sendMessage( @player, "Position saved\n" );
            return success;
        }

		if( args.getToken( 0 ) == "prerace" )
		{
			if( player.getState() != RS_STATE_PRERACE ||
				@player.client is null ||
				player.client.team != TEAM_PLAYERS )
			{
				sendMessage( @player, "Prerace postion must be set in prerace state\n");
				return false;
			}

			if( player.getHeight() != 0 )
			{
				sendMessage( @player, "Prerace position must be set on solid ground\n");
				return false;
			}

			if( player.client.getEnt().velocity.length() > .01 )
			{
				sendMessage( @player, "Prerace position must be set while standing still\n");
				return false;
			}

			success = player.positionPrerace.save();
            if( success )
                sendMessage( @player, "Position prerace saved\n" );
            return success;
		}

		else if( args.getToken( 0 ) == "load" )
			return player.position.load();

		else if( args.getToken( 0 ) == "speed" )
			return player.position.saveSpeed( args.getToken( 1 ) );

		return false;
    }
}
