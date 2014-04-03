/**
 * target_starttimer_use
 * @param Entity @self
 * @param Entity @other
 * @param Entity @activator
 * @return void
 */
void target_starttimer_use( Entity @self, Entity @other, Entity @activator )
{
    if ( @activator.client == null )
        return;

    RS_getPlayer( activator ).startRace();
}

/**
 * target_startTimer_use
 * Defrag camelcase compatibility
 * @param Entity @self
 * @param Entity @other
 * @param Entity @activator
 * @return void
 */
void target_startTimer_use( Entity @self, Entity @other, Entity @activator )
{
    target_starttimer_use( self, other, activator );
}

/**
 * target_starttimer
 * Start Timer Enitity Spawner
 * @param Entity @self
 * @return void
 */
void target_starttimer( Entity @self )
{
    @self.use = target_starttimer_use;
}

/**
 * target_startTimer
 * Defrag camelcase compatibility
 * @param Entity @self
 * @return void
 */
void target_startTimer( Entity @self )
{
    target_starttimer( self );
}
