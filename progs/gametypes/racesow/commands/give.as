/**
 * give Command
 * Give the player some inventory
 */
class RS_CMD_Give : RS_Command
{
	RS_CMD_Give()
	{
		name = "give";
    	description = "Give some weapons or items to the player";
    	usage = "give all - Give all items (including instagun)\n"
    		+ "give <item> - Give an item with a given name";
    	register();
	}

	bool validate(RS_Player @player, String &args, int argc)
	{
		if( player.state != RS_STATE_PRACTICE )
		{
			sendErrorMessage( @player, "give is only available in practicemode" );
			return false;
		}

		return true;
	}

    bool execute(RS_Player @player, String &args, int argc)
    {
    	if( args.getToken( 0 ) == "all" )
    	{
    		for( int i = 0; i < AMMO_TOTAL; i++ )
    		{
	    		Item @item = @G_GetItem( i );
	    		if( @item is null || !item.isPickable() )
	    			continue;

    			player.client.inventoryGiveItem( i );
    		}
    		return true;
    	}
    	else
    	{
    		Item @item = @G_GetItemByName( args.getToken( 0 ) );
    		if( @item is null || !item.isPickable() )
    		{
    			sendErrorMessage( @player, "No item matching " + args.getToken( 0 ) + " found" );
    			String items = "";
    			for( int i = 0; i < AMMO_TOTAL; i++ )
    			{
    				@item = @G_GetItem( i );
    				if( @item is null || !item.isPickable() )
    					continue;

    				items += " " + item.get_shortName();
    			}
    			sendErrorMessage( @player, "Available items are:" + items );
    			return false;
    		}
    		player.client.inventoryGiveItem( item.tag );
    	}

    	return false;
    }
}
