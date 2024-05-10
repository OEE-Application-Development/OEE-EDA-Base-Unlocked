import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import refreshData from '@salesforce/apex/CombinedFunctions.refreshData';
import getPublicChannelByName from '@salesforce/apex/CombinedFunctions.getPublicChannelByName';
import getWorkspaceByName from '@salesforce/apex/CombinedFunctions.getWorkspaceByName';
import evalCMSContent from '@salesforce/apex/CombinedFunctions.evalCMSContent';
import setWorkspaceFile from '@salesforce/apex/CombinedFunctions.setWorkspaceFile';
import getContentIdForCMSKey from '@salesforce/apex/CombinedFunctions.getContentIdForCMSKey';
import clearWorkspaceFile from '@salesforce/apex/CombinedFunctions.clearWorkspaceFile';

const INVALID_CHANNEL = new ShowToastEvent({title: 'Invalid Channel', message: 'The channel name provided is either missing, invalid, or not accessible.', variant: 'error'});
const INVALID_WORKSPACE = new ShowToastEvent({title: 'Invalid Workspace', message: 'The workspace name provided could not be found.', variant: 'error'});
const INVALID_KEY = new ShowToastEvent({title: 'Invalid Content Key', message: 'Could not find content with the provided key. Please ensure the key is correct and exists in the channel and is published.', variant: 'error'});
const FILE_SUCCESS = new ShowToastEvent({title: 'CMS Content Attached', message: 'The CMS content has been attached to the selected record.', variant: 'success'});
const REMOVE_SUCCESS = new ShowToastEvent({title: 'CMS Content Removed', message: 'CMS content unlinked from this record.', variant: 'success'});
export default class CmsFileSelector extends NavigationMixin(LightningElement) {

    @api workspaceName = '';
    get isWorkspaceUnavailable() {
        return this.workspaceName == '';
    }
    get workspaceBtnLabel() {
        if(this.workspaceName == '') {
            return 'Workspace Not Set';
        } else {
            return 'View CMS Workspace';
        }
    }

    workspaceId;
    @wire(getWorkspaceByName, { workspaceName: '$workspaceName' })
    handleSetWorkspaceId({error, data}) {
        if(error) {
            this.dispatchEvent(INVALID_WORKSPACE);
        }
        if(data) {
            this.workspaceId = data;
        }
    }

    isImg = false;
    get imgClass() {
        return(this.isImg)?"show":"hidden";
    }

    @api channelName = '';
    channelId;

    @api fileField;
    @api publicUrlField;

    @api acceptedFormats;

    objectType = '';

    @track contentKey = '';
    fileSrc = '';

    get contentBtnLabel() {
        return (this.contentKey==''||this.contentKey==null)?"No Key":"View Content";
    }

    get isContentUnavailable() {
        return (this.contentKey==''||this.contentKey==null);
    }

    publicUrl;
    showPublicUrl = false;
    get publicUrlClass() {
        return (this.showPublicUrl)?"show":"hidden";
    }

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: ['*.Id'] })
    getObject({error, data}) {
        if(data) {
            this.objectType = data.apiName;
            refreshData({ids: [this.recordId], objectName: data.apiName, fieldsToRefresh: [this.fileField, this.publicUrlField]})
                .then((result) => {
                    if(result[0][this.fileField]) {
                        this.contentKey = result[0][this.fileField];
                        this.fileSrc = '/cms/media/'+result[0][this.fileField];
                    }
                    if(result[0][this.publicUrlField]) {
                        this.publicUrl = result[0][this.publicUrlField];
                        this.showPublicUrl = true;
                    } else {
                        this.showPublicUrl = false;
                    }
                })
                .catch((error) => {
                    if(error.body.exceptionType == 'System.QueryException') {
                        this.dispatchEvent(INVALID_FIELD);
                    }
                });
        }
    }

    @wire(getPublicChannelByName, {channelName: '$channelName'})
    getChannel({error, data}) {
        if(data) {
            this.channelId = data;
        } else {
            this.dispatchEvent(INVALID_CHANNEL);
        }
    }

    @wire(evalCMSContent, {channelId: '$channelId', contentKey: '$contentKey'})
    handleCmsAttr({error, data}) {
        if(data) {
            this.isImg = data.isImage;
            if(data.url) {
                this.publicUrl = data.url;
                this.showPublicUrl = true;
            }
        }
    }

    updateKey(e) {
        setWorkspaceFile({recordId: this.recordId, objectName: this.objectType, fieldName: this.fileField, publicUrlField: this.publicUrlField, channelId: this.channelId, contentKey: this.refs.contentKeyInput.value})
            .then((result) => {
                if(result.success){
                    this.dispatchEvent(FILE_SUCCESS);
                    this.fileSrc = '/cms/media/'+this.refs.contentKeyInput.value;
                    this.isImg = result.isImage;
                    this.publicUrl = result.url;
                } else {
                    this.dispatchEvent(new ShowToastEvent({title: 'CMS Content Not Attached', message: result.message, variant: 'error'}));
                }
                this.contentKey = this.refs.contentKeyInput.value;
            })
            .catch((error) => {console.warn(error);this.dispatchEvent(INVALID_KEY);});
    }

    handleViewWorkspace(e) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/cms/spaces/'+this.workspaceId
            }
        });
    }

    handleViewContent(e) {
        if(this.contentKey == null || this.contentKey == ''){this.dispatchEvent(INVALID_KEY); return;}
        getContentIdForCMSKey({key: this.contentKey}).then((result) => {
            if(result == null){this.dispatchEvent(INVALID_KEY); return;}
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'lightning/r/ManagedContent/'+result+'/view'
                }
            });
        });
    }

    handleClearContent(e) {
        clearWorkspaceFile({recordId: this.recordId, objectName: this.objectType, fieldName: this.fileField, publicUrlField: this.publicUrlField})
            .then(() => {
                this.contentKey = null;
                this.fileSrc = null;
                
                this.publicUrl = '';
                this.showPublicUrl = false;

                this.dispatchEvent(REMOVE_SUCCESS);
            })
            .catch((error) => {
                console.warn(error);
            });
    }

}