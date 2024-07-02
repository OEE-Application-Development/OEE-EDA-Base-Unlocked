import { LightningElement, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import isValidCreditPlan from '@salesforce/apex/QueryProgramCompletion.isValidCreditPlan';

const CLEAN_PROGRAM = new ShowToastEvent({title: 'Program Plan Validity', message: 'Program Plan appears valid.', variant: 'success'});
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
                message: result.join('<br />'),
                variant: 'error'
            }));
        });
    }

}