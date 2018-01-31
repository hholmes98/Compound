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
        session.auth.user = userservice.getTemp();

        // set up the anonymous user's tmp session structure
        session.tmp = {};
        session.tmp.cards = {};
        session.tmp.preferences = {};
        session.tmp.queries = {};
    }

    function authorize( rc ) {

        // check to make sure the user is logged on
        if ( not ( structKeyExists( session, "auth" ) && session.auth.isLoggedIn ) && 
             !listfindnocase( 'login', variables.fw.getSection() ) && 
             !listfindnocase( 'debt', variables.fw.getSection() ) &&
             !listfindnocase( 'main.error', variables.fw.getFullyQualifiedAction() ) ) {
            variables.fw.redirect('login');
        }

    }

}
