const uint AUTH_STATUS_NONE = 0;
const uint AUTH_STATUS_PENDING = 1;
const uint AUTH_STATUS_FAILED = 2;
const uint AUTH_STATUS_SUCCESS = 3;
const uint AUTH_STATUS_REGISTER = 4;

/**
 * Callback for register auth
 */
void RS_AuthRegister_Done( int status, Client @client, Json @data )
{
	RS_Player @player = RS_getPlayer( @client );
	if( @player is null )
		return;

	if( status == 200 )
	{
		// Success, try to login
		player.auth.parsePlayer( @data );
	}
	else
	{
		// Failure, reset and notify the player
		player.auth.resetPlayer();
		player.auth.playerStatus = AUTH_STATUS_FAILED;
		sendErrorMessage( @player, "Failed to register as " + player.auth.user );
		if( @data !is null )
		{
			Json @node = data.getItem("error");
			sendErrorMessage( @player, node.getString() );
		}
	}
}

/**
 * Callback for player auth
 */
void RS_AuthPlayer_Done( int status, Client @client, Json @data )
{
	RS_Player @player = RS_getPlayer( @client );
	if( @player is null )
		return;

	if( status == 200 )
		player.auth.parsePlayer( @data );
	else
	{
		player.auth.resetPlayer();
		player.auth.playerStatus = AUTH_STATUS_FAILED;
		sendErrorMessage( @player, "Failed to authenticate as " + player.auth.user );
	}
}

/**
 * Callback for player auth
 */
void RS_AuthNick_Done( int status, Client @client, Json @data )
{
	RS_Player @player = RS_getPlayer( @client );
	if( @player is null )
		return;

	if( status == 200 )
		player.auth.parseNick( @data );
	else
	{
		player.auth.resetNick();
		player.auth.nickStatus = AUTH_STATUS_NONE;
	}
}

/**
 * Callback for Map data
 */
void RS_AuthMap_Done( int status, Json @data )
{
	if( status != 200 )
	{
		map.auth.Failed();
		return;
	}

	Json @node;

	@node = data.getItem("id");
	if( @node is null && node.type != cJSON_NULL )
	{
		map.auth.Failed();
		return;
	}
	map.auth.id = node.valueint;

	@node = data.getItem("record");
	if( @node !is null && node.type != cJSON_NULL )
		@map.record = @RS_Race( node );

	map.auth.status = AUTH_STATUS_SUCCESS;
}

/**
 * Callback for race reporting
 */
void RS_ReportRace_Done( int status, Client @client, Json @data )
{
	RS_Player @player = RS_getPlayer( @client );
	if( @player is null || @data is null || data.type != cJSON_Object )
		return;

	if( status != 200 )
	{
		sendErrorMessage( @player, "Race could not be saved");
		if( @data !is null )
			sendErrorMessage( @player, data.getItem( "error" ).getString() );
	}

	// update points
	int points = data.getItem( "points" ).valueint;
	if( points > player.auth.points )
	{
		sendMessage( @player, "You earned " + ( points - player.auth.points ) + " points!" );
		player.auth.points = points;
	}
}