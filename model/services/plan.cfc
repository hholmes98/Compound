//model/services/plan
component accessors=true {

  public any function init( beanFactory, preferenceService, plan_cardService, userService ) {

    variables.beanFactory = arguments.beanFactory;
    variables.preferenceService = arguments.preferenceService;
    variables.plan_cardService = arguments.plan_cardService;
    variables.userService = arguments.userService;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  /******
    CRUD
  ******/

  /*
  list() = get all plans for a user
  */
  public any function list( string user_id ) {

    var sql = '
      SELECT p.plan_id, p.active_on, c.card_id, c.credit_limit, c.due_on_day, c.user_id, c.card_label, c.min_payment, c.is_emergency, c.balance, 
        c.interest_rate, c.zero_apr_end_date, c.code, c.priority, pc.is_hot, pc.calculated_payment
      FROM "pPlans" p
      INNER JOIN "pPlanCards" pc ON
        p.plan_id = pc.plan_id
      INNER JOIN "pCards" c ON
        pc.card_id = c.card_id
      WHERE p.user_id = :uid
      ORDER BY p.active_on, pc.card_id;
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );
    var plans = ArrayNew();

    cfloop( query=result, group="plan_id" ) {

      var plan = variables.beanFactory.getBean('planBean');

      plan.setPlan_Id( result.plan_id );
      plan.setUser_Id( arguments.user_id );
      plan.setActive_On( result.active_on );

      var deck = variables.beanFactory.getBean('deckBean');

      cfloop() {

        var card = variables.beanFactory.getBean('plan_cardBean');

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

        deck.addCard( card );

      }

      plan.setPlan_Deck( deck );

      // add to the list of plans
      ArrayAppend( plans, plan );

    }

    return plans;

  }

  /*
  get() = get a specific plan by its primary key
  */
  public any function get( string id ) {

    var sql = '
      SELECT p.plan_id, p.user_id, p.active_on, c.card_id, c.credit_limit, c.due_on_day, c.user_id, c.card_label, c.min_payment, 
        c.is_emergency, c.balance, c.interest_rate, c.zero_apr_end_date, c.code, c.priority, pc.is_hot, pc.calculated_payment
      FROM "pPlans" p
      INNER JOIN "pPlanCards" pc ON
        p.plan_id = pc.plan_id
      INNER JOIN "pCards" c ON
        pc.card_id = c.card_id
      WHERE p.plan_id = :pid
    ';

    var params = {
      pid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );
    var plan = variables.beanFactory.getBean('planBean');

    if ( result.RecordCount ) {

      plan.setPlan_Id( result.plan_id[1] );
      plan.setUser_Id( result.user_id[1] );
      plan.setActive_On( result.active_on[1] );

      var deck = variables.beanFactory.getBean('deckBean');

      cfloop( query=result ) {

        var card = variables.beanFactory.getBean('plan_cardBean');

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

        deck.addCard( card );

      }

      plan.setPlan_Deck( deck );

    }

    return plan;

  }

  /*
  save() = save the contents of a single plan (for a user)
  */
  public any function save( any plan ) {

    if ( arguments.plan.getPlan_Id() == 0 ) {

      // create plan
      var sql = '
      INSERT INTO "pPlans" (
        user_id,
        active_on
      ) VALUES (
        #arguments.plan.getUser_Id()#,
        #CreateODBCDate( arguments.plan.getActive_On() )#
      ) returning plan_id AS pkey_out;
      ';

      var result = QueryExecute( sql, {}, variables.defaultOptions );
      var plan_id = result.pkey_out;

      var params = {
        pid = {
          value = plan_id, sqltype = 'integer'
        }
      };

      // create plan cards
      var pcsql = '
        INSERT INTO "pPlanCards" (
          plan_id,
          card_id,
          is_hot,
          calculated_payment
        ) VALUES
      ';

      var sql = '';
      for ( var card_id in arguments.plan.getPlan_Deck().getDeck_Cards() ) {

        var this_sql_string = '(
          :pid,
          #card_id#,
          #arguments.plan.getCard(card_id).getIs_Hot()#,
          #arguments.plan.getCard(card_id).getCalculated_Payment()#
        )';

        sql = ListAppend(sql, this_sql_string, ",");
      }

      result = QueryExecute( pcsql & sql & ';', params, variables.defaultOptions );

    } else {

      // update plan
      var plan_id = arguments.plan.getPlan_Id();

      var params = {
        pid = {
          value = plan_id, sqltype = 'integer'
        }
      };

      // FIXME: last_updated should be touched - but needs to be consistent with psql
      var sql = '
      UPDATE "pPlans"
      SET 
        active_on = #CreateODBCDate( arguments.plan.getActive_On() )#,
      WHERE 
        plan_id = :pid;
      ';

      var result = QueryExecute( sql, params, variables.defaultOptions );

      // update plan cards
      var pcsql = '
      UPDATE "pPlanCards" as pc SET
        is_hot = d.is_hot,
        calculated_payment = d.calculated_payment
      FROM (
        VALUES';

      sql = '';
      for ( var card_id in arguments.plan.getPlan_Deck().getDeck_Cards() ) {

        var this_sql_string = '( #arguments.plan.getPlan_Id()#, #card_id#, #arguments.plan.getCard(card_id).getIs_Hot()#, #arguments.plan.getCard(card_id).getCalculated_Payment()# )';

        sql = ListAppend(sql, this_sql_string, ",");

      }

      pcsql = pcsql & sql & ')
        AS d( plan_id, card_id, is_hot, calculated_payment )
        WHERE 
          d.plan_id = pc.plan_id 
        AND 
          d.card_id = pc.card_id;
      ';

      result = QueryExecute( pcsql, {}, variables.defaultOptions );

    }

    return plan_id;

  }

  /*
  delete() = delete a specfic plan
  */
  public any function delete( string id ) {

    var sql = '
      DELETE FROM "pPlans"
      WHERE plan_id = :pid;
      DELETE FROM "pPlanCards"
      WHERE plan_id = :pid;
    ';

    var params = {
      pid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;

  }

  /*
  purge() = delete all plans for a specific user
  */
  public any function purge( string user_id ) {

    var sql = '
    DELETE FROM "pPlanCards"
    WHERE card_id IN (
      SELECT card_id
      FROM "pPlanCards" pc
      INNER JOIN "pPlans" p ON
        pc.plan_id = p.plan_id
      WHERE p.user_id = :uid
    );
    DELETE FROM "pPlans"
    WHERE user_id = :uid;
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;

  }

  /****************
  Plan Calculations
  ****************/

  public any function create( string user_id, date calculated_for=Now(), no_cache=false ) {

    // 1. get the user's budget
    var user = userService.get( arguments.user_id );
    var budget = preferenceService.get( arguments.user_id ).getBudget();

    // 2. Get the user's deck
    var plan_deck = plan_cardService.deck( arguments.user_id );

    // 3. prep a plan bean
    var in_plan = variables.beanFactory.getBean('planBean');

    in_plan.setUser_Id( arguments.user_id );
    in_plan.setPlan_Deck( plan_deck );
    in_plan.setActive_On( CreateDate( Year( arguments.calculated_for ), Month( arguments.calculated_for ), 1 ) );
    in_plan.setBudget( budget );

    if ( user.getAccount_Type_Id() == 4 ) { // life hacker

      in_plan.setConsiderAPRExpiry( true );
      in_plan.setConsiderPriority( true );

    }

    var out_plan = calculatePayments( in_plan, budget, arguments.calculated_for );

    // 5. Cache the newly generated plan
    if ( !arguments.no_cache ) {
      plan_id = save( out_plan );
      out_plan.setPlan_Id( plan_id ); // technically, this should set the plan_id at the base obj *and* all the card in its deck.
    }

    // 6. Return the plan
    return out_plan;

  }

  /**************
  Plan Functions
  **************/
  public any function calculatePayments( any in_plan, numeric available_budget, date target, boolean use_interest=true, emergency_priority=false ) {

    var plan = arguments.in_plan;
    var deck = plan.getPlan_Deck();
    var cards = deck.getDeck_Cards();

    // 1. Calculated the current min. payments (on non-zero balances)
    var totalMinPayment = plan.getTotalMinPayments( ignoreBalance=false );

    if ( arguments.available_budget >= totalMinPayment ) {

      /*******
      Calc Hot Card's Payment
      *******/

      // get the hot card, store it
      var hot_card_id = plan.findNextHotCardID( arguments.available_budget );
      if ( hot_card_id != 0 ) {

        var hot_card = plan.getCard( hot_card_id );
        hot_card.setIs_Hot(1);

        // loop over all cards *but* the hot card
        var running_tot = 0;

        for ( var card_id in cards ) {

          if ( card_id != hot_card.getCard_Id() ) {

            var card = plan.getCard( card_id );

            //set their calculated_payment
            var calc_payment = plan.calculatePayment( card.getBalance(), card.getMin_Payment(), 0 ); // 0 = we never consider interest on a calculated payment.
            card.setCalculated_Payment( calc_payment );
            plan.setCard(card);

            // tally that calculated payment to a running total
            running_tot += card.getCalculated_Payment();

          }

        } // end loop

        // remove the tally from the availble budget
        // set to hot card's calculated payment
        hot_card.setCalculated_Payment( arguments.available_budget - running_tot );
        // update the plan with the hot card's values
        plan.setCard( hot_card );

        /****************
        Determine if there's more than 1 hot card in this plan
        *****************/

        // if the hot card's calculated payment > the hot card's balance (OR the hot card was the CALL Card) <-- look at this last one later
        if ( hot_card.getCalculated_Payment() > hot_card.getBalance() ) {

          // set the hot card's calculated payment = to its balance
          hot_card.setCalculated_Payment( hot_card.getBalance() );

          // set a smaller budget = available_budget - hot card's calculated payment
          var smaller_budget = arguments.available_budget - hot_card.getCalculated_Payment();

          // remove the hot card
          plan.removeCard( hot_card );

          // set plan = into calculated_payment, passing in plan with smaller deck and smaller budget
          plan = calculatePayments( plan, smaller_budget, arguments.target, arguments.use_interest, arguments.emergency_priority );

          // add hot card back into plan
          plan.addCard( hot_card );

        } // end if there should be multiple hot cards

      } // end if the hot_card_id != 0

    } else {

      /*new*/
      /* get the total number of remaining cards */
      var cards = plan.getPlan_Deck().getDeck_Cards();

      /* if there are more than 1 card left, move into the CALL card logic below */
      if ( StructCount( cards ) > 1 ) {

        /************
        get CALL, remove it, run again, add back
        ************/

        // use logic to determine the top most offending card
        var off_card_id = plan.findNextCallCardID();

        if ( off_card_id != 0 ) {

          var off_card = plan.getCard( off_card_id );

          // set it to Calculated_Payment(-1)
          off_card.setCalculated_Payment( -1 );

          // remove it from the deck
          plan.removeCard( off_card );

          // set plan = recurse into calculated_payments, passing in the plan with the smaller deck but the same budget
          plan = calculatePayments( plan, arguments.available_budget, arguments.target, arguments.use_interest, arguments.emergency_priority );

          // add it back into the plan deck
          plan.addCard( off_card );

        }

      /* if there is only 1 card left... */
      } else {

        // get the last remaining card
        var final_card = cards.reduce( function(p,k,v) {
          return v;
        });

        // set the budget = to the minimum payment on the card, and go again
        plan = calculatePayments( plan, final_card.getMin_Payment(), arguments.target, arguments.use_interest, arguments.emergency_priority );

        // throw the override flag so we can notify the front-end
        plan.setIsBudgetOverride(true);

      }

    }

    // return the updated plan
    return plan;

  }

}