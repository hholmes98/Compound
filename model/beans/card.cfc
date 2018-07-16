//model/beans/card
component accessors = true {

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
  property code; // string
  property priority; // numeric

  function init( string card_id = 0, string credit_limit= -1, string due_on_day= 0, string user_id="", string label="", 
    string min_payment="", string is_emergency=0, string balance=0, string interest_rate=0.29, 
    string zero_apr_end_date="", string code="", string priority="" ) {

    variables.card_id = arguments.card_id;
    variables.credit_limit = arguments.credit_limit;
    variables.due_on_day = arguments.due_on_day;
    variables.user_id = arguments.user_id;
    variables.label = arguments.label;
    variables.min_payment = arguments.min_payment;
    variables.is_emergency = arguments.is_emergency;
    variables.balance = arguments.balance;
    variables.interest_rate = arguments.interest_rate;
    variables.zero_apr_end_date = arguments.zero_apr_end_date;
    variables.code = arguments.code;
    variables.priority = arguments.priority;

    return this;

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

  // workaround until this bug is fixed: https://luceeserver.atlassian.net/browse/LDEV-1789?inbox=true
  function flatten() {

    var c_data = StructNew();

    c_data.card_id = variables.getcard_id();
    c_data.credit_limit = variables.getcredit_limit();
    c_data.due_on_day = variables.getdue_on_day();
    c_data.user_id = variables.getuser_id();
    c_data.label = variables.getlabel();
    c_data.min_payment = variables.getmin_payment();
    c_data.is_emergency = variables.getis_emergency();
    c_data.balance = variables.getbalance();
    c_data.interest_rate = variables.getinterest_rate();
    c_data.zero_apr_end_date = variables.getzero_apr_end_date();
    c_data.code = variables.getcode();
    c_data.priority = variables.getpriority();

    return c_data;

  }

}