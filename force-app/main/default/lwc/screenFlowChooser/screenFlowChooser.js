import { LightningElement, api } from 'lwc';
import {
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';

const DEFAULT_NEXT = "Next";
export default class ScreenFlowChooser extends LightningElement {
    @api switcherValue = DEFAULT_NEXT;
    @api switcher;

    @api buttonLabel;
    @api isDisabled = false;
    @api isFinish = false;

    handleClick(e) {
        console.log(e);
        this.switcher = this.switcherValue;
        console.log("test#2");
        if(this.isFinish) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        } else {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }
}