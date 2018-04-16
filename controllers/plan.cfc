// controllers/plan
component accessors = true { 

  property planservice;
  property eventservice;

  function init( fw ) {

    variables.fw = fw;

  }

  /* raw json methods */
  public void function list( struct rc ) {

    var cards = planservice.list( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', cards );

  }

  public void function events( struct rc ) {

    var events = planservice.events( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', events );

  }

  public void function deleteEvents( struct rc ) {

    var result = eventservice.delete( arguments.rc.user_id );

    variables.fw.renderdata( 'JSON', result );

  }

  public void function schedule( struct rc ) {

    // return an array of event dates reflecting when each card is paid and by how much

    /* match this format: 

      data = [
       
        //month1
        {id: 1, title: 'Pay $28.72 to card1', start: Wed Nov 30 2017 00:00:00 GMT-0600, balance_remaining: 4.22},
        {id: 2, title: 'Pay $33.90 to card2', start: Wed Nov 30 2017 00:00:00 GMT-0600, balance_remaining: 1428.4},
        
        //month2    
        {id: 1, title: 'Pay $28.72 to card1', start: Mon Dec 31 2018 00:00:00 GMT-0600, balance_remaining: 0},
        {id: 2, title: 'Pay $33.90 to card2', start: Mon Dec 31 2018 00:00:00 GMT-0600, balance_remaining: 1389.2},

        etc...

      ];

    */
    var events = ArrayNew(1);
    var s = planservice.events( arguments.rc.user_id );

    for ( var event in s ) {

      for ( var item in event ) {

        var sItem = StructNew();

        if ( event[item].getCalculated_Payment() > 0 ) {

          StructInsert( sItem, 'id', event[item].getCard_Id() );
          StructInsert( sItem, 'title', 'Pay $' & DecimalFormat( event[item].getCalculated_Payment() ) & ' to ' & event[item].getLabel() );
          StructInsert( sItem, 'start', DateFormat( event[item].getPay_Date(), "ddd mmm dd yyyy" ) & ' 00:00:00 GMT-0600' );

          ArrayAppend( events, sItem );

        }

      }
    }

    variables.fw.renderdata( 'JSON', events );

  }

  public void function journey( struct rc ) {

    // return an array of elements (each element is technically a month/year) that declare the remaining balance on each card
    // (with the implication that the schedule conveyed in events() is committed to by the user)

    // format is:
    
    /*
    data = [

      // milestone1
      {
        name: 'card1',
        data: [100, 88, 72, 69, 51, 48, 27, 12, 4, 0]   // each value in the array the balance_remaining for that month.
      },

      // milestone2
      {
        name: 'card2',
        data: [100, 72, 59, 34, 18, 9, 0]       // each value in the array the balance_remaining for that month.
      }

    ]
      */

    var s = planservice.events( arguments.rc.user_id );
    var cards = planservice.list( arguments.rc.user_id );
    var milestones = ArrayNew(1);
    var thisCardId = 0;

    // cards is an object(struct)!
    for ( var card in cards ) {

      var milestone = StructNew();

      milestone["name"] = cards[card].getLabel();
      milestone["data"] = ArrayNew(1);

      thisCardId = cards[card].getCard_Id();

      // events is an array of structs!
      for ( var event in s ) {

        for ( var item in event ) {

          if ( event[item].getCard_Id() == thisCardID && event[item].getRemaining_Balance() > 0 ) {

            // append the remainig balance as a plottable point along the 
            ArrayAppend( milestone["data"], event[item].getRemaining_Balance() );

          }

        }

      }

      // add new milestones for this card
      ArrayAppend( milestones, milestone );

    }

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