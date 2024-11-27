import { LightningElement, api } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import LightningConfirm from 'lightning/confirm';
import startBatchFromButton from '@salesforce/apex/CaseTriggerHandler.startBatchFromButton';

export default class LwcButton extends LightningElement {
    @api recordId;

    handleClick() {
        startBatchFromButton({caseId: this.recordId}).then(() => {
            this.handlepopup();
        })
        .catch((error) => {
            console.error('Error field update error:', error);
        });
    }

    async handlepopup() {
        const result = await LightningConfirm.open({
            message: 'Reason Description Fiel API Update',
            theme: 'info', 
            label: 'Reason Description',
        });

        if(result){
            this.dispatchEvent(new RefreshEvent());
        }
    }
}