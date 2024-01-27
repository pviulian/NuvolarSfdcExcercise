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
    }

}