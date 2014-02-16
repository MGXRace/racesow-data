/*
 * Entity code for infinitive weapon pickup
 */
void replacementItem( Entity @oldItem )
{
	Vec3 min, max;
	Entity @ent = @G_SpawnEntity( oldItem.classname );
	Item @item = @G_GetItem( oldItem.item.tag );
	@ent.item = @item;
	ent.origin = oldItem.origin;
	oldItem.getSize( min, max );
	ent.setSize( min, max );
	ent.type = ET_ITEM;
	ent.solid = SOLID_TRIGGER;
	ent.moveType = MOVETYPE_NONE;
	ent.count = oldItem.count;
	ent.spawnFlags = oldItem.spawnFlags;
	ent.svflags &= ~SVF_NOCLIENT;
	ent.style = oldItem.style;
	ent.target = oldItem.target;
	ent.targetname = oldItem.targetname;
    ent.setupModel( oldItem.item.model, oldItem.item.model2 );
	oldItem.solid = SOLID_NOT;
	oldItem.classname = "ASmodel_" + ent.item.classname;
	ent.wait = oldItem.wait;

	if( ent.wait > 0 )
	{
        ent.nextThink = levelTime + int( ent.wait );
	}

	if( oldItem.item.type == uint(IT_WEAPON) )
	{
        ent.skinNum = oldItem.skinNum;
        oldItem.freeEntity();
	}
	@ent.think = replacementItem_think;
	@ent.touch = replacementItem_touch;
	@ent.use = replacementItem_use;
	ent.linkEntity();
}

void replacementItem_think( Entity @ent )
{
    ent.respawnEffect();
}

/*
 * Soundfix
 */
void replacementItem_use( Entity @ent, Entity @other, Entity @activator )
{
    if( ent.wait > 0 )
    {
        ent.nextThink = levelTime + int( ent.wait );
    }
    else
    {
        ent.nextThink = levelTime + 1;
    }
}

//FIXME: The touch functions for armor shards and small health explicitly weren't called before.
//Do we still want that behaviour? If yes please add it here -K1ll
void replacementItem_touch( Entity @ent, Entity @other, const Vec3 planeNormal, int surfFlags )
{
	if( @other.client == null || other.moveType != MOVETYPE_PLAYER )
		return;

	if( ( other.client.pmoveFeatures & PMFEAT_ITEMPICK ) == 0 )
	    return;

	int count = other.client.inventoryCount( ent.item.tag );
	int inventoryMax = ent.item.inventoryMax;
	if( ( ent.item.type & IT_WEAPON ) == uint(IT_WEAPON) )
	{
		int weakcount = other.client.inventoryCount( ent.item.weakAmmoTag );
		int weakinventoryMax = G_GetItem( ent.item.weakAmmoTag ).inventoryMax;
		if( count >= inventoryMax && weakcount >= weakinventoryMax )
			return;
		if( count == 0 || other.client.canSelectWeapon( ent.item.tag ) )
			other.client.inventoryGiveItem( ent.item.tag, inventoryMax );
		other.client.inventorySetCount( ent.item.weakAmmoTag, weakinventoryMax );
		if( other.client.pendingWeapon == WEAP_GUNBLADE )
			other.client.selectWeapon( ent.item.tag );
	}
	else if( ( ent.item.type & IT_AMMO ) == uint(IT_AMMO) )
	{
		if( count >= inventoryMax )
			return;
		other.client.inventorySetCount( ent.item.tag, inventoryMax );
	}
	else if( ( ent.item.type & IT_ARMOR ) == uint(IT_ARMOR) )
	{
		if( other.client.armor >= ent.item.quantity )
			return;
		int amount = ( ent.count == 0 ) ? ent.item.quantity : ent.count;
		other.client.armor = amount;
	}
	else if( ( ent.item.type & IT_POWERUP ) == uint(IT_POWERUP) )
	{
		if( count > 0 )
			return;
		int amount = ( ent.count == 0 ) ? ent.item.quantity : ent.count;
		other.client.inventorySetCount( ent.item.tag, amount );
	}
	else if( ( ent.item.type & IT_HEALTH ) == uint(IT_HEALTH) )
	{
	    int healthAmount;
	    switch( ent.item.tag )
	    {
	    case HEALTH_SMALL:
	        healthAmount = 40;
	        break;
	    case HEALTH_MEDIUM:
	        healthAmount = 75;
	        break;
	    case HEALTH_LARGE:
	        healthAmount = 100;
	        break;
	    case HEALTH_MEGA:
	        healthAmount = 200;
	        break;
	    case HEALTH_ULTRA:
	        healthAmount = 200;
	        break;
	    }
        if( other.health >= 100 && healthAmount <= 100 ) 
            return;
        if( other.health >= 200 && healthAmount <= 200 ) 
            return;
        if( healthAmount <= other.health )
           return;
        other.health = healthAmount;
	}
	G_Sound( other, CHAN_ITEM, G_SoundIndex( ent.item.pickupSound ), 0.875 );
}