//controllers/cards
component accessors=true {

  property cardService;
  property card_paidService;
  property fantabulousCardService;

  function init( fw ) {

    variables.fw = fw;

  }

  /*
  private function validateToken( struct rc ) {

    rc.clientToken = DeserializeJSON( getHTTPRequestData().headers['X-XSRF-DD-TOKEN'] );
    rc.serverToken = SESSION.CFID & SESSION.CFTOKEN;
    rc.expected = Hash( Trim( rc.serverToken ) & Trim( rc.clientToken.salt ), "SHA-512" );

    rc.token_is_valid = !Compare( rc.expected, rc.clientToken.hash );
  }


  public void function list( struct rc ) {

    validateToken( arguments.rc );

    if ( rc.token_is_valid ) {

      var deck = cardService.deck( arguments.rc.user_id );

      variables.fw.renderdata( 'JSON', deck.getDeck_Cards() );

    } else {

      variables.fw.renderdata( 'JSON', {
        error:true,
        expected: rc.expected,
        received: rc.clientToken.hash
      } );

    }

  }

  public void function detail( struct rc ) {

    var card = cardService.get( arguments.rc.id );

    variables.fw.renderdata( 'JSON', card );

  }
  */

  /* public void function first() */

/*
  public void function delete( struct rc ) {

    var ret = cardService.delete( arguments.rc.id );

    variables.fw.renderdata( 'JSON', ret );

  }
*/

  /* public void function purge() */
/*
  public void function save( struct rc ) {

    ret = cardService.save( arguments.rc );

    variables.fw.renderdata( 'JSON', ret );

  }
*/
  /*
  public void function create( struct rc ) {

  }
  */

  /* extras */

  // public void function emergency( struct rc ) {

  //   var ret = cardService.setEmergencyCard( arguments.rc.card_id );

  //   variables.fw.renderdata( 'JSON', ret );

  // }

  // public void function getCardPayments( struct rc ) {

  //   var ret = card_paidService.list( arguments.rc.user_id, arguments.rc.month, arguments.rc.year );

  //   variables.fw.renderdata( 'JSON', ret );

  // }

  // public void function getCardPayment( struct rc ) {

  //   var ret = card_paidService.get( arguments.rc.card_id, arguments.rc.month, arguments.rc.year );

  //   variables.fw.renderdata( 'JSON', ret );

  // }

  // public void function saveCardPayment( struct rc ) {
  //   param name="rc.actually_paid_on" default=Now();

  //   var ret = card_paidService.save( arguments.rc );

  //   variables.fw.renderdata( 'JSON', ret );

  // }

  public void function css( struct rc ) {

    var cards = cardService.deck( arguments.rc.user_id ).getDeck_Cards();
    var out = '';
    var cardObj = '';

    cfloop( collection=cards, item="card" ) {
      var class = "card" & cards[card].getCard_Id();

      if ( cards[card].getCode() == "" ) {
        cardObj = fantabulousCardService.fantabulousCard( cardName=cards[card].getLabel(), cardClass=class ); // should never happen
        out = out & Chr(13) & Chr(10) & "/* " & class & " */" & Chr(13) & Chr(10) & cardObj.getCardCSS( cardName=cards[card].getLabel(), cardClass=class );
      } else {
        cardObj = fantabulousCardService.fantabulousCard( cardName=cards[card].getLabel(), cardClass=class, hash=cards[card].getCode() );
        out = out & Chr(13) & Chr(10) & "/* " & class & " */" & Chr(13) & Chr(10) & cardObj.getCardCSS( cardName=cards[card].getLabel(), cardClass=class, hash=cards[card].getCode() );
      }

    }

    if ( IsObject(cardObj) ) {

      // kind of a hack, but it works because all the cards should be the same size
      out = cardObj.getHolderCSS() & out;

    }

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

  // debug only!
  public void function spitCards( struct rc ) {
    param name="rc.limit" default=0;

    var codeQry = cardService.getCardCodes( rc.limit );

    cfsavecontent( variable="cardContent", append=true ) {

      cfloop( query=codeQry ) {

        WriteOutput( codeQry.code[codeQry.currentRow] & "<br>" );
        WriteOutput( fantabulousCardService.getHTML( cardName="temp" & codeQry.currentRow, cardClass="temp" & codeQry.currentRow, hash=codeQry.code[codeQry.currentRow] ) );
        WriteOutput( "<br><br>" );

      }

    }

    variables.fw.renderdata( 'HTML', cardContent );

  }

}