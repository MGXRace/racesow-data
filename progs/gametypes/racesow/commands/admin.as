/**
 * Admin command
 */
class RS_CMD_Admin : RS_Command
{
	RS_CMD_Admin()
	{
		name = "admin";
    	description = "Perform an admin action, type 'help admin' for more info";
    	usage = "";

        registerSubcommand( RS_CMD_AdminMap() );
        registerSubcommand( RS_CMD_AdminMaplistUpdate() );
        registerSubcommand( RS_CMD_AdminRestart() );
        registerSubcommand( RS_CMD_AdminMute() );
        registerSubcommand( RS_CMD_AdminUnmute() );
        registerSubcommand( RS_CMD_AdminVmute() );
        registerSubcommand( RS_CMD_AdminVunmute() );
        registerSubcommand( RS_CMD_AdminKick() );
        registerSubcommand( RS_CMD_AdminKickban() );
        registerSubcommand( RS_CMD_AdminIp() );
        registerSubcommand( RS_CMD_AdminRemove() );
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( @player is null || @player.client is null )
            return false;

        if( !player.auth.admin )
        {
            sendErrorMessage( @player, "You are not an admin" );
            return false;
        }

        return RS_Command::validate( @player, args, argc );
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( RS_Command::execute( player, args, argc ) )
        {
            G_PrintMsg( null, S_COLOR_WHITE + player.client.get_name() + S_COLOR_GREEN
                        + " executed command '" + args + "'\n" );
            return true;
        }

        return false;
    }
}

class RS_CMD_AdminMap : RS_Command
{
    RS_CMD_AdminMap()
    {
        name = "map";
        description = "Change to the given map";
        usage = "admin map <mapname>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        G_CmdExecute( "gamemap " + args.getToken( 0 ) + "\n" );
        return true;
    }
}

class RS_CMD_AdminMaplistUpdate : RS_Command
{
    RS_CMD_AdminMaplistUpdate()
    {
        name = "updateml";
        description = "Update the maplist";
        usage = "admin updateml";
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_UpdateMaplist();
        return true;
    }
}

class RS_CMD_AdminRestart : RS_Command
{
    RS_CMD_AdminRestart()
    {
        name = "restart";
        description = "Restart the match";
        usage = "admin restart";
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        G_CmdExecute( "match restart\n" );
        return true;
    }
}

class RS_CMD_AdminMute : RS_Command
{
    RS_CMD_AdminMute()
    {
        name = "mute";
        description = "Mute a player";
        usage = "admin mute <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        target.client.muted |= 1;
        return true;
    }
}

class RS_CMD_AdminUnmute : RS_Command
{
    RS_CMD_AdminUnmute()
    {
        name = "unmute";
        description = "Unmute a player";
        usage = "admin unmute <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        target.client.muted &= ~1;
        return true;
    }
}

class RS_CMD_AdminVmute : RS_Command
{
    RS_CMD_AdminVmute()
    {
        name = "vmute";
        description = "Voice and vote mute a player";
        usage = "admin vmute <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        target.client.muted |= 2;
        return true;
    }
}

class RS_CMD_AdminVunmute : RS_Command
{
    RS_CMD_AdminVunmute()
    {
        name = "vunmute";
        description = "Voice and Vote unmute a player";
        usage = "admin vunmute <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        target.client.muted &= ~2;
        return true;
    }
}

class RS_CMD_AdminKick : RS_Command
{
    RS_CMD_AdminKick()
    {
        name = "kick";
        description = "Kick a player";
        usage = "admin kick <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        G_CmdExecute( "kick " + target.client.playerNum );
        return true;
    }
}

class RS_CMD_AdminKickban : RS_Command
{
    RS_CMD_AdminKickban()
    {
        name = "kickban";
        description = "Kickban a player";
        usage = "admin kickban <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        String ip = target.client.getUserInfoKey( "ip" );
        G_CmdExecute( "addip " + ip + " 15;kick " + target.client.playerNum );
        return true;
    }
}

class RS_CMD_AdminIp : RS_Command
{
    RS_CMD_AdminIp()
    {
        name = "ip";
        description = "Show a players ip address";
        usage = "admin ip <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        String ip = target.client.getUserInfoKey( "ip" );
        sendMessage( @player, target.client.get_name() + S_COLOR_WHITE + " " + ip + "\n" );
        return false;
    }
}

class RS_CMD_AdminRemove : RS_Command
{
    RS_CMD_AdminRemove()
    {
        name = "remove";
        description = "Force a player to spectators";
        usage = "admin remove <player>";
    }

    bool validate(RS_Player @player, String &args, int argc)
    {
        if( argc == 1 )
            return true;

        return false;
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );
        if( @target is null || target.auth.admin )
            return false;

        target.client.team = TEAM_SPECTATOR;
        target.client.respawn( true );
        return false;
    }
}
