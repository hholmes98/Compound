    // controllers/login
component accessors = true {

  property userService;
  property mailService;
  property preferenceService;
  property cardService;

  function init( fw ) {

    VARIABLES.fw = fw;

  }

  function before( rc ) {

    // you must be logged in for 'logout','updateConfirm' methods, and
    // must be logged out for all others. Otherwise, back to main.
    // TODO: break this out into
    // 1. methods that require isLoggedin
    // 2. methods that require !isLoggedin, and
    // 3. methods than don't care/can handle either (sso)

    switch( VARIABLES.fw.getItem() ) {

      // REQUIRES: logged in
      case 'logout':
      case 'updateConfirm':

        if ( !(StructKeyExists(SESSION,'auth') && SESSION.auth.isLoggedIn) )
          VARIABLES.fw.redirect( 'main' );

        break;

    }

    /* old
    if ( structKeyExists( session, 'auth' ) && 
        SESSION.auth.isLoggedIn &&
        VARIABLES.fw.getItem() != 'logout' && 
        VARIABLES.fw.getItem() != 'updateConfirm' ) {

      VARIABLES.fw.redirect( 'main' );

    }
    */

  }

  function new( rc ) {

    // create a new account

    // if the form variables do not exist, redirect to the create form
    if ( !structKeyExists( rc, 'name' ) || !structKeyExists( rc, 'email' ) ) {

      VARIABLES.fw.redirect( 'login.create' );

    }

    // look up the user's record by the email address
    var user = VARIABLES.userService.getByEmail( rc.email );

    // if the user alredy exists, error!
    var emailAvailable = !user.getUser_Id();

    // on email in use, redisplay the create form
    if ( !emailAvailable ) {

      rc.message = ["Email Already In Use"];

      VARIABLES.fw.redirect( 'login.create', 'message' );

    }

    // if you're here, create checks pass, create the user...
    user = VARIABLES.userService.createUser( rc.name, rc.email );

    // ...if they came via the onboarding process:
    if ( !StructIsEmpty(SESSION.tmp.cards) ) {

      // 1. capture the tmp.preferences.budget
      var prefs = preferenceService.get( user.getUser_Id() );
      prefs.setBudget( SESSION.tmp.preferences.budget );
      preferenceService.save( VARIABLES.preferenceService.flatten( prefs ) );

      // 2. convert to legit (new) cards and save
      for ( var tmpCard in SESSION.tmp.cards ) {

        // card_id to 0
        SESSION.tmp.cards[tmpCard].setCard_Id(0);

        // user_id to legit id
        SESSION.tmp.cards[tmpCard].setUser_Id( user.getUser_Id() );

        // flatten bean to struct, pass to save service
        VARIABLES.cardService.save( VARIABLES.cardService.flatten( SESSION.tmp.cards[tmpCard] ) );

      }

      // 3. wipe the tmp session clean
      StructClear( SESSION.tmp );

    }

    // ... and log 'em in!
    SESSION.auth.isLoggedIn = true;
    SESSION.auth.fullname = user.getName();
    SESSION.auth.user = user;

    // off to the default authenticated start page
    VARIABLES.fw.redirect( application.auth_start_page & '/reg' );

  }

  function login( rc ) {

    // if the form variables do not exist, redirect to the login form
    if ( !structKeyExists( rc, 'email' ) || !structKeyExists( rc, 'password' ) ) {

      VARIABLES.fw.redirect( 'login' );

    }

    // look up the user's record by the email address
    var user = VARIABLES.userService.getByEmail( rc.email );

    // if that's a real user, verify their password is also correct
    var userValid = user.getUser_Id() ? VARIABLES.userService.validatePassword( user, rc.password ) : false;

    // on invalid credentials, redisplay the login form
    if ( !userValid ) {
      rc.message = ["Invalid Username or Password"];
      VARIABLES.fw.redirect( 'login', 'message' );
    }

    // set session variables from valid user
    SESSION.auth.isLoggedIn = true;
    SESSION.auth.fullname = user.getName();
    SESSION.auth.user = user;

    // is this an sso login?
    if ( StructKeyExists(SESSION, 'sso') ) {

      // grab the sso data temp. stored.
      var sso_data = SESSION.sso;

      // kill the sso key from the session (to ensure we can't reuse)
      StructDelete( SESSION, 'sso' );

      // many whelps, handle it!
      var dest_url = discourseSSO( sso_data, SESSION.auth.user );

      location( url=dest_url, addToken=false );

    }

    // off to the default authenticated start page
    VARIABLES.fw.redirect( application.auth_start_page );

  }

  function resetConfirm( rc ) {

    // first, verify the user exists
    var user = VARIABLES.userService.getByEmail( rc.email );

    // if that's a real user, verify their password is also correct
    var userValid = user.getUser_Id();

    var tmpKey = CreateUUID();

    SESSION.tempPasswordReset[tmpKey] = userValid;

    // fire the temp password off in an email
    destUrl = VARIABLES.fw.buildUrl('login.passwordChoose');
    VARIABLES.mailService.sendPasswordResetEmail( rc.email, tmpKey, destUrl );

    // redirect to message
    rc.message = ["An email was sent to your account to help you confirm & reset your password."];

    VARIABLES.fw.redirect( 'login.default', 'message' );

  }

  function changeConfirm( rc ) {

    if ( StructKeyExists(rc, 'q') && StructKeyExists( SESSION.tempPasswordReset, rc.q ) ) {

      var userId = SESSION.tempPasswordReset[rc.q];

      rc.user = VARIABLES.userService.get( userId );

      var newPassword = VARIABLES.userService.hashPassword( rc.new_password );

      rc.user.setPassword_Hash( newPassword.hash );
      rc.user.setPassword_Salt( newPassword.salt );

      VARIABLES.userService.save( rc.user );

      rc.message = ["Your account password was succesfully reset!"];

    } else {

      rc.message = ["There was some kind of error with your password reset! Wait a few minutes and try again."];

    }

    VARIABLES.fw.redirect( 'login.default', 'message' );

  }

  function updateConfirm( rc ) {

    rc.user = SESSION.auth.user;
    rc.message = VARIABLES.userService.checkPassword( argumentCollection = rc );

    if ( !ArrayIsEmpty( rc.message ) ) {
      VARIABLES.fw.redirect( 'profile.basic', 'message' );
    }

    var newPassword = VARIABLES.userService.hashPassword( rc.new_password );

    rc.user.setPassword_Hash( newPassword.hash );
    rc.user.setPassword_Salt( newPassword.salt );

    VARIABLES.userService.save( rc.user );

    rc.message = ["Your password was successfully updated."];

    VARIABLES.fw.redirect( 'profile.basic', 'message' );

  }

  function logout( rc ) {

    // reset session variables
    SESSION.auth.isLoggedIn = false;
    SESSION.auth.fullname = "Guest";

    StructDelete( SESSION.auth, 'user' );
    SESSION.auth.user = userservice.getTemp();

    rc.message = ["You have safely logged out"];

    VARIABLES.fw.redirect( 'login', 'message' );

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
      if ( StructKeyExists(SESSION,'auth') and SESSION.auth.isLoggedIn ) {

      // 3. create a new payload with nonce, email, external_id and optionally username,name)
      /*
      avatar_url will be downloaded and set as the user’s avatar if the user is new or SiteSetting.sso_overrides_avatar is set.
      avatar_force_update is a boolean field. If set to true, it will force Discourse to update the user’s avatar, whether avatar_url has changed or not.
      bio will become the contents of the user’s bio if the user is new, their bio is empty or SiteSetting.sso_overrides_bio is set.
      Additional boolean (“true” or “false”) fields are: admin, moderator, suppress_welcome_message
      */

        var dest = DiscourseSSO( data, SESSION.auth.user );

        location( url=dest, addToken=false );

      } else {

        SESSION.sso = data; // store the nonce & return_sso_url for now.

        VARIABLES.fw.redirect( 'login' ); // send them to the login page.

      }

    } else {

      writeOutput('You want to go home and rethink your life.');

      // TODO: Log the HELL out of this - it shouldn't happen, unless someone is forcing their way in.

      abort; // abort the process, the payload and signature do not match.

    }

  }

  //private
  private function urlToStruct( uri ) {

    var data = StructNew();
    var pair = '';

    cfloop( list=arguments.uri, item="pair", delimiters="&" ) {

      var key = ListGetAt(pair, 1, "=", false);
      var val = ListGetAt(pair, 2, "=", true);

      data[key] = UrlDecode(val);

    }

    return data;

  }

  private function structToUrl( obj ) {

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

    if ( arguments.user.getRole_Id() == 1) {
      payload_o["admin"] = true;
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
    //VARIABLES.fw.redirect( action='', path=data.return_sso_url, queryString="sso=#payload_url_encoded#&sig=#payload_url_hash#" );
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
