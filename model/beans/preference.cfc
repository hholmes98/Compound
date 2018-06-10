// model/beans/preference
component accessors=true {

  property user_id;
  property budget;
  property pay_frequency;
  property email_reminders;
  property email_frequency;
  property theme;

  function init( string user_id = 0, string budget = "", string pay_frequency = "", string email_reminders = "", string email_frequency = "", string theme = "" ) {

    variables.user_id = user_id;
    variables.budget = budget;
    variables.pay_frequency = pay_frequency;
    variables.email_reminders = email_reminders;
    variables.email_frequency = email_frequency;
    variables.theme = theme;

    return this;

  }

  // workaround until this bug is fixed: https://luceeserver.atlassian.net/browse/LDEV-1789?inbox=true
  public struct function flatten() {

    var p_data = Duplicate(variables);

    return p_data;

  }

}