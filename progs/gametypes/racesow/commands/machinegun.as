/**
 * machinegun Command
 * Give the player the machinegun
 */
class RS_CMD_Machinegun : RS_Command
{
	RS_CMD_Machinegun()
	{
		name = "machinegun";
    	description = "Gives yuo a machinegun";
    	usage = "";
    	register();
	}

	// TODO: Should we autoswitch to machinegun?
	// its not that hard to `bind x "machinegun; wait; weapselect mg" `
    bool execute(RS_Player @player, String &args, int argc)
    {
    	player.client.inventoryGiveItem( WEAP_MACHINEGUN );
    	// player.client.selectWeapon( WEAP_MACHINEGUN );
    	return true;
    }
}