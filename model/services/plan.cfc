// model/services/plan
component accessors="true" {

  property cardservice;
  property preferenceservice;
  property knapsackservice;
  property eventservice;

  public any function init( beanFactory ) {

    variables.beanFactory = beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  public any function list( string user_id ) {

    var plan = dbCalculatePlan( arguments.user_id );

    return plan;

  }

  /* ***
  events()

  powers the "Plan > Schedule by Month" tab
  *** */

  public any function events( string user_id ) {

    var schedule = dbCalculateSchedule( arguments.user_id );

    return schedule;

  }

  public any function event( string user_id ) {

    var t_date = Now();
    var t_plan = list( arguments.user_id );
    var t_event = dbCalculateEvent( t_plan, t_date );

    return t_event;

  }












  /* **
  CRUD
  ** */

  public any function get( string id ) {

    // a plan doesn't have a single key - plans only come by way of a user_id
    return getByUser( arguments.id );

  }

  public any function delete( string id ) {

    return deleteByUser( arguments.id );

  }

  public any function getByUser( string user_id ) {

    var i=0;
    var sql = '
      SELECT c.card_id, c.user_id, c.card_label, c.min_payment, c.is_emergency, c.balance, c.interest_rate, p.is_hot, p.calculated_payment
      FROM "pCards" c
      INNER JOIN "pPlans" p ON
        c.card_id = p.card_id
      INNER JOIN (
          SELECT last_updated
          FROM "pPlans"
          WHERE user_id = :uid
          GROUP BY last_updated
          ORDER BY last_updated DESC
          LIMIT 1
      ) AS PP ON
          pp.last_updated = p.last_updated
      WHERE c.user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );
    var deck = {};

    for ( i=1; i lte result.recordcount; i++ ) {
      card = variables.beanFactory.getBean('cardBean');

      card.setCard_Id(result.card_id[i]);
      card.setUser_Id(result.user_id[i]);
      card.setLabel(result.card_label[i]);
      card.setMin_Payment(result.min_payment[i]);
      card.setIs_Emergency(result.is_emergency[i]);
      card.setBalance(result.balance[i]);
      card.setInterest_Rate(result.interest_rate[i]);
      card.setIs_Hot(result.is_hot[i]);
      card.setCalculated_Payment(result.calculated_payment[i]);

      deck[card.getCard_id()] = card;
    }

    return deck;
  }

  public any function save( struct cards ) {

    var i=0;
    var sql=0;
    var result=0;
    var params={};

    sql = '
      INSERT INTO "pPlans" (
        card_id,
        is_hot,
        calculated_payment,
        user_id
      ) VALUES
    ';

    for ( card in arguments.cards ) {
      sql = sql & '(
        #arguments.cards[card].getCard_Id()#,
        #arguments.cards[card].getIs_Hot()#,
        #arguments.cards[card].getCalculated_Payment()#,
        #arguments.cards[card].getUser_Id()#
      )';

      sql = sql & ',';
    }

    sql = Left( sql, Len(sql)-1 ); // trim trailing comma off
    sql = sql & ';'; // add a semi-colon to the end

    result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;
  }

  public any function deleteByUser( string user_id ) {

    var sql = '
      DELETE FROM "pPlans"
      WHERE user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;
  }

  /* **
  BIZLOG
  ** */ 

  public any function dbCalculatePlan( string user_id, no_cache=false ) {

    var payment_plan = 0;
    var budget = 0;
    var deck = 0;
    var e_card = 0;

    // if cached and cache not expired
    payment_plan = get( arguments.user_id );

    // if cache expired OR non-existent...
    if ( StructIsEmpty( payment_plan ) || arguments.no_cache ) {

      // 1. get the user's budget
      budget = preferenceservice.get( arguments.user_id ).getBudget();

      // 2. Get the user's list of cards
      deck = cardservice.list( arguments.user_id );

      // 3. run calculatePayments(), passing in deck and budget
      try {
        payment_plan = dbCalculatePayments( deck, budget );
      } catch (any e) {
        if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
          // make a second attempt, but not adding interest to the minimum payment.
          payment_plan = dbCalculatePayments( deck, budget, false );
        } else {
          // TODO: make a third attempt that simply pays only certain cards, until the budget is used up.
          rethrow;
        }
      }

      // 4. run evaluateEmergencyCard(), passing in generated plan and emergency card_id
      e_card = cardservice.getEmergencyCardByUser( arguments.user_id );

      if ( e_card.getCard_Id() GT 0 ) {
        payment_plan = dbEvaluateEmergencyCard( payment_plan, e_card.getCard_Id() );
      }

      // TODO: Consider a last minute post analysis on ultra low budgets / ultra high debt loads, where the
      // budget cannot adequately handle *a single minimum payment*

      // 5. Cache the newly generated plan
      if ( !arguments.no_cache )
        save( payment_plan );

    }

    // 6. Return the plan
    return payment_plan;

  }

  public any function dbCalculatePayments( struct cards, numeric available_budget, boolean use_interest=true, emergency_priority=false ) {

    var i = 0;
    var calc_payment = 0;
    var total_payments = 0;
    var user_id = 0;
    var hot_card_calculated_payment = 0;
    var smaller_budget = 0;
    var _tmpCard = 0;
    var this_interest_rate = 0;
    var each_card = 0;
    var thirty_day_rule = false;
    var id_list = '';

    // you sent me an empty list of cards
    if ( StructIsEmpty( arguments.cards ) )
      return arguments.cards;

    var user_id = arguments.cards[ListFirst( StructKeyList( arguments.cards ) )].getUser_Id();

    // make a copy of the incoming cards...work with this var locally.
    var this_deck = Duplicate( arguments.cards );

    for ( each_card in this_deck ) {

      // reset all the calculated payments
      this_deck[each_card].setCalculated_Payment( 0 );
      this_deck[each_card].setIs_Hot( 0 );

    }

    id_list = cardservice.dbGetNonZeroCardIDs( this_deck );

    // WARNING: UNKNOWN REASON
    // if the balance is zero across the user's deck
    if ( id_list == '' ) {
      return this_deck;
    }

    // Build a query that sorts these cards so that the hot card is row 1
    var cardsQry = cardservice.qryGetNonZeroCardsByUser( user_id, id_list, arguments.emergency_priority );
    var hot_card_id = cardsQry.card_id[1];

    // firm up the hot card
    this_deck[hot_card_id].setIs_Hot(1);

    // can the user's budget even withstand this debt load? (aka preCalculation() )
    var totalMinPayments = cardservice.dbCalculateTotalMinPayments( this_deck, true ); // REMEMBER : a min payment only counts if there's a BALANCE.

    // it can
    if ( arguments.available_budget >= totalMinPayments ) {

      // 2. Loop over the cards (starting after the hot card), calculating the payment for each card that is not the hot card.
      for ( i=2; i lte cardsQry.recordcount; i++ ) {

        if ( application.AllowAvalanche ) {

          if ( cardsQry.interest_rate[i] > 0 && arguments.use_interest ) {

            this_interest_rate = cardsQry.interest_rate[i];

          } else {

            this_interest_rate = 0.0;
          }

        } else {

          this_interest_rate = 0.0;

        }

        calc_payment = dbCalculatePayment( this_deck[cardsQry.card_id[i]].getBalance(), this_deck[cardsQry.card_id[i]].getMin_Payment(), this_interest_rate );

        this_deck[cardsQry.card_id[i]].setCalculated_Payment( calc_payment );

        // 3. add up all the calculated payments...
        total_payments += calc_payment;

      }

      // 3. ...subtract from budget
      hot_card_calculated_payment = Evaluate( arguments.available_budget - total_payments );

      if ( hot_card_calculated_payment <= 0 ) {

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
          Throw( type="Custom", errorCode="ERR_BUDGET_OVERRUN", message="Budget Overrun", detail="While calculating multiple hot cards, the available budget was drained before all cards were accounted for." );
        }

        // 5c. Temporarily remove the hot card from the deck
        _tmpCard = Duplicate( this_deck[hot_card_id] );
        StructDelete( this_deck, hot_card_id, true );

        // 5d. Recurse into calculatePayments(), using the smaller deck and reduced budget
        try {
          this_deck = dbCalculatePayments( this_deck, smaller_budget, true, arguments.emergency_priority );
        } catch (any e) {
          if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
            this_deck = dbCalculatePayments( this_deck, smaller_budget, false, arguments.emergency_priority );
          } else {
            rethrow;
          }
        }

        // 5e. Add the removed hot card back into the deck
        this_deck[_tmpCard.getCard_Id()] = _tmpCard;

      }

    // it cannot, so...
    } else {

      // *******
      // precalculation
      // *******

      // remove the hot_card_id from the list of candidates
      id_list = ListDeleteAt( id_list, ListFind( id_list, hot_card_id ) );

      // find the biggest offender in the deck THAT ARE NOT THE HOT CARD (1. highest min_payment 2. highest balance 3. highest interest)
      var offendingQry = cardservice.qryGetOffendingCardsByUser( user_id, id_list, arguments.emergency_priority );
      var o_id = offendingQry.card_id[1];

      if ( StructKeyExists( this_deck, o_id ) ) { // you shouldn't need this!

        // firm up the offending card by setting its calc'd payment to -1 (CANT_PAY)
        this_deck[o_id].setCalculated_Payment(-1);

        // 5c. Temporarily remove the hot card from the deck
        _tmpCard = Duplicate( this_deck[o_id] );

        StructDelete( this_deck, o_id, true );

        // now perform the *actual* calculation
        try {
          this_deck = dbCalculatePayments( this_deck, arguments.available_budget, true, arguments.emergency_priority );
        } catch (any e) {
          if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
            this_deck = dbCalculatePayments( this_deck, arguments.available_budget, false, arguments.emergency_priority );
          } else {
            rethrow;
          }
        }

        // 5e. Add the removed offending back into the deck
        this_deck[_tmpCard.getCard_Id()] = _tmpCard;

      }

    }

    // 6. return the deck with calculated payments
    return this_deck;

  }

  remote any function dbCalculatePayment( numeric balance, numeric minimum_payment, numeric interest_rate, date target_date=Now() ) {

    var payment = 0;

    // why?!?
    if ( arguments.balance == 0 )
      return 0;

    // if you've *just* charged to a card, they may list your min. payment as 0. Take it! Cycle this around as revolving
    // to the following month.
    if ( arguments.minimum_payment == 0 )
      return 0;

    // prerequiste - sometimes this happens: the balance is less than the minimum payment. That's good!
    // so just return the balance.
    if ( arguments.balance < arguments.minimum_payment ) {
      return arguments.balance;
    }

    if ( arguments.interest_rate > 0 ) {
    
      // 1. calculate the interest for 1 month
      var month_interest = dbCalculateMonthInterest( arguments.balance, arguments.interest_rate, arguments.target_date );

      // 2. add the month_interest to the minimum payment
      payment = Evaluate( month_interest + arguments.minimum_payment );

    } else {

      payment = arguments.minimum_payment;

    }

    // 3. if the payment is > the balance, the payment *is* the balance
    if ( payment > arguments.balance ) {
      payment = arguments.balance;
    } else {
      
      // set a min balance threshold allowed on a card, to prevent a single month from allowing a card to have a
      // balance of 11 cents. :P, something like a min. threshold of $10.00
      // eg. use case: calculated payment: 12.72, balance: 13.04
      if ( ( arguments.balance - payment ) < application.min_card_threshold ) {
        payment = arguments.balance;
      }

    }

    // protection
    if ( payment < 0 ) {
      Throw( type="Custom", errorCode="ERR_NEGATIVE_CALCULATE_PAYMENT", message="dbCalculatePayment negative value.", detail="dbCalculatePayment produced a negative value.", var={balance:arguments.balance,interest_rate:arguments.interest_rate,target_date:arguments.target_date});
    }

    return payment;

  }

  public numeric function dbCalculateMonthInterest( numeric b, numeric i, date m ) {

    // 1. divide the interest rate by 365 to get dpr
    var dpr = arguments.i / 365;

    // 2. multiply the dpr by the balance to get a daily charge
    var daily = dpr * arguments.b;

    // 3. multiply the daily charge by the # of the days in the month.
    var total = daily * DaysInMonth( Month( arguments.m ) );

    return total;
  }

  public any function dbEvaluateEmergencyCard( struct plan, numeric eid ) {

    var e_card = cardservice.get( arguments.eid );
    var uid = e_card.getUser_Id();
    var budget = preferenceservice.get( uid ).getBudget();
    var card = 0;
    var calc_e_payment = 0;
    var this_plan = Duplicate( arguments.plan );
    var new_payment_plan = 0;

    // 1. Does the emergency card have a zero balance? Exit if so.
    if ( e_card.getBalance() == 0 ) {
      return this_plan;
    }

    // 2. Loop over the deck
    for ( card in this_plan ) {

      // ..is this card a hot card?
      if ( this_plan[card].getIs_Hot() == 1 ) {

        // ...and is this hot card the same as the emergency card? Exit if so.
        if ( this_plan[card].getCard_Id() == e_card.getCard_Id() ) {
          return this_plan;
        }

      }

    }

    // 3. If you've made it this far (the emergency card has a balance and none of the existing
    // hot cards in the plan match the emergency card), calculate the emergency card's payment
    calc_e_payment = dbCalculatePayment( e_card.getBalance(), e_card.getMin_Payment(), e_card.getInterest_Rate() );

    // 4. If the calculated emergency card's payment > 25% (application.emergencyBalanceThreshold)
    if ( calc_e_payment / budget > application.emergency_balance_threshold ) {

      try {
        new_payment_plan = dbCalculatePayments( cards=this_plan, available_budget=budget, emergency_priority=true );
      } catch (any e) {
        if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
          new_payment_plan = dbCalculatePayments( cards=this_plan, available_budget=budget, use_interest=false, emergency_priority=true );
        } else {
          rethrow;
        }
      }

      return new_payment_plan;

    }

    // everything fell through, so just return the original plan
    return arguments.plan;

  }

  /* takes a computed plan and a target date, and applies a 'pay_date' to each card in the plan (produces: event) */
  public any function dbCalculateEvent( struct plan, date calculated_for, no_cache=false ) {

    // TODO: later, look at the date and get a *portion* of the cached schedule from the db (if it exists)
    var card = 0;
    var this_plan = Duplicate( arguments.plan );
    var user_id = this_plan[ListFirst(StructKeyList(this_plan))].getUser_Id();
    var num_columns = 1; // default, for preference = 0|1
    var the_date = ArrayNew(1); // this will always be populated in reverse order, so the_date[1] should *always* be the *last* pay period of the month.

    //var the_date[1] = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), 1 );
    //var the_date[2] = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), 15 );
    //var the_date[3] = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), DaysInMonth( arguments.calculated_for ) );

    //var the_start = the_date[1];
    //var the_fifteenth = the_date[2];
    //var the_end = the_date[3];

    // by default (which applies to preference=1 and preference=4 {monthly,its complicated}) is to set the pay date
    // to the *last* day of the specified month

    // 1 or 4
    the_date[1] = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), DaysInMonth( arguments.calculated_for ) );
    // now the_date.length = 2;

    if ( preferenceservice.get( user_id ).getPay_Frequency() == 2) { // twice a month

      num_columns = 2;

      the_date[2] = CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), 15 );

      // now the_date.length = 2;

    } else if ( preferenceservice.get( user_id ).getPay_Frequency() == 3 ) { // every two weeks

      // TODO: Allow users that specify "every two weeks" to set the "first pay period of the year" -- otherwise, the following calculation is just a guess.

      var result = eventservice.qGetPayPeriodsInMonthOfDate( arguments.calculated_for );

      num_columns = result.recordCount; // might be 2 or 3.

      // updates the_date[] array to be the actual pay period dates, irrespective of # of pay dates in a month.
      for ( var m=num_columns; m > 0; m-- ) { // walk backwards.

        the_date[m] = result.pay_date[m];

        // the_date.length 2 or 3, depending on month/year.

      }

    }

    /* BEGIN */
    // adapted from: https://stackoverflow.com/questions/3009146/splitting-values-into-groups-evenly
    var cpStruct = StructNew();

    for ( var card in this_plan ) {

      // set the calculated_for_* setters
      this_plan[card].setCalculated_For_Month( Month(arguments.calculated_for) );
      this_plan[card].setCalculated_For_Year( Year(arguments.calculated_for) );

      // set aside a copy of all the cards that have a calculated payment (included ignored)
      if ( this_plan[card].getCalculated_Payment() > 0 )

        StructInsert( cpStruct, card, this_plan[card].getCalculated_Payment() );

    }

    var totalcp = cardservice.dbCalculateTotalCalculatedPayments( this_plan );
    var pay_frequency_capacity = totalcp / num_columns;
    var pay_days = ArrayNew(1);

    // if there are more/equal payments than there are days/month to pay (eg 2 debts, 2 times a month; 4 debts, 1 time a month)
    if ( StructCount(cpStruct) >= num_columns ) {

      for (var a=1; a <= num_columns; a++) {

        // if its not the last column, and the # of items to split is greater than the num of colums (to catch the edge condition of 1 debt on a multi-month payment schedule)
        // FIXME: Still broken - cpStruct (when down to 1 debt) is splitting the payment across the num_colums...but only 1 payment per month is displaying
        if ( a < num_columns && !StructIsEmpty(cpStruct) ) {

          var splits = knapsackservice.knapsack( cpStruct, pay_frequency_capacity );

          // if it can't split anything
          if ( ArrayLen(splits) == 0 ) {

            // put everything into the first index of the array
            ArrayAppend( pay_days, StructNew() );

            // and clear it out
            cpStruct = StructNew();

          } else {

            // TODO: Any list should suffice, but will we ever want to prefer one? The longest? The shortest?
            var chosen = splits[1];

            var thisPay = StructNew();
            var remains = StructNew();

            for ( var key in cpStruct ) {
              if ( ListFind(chosen, key, ',') ) {
                StructInsert( thisPay, key, cpStruct[key] );
              } else {
                StructInsert( remains, key, cpStruct[key] );
              }
            }

            // store what you kept
            ArrayAppend( pay_days, thisPay );

            // the remains are what's left, so pare cpStruct down
            cpStruct = remains;

          }

        } else {

          // we don't knapsack the the final entry in the list - we just accept it and carry on.
          ArrayAppend( pay_days, cpStruct );

        }

      }

    // if there are less payments than there are days/months to pay (eg. 1 debt, 2 times a momnth)
    } else {

      ArrayAppend( pay_days, cpStruct );
      
      // FIXME: Can't split until you allow 1 card to be paid multiple times per month (negated by lines #901 below)
      /*
      var key = StructKeyList(cpStruct);
      var split_pay = cpStruct[key] / num_columns;

      for (var a=1; a <= num_columns; a++) {
        var thisStruct = StructNew();
        StructInsert( thisStruct, key, split_pay );

        ArrayAppend( pay_days, thisStruct);
      }
      */

    }

    var pay_dates = ArrayReverse(the_date);

    // looping over the pay_days array assures us we'll only use what we *need* from the_dates[], so if we erroneously
    // assigned a 3rd pay date -- we won't even iterate that far.
    for ( var p=1; p <= ArrayLen(pay_days); p++ ) {

      for ( var p_card in pay_days[p] ) {

        if ( pay_days[p][p_card] > 0 ) {

          this_plan[p_card].setPay_Date( pay_dates[p] );

        }

      }

    }

    // set the ignored card to the last pay date
    for (var i_card in this_plan) {
      if (this_plan[i_card].getCalculated_Payment() == -1) {
        this_plan[i_card].setPay_Date( pay_dates[ArrayLen(pay_dates)] );
      }
    }


    return this_plan;

  }

  /* takes a user and returns a series of events, based on their computed plan, to determine the month-by-month
  details of a payoff */
  public array function dbCalculateSchedule( string user_id, no_cache=false ) {

    // 0. init
    var recalculate_plan = false;
    var new_payment_plan = 0;
    var each_card = 0;
    var this_card_next_interest = 0;
    var this_card_next_balance = 0;

    // if cached and cache not expired
    var events = eventservice.get( arguments.user_id );

    if ( ArrayIsEmpty(events) || arguments.no_cache ) {

      // 0. get the user's budget
      var budget = preferenceservice.get( arguments.user_id ).getBudget();

      // 1. init an events array
      events = ArrayNew(1);

      // 2. start with today's date
      var next_date = Now();

      // 3. get the user's plan
      var next_plan = list( arguments.user_id );

      // 4. convert the plan to an event with calculateEvent()
      var next_event = dbCalculateEvent( next_plan, next_date );

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

          // for resetting the plan
          // 1. calculated_payment -1 becomes 0 : (deferred)
          // 2. (balance > 0 && min_payment == 0) becomes min_payment(nonzero) : (30 day rule)
          // then
          // if (remaining_balance > 0)
          //   balance = remaining_balance + next month's interest
          // else
          //   balance = 0; 

          // reset any ignored/deferred cards
          if ( next_plan[each_card].getCalculated_Payment() < 0 )
            next_plan[each_card].setCalculated_Payment(0);

          // trigger the 30 day rule on a card with a balance but no min. payment
            // just calculate a min. payment, leave the balance alone
          if ( next_plan[each_card].getBalance() > 0 && next_plan[each_card].getMin_Payment() == 0 )
            next_plan[each_card].calculateMin_Payment();

          if ( next_plan[each_card].getRemaining_Balance() > 0 ) {

            // 8bi. calculate the interest for next month
            this_card_next_interest = dbCalculateMonthInterest( next_plan[each_card].getRemaining_Balance(), next_plan[each_card].getInterest_Rate(), next_date );

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

          }

        }

        // 8e. If the recreate flag was set, 
        // FIXME: You should only have to recalculate the plan *if* this iterate sets any balances to 0.
        if ( 1 ) {

          // 8ei. Reset the flag
          recalculate_plan = false;

          // TODO: this *really* needs to call dbCalculatePlan() or at the very least handle emergency cards as well.
          try {
            new_payment_plan = dbCalculatePayments( next_plan, budget );
          } catch (any e) {
            if ( e.errorCode == "ERR_BUDGET_OVERRUN" ) {
              new_payment_plan = dbCalculatePayments( next_plan, budget, false );
            } else {
              rethrow;
            }
          }

          next_plan = new_payment_plan;

        }

        // 8c. Convert next_plan into a next_event, using the new date.
        next_event = dbCalculateEvent( next_plan, next_date );

        // 8d. Add the new event to the events array
        ArrayAppend( events, next_event );

        // 8f. re-assign total_remaining_balance
        total_remaining_balance = cardservice.dbCalculateTotalRemainingBalance( next_event );

      }

      // save the plan
      if (!arguments.no_cache)
        eventservice.save( events );

    }

    // 9. return the entire events array.
    return events;

  }

}