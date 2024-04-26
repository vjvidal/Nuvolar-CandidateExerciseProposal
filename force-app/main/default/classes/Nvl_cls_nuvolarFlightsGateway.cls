public with sharing class Nvl_cls_nuvolarFlightsGateway {

    /*
    * Method that search all Airports in the BBDD
    * return List of Airports in the BBDD
    */
    public static List<nvl_obj_airport__c> getAllAirports(){
        return [SELECT Id,Name, nvl_fld_IATACode__c, nvl_fld_latitude__c, nvl_fld_longitude__c 
                FROM nvl_obj_airport__c];
    }

    /*
    * Method that search all Flights in the BBDD
    * return List of Flights in the BBDD
    */
    public static List<nvl_obj_flight__c> getAllFlights(){
        return [SELECT Id,Name,nvl_fld_arrivalAirport__c, nvl_fld_departureAirport__c, nvl_fld_flightDistance__c,nvl_fld_arrivalAirport__r.nvl_fld_IATACode__c,nvl_fld_departureAirport__r.nvl_fld_IATACode__c 
                FROM nvl_obj_flight__c 
                ORDER BY Name ASC];
    }
}