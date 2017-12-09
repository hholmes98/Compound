// card.cfc (bean)
component accessors=true {

	property card_id;
    property user_id;
    property label;
    property balance;
    property interest_rate;
    property is_emergency;
    property min_payment;
    property is_hot;
    property calculated_payment;
    property pay_date;

	function init( string card_id = 0, string user_id = 0, string label = "", string balance = 0, string interest_rate = 0, string is_emergency = 0, string min_payment = 0, string is_hot = 0, string calculated_payment = 0, date pay_date='1900-1-1' ) {
	    
	    variables.card_id = card_id;
	    variables.user_id = user_id;
	    variables.label = label;
	    variables.balance = balance;
	    variables.interest_rate = interest_rate;
	    variables.is_emergency = is_emergency;
	    variables.min_payment = min_payment;
	    variables.is_hot = is_hot;
	    variables.calculated_payment = calculated_payment;
	    variables.pay_date = pay_date;
	    
	    return this;
	}

	function getRemaining_Balance() {

		if ( ( variables.balance > 0 ) && ( variables.calculated_payment > 0 ) && ( variables.balance > variables.calculated_payment ) )
			return Evaluate( variables.balance - variables.calculated_payment );
		else
			return 0;
	}

	function IsHot() {

		return variables.is_hot;

	}

	function IsEmergency() {

		return variables.is_emergency;

	}

}