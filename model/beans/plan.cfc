//model/beans/plan
component accessors = true {

  // explicit (db rows)
  property plan_id;
  property user_id;
  property active_on;

  // cards
  property plan_deck; // the entire user deck for a given (active-on) date.

  // new
  property isBudgetOverride;

  /* TO FUTURE ME */
  /* modify the plan bean so that you set/get budget, prior to the calculation */
  /* then, the isBudgetOverride flag can be thrown if it needs to be overrridden */

  function init( string plan_id = 0, string user_id = "", string active_on = "", any plan_deck="", any isBudgetOverride = false ) {

    variables.plan_id = arguments.plan_id;
    variables.user_id = arguments.user_id;
    variables.active_on = arguments.active_on;

    variables.plan_deck = arguments.plan_deck; // since plan_deck mutates during calculation, consider storing the initial list of CardIDs

    // internal only
    variables.isBudgetOverride = arguments.isBudgetOverride;

    return this;

  }

  function isBudgetOverride() {

    return getIsBudgetOverride();
  }

  // setPlan_Deck
  // getPlan_Deck
  function setPlan_Id( string plan_id ) {

    variables.plan_id = arguments.plan_id;

    if ( !IsSimpleValue(variables.plan_deck) ) {
      for ( var card_id in variables.plan_deck.getDeck_Cards() ) {
        var dummy = getCard( card_id ); // see below: the act of calling getCard() cascades a plan_id down into the card
      }
    }

  }

  function addCard( any card ) {

    variables.plan_deck.addCard( arguments.card );
  }

  function removeCard( any card ) {

    variables.plan_deck.removeCard( arguments.card );
  }

  function getCard( string id ) {

    var card = variables.plan_deck.getCard( arguments.id );

    // if the card's plan_id is different than the plan's id, the plan's id takes precedence
    if ( variables.plan_id != 0 && variables.plan_id != card.getCard_Id() ) {

      card.setPlan_Id( variables.plan_id );
      setCard( card );

    }

    return card;
  }

  function setCard( any card ) {

    variables.plan_deck.setCard( arguments.card );
  }

  function findNextHotCardID( numeric available_budget ) {

    // get the emergency card from the plan.
    var e_card = getEmergencyCard( true );
    if ( !IsSimpleValue(e_card) ) {

      // next step: does it have a balance?
      if ( e_card.getBalance() > 0 ) {

        // get the current list of all the hot cards in the plan
        var hot_cards = getHotCards();
        var hot_card_ids = StructKeyList( hot_cards );

        // is the emergency card already one of the hot cards?
        if ( !ListFind( hot_card_ids, e_card.getCard_Id() ) ) {

          // yes? next: what % of its calculated_payment is of the available budget
          var e_payment = calculatePayment( e_card.getBalance(), e_card.getMin_Payment(), 0 );

          if ( e_payment / arguments.available_budget > application.emergency_balance_threshold ) {
            // if more than the threshold, then return this e_card as the hot card.
            return e_card.getCard_Id();
          }

        } // the e_card is already a hot card

      } // the e_card has no balance

    } // no e_card exists

    var cards = variables.plan_deck.getDeck_Cards();
    var sorted = sortHotCards( cards );

    if ( ArrayLen(sorted) ) {
      var hot_card_id = sorted[1];
      return hot_card_id;
    }

    return 0;
  }

  function findNextCallCardID() {

    // this function attempts to find the next best card to set to be ignored.
    // several rules are applied
    // 1. what is the card with the highest minimum payment, the highest balance, and the highest interest rate?
    var cards = variables.plan_deck.getDeck_Cards();
    var sorted = sortOffendingCards( cards );

    if ( ArrayLen(sorted) ) {
      var offending_card_id = sorted[1];
      return offending_card_id;
    }

    return 0;

    // TODO 2. is there a Zero APR card in the deck, and if so, is its due date in the future?

  }

  function sortInterestRateDESC(left, right) {
    if ( variables.plan_deck.getCard( arguments.left ).getInterest_Rate() > variables.plan_deck.getCard( arguments.right ).getInterest_Rate() )
      return -1;
    else if ( variables.plan_deck.getCard( arguments.left ).getInterest_Rate() < variables.plan_deck.getCard( arguments.right ).getInterest_Rate() )
      return 1;

    return 0;
  }

  function sortInterestRateASC(left, right) {
    if ( variables.plan_deck.getCard( arguments.left ).getInterest_Rate() > variables.plan_deck.getCard( arguments.right ).getInterest_Rate() )
      return 1;
    else if ( variables.plan_deck.getCard( arguments.left ).getInterest_Rate() < variables.plan_deck.getCard( arguments.right ).getInterest_Rate() )
      return -1;

    return 0;
  }

  function sortBalanceDESC(left, right) {
    if ( variables.plan_deck.getCard( arguments.left ).getBalance() > variables.plan_deck.getCard( arguments.right ).getBalance() )
      return -1;
    else if ( variables.plan_deck.getCard( arguments.left ).getBalance() < variables.plan_deck.getCard( arguments.right ).getBalance() )
      return 1;

    return 0;
  }

  function sortBalanceASC(left, right) {
    if ( variables.plan_deck.getCard( arguments.left ).getBalance() > variables.plan_deck.getCard( arguments.right ).getBalance() )
      return 1;
    else if ( variables.plan_deck.getCard( arguments.left ).getBalance() < variables.plan_deck.getCard( arguments.right ).getBalance() )
      return -1;

    return 0;
  }

  function sortMinPaymentDESC(left, right) {
    if ( variables.plan_deck.getCard( arguments.left ).getMin_Payment() > variables.plan_deck.getCard( arguments.right ).getMin_Payment() )
      return -1;
    else if ( variables.plan_deck.getCard( arguments.left ).getMin_Payment() < variables.plan_deck.getCard( arguments.right ).getMin_Payment() )
      return 1;

    return 0;
  }

  function sortMinPaymentASC(left, right) {
    if ( variables.plan_deck.getCard( arguments.left ).getMin_Payment() > variables.plan_deck.getCard( arguments.right ).getMin_Payment() )
      return 1;
    else if ( variables.plan_deck.getCard( arguments.left ).getMin_Payment() < variables.plan_deck.getCard( arguments.right ).getMin_Payment() )
      return -1;

    return 0;
  }

  function sortBalanceASC_interestRateDESC( left, right ) {

    var sorted = sortBalanceASC( arguments.left, arguments.right );

    if ( !sorted ) {
      sorted = sortInterestRateDESC( arguments.left, arguments.right );
    }

    return sorted;

  }

  function sortMinPaymentDESC_balanceDESC_interestRateDESC( left, right ) {

    var sorted = sortMinPaymentDESC( arguments.left, arguments.right );

    if ( !sorted ) {
      sorted = sortBalanceDESC( arguments.left, arguments.right );
      if ( !sorted ) {
        sorted = sortInterestRateDESC( arguments.left, arguments.right );
      }
    }

    return sorted;

  }

  function sortHotCards( any cards ) {

    // filter down to the cards that have a balance
    var f_cards = arguments.cards.filter( function(item) {
      return variables.plan_deck.getCard(item).getBalance() > 0
    });

    // convert to array
    var a_cards = StructKeyArray(f_cards);

    // balance ASC, interest_rate DESC
    a_cards.sort( sortBalanceASC_interestRateDESC );

    return a_cards;

  }

  function sortOffendingCards( any cards ) {

    // filter down to the cards that have a balance
    var f_cards = arguments.cards.filter( function(item) {
      return variables.plan_deck.getCard(item).getBalance() > 0
    });

    // convert to array
    var a_cards = StructKeyArray(f_cards);

    // min_payment DESC, balance DESC, interest_rate DESC
    a_cards.sort( sortMinPaymentDESC_balanceDESC_interestRateDESC );

    return a_cards;

  }

  function getHotCards() {

    var hot = {};

    for ( var card_id in variables.plan_deck.getDeck_Cards() ) {
      if ( variables.plan_deck.getCard(card_id).getIs_Hot() ) {
        StructInsert( hot, card_id, variables.plan_deck.getCard(card_id) );
      }
    }

    return hot;

  }

  function getNonZeroCalculatedPaymentCards() {

    var cps = StructNew();

    for ( var card_id in variables.plan_deck.getDeck_Cards() ) {
      if ( variables.plan_deck.getCard(card_id).getCalculated_Payment() > 0 ) {
        StructInsert( cps, card_id, variables.plan_deck.getCard(card_id) );
      }
    }

    return cps;
  }

  function getZeroBalanceCards() {

    var zeros = StructNew();

    for ( var card_id in variables.plan_deck.getDeck_Cards() ) {

      if ( variables.plan_deck.getCard(card_id).getBalance() == 0 ) {

        StructInsert( zeros, card_id, variables.plan_deck.getCard(card_id) );

      }

    }

    return zeros;

  }

  function getEmergencyCard( boolean returnIntOnError=false ) {

    try {

      var e_card = variables.plan_deck.getEmergencyCard();

      return e_card;

    } catch (e) {

      if ( !arguments.returnIntOnError ) {
        Throw( message="Emergency Card ID Non-Existent", detail="A request for the emergency card in the user's deck turned up nothing." );
      } else {
        return -1;
      }

    }

  }

  function setEmergencyCard( any e_card ) {

    variables.plan_deck.setEmergencyCard( arguments.e_card );

  }

  function getTotalCalculatedPayments() {

    var tot = 0
    var cards = variables.plan_deck.getDeck_Cards();

    for ( var card_id in cards ) {
      tot += cards[card_id].getCalculated_Payment();
    }

    return tot;

  }

  function getTotalMinPayments( boolean ignoreBalance=true ) {

    var tot = 0;
    var cards = variables.plan_deck.getDeck_Cards();

    for ( var card_id in cards ) {

      if ( arguments.ignoreBalance ) {

        tot += cards[card_id].getMin_Payment();

      } else {

        if ( cards[card_id].getBalance() > 0 ) {

          tot += cards[card_id].getMin_Payment();

        }

      }

    }

    return tot;

  }

  function getTotalDebtLoad() {

    var tot = 0;
    var cards = variables.plan_deck.getDeck_Cards();

    for ( var card_id in cards ) {

      tot += cards[card_id].getBalance();

    }

    return tot;

  }

  function getFingerprint() {

    //https://stackoverflow.com/questions/9813206/fastest-method-for-fingerprinting-an-array-calculating-a-unique-hash-from-an-ar

    var cards = variables.plan_deck.getDeck_Cards();

    var calc_cards = cards.map( function(key, value) {  // convert struct of beans to struct of calculated_payments
      return value.getCalculated_Payment();
    });

    //TODO: maybe look at a non-cryptographic hash?
    return Hash( SerializeJSON(calc_cards) );

  }

  public numeric function calculatePayment( numeric balance, numeric minimum_payment, numeric interest_rate, date target_date=Now() ) {

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
      var month_interest = calculateMonthInterest( arguments.balance, arguments.interest_rate, arguments.target_date );

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
      Throw( type="Custom", errorCode="ERR_NEGATIVE_CALCULATE_PAYMENT", message="CalculatePayment negative value.", detail="dbCalculatePayment produced a negative value.", var={balance:arguments.balance,interest_rate:arguments.interest_rate,target_date:arguments.target_date});
    }

    return payment;

  }

  public numeric function calculateMonthInterest( numeric b, numeric i, date m ) {

    // 1. divide the interest rate by 365 to get dpr
    var dpr = arguments.i / 365;

    // 2. multiply the dpr by the balance to get a daily charge
    var daily = dpr * arguments.b;

    // 3. multiply the daily charge by the # of the days in the month.
    var total = daily * DaysInMonth( Month( arguments.m ) );

    return total;

  }

}