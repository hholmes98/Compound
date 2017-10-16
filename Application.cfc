component extends="framework.one" {
	
	this.name = "ddApp";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0, 2, 0, 0);

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
		  { "$GET/plan/sched/:user_id" = "/plan/schedule/user_id/:user_id" },
		  { "$GET/plan/events/:user_id" = "/plan/events/user_id/:user_id" },
		  { "$GET/plan/:user_id" = "/plan/list/user_id/:user_id" }
		  
		],
		
		reloadApplicationOnEveryRequest = true // set this to false when in PROD!

	};
	
	function setupApplication() {
		application.adminEmail = 'support@mydomain.com';
	}

	function setupSession() {
		controller( 'security.session' );
	}

	function setupRequest() {
		controller( 'security.authorize' );
	}	

}
