component extends = "framework.one" {

  this.name = "ddApp";
  this.sessionManagement = true;
  this.sessionTimeout = CreateTimeSpan(0, 0, 20, 0);
  this.applicationTimeout = CreateTimeSpan(1, 0, 0, 0);

  variables.framework = {

    unhandledExtensions = "cfc,map,css,js,html",
    unhandledPaths = "/fonts",

    generateSES = 'true',

    home = 'debt',

    environments = {

        // development vars
        development = {
          reloadApplicationOnEveryRequest = true,
          error = "main.detailederror"
        },

        // production vars
        production = {
          reloadApplicationOnEveryRequest = false,
          error = "main.oops",
          password = "foobar" // default, overridden by config
        }
    },

    routes = [
      { "$GET/card/user_id/:user_id" = "/main/list/id/:user_id" },
      { "$GET/card/:id" = "/main/get/id/:id" },
      { "$DELETE/card/:card_id" = "/main/delete/card_id/:card_id" },
      { "$POST/card/eid/:eid/uid/:uid" = "/main/setAsEmergency/eid/:eid/uid/:uid" },
      { "$POST/card/" = "/main/save" },
      { "$GET/prefs/uid/:uid" = "/prefs/get/uid/:uid" },
      { "$POST/prefs/" = "/prefs/save" },
      { "$GET/plan/miles/:user_id" = "/plan/journey/user_id/:user_id" },
      { "$GET/plan/events/:user_id" = "/plan/schedule/user_id/:user_id" },
      { "$GET/plan/:user_id" = "/plan/list/user_id/:user_id" },
      { "$DELETE/plan/:user_id" = "/plan/delete/user_id/:user_id" },
      { "$GET/debt/miles/" = "/debt/journey/" },
    ],

  };

  function setupApplication() {

    var file = FileRead( ExpandPath( '/config/config.cfm') );
    var conf = XmlParse( file );

    application.admin_email = XmlSearch( conf, '//admin/email' )[1].XmlText;
    application.site_domain = XmlSearch( conf, '//app/domain' )[1].XmlText;

    application.app_name = XmlSearch( conf, '//app/name' )[1].XmlText & ' (' & XmlSearch( conf, '//app/version' )[1].XmlText & ')';
    application.show_app_name = XmlSearch( conf, '//app/show' )[1].XmlText;

    // locales
    application.locale = StructNew();

    var locales = XmlSearch( conf, '//locales' );

    for ( var i=1; i <= ArrayLen( locales ); i++ ) {

      var locale = StructNew();

      locale.country = locales[1].XmlChildren[i].XmlAttributes.country;
      locale.language = locales[1].XmlChildren[i].XmlAttributes.language;
      locale.code = locales[1].XmlChildren[i].XmlAttributes.language & '-' & locales[1].XmlChildren[i].XmlAttributes.country;
      locale.name = locales[1].XmlChildren[i].name.XmlText;
      locale.motto = locales[1].XmlChildren[i].motto.XmlText;

      StructInsert( application.locale, locale.code, locale, true );

    }

    // locale
    application.default_locale = XmlSearch( conf, '//app/locale' )[1].XmlText;

    // datasource
    application.datasource = XmlSearch( conf, '//app/datasource' )[1].XmlText;

    // a single hot card and/or an emergency card *must* stay over this percentage of the budget.
    application.emergency_balance_threshold = 0.33;

    // in a given month, never allow a payment to drop the balance of a card below this number 
    // (to prevent things like carrying an .11 cent balance)
    application.min_card_threshold = 10; // hey, 10 bucks is 10 bucks.

    // when false, only Snowball is ever used.
    // when true, Avalanche is used unless interest rates aren't specified / are 0.
    application.AllowAvalanche = false;

    application.start_page = variables.framework.home;  // if you're anonymous/non-authorized, this is where you start
    application.auth_start_page = 'pay';        // if you're logged-in/authorized, this is where you start

    application.base_url = CGI.SERVER_NAME;

    if ( CGI.SERVER_PORT_SECURE ) {
      application.base_url = "https://" & application.base_url;
    } else {
      application.base_url = "http://" & application.base_url;
    }

    if ( CGI.SERVER_PORT <> 80 ) {
      application.base_url = application.base_url & ":" & CGI.SERVER_PORT;
    }

    // overrides
    variables.framework['environments']['production']['password'] = XmlSearch( conf, '//fw1/password' )[1].XmlText;

  }

  function setupSession() {

    controller( 'security.session' );

    /* consider

    https://docs.angularjs.org/api/ng/service/$http#jsonp

    XSRF is an attack technique by which the attacker can trick an authenticated user into unknowingly executing actions on your website. AngularJS provides a mechanism to counter XSRF. When performing XHR requests, the $http service reads a token from a cookie (by default, XSRF-TOKEN) and sets it as an HTTP header (X-XSRF-TOKEN). Since only JavaScript that runs on your domain could read the cookie, your server can be assured that the XHR came from JavaScript running on your domain. The header will not be set for cross-domain requests.
    To take advantage of this, your server needs to set a token in a JavaScript readable session cookie called XSRF-TOKEN on the first HTTP GET request. On subsequent XHR requests the server can verify that the cookie matches X-XSRF-TOKEN HTTP header, and therefore be sure that only JavaScript running on your domain could have sent the request. The token must be unique for each user and must be verifiable by the server (to prevent the JavaScript from making up its own tokens). We recommend that the token is a digest of your site's authentication cookie with a salt for added security.
    The name of the headers can be specified using the xsrfHeaderName and xsrfCookieName properties of either $httpProvider.defaults at config-time, $http.defaults at run-time, or the per-request config object.
    In order to prevent collisions in environments where multiple AngularJS apps share the same domain or subdomain, we recommend that each application uses unique cookie name.
    */
  }

  function setupRequest() {

    if ( NOT StructKeyExists( SESSION, 'auth') ) {
      lock scope="session" type="exclusive" timeout="30" {
        setupSession();
      }
    }

    controller( 'security.authorize' );

  }

  function getEnvironment() {

    if ( FindNoCase( "dev", CGI.SERVER_NAME ) || FindNoCase( "lc", CGI.SERVER_NAME ) ) {
      return "development";
    }
    else 
      return "production";

  }

}