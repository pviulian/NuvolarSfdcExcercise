/**
 * @description       : Controller class that executes the necessary backend logic in SFDC.
 * @author            : IULIAN PREDA VLASCEANU
 * @group             :
 * @last modified on  : 27-01-2024
 * @last modified by  : IULIAN PREDA VLASCEANU
 **/
public with sharing class NV_cls_controller{
    /**
     * @description       : Wrapper class that provides error control structure.
     * @author            : IULIAN PREDA VLASCEANU
     * @group             :
     * @last modified on  : 27-01-2024
     * @last modified by  : IULIAN PREDA VLASCEANU
     **/
    public class errorMessages{
        public String errorCode;
        public String errorMessage;

        /**
         * @description       : Constructor method of the wrapper class.
         * @author            : IULIAN PREDA VLASCEANU
         * @group             :
         * @last modified on  : 27-01-2024
         * @last modified by  : IULIAN PREDA VLASCEANU
         **/
        public errorMessages(){
            this.errorCode = '';
            this.errorMessage = '';
        }

    }

    /**
     * @description       : Wrapper class that provides flight data structure.
     * @author            : IULIAN PREDA VLASCEANU
     * @group             :
     * @last modified on  : 27-01-2024
     * @last modified by  : IULIAN PREDA VLASCEANU
     **/
    public class flightDataWrapper{
        @AuraEnabled
        public String departure{ get; set; }

        @AuraEnabled
        public String arrival{ get; set; }

        @AuraEnabled
        public Integer distance{ get; set; }

        /**
         * @description       : Constructor method of the wrapper class.
         * @author            : IULIAN PREDA VLASCEANU
         * @group             :
         * @last modified on  : 27-01-2024
         * @last modified by  : IULIAN PREDA VLASCEANU
         **/
        public flightDataWrapper(){
            this.departure = '';
            this.arrival = '';
            this.distance = 0;
        }

    }

    /**
    * @description Method that inserts the flight to be calculated into SFDC (Salesforce).
    * @author IULIAN PREDA VLASCEANU | 27-01-2024 
    * @param departureAirport IATA Code
    * @param arrivalAirport IATA Code
    * @return List<String> Returns a list with the errors generated for management.
    **/
    @AuraEnabled
    public static List<String> saveFlight(String departureAirport, String arrivalAirport){

        Map<String, NV_obj_airport__c> mapIataCodeWithAirportId = new Map<String, NV_obj_airport__c>();
        List<NV_obj_flightData__c> lstFlightDistance = new List<NV_obj_flightData__c>();
        List<String> lstErrorsInsertedAirports = new List<String>();

        try{
            mapIataCodeWithAirportId = retrieveAirportId(mapIataCodeWithAirportId, departureAirport, arrivalAirport);
            NV_obj_airport__c departureAirportDetails = mapIataCodeWithAirportId.get(departureAirport);
            NV_obj_airport__c arrivalAirportDetails = mapIataCodeWithAirportId.get(arrivalAirport);


            if (departureAirportDetails != null && arrivalAirportDetails != null){
                // Accessing latitude and longitude
                Decimal departureLatitude = departureAirportDetails.NV_fld_airportLatitude__c;
                Decimal departureLongitude = departureAirportDetails.NV_fld_airportLongitude__c;

                Decimal arrivalLatitude = arrivalAirportDetails.NV_fld_airportLatitude__c;
                Decimal arrivalLongitude = arrivalAirportDetails.NV_fld_airportLongitude__c;


                NV_obj_flightData__c flightDistance = new NV_obj_flightData__c();
                flightDistance.NV_fld_departure__c = departureAirport;
                flightDistance.NV_fld_arrival__c = arrivalAirport;
                flightDistance.NV_fld_distance__c = (Integer) calculateDistance(departureLatitude, departureLongitude, arrivalLatitude, arrivalLongitude);
                lstFlightDistance.add(flightDistance);

            }
            Database.saveResult[] srListNewAirports = Database.insert (lstFlightDistance, false);
            for (Database.saveResult srAirports : srListNewAirports){
                if (!srAirports.isSuccess()){
                    for (Database.Error err : srAirports.getErrors()){
                        System.debug(err);
                        lstErrorsInsertedAirports.add(err.getMessage());
                    }
                }
            }

        } catch (DmlException dmlEx){
            lstErrorsInsertedAirports.add(dmlEx.getMessage());
        } catch (Exception e){
            lstErrorsInsertedAirports.add(e.getMessage());
        }
        return lstErrorsInsertedAirports;
    }

    /**
    * @description Method that retrieves airport data and creates a map with the IATA code as the primary value.
    * @author IULIAN PREDA VLASCEANU | 27-01-2024 
    * @param mapIataCodeWithAirportId Self-invoking map that fills itself.
    * @param departureAirport IATA code
    * @param arrivalAirport IATA code
    * @return Map<String, NV_obj_airport__c> Map filled with the IATA code as the primary key and the airport details as the value.
    **/
    private static Map<String, NV_obj_airport__c> retrieveAirportId(Map<String, NV_obj_airport__c> mapIataCodeWithAirportId, String departureAirport, String arrivalAirport){
        try{
            for (NV_obj_airport__c airport : [SELECT Id, NV_fld_airportIATA__c, NV_fld_airportLatitude__c, NV_fld_airportLongitude__c
                                              FROM NV_obj_airport__c
                                              WHERE (NV_fld_airportIATA__c = :departureAirport OR NV_fld_airportIATA__c = :arrivalAirport)]){
                mapIataCodeWithAirportId.put(airport.NV_fld_airportIATA__c, airport);
            }
        } catch (QueryException qe){
            // Log query-related exception details
            System.debug('Query exception: ' + qe.getMessage());
            System.debug('Query exception stack trace: ' + qe.getStackTraceString());
        }
        System.debug(JSON.serializePretty(mapIataCodeWithAirportId));
        return mapIataCodeWithAirportId;
    }

    /**
    * @description Method that retrieves the ID of airports to check for existence.
    * @author IULIAN PREDA VLASCEANU | 27-01-2024 
    * @param iataCode Código iata
    * @return String Returns "KO" if it does not exist and "OK" if it is created.
    **/
    @AuraEnabled(cacheable = true)
    public static String retrieveAirport(String iataCode){
        String airportResult = '';
        try{
            List<NV_obj_airport__c> lstGetAirport = [SELECT Id
                                                     FROM NV_obj_airport__c
                                                     WHERE NV_fld_airportIATA__c = :iataCode];

            airportResult = (lstGetAirport.isEmpty()) ? airportResult = NV_cls_utils.AIRPOT_KO : NV_cls_utils.AIRPORT_OK;
            System.debug('Query result getAirport: ' + lstGetAirport);
        } catch (QueryException qe){
            // Log query-related exception details
            System.debug('Query exception: ' + qe.getMessage());
            System.debug('Query exception stack trace: ' + qe.getStackTraceString());
        } catch (Exception e){
            // Log other exception details
            System.debug('Other exception: ' + e.getMessage());
            System.debug('Other exception stack trace: ' + e.getStackTraceString());
            System.debug('return result airportResult ' + airportResult);
        }
        System.debug('return ' + airportResult);
        return airportResult;
    }

    /**
    * @description Method that creates the airport record based on the received parameters.
    * @author IULIAN PREDA VLASCEANU | 27-01-2024 
    * @param name 
    * @param iataCode 
    * @param longitude 
    * @param latitude 
    * @return List<String> Returns a list of errors in case there are any.
    **/
    @AuraEnabled
    public static List<String> newAirport(String name, String iataCode, Decimal longitude, Decimal latitude){

        List<String> lstErrorsInsertedAirports = new List<String>();
        List<NV_obj_airport__c> lstNewAirport = new List<NV_obj_airport__c>();
        List<errorMessages> lstErrorMessages = new List<errorMessages>();

        try{

            lstErrorMessages = checkFields(name, iataCode, longitude, latitude, lstErrorMessages);

            if (lstErrorMessages.isEmpty()){
                NV_obj_airport__c airport = new NV_obj_airport__c();
                airport.Name = name;
                airport.NV_fld_airportIATA__c = iataCode;
                airport.NV_fld_airportLongitude__c = longitude;
                airport.NV_fld_airportLatitude__c = latitude;
                lstNewAirport.add(airport);
            } else{

                for (errorMessages err : lstErrorMessages){

                    lstErrorsInsertedAirports.add(err.errorMessage);

                }
            }

            System.debug('lstNewAirport ' + lstNewAirport);
            Database.saveResult[] srListNewAirports = Database.insert (lstNewAirport, false);

            for (Database.saveResult srAirports : srListNewAirports){
                if (!srAirports.isSuccess()){
                    for (Database.Error err : srAirports.getErrors()){
                        lstErrorsInsertedAirports.add(err.getMessage());
                    }
                }
            }

        } catch (DmlException dmlEx){
            lstErrorsInsertedAirports.add(dmlEx.getMessage());
        } catch (Exception e){
            lstErrorsInsertedAirports.add(e.getMessage());
        }
        return lstErrorsInsertedAirports;
    }

    /**
    * @description Method that checks for errors and returns a list if any of the conditions are met.
    * @author IULIAN PREDA VLASCEANU | 27-01-2024 
    * @param name 
    * @param iataCode 
    * @param longitude 
    * @param latitude 
    * @param lstErrorFields 
    * @return List<errorMessages> returns a list if any of the conditions are met.
    **/
    private static List<errorMessages> checkFields(String name, String iataCode, Decimal longitude, Decimal latitude, List<errorMessages> lstErrorFields){
        errorMessages validateField = new errorMessages();

        if (name == '' || name == null){
            validateField.errorCode = NV_cls_utils.ERROR_CODE_NAME;
            validateField.errorMessage = NV_cls_utils.ERROR_DESC_NAME;
            lstErrorFields.add(validateField);
        }
        if (iataCode == '' || iataCode == null){
            validateField.errorCode = NV_cls_utils.ERROR_CODE_IATA;
            validateField.errorMessage = NV_cls_utils.ERROR_DESC_IATA;
            lstErrorFields.add(validateField);
        }
        if (longitude == null || longitude < -180 || longitude > 180){
            validateField.errorCode = NV_cls_utils.ERROR_CODE_LONGITUDE;
            validateField.errorMessage = NV_cls_utils.ERROR_DESC_LONGITUDE;
            lstErrorFields.add(validateField);
        }
        if (latitude == null || latitude < -90 || latitude > 90){
            validateField.errorCode = NV_cls_utils.ERROR_CODE_LATITUDE;
            validateField.errorMessage = NV_cls_utils.ERROR_DESC_LATITUDE;
            lstErrorFields.add(validateField);
        }


        return lstErrorFields;
    }

    /**
    * @description Method that returns a list of the last 10 created flights in descending order to be displayed on the screen.
    * @author IULIAN PREDA VLASCEANU | 27-01-2024 
    * @return List<flightDataWrapper> returns a list of the last 10 created flights in descending order to be displayed on the screen.
    **/
    @AuraEnabled(cacheable = true)
    public static List<flightDataWrapper> getFlightDataList(){
        List<flightDataWrapper> lstFlightData = new List<flightDataWrapper>();
        List<NV_obj_flightData__c> flightDataRecords = [SELECT NV_fld_departure__c, NV_fld_arrival__c, NV_fld_distance__c
                                                        FROM NV_obj_flightData__c
                                                        ORDER BY CreatedDate DESC LIMIT 10];

        for (NV_obj_flightData__c record : flightDataRecords){
            flightDataWrapper fDw = new flightDataWrapper();
            fDw.departure = record.NV_fld_departure__c;
            fDw.arrival = record.NV_fld_arrival__c;
            fDw.distance = (Integer) record.NV_fld_distance__c;
            lstFlightData.add(fDw);
        }
        System.debug(lstFlightData);
        return lstFlightData;
    }

    /**
    * @description Method that calculates the distance in kilometers between two airports based on their longitude and latitude.
    * @author NUVOLAR | 27-01-2024 
    * @param latitude1 
    * @param longitude1 
    * @param latitude2 
    * @param longitude2 
    * @return Decimal airport distance
    **/
    static Decimal calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2, Decimal longitude2){

        Integer earthRadius = 6371 * 1000; // in meters
        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI / 180;
        Decimal latitudeRadians2 = latitude2 * Math.PI / 180;
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI / 180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI / 180;


        Decimal a = Math.sin(latitudeDelta / 2) * Math.sin(latitudeDelta / 2) + Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) * Math.sin(longitudeDelta / 2) * Math.sin(longitudeDelta / 2);
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in metres
        return distance;
    }

}