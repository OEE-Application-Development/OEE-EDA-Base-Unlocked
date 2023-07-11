import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Offering */
import IS_CREDIT from '@salesforce/schema/hed__Course_Offering__c.Is_Credit__c';

/* General */
import modalConfirm from 'c/modalConfirm';
import workspaceAPI from 'c/workspaceAPI';

import refreshData from '@salesforce/apex/CombinedFunctions.refreshData';
import createRegistrationBatch from '@salesforce/apex/CombinedFunctions.createRegistrationBatch';

const NO_CONTACTS = new ShowToastEvent({title: 'No Contacts', message: 'Please choose contacts with "Save & Continue" before moving on.', variant: 'error'});
const NO_CONTACTS_SUBMIT = new ShowToastEvent({title: 'No Contacts', message: 'Please choose contacts with "Save & Continue" before submitting!', variant: 'error'});
const SUBMITTED = new ShowToastEvent({title: 'Registration Sent', message: 'Registration batch created! If PE is included, the invoice will appear momentarily. If this is a credit section, we are currently attempting Banner XE request.', variant: 'success'});
export default class CreateRegistrationBatch extends LightningElement {

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [IS_CREDIT] })
    offering;

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

    sponsor;
    handleSponsorNext(event) {
        if(this.refs.sponsorlookup.value) {
            this.sponsor = this.refs.sponsorlookup.value;
            this.section = 'review';
            refreshData({ids: [this.sponsor], objectName: 'Account', fieldsToRefresh: ['Name']}).then((result) => {
                this.sponsorName = result[0].Name;
            });
        } else {
            this.sponsorName = 'No Sponsor Selected';
        }
    }

    sponsorName = 'No Sponsor Selected';
    get selectedSponsor() {
        return this.sponsorName;
    }

    submitRegistration() {
        if(this.contactsSelected.length == 0) {
            this.dispatchEvent(NO_CONTACTS_SUBMIT);
            return;
        }

        var message = '';
        if(getFieldValue(this.offering.data, IS_CREDIT)) {
            message = 'Since this is a credit offering, after submission, Banner XE will be attempted.';
        } else {
            message = 'Since this is a PE offering, after submission, an invoice will be generated per student. If a sponsor was provided, they will also receive an invoice. We will automatically transfer the amount specified.';
        }
        modalConfirm.open({
            title: 'Confirm Submission',
            content: message
        }).then((result) => {
            console.log({offerings: [this.recordId], contacts: this.contactsSelected, sponsorAccount: this.sponsor, responsibility: this.refs.sponsorresponsibility.value});
            if(result) {
                createRegistrationBatch({offerings: [this.recordId], contacts: this.contactsSelected, sponsorAccount: this.sponsor, responsibility: this.refs.sponsorresponsibility.value}).then(() => {
                    this.dispatchEvent(SUBMITTED);
                    this.refs.sponsorlookup.reset();
                    this.refs.contactselector.resetSearch();

                    this.contactsSelected = [];
                    this.sponsorName = 'No Sponsor Selected';
                });
            }
        });
    }

}