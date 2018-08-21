component extends = "framework.one" {

  this.name = "ddApp";
  this.sessionManagement = true;
  this.sessionTimeout = CreateTimeSpan(0, 0, 20, 0);
  this.applicationTimeout = CreateTimeSpan(1, 0, 0, 0);
  this.setClientCookies = false;

  variables.framework = {

    unhandledExtensions = "cfc,map,css,js,html",
    unhandledPaths = "/fonts",

    generateSES = 'true',

    home = 'main',

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

      // top/main nav
      { "$GET/pay/bills" = "/pay/cards" },
      { "$GET/manage/budget" = "/deck/manage" },
      { "$GET/calculate/future" = "/calculate/default" },
      { "$GET/pay/reg/" = "/pay" }

      // manage is an alias for controller.cards
      /*
      { "$GET/manage/list" = "/cards/list" },
      { "$GET/manage/detail" = "/cards/detail" },
      { "$GET/manage/delete" = "/cards/delete" },
      { "$GET/manage/save" = "/cards/save" },
      { "$GET/manage/setAsEmergency" = "/cards/setAsEmergency" },
      */


      /*{ "$GET/cards/:user_id" = "/budget/list/id/:user_id" },
      { "$GET/card/:card_id" = "/budget/get/id/:card_id" },
      { "$DELETE/card/:card_id" = "/budget/delete/card_id/:card_id" },
      { "$POST/card/eid/:eid/uid/:uid" = "/budget/setAsEmergency/eid/:eid/uid/:uid" },
      { "$POST/card/" = "/budget/save" },
      { "$GET/prefs/uid/:uid" = "/prefs/get/uid/:uid" },
      { "$POST/prefs/" = "/prefs/save" },
      { "$GET/plan/miles/:user_id" = "/plan/journey/user_id/:user_id" },
      { "$DELETE/plan/:user_id" = "/plan/delete/user_id/:user_id" },
      { "$GET/main/miles/" = "/main/journey/" },

      { "$DELETE/journey/:user_id" = "/plan/deleteEvents/user_id/:user_id" }*/
    ],

  };

  function setupApplication() {

    var file = FileRead( ExpandPath( '/config/config.cfm') );
    var conf = XmlParse( file );

    application.admin_email = XmlSearch( conf, '//admin/email' )[1].XmlText;
    application.site_domain = XmlSearch( conf, '//app/domain' )[1].XmlText;

    application.app_name = XmlSearch( conf, '//app/name' )[1].XmlText;
    application.app_short_description = XmlSearch( conf, '//app/shortDescription' )[1].XmlText;
    application.app_version = XmlSearch( conf, '//app/version' )[1].XmlText;
    application.app_show_version = XmlSearch( conf, '//app/show-version' )[1].XmlText;

    application.secure = XmlSearch( conf, '//app/secure' )[1].XmlText;

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
      locale.description = locales[1].XmlChildren[i].description.XmlText;

      StructInsert( application.locale, locale.code, locale, true );

    }

    // same-as
    application.sameas = ArrayNew(1);

    var same = XmlSearch( conf, '//same-as/url' );

    for (var j=1; j <= ArrayLen( same ); j++ ) {

      var this_url = same[j].XmlText;

      ArrayAppend( application.sameas, this_url );

    }

    // default locale
    application.default_locale = XmlSearch( conf, '//app/locale' )[1].XmlText;

    // skins
    application.skins = ArrayNew(1);
    application.skins[1] = {
      name: 'Jackson (Light)',
      path: 'dd.css',
      favicon: 'dd-logo-light.png',
      themeColor: '##1c6a3a'
    };
    application.skins[2] = {
      name: '80s ATM (Dark)',
      path: 'dd-dark.css',
      favicon: 'dd-logo-dark.png',
      themeColor: '##000000'
    };

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

    application.start_page = variables.framework.home; // if you're anonymous/non-authorized, this is where you start
    application.auth_start_page = 'pay'; // if you're logged-in/authorized, this is where you start

    // *** TWITTER ***
    application.twitter = StructNew();
    application.twitter.nick = XmlSearch( conf, '//twitter/nick' )[1].XmlText;
    application.twitter.image = XmlSearch( conf, '//twitter/image' )[1].XmlText;

    // *** DISCOURSE SSO ***
    application.sso_secret = XmlSearch( conf, '//discourse/sso-secret' )[1].XmlText;

    // *** STRIPE API ***
    application.stripe_public_key = XmlSearch( conf, '//stripe/public-key')[1].XmlText;
    application.stripe_secret_key = XmlSearch( conf, '//stripe/secret-key')[1].XmlText;
    application.stripe_plans = StructNew();

    var plan_list = XmlSearch( conf, '//stripe/plans/plan' );
    for (var plan in plan_list ) {
      var planObj = StructNew();
      for ( var field in plan.XmlChildren ) {
        planObj["#field.xmlName#"] = field.XmlText;
      }
      application.stripe_plans[plan.XmlAttributes.account_type_id] = planObj;
    }

    // **** SITE VARS ****

    // static URLs that are hard-linked within app (things like permalinks, help links, blog posts, forum, etc)
    application.static_urls = StructNew();

    // CALL Url
    application.static_urls.call = 'https://blog.debtdecimator.com/when-you-cant-pay-a-bill/';

    // ad blocking
    application.ad_blocker = 'We get it. Ads suck. But not everybody can pay for an account. Please consider whitelisting *.' & application.site_domain & ', upgrading to a paid account, or purchasing keys for other users who cannot.';

    // overrides
    variables.framework['environments']['production']['password'] = XmlSearch( conf, '//fw1/password' )[1].XmlText;

  }

  function setupSession() {

    cfcookie( name="cfid", value=session.cfid );
    cfcookie( name="cftoken", value=session.cftoken );

    controller( 'security.session' );

  }

  function setupRequest() {

    if ( NOT StructKeyExists( session, 'auth') ) {
      lock scope="session" type="exclusive" timeout="30" {
        setupSession();
      }
    }

    controller( 'security.authorize' );

    request.abs_url = buildAbsoluteUrl();

    //cfcontent( type="text/html; charset=UTF-8" );

  }

  function getEnvironment() {

    if ( FindNoCase( "dev", CGI.SERVER_NAME ) || FindNoCase( "lc", CGI.SERVER_NAME ) ) {
      return "development";
    }
    else 
      return "production";

  }

  /* methods below are REQUEST scope-safe only!! */
  function getHTTPHeader( headerName ) {
    var requestData = getHTTPRequestData();

    // if the header data is absent...
    if ( !StructKeyExists( requestData, 'headers') ) {
      return '';
    }

    if ( StructKeyExists( requestData.headers, arguments.headerName ) ) {
      return requestData.headers[arguments.headerName];
    } else {
      return '';
    }

  }

  boolean function isSSL() {

    return application.secure;

  }

  function buildAbsoluteUrl() {

    var abs_url = CGI.SERVER_NAME;

    if ( isSSL() ) {
      abs_url = "https://" & abs_url;
    } else {
      abs_url = "http://" & abs_url;
    }

    if ( CGI.SERVER_PORT != 80 && CGI.SERVER_PORT != 443 ) {
      abs_url = abs_url & ":" & CGI.SERVER_PORT;
    }

    return abs_url;

  }

  /*
  https://docs.angularjs.org/api/ng/service/$http#jsonp

  A JSON vulnerability allows third party website to turn your JSON resource URL into JSONP request under some conditions. 
  To counter this your server can prefix all JSON requests with following string ")]}',\n". AngularJS will automatically strip
  the prefix before processing it as JSON.

  For example if your server needs to return:

  ['one','two']
  which is vulnerable to attack, your server can return:

  )]}',
  ['one','two']
  AngularJS will strip the prefix, before processing the JSON.
  */
  private struct function render_json( struct renderData ) {
    var protected_output = ")]}'," & Chr(10) & SerializeJSON( renderData.data );
    return {
        contentType = 'application/json; charset=utf-8',
        output = protected_output
    };
  }

}