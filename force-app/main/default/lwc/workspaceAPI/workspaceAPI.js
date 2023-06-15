const invokeWorkspaceAPI = (method, args) => {
  return new Promise((resolve, reject) => {
    const apiEvent = new CustomEvent("internalapievent", {
      bubbles: true,
      composed: true,
      cancelable: false,
      detail: {
        category: "workspaceAPI",
        methodName: method,
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
};

const getFocusedTab = () => {
  return invokeWorkspaceAPI('getFocusedTabInfo');
}

const closeCurrentTab = () => {
  getFocusedTab().then((tab) => {
      invokeWorkspaceAPI('closeTab', {
          tabId: tab.tabId
      });
  })
};

const refreshCurrentTab = (includeAllSubtabs) => {
  getFocusedTab().then((tab) => {
      invokeWorkspaceAPI('refreshTab', {
          tabId: tab.tabId,
          includeAllSubtabs: (includeAllSubtabs)?includeAllSubtabs:true
      })
  })
}

export {invokeWorkspaceAPI, getFocusedTab, closeCurrentTab, refreshCurrentTab}