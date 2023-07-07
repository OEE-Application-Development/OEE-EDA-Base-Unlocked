import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import datatableHelpers from "c/datatableHelpers";

/* General */
import refreshData from '@salesforce/apex/CombinedFunctions.refreshData';

/* Contact */
import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';


const contactColumns = [{label: 'Name', fieldName: CONTACT_NAME.fieldApiName, type: 'text'}, {label: 'Email', fieldName: CONTACT_EMAIL.fieldApiName, type: 'text'}, {label: '', type: 'button', typeAttributes: {label: 'Remove', name: 'removeContact'}, cellAttributes: {alignment: 'center'}}];
const contactFields = ['id', CONTACT_NAME.objectApiName+'.'+CONTACT_NAME.fieldApiName, CONTACT_EMAIL.objectApiName+'.'+CONTACT_EMAIL.fieldApiName];
const noContacts = [{'id': 'fakeid', 'Name' : 'No Contacts', 'Email': ''}];

const CONTACT_ADDED = new ShowToastEvent({title: 'Contact', message: 'Contact Added.', variant: 'success'});
const CONTACT_REMOVED = new ShowToastEvent({title: 'Contact', message: 'Contact Removed.', variant: 'error'});
export default class ContactSelector extends LightningElement {

    foundContact = null;
    handleContactChange(event) {
        if(event.detail) {
            if(event.detail.value.length > 0) {
                this.foundContact = event.detail.value[0];
            }
        } else {
            this.foundContact = null;
        }
    }

    handleAddContact(event) {
        if(!this.foundContact) return;

        if(this.selectedContacts[0].id == 'fakeid') {
            refreshData({ids: [this.foundContact], objectName: 'Contact', fieldsToRefresh: contactFields}).then((result) => {
                result = datatableHelpers.ided(result);
                this.selectedContacts = result;

                let toast = CONTACT_ADDED;
                toast.message = result[0].Name+' added to set.';
                this.dispatchEvent(CONTACT_ADDED);
            });
        } else {
            for(var i=0;i<this.selectedContacts.length;i++) {
                if(this.foundContact == this.selectedContacts[i].id) return; // Duplicate
            }
            refreshData({ids: [this.foundContact], objectName: 'Contact', fieldsToRefresh: contactFields}).then((result) => {
                result = datatableHelpers.ided(result);
                let cloned = structuredClone(this.selectedContacts);
                cloned.push(result[0]);
                this.selectedContacts = cloned;

                let toast = CONTACT_ADDED;
                toast.message = result[0].Name+' added to set.';
                this.dispatchEvent(CONTACT_ADDED);
            });
        }
        this.refs.contactlookup.reset();
        this.foundContact = null;
    }

    selectedContacts = noContacts;

    handleAddMultiple() {

    }

    get contactColumns() {
        return contactColumns;
    }
    handleContactAction(event) {
        if(event.detail.action.name == 'removeContact') {
            for(var i=0;i<this.selectedContacts.length;i++) {
                if(this.selectedContacts[i].id == event.detail.row.id) {
                    let cloned = structuredClone(this.selectedContacts).splice(i, 1);
                    this.selectedContacts = cloned;

                    let toast = CONTACT_REMOVED;
                    toast.message = this.selectedContacts[i].Name + ' removed from set.';
                    this.dispatchEvent(toast);
                    break;
                }
            }
            return;
        }
    }

    handleNext(event) {
        this.dispatchEvent(
            new CustomEvent("contactschosen", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    contacts: this.selectedContacts
                }
            })
        );
    }

}