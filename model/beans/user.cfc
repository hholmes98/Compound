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

  property stripe_customer_id;
  property stripe_subscription_id;

  function init( string user_id = 0, string name = "", string email = "", any role = "", any account_type = "", string passwordHash = "", string passwordSalt = "", any preferences="", string stripe_customer_id = "", string stripe_subscription_id = "" ) {

    variables.user_id = arguments.user_id;
    variables.name = arguments.name;
    variables.email = arguments.email;

    variables.role = arguments.role;

    if ( isObject( role ) ) {
        variables.role_id = arguments.role.getRole_Id();
    } else {
        variables.role_id = 3; // default role id is user (3 = user, 2 = mod, 1 = admin)
    }

    variables.account_type = arguments.account_type;

    // id:1 = Penny-Pincher (Free) - default
    // id:2 = Ad Blocker (2.99/mo)
    // id:3 = Budgeter (5.99/mo)
    // id:4 = Life Hacker (14.99/mo)

    if ( isObject( arguments.account_type ) ) {
      variables.account_type_id = arguments.account_type.getAccount_Type_Id();
      variables.account_type_name = arguments.account_type.getName()
    } else {
      variables.account_type_id = 1;
      variables.account_type_name = "Penny-Pincher (Free)";
    }

    variables.password_hash = arguments.passwordHash;
    variables.password_salt = arguments.passwordSalt;

    // new, let's attach the pref bean
    variables.preferences = arguments.preferences;

    // stripe
    variables.stripe_customer_id = arguments.stripe_customer_id;
    variables.stripe_subscription_id = arguments.stripe_subscription_id;

    return this;

  }

  function flatten() {

    var u_data = Duplicate(variables);

    return u_data;

  }

}