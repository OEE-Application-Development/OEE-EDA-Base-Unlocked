import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const NO_CONTACTS = new ShowToastEvent({title: 'No Contacts', message: 'Please choose contacts with "Save & Continue" before moving on.', variant: 'error'});
export default class CreateRegistrationBatch extends LightningElement {

    @api recordId;

    section='contacts';

    handleContactsChosen(event) {
        this.contactsSelected = event.detail.contacts;
        this.section='sponsor';
    }

    checktoggle(event) {
        if(event.detail.openSections != 'contacts' && this.contactsSelected.length == 0) {
            this.dispatchEvent(NO_CONTACTS);
            this.dispatchEvent(new CustomEvent("sectiontoggle", {details: {openSections: 'contacts'}, target: this.refs.regaccordion}));
        }
    }

    contactsSelected=[];
    get selectedContactsCount() {
        return this.contactsSelected.length;
    }

    get selectedSponsor() {
        
    }

    submitRegistration() {

    }

}