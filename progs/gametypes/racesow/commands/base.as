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
     * Container of all subcommands
     * @var Dictionary
     */
    Dictionary subcommands;

    /**
     * Container of all subcommands
     * @var RS_Command[]
     */
    RS_Command@[] subcommandsByIndex;

    /**
     * Number of registered subcommands
     * @var int
     */
	int subcommandCount;

    /**
     * Default constructor
     * Registers the command on instantiation. Use these as singletons.
     */
    RS_Command()
    {
    }

    /**
     * Register the command
     * @return void
     */
    void register()
    {
    	RS_CommandByName.set( name, @this );
    	@RS_CommandByIndex[RS_CommandCount++] = @this;
    }

    /**
     * Register a subcommand
     * @return  void
     */
    void registerSubcommand( RS_Command @cmd )
    {
        if( @cmd is null )
            return;

        subcommands.set( cmd.name, @cmd );
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
        RS_Command @cmd;

        if( subcommands.get( args.getToken( 0 ), @cmd ) )
        {
            String subArgs = args.substr( args.getToken( 0 ).len() + 1 );
            return cmd.validate( @player, subArgs, argc - 1 );
        }

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
        RS_Command @cmd;

        if( subcommands.get( args.getToken( 0 ), @cmd ) )
        {
            String subArgs = args.substr( args.getToken( 0 ).len() + 1 );
            return cmd.execute( @player, subArgs, argc - 1 );
        }

        return false;
    }

    /**
     * Return the command description in a nice way to be printed
     */
    String getDescription()
    {
        RS_Command @cmd;

        String cname = ( name.substr( 0, 2 ) == '__' ) ? name.substr( 2 ) : name;
        String message = S_COLOR_ORANGE + cname + ": " + S_COLOR_WHITE + this.description + "\n";

        for( int i = 0; i < subcommandCount; i++ )
        {
            @cmd = @subcommandsByIndex[i];
            message += "    " + cmd.getDescription();
        }

        return message;
    }

    /**
     * Return the command usage in a nice way to be printed
     */
    String getUsage()
    {
        RS_Command @cmd;

        String message = this.usage + "\n";
        for( int i = 0; i < subcommandCount; i++ )
        {
            @cmd = @subcommandsByIndex[i];
            message += cmd.getUsage() + "\n";
        }

        return message;
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