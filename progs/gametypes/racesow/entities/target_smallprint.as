Dictionary ent_smallprint_messages;

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
    RS_Player @player = RS_getPlayer( @activator );
    if( @player is null || (activator.svflags & SVF_NOCLIENT) == 1 || @ent.enemy is null )
        return;

    // Timeout check
    if( !player.triggerCheck( ent, int(ent.wait * 1000) ) )
        return;
    player.triggerSet( ent );

    String @message;
    ent_smallprint_messages.get( String( ent.entNum ), @message );
	G_CenterPrintMsg( activator, message );
}