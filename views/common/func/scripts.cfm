<!--- scripts.cfm --->
<cfsilent>
  <cfparam name="scrollUp" default="" />
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

<!-- CDNs -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>

<cfif getEnvironment() is 'development'>
  <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.6.7/angular.js" type="text/javascript"></script>
<cfelse>
  <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.6.7/angular.min.js" type="text/javascript"></script>
</cfif>

<cfif getEnvironment() is 'development'>
  <script src="/node_modules/bootstrap/dist/js/bootstrap.js"></script>
<cfelse>
  <script src="/node_modules/bootstrap/dist/js/bootstrap.min.js"></script>
</cfif>

<cfif getEnvironment() is 'development'>
  <script src="//cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.14.3/ui-bootstrap-tpls.js"></script>
<cfelse>
  <script src="//cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.14.3/ui-bootstrap-tpls.min.js"></script>
</cfif>

<!--- http://www.bootstraptoggle.com/ --->
<!--- only needed on pages that use the toggle
profile.basic
--->
<cfif sectionDetection( 'profile.basic' )>
  <script src="//ziscloud.github.io/angular-bootstrap-toggle/js/angular-bootstrap-toggle.min.js"></script>
</cfif>

<!--- any page with an icon --->
<!-- font awesome -->
<script defer src="//use.fontawesome.com/releases/v5.0.8/js/all.js"></script>

<!-- dialogs -->
<!--- any page with a dialog (all)
--->
<script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap3-dialog/1.34.7/js/bootstrap-dialog.min.js"></script>

<!-- Locals -->
<!--- for the advanced (PAID ONLY) cards on deck.manage --->
<cfif sectionDetection( 'deck.manage' )>
  <cfif getEnvironment() is 'development'>
    <script src="/node_modules/angularjs-slider/dist/rzslider.js"></script>
  <cfelse>
    <script src="/node_modules/angularjs-slider/dist/rzslider.min.js"></script>
  </cfif>
</cfif>

<!--- any page that uses tooltips --->
<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angular-tooltips/dist/angular-tooltips.js"></script>
<cfelse>
  <script src="/node_modules/angular-tooltips/dist/angular-tooltips.min.js"></script>
</cfif>

<!--- any page that angular modifies cookies --->
<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angular-sanitize/angular-sanitize.js"></script>
<cfelse>
  <script src="/node_modules/angular-sanitize/angular-sanitize.min.js"></script>
</cfif>

<!--- any page that angular modifies cookies --->
<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angular-cookies/angular-cookies.js"></script>
<cfelse>
  <script src="/node_modules/angular-cookies/angular-cookies.min.js"></script>
</cfif>

<!-- date handling -->
<script src="/node_modules/moment/min/moment.min.js" type="text/javascript"></script>

<!-- fullpage animation -->
<cfif sectionDetection( 'main.default,main.demo,pay.default,pay.cards' )>
  <!--- any page that requires panning functionality 
  main.default
  main.demo
  pay.default
  pay.cards
  --->

  <cfif getEnvironment() is 'development'>
    <script src="/node_modules/fullpage.js/vendors/scrolloverflow.js" type="text/javascript"></script>
  <cfelse>
    <script src="/node_modules/fullpage.js/vendors/scrolloverflow.min.js" type="text/javascript"></script>
  </cfif>

  <cfif getEnvironment() is 'development'>
    <script src="/node_modules/fullpage.js/dist/fullpage.js" type="text/javascript"></script>
  <cfelse>
    <script src="/node_modules/fullpage.js/dist/fullpage.min.js" type="text/javascript"></script>
  </cfif>

  <script src="/node_modules/fullpage.js/dist/fullpage.extensions.min.js" type="text/javascript"></script>
</cfif>

<!-- calendar --> 
<!--- any page that requires calendar rendering
main.plan
calculate.default
--->
<cfif sectionDetection( 'main.plan,calculate.default' )>
  <script src="/node_modules/angular-ui-calendar/src/calendar.js" type="text/javascript"></script>

  <cfif getEnvironment() is 'development'>
    <script src="/node_modules/fullcalendar/dist/fullcalendar.js" type="text/javascript"></script>
    <script src="/node_modules/fullcalendar/dist/gcal.js" type="text/javascript"></script>
  <cfelse>
    <script src="/node_modules/fullcalendar/dist/fullcalendar.min.js" type="text/javascript"></script>
    <script src="/node_modules/fullcalendar/dist/gcal.min.js" type="text/javascript"></script>
  </cfif>
</cfif>

<!-- graphing -->
<!--- any page that needs charting
main.plan
calculate.default
--->
<cfif sectionDetection( 'main.plan,calculate.default' )>
  <script src="/node_modules/highcharts/highstock.js" type="text/javascript"></script>
</cfif>

<!-- payment gateway/fraud detection (everywhere) -->
<script src="https://js.stripe.com/v3/"></script>

<script>
  var ddApp = angular.module('ddApp', [
<cfif sectionDetection( 'main.plan,calculate.default' )>    'ui.calendar', </cfif>
    'ui.bootstrap', 
    '720kb.tooltips', 
<cfif sectionDetection( 'profile.basic' )>    'ui.toggle', </cfif>
<cfif sectionDetection( 'deck.manage' )>    'rzModule',</cfif>
    'ngSanitize', 
    'ngCookies'
  ]);
</script>

<cfoutput>#scrollUp#</cfoutput>

<!-- last but not least, our own logic! -->
<script src="/assets/js/dd-controller.js"></script>