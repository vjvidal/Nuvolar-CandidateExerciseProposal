@isTest
public with sharing class Nvl_cls_nuvolarFlightsController_Test {
    @TestSetup
    private static void makeData(){
        List<nvl_obj_Airport__c> airportList = new List<nvl_obj_Airport__c>();
        nvl_obj_Airport__c airport1 = new nvl_obj_Airport__c();
        airport1.Name = 'Aeropuerto Internacional de la Región de Murcia';
        airport1.nvl_fld_IATACode__c = 'RMU';
        airport1.nvl_fld_latitude__c = 37.803;
        airport1.nvl_fld_longitude__c = -1.125;
        airportList.add(airport1);

        nvl_obj_Airport__c airport2 = new nvl_obj_Airport__c();
        airport2.Name = 'Aeropuerto de Alicante-Elche';
        airport2.nvl_fld_IATACode__c = 'ALC';
        airport2.nvl_fld_latitude__c = 38.2822;
        airport2.nvl_fld_longitude__c = -0.558156;
        airportList.add(airport2);

        nvl_obj_Airport__c airport3 = new nvl_obj_Airport__c();
        airport3.Name = 'Aeropuerto de Badajoz';
        airport3.nvl_fld_IATACode__c = 'BJZ';
        airport3.nvl_fld_latitude__c = 38.8913;
        airport3.nvl_fld_longitude__c = -6.82133;
        airportList.add(airport3);

        insert airportList;

        List<nvl_obj_flight__c> flightsList = new List<nvl_obj_flight__c>();
        nvl_obj_flight__c flight = new nvl_obj_flight__c();
        flight.nvl_fld_arrivalAirport__c = airport1.Id;
        flight.nvl_fld_departureAirport__c = airport2.Id;
        flight.nvl_fld_flightDistance__c = 72.82;
        flightsList.add(flight);

        insert flightsList;
    }

    @isTest
    private static void testGetAllAirports(){
        Test.startTest();
        List<nvl_obj_Airport__c> airportList = Nvl_cls_nuvolarFlightsController.getAllAirports();
        Test.stopTest();
        Assert.areEqual(3, airportList.size(), 'Airport list have an incorrect size.');
    }

    @isTest
    private static void testGetAllFlights(){
        nvl_obj_flight__c testFlight = [SELECT Id,nvl_fld_flightDistance__c FROM nvl_obj_flight__c LIMIT 1];
        Test.startTest();
        List<nvl_obj_flight__c> flightList = Nvl_cls_nuvolarFlightsController.getAllFlights();
        Test.stopTest();
        Assert.areEqual(flightList.get(0).nvl_fld_flightDistance__c, testFlight.nvl_fld_flightDistance__c, 'Wrong flight selected, distance is incorrect');
    }

    @isTest
    private static void testSaveFlight(){
        nvl_obj_Airport__c arrivalAirport = null;
        nvl_obj_Airport__c departureAirport = null;

        for (nvl_obj_Airport__c airport : [SELECT Id,nvl_fld_IATACode__c,nvl_fld_latitude__c,nvl_fld_longitude__c FROM nvl_obj_Airport__c WHERE nvl_fld_IATACode__c = 'RMU' OR nvl_fld_IATACode__c = 'BJZ']){
            if (airport.nvl_fld_IATACode__c == 'RMU'){ arrivalAirport = airport; }
            else if (airport.nvl_fld_IATACode__c == 'BJZ'){ departureAirport = airport; }
        }
        
        Test.startTest();
        Nvl_cls_nuvolarFlightsController.saveFlight(arrivalAirport, departureAirport);
        Test.stopTest();

        nvl_obj_flight__c newFlight = [SELECT Id FROM nvl_obj_flight__c WHERE nvl_fld_arrivalAirport__c = :arrivalAirport.Id AND nvl_fld_departureAirport__c = :departureAirport.Id];
        Assert.areNotEqual(null, newFlight, 'Failed to insert the Flight');
    }
}