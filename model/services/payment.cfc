//model/services/payment.cfc
component accessors=true {

  function init( beanFactory ) {

    variables.beanFactory = arguments.beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  public function save( any userPayment ) {

    var sql = '
      INSERT INTO "pUserPurchases"
      (
        user_id,
        stripe_customer_id,
        stripe_payment_id,
        good_until,
        stripe_plan_id,
        stripe_subscription_id,
        memo
      ) 
      VALUES
      (
        #arguments.userPayment.user_id#,
        ''#arguments.userPayment.stripe_customer_id#'',
        ''#arguments.userPayment.stripe_payment_id#'',
        #CreateODBCDate( arguments.userPayment.good_until )#,
        ''#arguments.userPayment.stripe_plan_id#'',
        ''#arguments.userPayment.stripe_subscription_id#'',
        ''#arguments.userPayment.memo#''
      );
    ';

    var params = {};

    result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if error

  }

  public function getAccountTypeFromPlan( string plan_id ) {

    for ( var account_type in application.stripe_plans ) {

      if ( application.stripe_plans[account_type].id == arguments.plan_id ) {
        return account_type;
      }

    }

    return 0;

  }

  public function getPaymentStatus( string status ) {

    // arguments.status = stripe.subscription.status
    // https://stripe.com/docs/api#subscription_object

    switch(arguments.status) {

      case 'active':
        return 'Good standing';
        break;

      case 'past_due':
        return '<font color="red">Past Due</font>';
        break;

      case 'canceled':
        return '<font color="red">Canceled</font>';
        break;

      //case 'unpaid': // I don't think we'll configure to use this setting
      //case 'trialing': - don't use in DD

      default:
        Throw( message="Unidentified subscription status",
               errorcode="ERR_STRIPE_UNKNOWN_PAYMENT_STATUS",
               detail="The value of the 'status' field from the Stripe subscription, " & arguments.status & ", is unidentified and cannot be processed via paymentStatus.getPaymentStatus()" );
        break;

    }

  }

  public function getAsterisks( string card_type ) {

    switch( arguments.card_type ) {

      case 'Visa':
        return '**** **** **** ';
        break;

      case 'MasterCard':
      case 'American Express':
      case 'Diners Club':
      case 'Discover':
      case 'JCB':
      case 'UnionPay':
      default:
        return '**** **** ****';
        break;

    }

  }

}
