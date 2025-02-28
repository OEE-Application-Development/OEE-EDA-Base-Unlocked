import { LightningElement, api } from 'lwc';

export default class MergeSettingsManagement extends LightningElement {

    @api objectType;

    get lwcTitle() {
        return 'Managing '+this.objectType;
    }

}