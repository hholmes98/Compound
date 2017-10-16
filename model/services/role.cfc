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
			SELECT r.*
			FROM "pRoles" r
			WHERE r.role_id = :rid
		';

		params = {
			rid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute( sql, params, variables.defaultOptions );

		role = variables.beanFactory.getBean('roleBean');

		if (result.recordcount) {
		
			role.setRole_id( result.role_id[1] );
			role.setName( result.name[1] );
		
		}

		return role;
	}
	
	function list() {
		
		user = {};

		sql = '
			SELECT r.*
			FROM "pRoles" r
			ORDER BY r.role_id ASC
		';

		params = {};

		result = queryExecute( sql, params, variables.defaultOptions );

		roles = {};

		for ( i = 1; i lte result.recordcount; i++ ) {
			role = variables.beanFactory.getBean('roleBean');
			
			role.setRole_Id( result.role_id[i] );
			role.setName( result.name[i] );

			roles[role.getRole_id()] = role;
		}

		return roles;
    }
	
}