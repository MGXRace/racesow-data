class RS_CMD_NoClip : RS_Command
{
    RS_CMD_NoClip()
    {
        name = "noclip";
        description = "Disable your interaction with other players and objects";
        usage = "";
        register();
    }

    bool validate( RS_Player @player, String &args, int argc )
    {
        if( @player.client.getEnt() is null || player.client.getEnt().team != TEAM_PLAYERS || !player.practicing )
        {
            sendErrorMessage( @player, "Noclip is not available in your current state");
            return false;
        }

        return true;
    }

    bool execute( RS_Player @player, String &args, int argc )
    {
        return player.noclip();
    }
}