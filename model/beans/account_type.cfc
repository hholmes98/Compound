//model/beans/account_type
component accessors=true {

  property account_type_id;
  property name;

  function init( string account_type_id = 0, string name = "" ) {

    variables.account_type_id = account_type_id;
    variables.name = name;

    return this;

  }

  function flatten() {
    return variables;
  }

}