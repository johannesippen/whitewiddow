var Mandrill = require('mandrill');
Mandrill.initialize('Ui-SvJwQFD75FNqNFc3WTg');

var sendEmailInvitation = function(sendFrom, sendFromName, sendTo, sendToName, emailContent) {
  var emailSubject = sendFromName +  " wants to be your friend on Midddle!";
  Mandrill.sendEmail({
    message: {
      text: emailContent,
      subject: emailSubject,
      from_email: sendFrom,
      from_name: sendFromName,
      to: [
        {
          email: sendTo,
          name: sendToName
        }
      ]
    },
    async: true
  },{
    success: function(httpResponse) {
      console.log(httpResponse);
      response.success("Email sent!");
    },
    error: function(httpResponse) {
      console.error(httpResponse);
      response.error("Uh oh, something went wrong");
    }
  });
};
