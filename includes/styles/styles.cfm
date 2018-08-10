<cfsilent>
  <cfparam name="COOKIE['dd-skin']" default="1" />
  <cfscript>
  function sectionDetection( string allowed ) {
    var sec = getSection();
    var itm = getItem();

    var pages = ListToArray( arguments.allowed, ',' ); // ie. main.plan, calculate.default

    for ( var i=1; i <= ArrayLen(pages); i++ ) {

      var page = ListToArray( pages[i], '.' ); // ie. main.plan

      if ( ArrayLen(page) == 1 )
        page[2] = 'default'; // you can say 'main.default' or must 'main'

      if ( ListFindNoCase( page[1], sec ) && ListFindNoCase( page[2], itm ) ) {
        return true;
      } 

    }

    return false;
  }
  </cfscript>
</cfsilent>

<!--- styles.cfm --->
  <link href="//fonts.googleapis.com/css?family=Nunito:400,600,700,900|Ultra|Days+One|Slabo+13px|Oswald:400,600|Allerta+Stencil" rel="stylesheet" />

  <cfif getEnvironment() is 'development'>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
  <cfelse>
    <link href="/node_modules/bootstrap/dist/css/bootstrap.css" rel="stylesheet" /> 
  </cfif>

  <!--- http://www.bootstraptoggle.com/ --->
  <!--- only needed on pages that use the toggle
  profile.basic
  --->
  <cfif sectionDetection( 'profile.basic,pay.default,pay.cards' )>
    <link href="//ziscloud.github.io/angular-bootstrap-toggle/css/angular-bootstrap-toggle.min.css" rel="stylesheet" />
  </cfif>

  <!--- only needed on pages that use the Bootstrap Dialog
  (pretty much all)
  --->
  <link href="//cdnjs.cloudflare.com/ajax/libs/bootstrap3-dialog/1.34.7/css/bootstrap-dialog.min.css" rel="stylesheet" />

  <!--- for the FAB on deck.manage --->
  <cfif sectionDetection( 'deck.manage' )>
    <cfif getEnvironment() is 'development'>
      <link href="/node_modules/propellerkit/dist/css/propeller.css" rel="stylesheet" />
    <cfelse>
      <link href="/node_modules/propellerkit/dist/css/propeller.min.css" rel="stylesheet" />
    </cfif>
  </cfif>

  <!--- for the advanced (PAID ONLY) cards on deck.manage --->
  <cfif sectionDetection( 'deck.manage' )>
    <cfif getEnvironment() is 'development'>
      <link href="/node_modules/angularjs-slider/dist/rzslider.css" rel="stylesheet" />
    <cfelse>
      <link href="/node_modules/angularjs-slider/dist/rzslider.min.css" rel="stylesheet" />
    </cfif>
  </cfif>

  <!--- any page that requires panning functionality 
  main.default
  main.demo
  pay.default
  pay.cards
  --->
  <cfif sectionDetection( 'main.default,main.demo,pay.default,pay.cards' )>
    <cfif getEnvironment() is 'development'>
      <link href="/node_modules/fullpage.js/dist/fullpage.css" rel="stylesheet" />
    <cfelse>
      <link href="/node_modules/fullpage.js/dist/fullpage.min.css" rel="stylesheet" />
    </cfif>
  </cfif>

  <!--- any page that requires calendar rendering
  main.plan
  calculate.default
  --->
  <cfif sectionDetection( 'main.plan,calculate.default' )>
    <cfif getEnvironment() is 'development'>
      <link href="/node_modules/fullcalendar/dist/fullcalendar.css" rel="stylesheet" />
    <cfelse>
      <link href="/node_modules/fullcalendar/dist/fullcalendar.min.css" rel="stylesheet" />
    </cfif>
  </cfif>

  <!--- any page that requires a tooltip --->
  <cfif getEnvironment() is 'development'>
    <link href="/node_modules/angular-tooltips/dist/angular-tooltips.css" rel="stylesheet" />
  <cfelse>
    <link href="/node_modules/angular-tooltips/dist/angular-tooltips.min.css" rel="stylesheet" />
  </cfif>

  <!--- only needed for pages that in-line a custom font 
  basic.profile (the skin dropdown menu)
   --->
  <cfif sectionDetection( 'profile.basic' )>
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" />
  </cfif>

  <link id="skin" href="/assets/css/<cfoutput>#application.skins[COOKIE["dd-skin"]].path#</cfoutput>" type="text/css" rel="stylesheet" />
