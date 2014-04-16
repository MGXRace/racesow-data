void target_teleporter_think( Entity @ent )
{
	array<Entity@> targets = ent.findTargets();
	if( targets.length() > 0 )
		@ent.enemy = targets[0];
}

void target_teleporter( Entity @ent )
{
	@ent.think = target_teleporter_think;
	@ent.use = target_teleporter_use;
	ent.nextThink = levelTime + 1; //set up the targets
	ent.wait = 1;
}

void target_teleporter_use( Entity @ent, Entity @other, Entity @activator )
{
	RS_Player @player = RS_getPlayer( @activator );
	if( @player is null || (activator.svflags & SVF_NOCLIENT) == 1 || @ent.enemy is null )
		return;

	// Timeout check
	if( !player.triggerCheck( ent, int(ent.wait * 1000) ) )
		return;
	player.triggerSet( ent );

    player.teleport( ent.enemy.origin, ent.enemy.angles, true, true, true );
}