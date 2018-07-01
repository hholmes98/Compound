// model/service/plan_card
component accessors=true extends="model.services.card" {

  public any function init( beanFactory ) {

    return super.init( arguments.beanFactory );

  }

  /******
   CRUD
  ******/

  /*
  list() = get all cards for a user (aka a 'deck'), but override cardService.list by populating plan_card beans.
  */

  public any function list( string user_id ) {

    var cards = super.list( arguments.user_id );
    var plan_cards = {};

    for ( var card_id in cards ) {

      var plan_card = variables.beanFactory.getBean('plan_cardBean');

      plan_card.setCard_Id( cards[card_id].getCard_Id() )
      plan_card.setCredit_Limit( cards[card_id].getCredit_Limit() );
      plan_card.setDue_On_Day( cards[card_id].getDue_On_Day() );
      plan_card.setUser_Id( cards[card_id].getUser_Id() );
      plan_card.setLabel( cards[card_id].getLabel() );
      plan_card.setMin_Payment( cards[card_id].getMin_Payment() );
      plan_card.setIs_Emergency( cards[card_id].getIs_Emergency() );
      plan_card.setBalance( cards[card_id].getBalance() );
      plan_card.setInterest_Rate( cards[card_id].getInterest_Rate() );
      plan_card.setZero_APR_End_Date( cards[card_id].getZero_APR_End_Date() );

      plan_cards[plan_card.getCard_Id()] = plan_card;
    }

    return plan_cards;

  }

}