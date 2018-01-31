//role.cfc
component accessors=true {
	
	function init( beanFactory ) {

        variables.beanFactory = beanFactory;

		variables.defaultOptions = {
			datasource = 'dd'
		};
		
		return this;
	}
	
	function get( id ) {
		
		sql = '
			SELECT at.*
			FROM "pAccountTypes" at
			WHERE at.account_type_id = :rid
		';

		params = {
			rid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute( sql, params, variables.defaultOptions );

		account_type = variables.beanFactory.getBean('account_TypeBean');

		if (result.recordcount) {
		
			account_type.setAccount_Type_id( result.account_type_id[1] );
			account_type.setName( result.name[1] );
		
		}

		return account_type;
	}
	
	function list() {
		
		user = {};

		sql = '
			SELECT at.*
			FROM "pAccountTypes" at
			ORDER BY at.account_type_id ASC
		';

		params = {};

		result = queryExecute( sql, params, variables.defaultOptions );

		account_types = {};

		for ( i = 1; i lte result.recordcount; i++ ) {
			account_type = variables.beanFactory.getBean('account_TypeBean');
			
			account_type.setAccount_Type_Id( result.account_type_id[i] );
			account_type.setName( result.name[i] );

			account_types[account_type.getAccountType_id()] = account_type;
		}

		return account_types;
    }
	
}