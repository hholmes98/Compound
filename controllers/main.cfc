// controllers/main
component accessors = true { 

  property tempService;
  property planService;
  property eventService;
  property mailService;
  property cardService;
  property fantabulousCardService;
  property tokenService;
  property generatedCardService;

  function init( fw, beanFactory ) {

    variables.fw = arguments.fw;
    variables.beanFactory = arguments.beanFactory;

  }

  function before( struct rc ) {
    param name="rc.kc" default="0"; // kc = keyword code
    param name="rc.cc" default="0"; // cc = (ad) copy code

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

    // mktgTitle = Should mirror the keywords used for the adgroup (ie. what the user searched for)
    // mktgBody = Should mirror the content of the ad (tailored to the ad that was clicked)

    if ( IsNumeric(arguments.rc.kc) ) {

      switch ( arguments.rc.kc ) {
        case 1:
          rc.mktgTitle = "Calculate Your Own Payoff";
          break;
        case 2:
          rc.mktgTitle = "Pay Off Debt Yourself";
          break;
        case 3:
          rc.mktgTitle = "Credit Card Advice";
          break;
        case 4:
          rc.mktgTitle = "Don't Go Deeper Into Debt";
          break;
        case 5:
          rc.mktgTitle = "Pay Off Cards Yourself";
          break;
        case 6:
          rc.mktgTitle = "A Credit Card Calculator & More!";
          break;
        case 7:
          rc.mktgTitle = "New Debt Snowball Calculator";
          break;
        case 8:
          rc.mktgTitle = "A Snowball Calculator & More!";
          break;
        case 9:
          rc.mktgTitle = "Calculate Your Loan Payoff";
          break;
        case 10:
          rc.mktgTitle = "Pay Off Loans Yourself";
          break;
        case 11:
          rc.mktgTitle = "Loan Payoff Advice";
          break;
        case 12:
          rc.mktgTitle = "A Loan Payoff Calculator & More!";
          break;
        default:
          break;
      }

    }

    if ( IsNumeric(arguments.rc.cc) ) {

      switch ( arguments.rc.cc ) {
        case 1:
          rc.mktgBody = "Tell us your debt and we'll tell you the fastest way to pay it off!";
          break;
        case 2:
          rc.mktgBody = "Manage your debt reduction budget. What cards to pay off first, and by how much.";
          break;
        case 3:
          rc.mktgBody = "Our credit card calculator advises you on what to pay and when.";
          break;
        case 4:
          rc.mktgBody = "Don't know how to pay off your credit cards? Our app tells you what to pay.";
          break;
        case 5:
          rc.mktgBody = "Tell us your credit card balances and we'll tell you the fastest way to pay them off.";
          break;
        case 6:
          rc.mktgBody = "Manage your credit card payoff: what cards to pay off first, and by how much.";
          break;
        case 7:
          rc.mktgBody = "A credit card calculator that advises the fastest payoff to financial freedom.";
          break;
        case 8:
          rc.mktgBody = "Tell us your loans and we'll tell you the fastest way to pay them off!";
          break;
        case 9:
          rc.mktgBody = "Manage your loan payoff: what loans to pay off first, and by how much.";
          break;
        case 10:
          rc.mktgBody = "Our loan payoff calculator advises you on what to pay and when.";
          break;
        case 11:
          rc.mktgBody = "A loan payoff calculator that advises the fastest payoff to financial freedom.";
          break;
        default:
          break;
      }

    }

  }

  private void function populate( struct rc ) {

    // get al levents for this user
    var plan = tempService.createPlan( session.auth.user.getUser_Id() );
    var events = tempService.fillEvents( plan );

    arguments.rc.events = events;

  }

  private function createPayload( struct rc ) {

    rc.payload = tokenService.createToken();

  }

  function default( struct rc ) {
    param name="rc.demo_open" default=false;

    // detect if the user is logged in, and if so, just take them directly to auth_start_page
    if ( StructKeyExists(session, 'auth') && session.auth.isLoggedIn ) {
      variables.fw.redirect( application.auth_start_page );
    }

    rc.title = application.app_name & " - The Fastest Online Debt Elimination Tool";
    rc.pageDescription = "Calculate the fastest possible credit card payoff with " & application.app_name & ", your personal debt payoff assistant.";

  }

  /* alias of default, but with demo drawer already open */
  function demo( struct rc ) {

    rc.demo_open = true;
    variables.fw.setLayout('main.default');
    variables.fw.setView('main.default');
    default( rc );

  }

  function about( struct rc ) {

    rc.pageTitle = "What is " & application.app_name & "?";
  }

  function features( struct rc ) {

    rc.pageTitle = application.app_name & " features";
    rc.pageDescription = application.app_name & " features that make it your personalized debt payoff assistant.";
  }

  function pricing( struct rc ) {


    rc.pageTitle = application.app_name & " pricing";
    rc.pageDescription = "Affordable pricing plans for eliminating debt with " & application.app_name;
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

  function calculator( struct rc ) {
    param name="rc.debtLabel" default="Credit Card";

    rc.title = rc.debtLabel & " Payoff Calculator - " & application.app_name;
    rc.pageDescription = application.app_name & "'s " & LCase(rc.debtLabel) &  " calculator will tell you how much to pay and how long it will take to pay off.";
  }

  function card( struct rc ) {

    if ( !IsNumeric(rc.cid) )
      rc.cid = 0;

    rc.card = generatedCardService.get( rc.cid );

    //https://developers.pinterest.com/docs/rich-pins/products/
    rc.productType = 'og:product';
    rc.pageTitle = application.app_name & ': Featured Card Design';
    rc.pageDescription = 'Download this custom design for your own credit card';

    // our FANTABULOUS card service will perform the rendering
    rc.fantabulous = fantabulousCardService;

    rc.inlineStyle = rc.fantabulous.getCSS( cardName="featured", hash=rc.card.getCode(), size="large" );
    rc.cardHTML = rc.fantabulous.getHTML( cardName="featured", hash=rc.card.getCode(), size="large", id="shell" );
    rc.raw = rc.fantabulous.getCompleteHTML( cardName="featured", hash=rc.card.getCode(), size="large", id="shell" );

    cfdocument( format="PDF", filename="tmp.pdf", overwrite="true" ) {
      writeOutput(rc.raw);
    }
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
    param name="rc.anotherCalcURL" default="";

    /* shut down direct access */
    if ( !(IsNumeric(rc.budget) && rc.budget > 0) ) 
      variables.fw.redirect( application.start_page );

    var cardcount = 0;

    // reset the tmp cards session
    session.tmp.cards = StructNew();

    // store the temp. budget
    session.tmp.preferences.budget = Trim(rc.budget);

    // count the number of cards submitted by enumerating fieldlist via 'credit-card-label'
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

      if ( IsDefined( 'rc.credit-card-interest-rate' & a ) ) {
        card.interest_rate = Val(Trim(rc['credit-card-interest-rate' & a]));

        if (card.interest_rate > 70)
          card.interest_rate = 70;

        if (card.interest_rate < 0)
          card.interest_rate = 0;
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
    variables.fw.redirect( action='main.plan', preserve="anotherCalcURL" );

  }

  public void function create( struct rc ) {

    // store just redirects to the login.create method, but appends a message telling the user we're going to save their work
    rc.message = ["Let's save your progress by creating an account. Pick a Nickname for your account and give us your email address."];

    variables.fw.redirect( 'login.create', 'message' );

  }

  /* error handling */
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