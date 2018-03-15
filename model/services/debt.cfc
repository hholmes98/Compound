// model/services/debt
component accessors = true {

  property cardservice;
  property planservice;

  public any function init( beanFactory ) {

    variables.beanFactory = beanFactory;

    return this;

  }

  public any function list( string user_id ) {

    var plan = dbCalculateTempPlan( arguments.user_id );

    return plan;

  }

  public any function dbCalculateTempPlan( string user_id ) {

    var payment_plan = 0;
    var budget = 0;
    var deck = 0;

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
    }

    // 6. Return the plan
    return payment_plan;

  }

  public any function dbCalculateTempPayments( struct cards, numeric available_budget, boolean use_interest=true ) {

    var i = 0;
    var calc_payment = 0;
    var total_payments = 0;
    var user_id = 0;
    var hot_card_calculated_payment = 0;
    var smaller_budget = 0;
    var _tmpCard = 0;
    var this_interest_rate = 0;
    var each_card = 0;

    // you sent me an empty list of cards
    if ( StructIsEmpty( arguments.cards ) )
      return arguments.cards;

    var user_id = arguments.cards[ListFirst( StructKeyList( arguments.cards ) )].getUser_Id();

    // make a copy of the incoming cards...work with this var locally.
    var this_deck = Duplicate( arguments.cards );

    // reset all the calculated payments
    for ( each_card in this_deck ) {
      this_deck[each_card].setCalculated_Payment( 0 );
      this_deck[each_card].setIs_Hot( 0 );
    }

    // Get the list of card IDs in this deck (with a balance)
    var id_list = cardservice.dbGetNonZeroCardIDs( this_deck );

    // WARNING: UNKNOWN REASON
    // if the balance is zero across the user's deck
    if ( id_list == '' ) {
      return this_deck;
    }

    // I have no more budget to work with
    // TODO: Is this where we'll support the ability to stop calculating, if the budget's been used up?
    if ( arguments.available_budget <= 0 )
      return this_deck;

    // Build a query that sorts these cards so that the hot card is row 1
    var cardsQry        = qryGetNonZeroCardsByUser( user_id, id_list );
    var hot_card_id     = cardsQry.card_id[1];

    // firm up the hot card
    this_deck[hot_card_id].setIs_Hot(1);

    // 2. Loop over the cards (starting after the hot card), calculating the payment for each card that is not the hot card.
    for ( i=2; i <= cardsQry.recordcount; i++ ) {

      if ( application.AllowAvalanche ) {

        if ( cardsQry.interest_rate[i] > 0 && arguments.use_interest ) {

          this_interest_rate = cardsQry.interest_rate[i];

        } else {

          this_interest_rate = 0.0;

        }

      } else {

        this_interest_rate = 0.0;

      }

      calc_payment = planservice.dbCalculatePayment( cardsQry.balance[i], cardsQry.min_payment[i], this_interest_rate );

      this_deck[cardsQry.card_id[i]].setCalculated_Payment( calc_payment );

      // 3. add up all the calculated payments...
      total_payments += calc_payment;

    } // end the for-loop

    // 3. ...subtract from budget
    hot_card_calculated_payment = Evaluate( arguments.available_budget - total_payments );

    if ( hot_card_calculated_payment <= 0 ) {

      // not a great way to handle
      Throw( type="Custom", errorCode="ERR_BUDGET_OVERRUN", message="Budget Overrun", detail="The available budget was drained before being able to calculate the hot card's payment." );

    }

    // TODO:
    // at this point with 1 hot card (and yes, you'll *need* to ensure this is the 1st pass through the function only, because it recurses!!)
    // we'll probably want to do another check to ensure that the hot card's calculated payment is at least above the application's threshold, otherwise,
    // calculating with use_interest is probably too aggressive, and *more* $$ should be tossed toward hot card.
    // look at how we handle the emergency card's threshold too, I feel like that *and this* can be refactored together.

    // 4. Set the hot card's calculated payment
    this_deck[hot_card_id].setCalculated_Payment( hot_card_calculated_payment );

    // 5. execute postCalcuation()
    // if the calculated payment is greater than the balance, or evaluates to something less than 0 (when the min. payment
    // is larger than the balance)....
    if ( ( hot_card_calculated_payment > this_deck[hot_card_id].getBalance() ) || ( hot_card_calculated_payment < 0 ) ) {

      // 5a. Set the Hot Card's calculated payment to its balance
      this_deck[hot_card_id].setCalculated_Payment( this_deck[hot_card_id].getBalance() );

      // 5b. Calculate a new budget, reducing it by the amount of the hot card's calculated payment.
      smaller_budget = Evaluate( arguments.available_budget - this_deck[hot_card_id].getCalculated_Payment() );

      if ( smaller_budget <= 0 ) {

        // see above
        Throw( type="Custom", errorCode="ERR_BUDGET_OVERRUN", message="Budget Overrun", detail="While calculating multiple hot cards, the available budget was drained before all cards were accounted for." );

      }

      // 5c. Temporarily remove the hot card from the deck
      _tmpCard = Duplicate( this_deck[hot_card_id] );
      StructDelete( this_deck, hot_card_id, true );

      // 5d. Recurse into calculatePayments(), using the smaller deck and reduced budget
      try {
        this_deck = dbCalculateTempPayments( this_deck, smaller_budget, true );
      } catch ( any e ) {
        if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
          this_deck = dbCalculateTempPayments( this_deck, smaller_budget, false );
        } else {
          rethrow;
        }
      }

      // 5e. Add the removed hot card back into the deck
      this_deck[_tmpCard.getCard_Id()] = _tmpCard;

    }

    // 6. return the deck with calculated payments
    return this_deck;

  }

  public query function qryGetNonZeroCardsByUser( string user_id, string include_list='', boolean prioritize_emergency=false ) {

    var cards = duplicate( session.tmp.cards );
    var rows = 0;
    var tmpQry = {};
    var key = '';

    for ( card in cards ) {
      var c_data = StructNew();

      c_data.card_id = cards[card].getCard_Id();
      c_data.user_id = cards[card].getUser_Id();
      c_data.label = cards[card].getLabel();
      c_data.min_payment = cards[card].getMin_Payment();
      c_data.is_emergency = cards[card].getIs_Emergency();
      c_data.balance = cards[card].getBalance();
      c_data.interest_rate = cards[card].getInterest_Rate();

      if (!rows) {
        tmpQry = QueryNew( StructKeyList(c_data) );
        rows++;
      }

      QueryAddRow(tmpQry);
      for (key in StructKeyList(c_data)) {
        QuerySetCell(tmpQry,key,c_data[key],rows);
      }

      rows++;
    }

    var sql = '
      SELECT c.*
      FROM tmpQry c
      WHERE c.user_id = :uid
      AND c.balance > 0
    ';

    if ( Len( arguments.include_list ) ) {
      sql = sql & '
        AND c.card_id IN ( #ListQualify(arguments.include_list,"'")# )
      ';

    }

    if ( arguments.prioritize_emergency ) {

      sql = sql & '
        ORDER BY c.is_emergency DESC, c.balance ASC, c.interest_rate DESC
      ';

    } else {

      sql = sql & '
        ORDER BY c.balance ASC, c.interest_rate DESC
      ';

    }

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'varchar' 
      }
    };

    var queryOptions = {
      dbtype = 'query'
    };

    var result = queryExecute( sql, params, queryOptions );

    return result;

  }

  /* ***
  milestones()

  powers the Plan > Milestones tab
  *** */

  public any function milestones( string user_id ) {

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
    data: [100, 72, 59, 34, 18, 9, 0]               // each value in the array the balance_remaining for that month.
    }

    ]
    */

    var events = dbCalculateTempSchedule( arguments.user_id );
    var cards = session.tmp.cards;
    var milestones = ArrayNew(1);
    var thisEvent = 0;
    var thisCardId = 0;

    // cards is an object(struct)!
    for ( card in cards ) {

      var milestone = StructNew();

      milestone["name"] = JSStringFormat( cards[card].getLabel() );
      milestone["data"] = ArrayNew(1);

      thisCardId = cards[card].getCard_Id();

      // events is an array of structs!
      for ( event in events ) {

        thisEvent = event[thisCardId];

        if ( thisEvent.getCard_Id() == cards[card].getCard_Id() && thisEvent.getRemaining_Balance() > 0 ) {

          // append the remainig balance as a plottable point along the 
          ArrayAppend( milestone["data"], thisEvent.getRemaining_Balance() );

        }

      }

      // add new milestones for this card
      ArrayAppend( milestones, milestone );

    }

    return milestones;

  }

  /* takes a computed plan and a target date, and applies a 'pay_date' to each card in the plan (produces: event) */
  public any function dbCalculateTempEvent( struct plan, date calculated_for, no_cache=false ) {

    // TODO: later, look at the date and get a *portion* of the cached schedule from the db (if it exists)
    var card = 0;
    var this_plan = Duplicate( arguments.plan );

    //var the_first = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), 1 );

    // by default (which applies to preference=1 and preference=4 {monthly,its complicated}) is to set the pay date
    // to the *last* day of the specified month

    // TODO: examine the user's preferences, and calculate each card's pay_date.
    var the_last = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), DaysInMonth( arguments.calculated_for ) );

    for ( card in this_plan ) {

      this_plan[card].setPay_Date( the_last );

    }

    return this_plan;

  }

  /* takes a user and returns a series of events, based on their computed plan, to determine the month-by-month
  details of a payoff */
  public array function dbCalculateTempSchedule( string user_id ) {

    // 0. init
    var recalculate_plan = false;
    var new_payment_plan = 0;
    var each_card = 0;
    var this_card_next_interest = 0;
    var this_card_next_balance = 0;
    var budget = session.tmp.preferences.budget;

    // 1. init an events array
    var events = ArrayNew(1);

    // 2. start with today's date
    var next_date = Now();

    // 3. get the user's plan
    var next_plan = list( arguments.user_id );

    // 4. convert the plan to an event with calculateEvent()
    var next_event = dbCalculateTempEvent( next_plan, next_date );

    // 5. add the event to the events array
    ArrayAppend( events, next_event );

    // 6. calculate the total_remaining_balance by summing the remaining_balance of each card in the current_event.
    var total_remaining_balance = cardservice.dbCalculateTotalRemainingBalance( next_event );

    // 8. while total_remaining_balance is > 0, loop
    while ( total_remaining_balance > 0 ) {

      // 8a. Add a month to the working date.
      next_date = DateAdd( 'm', 1, next_date );

      // 8b. loop over every card in next_plan
      for ( each_card in next_plan ) {

        if ( next_plan[each_card].getRemaining_Balance() > 0 ) {

          // 8bi. calculate the interest for next month
          this_card_next_interest = planservice.dbCalculateMonthInterest( next_plan[each_card].getRemaining_Balance(), next_plan[each_card].getInterest_Rate(), next_date );

          // 8bii. add it to the card's reamining_balance.
          this_card_next_balance = next_plan[each_card].getRemaining_Balance() + this_card_next_interest;

          // 8biii. if any card's balance is set to 0 as a result of this, set a recalculate flag.
          if ( this_card_next_balance <= 0 ) {
            this_card_next_balance = 0;
            recalculate_plan = true;
            abort; // FIXME: Uhhh, this is *never* firing. IT MUST!!
          }

          // 8biv. set the new balance on the card in the plan
          next_plan[each_card].setBalance( this_card_next_balance );

        } else {

          next_plan[each_card].setBalance( 0 );

        } // if

      } // for

      // 8e. If the recreate flag was set, 
      // FIXME: You should only have to recalculate the plan *if* this iterate sets any balances to 0.
      if ( 1 ) {

        // 8ei. Reset the flag
        recalculate_plan = false;

        // TODO: this *really* needs to call dbCalculatedPlan() or at the very least handle emergency cards as well.
        try {
          new_payment_plan = dbCalculateTempPayments( next_plan, budget );
        } catch (any e) {
          if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
            new_payment_plan = dbCalculateTempPayments( next_plan, budget, false );
          } else {
            rethrow;
          }
        }

        next_plan = new_payment_plan;

      } // if (1)

      // 8c. Convert next_plan into a next_event, using the new date.
      next_event = dbCalculateTempEvent( next_plan, next_date );

      // 8d. Add the new event to the events array
      ArrayAppend( events, next_event );          

      // 8f. re-assign total_remaining_balance
      total_remaining_balance = cardservice.dbCalculateTotalRemainingBalance( next_event );

    }

    // 9. return the entire events array.
    return events;

  }

}