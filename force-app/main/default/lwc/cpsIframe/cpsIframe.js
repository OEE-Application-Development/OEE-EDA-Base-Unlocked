import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import workspaceAPI from 'c/workspaceAPI';

import CPS_COURSE_ID from '@salesforce/schema/hed__Course__c.CPS_ID__c';

import CPS_SECTION_ID from '@salesforce/schema/hed__Course_Offering__c.CPS_ID__c';
import CPS_SECTION_COURSE_ID from '@salesforce/schema/hed__Course_Offering__c.hed__Course__r.CPS_ID__c';

import CPS_TERM_ID from '@salesforce/schema/hed__Term__c.CPS_ID__c';

export default class CpsIframe extends LightningElement {

    @api cpsUrl;

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', optionalFields: [CPS_SECTION_ID, CPS_SECTION_COURSE_ID, CPS_COURSE_ID, CPS_TERM_ID] })
    getCpsObject({error, data}) {
        if(data) {
            if(data.apiName == 'hed__Course__c') {
                this.cpsUrl = this.getCpsCourseUrl(data);
            } else if(data.apiName == 'hed__Course_Offering__c') {
                this.cpsUrl = this.getCpsSectionUrl(data);
            } else if(data.apiName == 'hed__Term__c') {
                this.cpsUrl = this.getCpsTermUrl(data);
            }
            //Not the right page.
        }

        setTimeout(() => {try{workspaceAPI.refreshCurrentTab();}catch(e){}}, 3000);
    }

    @track isFrameHidden = true;

    getCpsCourseUrl(data) {
        let courseId = getFieldValue(data, CPS_COURSE_ID);
        this.isFrameHidden = this.isValueNotANumber(courseId);
        return this.cpsUrl+'course-search-results(modal:course-view-modify/'+courseId+')';
    }

    getCpsSectionUrl(data) {
        let courseId = getFieldValue(data, CPS_SECTION_COURSE_ID);
        let sectionId = getFieldValue(data, CPS_SECTION_ID);
        this.isFrameHidden = this.isValueNotANumber(courseId) || this.isValueNotANumber(sectionId);
        return this.cpsUrl+'course-search-results(modal:section-view-modify/'+courseId+'/'+sectionId+')';
    }

    getCpsTermUrl(data) {
        let termId = getFieldValue(data, CPS_TERM_ID);
        this.isFrameHidden = this.isValueNotANumber(termId);
        return this.cpsUrl+'admin/(modalAdmin:term-view-modify/'+termId+')';
    }

    isValueNotANumber(val) {
        if(val == null) return true;
        return isNaN(val);
    }

    get isFrameHiddenClass() {
        return (this.isFrameHidden)?"hidden":"";
    }

    get isShowErrorMessage() {
        return (this.isFrameHidden)?"":"hidden";
    }

}