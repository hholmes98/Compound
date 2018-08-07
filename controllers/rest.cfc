//controllers/rest
component accessors=true {

  property cardService;
  property card_paidService;
  property planService;
  property eventService;
  property preferenceService;
  property tokenService;
  property paymentService;

  function init( fw ) {

    variables.fw = arguments.fw;

  }

  function before( struct rc ) {
    param name="rc.validatedHeader" default={name:'X-XSRF-DD-TOKEN-VALIDATED',value:'Unknown'};
    param name="rc.statusCode" default=200;
    param name="rc.result" default=StructNew();
    param name="rc.result['ERROR']" default=StructNew();

    rc.stripe = new stripe_cfml.stripe(
      apiKey = '#application.stripe_secret_key#',
      config = {}
    );

    validateToken( arguments.rc );
  }

  /********************

      PRIVATE

  ********************/

  private function onRestError( struct e ) {

    // for now, it's just a pass through, but we may look at decorating the error for json specifically
    return arguments.e;

  }

  private function validateToken( struct rc ) {

    if ( variables.fw.getEnvironment() == 'production' ) {

      try {

        if ( StructKeyExists( getHTTPRequestData().headers, 'X-XSRF-DD-TOKEN' ) ) {

          var payload = DeserializeJSON( getHTTPRequestData().headers['X-XSRF-DD-TOKEN'] );

          var v_token = tokenService.validatePayload( payload );

          if ( v_token.valid ) {

            rc.validatedHeader.value = true;

          } else {

            rc.validatedHeader.value = false;
            Throw( message="Invalid token detected.", 
              detail="The X-XSRF-DD-TOKEN is invalid (expected: " & v_token.expected & ", received: " & v_token.received & ")." );

          }

         } else {

           Throw( message="Token not found.", 
             detail="The X-XSRF-DD-TOKEN is missing." );

        }

      } catch ( any e ) {

        rc.result['ERROR'] = onRestError( e );
        rc.statusCode = 500;

      }

    }

  }

  private void function eventsPopulate( struct rc ) {

    // get all events for this user
    var events = eventService.list( arguments.rc.user_id );

    // if none, create 1
    if ( !ArrayLen(events) ) {

      // get all plans for this user.
      var plans = planService.list( arguments.rc.user_id );

      // if none, create 1.
      if ( !ArrayLen(plans) ) {
        var plan = planService.create( arguments.rc.user_id );
      // if some, just return the 1st one, as they return chronologically.
      } else {
        var plan = plans[1];
      }

      var events = eventService.fill( plan );
    }

    arguments.rc.events = events;

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

  private function loadCardInfo( struct rc ) {
    param name="rc.card" default=StructNew();
    param name="rc.asterisks" default=StructNew();

    // credit card info
    if ( StructKeyExists( rc.customer, 'default_source' ) &&
        rc.customer.default_source != '' && 
        StructKeyExists( rc.customer, 'sources' ) &&
        ArrayLen( rc.customer.sources.data ) && 
        rc.customer.sources.data[1].id == rc.customer.default_source ) {

      rc.card = rc.customer.sources.data[1];
      rc.asterisks = variables.paymentService.getAsterisks( rc.card.brand );

    }

    //TODO: else, add a specific call to stripe to retrieve the card info (if needed)

  }

  private function loadInvoices( struct rc ) {
    param name="rc.invoices" default=ArrayNew(1);

    var invObj = rc.stripe.invoices.list({
      customer:arguments.rc.customer_id
    });

    if ( !StructKeyExists( invObj.content, 'error' ) )
      rc.invoices = invObj.content.data;

  }

  /**********************

      PUBLIC

  **********************/

  /******* DECK ******/

  // controller.deck.list
  public void function deckList( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = cardService.deck( arguments.rc.user_id ).getDeck_Cards();
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.detail
  public void function deckGet( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = cardService.get( arguments.rc.id );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.save
  public void function deckSave( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = cardService.save( arguments.rc );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.delete
  public void function deckDelete( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = cardService.delete( arguments.rc.id );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.emergency
  public void function deckEmergency( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = cardService.setEmergencyCard( arguments.rc.card_id );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.getCardPayments
  public void function deckCardPaymentsList( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = card_paidService.list( arguments.rc.user_id, arguments.rc.month, arguments.rc.year );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.cardPaymentSave
  public void function deckCardPaymentSave( struct rc ) {
    param name="rc.actually_paid_on" default=Now();

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = card_paidService.save( arguments.rc );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.deck.getCardPayment
  public void function deckCardPaymentGet( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = card_paidService.get( arguments.rc.card_id, arguments.rc.month, arguments.rc.year );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  /********** PLANS ***********/

  // controller.plans.first
  public void function plansFirst( struct rc ) {

    try {
      if ( rc.statusCode == 200 ) {

        // get all plans for this user.
        var plans = planService.list( arguments.rc.user_id );

        // if none, create 1.
        if ( !ArrayLen(plans) ) {
          var plan = planService.create( arguments.rc.user_id );
        // if some, just return the 1st one, as they return chronologically.
        } else {
          var plan = plans[1];
        }

        rc.result.data = plan.getPlan_Deck().getDeck_Cards();

      }
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  // controller.plans.purge
  public void function plansPurge( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = planService.purge( arguments.rc.user_id );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  /******** EVENTS **********/

  public void function eventsList( struct rc ) {

    try {
      if ( rc.statusCode == 200 ) {
        eventsPopulate( arguments.rc )
        rc.result.data = arguments.rc.events;
      }
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  public void function eventsFirst( struct rc ) {

    // formerly:
    // rc.result.data = arguments.rc.events[1];

    try {

      if ( rc.statusCode == 200 ) {

        eventsPopulate( arguments.rc )

        var event_card_ids = StructKeyList(arguments.rc.events[1].getEvent_Cards());

        var cards = {}
        var data = {};

        // loop over all the cards
        for ( var id in arguments.rc.events[1].getPlan().getPlan_Deck().getDeck_Cards() ) {

          // get the pay_date
          var card = arguments.rc.events[1].getPlan().getCard( id );
          var data[id] = card;

          if ( ListFind(event_card_ids, id) ) {
            data[id]['pay_date'] = arguments.rc.events[1].getCard( id ).getPay_Date();
          } else {
            data[id]['pay_date'] = '';
          }

        }

        rc.result.data['cards'] = data;
        rc.result.data['calculated_for_month'] = arguments.rc.events[1].getCalculated_For_Month();
        rc.result.data['calculated_for_year'] = arguments.rc.events[1].getCalculated_For_Year();

      }

    } catch ( any e ) {

      rc.statusCode = 500;
      rc.result['ERROR'] = onRestError(e);

    }

  }

  public void function eventsSchedule( struct rc ) {

    // return an array of event dates reflecting when each card is paid and by how much

    /* match this format: 

      data = [
       
        //month1
        {id: 1, title: 'Pay $28.72 to card1', start: Wed Nov 30 2017 00:00:00 GMT-0600, balance_remaining: 4.22},
        {id: 2, title: 'Pay $33.90 to card2', start: Wed Nov 30 2017 00:00:00 GMT-0600, balance_remaining: 1428.4},
        
        //month2    
        {id: 1, title: 'Pay $28.72 to card1', start: Mon Dec 31 2018 00:00:00 GMT-0600, balance_remaining: 0},
        {id: 2, title: 'Pay $33.90 to card2', start: Mon Dec 31 2018 00:00:00 GMT-0600, balance_remaining: 1389.2},

        etc...

      ];

    */

    try {

      if ( rc.statusCode == 200 ) {

        // populate events into the rc struct
        eventsPopulate( arguments.rc ); // rc.events should now exist
        var schedule = ArrayNew(1);
        var events = arguments.rc.events;

        for ( var event in events ) {

          for ( var card_id in event.getEvent_Cards() ) {

            var sItem = StructNew();

            StructInsert( sItem, 'id', event.getCard(card_id).getCard_Id() );
            StructInsert( sItem, 'title', 'Pay $' & DecimalFormat( event.getCard(card_id).getCalculated_Payment() ) & ' to ' & event.getCard(card_id).getLabel() );
            StructInsert( sItem, 'start', DateFormat( event.getCard(card_id).getPay_Date(), "ddd mmm dd yyyy" ) & ' 00:00:00 GMT-0600' );

            ArrayAppend( schedule, sItem );

          }

        }

        rc.result.data = schedule;

      }

    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  public void function eventsJourney( struct rc ) {

    // return an array of elements (each element is technically a month/year) that declare the remaining balance on each card
    // (with the implication that the schedule conveyed in events() is committed to by the user)

    // format is:
    
    /*
    data = [

      // milestone1
      {
        name: 'card1',
        data: [100, 88, 72, 69, 51, 48, 27, 12, 4, 0]   // each value in the array the balance_remaining for that month.
      },

      // milestone2
      {
        name: 'card2',
        data: [100, 72, 59, 34, 18, 9, 0]       // each value in the array the balance_remaining for that month.
      }

    ]
      */

    try {

      if ( rc.statusCode == 200 ) {

        eventsPopulate( arguments.rc );
        var events = arguments.rc.events;
        var milestones = ArrayNew(1);
        var cards = events[1].getPlan().getPlan_Deck().getDeck_Cards(); // this is convenience, just a full list of the user's card's.

        // cards is an object(struct)!
        for ( var card_id in cards ) {

          var milestone = StructNew();

          milestone["name"] = cards[card_id].getLabel();
          milestone["data"] = ArrayNew(1);

          // events is an array of structs!
          for ( var event in events ) {

            for ( var e_card_id in event.getEvent_Cards() ) {

              if ( e_card_id == card_id && event.getCard(e_card_id).getRemaining_Balance() > 0 ) {

                // append the remainig balance as a plottable point along the 
                ArrayAppend( milestone["data"], event.getCard(e_card_id).getRemaining_Balance() );

              }

            }

          }

          // add new milestones for this card
          ArrayAppend( milestones, milestone );

        }

        rc.result.data = milestones;

      }

    } catch ( any e ) {

      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;

    }

  }

  public void function eventsPurge( struct rc ) {

    try {
      // delete all events for a user_id
      if ( rc.statusCode == 200 )
        rc.result.data = eventService.purge( arguments.rc.user_id );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  /********* PREFERENCES **************/

  public void function preferencesGet( struct rc ) {

    try {
      if ( rc.statusCode == 200 )
        rc.result.data = preferenceService.get( rc.user_id );
    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  public void function preferencesSave( struct rc ) {
    param name="rc.user_id" default=0;

    try {

      if ( rc.statusCode == 200 ) {

        rc.preferences = preferenceService.get( rc.user_id );

        variables.fw.populate( cfc = rc.preferences, trim = true );

        // flatten bean to struct, pass to save service
        rc.result.data = preferenceService.save( rc.preferences.flatten() );

        session.auth.user.setPreferences( preferenceService.get( session.auth.user.getUser_Id() ) );

      }

    } catch ( any e ) {

      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;

    }

  }

  /******* PAYMENT INFO *******/

  public function profilePaymentInfoGet( struct rc ) {
    param name="rc.user_id" default="";
    param name="rc.payment" default=StructNew();

    try {
      if ( rc.statusCode == 200 ) {

        if ( Len(rc.user_id) && rc.user_id == session.auth.user.getUser_Id() && session.auth.user.getStripe_Customer_Id() != '' ) {

          // customer info
          rc.customer_id = session.auth.user.getStripe_Customer_Id();
          loadCustomer( arguments.rc );
          loadCardInfo( arguments.rc );

          rc.payment['card'] = rc.card;
          rc.payment['asterisks'] = rc.asterisks;

        }

        rc.result.data = rc.payment;

      }

    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  public function profilePaymentInfoSave( struct rc ) {

    try {
      if ( rc.statusCode == 200 ) {

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

        rc.result.data = customer;

      }

    } catch ( any e ) {
      rc.result['ERROR'] = onRestError( e );
      rc.statusCode = 500;
    }

  }

  public function after( struct rc ) {

    variables.fw.renderdata()
      .data( rc.result )
      .type( 'JSON' )
      .header( rc.validatedHeader.name, rc.validatedHeader.value )
      .statusCode( rc.statusCode );

    /* the cookie won't exist if ______
       the headers won't exist if it is the first call
    */
    if ( !StructKeyExists( COOKIE, 'XSRF-DD-TOKEN' ) ) {
      var payload = tokenService.createPayload();

      cfcookie( name="XSRF-DD-TOKEN", value=SerializeJSON( payload ), path="/", domain=".debtdecimator.com", httpOnly=false );
    }

  }

}
