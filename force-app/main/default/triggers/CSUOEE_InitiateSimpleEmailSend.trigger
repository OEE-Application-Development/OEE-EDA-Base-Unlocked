trigger CSUOEE_InitiateSimpleEmailSend on Email_Simple_Request__c (before insert) {
    List<Messaging.SingleEmailMessage> emails =  new List<Messaging.SingleEmailMessage>();
    for(Email_Simple_Request__c request : (List<Email_Simple_Request__c>) Trigger.new) {
        if(String.isBlank(request.Email_Recipient_List__c) || request.Email_Recipient_List__c == null) {
            request.addError('Recipient List cannot be empty.');
            continue;
        }
        List<String> recipients = request.Email_Recipient_List__c.split(',');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipients);
        email.setSubject(request.Name);
        email.setHtmlBody(request.Email_Body__c);

        emails.add(email);
    }

    Messaging.sendEmail(emails, false);
}