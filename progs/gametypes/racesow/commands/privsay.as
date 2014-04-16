// TODO: read these from normal chat cvars
const uint PRIVSAY_FLOODCOUNT = 4;
const uint PRIVSAY_FLOODTIME = 5000;

/**
 * privsay Command
 * Send a message to a player.
 */
class RS_CMD_Privsay : RS_Command
{
    RS_CMD_Privsay()
    {
        name = "privsay";
        description = "Send a private message to a player";
        usage = "privsay < playerid | playername >";
        register();
    }

    bool validate( RS_Player @player, String &args, int argc )
    {
        if( player.client.muted == 1 )
        {
            sendErrorMessage( @player, "You can't talk, you're muted" );
            return false;
        }

        if( argc < 2 )
        {
            sendErrorMessage( @player, "You must provide a player id and a message" );
            return false;
        }

        if( player.privsayCount == PRIVSAY_FLOODCOUNT &&
            player.privsayTimes[0] + PRIVSAY_FLOODTIME > realTime )
        {
            uint waitTime = ( PRIVSAY_FLOODTIME + player.privsayTimes[0] - realTime ) / 1000;
            sendErrorMessage( @player, "Flood proctection, wait " + waitTime + " seconds." );
            return false;
        }

        return true;
    }

    bool execute( RS_Player @player, String &args, int argc )
    {
        RS_Player @target = @RS_getPlayerFromArgs( args.getToken( 0 ) );

        if( @target is null || !target.client.getEnt().inuse )
        {
            sendErrorMessage( @player, "Invalid player" );
            return false;
        }

        // Increment the floodcount timer
        if( player.privsayCount == PRIVSAY_FLOODCOUNT )
        {
            for( int i = 1; i < PRIVSAY_FLOODCOUNT; i++ )
                player.privsayTimes[i-1] = player.privsayTimes[i];

            player.privsayTimes[PRIVSAY_FLOODCOUNT-1] = realTime;
        }
        else
            player.privsayTimes[player.privsayCount++] = realTime;

        // Send the message to the player
        String message = " \"" + args.substr( args.getToken( 0 ).length() + 1, args.len() ).replace( "\"", "\'" ) + "\"";
        String cmd = "pch 0 " + target.client.getEnt().get_entNum() + message;
        player.client.execGameCommand( cmd );

        // Send the message to the target
        cmd = "pch 1 " + player.client.getEnt().get_entNum() + message;
        target.client.execGameCommand( cmd );        
        return true;
    }
}