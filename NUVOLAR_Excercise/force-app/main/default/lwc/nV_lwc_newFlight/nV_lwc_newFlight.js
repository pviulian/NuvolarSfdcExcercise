// Imports the necessary data for correct functionality.
import { LightningElement, track, wire } from "lwc";
import retrieveAirport from "@salesforce/apex/NV_cls_controller.retrieveAirport";
import newAirport from "@salesforce/apex/NV_cls_controller.newAirport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveFlight from "@salesforce/apex/NV_cls_controller.saveFlight";
import getFlightDataList from "@salesforce/apex/NV_cls_controller.getFlightDataList";
export default class NV_lwc_newFlight extends LightningElement {
  //Track input data by name

  @track modalClass = "slds-show";
  @track modalNewAirport = "slds-hide";
  @track backdropClass = "slds-hide";
  @track modalNewAirportForm = "slds-hide";
  @track showNewAirportForm = false;
  @track departureAirport = "";
  @track arrivalAirport = "";
  @track departureAirportExists;
  @track arrivalAirportExists;
  @track iataCode = "";
  @track airportName = "";
  @track latitudeAirport = null;
  @track longitudeAirport = null;
  @track aeropuertoKO = false;
  @track aeropuertoOK = true;
  @track flightDetails;
  @wire(getFlightDataList) flightDataList;

  //Method which closes "new airport" dialog and reload page if operation is cancelled.
  closeDialog() {
    this.modalNewAirport = "slds-hide";
    this.showNewAirportForm = false;
    this.aeropuertoKO = false;
    // Clear introduced data
    this.departureAirport = "";
    this.arrivalAirport = "";

    setTimeout(() => {
      location.reload();
    }, 300);
  }
  //Method which clear introduced data in the first modal, reloads page.
  clearData() {
    // Clear introduced data
    this.departureAirport = "";
    this.arrivalAirport = "";
    setTimeout(() => {
      location.reload();
    }, 300);
  }

  // Method to add delay to checkAirportExistence method.
  addDelay(fn, delay) {
    let timer;

    return function () {
      const context = this;
      const args = arguments;
      clearTimeout(timer);
      timer = setTimeout(() => {
        fn.apply(context, args);
      }, delay);
    };
  }
  // Method which checks if airports exists, if not, displays a popup to create a new one.
  checkAirport(event) {
    const fieldName = event.target.name;
    const fieldValue = event.target.value;

    const valueUpperCase = fieldValue.toUpperCase();

    const isTextOnly = /^[a-zA-Z]+$/.test(fieldValue);

    this[fieldName] = valueUpperCase;
    console.log(fieldName);
    if (
      (fieldName === "departureAirport" || fieldName === "arrivalAirport") &&
      fieldValue.length === 3 &&
      isTextOnly
    ) {
      this.iataCode = valueUpperCase;
      console.log(fieldValue.length);
      this.delayCheckAirportExistence();
    }
  }

  // method which fetch data with SFDC
  checkAirportExistence() {
    retrieveAirport({ iataCode: this.departureAirport })
      .then((result) => {
        this.departureAirportExists = result;
        if (this.departureAirportExists === "airportOK") {
          this.modalNewAirport = "slds-hide";
        } else {
          this.aeropuertoKO = true;
          this.modalNewAirport = "slds-show";
        }
      })
      .catch((error) => {
        alert("The following airport does not exists in our database: ", error);
      });
    
    retrieveAirport({ iataCode: this.arrivalAirport })
      .then((result) => {
        this.arrivalAirportExists = result;
        if (this.arrivalAirportExists === "airportOK") {
          this.modalNewAirport = "slds-hide";
        } else {
          this.aeropuertoKO = true;
          this.modalNewAirport = "slds-show";
        }
      })
      .catch((error) => {
        alert("The following airport does not exists in our database: ", error);
      });
  }
  // method which delays inputed data to 500ms
  delayCheckAirportExistence = this.addDelay(this.checkAirportExistence, 500);

  //method which display new airport form modal 
  registerNewAirport() {
    this.showNewAirportForm = true;
    this.modalNewAirport = "slds-hide";
  }

  // method wich saves new airport in SFDC
  saveNewAirport(event) {
    const fieldName = event.target.name;
    const fieldValue = event.target.value;
    const valueUpperCase = fieldValue.toUpperCase();

    // Actualiza la variable correspondiente
    if (fieldName === "airportName") {
      this.airportName = valueUpperCase;
    } else if (fieldName === "iataCode") {
      this.iataCode = valueUpperCase;
    } else if (fieldName === "latitudeAirport") {
      this.latitudeAirport = parseFloat(fieldValue);
    } else if (fieldName === "longitudeAirport") {
      this.longitudeAirport = parseFloat(fieldValue);
    }
  }

  // handler method to save data in sfdc
  handleSaveAirport() {
    newAirport({
      name: this.airportName,
      iataCode: this.iataCode,
      longitude: this.longitudeAirport,
      latitude: this.latitudeAirport,
    })
      .then((result) => {
        console.log("Result of Apex call:", result);

        if (result && result.length === 0) {
          // Show a success toast
          this.showToast("Success", "Airport created successfully", "success");

          // Optionally, you can also reload the page or perform other actions here
          setTimeout(() => {
            location.reload();
          }, 2000);
        } else {
          const exceptionMessage = result && result[0]; // assuming result is an array with the exception message

          // Handle other cases or show an error toast with the exception message
          this.showToast(
            "Error",
            `Failed to create airport. Exception: ${exceptionMessage}`,
            "error"
          );
        }
      })
      .catch((error) => {
        const exceptionMessage = error.body
          ? error.body.message
          : "An unexpected error occurred";

        // Handle other cases or show an error toast with the exception message
        this.showToast(
          "Error",
          `Failed to create airport. Exception: ${exceptionMessage}`,
          "error"
        );
      });
  }

  //method which calculates flight distance betweeen airports.
  calculateFlight() {
    saveFlight({
      departureAirport: this.departureAirport,
      arrivalAirport: this.arrivalAirport,
    })
      .then((result) => {
        // Display a success toast
        console.log("Resultado del vuelo:", result);

        this.showToast("Success", "Flight saved successfully", "success");
        this.flightDetails = result;
        setTimeout(() => {
          location.reload();
        }, 300);
      })
      .catch((error) => {
        // Display an error toast with the error message
        this.showToast("Error", "An error occurred: " + error.message, "error");
      });
  }

  //getMethod to display data in form.
  get hasFlightData() {
    return (
      this.flightDataList &&
      this.flightDataList.data &&
      this.flightDataList.data.length > 0
    );
  }

  //showToasts method.
  showToast(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
    });
    this.dispatchEvent(toastEvent);
  }
}
