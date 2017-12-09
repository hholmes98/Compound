//event.cfc
component accessors=true {

	public any function saveEvents( struct cards ) {

		var i=0;
		var sql=0;
		var result=0;
		var params={};

		sql = '
			INSERT INTO "pEvents" (
				card_id,				
				card_label,
				balance,
				min_payment,
				interest_rate,
				is_hot,
				is_emergency,
				calculated_payment,
				pay_date,
				user_id
			) VALUES
		';

		for ( card in arguments.cards ) {
			sql = sql & '(
				#arguments.cards.getCard_id()#,
				''#arguments.cards.getCard_label()#'',
				#arguments.cards.getBalance()#,
				#arguments.cards.getMin_payment()#,
				#arguments.cards.getInterest_rate()#,
				#arguments.cards.getIs_hot()#,
				#arguments.cards.getIs_emergency()#,
				#arguments.cards.getCalculated_payment()#,
				#arguments.cards.getPay_date()#,
				#arguments.cards.getUser_id()#
			)';

			sql = sql & ',';
		}

		sql = Left( sql, Len(sql)-1 ); // trim trailing comma off
		sql = sql & ';'; 			// add a semi-colon to the end

		result = queryExecute( sql, params, variables.defaultOptions );

		return 0;
	}

	public any function dbSaveEvents( query plan ) {

		var i=0;
		var sql=0;
		var result=0;
		var params={};

		sql = '
			INSERT INTO "pEvents" (
				card_id,				
				card_label,
				balance,
				min_payment,
				interest_rate,
				is_hot,
				is_emergency,
				calculated_payment,
				pay_date,
				user_id
			) VALUES
		';

		for (i=1; i <= arguments.plan.recordcount; i++) {
			sql = sql & '(
				#arguments.plan.card_id[i]#,
				''#arguments.plan.card_label[i]#'',
				#arguments.plan.balance[i]#,
				#arguments.plan.min_payment[i]#,
				#arguments.plan.interest_rate[i]#,
				#arguments.plan.is_hot[i]#,
				#arguments.plan.is_emergency[i]#,
				#arguments.plan.calculated_payment[i]#,
				#arguments.plan.pay_date[i]#,
				#arguments.plan.user_id[i]#
			)';

			if (i < arguments.plan.recordcount) {
				sql = sql & ',';
			} 
		}

		sql = sql & ';';

		result = queryExecute( sql, params, variables.defaultOptions );

		return 0;
	}

}