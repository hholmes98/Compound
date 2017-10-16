//preference (bean)
component accessors=true {

    property user_id;
    property budget;
    property pay_frequency;

	function init( string user_id = 0, string budget = 0, string pay_frequency = 0 ) {
	    
	    variables.user_id = user_id;
	    variables.budget = budget;
	    variables.pay_frequency = pay_frequency;
	    
	    return this;
	}

}