/**
 * __login Command
 * Login the user with his current login credentials
 */
class RS_CMD_Login : RS_Command
{
	RS_CMD_Login()
	{
		name = "__login";
    	description = "Login with your credentials";
    	usage = "login <username> <password>";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        // Usage is for clientside command, we actually get the args
        // <user> <token> <time>
        if( argc != 3 )
            return false;

        return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( @player.client is null )
    		return false;

        player.auth.login( args.getToken( 0 ), args.getToken( 1 ), args.getToken( 2 ).toInt() );
		return true;
    }
}