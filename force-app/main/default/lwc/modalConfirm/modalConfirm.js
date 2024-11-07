import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalConfirm extends LightningModal {
    @api title;
    @api content;

    handleOk() {
        this.close(true);
    }

    handleCancel() {
        this.close(false);
    }

    @api forceOk() {
        this.close(true);
    }

    @api forceCancel() {
        this.close(false);
    }
}