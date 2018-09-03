//model/beans/generatedCard.cfc
component accessors = true {

  property generated_card_id; // number
  property code; // varchar

  function init( string generated_card_id = 0, string code = "" ) {

    variables.generated_card_id = arguments.generated_card_id;
    variables.code = arguments.code;

    return this;

  }

}
