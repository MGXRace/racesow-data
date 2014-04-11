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
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( @player is null || @player.client is null )
            return false;

        G_Print( "Admin is " + ( player.auth.admin ? 1 : 0 ) + "\n" );
        if( !player.auth.admin )
        {
            sendErrorMessage( @player, "You are not an admin" );
            return false;
        }

        return RS_Command::validate( @player, args, argc );
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