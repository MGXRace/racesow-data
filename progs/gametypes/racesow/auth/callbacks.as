const uint AUTH_STATUS_NONE = 0;
const uint AUTH_STATUS_PENDING = 1;
const uint AUTH_STATUS_FAILED = 2;
const uint AUTH_STATUS_SUCCESS = 3;

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
		player.auth.playerStatus = AUTH_STATUS_NONE;
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
	map.auth.pending = false;

	Json @node = @data.child;
	if( status == 200 )
	{
		RS_Race @record = @RS_Race();
		String name;
		while( @node !is null )
		{
			name = node.getName();

			if( name == "id" )
				map.auth.id = node.valueint;

			else if( name == "time" )
				record.endTime = node.valueint;

			else if( name == "checkpoints" )
				record.parseCheckpoints( @node.child );

			@node = @node.next;
		}

		if( record.getTime() > 0 )
			@map.record = @record;
	}
}