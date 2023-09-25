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

    @api isInBank = false;

    handleClick(e) {
        if(this.isInBank) {
            this.dispatchEvent(new CustomEvent('switcher', {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    switcherValue: this.switcherValue
                }
            }));
        } else {
            this.switcher = this.switcherValue;
            if(this.isFinish) {
                this.dispatchEvent(new FlowNavigationFinishEvent());
            } else {
                this.dispatchEvent(new FlowNavigationNextEvent());
            }
        }
    }
}