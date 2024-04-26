import { LightningElement,wire } from 'lwc';
import { refreshApex } from "@salesforce/apex";
import getAllAirports from '@salesforce/apex/Nvl_cls_nuvolarFlightsController.getAllAirports';
import getAllFlights from '@salesforce/apex/Nvl_cls_nuvolarFlightsController.getAllFlights';
import saveFlight from '@salesforce/apex/Nvl_cls_nuvolarFlightsController.saveFlight';

export default class Nvl_lwc_nuvolarFlights extends LightningElement {

    // Define columns for the flights datatable
    flightsColumns = [
        { label: 'Flight Name', fieldName: 'flightName' },
        { label: 'Arrival Airport', fieldName: 'arrAirport' },
        { label: 'Departure Airport', fieldName: 'deparAirport' },
        { label: 'Distance (km)', fieldName: 'distance', type: 'number' }
    ];

    searchIATA = '';
    airportData = [];
    filteredAirportData = [];
    filteredAirportDataNames = [];
    flightsData = [];

    pageSizeOptions = [5, 10, 25];
    totalFlights = 0;
    pageSize;
    totalPages;
    pageNumber = 1;
    flightsToDisplay = [];

    delayTimeout;

    arrivalAirport = '';
    selectedArrivalAirport = null;
    selectedArrivalName = '';

    departureAirport = '';
    selectedDepartureAirport = null;
    selectedDepartureName = '';

    validateEmptyArrivalAirport = '';
    validateEmptyDepartureAirport = '';
    validateInsertedFlight = '';

    // Get all airports by apex without filtering
    @wire(getAllAirports)
    wiredAirport({error, data}){
        if (data){
            this.airportData = data;
            this.filterAirportData();
        } else if (error){
            console.error('Error retrieving airports: ', error);
        }
    }

    // Get all flights by apex
    wiredFlightData;
    @wire(getAllFlights)
    wiredFlight({error, data}){
        this.wiredFlightData = data;
        if (data){
            this.flightsData = [];
            data.forEach(flight => this.flightsData.push({
                    flightName: flight.Name,
                    arrAirport: flight.nvl_fld_arrivalAirport__r.nvl_fld_IATACode__c,
                    deparAirport: flight.nvl_fld_departureAirport__r.nvl_fld_IATACode__c,
                    distance: flight.nvl_fld_flightDistance__c
                }));
            this.totalFlights = data.length;
            this.pageSize = this.pageSizeOptions[0];
            this.refreshFlightsToDisplay();
        } else if (error){
            console.error('Error retrieving Flights: ',error);
        }
    }

    handleArrivalChange(event){
        this.arrivalAirport = event.target.value;
        this.selectedArrivalAirport = this.airportData.find(airport =>
            airport.nvl_fld_IATACode__c == event.target.value
        );
        this.selectedArrivalName = this.selectedArrivalAirport.Name;
        this.filterAirportData();
        this.validateEmptyArrivalAirport = '';
    }

    handleDepartureChange(event){
        this.departureAirport = event.target.value;
        this.selectedDepartureAirport = this.airportData.find(airport =>
            airport.nvl_fld_IATACode__c == event.target.value
        );
        this.selectedDepartureName = this.selectedDepartureAirport.Name;
        this.filterAirportData();
        this.validateEmptyDepartureAirport = '';
    }

    handleSearch(event){
        this.searchIATA = event.target.value;
        this.delay();
    }

    handleSaveFlight(){
        this.validateEmptyArrivalAirport = this.selectedArrivalAirport == null ? 'Please fill Arrival Airport before saving a flight.' : '';
        this.validateEmptyDepartureAirport = this.selectedDepartureAirport == null ? 'Please fill Arrival Airport before saving a flight.' : '';
        if (this.selectedArrivalAirport != null && this.selectedDepartureAirport != null){
            saveFlight({arrivalAirport: this.selectedArrivalAirport, departureAirport: this.selectedDepartureAirport}).then(result => {
                refreshApex(this.flightsData);
                console.log('Save Flight result: ',result);
                this.handleClear();
            });            
        }
    }

    handleClear(){
        this.searchIATA = '';
        this.arrivalAirport = '';
        this.selectedArrivalAirport = null;
        this.selectedArrivalName = '';

        this.departureAirport = '';
        this.selectedDepartureAirport = null;
        this.selectedDepartureName = '';

        this.validateInsertedFlight = '';
    }

    handleRecordsPerPage(event){
        this.pageSize = event.target.value;
        this.refreshFlightsToDisplay();
    }

    previousPage(){
        this.pageNumber = this.pageNumber - 1;
        this.refreshFlightsToDisplay();
    }    
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.refreshFlightsToDisplay();
    }

    // Method to make a delay (300ms) when filtering by IATA Code
    delay(){
        clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.filterAirportData();
        }, 300);
    }

    filterAirportData(){
        // Clear before data
        this.filteredAirportDataNames = [];

        // Filter by IATA Code or selected
        this.filteredAirportData = this.airportData.filter(airport =>
            airport.nvl_fld_IATACode__c.includes(this.searchIATA.toUpperCase()) || airport.nvl_fld_IATACode__c == this.departureAirport  || airport.nvl_fld_IATACode__c == this.arrivalAirport
        );
        
        // Create list to display
        this.filteredAirportData.forEach(airportFiltered =>{
            let airportName = airportFiltered.Name+' ('+airportFiltered.nvl_fld_IATACode__c+')';
            this.filteredAirportDataNames.push({label: airportName, value: airportFiltered.nvl_fld_IATACode__c});
        });
    }

    refreshFlightsToDisplay(){
        this.flightsToDisplay = [];

        //Calculate total pages
        this.totalPages = Math.ceil(this.totalFlights / this.pageSize);

        //Set page number (validating min and max page)
        if (this.pageNumber <= 1){
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
        }

        //Set flights to display
        for (let i = (this.pageNumber-1) * this.pageSize; i<this.pageNumber*this.pageSize; i++){
            if (i < this.totalFlights){
                this.flightsToDisplay.push(this.flightsData[i]);
            }
        }
    }
}