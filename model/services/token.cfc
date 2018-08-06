// model/services/security
component accessors=true {

  public any function init( beanFactory ) {

    variables.beanFactory = arguments.beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  public function getServerToken() {

    if ( StructKeyExists( SESSION, 'CFID') ) {
      return SESSION.CFID;
    } else {
      Throw( message="Cannot create new token", 
        detail="A request to createToken() cannot be fulfilled, as the SESSION.CFID is inacessible or does not exist.");
    }

  }

  // creates a payload (struct with .hash and .salt keys)
  // if no token (string) is passed in, it'll generate a new token based on the CF user session.
  public function createPayload( string token="" ) {

    var tok = arguments.token;

    if ( !Len(tok) ) {
      tok = getServerToken();
    }

    var seasoning = CreateUUID();

    var returnVar = {
      salt: seasoning,
      hash: Hash( tok & seasoning, "SHA-512" )
    };

    return returnVar;

  }

  public function validatePayload( struct payload, string token="" ) {

    var sToken = arguments.token;

    if ( !Len(sToken) ) {
      sToken = getServerToken();
    }

    if ( !StructKeyExists(arguments.payload,'hash') || !StructKeyExists(arguments.payload,'salt') ) {
      Throw( message="Unrecognizable payload", 
        detail="The payload passed to validatePayload requires both 'hash' and 'salt' keys (current keys are " & StructKeyList(arguments.payload) & ")");
    }

    var new_hash = Hash( Trim( sToken ) & Trim( arguments.payload.salt ), "SHA-512" );

    var isValid = !Compare( new_hash, arguments.payload.hash );

    var result = {
      valid: isValid,
      expected: new_hash,
      received: arguments.payload.hash
    }

    return result;

  }

}