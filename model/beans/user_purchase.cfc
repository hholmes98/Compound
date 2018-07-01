//model/beans/user_purchase
component accessors=true {

  property user_id;
  property stripe_customer_id;
  property stripe_payment_id;
  property good_until;
  property stripe_plan_id;
  property stripe_subscription_id;
  property memo;

  function init( string user_id = "", string stripe_customer_id= "", string good_until = "", string stripe_plan_id = "", string stripe_subscription_id = "", string memo = "" ) {

    variables.user_id = arguments.user_id;
    variables.stripe_customer_id = arguments.stripe_customer_id;
    variables.good_until = arguments.good_until;
    variables.stripe_plan_id = arguments.stripe_plan_id;
    variables.stripe_subscription_id = arguments.stripe_subscription_id;
    variables.memo = arguments.memo;

    return this;

  }


  function flatten() {

    var up_data = Duplicate(variables);

    return up_data;

  }

}