// controllers/plan
component accessors=true {

  property planService;

  function init( fw ) {

    variables.fw = fw;

  }

  /* raw json methods */

  /* get all plans for a user (remember! a user can have multiple plans over the course of a schedule) */
  public void function list( struct rc ) {

    var plans = planService.list( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', plans );

  }

  /* get a specific plan by its id */
  public void function detail( struct rc ) {

    var plan = planService.get( arguments.rc.plan_id );

    variables.fw.renderdata( 'JSON', plan );

  }

  /* get the 1st plan for a user (will populate calculate.future) */
  /*
  public void function first( struct rc ) {

    // get all plans for this user.
    var plans = planService.list( arguments.rc.user_id );

    // if none, create 1.
    if ( !ArrayLen(plans) ) {
      var plan = planService.create( arguments.rc.user_id );
    // if some, just return the 1st one, as they return chronologically.
    } else {
      var plan = plans[1];
    }

    variables.fw.renderdata( 'JSON', plan.getPlan_Deck().getDeck_Cards() );

  }
  */

  // kill a plan
  public void function delete( struct rc ) {

    var ret = planService.delete( arguments.rc.id );

    variables.fw.renderdata( 'JSON', ret );

  }

  // kill all plans for a user
  /*
  public void function purge( struct rc ) {

    var ret = planService.purge( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', ret );

  }
  */

  /* public void function save() {
  
  }
  */

  public void function create() {

    var plan = planService.create( arguments.rc.user_id );

    variables.fw.renderData( 'JSON', plan.getPlan_Deck().getDeck_Cards() );

  }

}