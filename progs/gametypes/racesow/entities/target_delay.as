//=================
//QUAKED target_delay (1 0 0) (-8 -8 -8) (8 8 8)
//"wait" seconds to pause before firing targets.
//=================
void target_delay_think( Entity @ent )
{
    ent.useTargets( @ent.enemy );
}

void target_delay_use( Entity @self, Entity @other, Entity @activator )
{
    self.nextThink = levelTime + int( self.wait ) * 1000;
    @self.enemy = @activator;
}

void target_delay( Entity @ent )
{

    @ent.think = target_delay_think;
    @ent.use = target_delay_use;
    if ( ent.wait == 0 )
    {
        ent.wait = 1;
    }
}