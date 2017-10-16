//plan.cfc
component accessors="true" {

	property cardservice;
	property preferenceservice;
		
	public any function init(  ) {

		variables.planFile = expandPath( "/assets/plan-dataset.json" ); 

		variables.data = deserializeJSON( fileRead( variables.planFile ) );		

	}

	public any function list( string user_id ) {

		// TODO: Look at plan creation date, and last login date. If ~1 month has passed,
		// update balances for user as they go along, so they don't have to update them on their own.

		// TODO: later, add a check for IsDirty = cards were changed, but plan wasn't
		//if ( StructIsEmpty( variables.data.plan ) ) { 

			var cards = cardservice.list( arguments.user_id );

			// just do it here. take a look at today's date. 
			// then compare with user's plan creation date.
			// then determine difference in months.
			// then get the plan for that many month's into the future.

			// TODO: later, each card should record the date of its last update,
			// so a daily service can run in the background, look at a last update of (30+ days) and
			// automatically update the balance for user's
			// the first time the plan is created, all the card's dates will be the same (the day of the
			// plan) but over time, as user's come back to update cards, the dates will begin to update
			// to more accurate values

			variables.data.plan = calculatePayments( cards, preferenceservice.getBudget( arguments.user_id ) );

			//FileWrite( variables.planFile, serializeJson( variables.data ) );

		//}

		return variables.data.plan;

	}	

	/* ***
	events()

	powers the "Plan > Schedule by Month" tab
	*** */

	public any function events( string user_id ) {

		// return an array of event dates reflecting when each card is paid and by how much

		/* match this format: 

		  var = [
		   
		    //month1
		    {title: 'Pay $28.72 to card1', start: new Date(y, m, 12)},
		    {title: 'Pay $33.90 to card2', start: new Date(y, m, 27)},
		    
		    //month2    
		    {title: 'Pay $28.72 to card1', start: new Date(y, m+1, 12)},
		    {title: 'Pay $33.90 to card2', start: new Date(y, m+1, 27)},

		    etc...

		  ];

		*/

		var min_card_threshold = 10; // in a given month, never allow a payment to drop the balance of a card below this number (to prevent things like carrying an .11 cent balance)

		var events = arrayNew(1);
		var plancards = list( arguments.user_id ); // you're getting the calculated card plan for 1 month.

		var year = Year(Now());
		var month = Month(Now());
		var day = Day(Now());

		var thisDate = CreateDate(year,month,day);
		var nextDate = thisDate;		

		/* re-factor 

		WARNING: YOU'RE MANIPULATING AN ARRAY AS YOU ITERATE OVER IT. PAY ATTENTION!!!

		1. loop until the total balance of all cards is 0. 
		2. Each iteration is one month. For each month:
			3. Process each card. For each card:
				4. Get the balance.
				4a. If this is any month other than the first, calculate the interest, add to the balance.
				4b. If the calculated payment < the balance, set the calculated payment to the balance.
				5.  Remove the calculated payment from the balance.
			6.  If the balance on any card was set to 0, calculate a new plan based on remaining cards, and continue to the next month
		*/
		var total_balance = 0;
		var thisMonthBalance = 0;
		var one_card_paid_off = false;	
		var count = 0;	
		var nonZeroCardCount = 0;

		for (card in plancards) {
			total_balance += Replace( plancards[card].getBalance(), ",", "", "ALL" );
			if ( Replace( plancards[card].getBalance(), ",", "", "ALL" ) > 0 ) {
				nonZeroCardCount++;
			}
		}

		//1. loop until the total balance of all cards is 0. 
		while ( total_balance > 0 ) {

			thisMonthBalance = 0;

			var firstOfMonth = CreateDate(Year(nextDate),Month(nextDate),1);
			var fifteenthOfMonth = CreateDate(Year(nextDate),Month(nextDate),15);
			var twoWeeksFromNow = DateAdd('w',nextDate,2);
			var cardCount = 0;

			for (card in plancards) {

				var thisCardDetails = structNew();
				var cardCount++;

				// 4. get balance (as a val)
				if ( IsObject(plancards[card]) ) {
					
					var thisBalance = Replace( plancards[card].getBalance(), ",", "", "ALL" );
					
					plancards[card].setBalance( thisBalance );

					// if there is a balance
					if ( plancards[card].getBalance() > 0 ) {
						
						// 4a. If this is any month other than the first, calculate the interest, add to the balance.
						
						if ( arrayLen( events ) ) {

							// update the balance by incrementing it 
							// banks do this on a daily basis as the balance fluctuates, but
							// we have the luxury of assuming no changes across the history of the cards based on the starting 
							// snapshot, so we'll just multiple the daily interest accrued by the number of days in this calculated month
							var daily_interest_accrued = (plancards[card].getInterest_Rate() / 365) * thisBalance;
					
							plancards[card].setBalance( thisBalance + (daily_interest_accrued * daysInMonth(Month(nextDate))) );

						}
						

						// 4b. If the calculated payment > the balance, set the calculated payment to the balance.
						if ( plancards[card].getCalculated_Payment() > plancards[card].getBalance() ) {
							plancards[card].setCalculated_Payment( plancards[card].getBalance() );
						} else {

						// TODO
						// set a min balance threshold allowed on a card, to prevent a single month from allowing a card to have a balance of 11 cents. :P
						// something like a min. threshold of $10.00
						// eg. calculated payment: 12.72, balance: 13.04
							if ( plancards[card].getBalance() - plancards[card].getCalculated_Payment() < min_card_threshold ) {
								plancards[card].setCalculated_Payment( plancards[card].getBalance() );	// just pay it off
							}

						}

						// CALCULATION END ****
						

						// DEBUG
						//writeoutput(plancards[card].label & " is getting a payment of " & plancards[card].calculated_payment & "towards a balance of " & plancards[card].balance & "<br>");					

						// 5. Remove the calculated payment from the balance.
						plancards[card].setBalance( plancards[card].getBalance() - plancards[card].getCalculated_Payment() );

						// 6. If paid off this iteration (month), the plan must be recalculated
						if ( plancards[card].getBalance() <= 0 ) {
							
							one_card_paid_off = true;
							// DEBUG
							//writeoutput(plancards[card].label & " paid off with a final payment of " & plancards[card].calculated_payment & " on a balance of " & plancards[card].balance);

						}
						
						thisCardDetails["id"] = plancards[card].getCard_Id();
						thisCardDetails["title"] = 'Pay $' & DecimalFormat(plancards[card].getCalculated_Payment()) & ' to ' & JSStringFormat(plancards[card].getLabel());

						// TODO: Make this smart, rather than dumb 'divide by 2'. Iterate over the payments and determine the fairest (most equal) distribution across
						// multiple payments in a single month ( needed for TWICE A MONTH and EVER TWO WEEKS )					
						
						// PAY SCHEDULE
						if ( preferenceservice.getFrequency( arguments.user_id ) == 1 ) {
							
							// ONCE A MONTH
							thisCardDetails["start"] = DateFormat(nextDate,"ddd mmm dd yyyy") & " 00:00:00 GMT-0600";

						} else if ( preferenceservice.getFrequency( arguments.user_id ) == 2) {
							// TWICE A MONTH

							if ( cardCount > nonZeroCardCount / 2 )
								// 15th
								thisCardDetails["start"] = DateFormat(fifteenthOfMonth,"ddd mmm dd yyyy") & " 00:00:00 GMT-0600";
							else
								// 1st
								thisCardDetails["start"] = DateFormat(firstOfMonth,"ddd mmm dd yyyy") & " 00:00:00 GMT-0600";

						} else if ( preferenceservice.getFrequency( arguments.user_id ) == 3 ) {
							// EVERY TWO WEEKS

							
							if ( cardCount > nonZeroCardCount / 2 )
								// TWO WEEKS FROM NOW
								thisCardDetails["start"] = DateFormat(twoWeeksFromNow,"ddd mmm dd yyyy") & " 00:00:00 GMT-0600";
							else 
								// NOW
								thisCardDetails["start"] = DateFormat(nextDate,"ddd mmm dd yyyy") & " 00:00:00 GMT-0600";

						} else {

							// ONCE A month
							thisCardDetails["start"] = DateFormat(nextDate,"ddd mmm dd yyyy") & " 00:00:00 GMT-0600";

						}
						

						thisCardDetails["balance_remaining"] = plancards[card].getBalance();

						thisMonthBalance += plancards[card].getBalance();

						// append this card's payment details for the month in question
						arrayAppend( events, thisCardDetails );

					}
				}

			}

			total_balance = thisMonthBalance;

			// 2. Each iteration is one month. For each month:
			nextDate = DateAdd('m', 1, nextDate);

			// PC: DON'T LIKE THIS!!!
			if (one_card_paid_off == true) {

				one_card_paid_off = false;

				var supcards = duplicate( plancards );

				var newcards = calculatePayments( supcards, preferenceservice.getBudget( arguments.user_id ) );

				if ( StructIsEmpty( newcards ) ) {

					total_balance = 0;
					nonZeroCardCount = 0;

				} else {

					plancards = newcards;
					nonZeroCardCount = 0;
					for (card in plancards) {
			
						if ( IsObject(plancards[card]) && Replace( plancards[card].getBalance(), ",", "", "ALL" ) > 0 ) {
							nonZeroCardCount++;
						}
					}					
				
				}

				//writeoutput('ok');abort;

				//TODO: should I structdelete all cards with a balance of 0? or can they be ignored?
			}

			count++;

			//If (count eq 1) {writedump(events); abort;}
			// DEBUG 
			//writeoutput('iteration' & count);

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

		[{
			name: 'card1',
			data: [100, 88, 72, 69, 51, 48, 27, 12, 4, 0]
		},{
			name: 'card2',
			data: [100, 72, 59, 34, 18, 9, 0]
		}]

    	*/

    	var events = events( arguments.user_id );
    	var cards = list( arguments.user_id );
    	var milestones = arrayNew(1);

    	// cards is an object(struct)!
    	for (card in cards) {

    		var milestone = structNew();

    		milestone["name"] = JSStringFormat(cards[card].getLabel());
    		milestone["data"] = arrayNew(1);

    		// events is an array!
    		for (event in events) {

    			if ( event.id == cards[card].getCard_Id() && event.balance_remaining > 0 ) {

    				// append the remainig balance as a plottable point along the 
    				arrayAppend(milestone["data"], event.balance_remaining);

    			}

    		}

    		// add new milestones for this card
    		arrayAppend(milestones, milestone);

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
		//	 the is_emergency card set (and have a non-zero balance?) THEN SET 
		// ELSE
		// 	 get the first non-zero balance card with the highest interest rate and the lowest balance.

		for ( card in _searchCards ) {

			/* Determine "hot" card */
			// TODO: add in individual card priorities
			if ( IsObject(_searchcards[card]) && _searchcards[card].getIs_Emergency() eq 1 && _searchcards[card].getBalance() > 0 ) {
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

						return _searchCards[card];
					}

				}
			}

		}

		// I messed up somewhere, so return the first non-zero
		for ( card in _searchCards ) {

			if ( IsObject(_searchCards[card]) && _searchCards[card].getBalance() > 0) {

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

//		writeDump(hot_card);abort;

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

//			writeoutput(total_paid & "<br>");
		
		}

		var hot_paid = arguments.available_budget - total_paid;

//		writeoutput("precalc hot card payment: " & hot_card_calculated_payment & "<br>");
//		writeoutput("postcalcl hot card payment: " & hot_paid );abort;

		//StructInsert( _cards[hot_card.getCard_Id()], "calculated_payment", hot_paid, true ); //FIXME: WARNING, SHOULDN'T NEED TRUE HERE, BUT DOES. SOMETHING'S WRONG
		_cards[hot_card.getCard_Id()].setCalculated_Payment( hot_paid );

//		writeDump(_cards);abort;

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

}