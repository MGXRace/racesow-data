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
	 * Player id
	 * @var uint
	 */
	uint id;

	/**
	 * Player's username
	 * @var String
	 */
	String user;

	/**
	 * Status of the player auth query
	 * @var uint
	 */
	uint playerStatus;

	/**
	 * Is the user a superuser?
	 * @var bool
	 */
	bool admin;

	/**
	 * Users authentication nickname
	 * @var String
	 */
	String nick;

	/**
	 * Status of the protected nick query
	 * @var bool
	 */
	uint nickStatus;

	/**
	 * True if the player is using protected nickname
	 * @var bool
	 */
	bool nickProtected;

	/**
	 * realTime for next think
	 * @var uint
	 */
	uint thinkTime;

	/**
	 * realTime when the kick countdown begins
	 * @var uint
	 */
	uint failTime;

	/**
	 * Points the player has on the map
	 * @var int
	 */
	int points;

	/**
	 * Base constructor
	 * @return void
	 */
	RS_PlayerAuth( RS_Player @player )
	{
		@this.player = @player;
		QueryNick();

		// Ask the client to auto-login
		player.client.execGameCommand( "slogin" );
	}

	/**
	 * Try to authenticate the player
	 * @return void
	 */
	void Think()
	{
		// Protected nick countdown
		if( thinkTime != 0 && thinkTime < realTime && failTime != 0 && nickStatus != AUTH_STATUS_PENDING )
		{
			int remaining = ( 15500 - int(realTime) + int(failTime) ) / 1000;

			// Out of time, rename them
			if( remaining < 1 )
			{
				failTime = 0;
				thinkTime = 0;
				RS_RenameClient( player.client, "player" );
				return;
			}

			// Send a message and set the next think time
			sendMessage( @player, S_COLOR_ORANGE + "Warning: " + player.client.get_name() + S_COLOR_WHITE + " is protected, change your name or login within " + remaining + " seconds.\n" );
			if( remaining > 5 )
				thinkTime = realTime + 5000;
			else
				thinkTime = realTime + 1000;
		}
	}

	/**
	 * Check if the player changed any important userinfo variables and reauth as needed
	 */
	void UserInfoChanged( String oldnick )
	{
		// User changed name
		String simpleNick = oldnick.removeColorTokens().tolower();
		if( simpleNick != player.simpleNick() )
		{
			resetNick();
			QueryNick();
		}
	}

	/**
	 * Try to register the player
	 * @return void
	 */
	void registerPlayer( String user, String token, String email )
	{
		resetPlayer();
		this.user = user;
		playerStatus = AUTH_STATUS_PENDING;
		RS_AuthRegister( @player.client, user, token, email, player.client.get_name() );
	}

	/**
	 * Make the login query
	 * @return void
	 */
	void QueryPlayer( String user, String token, int uTime )
	{
		resetPlayer();
		this.user = user;
		playerStatus = AUTH_STATUS_PENDING;
		RS_AuthPlayer( @player.client, user, token, uTime, map.auth.id );
	}

	/**
	 * Parse the server response
	 * @param Json data The response data
	 */
	void parsePlayer( Json @data )
	{
		// Parse a valid response
		RS_Race @race = @RS_Race();
		Json @node;

		// TODO: Handle malformed queries
		// Really wish we had try/catch blocks :S
		@node = data.getItem("name");
		nick = node.getString();

		// Check if we authorized the protected nick
		String simpleNick = nick.removeColorTokens().tolower();
		if( nickProtected && simpleNick != player.simpleNick() )
		{
			// Still not authorized
			failTime = failTime == 0 ? realTime : failTime;
			thinkTime = thinkTime == 0 ? realTime : thinkTime;
			nickStatus = AUTH_STATUS_FAILED;
		}
		else if( nickProtected )
		{
			// Authorized
			failTime = 0;
			nickStatus = AUTH_STATUS_SUCCESS;
		}

		@node = data.getItem("id");
		id = node.valueint;

		@node = data.getItem("admin");
		admin = node.type == cJSON_True;

		@node = data.getItem("record");
		if( @node !is null && node.type == cJSON_Object )
		{
			RS_Race @record = @RS_Race( node );
			@player.record = @record;
			points = node.getItem( "points" ).valueint;
		}

		// De-Authenticate any other players logged in with the same user
		RS_Player @other;
		for( int i = 0; i < maxClients; i++ )
		{
			@other = players[i];
			if( @other is null || @other is @player || other.auth.id != id )
				continue;

			sendMessage( @other, "You have been logged out\n" );
			other.auth.resetPlayer();
			other.auth.playerStatus = AUTH_STATUS_FAILED;
		}

		playerStatus = AUTH_STATUS_SUCCESS;
		sendMessage( @player, "Authenticated as: " + id + " " + user + "\n" );
		if( admin )
			sendMessage( @player, "Authenticated with admin powers.\n" );
	}

	/**
	 * Reset the player's auth state
	 * @return void
	 */
	void resetPlayer()
	{
		id = 0;
		playerStatus = AUTH_STATUS_NONE;
		user = "";
		nick = "";

		// Set the nick protection again if necessary
		if( nickProtected )
		{
			failTime = failTime == 0 ? realTime : failTime;
			thinkTime = thinkTime == 0 ? realTime : thinkTime;
			nickStatus = AUTH_STATUS_FAILED;
		}
	}

	/**
	 * Query if the player is using a protected nick
	 * @return void
	 */
	void QueryNick()
	{
		nickStatus = AUTH_STATUS_PENDING;
		RS_AuthNick( player.client, player.simpleNick() );
	}

	/**
	 * Parse the server response
	 * @param data The server response data
	 * @return void
	 */
	void parseNick( Json @data )
	{
		// Malformed response, give them benefit of the doubt
		if( data.type != cJSON_Object )
		{
			nickProtected = false;
			nickStatus = AUTH_STATUS_SUCCESS;
			return;
		}

		Json @node = @data.child;
		String protectedNick = node.getName();
		String simpleNick = protectedNick.removeColorTokens().tolower();
		nickProtected = node.type == cJSON_True ? true : false;

		// player changed name since the request, ignore this and wait for that response
		if( simpleNick != player.simpleNick() )
		{
			nickProtected = false;
			nickStatus = AUTH_STATUS_NONE;
			return;
		}

		// Not authorized to use this nickname
		if( nickProtected && simpleNick != nick )
		{
			failTime = failTime == 0 ? realTime : failTime;
			thinkTime = thinkTime == 0 ? realTime : thinkTime;
			nickStatus = AUTH_STATUS_FAILED;
			return;
		}

		// Authorized to use the nickname
		failTime = 0;
		thinkTime = 0;
		nickStatus = AUTH_STATUS_SUCCESS;
	}

	/**
	 * Reset protected nick variables
	 * @return void
	 */
	void resetNick()
	{
		nickProtected = false;
		nickStatus = AUTH_STATUS_NONE;
	}
}