import { LightningElement, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import isValidCreditPlan from '@salesforce/apex/QueryProgramCompletion.isValidCreditPlan';
import getPlanCompletion from '@salesforce/apex/QueryProgramCompletion.getPlanCompletion';

const CLEAN_PROGRAM = new ShowToastEvent({title: 'Program Plan Validity', message: 'Program Plan appears valid.', variant: 'success'});
const NO_CONTACT = new ShowToastEvent({title: 'Program Progess', message: 'No Contact Chosen.', variant: 'error'});
export default class ProgramPlanButtons extends LightningElement {

    @api recordId;

    checkPlan(e) {
        isValidCreditPlan({programPlanId: this.recordId}).then(result => {
            if(result.length == 0) {
                this.dispatchEvent(CLEAN_PROGRAM);
                return;
            }

            this.dispatchEvent(new ShowToastEvent({
                title: 'Program Plan Validity',
                message: result.join("\r\n"),
                variant: 'error',
                mode: 'sticky'
            }));
        });
    }

    showStudent(e) {
        this.showContactCard = !this.showContactCard;
    }

    showContactCard = false;
    get studentProgressLabel() {
        return (this.showContactCard)?"Close Student Progress":"Open Student Progress";
    }
    get contactCardClass() {
        return (this.showContactCard)?"":"hidden";
    }

    checkStudent(event) {
        if(event.detail.contacts.length == 0 || event.detail.contacts[0] == "fakeid") {
            this.dispatchEvent(NO_CONTACT);
            return;
        }
        getPlanCompletion({contactId: event.detail.contacts[0], programPlanId: this.recordId}).then(result => {
            console.log(result);
            this.dispatchEvent(new ShowToastEvent({title: 'Student Plan Progress', message: 'Status: {0} / Required Credits: {1} / Earned Credits: {2}', messageData: [result.Result.Status, result.Result.TotalCredits, result.Result.EarnedCredits]}))
        });
    }

}