component accessors=true {
		
	public any function init( beanFactory ) {

		variables.beanFactory = beanFactory;

		variables.defaultOptions = {
			datasource = 'dd'
		};

		return this;

	}

	public any function list( string id ) {

		var sql = '
			SELECT c.*
			FROM "pCards" c
			WHERE c.user_id = :uid
			ORDER BY c.card_id
		';

		var params = {
			uid = {
				value = arguments.id, sqltype = 'integer' 
			}
		};

		var card = {};
		var cards = {};

		var result = queryExecute(sql, params, variables.defaultOptions);

		for (i = 1; i lte result.recordcount; i++) {
			card = variables.beanFactory.getBean('cardBean');

			card.setCard_Id(result.card_id[i]);
			card.setUser_Id(result.user_id[i]);
			card.setLabel(result.card_label[i]);
			card.setMin_Payment(result.min_payment[i]);
			card.setIs_Emergency(result.is_emergency[i]);
			card.setBalance(result.balance[i]);
			card.setInterest_Rate(result.interest_rate[i]);

			cards[card.getCard_id()] = card;
		}

		return cards;

	}

	public any function get( string id ) {
		
		sql = '
			SELECT c.*
			FROM "pCards" c			
			WHERE c.card_id = :cid
		';

		params = {
			cid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute(sql, params, variables.defaultOptions);

		card = variables.beanFactory.getBean('cardBean');

		if (result.recordcount) {

			card.setCard_Id(result.card_id[1]);
			card.setUser_Id(result.user_id[1]);
			card.setLabel(result.card_label[1]);
			card.setMin_Payment(result.min_payment[1]);
			card.setIs_Emergency(result.is_emergency[1]);
			card.setBalance(result.balance[1]);
			card.setInterest_Rate(result.interest_rate[1]);

		}

		return card;

	}

	public any function save( struct card ) {

		param name="card.card_id" default=0;
		param name="card.user_id" default=0;
		param name="card.label" default="";
		param name="card.balance" default="";
		param name="card.interest_rate" default="";
		param name="card.min_payment" default="";
		param name="card.is_emergency" default=0;

		if ( card.card_id lte 0 ) {

			sql = '
				INSERT INTO "pCards" (
					user_id,
					card_label,
					min_payment,
					is_emergency,
					balance,
					interest_rate
				) VALUES (
					#card.user_id#,
					:label,
					#card.min_payment#,
					#card.is_emergency#,
					#card.balance#,
					#card.interest_rate#
				) RETURNING card_id AS card_id_out;			
			';

			params = {
				label = {
					value = card.label, sqltype = 'varchar'
				},
				psq = true
			};

			result = queryExecute( sql, params, variables.defaultOptions );

			return result.card_id_out;

		} else {

			sql = '
				UPDATE "pCards"
				SET 
					card_label = :label,
					min_payment = #card.min_payment#,
					balance = #card.balance#,
					interest_rate = #card.interest_rate#
				WHERE
					card_id = :cid;
			';

			params = {
				label = {
					value = card.label, sqltype = 'varchar'
				},
				cid = {
					value = card.card_id, sqltype = 'integer'
				},
				psq = true
			};

			result = queryExecute( sql, params, variables.defaultOptions );

			return card.card_id;

		}

	}

	public any function setAsEmergency( required string card_id, required string user_id ) {

		// blank out all the cards' emergency
		// then set the new one

		sql = '
			UPDATE "pCards"
			SET 
				is_emergency = 0
			WHERE 
				user_id = :uid;
			UPDATE "pCards"
			SET 
				is_emergency = 1
			WHERE 
				card_id = :cid;
		';

		params = {
			uid = {
				value = arguments.user_id, sqltype = 'integer'
			},
			cid = {
				value = arguments.card_id, sqltype = 'integer'
			}
		};

		result = queryExecute(sql, params, variables.defaultOptions);

		return arguments.card_id;	
	}

	public any function delete( required string card_id ) {

		sql = '
			DELETE FROM "pCards" c			
			WHERE c.card_id = :cid
		';

		params = {
			cid = {
				value = arguments.card_id, sqltype = 'integer'
			}
		};

		result = queryExecute(sql, params, variables.defaultOptions);

		return 0;		
	
	}

	/* **

	** */
		
	public query function qryGetNonZeroCardsByUser( string user_id, string include_list='', boolean prioritize_emergency=false ) {

		var i = 0;

		var sql = '
			SELECT c.*
			FROM "pCards" c
			WHERE c.user_id = :uid
			AND c.balance > 0
			';

		if ( Len( arguments.include_list ) ) {
			sql = sql & '
				AND c.card_id IN ( #arguments.include_list# )
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
				value = arguments.user_id, sqltype = 'integer' 
			}
		};

		var card = {};

		var result = queryExecute(sql, params, variables.defaultOptions);

		return result;

	}

	public any function getEmergencyCardByUser( string user_id ) {

		var sql = '
			SELECT c.*
			FROM "pCards" c
			WHERE c.user_id = :uid
			AND c.is_emergency = 1
		';

		var params = {
			uid = {
				value = arguments.user_id, sqltype = 'integer'
			}
		};

		var result = queryExecute(sql, params, variables.defaultOptions);

		var card = variables.beanFactory.getBean('cardBean');

		if (result.recordcount) {

			card.setCard_Id(result.card_id[1]);
			card.setUser_Id(result.user_id[1]);
			card.setLabel(result.card_label[1]);
			card.setMin_Payment(result.min_payment[1]);
			card.setIs_Emergency(result.is_emergency[1]);
			card.setBalance(result.balance[1]);
			card.setInterest_Rate(result.interest_rate[1]);

		}

		return card;
	}

	public string function dbGetCardIDs( struct cards, require_nonzero_balance=false ) {

		var res = '';
		var card = 0;

		for ( card in arguments.cards ) {

			if ( !arguments.require_nonzero_balance ) {
				res = ListAppend(res, arguments.cards[card].getCard_Id() );
			} else {
				if ( arguments.cards[card].getBalance() > 0 ) {
					res = ListAppend(res, arguments.cards[card].getCard_Id() );
				}
			}

		}

		return res;

	}

	public string function dbGetNonZeroCardIDs( struct cards ) {

		var res = dbGetCardIDs( arguments.cards, true );

		return res;

	}

	public numeric function dbCalculateTotalBalance( struct cards ) {

		var tot=0;

		for ( card in arguments.cards ) {
			tot += arguments.cards[card].getBalance();
		}

		return tot;

	}

	public numeric function dbCalculateTotalRemainingBalance( struct cards ) {

		var rtot=0;

		for ( card in arguments.cards ) {
			rtot += arguments.cards[card].getRemaining_Balance();
		}

		return rtot;

	}

}