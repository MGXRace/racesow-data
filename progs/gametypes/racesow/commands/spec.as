class RS_CMD_Spec : RS_Command
{
    RS_CMD_Spec()
    {
        name = "spec";
        description = "Move to spectators";
        usage = "spec";
        register();
    }

    bool execute(RS_Player @player, String &args, int argc)
    {
        if( @player is null )
            return false;

        player.client.team = TEAM_SPECTATOR;
        player.client.respawn( true );
        return true;
    }
}