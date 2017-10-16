component accessors=true {
		
	public any function init( beanFactory ) {

		/* PC: this was the original line that was /examples/cards/assets/todo.json that required a url-mapping
		in tomcat for. Beware! this may be something that must be adjusted/mapped for in the future. */
		//variables.ddFile = expandPath( "/assets/dd-dataset.json" ); 

		//variables.data = deserializeJSON( fileRead( variables.ddFile ) );

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

		/*
		var ret = structCopy( variables.data.cards );

		ret['keylist'] = structKeyArray( variables.data.cards );
		arraySort( ret['keylist'], "numeric", "desc" );
		
		return variables.data.cards;
		*/
	
	}

	public any function get( string id ) {
		
		/*       		
		if ( structKeyExists( variables.data.cards, arguments.id ) ) {
			return variables.data.cards[ arguments.id ];
		} else
			return 0;
		*/

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

		/*
		for (card in variables.data.cards) {
			variables.data.cards[card]["is_emergency"] = 0;
		}
						
		variables.data.cards[arguments.id]["is_emergency"] = 1;		
		
		FileWrite( variables.ddFile, serializeJson( variables.data ) );
		
		return variables.data.cards[id];
		

		sql = '
			SELECT u.user_id
			FROM "pUsers" u
			INNER JOIN "pCards" c ON
				u.user_id = c.user_id
			WHERE c.card_id = :cid
		';

		params = {
			cid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExceute(sql, params, variables.defaultOptions);

		var user_id = result.user_id[1];
		*/

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

		/*
		structDelete(variables.data.cards, id);		

		FileWrite( variables.ddFile, serializeJson( variables.data ) );		
		
		return variables.data.cards;
		*/

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
		
}
