// pay.cfc
component accessors = true { 

	property framework;
	property cardservice;
	property userservice;

	function init( fw ) {

        variables.fw = fw;

    }

    function list( struct rc ) {

		// use main.list to show a list of cards.

    }

    function get( struct rc ) {

		// use main.get to a specific card.

    }

    function choose( struct rc) {

    	
    }


}