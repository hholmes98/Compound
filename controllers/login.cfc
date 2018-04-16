    // controllers/login
component accessors = true {

  property userService;
  property mailService;
  property preferenceService;
  property cardService;

  function init( fw ) {

    variables.fw = fw;

  }

  function before( rc ) {

    if ( structKeyExists( session, 'auth' ) && session.auth.isLoggedIn &&
        variables.fw.getItem() != 'logout' && variables.fw.getItem() != 'updateConfirm' ) {

      variables.fw.redirect( 'main' );

    }

  }

  function new( rc ) {

    // create a new account

    // if the form variables do not exist, redirect to the create form
    if ( !structKeyExists( rc, 'name' ) || !structKeyExists( rc, 'email' ) ) {

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

    // if you're here, create checks pass, create the user...
    user = variables.userService.createUser( rc.name, rc.email );

    // ...if they came via the onboarding process:
    if ( !StructIsEmpty(session.tmp.cards) ) {

      // 1. capture the tmp.preferences.budget
      var prefs = preferenceService.get( user.getUser_Id() );
      prefs.setBudget( session.tmp.preferences.budget );
      preferenceService.save( variables.preferenceService.flatten( prefs ) );

      // 2. convert to legit (new) cards and save
      for ( var tmpCard in session.tmp.cards ) {

        // card_id to 0
        session.tmp.cards[tmpCard].setCard_Id(0);

        // user_id to legit id
        session.tmp.cards[tmpCard].setUser_Id( user.getUser_Id() );

        // flatten bean to struct, pass to save service
        variables.cardService.save( variables.cardService.flatten( session.tmp.cards[tmpCard] ) );

      }

      // 3. wipe the tmp session clean
      StructClear( session.tmp );

    }

    // ... and log 'em in!
    session.auth.isLoggedIn = true;
    session.auth.fullname = user.getName();
    session.auth.user = user;

    // off to the default authenticated start page
    variables.fw.redirect( application.auth_start_page & '/reg' );

  }

  function login( rc ) {

    // if the form variables do not exist, redirect to the login form
    if ( !structKeyExists( rc, 'email' ) || !structKeyExists( rc, 'password' ) ) {

      variables.fw.redirect( 'login' );

    }

    // look up the user's record by the email address
    var user = variables.userService.getByEmail( rc.email );

    // if that's a real user, verify their password is also correct
    var userValid = user.getUser_Id() ? variables.userService.validatePassword( user, rc.password ) : false;

    // on invalid credentials, redisplay the login form
    if ( !userValid ) {
      rc.message = ["Invalid Username or Password"];
      variables.fw.redirect( 'login', 'message' );
    }

    // set session variables from valid user
    session.auth.isLoggedIn = true;
    session.auth.fullname = user.getName();
    session.auth.user = user;

    // off to the default authenticated start page
    variables.fw.redirect( application.auth_start_page );

  }

  function resetConfirm( rc ) {

    // first, verify the user exists
    var user = variables.userService.getByEmail( rc.email );

    // if that's a real user, verify their password is also correct
    var userValid = user.getUser_Id();

    var tmpKey = CreateUUID();

    session.tempPasswordReset[tmpKey] = userValid;

    // fire the temp password off in an email
    destUrl = variables.fw.buildUrl('login.passwordChoose');
    variables.mailService.sendPasswordResetEmail( rc.email, tmpKey, destUrl );

    // redirect to message
    rc.message = ["An email was sent to your account to help you confirm & reset your password."];

    variables.fw.redirect( 'login.default', 'message' );

  }

  function changeConfirm( rc ) {

    if ( StructKeyExists(rc, 'q') && StructKeyExists( session.tempPasswordReset, rc.q ) ) {

      var userId = session.tempPasswordReset[rc.q];

      rc.user = variables.userService.get( userId );

      var newPassword = variables.userService.hashPassword( rc.new_password );

      rc.user.setPassword_Hash( newPassword.hash );
      rc.user.setPassword_Salt( newPassword.salt );

      variables.userService.save( rc.user );

      rc.message = ["Your account password was succesfully reset!"];

    } else {

      rc.message = ["There was some kind of error with your password reset! Wait a few minutes and try again."];

    }

    variables.fw.redirect( 'login.default', 'message' );

  }

  function updateConfirm( rc ) {

    rc.user = session.auth.user;
    rc.message = variables.userService.checkPassword( argumentCollection = rc );

    if ( !ArrayIsEmpty( rc.message ) ) {
      variables.fw.redirect( 'profile.basic', 'message' );
    }

    var newPassword = variables.userService.hashPassword( rc.new_password );

    rc.user.setPassword_Hash( newPassword.hash );
    rc.user.setPassword_Salt( newPassword.salt );

    variables.userService.save( rc.user );

    rc.message = ["Your password was successfully updated."];

    variables.fw.redirect( 'profile.basic', 'message' );

  }

  function logout( rc ) {

    // reset session variables
    session.auth.isLoggedIn = false;
    session.auth.fullname = "Guest";

    StructDelete( session.auth, 'user' );
    session.auth.user = userservice.getTemp();

    rc.message = ["You have safely logged out"];

    variables.fw.redirect( 'login', 'message' );

  }

}
