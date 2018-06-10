//controllers/cards
component accessors=true {

  property cardService;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function list( struct rc ) {

    var deck = cardService.deck( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', deck.getDeck_Cards() );

  }

  public void function detail( struct rc ) {

    var card = cardService.get( arguments.rc.id );

    variables.fw.renderdata( 'JSON', card );

  }

  /* public void function first() */

  public void function delete( struct rc ) {

    var ret = cardService.delete( arguments.rc.id );

    variables.fw.renderdata( 'JSON', ret );

  }

  /* public void function purge() */

  public void function save( struct rc ) {

    ret = cardService.save( arguments.rc );

    variables.fw.renderdata( 'JSON', ret );

  }

  /*
  public void function create( struct rc ) {

  }
  */

  /* extras */

  public void function emergency( struct rc ) {

    var ret = cardService.setEmergencyCard( arguments.rc.card_id );

    variables.fw.renderdata( 'JSON', ret );

  }

}