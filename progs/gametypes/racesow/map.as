/**
 * Racesow Map Model
 *
 * @package Racesow
 * @version 1.0.3
 */
class RS_Map
{
    /**
     * World record race
     * @var RS_Race
     */
    RS_Race @record;

    /**
     * Auth data for the map
     * @var RS_MapAuth
     */
    RS_MapAuth auth;

    /**
     * Constructor
     */
    RS_Map()
    {
        @record = null;
        auth = RS_MapAuth();
    }

    /**
     * Destructor
     */
    ~RS_Map()
    {
    }

    /**
     * Think function for the map
     * @return void
     */
    void Think()
    {
        auth.Think();
    }
}
