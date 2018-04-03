// model/services/preference
component accessors=true  {

  public any function init( beanFactory ) {

    variables.beanFactory = beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  public any function get( id ) {

    var sql = '
      SELECT up.*
      FROM "pUserPreferences" up
      WHERE up.user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var preference = variables.beanFactory.getBean('preferenceBean');

    if ( result.recordcount ) {

      preference.setUser_Id( result.user_id[1] );
      preference.setBudget( Replace( DecimalFormat( result.budget[1] ),",","","ALL" ) );
      preference.setPay_Frequency( result.pay_frequency[1] );
      preference.setEmail_Reminders( result.email_reminders[1] );
      preference.setEmail_Frequency( result.email_frequency[1] );

    }

    return preference;

  }

  public struct function flatten( any pref ) {

    var p_data = StructNew();

    p_data.user_id = pref.getUser_Id();
    p_data.budget = pref.getBudget();
    p_data.pay_frequency = pref.getPay_Frequency();
    p_data.email_reminders = pref.getEmail_Reminders();
    p_data.email_frequency = pref.getEmail_Frequency();

    return p_data;

  }

  public any function save( struct preference ) {

    var f_bud = Replace( preference.budget, ",","","ALL" );

    var sql = '
      UPDATE "pUserPreferences"
      SET
        budget = :bud,
        pay_frequency = :pay_freq,
        email_reminders = :email_rem,
        email_frequency = :email_freq
      WHERE
        user_id = :uid
    ';

    var params = {
      uid = {
        value = preference.user_id, sqltype = 'integer'
      },
      bud = {
        value = f_bud, sqltype = 'decimal'
      },
      pay_freq = {
        value = preference.pay_frequency, sqltype = 'integer'
      },
      email_rem = {
        value = preference.email_reminders, sqltype = 'integer'
      },
      email_freq = {
        value = preference.email_frequency, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if you throw an error

  }

}