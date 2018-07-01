//model/beans/event
component accessors=true {

  property event_id;
  property plan_id;
  property plan;
  property calculated_for_month;
  property calculated_for_year;

  property event_cards; // all the event cards that are non-zero for a plan.(not a deck, because we don't include non-zeros!)

  function init( string event_id = 0, string plan_id="", any plan="", string calculated_for_month = "", string calculated_for_year = "", struct event_cards=StructNew() ) {

    variables.event_id = arguments.event_id;
    variables.plan_id = arguments.plan_id;

    variables.plan = arguments.plan;

    variables.calculated_for_month = arguments.calculated_for_month;
    variables.calculated_for_year = arguments.calculated_for_year;

    variables.event_cards = arguments.event_cards;

    return this;

  }

  function addCard( any card ) {

    StructInsert( variables.event_cards, arguments.card.getCard_Id(), arguments.card );

  }

  function removeCard( any card ) {

    StructDelete( variables.event_cards, arguments.card.getCard_Id() );
  }

  function getCard( string id ) {

    return variables.event_cards[arguments.id];
  }

  function setCard( any card ) {

    variables.event_cards[arguments.card.getCard_Id()] = arguments.card;
  }

  function getCalculated_For() {

    return CreateDate( Year( variables.calculated_for_year ), Month( variables.calculated_for_month ), 1 );

  }

  function setCalculated_For( date target ) {

    var the_year = Year( arguments.target );
    var the_month = Month( arguments.target );

    variables.calculated_for_year = the_year;
    variables.calculated_for_month = the_month;

  }

}