import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEngagementData from '@salesforce/apex/EngagementSummaryController.getEngagementData';
import createFollowUpCall from '@salesforce/apex/EngagementSummaryController.createFollowUpCall';

export default class EngagementSummary extends LightningElement {
    @api recordId;
    opportunityAmount = 0;
    completedTasks = 0;
    upcomingEvents = 0;
    engagementName = '';

    @wire(getEngagementData, { recordId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.opportunityAmount = data.opportunityAmount;
            this.completedTasks = data.completedTasks;
            this.upcomingEvents = data.upcomingEvents;
        } else if (error) {
            console.error(error);
        }
    }

    createCall() {
        createFollowUpCall({ 
            recordId: this.recordId, 
            engagementName: this.engagementName 
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Follow-up call created!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.error(error);
        });
    }
}