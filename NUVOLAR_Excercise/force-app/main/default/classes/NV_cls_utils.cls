public with sharing class NV_cls_utils{
    public static final String AIRPORT_OK = 'airportOK';
    public static final String AIRPOT_KO = 'airportKO';
    // ERROR CODES
    public static final String ERROR_CODE_NAME = '100';
    public static final String ERROR_DESC_NAME = 'Airport Name cannot be blank or null';

    public static final String ERROR_CODE_IATA = '101';
    public static final String ERROR_DESC_IATA = 'Airport IATA Code cannot be blank or null';

    public static final String ERROR_CODE_LATITUDE = '102';
    public static final String ERROR_DESC_LATITUDE = 'Airport Latitude cannot be blank or null or is out of range (-90 or +90)';
    
    public static final String ERROR_CODE_LONGITUDE = '102';
    public static final String ERROR_DESC_LONGITUDE = 'Airport Longitude cannot be blank or null or is out of range (-180 or +180)';
}