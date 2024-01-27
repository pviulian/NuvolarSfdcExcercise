/**
 * @description       : Test class to test the different test scenarios.
 * @author            : IULIAN PREDA VLASCEANU
 * @group             :
 * @last modified on  : 27-01-2024
 * @last modified by  : IULIAN PREDA VLASCEANU
 **/
@isTest
public class NV_cls_controller_test{
    /**
     * @description Setup method of the class.
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @TestSetup
    static void makeData(){
        NV_obj_airport__c airport1 = new NV_obj_airport__c();
        airport1.Name = NV_cls_utils.NAME_1;
        airport1.NV_fld_airportIATA__c = NV_cls_utils.NAME_1;
        airport1.NV_fld_airportLongitude__c = NV_cls_utils.DEC_LONG_1;
        airport1.NV_fld_airportLatitude__c = NV_cls_utils.DEC_LAT_1;
        insert airport1;

        NV_obj_airport__c airport2 = new NV_obj_airport__c();
        airport2.Name = NV_cls_utils.NAME_2;
        airport2.NV_fld_airportIATA__c = NV_cls_utils.NAME_2;
        airport2.NV_fld_airportLongitude__c = NV_cls_utils.DEC_LONG_2;
        airport2.NV_fld_airportLatitude__c = NV_cls_utils.DEC_LAT_2;
        insert airport2;
    }

    /**
     * @description Test scenario where the airport is not created.
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @isTest
    static void newAirportKOTest(){


        NV_obj_airport__c airport = [SELECT Id, Name, NV_fld_airportIATA__c, NV_fld_airportLatitude__c, NV_fld_airportLongitude__c
                                     FROM NV_obj_airport__c
                                     LIMIT 1];
        List<String> lstStrError = new List<String>();

        Test.startTest();
        lstStrError = NV_cls_controller.newAirport(airport.name, airport.NV_fld_airportIATA__c, airport.NV_fld_airportLongitude__c, airport.NV_fld_airportLatitude__c);
        Test.stopTest();

        System.assertEquals(1, lstStrError.size());
    }

    /**
     * @description Test scenario where the airport is not created.
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @isTest
    static void saveFlightest(){


        List<NV_obj_airport__c> airport = [SELECT Id, Name, NV_fld_airportIATA__c, NV_fld_airportLatitude__c, NV_fld_airportLongitude__c
                                           FROM NV_obj_airport__c
                                           LIMIT 2];
        List<String> lstStrError = new List<String>();

        Test.startTest();
        lstStrError = NV_cls_controller.saveFlight(NV_cls_utils.NAME_1, NV_cls_utils.NAME_2);
        Test.stopTest();

        System.assertEquals(0, lstStrError.size());
    }

    /**
     * @description Test plan where exceptions are checked.
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @isTest
    static void errorMessageNameTest(){

        List<String> lstErrorMessage = new List<String>();
        Test.startTest();
        lstErrorMessage = NV_cls_controller.newAirport(null, null, null, null);
        Test.stopTest();

        System.assertEquals(4, lstErrorMessage.size());
    }

    /**
     * @description Method that retrieves the data of planned flight.
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @isTest
    static void testGetFlightDataList(){
        List<NV_obj_flightData__c> flightDataList = new List<NV_obj_flightData__c>();
        for (Integer i = 0; i < 10; i++){
            NV_obj_flightData__c flightData = new NV_obj_flightData__c(
                NV_fld_departure__c = NV_cls_utils.DEPARTURE + i, 
                NV_fld_arrival__c = NV_cls_utils.ARRIVAL + i, 
                NV_fld_distance__c = i * 100
            );
            flightDataList.add(flightData);
        }
        insert flightDataList;

        Test.startTest();
        List<NV_cls_controller.flightDataWrapper> result = NV_cls_controller.getFlightDataList();
        Test.stopTest();

        System.assertEquals(10, result.size());

        for (Integer i = 0; i < 10; i++){
            NV_cls_controller.flightDataWrapper expectedData = result[i];
            NV_obj_flightData__c actualData = flightDataList[i];

            System.assertEquals(NV_cls_utils.DEPARTURE + i, expectedData.departure);
            System.assertEquals(NV_cls_utils.ARRIVAL + i, expectedData.arrival);
            System.assertEquals(i * 100, expectedData.distance);
        }
    }

    /**
     * @description Method that calculates distance between coordinates
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @isTest
    static void calculateDistanceTest(){
        Decimal result;
        Test.startTest();
        result = NV_cls_controller.calculateDistance(NV_cls_utils.DEC_LAT_1, NV_cls_utils.DEC_LONG_1, NV_cls_utils.DEC_LAT_2, NV_cls_utils.DEC_LONG_2);
        Test.stopTest();

        System.assertNotEquals(9000, result);
    }

    /**
     * @description Method that retrieves airport data
     * @author IULIAN PREDA VLASCEANU | 27-01-2024
     **/
    @isTest
    static void retrieveAirportTest(){
        Test.startTest();
        String result = NV_cls_controller.retrieveAirport(NV_cls_utils.NAME_1);
        Test.stopTest();

        System.assertEquals(NV_cls_utils.AIRPORT_OK, result);
    }

}