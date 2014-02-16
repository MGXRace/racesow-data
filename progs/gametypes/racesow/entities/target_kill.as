void target_kill( Entity @ent )
{
    @ent.use = target_kill_use;
	//the rest does the use code
}

void target_kill_use( Entity @ent, Entity @other, Entity @activator )
{
	activator.sustainDamage( @activator, null, Vec3(0,0,0), 9999, 0, 0, MOD_SUICIDE );
	activator.health = 0;
}