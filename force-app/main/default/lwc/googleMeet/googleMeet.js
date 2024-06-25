import { LightningElement, wire, track, api } from 'lwc';
import getGoogleMeetCredentials from '@salesforce/apex/GoogleMeetController.getGoogleMeetCredentials';
import isAccessTokenExpire from '@salesforce/apex/GoogleMeetController.isAccessTokenExpire';
import getGoogleMeetings from '@salesforce/apex/GoogleMeetController.getGoogleMeetings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class GoogleMeet extends LightningElement {
    @api recordId;
    @track systemVar1 = { googleMeetCred: {}, eventData: [], isEventTableVisible: true };

    @track eventColumn = [{ label: 'Title', fieldName: 'Title__c', initialWidth: 120, },
    { label: 'Start Time', fieldName: 'Start_Time__c', initialWidth: 150, type: 'date', typeAttributes: { day: "2-digit", hour: "2-digit", minute: "2-digit", year: "numeric", month: "short" } },
    { label: 'End Time', fieldName: 'End_Time__c', initialWidth: 150, type: 'date', typeAttributes: { day: "2-digit", hour: "2-digit", minute: "2-digit", year: "numeric", month: "short" } }, { label: 'Description', fieldName: 'Description__c' },
    { type: "button", label: 'Join Meeting', initialWidth: 130, typeAttributes: { label: 'Join Meeting', name: 'meeting', title: 'Join Meeting', disabled: false, value: 'view', variant: 'Brand' } }]
    wiredEventDate;

    @wire(getGoogleMeetCredentials)
    googleMeetCred(result) {
        this.wiredEventDate = result;
        if (result.data) {
            this.systemVar1.googleMeetCred = JSON.parse(JSON.stringify(result.data))
            isAccessTokenExpire({ gmC: result.data })
                .then(eventResult => {
                    if (eventResult) { this.showToast('Refresh Token Expired.', 'Your refresh Token is expired. Please click on the configuration button to generate new token', 'error') }
                    if (!eventResult) {  this.getGoogleEvent();  }
                })
                .catch(error => { console.log('error 001', error); })
        }
        else if (result.error) { console.log('error 002', error); }

    }

   getGoogleEvent(){
       getGoogleMeetings({ accountId: this.recordId })
                            .then(eventResult => {
                                this.systemVar1.eventData = JSON.parse(JSON.stringify(eventResult));
                                console.log('this.systemVar1.eventData', this.systemVar1.eventData);
                            })
                            .catch(error => { console.log('error 003', error); })
   }

    handleConfiguration() {
        let tempUrl = 'https://accounts.google.com/o/oauth2/auth?client_id=' + this.systemVar1.googleMeetCred.Client_Id__c + '&redirect_uri='
            + this.systemVar1.googleMeetCred.Redirect_uri__c + '&access_type=offline&prompt=consent&response_type=code&scope=' + this.systemVar1.googleMeetCred.Scope__c;
        window.open(tempUrl, '_blank');
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title: title, message: message, variant: variant, mode: 'dismissable' });
        this.dispatchEvent(event);
    }
    handleJoinMeeting(event) { window.open(event.detail.row.Meeting_Link__c, '_blank'); }
    handleAddNewMeeting() { this.systemVar1.isEventTableVisible = false; }
    handleReset() { this.resetFieldAfterSave(); }
    handleEventSuccess() { 
       //refreshApex(this.wiredEventDate);
       setTimeout(()=>{
          this.dispatchEvent(new CloseActionScreenEvent());
         this.resetFieldAfterSave();
       },400)
       
       
    }
    resetFieldAfterSave() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) { inputFields.forEach(field => { field.reset(); }); }
        this.systemVar1.isEventTableVisible = true;
    }


}