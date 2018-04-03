//controllers/prefs
component accessors = true { 

  property preferenceservice;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function get( struct rc ) {

    var prefbean = preferenceservice.get( rc.uid );

    variables.fw.renderdata( "JSON" , prefbean );

  }

  public void function save( struct rc ) {
    param name="rc.user_id" default=0;

    rc.preference = preferenceservice.get( rc.user_id );

    variables.fw.populate( cfc = rc.preference, trim = true );

    // flatten bean to struct, pass to save service
    ret = preferenceservice.save( variables.preferenceservice.flatten( rc.preference ) );

    variables.fw.renderdata( "JSON", ret );

  }

}