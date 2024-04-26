public with sharing class Nvl_cls_nuvolarFlightsController {
    
    public static final String FIELD_LATITUDE = 'nvl_fld_latitude__c';
    public static final String FIELD_LONGITUDE = 'nvl_fld_longitude__c';
    
    /*
    * Method to get all Airports in the BBDD.
    * return the List of all Airports in the BBDD.
    */
    @AuraEnabled(cacheable=true)
    public static List<nvl_obj_airport__c> getAllAirports(){
        return Nvl_cls_nuvolarFlightsGateway.getAllAirports();
    }

    /*
    * Method to get all Flights in the BBDD.
    * return the List of all Flights in the BBDD.
    */
    @AuraEnabled(cacheable=true)
    public static List<nvl_obj_flight__c> getAllFlights(){
        return Nvl_cls_nuvolarFlightsGateway.getAllFlights();
    }

    /*
    * Method to save a new Flight in the BBDD, calculating the distance between both Airports.
    * @param arrivalAirport: Arrival Airport, departureAirport: Departure Airport
    * return 'OK' in case the Flight was inserted correctly. 'NOK' in other case.
    */
    @AuraEnabled
    public static String saveFlight(nvl_obj_airport__c arrivalAirport, nvl_obj_airport__c departureAirport){
        Decimal flightDistance = Nvl_cls_nuvolarFlightsHandler.calculateDistance((Decimal) arrivalAirport.get(FIELD_LATITUDE),(Decimal) arrivalAirport.get(FIELD_LONGITUDE),
                                                                                (Decimal) departureAirport.get(FIELD_LATITUDE),(Decimal) departureAirport.get(FIELD_LONGITUDE));
        return Nvl_cls_nuvolarFlightsHandler.insertFlight(arrivalAirport, departureAirport, flightDistance);
        
    }
}