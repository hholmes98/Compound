component accessors=true {

    function init( roleService, mailService, beanFactory  ) {
        
        variables.beanFactory = beanFactory;
		
		variables.roleService = roleService;
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
			SELECT u.*, r.role_id, r.name AS role_name
			FROM "pUsers" u
			INNER JOIN "pUserRoles" ur ON (u.user_id = ur.user_id)
			INNER JOIN "pRoles" r ON (ur.role_id = r.role_id)
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
			user.setRole_id(result.role_id[1]);
			user.setRole(variables.roleService.get(user.getRole_Id()));
			user.setPassword_Hash(result.password_hash[1]);
			user.setPassword_Salt(result.password_salt[1]);
		
		}

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
			SELECT u.*, r.role_id, r.name
			FROM "pUsers" u
			INNER JOIN "pUserRoles" ur ON (u.user_id = ur.user_id)
			INNER JOIN "pRoles" r ON (ur.role_id = r.role_id)
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

			users[user.getUser_id()] = user;
		}

		return users;

    }

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
        var password = "smile89"; // TODO
        var newPassword = hashPassword( password );
        
        user.setPassword_Hash(newPassword.hash);
        user.setPassword_Salt(newPassword.salt);

        // save the new user
        newUser = save( user );

    	// kick off verification email
        // TODO: fire off the verification email 
        // variables.mailService.verifyUser( newUser, password ); // we pass in the plain-text password generated, this is the *only* time it is ever seen/displayed, never stored.

    	// return user populdated object
    	return newUser;
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
        var returnVar = { };

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

    function checkPassword( any user, string currentPassword = "",
                            string newPassword = "", string retypePassword = "" ) {

		// Initialize return variable
		var aErrors = arrayNew(1);
		var inputHash = '';
		var count = 0;

		// if the password fields to not have values, add an error and return
		if (not len(arguments.newPassword) or not len(arguments.retypePassword)) {
			arrayAppend(aErrors, "Please fill out all form fields");
			return aErrors;
		}

		if (len(arguments.currentPassword) and isObject(user)) {
			// If the user is changing their password, compare the current password to the saved hash
			inputHash = hash(trim(arguments.currentPassword) & trim(user.getPasswordSalt()), 'SHA-512');

			/* Compare the inputHash with the hash in the user object. if they do not match,
				then the correct password was not passed in */
			if (not compare(inputHash, user.getPasswordHash()) IS 0) {
				arrayAppend(aErrors, "Your current password does not match the current password entered");
				// Return now, there is no point testing further
				return aErrors;
			}

			// Compare the current password to the new password, if they match add an error
			if (compare(arguments.currentPassword, arguments.newPassword) IS 0)
				arrayAppend(aErrors, "The new password can not match your current password");
		}

		// Check the password rules
		// *** to change the strength of the password required, uncomment as needed

		// Check to see if the two passwords match
		if (not compare(arguments.newPassword, arguments.retypePassword) IS 0) {
			arrayAppend(aErrors, "The new passwords you entered do not match");
			// Return now, there is no point testing further
			return aErrors;
		}

		// If the password is more than X and less than Y, add an error.
		if (len(arguments.newPassword) LT 8)// OR Len(arguments.newPassword) GT 25
			arrayAppend(aErrors, "Your password must be at least 8 characters long");// between 8 and 25

		// Check for atleast 1 uppercase or lowercase letter
		/* if (NOT REFind('[A-Z]+', arguments.newPassword) AND NOT REFind('[a-z]+', arguments.newPassword))
			ArrayAppend(aErrors, "Your password must contain at least 1 letter"); */

		// check for at least 1 letter
		if (reFind('[A-Z]+',arguments.newPassword))
			count++;
		if (reFind('[a-z]+', arguments.newPassword))
			count++;
		if (not count)
			arrayAppend(aErrors, "Your password must contain at least 1 letter");

		// Check for at least 1 uppercase letter
		/*if (NOT REFind('[A-Z]+', arguments.newPassword))
			ArrayAppend(aErrors, "Your password must contain at least 1 uppercase letter");*/

		// Check for at least 1 lowercase letter
		/*if (NOT REFind('[a-z]+', arguments.newPassword))
			ArrayAppend(aErrors, "Your password must contain at least 1 lowercase letter");*/

		// check for at least 1 number or special character
		count = 0;
		if (reFind('[1-9]+', arguments.newPassword))
			count++;
		if (reFind("[;|:|@|!|$|##|%|^|&|*|(|)|_|-|+|=|\'|\\|\||{|}|?|/|,|.]+", arguments.newPassword))
			count++;
		if (not count)
			arrayAppend(aErrors, "Your password must contain at least 1 number or special character");

		// Check for at least 1 numeral
		/*if (NOT REFind('[1-9]+', arguments.newPassword))
			ArrayAppend(aErrors, "Your password must contain at least 1 number");*/

		// Check for one of the predfined special characters, you can add more by seperating each character with a pipe(|)
		/* if (NOT REFind("[;|:|@|!|$|##|%|^|&|*|(|)|_|-|+|=|\'|\\|\||{|}|?|/|,|.]+", arguments.newPassword))
			ArrayAppend(aErrors, "Your password must contain at least 1 special character"); */

		// Check to see if the password contains the username
		if (len(user.getEmail()) and arguments.newPassword CONTAINS user.getEmail())
			arrayAppend(aErrors, "Your password cannot contain your email address");

		// Check to see if password is a date
		if (isDate(arguments.newPassword))
			arrayAppend(aErrors, "Your password cannot be a date");

		// Make sure password contains no spaces
		if (arguments.newPassword CONTAINS " ")
			arrayAppend(aErrors, "Your password cannot contain spaces");

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
