import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import refreshData from '@salesforce/apex/CombinedFunctions.refreshData';
import associateFile from '@salesforce/apex/CombinedFunctions.associateFile';

const INVALID_FIELD = new ShowToastEvent({title: 'Field Not Found', message: 'Please edit the Lightning Component - could not find the field specified by Field Field Dev Name.', variant: 'error'});
const UPLOAD_COMPLETE = new ShowToastEvent({title: 'Upload Complete', message: 'Upload complete - associating with record...', variant: 'success'});
const FILE_SET_COMPLETE = new ShowToastEvent({title: 'Association Complete', message: 'File association complete! Share with others using provided link.', variant: 'success'});
export default class ObjectAttachedImage extends LightningElement {

    @api fileField;

    objectType;
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: ['*.Id'] })
    getObject({error, data}) {
        if(data) {
            this.objectType = data.apiName;
            refreshData({ids: [this.recordId], objectName: data.apiName, fieldsToRefresh: [this.fileField]})
                .then((result) => {
                    // Guaranteed a row 0
                    this.token = result[0][this.fileField];
                })
                .catch((error) => {
                    if(error.body.exceptionType == 'System.QueryException') {
                        this.dispatchEvent(INVALID_FIELD);
                    }
                });
        }
    }
    
    @api label;
    get getLabel() {
        if(this.label == null) {
            return 'Upload File';
        }
        return this.label;
    }

    @api acceptedFormats;
    get getAcceptedFormats() {
        if(this.acceptedFormats == null) {
            return ['.png', '.jpg', '.gif'];
        }

        return this.acceptedFormats.split(',');
    }

    handleUploadFinished(event) {
        if(event.type == 'uploadfinished') {
            // Upload completed successfully!
            this.dispatchEvent(UPLOAD_COMPLETE);

            let f1 = event.detail.files[0];
            associateFile({recordId: this.recordId, contentDocumentId: f1.documentId, objectName: this.objectType, fieldName: this.fileField})
                .then(() => {this.dispatchEvent(FILE_SET_COMPLETE);})
                .catch((error) => {console.log(error);});
        }
    }

}