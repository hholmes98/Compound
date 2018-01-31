// debt.cfc
/* this is the controller for the custom on-boarding - Card-First, rather than Account-First */
component accessors = true { 

	property framework;
    property debtservice;
    property cardservice;

    function init( fw ) {

        variables.fw = fw;

        return this;

    }    

    /* raw json methods */
    public void function list( struct rc ) {
        
        var cards = debtservice.list( session.auth.user.getUser_Id() );

        framework.renderdata("JSON", cards);
    
    }

    /* we don't use events in the anonymous version
    public void function schedule( struct rc ) {

        var events = planservice.events( arguments.rc.user_id );

        framework.renderdata("JSON", events);

    }
    */

    public void function journey( struct rc ) {

        var milestones = debtservice.milestones( session.auth.user.getUser_Id() );

        framework.renderdata("JSON", milestones);

    }

    /* we don't delete plans in the anonymous version
    public void function delete( struct rc ) {
        
        var ret = planservice.delete( arguments.rc.user_id );
        
        framework.renderdata("JSON", ret);
    
    }
    */

    public void function calculate( struct rc ) {

        var cardcount = 0;

        // reset the tmp cards session
        session.tmp.cards = StructNew();

        // store the temp. budget
        session.tmp.preferences.budget = rc.budget;
        
        // count the number of cards submitted by enumerating fieldlist via 'credit-card'
        for ( field in rc.fieldnames ) {

            if ( field CONTAINS 'credit-card-label' ) {

                cardcount++;

            }

        }

        // store the counted temp. cards
        for ( var a=1; a <= cardcount; a++ ) {

            var card = StructNew();
            var capture = false;

            if ( Len( rc['credit-card-balance' & a] ) ) {

                card.balance = rc['credit-card-balance' & a];
                capture = true;

            }

            if ( capture ) {

                card.card_id = CreateUUID();
                card.user_id = session.auth.user.getUser_Id();
                card.label = rc['credit-card-label' & a];

                var card_o = cardservice.toBean( card );

                StructInsert( session.tmp.cards, card.card_id, card_o );

            }

        }

        // redirect to the plan
        variables.fw.redirect( "debt.plan" );

    }

    public void function create( struct rc ) {

        // store just redirects to the login.create method, but appends a message telling the user we're going to save their work
        rc.message = ["Let's save your progress by creating an account. Pick a Nickname for your account and give us your email address."];

        variables.fw.redirect( "login.create", "message" );

    }

    /* front-end methods */
    /*
    public any function plan( struct rc ) {

    }
    */















    







    



    
    /*
    remote any function dbCalculatePayment( numeric balance, numeric minimum_payment, numeric interest_rate, date target_date=Now() ) {

        var payment = 0;

        // why?!?
        if ( arguments.balance == 0 )
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
    */

    /*
    public numeric function dbCalculateMonthInterest( numeric b, numeric i, date m ) {

        // 1. divide the interest rate by 365 to get dpr
        var dpr = arguments.i / 365;

        // 2. multiply the dpr by the balance to get a daily charge
        var daily = dpr * arguments.b;

        // 3. multiply the daily charge by the # of the days in the month.
        var total = daily * DaysInMonth( Month( arguments.m ) );

        return total;
    }
    */

    /*
    public any function dbEvaluateEmergencyCard( struct plan, numeric eid ) {

        var e_card              = cardservice.get( arguments.eid );
        var uid                 = e_card.getUser_Id();
        var budget              = preferenceservice.getBudget( uid );
        var card                = 0;
        var calc_e_payment      = 0;
        var this_plan           = duplicate( arguments.plan );
        var new_payment_plan    = 0;

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
    */

    /* takes a computed plan and a target date, and applies a 'pay_date' to each card in the plan (produces: event) */
    /*
    public any function dbCalculateEvent( struct plan, date calculated_for, no_cache=false ) {

        // TODO: later, look at the date and get a *portion* of the cached schedule from the db (if it exists)
        var card        = 0;
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
    */

}