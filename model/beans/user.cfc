// model/beans/user
component accessors=true {

  property user_id;
  property name;
  property email;

  property role;
  property role_id;

  property account_type; 
  property account_type_id;
  property account_type_name;

  property password_hash;
  property password_salt;

  property preferences;

  function init( string user_id = 0, string name = "", string email = "", any role = "", any account_type = "", string passwordHash = "", string passwordSalt = "", any preferences="" ) {

    variables.user_id = user_id;
    variables.name = name;
    variables.email = email;

    variables.role = role;

    if ( isObject( role ) ) {
        variables.role_id = role.getRole_Id();
    } else {
        variables.role_id = 3; // default role id is user (3 = user, 2 = mod, 1 = admin)
    }

    variables.account_type = account_type;

    if ( isObject( account_type ) ) {
      variables.account_type_id = account_type.getAccount_Type_Id();
      variables.account_type_name = account_type.getName()
    } else {
      variables.account_type_id = 1; // default account_type is free (1=free, 2=basic, 3=advanced)
      variables.account_type_name = "Free";
    }

    variables.password_hash = passwordHash;
    variables.password_salt = passwordSalt;

    // new, let's attach the pref bean
    variables.preferences = preferences;

    return this;

  }

  function flatten() {

    var u_data = Duplicate(variables);

    return u_data;

  }

}