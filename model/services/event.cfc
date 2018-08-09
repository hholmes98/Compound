//model/services/event
component accessors=true {

  public any function init( beanFactory, planService, cardService, preferenceService, knapsackService, pay_periodService, userService, card_paidService ) {

    variables.beanFactory = arguments.beanFactory;
    variables.planService = arguments.planService;
    variables.cardService = arguments.cardService;
    variables.preferenceService = arguments.preferenceService;
    variables.knapsackService = arguments.knapsackService;
    variables.pay_periodService = arguments.pay_periodService;
    variables.userService = arguments.userService;
    variables.card_paidService = arguments.card_paidService;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  /******
    CRUD
  ******/

  /*
  list() = get all events for a user (aka a schedule)
  */
  public any function list( string user_id ) {

    var result = export( arguments.user_id );
    var events = []; // events is an array because they go in a specific order.

    cfloop( query=result, group="calculated_for" ) {

      var event = variables.beanFactory.getBean('eventBean');

      event.setEvent_Id( result.event_id );
      event.setPlan_Id( result.plan_id );

      event.setCalculated_For_Month( result.calculated_for_month );
      event.setCalculated_For_Year( result.calculated_for_year );

      var plan = planService.get( result.plan_id );
      event.setPlan( plan );

      cfloop() {

        var card = variables.beanFactory.getBean('event_CardBean');

        // card
        card.setCard_Id(result.card_id);
        card.setCredit_Limit(result.credit_limit);
        card.setDue_On_Day(result.due_on_day);
        card.setUser_Id(result.user_id);
        card.setLabel(result.card_label);
        card.setMin_Payment(result.min_payment);
        card.setIs_Emergency(result.is_emergency);
        card.setBalance(result.balance);
        card.setInterest_Rate(result.interest_rate);
        card.setZero_APR_End_Date(result.zero_apr_end_date);
        card.setCode(result.code);
        card.setPriority(result.priority);

        // plan_card
        card.setPlan_Id(result.plan_id);
        card.setIs_Hot(result.is_hot);
        card.setCalculated_Payment(result.calculated_payment);

        // event_card
        card.setEvent_Id( result.event_id );
        card.setPay_Date( result.pay_date );

        event.addCard( card );

        if ( Len(result.actual_payment) AND Len(result.actually_paid_on) ) {

          var card_payment = variables.beanFactory.getBean('card_paidBean');

          card_payment.setUser_Id( card.getUser_Id() );
          card_payment.setCard_Id( card.getCard_Id() );
          card_payment.setActual_Payment( result.actual_payment );
          card_payment.setActually_Paid_On( result.actually_paid_on );
          card_payment.setPayment_For_Month( event.getCalculated_For_Month() );
          card_payment.setPayment_For_Year( event.getCalculated_For_Year() );

          event.addPaidCard( card_payment );

        }

      }

      ArrayAppend( events, event );

    }

    return events;

  }

  public query function export( string user_id ) {

    /* this is expensive, keep in mind this will have to be rewritten */
    var sql = '
      SELECT 
        e.event_id, e.plan_id, e.calculated_for_month, e.calculated_for_year, 
        CONCAT(e.calculated_for_year, ''-'', e.calculated_for_month) AS calculated_for, 
        ec.balance, ec.is_hot, ec.calculated_payment, ec.pay_date,
        c.card_id, c.credit_limit, c.due_on_day, c.user_id, c.card_label, c.min_payment, 
        c.is_emergency, c.interest_rate, c.zero_apr_end_date, c.code, c.priority, ucp.actual_payment, ucp.actually_paid_on
      FROM 
        "pEvents" e
      INNER JOIN 
        "pEventCards" ec ON e.event_id = ec.event_id
      INNER JOIN 
        "pCards" c ON ec.card_id = c.card_id
      LEFT JOIN "pUserCardsPaid" ucp ON (
          e.calculated_for_month = ucp.payment_for_month
        AND
          e.calculated_for_year = ucp.payment_for_year
        AND
        c.card_id = ucp.card_id
      )
      WHERE 
        c.user_id = :uid
      ORDER BY 
        e.calculated_for_year, e.calculated_for_month, ec.pay_date;
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return result;

  }

  /*
  get() = get a specific event by its primary key (which is the plan's plan_id)
  */
  public any function get( string id ) {

    var sql = '
      SELECT 
        e.event_id, e.plan_id, e.calculated_for_month, e.calculated_for_year, 
        CONCAT(e.calculated_for_year, ''-'', e.calculated_for_month) AS calculated_for, 
        ec.balance, ec.is_hot, ec.calculated_payment, ec.pay_date,
        c.card_id, c.credit_limit, c.due_on_day, c.user_id, c.card_label, c.min_payment, 
        c.is_emergency, c.interest_rate, c.zero_apr_end_date, c.code, c.priority, ucp.actual_payment, ucp.actually_paid_on
      FROM 
        "pEvents" e
      INNER JOIN 
        "pEventCards" ec ON e.event_id = ec.event_id
      INNER JOIN 
        "pCards" c ON ec.card_id = c.card_id
      LEFT JOIN "pUserCardsPaid" ucp ON (
          e.calculated_for_month = ucp.payment_for_month
        AND
          e.calculated_for_year = ucp.payment_for_year
        AND
          c.card_id = ucp.card_id
      )
      WHERE 
        e.event_id = :eid
      ORDER BY 
        ec.pay_date;
    ';

    var params = {
      eid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    cfloop( query=result, group="event_id" ) {

      var event = variables.beanFactory.getBean('eventBean');

      event.setEvent_Id( result.event_id );
      event.setPlan_Id( result.plan_id );

      event.setCalculated_For_Month( result.calculated_for_month );
      event.setCalculated_For_Year( result.calculated_for_year );

      var plan = planService.get( result.plan_id );
      event.setPlan( plan );

      cfloop() {

        var card = variables.beanFactory.getBean('event_CardBean');

        // card
        card.setCard_Id(result.card_id);
        card.setCredit_Limit(result.credit_limit);
        card.setDue_On_Day(result.due_on_day);
        card.setUser_Id(result.user_id);
        card.setLabel(result.card_label);
        card.setMin_Payment(result.min_payment);
        card.setIs_Emergency(result.is_emergency);
        card.setBalance(result.balance);
        card.setInterest_Rate(result.interest_rate);
        card.setZero_APR_End_Date(result.zero_apr_end_date);

        // plan_card
        card.setPlan_Id(result.plan_id);
        card.setIs_Hot(result.is_hot);
        card.setCalculated_Payment(result.calculated_payment);

        // event_card
        card.setEvent_Id( result.event_id );
        card.setPay_Date( result.pay_date );

        event.addCard( card );

        if ( Len(result.actual_payment) AND Len(result.actually_paid_on) ) {

          var card_payment = variables.beanFactory.getBean('card_paidBean');

          card_payment.setUser_Id( card.getUser_Id() );
          card_payment.setCard_Id( card.getCard_Id() );
          card_payment.setActual_Payment( result.actual_payment );
          card_payment.setActually_Paid_On( result.actually_paid_on );
          card_payment.setPayment_For_Month( event.getCalculated_For_Month() );
          card_payment.setPayment_For_Year( event.getCalculated_For_Year() );

          event.addPaidCard( card_payment );

        }

      }

    }

    return event;

  }

  public any function getByMonthAndYear( string user_id, number month, number year ) {

    var sql = '
      SELECT 
        e.event_id, e.plan_id, e.calculated_for_month, e.calculated_for_year, 
        CONCAT(e.calculated_for_year, ''-'', e.calculated_for_month) AS calculated_for, 
        ec.balance, ec.is_hot, ec.calculated_payment, ec.pay_date,
        c.card_id, c.credit_limit, c.due_on_day, c.user_id, c.card_label, c.min_payment, 
        c.is_emergency, c.interest_rate, c.zero_apr_end_date, c.code, c.priority, ucp.actual_payment, ucp.actually_paid_on
      FROM 
        "pEvents" e
      INNER JOIN 
        "pEventCards" ec ON e.event_id = ec.event_id
      INNER JOIN 
        "pCards" c ON ec.card_id = c.card_id
      LEFT JOIN "pUserCardsPaid" ucp ON (
          e.calculated_for_month = ucp.payment_for_month
        AND
          e.calculated_for_year = ucp.payment_for_year
        AND
          c.card_id = ucp.card_id
      )
      WHERE 
        c.user_id = :uid
      AND
        e.calculated_for_month = :month
      AND
        e.calculated_for_year = :year
      ORDER BY 
        ec.pay_date;
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      },
      month = {
        value = arguments.month, sqltype = 'integer'
      },
      year = {
        value = arguments.year, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );
    var event = variables.beanFactory.getBean('eventBean');

    cfloop( query=result, group="event_id" ) { // NOTE: the group is only for base property setter efficiency; this query should never return more than 1 event_id

      event.setEvent_Id( result.event_id );
      event.setPlan_Id( result.plan_id );

      event.setCalculated_For_Month( result.calculated_for_month );
      event.setCalculated_For_Year( result.calculated_for_year );

      var plan = planService.get( result.plan_id );
      event.setPlan( plan );

      cfloop() {

        var card = variables.beanFactory.getBean('event_CardBean');

        // card
        card.setCard_Id(result.card_id);
        card.setCredit_Limit(result.credit_limit);
        card.setDue_On_Day(result.due_on_day);
        card.setUser_Id(result.user_id);
        card.setLabel(result.card_label);
        card.setMin_Payment(result.min_payment);
        card.setIs_Emergency(result.is_emergency);
        card.setBalance(result.balance);
        card.setInterest_Rate(result.interest_rate);
        card.setZero_APR_End_Date(result.zero_apr_end_date);

        // plan_card
        card.setPlan_Id(result.plan_id);
        card.setIs_Hot(result.is_hot);
        card.setCalculated_Payment(result.calculated_payment);

        // event_card
        card.setEvent_Id( result.event_id );
        card.setPay_Date( result.pay_date );

        event.addCard( card );

        if ( Len(result.actual_payment) AND Len(result.actually_paid_on) ) {

          var card_payment = variables.beanFactory.getBean('card_paidBean');

          card_payment.setUser_Id( card.getUser_Id() );
          card_payment.setCard_Id( card.getCard_Id() );
          card_payment.setActual_Payment( result.actual_payment );
          card_payment.setActually_Paid_On( result.actually_paid_on );
          card_payment.setPayment_For_Month( event.getCalculated_For_Month() );
          card_payment.setPayment_For_Year( event.getCalculated_For_Year() );

          event.addPaidCard( card_payment );

        }

      }

    }

    return event;

  }

  /*
  save() = save the contents of a single event (for a user)
  */
  public any function save( any event ) {

    if ( arguments.event.getEvent_Id() == 0 ) {

      var params = {
        pid = {
          value = arguments.event.getPlan_Id(), sqltype = 'integer'
        },
        month = {
          value = arguments.event.getCalculated_For_Month(), sqltype = 'integer'
        },
        year = {
          value = arguments.event.getCalculated_For_Year(), sqltype = 'integer'
        }
      }

      // create plan
      var sql = '
      INSERT INTO "pEvents" (
        plan_id,
        calculated_for_month,
        calculated_for_year
      ) VALUES (
        :pid,
        :month,
        :year
      ) returning event_id AS pkey_out;
      ';

      var result = QueryExecute( sql, params, variables.defaultOptions );
      var event_id = result.pkey_out;

      StructClear(params); // just in case

      params = {
        eid = {
          value = event_id, sqltype = 'integer'
        }
      };

      // create event cards
      var ecsql = '
        INSERT INTO "pEventCards" (
          event_id,
          plan_id,
          card_id,
          balance,
          is_hot,
          calculated_payment,
          pay_date
        ) VALUES
      ';

      var sql = '';
      for ( var card_id in arguments.event.getEvent_Cards() ) {

        var this_sql_string = '(
          :eid,
          #arguments.event.getPlan_Id()#,
          #card_id#,
          #arguments.event.getCard(card_id).getBalance()#,
          #arguments.event.getCard(card_id).getIs_Hot()#,
          #arguments.event.getCard(card_id).getCalculated_Payment()#,
          #arguments.event.getCard(card_id).getPay_Date()#
        )';

        sql = ListAppend(sql, this_sql_string, ",");
      }

      result = QueryExecute( ecsql & sql & ';', params, variables.defaultOptions );

    } else {

      // update event
      var event_id = arguments.event.getEvent_Id();

      var params = {
        eid = {
          value = event_id, sqltype = 'integer'
        },
        pid = {
          value = arguments.event.getPlan_Id(), sqltype = 'integer'
        },
        month = {
          value = arguments.event.getCalculated_For_Month(), sqltype = 'integer'
        },
        year = {
          value = arguments.event.getCalculated_For_Year(), sqltype = 'integer'
        }
      };

      // FIXME: last_updated should be touched - but needs to be consistent with psql
      var sql = '
      UPDATE "pEvents"
      SET 
        plan_id = :pid,
        calculated_for_month = :month,
        calculated_for_year = :year
      WHERE 
        event_id = :eid;
      ';

      var result = QueryExecute( sql, params, variables.defaultOptions );

      // update event cards
      var ecsql = '
      UPDATE "pEventCards" as ec SET
        balance = d.balance,
        is_hot = d.is_hot,
        calculated_payment = d.calculated_payment,
        pay_date = d.pay_date
      FROM (
        VALUES';

      sql = '';
      for ( var card_id in arguments.event.getEvent_Cards() ) {

        var card = arguments.event.getCard( card_id );

        var this_sql_string = '( #event_id#, 
          #arguments.event.getPlan_Id()#, 
          #card_id#, 
          #card.getBalance()#, 
          #card.getIs_Hot()#,
          #card.getCalculated_Payment()#,
          #CreateODBCDate( card.getPay_Date() )#
        )';

        sql = ListAppend(sql, this_sql_string, ",");

      }

      ecsql = ecsql & sql & ')
        AS d( event_id, plan_id, card_id, balance, is_hot, calculated_payment, pay_date )
        WHERE 
          d.card_id = pc.card_id
        AND 
          d.event_id = pc.event_id;
      ';

      result = QueryExecute( ecsql, {}, variables.defaultOptions );

    }

    return event_id;

  }

  /*
  delete() = delete a specfic event
  */
  public any function delete( string id ) {

    var sql = '
      DELETE FROM "pEventCards"
      WHERE event_id = :eid;
      DELETE FROM "pEvents"
      WHERE event_id = :eid;
    ';

    var params = {
      eid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if error

  }

  /*
  purge() = delete all events for a specific user
  */
  public any function purge( string user_id ) {

    var sql = '
      DELETE FROM "pEventCards"
      WHERE card_id IN (
        SELECT card_id
        FROM "pCards" c
        WHERE c.user_id = :uid
      );
      DELETE FROM "pEvents"
      WHERE plan_id IN (
        SELECT plan_id
        FROM "pPlans" p
        WHERE p.user_id = :uid
      );
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if error

  }

  /*****************
  Event Calculations
  *****************/

  /* will be renamed to event.create() */
  public any function create( struct in_plan, date target="1900-01-01", no_cache=false ) {

    // ================
    // 1. prep defaults
    // ================
    var plan = Duplicate( arguments.in_plan );
    var user_id = plan.getUser_Id();
    var user = userService.get(user_id);
    var deck = plan.getPlan_Deck(); // should probably run a verify here - must be a populated plan.
    var cards = deck.getDeck_Cards();
    var pay_freq = preferenceService.get( user_id ).getPay_Frequency();
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

    var nonzero_cards = plan.getNonZeroCalculatedPaymentCards();

    // PAID ACCOUNTS
    if ( user.getAccount_Type_Id() == 4 ) {

      for ( var card in nonzero_cards ) {

        // did the user actually specify a due date?
        if ( nonzero_cards[card].getDue_On_Day() > 0 ) {

          var intended_day = nonzero_cards[card].getDue_On_Day();

          // 31st, 30th, 29th (leap year) handling
          if ( DaysInMonth(calculated_for) < intended_day )
            intended_day = DaysInMonth(calculated_for);

          // populate event_card bean with its starting values
          var event_card = variables.beanFactory.getBean('event_cardBean').init( argumentCollection=nonzero_cards[card].flatten() );
          event_card.setPay_Date( CreateDate( Year(calculated_for), Month(calculated_for), intended_day ) );

          // store in event
          event.addCard( event_card );

          // remote this card from the nonzero_cards
          StructDelete( nonzero_cards, card ); // uh within the loop?

        }

      }

    }

    // if any cards remain that need their pay_date set...
    if ( !StructIsEmpty( nonzero_cards ) ) {

      // 1. including the_date[], an array of dates in the month that will be used as a ref. point
      // for deciding what to assign to each card.
      var valid_dates_for_month = ArrayNew(1);
      valid_dates_for_month[1] = CreateDate( Year( calculated_for ), Month( calculated_for ), DaysInMonth( calculated_for ) ); // end of the month

      // 2. Examine the user's preferences, and modify/update the_date[] accordingly.
      if ( pay_freq == 2 ) {

        valid_dates_for_month[2] = CreateDate( Year( calculated_for ), Month( calculated_for ), 15 );

      } else if ( pay_freq == 3 ) {

        var qMonthPayPeriods = pay_periodService.qGetPayPeriodsInMonthOfDate( calculated_for );

        for ( var m=qMonthPayPeriods.RecordCount; m > 0; m-- ) { // walk backwards

          valid_dates_for_month[m] = qMonthPayPeriods.pay_date[m];

        }

      }

      // 3. Reduce the cards to only those with a balance, and split their payments with a knapsack algorithm
      var paymentsArray = splitPayments( nonzero_cards, ArrayLen(valid_dates_for_month) );

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

    } // if cards remain that need have their pay_date set

    // if the user made any payments, add them here

    var card_payments = variables.card_paidService.list( user_id, Month(calculated_for), Year(calculated_for) ); // array

    if ( ArrayLen( card_payments) ) {
      cfloop( array=card_payments, index="paid_card" ) {
        event.addPaidCard( paid_card );
      }
    }

    // 5. FIXME: Handle any ignored cards (not sure why they should be included at all?) - their absence is probably fucking up forecasting.

    if (!arguments.no_cache) {
      var event_id = save(event);
      event.setEvent_Id( event_id );
    }

    // 6. create event bean and populate
    return event;

  }

  public array function splitPayments( any cards, number dividend ) {

    // this function will iterate over the cards, determine the best way to split payments across divident amt of times.
    // adapted from: https://stackoverflow.com/questions/3009146/splitting-values-into-groups-evenly

    // 0. prep
    var pay_days = ArrayNew(1);
    var calc_cards = arguments.cards.map( function(key, value) {  // convert struct of beans to struct of calculated_payments
      return value.getCalculated_Payment();
    });

    // 1. total the calculated payments
    var totalcp = calc_cards.reduce( function(result, key, value) {
      return result + value;
    }, 0);

    // 2. divide total by # of elements you need to split across - this gives you a max per split.
    var pay_frequency_capacity = totalcp / arguments.dividend;

    // 3. if there are more/equal payments than there are days/month to pay (eg 2 debts, 2 times a month or 4 debts, 1 time a month)
    if ( StructCount( calc_cards ) >= arguments.dividend ) {

      // 3a. loop over the # of elements to split across
      for ( var a=1; a <= arguments.dividend; a++ ) {

        // if not the last element AND there are still cards to split
        if ( a < arguments.dividend && !StructIsEmpty( calc_cards ) ) {

          // split pay
          var splitArray = knapsackService.knapsack( calc_cards, pay_frequency_capacity );

          // if it was splittable...
          if ( ArrayLen(splitArray) ) {

            // TODO: any list should suffice, but will we ever want to *prefer* one?
            // grab the 1st list of split payments
            var chosen = splitArray[1];
            var payment_made = calc_cards.filter( function(key, value) {
              return ListFind( chosen, key, "," );
            });
            var payment_remains = calc_cards.filter( function(key, value) {
              return !ListFind( chosen, key, "," );
            });

            // store the made payments
            ArrayAppend( pay_days, payment_made )

            // pair the loop down by updating calc_cards to whatever remains
            calc_cards = payment_remains;

          }

        // else (it is the last element OR there are no more cards to split)
        } else {

          // we don't attempt to knapsack (split) the last element. we accept it as is.
          ArrayAppend( pay_days, calc_cards );

        }

      } // end loop over elements to split

    // else if there are less payments than days/months to pay (eg 1 debt, 2 times a month)
    } else {

      // put all the cards into the 1st element.
      ArrayAppend( pay_days, calc_cards );

      // TODO: re-factor so that you can pay 1 card multiple times a month.

    }

    return pay_days;

  }

  // use an initial plan and create all of the events necessary to populate a schedule
  public function fill( any in_plan, no_cache=false ) {

    /*
    1. prep vars
    - grab a copy of the plan's fingerprint
    2. get the user's budget
    3. start a new events array
    4. get the user's plan
    */
    var plan = Duplicate( arguments.in_plan );
    var fp = plan.getFingerprint();
    var user_id = plan.getUser_Id();
    var user = userService.get( user_id );
    var deck = plan.getPlan_Deck();
    var cards = deck.getDeck_Cards();
    var budget = preferenceService.get( user_id ).getBudget();
    var next_date = plan.getActive_On();
    var events = ArrayNew(1);

    /* 5. convert the plan into an event.*/
    var event = create( plan );

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

            // ***PAID*** support only
            if ( user.getAccount_Type_Id() == 4 ) {

              var expiryDate = cards[card_id].getZero_APR_End_Date();

              // if there is an expiry date, and it hasn't yet lapsed (compared to date being computed)
              if ( isDate( expiryDate ) && DateCompare( next_date, expiryDate, "m" ) <= 0 ) {

                // 8bii. add it to the card's reamining_balance.
                var next_balance = cards[card_id].getRemaining_Balance();

              } else {

                // it's either not a zero apr card, or it is but the expiry has passed
                // 8bi. calculate the interest for next month (STANDARD/FREE accounts)
                var next_interest = plan.calculateMonthInterest( cards[card_id].getRemaining_Balance(), cards[card_id].getInterest_Rate(), next_date );

                // 8bii. add it to the card's reamining_balance.
                var next_balance = cards[card_id].getRemaining_Balance() + next_interest;

              }

            } else {

              // 8bi. calculate the interest for next month (STANDARD/FREE accounts)
              var next_interest = plan.calculateMonthInterest( cards[card_id].getRemaining_Balance(), cards[card_id].getInterest_Rate(), next_date );

              // 8bii. add it to the card's reamining_balance.
              var next_balance = cards[card_id].getRemaining_Balance() + next_interest;

            }

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
        if ( !arguments.no_cache ) {
          plan_id = planService.save( plan );
          // update the plan obj
          plan.setPlan_Id( plan_id );
        }

        // now use this plan to create a new event
        var new_event = create( plan );

        // update the fingerprint
        fp = plan.getFingerprint();

      } else {

        // use the existing plan, but pass in the new working date
        var new_event = create( plan, next_date );

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