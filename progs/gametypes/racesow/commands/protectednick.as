/**
 * protectednick Command
 * Updates the players protected nick
 */
class RS_CMD_ProtectedNick : RS_Command
{
	RS_CMD_ProtectedNick()
	{
		name = "protectednick";
    	description = "Update your protected nickname";
    	usage = "protectednick";
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( @player.client is null )
        	return false;

        if( argc == 0 )
            player.auth.setNick( player.client.get_name() );
        else
            player.auth.setNick( args );

        return true;
    }
}
