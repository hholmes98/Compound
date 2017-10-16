component accessors=true  {
		
	public any function init( beanFactory ) {

		variables.beanFactory = beanFactory;

		variables.defaultOptions = {
			datasource = 'dd'
		};
		
		return this;

	}

	/*
	public any function list( ) {

		var ret = structCopy( variables.data.cards );

		ret['keylist'] = structKeyArray( variables.data.cards );
		arraySort( ret['keylist'], "numeric", "desc" );
		
		return variables.data.cards;
	
	}
	*/

	public any function get( id ) {

		sql = '
			SELECT up.*
			FROM "pUserPreferences" up
			WHERE up.user_id = :uid
		';

		params = {
			uid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute( sql, params, variables.defaultOptions );

		preference = variables.beanFactory.getBean('preferenceBean');

		if ( result.recordcount ) {
		
			preference.setUser_id( result.user_id[1] );
			preference.setBudget( result.budget[1] );
			preference.setPay_Frequency( result.pay_frequency[1] );
		
		}

		return preference;

	}

	public any function setBudget( required string val, required string id ) {
					
		var sql = '
			UPDATE "pUserPreferences"
			SET 
				budget = :bval
			WHERE 
				user_id = :uid
			RETURNING 
				budget AS budget_out;
		';

		var params = {
			bval = {
				value = arguments.val, sqltype = 'numeric'
			},
			uid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		var result = queryExecute( sql, params, variables.defaultOptions );

		return result.budget_out;
	}

	public any function setFrequency( required string val, required string id ) {

		sql = '
			UPDATE "pUserPreferences"
			SET 
				pay_frequency = :pfval
			WHERE 
				user_id = :uid
			RETURNING
				pay_frequency AS pay_frequency_out
		';

		params = {
			uid = {
				value = arguments.id, sqltype = 'integer'
			},
			pfval = {
				value = arguments.val, sqltype = 'integer'
			}
		};

		result = queryExecute( sql, params, variables.defaultOptions );

		return result.pay_frequency_out;	
	}

	public string function getBudget( required string id ) {

		sql = '
			SELECT up.budget
			FROM "pUserPreferences" up
			WHERE up.user_id = :uid
		';

		params = {
			uid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute( sql, params, variables.defaultOptions );

		if (result.recordcount) {
		
			return result.budget[1];
		
		} else {

			-1;

		}
			
	}

	public string function getFrequency( required string id ) {

		sql = '
			SELECT up.pay_frequency
			FROM "pUserPreferences" up
			WHERE up.user_id = :uid
		';

		params = {
			uid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute( sql, params, variables.defaultOptions );

		if (result.recordcount) {
		
			return result.pay_frequency[1];
		
		} else {

			-1;

		}

	}	
		
}
