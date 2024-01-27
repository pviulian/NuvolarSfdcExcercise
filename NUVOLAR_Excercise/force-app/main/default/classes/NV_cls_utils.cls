/**
 * @description       : 
 * @author            : IULIAN PREDA VLASCEANU
 * @group             : 
 * @last modified on  : 27-01-2024
 * @last modified by  : IULIAN PREDA VLASCEANU
**/
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

    //Test Variable
    public static final String NAME_1 ='GTG';
    public static final String NAME_2 ='CLJ';
    public static final Decimal DEC_LAT_1 = 4.5420;
    public static final Decimal DEC_LONG_1 = 132.5420;
    public static final Decimal DEC_LAT_2 = 32.5420;
    public static final Decimal DEC_LONG_2 = 194.5420;
    public static final String ARRIVAL ='Arrival';
    public static final String DEPARTURE ='Departure';

}