import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RouteMessageToToastEvent extends LightningElement {
    @api title;
    @api message;
    @api messageData;
    @api variant;
    @api mode;
    @api show;

    connectedCallback() {
        if(this.show) {
            if(this.messageData) {
                this.dispatchEvent(new ShowToastEvent({
                    title: this.title,
                    message: this.message,
                    messageData: [this.messageData],
                    variant: this.variant,
                    mode: this.mode,    
                }));
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: this.title,
                    message: this.message,
                    variant: this.variant,
                    mode: this.mode,    
                }));
            }
        }
    }
}