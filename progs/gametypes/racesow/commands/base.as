/**
 * Total number of commands
 */
int RS_CommandCount = 0;

/**
 * Total number of allowed commands
 * There is a limitation in C that prevents this from ever being reached
 */
int RS_MaxCommands = 50;

/**
 * Container for all the commands
 */
Dictionary RS_CommandByName;

/**
 * Array container for all commands
 */
RS_Command@[] RS_CommandByIndex( RS_MaxCommands );

/**
 * Generic command class, all commands inherit from this class
 * and should override the validate and execute function
 */
class RS_Command
{

    /**
     * The name of the command.
     * That's what the user will have to type to call the command
     * @var String
     */
    String name;

    /**
     * Description of what the command does.
     * This is displayed in the help
     * @var String
     */
    String description;

    /**
     * Usage of the command. This should document the command syntax.
     * Displayed when you do "help <command>" and also when you make an error
     * with the command syntax (e.g wrong number of arguments).
     * When describing the syntax, put the arguments name into brackets (e.g <mapname>)
     * @var String
     */
    String usage;
	
    /**
     * Default constructor
     */
    RS_Command()
    {
    }

    /**
     * This is called before the actual work is done.
     *
     * Here you should only check the number of arguments and that
     * the player has the right to call the command
     *
     * @param player The player who calls the command
     * @param args The tokenized string of arguments
     * @param argc The number of arguments
     * @return success boolean
     */
    bool validate(RS_Player @player, String &args, int argc)
    {
        return true;
    }

    /**
     * This is called after the validate function.
     *
     * Technically no validation should be done here, only the real work.
     * Most probably a call to a player method.
     * @param player The player who calls the command
     * @param args The tokenized string of arguments
     * @param argc The number of arguments
     * @return success boolean
     */
    bool execute(RS_Player @player, String &args, int argc)
    {
        return true;
    }

    /**
     * Return the command description in a nice way to be printed
     */
    String getDescription()
    {
        return S_COLOR_ORANGE + this.name + ": " + S_COLOR_WHITE + this.description + "\n";
    }

    /**
     * Return the command usage in a nice way to be printed
     */
    String getUsage()
    {
        if ( this.usage.len() > 0 )
            return S_COLOR_ORANGE + "Usage: " + S_COLOR_WHITE + this.usage + "\n";
        else
            return "";
    }
}

/**
 * RS_InitCommands
 * Register all loaded commands
 * @return void
 */
void RS_InitCommands()
{
	for( int i = 0; i < RS_CommandCount; i++ )
		G_RegisterCommand( RS_CommandByIndex[i].name );
}