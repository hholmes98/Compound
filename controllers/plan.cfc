//plan.cfc
component accessors = true { 

	property framework;
	property planservice;

	/*
	public void function default( struct rc ) {
		
		location(url:"index.cfm?action=plan", addtoken:false);
	
	}
	*/

	public void function list( struct rc ) {
		
		var cards = planservice.list( arguments.rc.user_id );

		framework.renderdata("JSON", cards);
	
	}

	public void function schedule( struct rc ) {

		var events = planservice.events( arguments.rc.user_id );

		framework.renderdata("JSON", events);

	}

	public void function journey( struct rc ) {

		var milestones = planservice.milestones( arguments.rc.user_id );

		framework.renderdata("JSON", milestones);

	}

	public void function delete( struct rc ) {
		
		var ret = planservice.delete( arguments.rc.user_id );
		
		framework.renderdata("JSON", ret);
	
	}	

}