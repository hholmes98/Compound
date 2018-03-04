// model/beans/card
component accessors = true {

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

  function init( string card_id = 0, string user_id = 0, string label = "", string balance = 0, string interest_rate = 0.29, string is_emergency = 0, string min_payment = "", string is_hot = 0, string calculated_payment = 0, date pay_date='1900-1-1' ) {

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

    // remaining balance is never stored, always calculated
    // it is what the balance *will be if the calculated payment is applied to the current balance*
    // eg. balance = $100.00, calculated_payment = $15.00, remaining_balance = $85.00
    // automatically handles zeroing account when the balance isn't 0, or when the calculated payment ends up being more than the balance
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

  function getMin_Payment() {

    // this logic is used as a convenience when people do not specify minimum payments (primarily via onboarding)
    // if instatiated with no minimum payment, we calc a min payment, and the first "get" will set it.
    if ( variables.min_payment is "" ) {
      // if there's a balance...
      if ( variables.balance > 0 ) {
        // ...set a default to 3% of balance
        variables.min_payment = (variables.balance * 0.03);
        // ...and return it.
        return variables.min_payment;
      } else {
        // there's no balance and no min payment, so $0, but leave the private var "".
        return 0;
      }
    } else {
      return variables.min_payment;
    }
  }

}