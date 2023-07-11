import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import datatableHelpers from "c/datatableHelpers";
import modalSingleInput from 'c/modalSingleInput';

/* General */
import refreshData from '@salesforce/apex/CombinedFunctions.refreshData';
import getContactsByEmails from '@salesforce/apex/CombinedFunctions.getContactsByEmails';

/* Contact */
import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';


const contactColumns = [{label: 'Name', fieldName: CONTACT_NAME.fieldApiName, type: 'text'}, {label: 'Email', fieldName: CONTACT_EMAIL.fieldApiName, type: 'text'}, {label: '', type: 'button', typeAttributes: {label: 'Remove', name: 'removeContact'}, cellAttributes: {alignment: 'center'}}];
const contactFields = ['id', CONTACT_NAME.objectApiName+'.'+CONTACT_NAME.fieldApiName, CONTACT_EMAIL.objectApiName+'.'+CONTACT_EMAIL.fieldApiName];
const noContacts = [{'id': 'fakeid', 'Name' : 'No Contacts', 'Email': ''}];

const CONTACT_ADDED = new ShowToastEvent({title: 'Contact', message: 'Contact Added.', variant: 'success'});
const CONTACT_REMOVED = new ShowToastEvent({title: 'Contact', message: 'Contact Removed.', variant: 'error'});
const MULTIPLE_CONTACT_ADDED = new ShowToastEvent({title: 'Contact', message: 'Multiple contacts added.', variant: 'success'});
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
        modalSingleInput.open({
            title: 'Paste Multiple Emails',
            content: 'Please separate emails by a \',\'. Spaces will be trimmed.',
            inputlabel: 'Emails',
            inputplaceholder: 'email1@colostate.edu,email2@colostate.edu...'
        }).then((result) => {
            if(result.ok && result.value) {
                getContactsByEmails({emails: result.value}).then((contactIds) => {
                    refreshData({ids: contactIds, objectName: 'Contact', fieldsToRefresh: contactFields}).then((result) => {
                        result = datatableHelpers.ided(result);
                        var cloned;
                        if(this.selectedContacts[0].id == 'fakeid') {
                            cloned = [];
                        } else {
                            cloned = structuredClone(this.selectedContacts);
                        }
                        for(var j=0;j<result.length;j++) {
                            var isDupe = false;
                            for(var i=0;i<this.selectedContacts.length;i++) {
                                if(result[j].id == this.selectedContacts[i].id) {isDupe=true;break;} // Duplicate
                            }
                            if(isDupe)continue;
                            cloned.push(result[j]);
                        }
                        if(cloned.length > 0)
                            this.selectedContacts = cloned;
        
                        this.dispatchEvent(MULTIPLE_CONTACT_ADDED);
                    });
                });
            }
        });
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
        var contactIds=[];
        for(var i=0;i<this.selectedContacts.length;i++) {
            contactIds.push(this.selectedContacts[i].id);
        }
        this.dispatchEvent(
            new CustomEvent("contactschosen", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    contacts: contactIds
                }
            })
        );
    }

    @api resetSearch() {
        this.selectedContacts = noContacts;
        this.refs.contactlookup.reset();
    }

}