import { LightningElement, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import setKey from '@salesforce/apex/OEEKeyHelpers.setKey';

const UPDATE_COMPLETE = new ShowToastEvent({title: 'Set Key', message: 'Value updated.', variant: 'success'});
const UPDATE_FAILED = new ShowToastEvent({title: 'Set Key', message: 'Value not updated.', variant: 'error'});

export default class SetOeeKey extends LightningElement {

    @api defaultkey;

    handleClick(e) {
        setKey({"key": this.refs.keyname.value, "value": this.refs.valuename.value}).then((result) => {
            if(result) {
                this.dispatchEvent(UPDATE_COMPLETE);
            } else {
                this.dispatchEvent(UPDATE_FAILED);
            }
        });
    }

}