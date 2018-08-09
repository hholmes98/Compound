//controllers/events
component accessors=true {

  property eventService;
  property planService;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function detail( struct rc ) {

    var event = eventService.get( arguments.rc.id );

    variables.fw.renderdata( 'JSON', event );

  }

  public void function delete( struct rc ) {

    var ret = eventService.delete( arguments.rc.id );

    variables.fw.renderdata( 'JSON', ret );

  }

  public void function save( struct rc ) {

    ret = eventService.save( arguments.rc );

    variables.fw.renderdata( 'JSON', ret );

  }

  /* Event Functions */

}