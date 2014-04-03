/**
 * register Command
 * Register the user with his current login credentials
 */
class RS_CMD_Register : RS_Command
{
	RS_CMD_Register()
	{
		name = "__register";
    	description = "Register your login credentials";
    	usage = "register <username> <password> <email>";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( argc != 3 )
            return false;

        if( player.auth.playerStatus == AUTH_STATUS_PENDING )
        {
            sendErrorMessage( @player, "Please wait for your current auth query to finish" );
            return false;
        }

        return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( @player.client is null )
    		return false;

        player.auth.registerPlayer( args.getToken( 0 ), args.getToken( 1 ), args.getToken( 2 ) );
        return true;
    }
}