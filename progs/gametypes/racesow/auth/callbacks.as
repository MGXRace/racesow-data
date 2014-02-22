/**
 * Callback for player auth
 */
void RS_AuthPlayer_Done( int status, Client @client, Json @data )
{	
	if( @client is null )
		return;

	RS_Player @player = RS_getPlayer( @client );
	if( @player is null )
		return;

	player.auth.pending = false;
	if( status == 200 )
		player.auth.parseAuth( @data );
	else
		player.auth.resetAuth();
}

/**
 * Callback for player auth
 */
void RS_AuthNick_Done( int status, Client @client, Json @data )
{
	if( @client is null )
		return;

	RS_Player @player = RS_getPlayer( @client );
	if( @player is null )
		return;

	player.auth.pending = false;
	if( status == 200 )
		player.auth.parseNick( @data );
	else
		player.auth.resetNick();
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