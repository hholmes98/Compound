// model/beans/card
component accessors = true {

  property card_id;
  property user_id;
  property label;
  property balance;
  property interest_rate;
  property is_emergency;
  property min_payment;
  property is_hot; // plan
  property calculated_payment; // plan
  property pay_date; // event
  property calculated_for_month; // event
  property calculated_for_year; // event

  function init( string card_id = 0, string user_id = 0, string label = "", string balance = 0, string interest_rate = 0.29, string is_emergency = 0, string min_payment = "", string is_hot = 0, string calculated_payment = "", date pay_date='1900-1-1', string calculated_for_month = "", string calculated_for_year = "" ) {

    variables.card_id = card_id;
    variables.user_id = user_id;
    variables.label = label;
    variables.balance = balance;
    variables.interest_rate = interest_rate;
    variables.is_emergency = is_emergency;
    variables.min_payment = min_payment; // "" = init; populated on first get() if there is a balance and min_payment was never set after init.
    variables.is_hot = is_hot;
    variables.calculated_payment = calculated_payment; // "" = init, 0 or positive = calculated payment, -1 = do not/can not pay
    variables.pay_date = pay_date;
    variables.calculated_for_month = calculated_for_month;
    variables.calculated_for_year = calculated_for_year;

    return this;

  }

  function getRemaining_Balance() {

    // remaining balance is never stored, always calculated
    // it is what the balance *will be if the calculated payment is applied to the current balance*
    // eg. balance = $100.00, calculated_payment = $15.00, remaining_balance = $85.00
    // automatically handles zeroing account when the balance isn't 0, or when the calculated payment ends up being more than the balance
    if ( IsNumeric( variables.calculated_payment )
        && ( variables.balance > 0 )
        && ( variables.calculated_payment > 0 )
        && ( variables.balance > variables.calculated_payment ) 
    )
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

  function getMin_Payment() {

    // this logic is used as a convenience when people do not specify minimum payments
    // if instatiated with no minimum payment, we calc a min payment, and the first "get" will set it.
    // honors a previously set value of 0.
    // primary use: Onboarding; the user is never asked for a min. payment

    // a min_payment was never set
    if ( variables.min_payment is "" ) {
      // if there's a balance...
      if ( variables.balance > 0 ) {
        // calculate it
        calculateMin_Payment();
        // ...and return it.
        return variables.min_payment;
      } else {
        // there's no balance, so therefore, can't calculate a default. Leave private var alone, for a potential future get().
        return 0;
      }
    } else {
      return variables.min_payment;
    }
  }

  function calculateMin_Payment() {

    // similar to above, this forces a min payment calculation. Unlike above, does not care if min_payment is currently 0.
    // primary use: The 30 Day Rule, during dbCalculateSchedule.

    // ...set a default to 3% of balance
    variables.min_payment = (variables.balance * 0.03);

  }

  function calculated_for() {

    if ( IsNumeric(variables.calculated_for_year) && IsNumeric(variables.calculated_for_month) )

      return CreateDate( variables.calculated_for_year, variables.calculated_for_month, 1 );

    else

      return '1900-01-01';

  }

}