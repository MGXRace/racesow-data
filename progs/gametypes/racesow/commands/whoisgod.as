/**
 * whoisgod Command
 */
class RS_CMD_WhoIsGod : RS_Command
{
    String[] devs = { "R2", "Zaran", "Zolex", "Schaaf", "K1ll", "Weqo", "Jerm's", "Hettoo" };

	RS_CMD_WhoIsGod()
	{
		name = "whoisgod";
    	description = "Well?";
    	usage = "";
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	int index;
        index = int( brandom( 0, devs.length() ) );
        sendMessage( @player, devs[index] + "\n" );
    	return true;
    }
}