public with sharing class Nvl_cls_nuvolarFlightsHandler {

    /*
    * Method to create a new Flight and insert to the BBDD.
    * @param arrivalAirport: Arrival Airport, departureAirport: Departure Airport, flightDistance: Flight distance
    * return 'OK' in case the Flight was inserted correctly. 'NOK' in other case.
    */
    public static String insertFlight(nvl_obj_airport__c arrivalAirport, nvl_obj_airport__c departureAirport, Decimal flightDistance){
        List<nvl_obj_flight__c> newFlightsList = new List<nvl_obj_flight__c>();
        nvl_obj_flight__c newFlight = new nvl_obj_flight__c(nvl_fld_arrivalAirport__c = arrivalAirport.Id, nvl_fld_departureAirport__c = departureAirport.Id, nvl_fld_flightDistance__c  = flightDistance);
        newFlightsList.add(newFlight);

        Database.SaveResult[] srList = Database.insert(newFlightsList, true);
        Boolean insertError = false;

        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                System.debug('Flight inserted: '+sr.getId());
            } else {
                insertError = true;
                for (Database.Error objErr : sr.getErrors()){
                    System.debug('Error inserting flight: ['+objErr.getStatusCode()+'], ['+objErr.getMessage()+']');
                }
            }
        }

        return insertError == false ? 'OK' : 'NOK';
    }
    
    /*
    * Method to create a new Flight and insert to the BBDD.
    * @param arrivalAirport: Arrival Airport, departureAirport: Departure Airport, flightDistance: Flight distance
    * return The distance between both Airports in Kilometers
    */
    public static Decimal calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371; // in kilometers

        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;       
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;

        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
                    Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
                    Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);

        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in kilometers
        return distance.setScale(2); // return rounded to 2 decimal places
    }
}