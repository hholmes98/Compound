//model/beans/plan_card
component accessors=true extends=model.beans.card {

  /* you shouldn't have to do this */
  property card_id; // number
  property credit_limit; // number (8,2)
  property due_on_day; // int (day of month)
  property user_id; // number
  property label; // string
  property min_payment; // number (8,2)
  property is_emergency; // smallint
  property balance; // number (8,2)
  property interest_rate; // decimal
  property zero_apr_end_date; // date
  /* end */

  property plan_id;
  property is_hot;
  property calculated_payment;

  function init( string card_id = 0, string credit_limit= -1, string due_on_day= 0, string user_id="", string label="", 
      string min_payment="", string is_emergency=0, string balance=0, string interest_rate=0.29, 
      string zero_apr_end_date="1900-01-01", string plan_id = 0, string is_hot=0, string calculated_payment="" ) {

    variables.plan_id = arguments.plan_id;
    variables.is_hot = arguments.is_hot;
    variables.calculated_payment = arguments.calculated_payment;

    return super.init(
      arguments.card_id,
      arguments.credit_limit,
      arguments.due_on_day,
      arguments.user_id,
      arguments.label,
      arguments.min_payment,
      arguments.is_emergency,
      arguments.balance,
      arguments.interest_rate,
      arguments.zero_apr_end_date
    );

  }

  function getRemaining_Balance() {

    // remaining balance is never stored, always calculated
    // it is what the balance *will be if the calculated payment is applied to the current balance*
    // eg. balance = $100.00, calculated_payment = $15.00, remaining_balance = $85.00
    // automatically handles zeroing account when the balance isn't 0, or when the calculated payment ends up being more than the balance

    if ( IsNumeric( variables.calculated_payment ) ) {

      // if the card was deferred (-1), the remaining balance == balance
      if ( variables.balance > 0 && variables.calculated_payment < 0 )
        return variables.balance;

      else if ( ( variables.balance > 0 )
        && ( variables.calculated_payment >= 0 )
        && ( variables.balance > variables.calculated_payment ) 
      )
        return Evaluate( variables.balance - variables.calculated_payment );

    } else {
      return 0;
    }

  }

  // workaround until this bug is fixed: https://luceeserver.atlassian.net/browse/LDEV-1789?inbox=true
  function flatten() {

    var c_data = super.flatten();

    c_data.plan_id = variables.getplan_id();
    c_data.is_hot = variables.getis_hot();
    c_data.calculated_payment = variables.getcalculated_payment();

    return c_data;

  }

}