//plan.cfc
component accessors = true { 

  property planservice;

  function init( fw ) {

    variables.fw = fw;

  }

  /* raw json methods */
  public void function list( struct rc ) {

    var cards = planservice.list( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', cards );

  }

  public void function schedule( struct rc ) {

    var events = planservice.events( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', events );

  }

  public void function journey( struct rc ) {

    var milestones = planservice.milestones( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', milestones );

  }

  public void function delete( struct rc ) {

    var ret = planservice.delete( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', ret );

  }

  /* front end-methods */

  /*
  public void function default( struct rc ) {
  }
  */

}