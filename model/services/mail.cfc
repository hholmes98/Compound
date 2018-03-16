// model/services/mail
component accessors = true {

  variables.nl = chr(13) & chr(10);

  function sendPasswordResetEmail( dest_email, key, dest_url ) {

    var mailBody = 'Greetings!

Someone (possibly you) requested a password reset. If you requested this reset, please click the link below to confirm the reset.

' & application.base_url & dest_url & '/q/' & key & '

If it was not you, please disregard this email completely.

Sincerely, 
Your friends at ' & application.locale[session.auth.locale]['name'];

    // send the email
    cfmail(
        to = dest_email,
        from = application.admin_email,
        subject = "[" & application.locale[session.auth.locale]['name'] & "] Password Reset Request" ) {
      WriteOutput(mailBody);
    }

    // log the change request, for audit purposes.

  }

  function verifyUser( dest_email, plain_password ) {

    var mailBody = 'Welcome to ' & application.locale[session.auth.locale]['name'] & '!

Someone (possibly you) has created an account. If this is, in fact, you, here is your starting password:

' & plain_password & '

Use this as a temporary password to log in to your new account. We look forward to helping you become financially secure!

Be sure to update your password in profile > basic settings.

Sincerely,
Your friends at ' & application.locale[session.auth.locale]['name'];

    // send the email
    cfmail( 
        to = dest_email,
        from = application.admin_email,
        subject = "[" & application.locale[session.auth.locale]['name'] & "] New Account" ) {
      WriteOutput(mailBody);
    }

  }

  function sendError( dest_email, e, requested_url ) {

    var errorBody = '';
    var tagBody = '';
    var msg = "Unknown";
    var tagCount = 1;
    var offender = StructNew();

    errorBody &= 'URL: ' & requested_url & nl & nl;

    if ( StructKeyExists(e,'message') ) {
      msg = e.message;
      errorBody &= 'Message: ' & msg & nl & nl;
    }

    if ( StructKeyExists(e, 'stacktrace') ) {
      errorBody &= 'Stack Trace: ' & nl & e.stacktrace & nl & nl;
    }

    if ( StructKeyExists(e, 'tagcontext') ) {

      for (tag in e.tagcontext) {

        savecontent variable="tagBody" append=true {
          WriteDump( var=tag, format="text" );
        }

        if (tagCount == 1) {
          offender = tag;
        }

        tagCount++;
      }

      errorBody &= 'Start at:' & nl;
      errorBody &= '- Line: ' & offender.line & nl;
      errorBody &= '- Template: ' & offender.template & nl;
      errorBody &= '- Code: ' & nl & offender.codePrintPlain & nl & nl;

      errorBody &= 'Tag Context: ' & tagBody & nl & nl;

    }

    cfmail(
        to = dest_email,
        from = application.admin_email,
        subject = "[" & application.locale[session.auth.locale]['name'] & "] ERROR: " & msg ) {
      WriteOutput(errorBody);
    }

  }

}