component accessors = true { 

	property framework;
	property cardservice;
	property userservice;

	function init( fw ) {

        variables.fw = fw;

    }

    function password( rc ) {

        rc.id = session.auth.user.getId();

    }

    function change( rc ) {
        
        rc.user = variables.userService.get( rc.id );
        rc.message = variables.userService.checkPassword( argumentCollection = rc );
        
        if ( !arrayIsEmpty( rc.message ) ) {
            variables.fw.redirect( "main.password", "message" );
        }
        
        var newPasswordHash = variables.userService.hashPassword( rc.newPassword );
        
        rc.passwordHash = newPasswordHash.hash;
        rc.passwordSalt = newPasswordHash.salt;
        
        // this will update any user fields from RC so it's a bit overkill here
        variables.fw.populate( cfc = rc.user, trim = true );

        variables.userService.save( rc.user );
        
        rc.message = ["Your password was changed"];
        
        variables.fw.redirect( "main", "message" );
    }


    /*
	public void function default( struct rc ) {
		
		location(url:"index.html", addtoken:false);
	
	}
	*/

	public void function get( struct rc ) {

		var cardbean = cardservice.get( arguments.rc.id );
		
		framework.renderdata("JSON", cardbean);
	
	}

	public void function delete( struct rc ) {
		
		var ret = cardservice.delete( arguments.rc.card_id );
		
		framework.renderdata("JSON", ret);
	
	}

	public void function list( struct rc ) {
		
		var cards = cardservice.list( arguments.rc.id );

		framework.renderdata("JSON", cards);
	
	}

	public void function save( struct rc ) {

		var ret = cardservice.save( arguments.rc );

		framework.renderdata("JSON", ret);
	
	}

	public void function setAsEmergency( struct rc ) {

		var ret = cardservice.setAsEmergency( arguments.rc.eid, arguments.rc.uid );

		framework.renderdata("JSON", ret);
	
	}	

}