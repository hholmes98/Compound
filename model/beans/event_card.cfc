//model/beans/event_card
component accessors=true extends=model.beans.plan_card {

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
  property code; // string
  property priority; // numeric

  /* end */

  /* or this!! */
  property plan_id;
  property is_hot;
  property calculated_payment;
  /* end */

  property event_id;
  property pay_date;

  function init( string card_id = 0, string credit_limit= -1, string due_on_day= 0, string user_id="", string label="", 
      string min_payment="", string is_emergency=0, string balance=0, string interest_rate=0.29, 
      string zero_apr_end_date="", string code="", string priority=0, string plan_id=0, string is_hot="",
      string calculated_payment="", string event_id=0, string pay_date="" ) {

    variables.event_id = arguments.event_id;
    variables.pay_date = arguments.pay_date;

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
      arguments.zero_apr_end_date,
      arguments.code,
      arguments.priority,
      arguments.plan_id,
      arguments.is_hot,
      arguments.calculated_payment
    );

  }

  function calculated_for() {

    if ( IsNumeric(variables.calculated_for_year) && IsNumeric(variables.calculated_for_month) )

      return CreateDate( variables.calculated_for_year, variables.calculated_for_month, 1 );

    else

      return '1900-01-01';

  }

  // workaround until this bug is fixed: https://luceeserver.atlassian.net/browse/LDEV-1789?inbox=true
  function flatten() {

    var c_data = super.flatten();

    c_data.event_id = variables.getevent_id();
    c_data.pay_date = variables.getpay_date();

    return c_data;

  }

}