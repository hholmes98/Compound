// model/services/preference
component accessors=true {

  public any function init( beanFactory ) {

    variables.beanFactory = arguments.beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  /******
    CRUD
  ******/

  /*
  list() = get all preferences
  */

  // unused

  /*
  get() = get a specific set of preferences (for its user)
  */
  public any function get( string id ) {

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
      preference.setBudget( Replace( DecimalFormat( result.budget[1] ),",","","ALL" ) ); // why is this here?
      preference.setPay_Frequency( result.pay_frequency[1] );
      preference.setEmail_Reminders( result.email_reminders[1] );
      preference.setEmail_Frequency( result.email_frequency[1] );
      preference.setTheme( result.theme[1] );

    }

    return preference;

  }

  /*
  save() = save the preferences of a single user
  */

  public any function save( any preference ) {

    var f_bud = Replace( arguments.preference.getBudget(), ",","","ALL" );

    // setting your payment frequency to 'it's complicated' forces the email_frequency to once a month (1)
    if ( arguments.preference.getPay_Frequency() == 0 ) {
      if ( arguments.preference.getEmail_Frequency() > 1 ) // we'll leave 0 and 1 alone.
        arguments.preference.setEmail_Frequency(1);
    }

    var sql = '
      UPDATE "pUserPreferences"
      SET
        budget = :bud,
        pay_frequency = :pay_freq,
        email_reminders = :email_rem,
        email_frequency = :email_freq,
        theme = :skin_id
      WHERE
        user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.preference.getUser_Id(), sqltype = 'integer'
      },
      bud = {
        value = f_bud, sqltype = 'decimal'
      },
      pay_freq = {
        value = arguments.preference.getPay_Frequency(), sqltype = 'integer'
      },
      email_rem = {
        value = arguments.preference.getEmail_Reminders(), sqltype = 'integer'
      },
      email_freq = {
        value = arguments.preference.getEmail_Frequency(), sqltype = 'integer'
      },
      skin_id = {
        value = arguments.preference.getTheme(), sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return arguments.preference.getUser_Id(); // -1 if you throw an error

  }

  /*
  delete() = delete preferences for a user
  */

  // unused

  /*
  purge() = delete all preferences (we won't do this!)
  */

  // unused

  /*
  create() = create a new set of user preferences
  */

  public any function create( string user_id ) {

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var sql = '
      INSERT INTO "pUserPreferences"
      (
        user_id
      )
      VALUES
      (
        :uid
      )
    ';

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var preferences = get( arguments.user_id );

    return preferences;

  }

  /*******************
  Preference Functions
  *******************/

  // needed until this bug is fixed: https://luceeserver.atlassian.net/browse/LDEV-1789
  public struct function flatten( any pref ) {

    var p_data = StructNew();

    p_data.user_id = arguments.pref.getUser_Id();
    p_data.budget = arguments.pref.getBudget();
    p_data.pay_frequency = arguments.pref.getPay_Frequency();
    p_data.email_reminders = arguments.pref.getEmail_Reminders();
    p_data.email_frequency = arguments.pref.getEmail_Frequency();
    p_data.theme = arguments.pref.getTheme();

    return p_data;

  }

}