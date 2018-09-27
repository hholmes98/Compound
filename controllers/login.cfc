    // controllers/login
component accessors = true {

  property userService;
  property mailService;
  property preferenceService;
  property cardService;
  property paymentService;
  property tokenService;

  function init( fw ) {

    variables.fw = fw;

  }

  function before( struct rc ) {
    // you must be logged in for 'logout','updateConfirm' methods, and
    // must be logged out for all others. Otherwise, back to main.
    // TODO: break this out into
    // 1. methods that require isLoggedin
    // 2. methods that require !isLoggedin, and
    // 3. methods than don't care/can handle either (sso)

    switch( variables.fw.getItem() ) {

      // REQUIRES: logged in
      case 'logout':
      case 'updateConfirm':

        if ( !(StructKeyExists( session,'auth' ) && session.auth.isLoggedIn ) )
          variables.fw.redirect( 'budget' );

        break;

    }

    /* old
    if ( structKeyExists( session, 'auth' ) && 
        session.auth.isLoggedIn &&
        variables.fw.getItem() != 'logout' && 
        variables.fw.getItem() != 'updateConfirm' ) {

      variables.fw.redirect( 'budget' );

    }
    */

    rc.stripe = new stripe_cfml.stripe(
      apiKey = '#application.stripe_secret_key#',
      config = {}
    );

  }

  private function createCookie( struct rc ) {

    if ( !StructKeyExists( COOKIE, 'XSRF-DD-TOKEN' ) ) {

      var payload = tokenService.createPayload();

      cfcookie( name="XSRF-DD-TOKEN", value=SerializeJSON( payload ), path="/", domain=".debtdecimator.com", httpOnly=false );

    }

  }

  /* landing on the login page is what instatiates the XSRF-TOKEN */
  function default( struct rc ) {

    rc.pageTitle = "Sign In";
    rc.pageDescription = application.app_name & " secure sign in page";

    createCookie( arguments.rc );

  }

  function create( struct rc ) {
    param name="rc.at_id" default="1";
    param name="rc.kc" default="0"; // kc = keyword code
    param name="rc.cc" default="0"; // cc = (ad) copy code

    // mktgTitle = Should mirror the keywords used for the adgroup (ie. what the user searched for)
    // mktgBody = Should mirror the content of the ad (tailored to the ad that was clicked)

    if ( arguments.rc.kc ) {

      switch ( arguments.rc.kc ) {
        case 1:
          rc.mktgTitle = "Calculate Your Own Payoff";
          break;
        case 2:
          rc.mktgTitle = "Pay Off Debt Yourself";
          break;
        case 3:
          rc.mktgTitle = "Credit Card Advice";
          break;
        case 4:
          rc.mktgTitle = "Don't Go Deeper Into Debt";
          break;
        case 5:
          rc.mktgTitle = "Pay Off Cards Yourself";
          break;
        case 6:
          rc.mktgTitle = "A Credit Card Calculator & More!";
          break;
        case 7:
          rc.mktgTitle = "New Debt Snowball Calculator";
          break;
        case 8:
          rc.mktgTitle = "A Snowball Calculator & More!";
          break;
        default:
          break;
      }

    }

    if ( arguments.rc.cc ) {

      switch ( arguments.rc.cc ) {
        case 1:
          rc.mktgBody = "Tell us your debt and we'll tell you the fastest way to pay it off!";
          break;
        case 2:
          rc.mktgBody = "Manage your debt reduction budget. What cards to pay off first, and by how much.";
          break;
        case 3:
          rc.mktgBody = "Our credit card calculator advises you on what to pay and when.";
          break;
        case 4:
          rc.mktgBody = "Don't know how to pay off your credit cards? Our app tells you what to pay.";
          break;
        case 5:
          rc.mktgBody = "Tell us your credit card balances and we'll tell you the fastest way to pay them off.";
          break;
        case 6:
          rc.mktgBody = "Manage your credit card payoff: what cards to pay off first, and by how much.";
          break;
        case 7:
          rc.mktgBody = "A credit card calculator that advises the fastest payoff to financial freedom.";
          break;
        default:
          break;
      }

    }

    if ( arguments.rc.kc || arguments.rc.cc )
      rc.marketingContent = variables.fw.view('login/mkt1');

    createCookie( arguments.rc );

    if ( IsNumeric(rc.at_id) && (rc.at_id < 1 || rc.at_id > 4) )
      rc.at_id = 3;

    rc.account_type_id = rc.at_id;
  }

  function new( struct rc ) {
    param name="rc.stripeToken" default="";

    // create a new account
    var endString = '';

    // if the form variables do not exist, redirect to the create form
    if ( !StructKeyExists( rc, 'name' ) || !StructKeyExists( rc, 'email' ) ) {

      variables.fw.redirect( 'login.create' );

    }

    // look up the user's record by the email address
    var user = variables.userService.getByEmail( rc.email );

    // if the user alredy exists, error!
    var emailAvailable = !user.getUser_Id();

    // on email in use, redisplay the create form
    if ( !emailAvailable ) {

      rc.message = ["Email Already In Use"];

      variables.fw.redirect( 'login.create', 'message' );

    }

    // if you're here, create checks have passed, so create the user...
    user = variables.userService.create( rc.name, rc.email );

    // ...if they came via the onboarding process:
    if ( !StructIsEmpty( session.tmp.cards ) ) {

      // 1. capture the tmp.preferences.budget
      var prefs = preferenceService.get( user.getUser_Id() );
      prefs.setBudget( session.tmp.preferences.budget );
      preferenceService.save( prefs.flatten() );

      // 2. convert to legit (new) cards and save
      for ( var tmpCard in session.tmp.cards ) {

        // card_id to 0
        session.tmp.cards[tmpCard].setCard_Id( 0 );

        // user_id to legit id
        session.tmp.cards[tmpCard].setUser_Id( user.getUser_Id() );

        // flatten bean to struct, pass to save service
        variables.cardService.save( session.tmp.cards[tmpCard].flatten() );

      }

      // 3. wipe the tmp session clean
      StructClear( session.tmp.cards );

    }

    // ... and log 'em in!
    session.auth.isLoggedIn = true;
    session.auth.fullname = user.getName();
    session.auth.user = user;

    // if they are creating a paid account, create a Stripe Customer and Sub
    if ( Len(rc.stripeToken) ) {

      var createObj = rc.stripe.customers.create({
        email: '#session.auth.user.getEmail()#',
        source: '#rc.stripeToken#' // this is a payment object, via Billing
      });

      var customer = createObj.content;

      if ( !StructKeyExists( customer, 'error' ) ) {

        // update bean
        session.auth.user.setStripe_Customer_Id( customer.id );

        // save to db
        userService.save( session.auth.user.flatten() );

        // then subscribe them to the selected plan
        var subObj = rc.stripe.subscriptions.create({
          customer: '#session.auth.user.getStripe_Customer_Id()#',
          items: [{plan: '#rc.stripe_plan_id#'}]
        });

        var subscription = subObj.content;

        if ( !StructKeyExists( subscription, 'error' ) ) {

          // if successful, update
          session.auth.user.setStripe_Subscription_Id( subscription.id );
          session.auth.user.setAccount_Type_Id( variables.paymentService.getAccountTypeFromPlan( subscription.items.data[1].plan.id ) );

          // save to db
          userService.save( session.auth.user.flatten() );

          // prep the end string
          endString = '/c/' & variables.paymentService.getAccountTypeFromPlan( subscription.items.data[1].plan.id );

        } else {

          rc.message = ["There was a problem with your payment information. Your account will behave as a free one until you fix your payment information in the Profile -> Account Information."];

        }

      } else {

        rc.message = ["There was a problem with your payment information, so we've granted you free access. You can fix your payment information in the Profile -> Account Information."];

      }

    }

    // off to the default authenticated start page
    variables.fw.redirect( application.auth_start_page & '/reg' & endString );

  }

  function login( struct rc ) {

    // if the form variables do not exist, redirect to the login form
    if ( !StructKeyExists( rc, 'email' ) || !StructKeyExists( rc, 'password' ) ) {

      variables.fw.redirect( 'login' );

    }

    // look up the user's record by the email address
    var user = variables.userService.getByEmail( rc.email );

    // if that's a real user, verify their password is also correct
    var userValid = user.getUser_Id() ? variables.userService.validatePassword( user.flatten(), rc.password ) : false;

    // on invalid credentials, redisplay the login form
    if ( !userValid ) {
      rc.message = ["Invalid Username or Password"];
      variables.fw.redirect( 'login', 'message' );
    }

    // set session variables from valid user
    session.auth.isLoggedIn = true;
    session.auth.fullname = user.getName();
    session.auth.user = user;

    // is this an sso login?
    if ( StructKeyExists( session, 'sso' ) ) {

      // grab the sso data temp. stored.
      var sso_data = session.sso;

      // kill the sso key from the session (to ensure we can't reuse)
      StructDelete( session, 'sso' );

      // many whelps, handle it!
      var dest_url = discourseSSO( sso_data, session.auth.user );

      location( url=dest_url, addToken=false );

    }

    // off to the default authenticated start page
    variables.fw.redirect( application.auth_start_page );

  }

  function resetConfirm( struct rc ) {

    // first, verify the user exists
    var user = variables.userService.getByEmail( rc.email );

    // if that's a real user, verify their password is also correct
    var userValid = user.getUser_Id();

    var tmpKey = CreateUUID();

    session.tempPasswordReset[tmpKey] = userValid;

    // fire the temp password off in an email
    destUrl = variables.fw.buildUrl('login.choose');
    variables.mailService.sendPasswordResetEmail( rc.email, tmpKey, destUrl );

    // redirect to message
    rc.message = ["An email was sent to your account to help you confirm & reset your password."];

    variables.fw.redirect( 'login.default', 'message' );

  }

  function changeConfirm( struct rc ) {

    if ( StructKeyExists( rc, 'q' ) && StructKeyExists( session.tempPasswordReset, rc.q ) ) {

      var userId = session.tempPasswordReset[rc.q];

      rc.user = variables.userService.get( userId );

      var newPassword = variables.userService.hashPassword( rc.new_password );

      rc.user.setPassword_Hash( newPassword.hash );
      rc.user.setPassword_Salt( newPassword.salt );

      variables.userService.save( rc.user.flatten() );

      rc.message = ["Your account password was succesfully reset!"];

    } else {

      rc.message = ["There was some kind of error with your password reset! Wait a few minutes and try again."];

    }

    variables.fw.redirect( 'login.default', 'message' );

  }

  function updateConfirm( struct rc ) {

    rc.user = session.auth.user;
    rc.message = variables.userService.checkPassword( rc.user.flatten(), rc.new_password );

    if ( !ArrayIsEmpty( rc.message ) ) {
      variables.fw.redirect( 'profile.basic', 'message' );
    }

    var newPassword = variables.userService.hashPassword( rc.new_password );

    rc.user.setPassword_Hash( newPassword.hash );
    rc.user.setPassword_Salt( newPassword.salt );

    variables.userService.save( rc.user.flatten() );

    rc.message = ["Your password was successfully updated."];

    variables.fw.redirect( 'profile.basic', 'message' );

  }

  function logout( struct rc ) {

    // reset session variables
    session.auth.isLoggedIn = false;
    session.auth.fullname = "Guest";

    StructDelete( session.auth, 'user' );
    session.auth.user = userservice.getTemp();

    rc.message = ["CALC YOU LATER!! You have safely logged out"];

    variables.fw.redirect( 'login', 'message' );

  }

  function oops( rc ) {

    rc.message = ["Oops! There may have been an error! You're probably still logged in, try clicking the link in the upper left."];

    variables.fw.redirect( 'login', 'message' );

  }

  function sso( rc ) {

    var payload = rc.sso; // discourse param for payload.
    var signature = rc.sig; // discourse param for signature.

    //https://meta.discourse.org/t/official-single-sign-on-for-discourse-sso/13045
    // 1. validate the signature: ensure that HMAC-SHA256 of (sso_secret, payload) equal to sig
    if ( verifyDiscoursePayload( payload, signature ) ) {

      var decoded_payload = UrlDecode(payload); // I have a sneaking suspicion this isn't needed (see my urlencode comments below)
      var decoded = BinaryDecode( decoded_payload, 'Base64' );
      var data = urlToStruct(decoded); // now you have the nonce and the return_sso_url.

      // 2. Perform whatever authentication it has to
      // next step:
      // is the user already logged-in?
      if ( StructKeyExists( session,'auth' ) and session.auth.isLoggedIn ) {

        // 3. create a new payload with nonce, email, external_id and optionally username,name)
        /*
        avatar_url will be downloaded and set as the user’s avatar if the user is new or SiteSetting.sso_overrides_avatar is set.
        avatar_force_update is a boolean field. If set to true, it will force Discourse to update the user’s avatar, whether avatar_url has changed or not.
        bio will become the contents of the user’s bio if the user is new, their bio is empty or SiteSetting.sso_overrides_bio is set.
        Additional boolean (“true” or “false”) fields are: admin, moderator, suppress_welcome_message
        */

        var dest = DiscourseSSO( data, session.auth.user );

        location( url=dest, addToken=false );

      } else {

        session.sso = data; // store the nonce & return_sso_url for now.

        variables.fw.redirect( 'login' ); // send them to the login page.

      }

    } else {

      writeOutput('You want to go home and rethink your life.');

      // TODO: Log the HELL out of this - it shouldn't happen, unless someone is forcing their way in.

      abort; // abort the process, the payload and signature do not match.

    }

  }

  //private
  private function urlToStruct( string uri ) {

    var data = StructNew();
    var pair = '';

    cfloop( list=arguments.uri, item="pair", delimiters="&" ) {

      var key = ListGetAt(pair, 1, "=", false);
      var val = ListGetAt(pair, 2, "=", true);

      data[key] = UrlDecode(val);

    }

    return data;

  }

  private function structToUrl( struct obj ) {

    var key = '';
    var uri = '';

    cfloop( collection=arguments.obj, item="key" ) {

      uri = ListAppend(uri, '#key#=#UrlEncodedFormat(arguments.obj[key])#', '&');

    }

    return uri;

  }

  private function discourseSSO( auth_params, user ) {

    var payload_o = StructNew();

    payload_o["nonce"] = auth_params.nonce; //nonce should be copied from the input payload
    payload_o["email"] = arguments.user.getEmail(); //email must be a verified email address.
    payload_o["require_activation"] = false; // If the email address has not been verified, set require_activation to “true”.
    payload_o["external_id"] = arguments.user.getUser_Id(); // external_id is any string unique to the user that will never change, even if their email, name, etc change. The suggested value is your database’s ‘id’ row number.
    payload_o["username"] = arguments.user.getName(); // username will become the username on Discourse if the user is new or SiteSetting.sso_overrides_username is set.
    payload_o["name"] = arguments.user.getName(); // name will become the full name on Discourse if the user is new or SiteSetting.sso_overrides_name is set.
    payload_o["suppress_welcome_message"] = true;

    // prep default
    payload_o["add_groups"] = "Registered";

    if ( arguments.user.getRole_Id() == 1) {
      payload_o["admin"] = true;
    }

    // paid access
    if ( arguments.user.getAccount_Type_Id() == 4 ) {  // 4 is the one with special access to premiere support + beta
      payload_o["add_groups"] = ListAppend(payload_o["add_groups"], "Paid");
    } else {
      payload_o["remove_groups"] = "Paid";
    }

    var payload_url = structToUrl(payload_o);

    // 4. Base64 encode the payload
    var payload_url_base64 = ToBase64( payload_url, "utf-8" );

    // UrlEncoded
    //var payload_url_encoded = UrlEncodedFormat( payload_url_base64 ); // do not do this (see below)
    var payload_url_encoded = payload_url_base64; // interesting! for some reason, Discourse does not want the payload UrlEncoded.

    // 5. Calculate a HMAC-SHA256 hash of the payload using sso_secret as the key and Base64 encoded payload as text
    var payload_url_hash = hashDiscoursePayload( payload_url_encoded );

    // 6. Redirect back to http://discourse_site/session/sso_login?sso=payload&sig=sig
    //variables.fw.redirect( action='', path=data.return_sso_url, queryString="sso=#payload_url_encoded#&sig=#payload_url_hash#" );
    var dest = auth_params.return_sso_url & '?sso=' & payload_url_encoded & '&sig=' & payload_url_hash;

    return dest;

  }

  private function verifyDiscoursePayload( payload, sig ) {

    return ( !Compare( hashDiscoursePayload( arguments.payload ), arguments.sig ) );

  }

  private function hashDiscoursePayload( payload ) {

    return LCase( BinaryEncode( HMac( arguments.payload, application.sso_secret, 'HMACSHA256' ), 'Base64' ) );

  }

}
