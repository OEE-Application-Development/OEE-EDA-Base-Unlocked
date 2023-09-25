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
    @api variant;

    @api buttonAlignment = "left";

    handleClick(e) {
        this.switcher = this.switcherValue;
        if(this.isFinish) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        } else {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }
}