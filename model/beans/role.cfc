// model/beans/role
component accessors = true {

  property role_id;
  property name;

  function init( string role_id = 0, string name = "" ) {

    variables.role_id = role_id;
    variables.name = name;

    return this;

  }

}