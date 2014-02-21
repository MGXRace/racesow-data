class RS_MapAuth
{
	/**
	 * Map ID number, 0 means unidentified
	 * @var uint
	 */
	uint id;

	/**
	 * Number of attempts to load data
	 * @var uint
	 */
	uint attempts;

	/**
	 * realTime for next think
	 * @var uint
	 */
	uint thinkTime;

	/**
	 * True if waiting on a query
	 * @var bool
	 */
	bool pending;

	RS_MapAuth()
	{
		id = 0;
		attempts = 0;
		thinkTime = 0;
		pending = false;
	}

	/**
	 * Try to load the map data
	 * @return void
	 */
	void Think()
	{
		if( id > 0 || attempts > 2 || pending || thinkTime > realTime )
			return;

		attempts++;
		thinkTime = realTime + 2000;
		RS_AuthMap( realTime );
		pending = true;
	}
}