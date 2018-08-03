//controllers/events
component accessors=true {

  property eventService;
  property planService;

  function init( fw ) {

    variables.fw = fw;

  }

/*
  private void function populate( struct rc ) {

    // get all events for this user
    var events = eventService.list( arguments.rc.user_id );

    // if none, create 1
    if ( !ArrayLen(events) ) {

      // get all plans for this user.
      var plans = planService.list( arguments.rc.user_id );

      // if none, create 1.
      if ( !ArrayLen(plans) ) {
        var plan = planService.create( arguments.rc.user_id );
      // if some, just return the 1st one, as they return chronologically.
      } else {
        var plan = plans[1];
      }

      var events = eventService.fill( plan );
    }

    arguments.rc.events = events;

  }

  public void function list( struct rc ) {

    populate( arguments.rc )

    variables.fw.renderdata( 'JSON', arguments.rc.events );

  }
*/

  public void function detail( struct rc ) {

    var event = eventService.get( arguments.rc.id );

    variables.fw.renderdata( 'JSON', event );

  }

/*
  public void function first( struct rc ) {

    populate( arguments.rc )

    variables.fw.renderdata( 'JSON', arguments.rc.events[1] );

  }
*/

  public void function delete( struct rc ) {

    var ret = eventService.delete( arguments.rc.id );

    variables.fw.renderdata( 'JSON', ret );

  }

  // public void function purge( struct rc ) {

  //   // delete all events for a user_id
  //   var ret = eventService.purge( arguments.rc.user_id );

  //   variables.fw.renderData( 'JSON', ret );

  // }

  public void function save( struct rc ) {

    ret = eventService.save( arguments.rc );

    variables.fw.renderdata( 'JSON', ret );

  }

  /* Event Functions */
/*
  public void function schedule( struct rc ) {

    // return an array of event dates reflecting when each card is paid and by how much

    // populate events into the rc struct
    populate( arguments.rc ); // rc.events should now exist
    var schedule = ArrayNew(1);
    var events = arguments.rc.events;

    for ( var event in events ) {

      for ( var card_id in event.getEvent_Cards() ) {

        var sItem = StructNew();

        StructInsert( sItem, 'id', event.getCard(card_id).getCard_Id() );
        StructInsert( sItem, 'title', 'Pay $' & DecimalFormat( event.getCard(card_id).getCalculated_Payment() ) & ' to ' & event.getCard(card_id).getLabel() );
        StructInsert( sItem, 'start', DateFormat( event.getCard(card_id).getPay_Date(), "ddd mmm dd yyyy" ) & ' 00:00:00 GMT-0600' );

        ArrayAppend( schedule, sItem );

      }

    }

    variables.fw.renderdata( 'JSON', schedule );

  }*/

  /*
  public void function journey( struct rc ) {

    // return an array of elements (each element is technically a month/year) that declare the remaining balance on each card
    // (with the implication that the schedule conveyed in events() is committed to by the user)

    // format is:
    

    populate( arguments.rc );
    var events = arguments.rc.events;
    var milestones = ArrayNew(1);
    var cards = events[1].getPlan().getPlan_Deck().getDeck_Cards(); // this is convenience, just a full list of the user's card's.

    // cards is an object(struct)!
    for ( var card_id in cards ) {

      var milestone = StructNew();

      milestone["name"] = cards[card_id].getLabel();
      milestone["data"] = ArrayNew(1);

      // events is an array of structs!
      for ( var event in events ) {

        for ( var e_card_id in event.getEvent_Cards() ) {

          if ( e_card_id == card_id && event.getCard(e_card_id).getRemaining_Balance() > 0 ) {

            // append the remainig balance as a plottable point along the 
            ArrayAppend( milestone["data"], event.getCard(e_card_id).getRemaining_Balance() );

          }

        }

      }

      // add new milestones for this card
      ArrayAppend( milestones, milestone );

    }

    variables.fw.renderdata( 'JSON', milestones );

  }
  */

}