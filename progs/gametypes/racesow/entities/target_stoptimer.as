/**
 * target_stoptimer_use
 * @param Entity @self
 * @param Entity @other
 * @param Entity @activator
 * @return void
 */
void target_stoptimer_use( Entity @self, Entity @other, Entity @activator )
{
    if ( @activator.client == null )
        return;

    RS_getPlayer( activator ).stopRace();
}

/**
 * target_stopTimer_use
 * defrag maps compatibility
 * @param Entity @self
 * @param Entity @other
 * @param Entity @activator
 * @return void
 */
void target_stopTimer_use( Entity @self, Entity @other, Entity @activator )
{
    target_stoptimer_use( self, other, activator );
}

/**
 * target_stoptimer
 * @param Entity @self
 * @return void
 */
void target_stoptimer( Entity @self )
{
    @self.use = target_stoptimer_use;
}

/**
 * target_stopTimer
 * defrag maps compatibility
 * @param Entity @self
 * @return void
 */
void target_stopTimer( Entity @self )
{
    @self.use = target_stopTimer_use;
}