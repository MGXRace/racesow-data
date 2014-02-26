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
	 * True if waiting on a query
	 * @var bool
	 */
	uint status;

	RS_MapAuth()
	{
		id = 0;
		attempts = 0;
		status = AUTH_STATUS_PENDING;
		RS_AuthMap();
	}

	void Think()
	{
	}

    /**
     * Deactivate auth status
     */
    void Failed()
    {
    	if( attempts < 3 )
    	{
    		attempts++;
    		RS_AuthMap();
    		status = AUTH_STATUS_PENDING;
    		return;
    	}

		id = 0;
		status = AUTH_STATUS_FAILED;        
    }
}