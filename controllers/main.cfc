// controllers/main
component accessors = true { 

  property tempService;
  property planService;
  property eventService;
  property mailService;
  property cardService;
  property fantabulousCardService;
  property tokenService;

  function init( fw, beanFactory ) {

    variables.fw = arguments.fw;
    variables.beanFactory = arguments.beanFactory;

  }

  function before( struct rc ) {

    rc.robots = "index,follow,archive";

    switch( variables.fw.getItem() ) {

      case 'default':
      case 'demo':
      case 'about':
      case 'features':
      case 'pricing':
      case 'contact':
        rc.cache = 1;
        break;

    }

  }

  private function createPayload( struct rc ) {

    rc.payload = tokenService.createToken();

  }

  function about( struct rc ) {

    rc.pageTitle = "What is " & application.app_name & "?";
  }

  function features( struct rc ) {

    rc.pageTitle = application.app_name & " features";
    rc.pageDescription = application.app_name & " features that make it the only credit card caluclator you'll ever need.";
  }

  function pricing( struct rc ) {


    rc.pageTitle = application.app_name & " pricing";
    rc.pageDescription = "Affordable pricing plans for eliminating credit card debt with " & application.app_name;
  }

  function contact( struct rc ) {

    rc.pageTitle = "Contact the " & application.app_name & " team";
    rc.pageDescription = "Got more questions! We're standing by with answers!";
  }

  function top( struct rc ) {

    rc.pageTitle = application.app_name & " top ranked cards";
    rc.pageDescription = "Check out the most popular custom credit card designs in use at " & application.app_name;

    rc.codes = cardService.getCardCodes( limit=10 );
    rc.fantabulous = fantabulousCardService;
  }  

  private void function populate( struct rc ) {

    // get al levents for this user
    var plan = tempService.createPlan( session.auth.user.getUser_Id() );
    var events = tempService.fillEvents( plan );

    arguments.rc.events = events;

  }

  /* default (always at the top) */
  public void function default( struct rc ) {
    param name="rc.demo_open" default=false;

    // detect if the user is logged in, and if so, just take them directly to auth_start_page
    if ( StructKeyExists(session, 'auth') && session.auth.isLoggedIn ) {
      variables.fw.redirect( application.auth_start_page );
    }

  }

  public void function demo( struct rc ) {

    rc.demo_open = true;
    variables.fw.setLayout('main.default');
    variables.fw.setView('main.default');
    default( rc );

  }

  /* raw json methods */
  public void function list( struct rc ) {

    var plan = tempService.createPlan( session.auth.user.getUser_Id() );

    variables.fw.renderdata( 'JSON', plan.getPlan_Deck().getDeck_Cards() );

  }

  public void function journey( struct rc ) {

    //FIXME: trap if the session times out, send the user back to the homepage
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

  /* back-end actions */
  public void function calculate( struct rc ) {
    param name="rc.budget" default=0;

    /* shut down direct access */
    if ( !(IsNumeric(rc.budget) && rc.budget > 0) ) 
      variables.fw.redirect( application.start_page );

    var cardcount = 0;

    // reset the tmp cards session
    session.tmp.cards = StructNew();

    // store the temp. budget
    session.tmp.preferences.budget = Trim(rc.budget);

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

        card.balance = Val(Trim(rc['credit-card-balance' & a]));
        capture = true;

      }

      if ( capture ) {

        card.card_id = CreateUUID();
        card.user_id = session.auth.user.getUser_Id();
        card.label = Trim(rc['credit-card-label' & a]);

        var card_o = variables.beanFactory.getBean('plan_cardBean').init( argumentCollection=card );

        StructInsert( session.tmp.cards, card.card_id, card_o );

      }

    }

    // redirect to the plan
    variables.fw.redirect( 'main.plan' );

  }

  public void function create( struct rc ) {

    // store just redirects to the login.create method, but appends a message telling the user we're going to save their work
    rc.message = ["Let's save your progress by creating an account. Pick a Nickname for your account and give us your email address."];

    variables.fw.redirect( 'login.create', 'message' );

  }

  public void function oops( struct rc ) {

    var the_url = 'Unknown';

    if (StructKeyExists(request,'_fw1') && 
        StructKeyExists(request._fw1, 'CGIPATHINFO') &&
        StructKeyExists(request._fw1, 'CGISCRIPTNAME') &&
        StructKeyExists(request._fw1, 'HEADERS') &&
        StructKeyExists(request._fw1.HEADERS, 'origin') ) {

      the_url = request._fw1.HEADERS.origin & request._fw1.CGISCRIPTNAME & request._fw1.CGIPATHINFO;

    }

    // email the admins before displaying anything nice to the user.
    mailservice.sendError( application.admin_email, request.exception, the_url );

  }

}