import { LightningElement, api, wire } from 'lwc';

import getPlanCompletion from '@salesforce/apex/QueryProgramCompletion.getPlanCompletion';

export default class ProgramPlanProgress extends LightningElement {

    @api contactId;
    @api programPlanId;// Program Plan ID, not AccountId

    @wire(getPlanCompletion, {contactId: '$contactId', programPlanId: '$programPlanId'})
    displayCompletionData({error, data}) {
        console.log(data);
    }

}