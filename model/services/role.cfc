// model/services/role
component accessors=true {

  function init( beanFactory ) {

    variables.beanFactory = beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  function get( id ) {

    var sql = '
      SELECT r.*
      FROM "pRoles" r
      WHERE r.role_id = :rid
    ';

    var params = {
      rid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var role = variables.beanFactory.getBean('roleBean');

    if ( result.recordcount ) {

      role.setRole_id( result.role_id[1] );
      role.setName( result.name[1] );

    }

    return role;

  }

  function list() {

    var sql = '
      SELECT r.*
      FROM "pRoles" r
      ORDER BY r.role_id ASC
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var roles = {};

    for ( var i = 1; i <= result.recordcount; i++ ) {

      var role = variables.beanFactory.getBean('roleBean');

      role.setRole_Id( result.role_id[i] );
      role.setName( result.name[i] );

      roles[role.getRole_id()] = role;

    }

    return roles;

  }

}