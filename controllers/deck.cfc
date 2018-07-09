//controllers/cards
component accessors=true {

  property cardService;
  property card_paidService;

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

  public void function getCardPayments( struct rc ) {

    var ret = card_paidService.list( arguments.rc.user_id, arguments.rc.month, arguments.rc.year );

    variables.fw.renderdata( 'JSON', ret );

  }

  public void function getCardPayment( struct rc ) {

    var ret = card_paidService.get( arguments.rc.card_id, arguments.rc.month, arguments.rc.year );

    variables.fw.renderdata( 'JSON', ret );

  }

  public void function saveCardPayment( struct rc ) {
    param name="rc.actually_paid_on" default=Now();

    var ret = card_paidService.save( arguments.rc );

    variables.fw.renderdata( 'JSON', ret );

  }

}