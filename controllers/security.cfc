//controllers/security.cfc
component accessors=true {

  property userService;

  function init( fw ) {

    variables.fw = fw;

  }

  function session( rc ) {

    // set up the user's session
    session.auth = {};
    session.auth.isLoggedIn = false;
    session.auth.fullname = 'Guest';
    session.auth.locale = application.default_locale;
    session.auth.user = userService.getTemp();

    // set up the anonymous user's tmp session structure
    session.tmp = {};
    session.tmp.cards = {};
    session.tmp.preferences = {};
    session.tmp.queries = {};

  }

  function authorize( rc ) {

    // check to make sure the user is logged on
    if ( not ( StructKeyExists( session, 'auth' ) && session.auth.isLoggedIn ) &&
        !ListFindNoCase( 'login', variables.fw.getSection() ) && 
        !ListFindNoCase( 'main', variables.fw.getSection() ) &&
        !ListFindNoCase( 'mail', variables.fw.getSection() ) ) {

      variables.fw.redirect('login');

    }

  }

}