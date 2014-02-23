/**
 * Racesow Player Auth Model
 *
 * @package Racesow
 * @version 1.1.0
 */
class RS_PlayerAuth
{
	/**
	 * Player associated with the auth
	 * @var RS_Player
	 */
	RS_Player @player;

	/**
	 * True if the authentication query was successful
	 * May be true even if the player failed to authenticate
	 * Use `id > 0` to check for succesful authentication
	 * @var bool
	 */
	bool authenticated;

	/**
	 * True if we have a pending request
	 * @var bool
	 */
	bool pending;

	/**
	 * Users authentication username
	 * @var String
	 */
	String user;

	/**
	 * Users authentication nickname
	 * @var String
	 */
	String authNick;

	/**
	 * Nickname at last QueryNick call
	 * @var string
	 */
	String nick;

	/**
	 * True if the nick query was successful
	 * May be true even if the player is nick faking
	 * use `failTime == 0 && nickAuthenticated` to test if the nick is valid
	 * @var bool
	 */
	bool nickAuthenticated;

	/**
	 * Player id
	 * @var uint
	 */
	uint id;

	/**
	 * realTime used to generate tokens
	 * TODO: use UNIX timestamp
	 * @var uint
	 */
	uint authTime;

	/**
	 * realTime for next think
	 * @var uint
	 */
	uint thinkTime;

	/**
	 * realTime when the kick countdown beings
	 * @var uint
	 */
	uint failTime;

	/**
	 * Base constructor
	 * @return void
	 */
	RS_PlayerAuth( RS_Player @player )
	{
		@this.player = @player;
		resetAuth();
	}

	/**
	 * Try to authenticate the player
	 * @return void
	 */
	void Think()
	{
		if( thinkTime > realTime || map.auth.id == 0 )
			return;

		if( !authenticated )
			QueryPlayer();

		if( !nickAuthenticated )
			QueryNick();

		if( failTime != 0 )
		{
			// Fakenick kick countdown
			if( nick.tolower() == authNick.tolower() )
			{
				failTime = 0;
				return;
			}
			int remaining = 30 - ( ( int(realTime) - int(failTime) ) / 1000 );

			if( remaining < 1 )
			{
				failTime = 0;
				RS_RenameClient( player.client, "player" );
			}
			else
			{
				sendMessage( @player, S_COLOR_ORANGE + "Warning: " + nick + S_COLOR_WHITE + " is protected, change your name or auth within " + remaining + " seconds.\n" );
				thinkTime = realTime + 1000;
			}
		}
	}

	/**
	 * Check if the player changed any important userinfo variables and reauth as needed
	 */
	void UserInfoChanged()
	{
		if( user != player.client.getUserInfoKey( "rs_authUser" ) )
		{
			resetAuth();
			return;
		}

		if( player.client.get_name().removeColorTokens().tolower() != nick.tolower() )
			resetNick();
	}

	void QueryPlayer()
	{
		if( pending )
			return;

		if( authTime == 0 || authTime + 10000 < realTime )
		{
			// Regenerate the token every 10 seconds
			authTime = realTime;
			thinkTime = realTime + 1000;
			player.client.execGameCommand( "utoken \"" + authTime + "\"" );
			return;
		}

		thinkTime = realTime + 500;
		user = player.client.getUserInfoKey( "rs_authUser" );
		String authToken = player.client.getUserInfoKey( "rs_authToken" );

		if( user.empty() || authToken.empty() )
		{
			id = 0;
			authenticated = true;
			sendErrorMessage( @player, "You are not authenticated. Login with 'rs_login <user> <pass>'" );
		}
		
		pending = true;
		RS_AuthPlayer( @player.client, user, authToken, authTime, map.auth.id );
	}

	/**
	 * Parse the server response
	 * @param Json data The response data
	 */
	void parseAuth( Json @data )
	{
		authenticated = true;

		if( data.type == cJSON_Object )
		{
			// Parse a valid response
			RS_Race @race = @RS_Race();
			Json @node = @data.child;
			String name;

			while( @node !is null )
			{
				G_Print( "ParseNode " + node.getName() + " " + node.getString() + "\n" );
				name = node.getName();
				if( name == "nick")
					authNick = node.getString();

				if( name == "id")
					id = node.valueint;

				if( name == "checkpoints" )
					race.parseCheckpoints( @node.child );

				if( name == "time" )
					race.endTime = node.valueint;

				@node = @node.next;
			}

			if( race.getTime() != 0 )
				@player.recordRace = @race;

			sendMessage( @player, "Authenticated as " + user + "\n" );
		}
		else
		{
			// Player failed to authenticate
			id = 0;
			sendErrorMessage( @player, "Failed to authenticate as " + user );
		}
	}

	/**
	 * Parse the server response
	 * @param Json data The response data
	 */
	void resetAuth()
	{
		id = 0;
		authenticated = false;
		thinkTime = 0;
		user = "";
		authNick = "";
		resetNick();
	}

	void QueryNick()
	{
		if( pending )
			return;

		thinkTime = realTime + 500;
		pending = true;
		nick = player.client.get_name().removeColorTokens();
		RS_AuthNick( player.client, nick );
	}

	void parseNick( Json @data )
	{
		// Player changed name before the callback appeared
		if( nick != player.client.get_name().removeColorTokens() )
			return;

		nickAuthenticated = true;
		if( data.type == cJSON_True )
			failTime = realTime;
	}

	void resetNick()
	{
		thinkTime = realTime + 500;
		nick = "";
		nickAuthenticated = false;
	}
}