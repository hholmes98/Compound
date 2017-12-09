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

		application.app_name = 'Compound (Alpha v0.8)';

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
	}

	function setupRequest() {
		controller( 'security.authorize' );
	}	

}
