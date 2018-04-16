// model/beans/preference
component accessors = true invokeImplicitAccessor=true {

  property user_id;
  property budget;
  property pay_frequency;
  property email_reminders;
  property email_frequency;

  function init( string user_id = 0, string budget = 0, string pay_frequency = 0, string email_reminders = 0, string email_frequency = 0 ) {

    variables.user_id = user_id;
    variables.budget = budget;
    variables.pay_frequency = pay_frequency;
    variables.email_reminders = email_reminders;
    variables.email_frequency = email_frequency;

    return this;

  }

}