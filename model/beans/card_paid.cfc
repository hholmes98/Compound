//model/beans/card_paid
component accessors=true {

  property user_id;
  property card_id;
  property actual_payment;
  property actually_paid_on;
  property payment_for_month;
  property payment_for_year;

  function init( string user_id = "", string card_id = "", string actual_payment = "", string actually_paid_on = "", string payment_for_month = "", string payment_for_year = "" ) {

    variables.user_id = arguments.user_id;
    variables.card_id = arguments.card_id;
    variables.actual_payment = arguments.actual_payment;
    variables.actually_paid_on = arguments.actually_paid_on;
    variables.payment_for_month = arguments.payment_for_month;
    variables.payment_for_year = arguments.payment_for_year;

    return this;

  }

  function flatten() {

    var cp = Duplicate(variables);

    return cp;

  }

}