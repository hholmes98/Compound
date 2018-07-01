// model/services/temp
component accessors=true {

  property cardService;
  property planService;
  property eventService;

  public any function init( beanFactory ) {

    variables.beanFactory = arguments.beanFactory;

    return this;

  }

  public any function list( string user_id ) {

    var plan = createPlan( arguments.user_id );

    return plan;

  }

  public any function createPlan( string user_id ) {

    var payment_plan = 0;
    var budget = 0;
    var deck = 0;

    /*
    // 1. get the temp user's budget
    budget = session.tmp.preferences.budget;

    // 2. Get the temp user's list of cards
    deck = session.tmp.cards;

    // 3. run calculatePayments(), passing in deck and budget
    try {
      payment_plan = dbCalculateTempPayments( deck, budget );
    } catch ( any e ) {
      if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
        // make a second attempt, but not adding interest to the minimum payment.
        payment_plan = dbCalculateTempPayments( deck, budget, false );
      } else {
        // TODO: make a third attempt that simply pays only certain cards, until the budget is used up.
        rethrow;
      }
    }*/

    // 1. get the TEMP user's budget
    var budget = session.tmp.preferences.budget;

    // 2. Get the TEMP user's deck
    var plan_deck = variables.beanFactory.getBean('deckBean');
    var cards = Duplicate( session.tmp.cards );
    plan_deck.setDeck_Cards( cards );

    // 3. prep a plan bean
    var in_plan = variables.beanFactory.getBean('planBean');

    in_plan.setUser_Id( arguments.user_id );
    in_plan.setPlan_Deck( plan_deck );
    in_plan.setActive_On( CreateDate( Year( Now() ), Month( Now() ), 1 ) );

    var out_plan = planService.calculatePayments( in_plan, budget, Now() );

    // 4. We don't save temp plans, we just return 'em.
    return out_plan;

  }

  public any function createEvent( struct in_plan, date target="1900-01-01" ) {

    // ================
    // 1. prep defaults
    // ================
    var plan = arguments.in_plan;
    var user_id = plan.getUser_Id();
    var deck = plan.getPlan_Deck(); // should probably run a verify here - must be a populated plan.
    var cards = deck.getDeck_Cards();
    var pay_freq = 0;
    var calculated_for = arguments.target;

    // if target isn't specified, pull it from the plan.
    if ( calculated_for == "1900-01-01" ) {
      calculated_for = plan.getActive_On();
    }

    // the new event!
    var event = variables.beanFactory.getBean('eventBean');
    event.setPlan_Id( plan.getPlan_Id() );
    event.setPlan( plan );
    event.setCalculated_For_Month( Month(calculated_for) );
    event.setCalculated_For_Year( Year(calculated_for) );

    // 1. including the_date[], an array of dates in the month that will be used as a ref. point
    // for deciding what to assign to each card.
    var valid_dates_for_month = ArrayNew(1);
    valid_dates_for_month[1] = CreateDate( Year( calculated_for ), Month( calculated_for ), DaysInMonth( calculated_for ) ); // end of the month

    // 2. Examine the user's preferences, and modify/update the_date[] accordingly.
    if ( pay_freq == 2 ) {

      valid_dates_for_month[2] = CreateDate( Year( calculated_for ), Month( calculated_for ), 15 );

    } else if ( pay_freq == 3 ) {

      var qMonthPayPeriods = eventService.qGetPayPeriodsInMonthOfDate( calculated_for );

      for ( var m=qMonthPayPeriods.RecordCount; m > 0; m-- ) { // walk backwards

        valid_dates_for_month[m] = qMonthPayPeriods.pay_date[m];

      }

    }

    // 3. Reduce the cards to only those with a balance, and split their payments with a knapsack algorithm
    var nonzero_cards = plan.getNonZeroCalculatedPaymentCards();
    var paymentsArray = eventService.splitPayments( nonzero_cards, ArrayLen(valid_dates_for_month) );

    // 4. Assign pay_dates to the split payments, based on the available dates of the month (the_date[]).
    var pay_dates = ArrayReverse( valid_dates_for_month ); // pay_dates should now be 1st, 15th, 30th, etc.

    // looping over the pay_days array assures us we'll only use what we *need* from the_dates[], so if we erroneously
    // assigned a 3rd pay date -- we won't even iterate that far.
    for ( var p=1; p <= ArrayLen(paymentsArray); p++ ) {

      for ( var card_id in paymentsArray[p] ) {

        if ( paymentsArray[p][card_id] > 0 ) {

          var card = plan.getCard( card_id );

          // populate event_card bean with its starting values
          var event_card = variables.beanFactory.getBean('event_cardBean').init( argumentCollection=card.flatten() );

          event_card.setPay_Date( pay_dates[p] );

          // store in event
          event.addCard( event_card );

        }

      }

    }

    // 5. FIXME: Handle any ignored cards (not sure why they should be included at all?) - their absence is probably fucking up forecasting.


    // 6. create event bean and populate
    return event;

  }

  public function fillEvents( any in_plan ) {

    /*
    1. prep vars
    - grab a copy of the plan's fingerprint
    2. get the user's budget
    3. start a new events array
    4. get the user's plan
    */
    var plan = arguments.in_plan;
    var fp = plan.getFingerprint();
    var user_id = plan.getUser_Id();
    var deck = plan.getPlan_Deck();
    var cards = deck.getDeck_Cards();
    var budget = session.tmp.preferences.budget;
    var next_date = plan.getActive_On();
    var events = ArrayNew(1);
    /* 5. convert the plan into an event.*/
    var event = createEvent( plan );
    /* 6. add that new event into the events array */
    ArrayAppend( events, event );
    /*7. calculate the total_remaining_balance by summing the remaining_balance of each card in the current event*/
    var totalrb = event.getEvent_Cards().reduce( function(result, key, value) {
      return result + value.getRemaining_Balance();
    }, 0);

    /*8. while the total_remaining_balance > 0 loop*/
    while ( totalrb > 0 ) {

      /*********************
      forcast 1 month ahead,
      based off current plan
      *********************/

      /*8a. add a month to the working date*/
      var next_date = DateAdd( 'm', 1, next_date );

      /*8b. loop over each card in the plan*/
      for ( var card_id in cards ) {

        // reset any ignored/deferred cards
        if ( cards[card_id].getCalculated_Payment() < 0 )
          cards[card_id].setCalculated_Payment( 0 );

        // trigger the 30 day rule on a card with a balance but no min. payment
        // just calculate a min. payment, leave the balance alone
        if ( cards[card_id].getBalance() > 0 && cards[card_id].getMin_Payment() == 0 )
            cards[card_id].calculateMin_Payment();

        // if there is a remaining balance
        if ( cards[card_id].getRemaining_Balance() > 0 ) {

            // 8bi. calculate the interest for next month
            var next_interest = plan.calculateMonthInterest( cards[card_id].getRemaining_Balance(), cards[card_id].getInterest_Rate(), next_date );

            // 8bii. add it to the card's reamining_balance.
            var next_balance = cards[card_id].getRemaining_Balance() + next_interest;

            // 8biii and set it
            cards[card_id].setBalance( next_balance );

        // no remaining balance, so next month, the balance = 0
        } else {

          cards[card_id].setBalance( 0 );

        }

      } // end update all cards +1 month

      deck.setCards( cards );
      plan.setPlan_Deck( deck );
      plan = planService.calculatePayments( plan, budget, next_date );

      // *****************
      // plan save 
      // (if new enough)
      // *****************

      // 8c-0. if the current plan's fingerprint is not the same as the orig. fingerprint
      if ( plan.getFingerprint() != fp ) {

        // negate the plan_id
        plan.setPlan_Id( 0 );
        // update the active_on date
        plan.setActive_On( next_date );
        // save it
        //if ( !arguments.no_cache ) {
          //plan_id = planService.save( plan );
          // update the plan obj
          //plan.setPlan_Id( plan_id );
        //}

        // now use this plan to create a new event
        var new_event = createEvent( plan );

        // update the fingerprint
        fp = plan.getFingerprint();

      } else {

        // use the existing plan, but pass in the new working date
        var new_event = createEvent( plan, next_date );

      }

      // append the new event
      ArrayAppend( events, new_event );

      // save the event
      //save( new_event );

      // update total_rb
      totalrb = new_event.getEvent_Cards().reduce( function(result, key, value) {
        return result + value.getRemaining_Balance();
      }, 0);

    } // end while

    return events;

  }

}