import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import CPS_SECTION_ID from '@salesforce/schema/hed__Course_Offering__c.CPS_ID__c';
import CPS_SECTION_COURSE_ID from '@salesforce/schema/hed__Course_Offering__c.hed__Course__r.CPS_ID__c';

export default class CpsIframe extends LightningElement {

    @api cpsUrl = 'https://test.cps.online.colostate.edu/course-search-results(modal:section-view-modify/146/62175)';

    /*@api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [CPS_SECTION_ID, CPS_SECTION_COURSE_ID] })
    getSectionCpsIds({error, data}) {
        if(data) {
            let cpsSectionId = getFieldValue(data, CPS_SECTION_ID);
            let cpsCourseId = getFieldValue(data, CPS_SECTION_COURSE_ID);

            if(cpsCourseId && cpsSectionId) {
                this.cpsUrl = this.cpsUrl+'course-search-results(modal:section-view-modify/'+cpsCourseId+'/'+cpsSectionId+')';
            }
        }
    }*/

}