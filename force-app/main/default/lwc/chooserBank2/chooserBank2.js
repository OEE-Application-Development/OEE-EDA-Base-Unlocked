import { LightningElement, api } from 'lwc';
import {
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';

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

    handleSwitcher1(e) {
        this.switcher1 = this.switcherValue1;
        if(this.isFinish) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        } else {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }

    handleSwitcher2(e) {
        this.switcher2 = this.switcherValue2;
        if(this.isFinish) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        } else {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }
}