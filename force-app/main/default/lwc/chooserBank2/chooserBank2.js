import { LightningElement, api } from 'lwc';

export default class ChooserBank2 extends LightningElement {
    @api switcherValue1;
    @api switcher1;
    @api buttonLabel1;
    @api isDisabled1;
    @api isFinish1;
    @api variant1;
    
    @api switcherValue2;
    @api switcher2;
    @api buttonLabel2;
    @api isDisabled2;
    @api isFinish2;
    @api variant2;

    @api buttonAlignment = "left";
}