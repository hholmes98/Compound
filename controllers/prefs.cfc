component accessors = true { 

	property framework;
	property preferenceservice;

	public void function get( struct rc ) {
		
		var prefbean = preferenceservice.get( rc.uid );
		
		framework.renderdata( "JSON" , prefbean );
	
	}

	public void function save( struct rc ) {

		var ret = {};

		if ( structKeyExists( arguments.rc, 'freq' ) ) {
		
			ret = freq( arguments.rc.uid, arguments.rc.freq );
		
		} else if ( structKeyExists( arguments.rc, 'budget' ) ) {
		
			ret = budget( arguments.rc.uid, arguments.rc.budget );
		
		}

		framework.renderdata( "JSON", ret );
	
	}

	/******
	private (refactor these out completely later, thanks)
	******/
	
	private string function budget( string budget, string uid ) {

		var ret = preferenceservice.setbudget( arguments.uid, arguments.budget );

		return ret;
	
	}

	private string function freq( string freq, string uid ) {

		var ret = preferenceservice.setfrequency( arguments.uid, arguments.freq );

		return ret;
	
	}

}