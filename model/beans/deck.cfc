//model/bean/deck
component accessors=true {

  property deck_cards;

  function init( any deck_cards=StructNew() ) {

    //variables.user_id = arguments.user_id;
    variables.deck_cards = arguments.deck_cards;

    variables.e_id = 0; // internal index for a bit faster lookup

    return this;

  }

  function getCard( string id ) {

    if ( StructKeyExists( variables.deck_cards, arguments.id ) ) {
      return variables.deck_cards[arguments.id];
    } else {
      Throw( message="[bean.deck.getCard]Error: Card not found", detail="A request for a Card ID, " & arguments.id & " was invalid, as the id does not exist in the User's deck (valid IDs are: " & StructKeyList(variables.deck) & ")" );
    }

  }

  function setCard( any card ) {

    var id = arguments.card.getCard_Id();

    variables.deck_cards[id] = arguments.card;

    if ( arguments.card.getIs_Emergency() )
      variables.e_id = id;

  }

  function addCard( any card ) {

    StructInsert( variables.deck_cards, arguments.card.getCard_Id(), arguments.card, true );

    if ( arguments.card.getIs_Emergency() )
      variables.e_id = arguments.card.getCard_Id();

  }

  function removeCard( any card ) {

    StructDelete( variables.deck_cards, arguments.card.getCard_Id() );

    if ( arguments.card.getIs_Emergency() )
      variables.e_id = 0;

  }

  function getAllCardIDs() {

    return StructKeyList( variables.deck_cards );

  }

  function setCards( any cards ) {

    variables.deck_cards = arguments.cards;

    updateDeckEmergencyCard();

  }

  function setDeck_Cards( any cards ) {

    setCards( arguments.cards );

  }

  function updateDeckEmergencyCard() {

    variables.e_id = 0;

    for ( var card_id in variables.deck_cards ) {
      if ( variables.deck_cards[card_id].getIs_Emergency() ) {
        variables.e_id = card_id;
        break;
      }
    }

  }

  function getEmergencyCard() {

    if ( variables.e_id != 0 ) {
      // walk it to be sure
      for ( var card_id in variables.deck_cards ) {
        if ( variables.deck_cards[card_id].getIs_Emergency() ) {
          variables.e_id = card_id;
          return variables.deck_cards[variables.e_id];
        }
      }
      return variables.deck_cards[variables.e_id];
    }
    else
      Throw( message="[bean.deck.getEmergencyCard]Error: Emergency Card not found", detail="A request for the emergency card in the deck turned up nothing (IDs checked were: " & StructKeyList(variables.deck) & ")" ); // no emergency!

  }

  function setEmergencyCard( any card ) {

    // turn the old one off.
    variables.deck_cards[variables.e_id].setIs_Emergency( false );

    // turn the new one on.
    var id = arguments.card.getCard_Id();
    variables.deck_cards[id].setIs_Emergency( true );

    // little faster lookup
    variables.e_id = id;

  }

}