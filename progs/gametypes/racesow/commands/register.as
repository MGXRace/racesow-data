/**
 * register Command
 * Register the user with his current login credentials
 */
class RS_CMD_Register : RS_Command
{
	RS_CMD_Register()
	{
		name = "register";
    	description = "Register your login credentials";
    	usage = "register <email>";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
        if( player.auth.id != 0 )
        {
            sendErrorMessage( @player, "You are already authenticated" );
            return false;
        }

        if( argc < 1 )
        {
            sendErrorMessage( @player, "You must provide a valid email address" );
            return false;
        }

        if( player.auth.user.empty() )
        {
            sendErrorMessage( @player, "Please set your credentials with `login <user> <pass>` first" );
            return false;
        }

        if( player.auth.playerStatus == AUTH_STATUS_PENDING || player.auth.playerStatus == AUTH_STATUS_REGISTER )
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

        player.client.execGameCommand( "utoken \"REGISTER\"" );
        player.auth.playerStatus = AUTH_STATUS_REGISTER;
		return true;
    }
}