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

        registerSubcommand( RS_CMD_PositionSave() );
        registerSubcommand( RS_CMD_PositionLoad() );
        registerSubcommand( RS_CMD_PositionSpeed() );
        registerSubcommand( RS_CMD_PositionPrerace() );
        registerSubcommand( RS_CMD_PositionPlayer() );
        registerSubcommand( RS_CMD_PositionCp() );
        registerSubcommand( RS_CMD_PositionSet() );
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( argc == 0 )
    	{
    		Entity @ent = @player.client.getEnt();
    		sendMessage( @player, "Current position:"
    			+ " " + ent.origin.x + " " + ent.origin.y + " " + ent.origin.z 
    			+ " " + ent.angles.x + " " + ent.angles.y + " " + ent.angles.z );
    		return true;
    	}

    	return RS_Command::execute( @player, args, argc );
    }
}


class RS_CMD_PositionSave : RS_Command
{
	RS_CMD_PositionSave()
	{
		name = "save";
    	description = "Save the current position";
    	usage = "position save\n";
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
		bool success = player.position.save();
        if( success )
            sendMessage( @player, "Position saved\n" );
        return success;
	}
}

class RS_CMD_PositionLoad : RS_Command
{
	RS_CMD_PositionLoad()
	{
		name = "load";
    	description = "Load the saved position";
    	usage = "position load\n";
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
		player.respawn();
		return true;
	}
}

class RS_CMD_PositionSpeed : RS_Command
{
	RS_CMD_PositionSpeed()
	{
		name = "speed";
    	description = "Set the speed for the saved position";
    	usage = "position speed <speed>\n" +
    			"    Set the absolute speed\n" +
    			"position speed (+|-)<speed>\n" +
    			"    Set the speed relative to your current speed";
	}

	bool validate( RS_Player @player, String &args, int argc )
	{
		if( argc != 1 )
		{
			sendErrorMessage( @player, "Invalid arguments\n");
			sendMessage( @player, getUsage() );
			return false;
		}
		return true;
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
		return player.position.saveSpeed( args.getToken( 0 ) );
	}
}

class RS_CMD_PositionPrerace : RS_Command
{
	RS_CMD_PositionPrerace()
	{
		name = "prerace";
    	description = "Set the prerace respawn position and inventory";
    	usage = "position prerace";
	}

	bool validate( RS_Player @player, String &args, int argc )
	{
		if( player.state != RS_STATE_PRERACE ||
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

		return true;
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
		bool success = player.positionPrerace.save();
        if( success )
            sendMessage( @player, "Position prerace saved\n" );
        return success;
	}
}

class RS_CMD_PositionPlayer : RS_Command
{
	RS_CMD_PositionPlayer()
	{
		name = "player";
    	description = "Teleport to a particular player";
    	usage = "position player (playerName|playerNum)\n";
	}

	bool validate( RS_Player @player, String &args, int argc )
	{
		if( player.client.team == TEAM_PLAYERS && player.state != RS_STATE_PRACTICE )
		{
			sendMessage( @player, "Position player may only be used in practicemode\n" );
			return false;				
		}

		if( argc != 1 )
		{
			sendErrorMessage( @player, "Invalid arguments\n");
			sendMessage( @player, getUsage() );
			return false;
		}

		return true;
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
		RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
		if( @target is null || @target.client is null )
		{
			sendErrorMessage( @player, "Matching player for " + args.getToken( 1 ) + " not found." );
			return false;
		}

		Entity @ent = @target.client.getEnt();
		return player.teleport( ent.origin, ent.angles, false, false, false );
	}
}

class RS_CMD_PositionCp : RS_Command
{
	RS_CMD_PositionCp()
	{
		name = "cp";
    	description = "Teleport to a particular checkpoint (id order may vary)";
    	usage = "position cp <id>\n";
	}

	bool validate( RS_Player @player, String &args, int argc )
	{
		if( player.client.team == TEAM_PLAYERS && player.state != RS_STATE_PRACTICE )
		{
			sendMessage( @player, "Position cp may only be used in practicemode\n" );
			return false;				
		}

		if( argc != 1 )
		{
			sendErrorMessage( @player, "Invalid arguments\n");
			sendMessage( @player, getUsage() );
			return false;
		}

		return true;
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
        int index = args.getToken( 0 ).toInt();
        for( int i = 0; i <= numEntities; i++ )
        {
            Entity @ent = @G_GetEntity( i );
            if( @ent != null && ent.count == index - 1 && ent.get_classname() == "target_checkpoint" )
                return player.teleport( ent.origin, ent.angles, false, false, false );
        }

        sendErrorMessage( @player, "Undefined checkpoint: " + index );
        return true;
	}
}

class RS_CMD_PositionSet : RS_Command
{
	RS_CMD_PositionSet()
	{
		name = "set";
    	description = "Teleport to a particular location";
    	usage = "position player <x> <y> <z> <pitch> <yaw>\n";
	}

	bool validate( RS_Player @player, String &args, int argc )
	{
		if( player.client.team == TEAM_PLAYERS && player.state != RS_STATE_PRACTICE )
		{
			sendMessage( @player, "Position set may only be used in practicemode\n" );
			return false;				
		}

		if( argc != 5 )
		{
			sendErrorMessage( @player, "Invalid arguments\n");
			sendMessage( @player, getUsage() );
			return false;
		}

		return true;
	}

	bool execute(RS_Player @player, String &args, int argc)
	{
		Vec3 origin, angles;
		origin.x = args.getToken( 1 ).toFloat();
		origin.y = args.getToken( 2 ).toFloat();
		origin.z = args.getToken( 3 ).toFloat();
		angles.x = args.getToken( 4 ).toFloat();
		angles.y = args.getToken( 5 ).toFloat();

		return player.teleport( origin, angles, false, false, false );
	}
}
