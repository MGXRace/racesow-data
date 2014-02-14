/**
 * target_checkpoint_use
 * Use function for the checkpoint entity, called when triggered.
 *
 * @param Entity self The checkpoint entity
 * @param Entity other The entity that targets the checkpoint
 * @param Entity activator The entity that triggered other
 * @return void
 */
void target_checkpoint_use( Entity @self, Entity @other, Entity @activator )
{
	if( @activator.client == null )
		return;

	RS_getPlayer( activator ).addCheckpoint( self.count );
}

/**
 * target_checkpoint
 * Spawning function for the checkpoint entity, called on map load.
 *
 * @param Entity
 * @self The checkpoint entity
 * @return void
 */
void target_checkpoint( Entity @self )
{
    @self.use = target_checkpoint_use;
    self.count = numCheckpoints;
    numCheckpoints++;
}