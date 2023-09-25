import { LightningElement, api } from 'lwc';

export default class ChooserBank4 extends LightningElement {
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
    
    @api switcherValue3;
    @api switcher3;
    @api buttonLabel3;
    @api isDisabled3;
    @api isFinish3;
    @api variant3;
    
    @api switcherValue4;
    @api switcher4;
    @api buttonLabel4;
    @api isDisabled4;
    @api isFinish4;
    @api variant4;

    @api buttonAlignment = "left";
}