// model/services/account_type
component accessors = true {

  function init( beanFactory ) {

    variables.beanFactory = arguments.beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  function list() {

    var sql = '
      SELECT at.*
      FROM "pAccountTypes" at
      ORDER BY at.account_type_id ASC
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var account_types = {};

    for ( var i = 1; i <= result.recordcount; i++ ) {
      var account_type = variables.beanFactory.getBean('account_TypeBean');

      account_type.setAccount_Type_Id( result.account_type_id[i] );
      account_type.setName( result.name[i] );

      account_types[account_type.getAccountType_id()] = account_type;
    }

    return account_types;
  }

  function get( id ) {

    var sql = '
      SELECT at.*
      FROM "pAccountTypes" at
      WHERE at.account_type_id = :atid
    ';

    var params = {
      atid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var account_type = variables.beanFactory.getBean('account_TypeBean');

    if ( result.recordcount ) {

      account_type.setAccount_Type_Id( result.account_type_id[1] );
      account_type.setName( result.name[1] );

    }

    return account_type;

  }

}