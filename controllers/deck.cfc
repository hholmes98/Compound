//controllers/cards
component accessors=true {

  property cardService;
  property card_paidService;
  property fantabulousCardService;

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

  public void function css( struct rc ) {

    var cards = cardService.deck( arguments.rc.user_id ).getDeck_Cards();
    var out = '';
    var cardObj = '';

    cfloop( collection=cards, item="card" ) {
      var class = "card" & cards[card].getCard_Id();

      if ( cards[card].getCode() == "" ) {
        cardObj = fantabulousCardService.fantabulousCard( cardName=cards[card].getLabel(), cardClass=class ); // should never happen
      } else {
        cardObj = fantabulousCardService.fantabulousCard( cardName=cards[card].getLabel(), cardClass=class, hash=cards[card].getCode() );
      }

      out = out & Chr(13) & Chr(10) & "/* " & class & " */" & Chr(13) & Chr(10) & cardObj.getCSS();
    }

    // kind of a hack, but it works because all the cards should be the same size
    out = cardObj.getHolderCSS() & out;

    // deliver it
    variables.fw.renderdata().data( out ).type( function( outData ) {
      return {
        contentType = 'text/css',
        output = outData.data
      };
    });

  }

  public void function getNewDesign( struct rc ) {
    param name="rc.code" default="";

    if ( !Len(Trim(rc.code) ) ) {
      rc.code = Hash( Now(), "SHA-256", "UTF-8" );
    }

    var designObj = fantabulousCardService.fantabulousCard( cardName="temp", cardClass="temp", hash=rc.code );

    var data_out = {
      'code' = rc.code,
      'css' = designObj.getCSS()
    }

    variables.fw.renderdata( 'JSON', data_out );
  }

}