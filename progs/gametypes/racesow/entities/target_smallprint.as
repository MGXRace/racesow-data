Dictionary ent_smallprint_messages;
uint[] ent_smallprint_times( maxClients );
const uint ENT_SMALLPRINT_TIMEOUT = 1000;

void target_smallprint( Entity @ent )
{
    @ent.use = target_smallprint_use;

    // Seems like you have to get spawn keys while the entity is spawning
    // they can't be retrieved any other time.
	String message = G_SpawnTempValue( "message" );
    if( message.empty() )
    	ent.freeEntity();

    else
    	ent_smallprint_messages.set( String( ent.entNum ), message );
}

void target_smallprint_use( Entity @ent, Entity @other, Entity @activator )
{
	if( @activator.client is null ||
        ent_smallprint_times[activator.get_playerNum()] > realTime )
        return;

    String @message;
    ent_smallprint_messages.get( String( ent.entNum ), @message );
    ent_smallprint_times[activator.get_playerNum()] = realTime + ENT_SMALLPRINT_TIMEOUT + uint( ent.wait );
	G_CenterPrintMsg( activator, message );
}