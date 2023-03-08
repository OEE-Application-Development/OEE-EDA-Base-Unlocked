import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalAlert extends LightningModal {
    @api title;
    @api content;

    handleOk() {
        this.close(true);
    }

}