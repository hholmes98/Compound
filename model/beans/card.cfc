// card.cfc (bean)
component accessors=true {

	property card_id;
    property user_id;
    property label;
    property balance;
    property interest_rate;
    property is_emergency;
    property min_payment;
    property calculated_payment;

	function init( string card_id = 0, string user_id = 0, string label = "", string balance = 0, string interest_rate = 0, string is_emergency = 0, string min_payment = 0 ) {
	    
	    variables.card_id = card_id;
	    variables.user_id = user_id;
	    variables.label = label;
	    variables.balance = balance;
	    variables.is_emergency = is_emergency;
	    variables.interest_rate = interest_rate;
	    variables.min_payment = min_payment;

	    // not stored, always generated
	    variables.calculated_payment = -1;
	    
	    return this;
	}

}