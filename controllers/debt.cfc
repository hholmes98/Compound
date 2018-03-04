// controllers/debt
component accessors = true { 

  property debtservice;
  property cardservice;

  function init( fw ) {

    variables.fw = fw;

  }

  /* default (always at the top) */
  public void function default( struct rc ) {

    // detect if the user is logged in, and if so, just take them directly to auth_start_page
    if ( session.auth.isLoggedIn ) {
      variables.fw.redirect( application.auth_start_page );
    }

  }

  /* raw json methods */
  public void function list( struct rc ) {

    var cards = debtservice.list( session.auth.user.getUser_Id() );
    variables.fw.renderdata( 'JSON', cards );

  }

  public void function journey( struct rc ) {

    var milestones = debtservice.milestones( session.auth.user.getUser_Id() );
    variables.fw.renderdata( 'JSON', milestones );

  }

  /* back-end actions */
  public void function calculate( struct rc ) {

    var cardcount = 0;

    // reset the tmp cards session
    session.tmp.cards = StructNew();

    // store the temp. budget
    session.tmp.preferences.budget = rc.budget;

    // count the number of cards submitted by enumerating fieldlist via 'credit-card'
    for ( field in rc.fieldnames ) {

      if ( field CONTAINS 'credit-card-label' ) {

        cardcount++;

      }

    }

    // store the counted temp. cards
    for ( var a=1; a <= cardcount; a++ ) {

      var card = StructNew();
      var capture = false;

      if ( Len( rc['credit-card-balance' & a] ) ) {

        card.balance = rc['credit-card-balance' & a];
        capture = true;

      }

      if ( capture ) {

        card.card_id = CreateUUID();
        card.user_id = session.auth.user.getUser_Id();
        card.label = rc['credit-card-label' & a];

        var card_o = cardservice.toBean( card );

        StructInsert( session.tmp.cards, card.card_id, card_o );

      }

    }

    // redirect to the plan
    variables.fw.redirect( 'debt.plan' );

  }

  public void function create( struct rc ) {

    // store just redirects to the login.create method, but appends a message telling the user we're going to save their work
    rc.message = ["Let's save your progress by creating an account. Pick a Nickname for your account and give us your email address."];

    variables.fw.redirect( 'login.create', 'message' );

  }

/* front-end methods */
}