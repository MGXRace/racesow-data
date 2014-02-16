void target_relay( Entity @ent )
{
    @ent.use = target_relay_use;
	//the rest does the use code
}

void target_relay_use( Entity @ent, Entity @other, Entity @activator )
{
	ent.useTargets( @activator );
}