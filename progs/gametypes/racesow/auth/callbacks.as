/**
 * Callback for player auth
 */
void RS_AuthPlayer_Done( int status, Json @data )
{
	G_PrintMsg( null, "Status: " + status + "\n" );
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
			{
				G_Print( "Map Id: " + node.valueint + "\n" );
				map.auth.id = node.valueint;
			}
			else if( name == "time" )
			{
				G_Print( "Map Time: " + node.valueint + "\n" );
				record.endTime = node.valueint;
			}
			else if( name == "checkpoints" )
			{
				Json @cpNode = @node.child;
				while( @cpNode !is null )
				{
					int num = cpNode.getName().toInt();
					uint time = uint(cpNode.valueint);
					G_Print( "Checkpoint " + num + " " + time + "\n" );

					if( num < numCheckpoints )
						record.checkpoints[num] = time;

					@cpNode = @cpNode.next;
				}
			}

			@node = @node.next;
		}

		if( record.endTime > 0 )
			@map.record = @record;
	}
}