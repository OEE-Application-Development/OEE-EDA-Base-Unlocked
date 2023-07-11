import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalSingleInput extends LightningModal {
    @api title;
    @api content;

    @api inputlabel;
    @api inputvalue;
    @api inputplaceholder;

    handleSubmit(event) {
        event.preventDefault();

        this.handleOk();
    }

    handleOk() {
        this.close({ok: true, value: this.refs.requestedtextinput.value});
    }

    handleCancel() {
        this.close({ok: false});
    }
}