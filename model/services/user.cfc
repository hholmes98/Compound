component accessors=true {

    function init( roleService, account_typeService, mailService, beanFactory  ) {
      variables.beanFactory = beanFactory;

      variables.roleService = roleService;
      variables.account_TypeService = account_TypeService;
      variables.mailService = mailService;

      variables.defaultOptions = {
        datasource = 'dd'
      };

      return this;

    }

    function delete( string id ) {

        sql = '
			DELETE FROM "pUsers" u
			WHERE u.user_id = :uid
		';

		params = {
			uid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute(sql, params, variables.defaultOptions);

		sql = '
			DELETE FROM "pUserRoles" ur
			WHERE ur.user_id = :uid
		';

		result = queryExecute(sql, params, variables.defaultOptions);

		return result;
    }

    function get( string id ) {

        sql = '
			SELECT u.*, r.role_id, r.name AS role_name, at.account_type_id, at.name AS account_type_name
			FROM "pUsers" u
			INNER JOIN "pUserRoles" ur ON (u.user_id = ur.user_id)
				INNER JOIN "pRoles" r ON (ur.role_id = r.role_id)
			INNER JOIN "pUserAccountTypes" uat ON (u.user_id = uat.user_id)
				INNER JOIN "pAccountTypes" at ON (uat.account_type_id = at.account_type_id)
			WHERE u.user_id = :uid
		';

		params = {
			uid = {
				value = arguments.id, sqltype = 'integer'
			}
		};

		result = queryExecute(sql, params, variables.defaultOptions);

		user = variables.beanFactory.getBean('userBean');

		if (result.recordcount) {
		
			user.setUser_Id(result.user_id[1]);
			user.setName(result.name[1]);
			user.setEmail(result.email[1]);

			user.setRole_Id(result.role_id[1]);
			user.setRole(variables.roleService.get(user.getRole_Id()));

			user.setAccount_Type_Id(result.account_type_id[1]);
			user.setAccount_Type(variables.account_TypeService.get(user.getAccount_Type_Id()));

			user.setPassword_Hash(result.password_hash[1]);
			user.setPassword_Salt(result.password_salt[1]);
		
		}

		return user;
    }

    function getTemp() {

		var user = variables.beanFactory.getBean('userBean');

		user.setUser_Id(CreateUUID());
		user.setName("Guest");

		return user;

    }

	function getByEmail( string email ) {
        
		sql = '
			SELECT u.user_id
			FROM "pUsers" u
			WHERE u.email = :email
		';

		params = {
			email = {
				value = arguments.email, sqltype = 'varchar'
			}
		};

		result = queryExecute(sql, params, variables.defaultOptions);

		user = variables.beanFactory.getBean('userBean');

		if (result.recordcount) {

			// we do this so that we have a central sql call to pull a user, rather
			// than risk duplicating code and increasing maintenance.
			user = get(result.user_id[1]);
		
		}

		return user;

    }    

    function list() {

        user = {};

		sql = '
			SELECT u.*, r.role_id, r.name AS role_name, at.account_type_id, at.name AS account_type_name
			FROM "pUsers" u
			INNER JOIN "pUserRoles" ur ON (u.user_id = ur.user_id)
				INNER JOIN "pRoles" r ON (ur.role_id = r.role_id)
			INNER JOIN "pUserAccountTypes" uat ON (u.user_id = uat.user_id)
				INNER JOIN "pAccountTypes" at ON (uat.account_type_id = at.account_type_id)
			ORDER BY u.user_id
		';

		params = {};

		result = queryExecute(sql, params, variables.defaultOptions);

		users = {};

		for (i = 1; i lte result.recordcount; i++) {
			user = variables.beanFactory.getBean('userBean');
			
			user.setUser_id(result.user_id[i]);
			user.setName(result.name[i]);
			user.setEmail(result.email[i]);
			user.setRole_id(result.role_id[i]);
			user.setRole(variables.roleService.get(user.getRole_id()));
			user.setAccount_Type_Id(result.account_type_id[i]);
			user.setAccount_Type(variables.account_TypeService.get(user.getAccount_Type_Id()));

			users[user.getUser_id()] = user;
		}

		return users;

    }

    /* get into the habit of **not** returning anything from a save - get() is the central point-of-truth for an object */
    function save( user ) {

        if ( len( user.getUser_Id() ) && user.getUser_Id() GT 0 ) {

        	//transaction {

        	//	try {
	        
			        sql = '
						UPDATE "pUsers"
						SET
							name = ''#user.getName()#'',
							email = ''#user.getEmail()#'',
							password_hash = ''#user.getPassword_Hash()#'',
							password_salt = ''#user.getPassword_Salt()#''
						WHERE 
							user_id = :uid
					';

					params = {
						uid = {
							value = user.getUser_id(), sqltype = 'integer'
						},
						rid = {
							value = user.getRole_id(), sqltype = 'integer'
						},
						atid = {
							value = user.getAccount_Type_Id(), sqltype = 'integer'
						}
					};

					result = queryExecute(sql, params, variables.defaultOptions);

					sql = '
						UPDATE "pUserRoles"
						SET
							role_id = :rid
						WHERE
							user_id = :uid
					';

					result = queryExecute(sql, params, variables.defaultOptions);

					sql = '
						UPDATE "pUserAccountTypes"
						SET
							account_type_id = :atid
						WHERE
							user_id = :uid
					';

					result = queryExecute(sql, params, variables.defaultOptions);

//					transaction action="commit";

//				} 

//				catch(any e) {

					//transaction action="rollback";
//					rethrow(e);

				//}

			//}

        } else {

//        	transaction {

        		//try {

		 			sql = '
						INSERT INTO "pUsers"
						(
							name,
							email,
							password_hash,
							password_salt
						)
						VALUES
						(
							''#user.getName()#'',
							''#user.getEmail()#'',
							''#user.getPassword_Hash()#'',
							''#user.getPassword_Salt()#''
						)
						RETURNING
							user_id AS pkey;
					';

					params = {};

					result = queryExecute(sql, params, variables.defaultOptions);

					user.setUser_Id( result.pkey );

					sql = '
						INSERT INTO "pUserRoles"
						(
							user_id,
							role_id
						)
						VALUES
						(
							#user.getUser_id()#,
							#user.getRole_id()#
						)
					';

					result = queryExecute(sql, params, variables.defaultOptions);

					sql = '
						INSERT INTO "pUserPreferences"
						(
							user_id
						)
						VALUES
						(
							#user.getUser_id()#
						)
					';

					params = {};

					result = queryExecute(sql, params, variables.defaultOptions);

					sql = '
						INSERT INTO "pUserAccountTypes"
						(
							user_id,
							account_type_id
						)
						VALUES
						(
							#user.getUser_id()#,
							#user.getAccount_Type_Id()#
						)
					';

					params = {};

					result = queryExecute(sql, params, variables.defaultOptions);

//					transaction action="commit";

				//}

//				catch (any e) {

					//transaction action="rollback";
//					rethrow(e);

				//}

			//}

        }

        return user;
    }

    function createUser( string name, string email ) {

    	// do user / pass prep
    	var user = variables.beanFactory.getBean('userBean');
    	
    	user.setName( arguments.name );
    	user.setEmail( arguments.email );

    	// create a temp password that's rando
        var password = createTempPassword();
        var newPassword = hashPassword( password );
        
        user.setPassword_Hash(newPassword.hash);
        user.setPassword_Salt(newPassword.salt);

        // save the new user
        newUser = save( user );

		// now, for safety, let's do a nice clean get
		// we do this so that we have a central sql call to pull a user, rather
		// than risk duplicating code and increasing maintenance.
		real_user = get( newUser.getUser_Id() );

    	// kick off verification email
        variables.mailService.verifyUser( real_user.getEmail(), password ); // we pass in the plain-text password generated, this is the *only* time it is ever seen/displayed, never stored.

    	// return user populated object
    	return real_user;
    }

    function createTempPassword() {

    	var tmpPass = ArrayNew(1);

    	for ( var i=1; i < 6; i++ ) {

    		var e = RandRange(1,2);

    		if (e == 1) {
    			ArrayAppend(tmpPass, Chr(RandRange(48,57))); // 0-9
    		} else {
    			ArrayAppend(tmpPass, Chr(RandRange(65,90))); // A-Z
    		}

    	}

    	return ArrayToList(tmpPass,"");

    }

	function validate( any user, string firstName = "", string lastName = "", string email = "",
                       string role_id = "", string password = "" ) {
        
        var aErrors = [ ];
        var userByEmail = getByEmail( email );
        var role = variables.roleService.get( role_id );

        // validate password for new or existing user
        /*
        if ( !user.getUser_Id() && !len( password ) ) {
            arrayAppend( aErrors, "Please enter a password for the user" );
        } else if ( len( password ) ) {
            aErrors = checkPassword( user = user, newPassword = password, retypePassword = password );
        }
        */
        
        // validate name
        if ( !len( user.getName() ) && !len( name ) ) {
            arrayAppend( aErrors, "Please enter the user's name" );
        }
        
        // validate email address
        if ( !len( user.getEmail() ) && !len( email ) ) {
            arrayAppend( aErrors, "Please enter the user's email address" );
        } else if ( len( email ) && !isEmail( email ) ) {
            arrayAppend( aErrors, "Please enter a valid email address" );
        } else if ( !user.getUser_Id() && len( email ) && !compare( email, userByEmail.getEmail() ) ) {
            arrayAppend( aErrors, "A user already exists with this email address, please enter a new address." );
        }
        
        // validate role ID
        if ( !len( role_id ) || !isNumeric( role_id ) || !role.getRole_Id() ) {
            arrayAppend( aErrors, "Please select a role" );
        }

        return aErrors;
    }

	/*
	security functions were adapted from Jason Dean's security series
	http://www.12robots.com/index.cfm/2008/5/13/A-Simple-Password-Strength-Function-Security-Series-4.1
	http://www.12robots.com/index.cfm/2008/5/29/Salting-and-Hashing-Code-Example--Security-Series-44
	http://www.12robots.com/index.cfm/2008/6/2/User-Login-with-Salted-and-Hashed-passwords--Security-Series-45
	*/

    function hashPassword( string password ) {

        var returnVar = {};

        returnVar.salt = createUUID();
        returnVar.hash = hash( password & returnVar.salt, "SHA-512" );

        return returnVar;
    }

    function validatePassword( any user, string password ) {

        // catenate password and user salt to generate hash
        var inputHash = hash( trim( password ) & trim( user.getPassword_Salt() ), "SHA-512" );

        // password is valid if hash matches existing user hash
        return !compare( inputHash, user.getPassword_Hash() );
    }

    function checkPassword( any user, string new_password = "" ) {

		// Initialize return variable
		var aErrors = ArrayNew(1);
		var inputHash = '';
		var count = 0;
		var entropyCount = 0;

		// https://xato.net/10-000-top-passwords-6d6380716fe0 - disallowed passwords
		var disallowed_pass = ['password','123456','12345678','1234','pussy','12345','qwerty','dragon','696969','mustang','baseball','football','letmein','pass123','password123'];

		// too short or too long
		if ( Len(new_password) < 2 OR Len(new_password) > 60 ) {
			ArrayAppend( aErrors, "Your password must be longer than 2 characters and shortern than 60 characters." );
		}

		// too guessable via top ten (above)
		for (var a=1; a < ArrayLen(disallowed_pass); a++) {
			if ( !CompareNoCase(new_password,disallowed_pass[a]) ) {
				ArrayAppend( aErrors, "The password you chose was not allowed (too guessable)." );
			}
		}

		for ( var b=1; b < Len(new_password); b++ ) {
			
			// get the char
			var char = Mid(new_password,b,1);

			if ( b > 1 ) {
				var last_char = Mid(new_password,b-1,1);

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
		if ( Len(session.auth.user.getEmail() ) and arguments.new_password CONTAINS user.getEmail() )
			ArrayAppend( aErrors, "Your password cannot contain your email address.");

		// Check to see if the password contains the Nickname
		if ( Len(session.auth.user.getName() ) and arguments.new_password CONTAINS user.getName() )
			ArrayAppend( aErrors, "Your password cannot contain your account name (nickname).");

		// Check to see if password is a date
		if ( IsDate(arguments.new_password) )
			arrayAppend( aErrors, "Your password cannot be a date.");

        return aErrors;
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
            len( listFirst(str, "@") ) <= 64 &&
            len( listRest(str, "@") ) <= 255;
    }

}
