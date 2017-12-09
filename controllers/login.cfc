component accessors=true {

    property userService;

    function init( fw ) {
        variables.fw = fw;
        return this;
    }

    function before( rc ) {
        if ( structKeyExists( session, "auth" ) && session.auth.isLoggedIn &&
             variables.fw.getItem() != "logout" ) {
            variables.fw.redirect( "main" );
        }
    }

    function new( rc ) {
        
        // create a new account

        // if the form variables do not exist, redirect to the create form
        if ( !structKeyExists( rc, "name" ) || !structKeyExists( rc, "email") ) {
            variables.fw.redirect( "login.create" );
        }
        
        // look up the user's record by the email address
        var user = variables.userService.getByEmail( rc.email );

        // if the user alredy exists, error!
        var emailAvailable = !user.getUser_Id();

        // on email in use, redisplay the create form
        if ( !emailAvailable ) {
            rc.message = ["Email Already In Use"];
            variables.fw.redirect( "login.create", "message" );
        }

        // if you're here, create checks pass, create the user and log 'em in!
        user = variables.userService.createUser( rc.name, rc.email );

        // log the user in (same as below)
        session.auth.isLoggedIn = true;
        session.auth.fullname = user.getName();
        session.auth.user = user;

        variables.fw.redirect( application.start_page );
    }    

    function login( rc ) {
        
        // if the form variables do not exist, redirect to the login form
        if ( !structKeyExists( rc, "email" ) || !structKeyExists( rc, "password" ) ) {
            variables.fw.redirect( "login" ); // login.default
        }
        
        // look up the user's record by the email address
        var user = variables.userService.getByEmail( rc.email );
        
        // if that's a real user, verify their password is also correct
        var userValid = user.getUser_Id() ? variables.userService.validatePassword( user, rc.password ) : false;
        
        // on invalid credentials, redisplay the login form
        if ( !userValid ) {
            rc.message = ["Invalid Username or Password"];
            variables.fw.redirect( "login", "message" );
        }
        
        // set session variables from valid user
        session.auth.isLoggedIn = true;
        session.auth.fullname = user.getName();
        session.auth.user = user;

        variables.fw.redirect( application.start_page );
    }

    /*
    function change( rc ) {
        
        rc.user = variables.userService.getByEmail( rc.email );

        var newPassword = "smile89";
        var newPasswordHash = variables.userService.hashPassword( newPassword );
        
        rc.password_hash = newPasswordHash.hash;
        rc.password_salt = newPasswordHash.salt;

        // this will update any user fields from RC so it's a bit overkill here
        variables.fw.populate( cfc = rc.user, trim = true );

        variables.userService.save( rc.user );

        rc.message = ["Your password was changed to " & newPassword];
        
        variables.fw.redirect( "userManagerAccessControl:login", "message" );
    } 
    */      

    function logout( rc ) {
        // reset session variables
        session.auth.isLoggedIn = false;
        session.auth.fullname = "Guest";
        structdelete( session.auth, "user" );
        rc.message = ["You have safely logged out"];
        variables.fw.redirect( "login", "message" );
    }

}
