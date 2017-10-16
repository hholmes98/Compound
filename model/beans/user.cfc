component accessors=true {

    property user_id;
    property name;
    property email;
    property role_id;
    property role;
    property password_hash;
    property password_salt;

	function init( string user_id = 0, string name = "", string email = "", any role = "", string passwordHash = "", string passwordSalt = "" ) {
	    
	    variables.user_id = user_id;
	    variables.name = name;
	    variables.email = email;

	    variables.role = role;

	    if ( isObject( role ) ) {
	        variables.role_id = role.getRole_Id();
	    } else {
	        variables.role_id = 3; // default role id is user (3 = user, 2 = mod, 1 = admin)
	    }
	    
	    variables.password_hash = passwordHash;
	    variables.password_salt = passwordSalt;
	    
	    return this;
	}

}