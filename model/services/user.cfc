//model/services/user
component accessors=true {

  function init( roleService, account_typeService, preferenceService, mailService, beanFactory ) {

    variables.beanFactory = arguments.beanFactory;
    variables.roleService = arguments.roleService;
    variables.account_TypeService = arguments.account_TypeService;
    variables.mailService = arguments.mailService;
    variables.preferenceService = arguments.preferenceService;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  /******
    CRUD
  ******/

  /*
  list() = get all users
  */
  public any function list() {

    var sql = '
      SELECT 
        u.*, up.stripe_subscription_id, r.role_id, r.name AS role_name, at.account_type_id, at.name AS account_type_name
      FROM 
        "pUsers" u
      INNER JOIN "pUserRoles" ur ON (u.user_id = ur.user_id)
        INNER JOIN "pRoles" r ON (ur.role_id = r.role_id)
      INNER JOIN "pUserAccountTypes" uat ON (u.user_id = uat.user_id)
        INNER JOIN "pAccountTypes" at ON (uat.account_type_id = at.account_type_id)
      LEFT JOIN 
        "pUserPurchases" up ON
          u.user_id = up.user_id
      LEFT JOIN (
        SELECT
          last_updated
        FROM
          "pUserPurchases"
        GROUP BY
          last_updated
        ORDER BY
          last_updated DESC
        LIMIT 1
      ) AS upp ON
          upp.last_updated = up.last_updated
      ORDER BY u.user_id
    ';

    var params = {};
    var result = QueryExecute( sql, params, variables.defaultOptions );
    var users = {};

    for ( var i = 1; i <= result.recordCount; i++ ) {

      var user = variables.beanFactory.getBean('userBean');

      user.setUser_id(result.user_id[i]);
      user.setName(result.name[i]);
      user.setEmail(result.email[i]);

      user.setRole_id(result.role_id[i]);
      user.setRole(variables.roleService.get(user.getRole_id()));

      user.setAccount_Type_Id(result.account_type_id[i]);
      user.setAccount_Type(variables.account_TypeService.get(user.getAccount_Type_Id()));

      user.setPassword_Hash(result.password_hash[i]);
      user.setPassword_Salt(result.password_salt[i]);

      user.setStripe_Customer_Id( result.stripe_customer_id[i] );
      user.setStripe_Subscription_Id( result.stripe_subscription_id[i] );

      users[user.getUser_id()] = user;

    } // for

    return users;

  }

  /*
  get() = get a specific user by its primary key
  */
  public any function get( string id ) {

    var sql = '
      SELECT 
        u.*, up.stripe_subscription_id, r.role_id, r.name AS role_name, at.account_type_id, at.name AS account_type_name
      FROM 
        "pUsers" u
      INNER JOIN "pUserRoles" ur ON (u.user_id = ur.user_id)
        INNER JOIN "pRoles" r ON (ur.role_id = r.role_id)
      INNER JOIN "pUserAccountTypes" uat ON (u.user_id = uat.user_id)
        INNER JOIN "pAccountTypes" at ON (uat.account_type_id = at.account_type_id)
      LEFT JOIN 
        "pUserPurchases" up ON
          u.user_id = up.user_id
      LEFT JOIN (
        SELECT
          last_updated
        FROM
          "pUserPurchases"
        WHERE 
          user_id = :uid
        GROUP BY
          last_updated
        ORDER BY
          last_updated DESC
        LIMIT 1
      ) AS upp ON
          upp.last_updated = up.last_updated
      WHERE u.user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );
    var user = variables.beanFactory.getBean('userBean');

    if ( result.recordCount ) {

      user.setUser_Id(result.user_id[1]);
      user.setName(result.name[1]);
      user.setEmail(result.email[1]);

      user.setRole_Id(result.role_id[1]);
      user.setRole(variables.roleService.get(result.role_id[1]));

      user.setAccount_Type_Id(result.account_type_id[1]);
      user.setAccount_Type(variables.account_TypeService.get(result.account_type_id[1]));

      user.setPassword_Hash(result.password_hash[1]);
      user.setPassword_Salt(result.password_salt[1]);

      user.setStripe_Customer_Id( result.stripe_customer_id[1] );
      user.setStripe_Subscription_Id( result.stripe_subscription_id[1] );

      user.setPreferences(variables.preferenceService.get(user.getUser_Id()));

    }

    return user;

  }

  /*
  save() = save the contents of a single user
  */
  public any function save( any user ) {

    var sql = '';
    var params = '';
    var result = '';

    // if an update...
    if ( Len( arguments.user.user_id ) && arguments.user.user_id > 0 ) {

      sql = '
        UPDATE "pUsers"
        SET
          name = ''#arguments.user.name#'',
          email = ''#arguments.user.email#'',
          password_hash = ''#arguments.user.password_hash#'',
          password_salt = ''#arguments.user.password_salt#'',
          stripe_customer_id = ''#arguments.user.stripe_customer_id#''
        WHERE 
          user_id = :uid
      ';

      params = {
        uid = {
          value = arguments.user.user_id, sqltype = 'integer'
        },
        rid = {
          value = arguments.user.role_id, sqltype = 'integer'
        },
        atid = {
          value = arguments.user.account_type_id, sqltype = 'integer'
        }
      };

      result = QueryExecute( sql, params, variables.defaultOptions );

      sql = '
        UPDATE "pUserRoles"
        SET
          role_id = :rid
        WHERE
          user_id = :uid
      ';

      result = QueryExecute( sql, params, variables.defaultOptions );

      sql = '
        UPDATE "pUserAccountTypes"
        SET
          account_type_id = :atid
        WHERE
          user_id = :uid
      ';

      result = QueryExecute( sql, params, variables.defaultOptions );

    } else {

      // main table : pUsers
      sql = '
        INSERT INTO "pUsers"
        (
          name,
          email,
          password_hash,
          password_salt,
          stripe_customer_id
        )
        VALUES
        (
          ''#arguments.user.name#'',
          ''#arguments.user.email#'',
          ''#arguments.user.password_hash#'',
          ''#arguments.user.password_salt#'',
          ''#arguments.user.stripe_customer_id#''
        )
        RETURNING
          user_id AS pkey;
      ';

      params = {};

      result = QueryExecute( sql, params, variables.defaultOptions );

      arguments.user.user_id = result.pkey;

      // join - UserRoles
      sql = '
        INSERT INTO "pUserRoles"
        (
          user_id,
          role_id
        )
        VALUES
        (
          #arguments.user.user_id#,
          #arguments.user.role_id#
        )
      ';

      result = QueryExecute( sql, params, variables.defaultOptions );

      // join - UserPreferences
      preferenceService.create( user.user_id );

      // join - UserAccountTypes
      sql = '
        INSERT INTO "pUserAccountTypes"
        (
          user_id,
          account_type_id
        )
        VALUES
        (
          #arguments.user.user_id#,
          #arguments.user.account_type_id#
        )
      ';

      result = QueryExecute( sql, params, variables.defaultOptions );

    }

    return arguments.user.user_id;

  }

  /*
  delete() = delete a specfic user
  */
  public any function delete( string id ) {

    var sql = '';
    var params = '';
    var result = '';

    // same params for every query
    params = {
      uid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    // pUsers
    sql = '
      DELETE FROM "pUsers" u
      WHERE u.user_id = :uid
    ';

    result = QueryExecute( sql, params, variables.defaultOptions );

    // pUserRoles
    sql = '
      DELETE FROM "pUserRoles" ur
      WHERE ur.user_id = :uid
    ';

    var result = QueryExecute( sql, params, variables.defaultOptions );

    // pUserAccountTypes
    sql = '
      DELETE FROM "pUserAccountTypes" uat
      WHERE uat.user_id = :uid
    ';

    var result = QueryExecute( sql, params, variables.defaultOptions );

    // pUserPreferences
    sql = '
      DELETE FROM "pUserPreferences" up
      WHERE up.user_id = :uid
    ';

    result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;

  }

  /*
  purge() = delete all users (we won't do this!)
  */

  /*
  create() = create a new user
  */
  public any function create( string name, string email ) {

    // do user / pass prep
    var user = variables.beanFactory.getBean('userBean');

    user.setName( arguments.name );
    user.setEmail( arguments.email );

    // create a temp password that's rando
    var password = createTempPassword();
    var newPassword = hashPassword( password );

    user.setPassword_Hash( newPassword.hash );
    user.setPassword_Salt( newPassword.salt );

    // save the new user
    var newUser_id = save( user.flatten() ); // flatten until LUCEE bug fixed

    // now, for safety, let's do a nice clean get
    // we do this so that we have a central sql call to pull a user, rather
    // than risk duplicating code and increasing maintenance.
    var real_user = get( newUser_id );

    // kick off verification email
    variables.mailService.verifyUser( real_user.getEmail(), password ); // we pass in the plain-text password generated, this is the *only* time it is ever seen/displayed, never stored.

    // return user populated object
    return real_user;

  }

  /***************
   User Functions
  ****************/

  function getTemp() {

    // this is for temporary (anon) users' sessions, for playing with the site before they authenticate.
    var user = variables.beanFactory.getBean('userBean');

    user.setUser_Id( CreateUUID() );
    user.setName( "Guest" );

    return user;

  }

  function getByEmail( string email ) {

    var sql = '
      SELECT u.user_id
      FROM "pUsers" u
      WHERE u.email = :email
    ';

    var params = {
      email = {
        value = arguments.email, sqltype = 'varchar'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var user = variables.beanFactory.getBean('userBean');

    if ( result.recordCount ) {

      // we do this so that we have a central sql call to pull a user, rather
      // than risk duplicating code and increasing maintenance.
      user = get( result.user_id[1] );

    }

    return user;

  }

  /*
  security functions were adapted from Jason Dean's security series
  http://www.12robots.com/index.cfm/2008/5/13/A-Simple-Password-Strength-Function-Security-Series-4.1
  http://www.12robots.com/index.cfm/2008/5/29/Salting-and-Hashing-Code-Example--Security-Series-44
  http://www.12robots.com/index.cfm/2008/6/2/User-Login-with-Salted-and-Hashed-passwords--Security-Series-45
  */

  function hashPassword( string password ) {

    var returnVar = {};

    returnVar.salt = CreateUUID();
    returnVar.hash = Hash( arguments.password & returnVar.salt, "SHA-512" );

    return returnVar;

  }

  function validatePassword( any user, string password ) {

    // catenate password and user salt to generate hash
    var inputHash = Hash( Trim( arguments.password ) & Trim( arguments.user.password_salt ), "SHA-512" );

    // password is valid if hash matches existing user hash
    return !Compare( inputHash, arguments.user.password_hash );

  }

  function checkPassword( any user, string new_password = "" ) {

    // Initialize return variable
    var aErrors = ArrayNew(1);
    var entropyCount = 0;

    // https://xato.net/10-000-top-passwords-6d6380716fe0 - disallowed passwords
    // FIXME: make this a config string to pass in.
    var disallowed_pass = ['password','123456','12345678','1234','pussy','12345','qwerty','dragon','696969','mustang','baseball','football','letmein','pass123','password123'];

    // too short or too long
    if ( Len( arguments.new_password ) < 2 || Len( arguments.new_password ) > 60 ) {
      ArrayAppend( aErrors, "Your password must be longer than 2 characters and shortern than 60 characters." );
    }

    // too guessable via top ten (above)
    for ( var a=1; a < ArrayLen( disallowed_pass ); a++ ) {
      if ( !CompareNoCase( arguments.new_password, disallowed_pass[a] ) ) {
        ArrayAppend( aErrors, "The password you chose was not allowed (too guessable)." );
      }
    }

    for ( var b=1; b < Len( arguments.new_password ); b++ ) {

      // get the char
      var char = Mid( arguments.new_password, b, 1 );

      if ( b > 1 ) {
        var last_char = Mid( arguments.new_password, b-1, 1 );

        if ( char == last_char ) {
          entropyCount++;
        }

      }

    }

    // check for basic entropy
    if ( entropyCount > 3 ) {
      ArrayAppend( aErrors, "The password uses too many matching characters in succession (avoid 'aaaabbbbcccc')." );
    }

    // Check to see if the password contains the email
    if ( Len( arguments.user.email ) && arguments.new_password CONTAINS arguments.user.email )
      ArrayAppend( aErrors, "Your password cannot contain your email address.");

    // Check to see if the password contains the Nickname
    if ( Len( arguments.user.name ) && arguments.new_password CONTAINS arguments.user.name )
      ArrayAppend( aErrors, "Your password cannot contain your account name (nickname).");

    // Check to see if password is a date
    if ( IsDate( arguments.new_password ) )
      ArrayAppend( aErrors, "Your password cannot be a date.");

    return aErrors;

  }

  function createTempPassword() {

    var tmpPass = ArrayNew(1);

    for ( var i=1; i < 6; i++ ) {

      var e = RandRange(1,2);

      if (e == 1) {
        ArrayAppend( tmpPass, Chr( RandRange( 48, 57 ) ) ); // 0-9
      } else {
        ArrayAppend( tmpPass, Chr( RandRange( 65, 90) ) ); // A-Z
      }

    }

    return ArrayToList( tmpPass, "" );

  }

  /* cflib.org */
  /**
  * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).
  * Update by David Kearns to support '
  * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.
  * Should support + gmail style addresses now.
  * More TLDs
  * Version 4 by P Farrel, supports limits on u/h
  * Added mobi
  * v6 more tlds
  *
  * @param str      The string to check. (Required)
  * @return Returns a boolean.
  * @author Jeff Guillaume (SBrown@xacting.comjeff@kazoomis.com)
  * @version 7, May 8, 2009
  */
  function isEmail(str) {
    return REFindNoCase("^['_a-z0-9-\+]+(\.['_a-z0-9-\+]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|asia|biz|cat|coop|info|museum|name|jobs|post|pro|tel|travel|mobi))$",str) &&
        Len( ListFirst(arguments.str, "@") ) <= 64 &&
        Len( ListRest(arguments.str, "@") ) <= 255;
  }

}