/**
 * help Command
 * Display a help message for a command
 */
class RS_CMD_Help : RS_Command
{
	RS_CMD_Help()
	{
		name = "help";
    	description = "Print this help, or give help on a specific command";
    	usage = "help <command>";
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
        if ( argc >= 1 )
        {
            RS_Command@ command;
            if ( RS_CommandByName.get( args.getToken(0), @command ) )
            {
                sendMessage( @player, command.getDescription() + command.getUsage() );
                return true;
            }
            else
            {
                sendErrorMessage( @player, "Command " + S_COLOR_YELLOW + args.getToken(0) + S_COLOR_WHITE + " not found" );
                return true;
            }
        }
        else
        {
            String help;
            help += S_COLOR_BLACK + "--------------------------------------------------------------------------------------------------------------------------\n";
            help += S_COLOR_RED + "HELP for Racesow " + gametype.version + "\n";
            help += S_COLOR_BLACK + "--------------------------------------------------------------------------------------------------------------------------\n";
            sendMessage( @player, help );
            help = "";

            for (int i = 0; i < RS_CommandCount; i++)
            {
                RS_Command@ command = RS_CommandByIndex[i];

                help += command.getDescription();
                if ( (i/5)*5 == i ) //to avoid print buffer overflow
                {
                    sendMessage( @player, help );
                    help = "";
                }
            }

            sendMessage( @player, help);
            sendMessage( @player, S_COLOR_BLACK + "--------------------------------------------------------------------------------------------------------------------------\n\n" );
            return true;
        }
    }
}