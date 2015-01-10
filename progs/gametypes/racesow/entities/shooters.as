Cvar rs_plasma_speed( "rs_plasma_speed", "1700", CVAR_ARCHIVE );
Cvar rs_plasma_knockback( "rs_plasma_maxKnockback", "22", CVAR_ARCHIVE );
Cvar rs_plasma_splash( "rs_plasma_splash", "40", CVAR_ARCHIVE );
Cvar rs_rocket_speed( "rs_rocket_speed", "950", CVAR_ARCHIVE );
Cvar rs_rocket_knockback( "rs_rocket_maxKnockback", "100", CVAR_ARCHIVE );
Cvar rs_rocket_splashfrac( "rs_rocket_splashfrac", "2.0", CVAR_ARCHIVE );
Cvar rs_rocket_splash( "rs_rocket_splash", "150", CVAR_ARCHIVE );
Cvar rs_grenade_speed( "rs_grenade_speed", "820", CVAR_ARCHIVE );
Cvar rs_grenade_knockback( "rs_grenade_maxKnockback", "115", CVAR_ARCHIVE );
Cvar rs_grenade_splash( "rs_grenade_splash", "170", CVAR_ARCHIVE );

//==============
//RS_UseShooter
//==============
void RS_UseShooter( Entity @self, Entity @other, Entity @activator ) {

	Vec3 dir;
	Vec3 angles;

    if ( @self.enemy != null ) {
        dir = self.enemy.origin - self.origin;
        dir.normalize();
    } else {
        dir = self.movedir;
        dir.normalize();
    }
    angles = dir.toAngles();
	switch ( self.weapon )
	{
        case WEAP_GRENADELAUNCHER:
        	G_FireGrenade( self.origin, angles, rs_grenade_speed.integer, rs_grenade_splash.integer, 65, rs_grenade_knockback.integer, 0, @activator );
            break;
        case WEAP_ROCKETLAUNCHER:
        	G_FireRocket( self.origin, angles, rs_rocket_speed.integer, rs_rocket_splash.integer, 75, rs_rocket_knockback.integer, 0, @activator );
            break;
        case WEAP_PLASMAGUN:
        	G_FirePlasma( self.origin, angles, rs_plasma_speed.integer, rs_plasma_splash.integer, 15, rs_plasma_knockback.integer, 0, @activator );
            break;
    }

}

//======================
//RS_InitShooter_Finish
//======================
void RS_InitShooter_Finish( Entity @self )
{
	array<Entity@> targets = self.findTargets();
	if( targets.length() > 0 )
		@self.enemy = targets[0]; // Use the first target
	else
		@self.enemy = null;

    self.nextThink = 0;
}

//===============
//RS_InitShooter
//===============
void RS_InitShooter( Entity @self, int weapon ) {
    self.weapon = weapon;
    // target might be a moving object, so we can't set a movedir for it
    if ( self.targetname != "" ) {
        self.nextThink = levelTime + 500;
    }
    self.linkEntity();
}


//=================
//RS_shooter_rocket
//=================
void shooter_rocket( Entity @ent ) {
    @ent.think = RS_InitShooter_Finish;
    @ent.use = RS_UseShooter;
    RS_InitShooter( @ent, WEAP_ROCKETLAUNCHER );
}

//=================
//RS_shooter_plasma
//=================
void shooter_plasma( Entity @ent ) {
    @ent.think = RS_InitShooter_Finish;
    @ent.use = RS_UseShooter;
    RS_InitShooter( @ent, WEAP_PLASMAGUN );
}

//=================
//RS_shooter_grenade
//=================
void shooter_grenade( Entity @ent ) {
    @ent.think = RS_InitShooter_Finish;
    @ent.use = RS_UseShooter;
    RS_InitShooter( @ent, WEAP_GRENADELAUNCHER );
}
