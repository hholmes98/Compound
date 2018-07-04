// controllers/profile.cfc
component accessors=true {

  property userService;
  property paymentService;

  function init( fw, beanFactory ) {

    variables.fw = fw;
    variables.beanFactory = arguments.beanFactory;

  }

  function before( struct rc ) {

    rc.stripe = new stripe_cfml.stripe(
      apiKey = '#application.stripe_secret_key#',
      config = {}
    );

  }

  /***********/
  /* private */
  /***********/

  private function loadCustomer( struct rc ) {
    param name="rc.customer" default=StructNew();

    var custObj = rc.stripe.customers.retrieve( arguments.rc.customer_id );

    if ( !StructKeyExists( custObj.content, 'error' ) )
      rc.customer = custObj.content;

  }

  private function loadInvoices( struct rc ) {
    param name="rc.invoices" default=ArrayNew(1);

    var invObj = rc.stripe.invoices.list({
      customer:arguments.rc.customer_id
    });

    if ( !StructKeyExists( invObj.content, 'error' ) )
      rc.invoices = invObj.content.data;

  }

  /**********/
  /* public */
  /**********/

  function advanced( struct rc ) {

    // defaults
    rc.customer = StructNew();
    rc.subscription = StructNew();
    rc.card = StructNew();
    rc.invoices = ArrayNew(1);
    rc.payment_status = '';
    rc.asterisks = '';

    if ( session.auth.user.getStripe_Customer_Id() != '' ) {

      // customer info
      rc.customer_id = session.auth.user.getStripe_Customer_Id();
      loadCustomer( arguments.rc );

      // credit card info
      if ( rc.customer.default_source != '' && ArrayLen( rc.customer.sources.data ) && rc.customer.sources.data[1].id == rc.customer.default_source ) {

        rc.card = rc.customer.sources.data[1];
        rc.asterisks = variables.paymentService.getAsterisks( rc.card.brand );

      }

      // subscription info
      if ( ArrayLen( rc.customer.subscriptions.data ) && rc.customer.subscriptions.data[1].id == session.auth.user.getStripe_Subscription_Id() ) {

        rc.subscription = rc.customer.subscriptions.data[1];
        rc.payment_status = variables.paymentService.getPaymentStatus( rc.subscription.status );

        // if the user has cancelled recently (and the account is still active with time remaining), we'll still tell them their account is cancelled
        if ( rc.subscription.cancel_at_period_end ) {
          rc.payment_status = '<font color="red">Canceled</font>';
        }

      }

      // invoice info
      loadInvoices( arguments.rc );

    }

  }

  function paymentComplete( struct rc ) {

    var logPayment = false;
    var delim = 'c';

    /* use cases supported
    existing - paidUpgrade
    existing - upgrade
    existing - downgrade
    existing - re-subscribe (samegrade)
    */

    // if stripe user doesn't exist, create (for "paidUpgrade")
    if ( session.auth.user.getStripe_Customer_Id() == '' ) {

      // create the actual customer in stripe
      var createObj = rc.stripe.customers.create({
        email: '#session.auth.user.getEmail()#',
        source: '#rc.stripeToken#' // this is a payment object, via Billing
      });

      if ( !StructKeyExists( createObj.content, 'error') ) {
        var customer = createObj.content;

        // update bean
        session.auth.user.setStripe_Customer_Id( customer.id );

        // save to db
        variables.userService.save( session.auth.user.flatten() );

      } else {

        /* ref:

        content.error.code
        content.error.doc_url
        content.error.message
        content.error.param
        content.error.type

        */

        rc.message = ["Oops! There was a problem creating a customer account (" & createObj.content.error.message & ")"];

        variables.fw.redirect( 'profile.basic', 'message' );

      }

    }

    /* if stripe subscription (a paid plan) doesn't exist, create it (for "paidUpgrade") */
    if ( session.auth.user.getStripe_Subscription_Id() == '' ) {

      // step3: create a new subscription, and attach the customer's chosen plan
      var subObj = rc.stripe.subscriptions.create({
        customer: '#session.auth.user.getStripe_Customer_Id()#',
        items: [{plan: '#rc.stripe_plan_id#'}]
      });

      if ( !StructKeyExists( subObj.content, 'error' ) ) {

        var subscription = subObj.content;

        // if successful, update
        session.auth.user.setStripe_Subscription_Id( subscription.id );
        session.auth.user.setAccount_Type_Id( variables.paymentService.getAccountTypeFromPlan( subscription.items.data[1].plan.id ) );

        // save
        userService.save( session.auth.user.flatten() );

        // log this
        logPayment = true;

      } else {

        rc.message = ["Oops! There was a problem creating a customer account (" & createObj.content.error.message & ")"];

        variables.fw.redirect( 'profile.basic', 'message' );

      }


    } else {

      delim = 'u';

      /* use cases: paid(low)to-paid(high) only (eg "upgrade", "downgrade") */

      var subObj = rc.stripe.subscriptions.retrieve(
        subscription_id = '#session.auth.user.getStripe_Subscription_Id()#'
      );

      var subscription = subObj.content;

      //TODO: Trap errors here

      var subscriptionItems = subscription.items.data;
      var currentItem = subscriptionItems[subscription.items.total_count];

      /* if it is an upgrade (old_plan_id < new_plan_id) ("upgrade") */
      if ( variables.paymentService.getAccountTypeFromPlan( currentItem.plan.id ) < variables.paymentService.getAccountTypeFromPlan( rc.stripe_plan_id ) ) {

        //1. get existing subscriptionItem, delete it. (prorate should fire by default)
        subObj = rc.stripe.subscriptionItems.del({
          item: '#currentItem.id#',
          prorate: true
        });

        //2. create new subscriptionItem (new plan), active now (charge the user, prorate it).
        subObj = rc.stripe.subscriptionItems.create({
          subscription_id: '#session.auth.user.getStripe_Subscription_Id()#',
          plan_id: '#rc.stripe_plan_id#',
          prorate: true
        });

        // TODO: trap errors here.

        //3. update user account_type_id now.
        session.auth.user.setAccount_Type_Id( variables.paymentService.getAccountTypeFromPlan( rc.stripe_plan_id ) );

        // save
        userService.save( session.auth.user.flatten() );

        // log payment
        logPayment = true;

      /* if it is a downgrade (old_plan_id > new_plan_id ) ("downgrade") */
      } else if ( variables.paymentService.getAccountTypeFromPlan( currentItem.plan.id ) > variables.paymentService.getAccountTypeFromPlan( rc.stripe_plan_id ) ) {

        //1. get existing plan, set it to expire at the end date.
        subObj = rc.stripe.subscriptionItems.update({
          item: '#currentItem.id#',
          quantity: 0
        });

        //2. add new plan, active at the end date of the previous plan (don't charge the user right now).
        subObj = rc.stripe.subscriptionItems.create({
          subscription_id: '#session.auth.user.getStripe_Subscription_Id()#',
          plan_id: '#rc.stripe_plan_id#',
          prorate: true,
          proration_date: '#subscription.current_period_end#' // i'm hoping this is the same as saying 'since we're changing in the  middle of the month, i'm charging you as if you were added at the end of the current plan's expiry
        });

        //3. done (don't update the user account_type_id...it'll be pinged later via webhook)

        // TODO trap errors

      } else {

        // if the (old_plan_id == new_plan_id), this is the resubscribe use-case ("samegrade")
        var subObj = rc.stripe.subscriptions.update(
          subscription_id = '#session.auth.user.getStripe_Subscription_Id()#',
          items = [{plan: '#rc.stripe_plan_id#'}]
        );

        var subscription = subObj.content;

        // TODO: error trap

        logPayment = true;

      }

    }

    // store the purchase 
    if ( logPayment ) {

      var userPayment = variables.beanFactory.getBean('user_purchaseBean');
      userPayment.setUser_Id( session.auth.user.getUser_Id() );
      userPayment.setStripe_Customer_Id( session.auth.user.getStripe_Customer_Id() );
      //userPayment.setStripe_Payment_Id( ); // not sure yet. source_id perhaps?
      userPayment.setStripe_Plan_Id( rc.stripe_plan_id );
      userPayment.setStripe_Subscription_Id( session.auth.user.getStripe_Subscription_Id() );
      userPayment.setGood_Until( subscription.current_period_end );

      // save it
      paymentService.save( userPayment.flatten() );

    }

    // no errors? Redirect to confirmed
    // TODO: if it is an updated subscription, use /u/, and track it differently in GA
    variables.fw.redirect( 'profile.paymentConfirmed' & '/' & delim & '/' & paymentService.getAccountTypeFromPlan( rc.stripe_plan_id ) );

  }

  function cancelSub( struct rc ) {

    var subObj = rc.stripe.subscriptions.delete(
      subscription_id = '#session.auth.user.getStripe_Subscription_Id()#',
      at_period_end = true /* since we charge at the start of the month, we'll always give the user the remaining days that were paid for */
    );

    var subscription = subObj.content;

    // TODO: trap errors

    // we don't write anything to pUserPurchases, since the previous entry in pUserPurchases will have the 'good_until' date.

    // we're done
    variables.fw.redirect('profile.cancelConfirmed');

  }

  function upgradeSub( struct rc ) {
    param name="rc.upgrade" default="upgrade";

    // handles free->paid
    // handles paid->paid (higher)

    /*
    This interface kicks in when a user wants to either
    a) upgrade a free account to a paid account,
    b) upgrade a paid account to another type of paid account (with more features), or
    c) resubscribe to a previously-canceled paid account.

    In all 3 instances, a valid source (method-of-payment) is already in-play, so we're just:
    a) re-configuring the subscription in stripe, and
    b) re-configuring the subscription locally.
    */

    rc.customer_id = session.auth.user.getStripe_Customer_Id()
    loadCustomer( arguments.rc );

    rc.card = rc.customer.sources.data[1];
    rc.asterisks = paymentService.getAsterisks( rc.card.brand );
    rc.subscription = rc.customer.subscriptions.data[1];

    // step 2: grab the sub that we're working with
    //var subObj = rc.stripe.subscriptions.retrieve( session.auth.user.getStripe_Subscription_Id() );

    //rc.subscription = subObj.content;

  }

  function resubscribe( struct rc ) {

    rc.upgrade = "resub";

    upgradeSub( arguments.rc );

    variables.fw.setView('profile.upgradeSub');

  }

  /*******
  * REST *
  *******/

  function savePaymentInfo( struct rc ) {

    // if this is the very first time you're adding a card, we might not have a Stripe customer_id yet
    if ( session.auth.user.getStripe_Customer_Id() == '' ) {

      // create the actual customer
      var createObj = rc.stripe.customers.create({
        email: '#session.auth.user.getEmail()#',
        source: '#rc.stripeToken#' // this is a payment object (source), via Billing
      });

      var customer = createObj.content;

      // update bean
      session.auth.user.setStripe_Customer_Id( customer.id );

      // save
      userService.save( session.auth.user.flatten() );

    } else {

      // update the customer
      var updateObj = rc.stripe.customers.update(
        customer_id = '#session.auth.user.getStripe_Customer_Id()#',
        source = '#rc.stripeToken#' // see above
      );

      var customer = updateObj.content;

    }

    variables.fw.renderdata( 'JSON', customer );

  }

}