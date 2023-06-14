import { LightningElement } from 'lwc';

export default class WorkspaceAPI extends LightningElement {

    closeCurrentTab() {
        this.getFocusedTab().then((tab) => {
            this.invokeWorkspaceAPI('closeTab', {
                tabId: tab.tabId
            });
        })
    }

    refreshCurrentTab(includeAllSubtabs) {
        this.getFocusedTab().then((tab) => {
            this.invokeWorkspaceAPI('refreshTab', {
                tabId: tab.tabId,
                includeAllSubtabs: (includeAllSubtabs)?includeAllSubtabs:true
            })
        })
    }

    getFocusedTab() {
        return this.invokeWorkspaceAPI('getFocusedTabInfo');
    }

    invokeWorkspaceAPI(method, args) {
      return new Promise((resolve, reject) => {
        const apiEvent = new CustomEvent("internalapievent", {
          bubbles: true,
          composed: true,
          cancelable: false,
          detail: {
            category: "workspaceAPI",
            methodName: method,//"getFocusedTabInfo",
            methodArgs: args,
            callback: (err, response) => {
              if (err) {
                  return reject(err);
              } else {
                  return resolve(response);
              }
            }
          }
        });
   
        window.dispatchEvent(apiEvent);
      });
    }

}