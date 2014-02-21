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
	 * True if the player is authenticated
	 * @var bool
	 */
	bool authenticated;

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
	 * True if we have a pending request
	 * @var bool
	 */
	bool pending;

	/**
	 * Base constructor
	 * @return void
	 */
	RS_PlayerAuth( RS_Player @player )
	{
		@this.player = @player;
		authenticated = false;
		pending = false;
		thinkTime = 0;
	}

	/**
	 * Try to authenticate the player
	 * @return void
	 */
	void Think()
	{
		if( authenticated || pending || thinkTime > realTime )
			return;

		if( authTime == 0 || authTime + 10000 < realTime )
		{
			sendMessage( @player, "Generating token\n" );
			// Regenerate the token every 10 seconds
			authTime = realTime;
			player.client.execGameCommand( "utoken \"" + authTime + "\"" );
		}

		else if( authTime + 1000 < realTime )
		{
			thinkTime = realTime + 1000;
			String authUser = player.client.getUserInfoKey( "rs_authUser" );
			String authToken = player.client.getUserInfoKey( "rs_authToken" );

			sendMessage( @player, "Validating token" + authUser + " " + authToken + "\n" );
			if( authUser.empty() || authToken.empty() )
			{
				return;
			}

			pending = true;
			RS_AuthPlayer( authUser, authToken, authTime );
		}
	}
}