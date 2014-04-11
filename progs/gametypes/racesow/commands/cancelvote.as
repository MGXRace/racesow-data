/**
 * cancelvote Command
 */
class RS_CMD_Cancelvote : RS_Command
{
	RS_CMD_Cancelvote()
	{
		name = "cancelvote";
    	description = "Cancel the current vote if you called it or are an admin";
    	usage = "cancelvote\n";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
		return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( @player is null )
            return false;

        RS_Cancelvote( player.client.getEnt(), player.auth.admin );
    	return true;
    }
}