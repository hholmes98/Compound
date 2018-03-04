//plan.cfc
component accessors="true" {

  property cardservice;
  property preferenceservice;

  public any function init( beanFactory ) {

    variables.beanFactory = beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  public any function list( string user_id ) {

    //var deck = get( arguments.user_id );

    var plan = dbCalculatePlan( arguments.user_id );

    return plan;

  }

  /* ***
  events()

  powers the "Plan > Schedule by Month" tab
  *** */

  public any function events( string user_id ) {

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

    var events = ArrayNew(1);
    var schedule = dbCalculateSchedule( arguments.user_id );

    for ( event in schedule ) {
      
      for ( item in event ) {

        var sItem = StructNew();

        if ( event[item].getCalculated_Payment() > 0 ) {

          StructInsert( sItem, 'id', event[item].getCard_Id() );
          StructInsert( sItem, 'title', 'Pay $' & DecimalFormat( event[item].getCalculated_Payment() ) & ' to ' & JSStringFormat( event[item].getLabel() ) );
          StructInsert( sItem, 'start', DateFormat( event[item].getPay_Date(), "ddd mmm dd yyyy" ) & ' 00:00:00 GMT-0600' );

          ArrayAppend( events, sItem );

        }

      }
    }

    return events;

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
        data: [100, 72, 59, 34, 18, 9, 0]       // each value in the array the balance_remaining for that month.
      }

    ]
      */

      var events = dbCalculateSchedule( arguments.user_id );
      var cards = list( arguments.user_id );
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
        for ( var event in events ) {

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



  /*

  *****************
  PRIVATE FUNCTIONS
  *****************

  */

  private any function getHotCard( struct cards ) {

    var _searchCards = duplicate( arguments.cards );
    var card = 0;
    var top_cards = structNew();
    var interest_array = arrayNew(1);
    var balance_array = arrayNew(1);
    var top_interest_rate = 0;


    // new logic to determine hot card:
    // IF
    //   the is_emergency card set (and have a non-zero balance?) THEN SET 
    // ELSE
    //   get the first non-zero balance card with the highest interest rate and the lowest balance.

    for ( card in _searchCards ) {

      /* Determine "hot" card */
      // TODO: add in individual card priorities
      if ( IsObject(_searchcards[card]) && _searchcards[card].getIs_Emergency() eq 1 && _searchcards[card].getBalance() > 0 ) {
        _searchcards[card].setIs_Hot(1);
        return _searchcards[card];
      }

    }

    // make an array of interests, sorted by highest first, on only cards with a non-zero balance
    for ( card in _searchCards ) {

      if ( IsObject(_searchCards[card]) && _searchCards[card].getBalance() > 0 ) {

        arrayAppend( interest_array, _searchcards[card].getInterest_Rate() );

      }
      
    }
    
    arraySort( interest_array, "numeric", "desc" );

    //eg [.30, .28, .27, .25, .25]

    // make an array of non-zero balances, sorted by lowest first
    for ( card in _searchcards ) {

      if ( IsObject(_searchCards[card]) && _searchCards[card].getBalance() > 0 ) {

        arrayAppend( balance_array, _searchcards[card].getBalance() );

      }
      
    }
    
    arraySort( balance_array, "numeric", "asc" );

    //eg [ 0, 0, 0, 12, 24, 180, 620, 772, 1149, 2250 ]

    // find the first non-zero balance card with the highest interest rate and the lowest balance
    for ( card in _searchCards ) {

      if ( IsObject(_searchCards[card]) && _searchCards[card].getBalance() > 0 ) {

        if ( _searchCards[card].getInterest_Rate() == interest_array[1] ) {

          if ( _searchCards[card].getBalance() == balance_array[1] ) {

            _searchCards[card].setIs_Hot(1);
            return _searchCards[card];
          }

        }
      }

    }

    // I messed up somewhere, so return the first non-zero
    for ( card in _searchCards ) {

      if ( IsObject(_searchCards[card]) && _searchCards[card].getBalance() > 0) {

        _searchcards[card].setIs_Hot(1);
        return _searchCards[card];

      }

    }

    // a big mess up!
    return cardservice.get(0);

  }

  /* 

  *********************
  calculatePayments()
  *********************

  takes the user's (passed-in) list of cards, examines the user's budget, and calculates a payment for each card that leverages
  the entire budget, while maximizing the biggest payment to a "hot" card: a card that is:
  
  a. either the emergency card, or
  b. the card with the highest interest rate and the lowest balance.

  input: struct of cards, each with a balance, interst_rate, and min_payment
  output: struct of cards, each with a balance, interst_rate, min_payment, and *calculated_payment*

  */
  private any function calculatePayments( struct cards, numeric available_budget ) {

    /* 

      Rules for setting up/distributing payment plan:
      
      A. Determine the "hot" card.
      B. Take the monthly budget.
      C. Subtrack the minimum payment for the cards that are not the "hot" card.
      D. Use the remaining budget for the "hot" card.

      Rules for determining the "hot" card (card that MUST be paid off first)

      1. Loop over all cards, looking at priority, lowest is most important.
      - 1a. Alternately, if priority can't be determined/isn't set by user, look at emergency card.
      2. For the given list of cards in the highest priority, are all balances 0?
      - 2a. If yes, go to next priority, return to 1. (and if only emergency, go to all remaining cards)
      - 2b. If no, stay with the selected list of cards
      3. For the selected cards that still have a balance, re-order by interest rate (highest first)
      4. For the selected cards, look at which balance is closest to being paid off. this is the "hot" card.
      5. Add up all the minimum payments.
      6. Subtrack the minimum payment of the "hot" card. this is the "available_min_spread" alotted for all remaining minimum balances.
      7. Take "available_min_spread", subtract it from "preferences.budget", this is now the "hot" card "calculated_payment"

    */

    // if there are no more cards to work with
    if ( structIsEmpty(cards) )
      return arguments.cards;

    // if there is no more budget left to work with
    if ( arguments.available_budget <= 0)
      return arguments.cards;

    var _cards = duplicate( arguments.cards );
    var hot_card = getHotCard( _cards );

    if ( hot_card.getCard_Id() lte 0 ) {

      // allegedly no cards with a balance remain
      return hot_card;
    } else {
      _cards[hot_card.getCard_Id()].setIs_Hot(1);
    }


    //NOTE: hot_card should be valid/should have a balance by this point!
    
    //5. Add up all the minimum payments.
    var min_payment_total = 0;
    
    for (card in _cards) {
      min_payment_total += _cards[card].getMin_Payment();
    }
    

    //6. Subtrack the minimum payment of the "hot" card. this is the "available_min_spread" alotted for all remaining minimum balances.
    var available_min_spread = min_payment_total - hot_card.getMin_Payment();

    //7. Take "available_min_spread", subtract it from "preferences.budget", this is now the "hot" card "calculated_payment"
    var hot_card_calculated_payment = arguments.available_budget - available_min_spread;
    
    var total_paid = 0; 

//    writeDump(hot_card);abort;

    for ( card in _cards ) {
      
      if ( _cards[card].getCard_Id() != hot_card.getCard_Id() ) {

        if ( _cards[card].getBalance() > 0 ) {

          var min = replace( _cards[card].getMin_Payment(),",","","ALL" );
          var bal = replace( _cards[card].getBalance(),",","","ALL" );

          if ( min > bal ) {
          
            //StructInsert( _cards[card], "calculated_payment", bal, true );
            _cards[card].setCalculated_Payment( bal );
            total_paid += bal;
          
          } else {

            //StructInsert( _cards[card], "calculated_payment", min, true );
            _cards[card].setCalculated_Payment( min );
            total_paid += min;
          }
        
        } else {

          //StructInsert( _cards[card], "calculated_payment", 0, true );
          _cards[card].setCalculated_Payment( 0 );

        }

      }

//      writeoutput(total_paid & "<br>");
    
    }

    var hot_paid = arguments.available_budget - total_paid;

//    writeoutput("precalc hot card payment: " & hot_card_calculated_payment & "<br>");
//    writeoutput("postcalcl hot card payment: " & hot_paid );abort;

    //StructInsert( _cards[hot_card.getCard_Id()], "calculated_payment", hot_paid, true ); //FIXME: WARNING, SHOULDN'T NEED TRUE HERE, BUT DOES. SOMETHING'S WRONG
    _cards[hot_card.getCard_Id()].setCalculated_Payment( hot_paid );

//    writeDump(_cards);abort;

    /****** 
    postCalculation
    ******/

    // is the hot card's calculated payment greater than its balance?
    if ( _cards[hot_card.getCard_Id()].getCalculated_Payment() > _cards[hot_card.getCard_Id()].getBalance() ) {

      // set the hot card's calculated payment = to its balance 
      _cards[hot_card.getCard_Id()].setCalculated_Payment( _cards[hot_card.getCard_Id()].getBalance() );

      // remove (newly updated) calculated payment from the available budget
      var reduced_budget = arguments.available_budget - _cards[hot_card.getCard_Id()].getCalculated_Payment();

      // temp. remove hot card from entire set of cards (save a copy)
      var _tmpCard = duplicate( _cards[hot_card.getCard_Id()] );
      StructDelete( _cards, hot_card.getCard_Id() );

      // recurse, calling calculatePayments() all over but with a smaller card set and a smaller budget
      var _updatedCards = calculatePayments( _cards, reduced_budget );

      // add the removed card back into the deck.
      _updatedCards[_tmpCard.getCard_Id()] = _tmpCard;

      // this is now the set of cards we've been working with all along.
      _cards = _updatedCards;

    }

    return _cards;

  }







  /* **
  CRUD
  ** */

  public any function get( string id ) {

    // a plan doesn't have a single key - plans only come by way of a user_id
    return getByUser( arguments.id );

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

    var result = queryExecute( sql, params, variables.defaultOptions );
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
    sql = sql & ';';      // add a semi-colon to the end

    //trace( category="SQL", type="Information", text=sql );  

    result = queryExecute( sql, params, variables.defaultOptions );

    return 0;
  }

  public any function delete( string user_id ) {

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

    var payment_plan  = 0;    
    var budget      = 0;
    var deck      = 0;
    var e_card      = 0;

    // if cached and cache not expired
    payment_plan = get( arguments.user_id );

    // if cache expired OR non-existent...
    if ( StructIsEmpty( payment_plan ) OR arguments.no_cache ) {

      // 1. get the user's budget
      budget = preferenceservice.getBudget( arguments.user_id );

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

      // 5. Cache the newly generated plan
      if ( !arguments.no_cache ) {
        save( payment_plan );
      }

    }

    // 6. Return the plan
    return payment_plan;
  }

  public any function dbCalculatePayments( struct cards, numeric available_budget, boolean use_interest=true, emergency_priority=false ) {

    var i               = 0;
    var calc_payment        = 0;
    var total_payments        = 0;
    var user_id           = 0;
    var hot_card_calculated_payment = 0;
    var smaller_budget        = 0;
    var _tmpCard          = 0;
    var this_interest_rate      = 0;
    var each_card         = 0;

    // you sent me an empty list of cards
    if ( StructIsEmpty( arguments.cards ) )
      return arguments.cards;

    var user_id     = arguments.cards[ListFirst( StructKeyList( arguments.cards ) )].getUser_Id();

    // make a copy of the incoming cards...work with this var locally.
    var this_deck     = duplicate( arguments.cards );

    // reset all the calculated payments
    for ( each_card in this_deck ) {
      this_deck[each_card].setCalculated_Payment( 0 );
      this_deck[each_card].setIs_Hot( 0 );
    }

    // Get the list of card IDs in this deck (with a balance)
    var id_list     = cardservice.dbGetNonZeroCardIDs( this_deck );

    // WARNING: UNKNOWN REASON
    // if the balance is zero across the user's deck
    if (id_list == '') {
      return this_deck;
    }

    // I have no more budget to work with
    // TODO: Is this where we'll support the ability to stop calculating, if the budget's been used up?
    if ( arguments.available_budget <= 0 )
      return this_deck;

    // Build a query that sorts these cards so that the hot card is row 1
    var cardsQry    = cardservice.qryGetNonZeroCardsByUser( user_id, id_list, arguments.emergency_priority );
    var hot_card_id   = cardsQry.card_id[1];

    // firm up the hot card
    this_deck[hot_card_id].setIs_Hot(1);

    // 2. Loop over the cards (starting after the hot card), calculating the payment for each card that is not the hot card.
    for ( i=2; i lte cardsQry.recordcount; i++ ) {

      if ( application.consider_interest_when_calculating_payments ) {

        if ( cardsQry.interest_rate[i] > 0 && arguments.use_interest ) {

          this_interest_rate = cardsQry.interest_rate[i];

        } else {

          this_interest_rate = 0.0;
        }

      } else {

        this_interest_rate = 0.0;

      }

      calc_payment = dbCalculatePayment( cardsQry.balance[i], cardsQry.min_payment[i], this_interest_rate );

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
          //writeDump( qSmallerDeck );
          //writeOutput('SUBCAUGHT/FIXED');         
          this_deck = dbCalculatePayments( this_deck, smaller_budget, false, arguments.emergency_priority );
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

    var e_card        = cardservice.get( arguments.eid );
    var uid         = e_card.getUser_Id();
    var budget        = preferenceservice.getBudget( uid );
    var card        = 0;
    var calc_e_payment    = 0;
    var this_plan     = duplicate( arguments.plan );
    var new_payment_plan  = 0;

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
    var card    = 0;
    var this_plan   = duplicate( arguments.plan );
    
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
  public array function dbCalculateSchedule( string user_id ) {

    // 0. init
    var recalculate_plan    = false;
    var new_payment_plan    = 0;
    var each_card       = 0;
    var this_card_next_interest = 0;
    var this_card_next_balance  = 0;
    var budget          = preferenceservice.getBudget( arguments.user_id );

    // 1. init an events array
    var events          = ArrayNew(1);    

    // 2. start with today's date
    var next_date         = Now();

    // 3. get the user's plan
    var next_plan         = list( arguments.user_id );

    // 4. convert the plan to an event with calculateEvent()
    var next_event        = dbCalculateEvent( next_plan, next_date );

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

          // 8bv. if the card has a balance but no minimum payment (eg. credit that was added to the card *this month*), calc one and set it.
          if ( next_plan[each_card].getBalance() > 0 && next_plan[each_card].getMin_Payment() == 0 ) {
              // FIXME: This isn't working
              next_plan[each_card].setMin_Payment(''); // this is a trick in the card bean that forces a calculated minpayment.
          }

        } else {

          next_plan[each_card].setBalance( 0 );

        }

      }

      // 8e. If the recreate flag was set, 
      // FIXME: You should only have to recalculate the plan *if* this iterate sets any balances to 0.
      if ( 1 ) {

        // 8ei. Reset the flag
        recalculate_plan = false;

        // TODO: this *really* needs to call dbCalculatedPlan() or at the very least handle emergency cards as well.
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
    
    // 9. return the entire events array.
    return events;

  }

}