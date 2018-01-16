component extends="framework.one" {
	
	this.name = "ddApp";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0, 0, 20, 0);
	this.applicationTimeout = createTimeSpan(1, 0, 0, 0);

	variables.framework = {
        
        unhandledExtensions = "cfc,map,css,js,html",
        
        unhandledPaths = "/fonts",
		
		generateSES = 'true',
		
		routes = [ //Just for fun.....
		  { "$GET/card/user_id/:user_id" = "/main/list/id/:user_id" },
		  { "$GET/card/:id" = "/main/get/id/:id" },
		  { "$DELETE/card/:card_id" = "/main/delete/card_id/:card_id" },
		  { "$POST/card/eid/:eid/uid/:uid" = "/main/setAsEmergency/eid/:eid/uid/:uid" },
		  { "$POST/card/" = "/main/save" },
		  { "$GET/prefs/uid/:uid" = "/prefs/get/uid/:uid" },
		  { "$POST/prefs/freq/:freq/uid/:uid" = "/prefs/save/freq/:freq/uid/:uid" },
		  { "$POST/prefs/budget/:budget/uid/:uid" = "/prefs/save/budget/:budget/uid/:uid" },
		  { "$GET/plan/sched/:user_id" = "/plan/journey/user_id/:user_id" },
		  { "$GET/plan/events/:user_id" = "/plan/schedule/user_id/:user_id" },
		  { "$GET/plan/:user_id" = "/plan/list/user_id/:user_id" },
		  { "$DELETE/plan/:user_id" = "/plan/delete/user_id/:user_id" },
		],
		
		reloadApplicationOnEveryRequest = true // set this to false when in PROD!

	};
	
	function setupApplication() {
		application.admin_email = 'support@debtdecimator.com';

		application.app_name = 'Compound (Alpha v0.82)';

		// a single hot card and/or an emergency card *must* stay over this percentage of the budget.
		application.emergency_balance_threshold = 0.33;

		// in a given month, never allow a payment to drop the balance of a card below this number 
		// (to prevent things like carrying an .11 cent balance)
		application.min_card_threshold = 10; // hey, 10 bucks is 10 bucks.

		// when this is true, I consistently add on several more months to the payout plan, as hot card 
		// payments are spread more thinly, month-to-month.
		application.consider_interest_when_calculating_payments = false;

		application.start_page = 'pay';
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
		controller( 'security.authorize' );
	}	

}
