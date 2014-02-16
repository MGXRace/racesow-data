/**
 * weapondefs Command
 * Change the servers weapon definitions. Only enable for testing!
 */
class RS_CMD_WeaponDefs : RS_Command
{
	String[] cvarNames = {
		"g_gravity",
		"rs_grenade_minKnockback",
		"rs_grenade_maxKnockback",
		"rs_grenade_splash",
		"rs_grenade_speed",
		"rs_grenade_timeout",
		"rs_grenade_gravity",
		"rs_grenade_friction",
		"rs_grenade_prestep",
		"rs_gunblade_minKnockback",
		"rs_gunblade_maxKnockback",
		"rs_gunblade_splash",
		"rs_plasma_minKnockback",
		"rs_plasma_maxKnockback",
		"rs_plasma_splash",
		"rs_plasma_speed",
		"rs_plasma_prestep",
		"rs_plasma_hack",
		"rs_rocket_minKnockback",
		"rs_rocket_maxKnockback",
		"rs_rocket_splash",
		"rs_rocket_speed",
		"rs_rocket_prestep",
		"rs_rocket_antilag"
	};
	// Doesn't seem to be a clean way to do this
	// Values copied from g_racesow.cpp
	String[] defaults = {
		"850",	// "g_gravity",
		"5",	// "rs_grenade_minKnockback",
		"90",	// "rs_grenade_maxKnockback",
		"160",	// "rs_grenade_splash",
		"900",	// "rs_grenade_speed",
		"1250",	// "rs_grenade_timeout",
		"1.3",	// "rs_grenade_gravity",
		"0.85",	// "rs_grenade_friction",
		"90",	// "rs_grenade_prestep",
		"10",	// "rs_gunblade_minKnockback",
		"60",	// "rs_gunblade_maxKnockback",
		"80",	// "rs_gunblade_splash",
		"1",	// "rs_plasma_minKnockback",
		"20",	// "rs_plasma_maxKnockback",
		"45",	// "rs_plasma_splash",
		"2400",	// "rs_plasma_speed",
		"90",	// "rs_plasma_prestep",
		"0",	// "rs_plasma_hack",
		"10",	// "rs_rocket_minKnockback",
		"100",	// "rs_rocket_maxKnockback",
		"140",	// "rs_rocket_splash",
		"950",	// "rs_rocket_speed",
		"90",	// "rs_rocket_prestep",
		"0",	// "rs_rocket_antilag"
	};
	int numCvars = 24;


	RS_CMD_WeaponDefs()
	{
		name = "weapondefs";
    	description = "List or change the physics cvars\n";
    	usage = "list - list all cvars, values, and default values\n"
    		+ "set <cvar> <value> - Set a cvar to a specific value\n"
    		+ "reset <cvar> - Reset a specific cvar to its default value\n"
    		+ "reset - Reset all cvars to their default value\n";
    	register();
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	String message;
    	Cvar cvar;
        if( @player.client is null )
        	return false;

        // List all cvars we can change
        if( args.getToken( 0 ) == "list" )
        {
        	sendMessage( @player, S_COLOR_ORANGE + "cvar    " + S_COLOR_WHITE + "value    default\n" );
        	for( int i = 0; i < numCvars; i++ )
        	{
        		cvar = Cvar( cvarNames[i], defaults[i], CVAR_ARCHIVE );
        		message = S_COLOR_ORANGE + cvarNames[i] + "   "
        				+ S_COLOR_WHITE + cvar.get_string() + "   "
        				+ cvar.get_defaultString()  + "\n";
        		sendMessage( @player, message );
        	}
        	return true;
        }

        // Set a cvar if allowed
        else if( args.getToken( 0 ) == "set" &&	argc == 3 && 
        	args.getToken( 2 ).isNumeric() )
        {
        	int i = cvarIndex( args.getToken( 1 ) );
        	if( i == -1 )
        		return false;

        	cvar = Cvar( cvarNames[i], defaults[i], CVAR_ARCHIVE );
        	cvar.set( args.getToken( 2 ) );
        	return true;
        }

        // Reset a specific cvar
        else if( args.getToken( 0 ) == "reset" && argc == 1 )
        {
        	for( int i = 0; i < numCvars; i++ )
        		resetCvar( cvarNames[i], defaults[i] );
        }

        // Reset all cvars
        else if ( args.getToken( 0 ) == "reset" && argc == 2 )
        {
        	int i = cvarIndex( args.getToken( 1 ) );
        	if( i == -1 )
        		return false;

        	resetCvar( cvarNames[i], defaults[i] );
        	return true;	
        }

        return false;
    }

    int cvarIndex( String cvarName )
    {
    	for( int i = 0; i < numCvars; i++ )
    	{
    		if( cvarNames[i] == cvarName )
    			return i;
    	}
    	return -1;
    }

    void resetCvar( String cvarName, String cvarDefault )
    {
    	Cvar cvar = Cvar( cvarName, cvarDefault, CVAR_ARCHIVE );
    	cvar.set( cvarDefault );
    }
}