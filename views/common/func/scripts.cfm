<!--- scripts.cfm --->
<cfparam name="scrollUp" default="" />

<!-- CDNs -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>

<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.6.7/angular.min.js" type="text/javascript"></script>

<cfif getEnvironment() is 'development'>
  <script src="/node_modules/bootstrap/dist/js/bootstrap.js"></script>
<cfelse>
  <script src="/node_modules/bootstrap/dist/js/bootstrap.min.js"></script>
</cfif>
<script src="//cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.14.3/ui-bootstrap-tpls.js"></script>

<!--- http://www.bootstraptoggle.com/ --->
<script src="//ziscloud.github.io/angular-bootstrap-toggle/js/angular-bootstrap-toggle.min.js"></script>

<!-- font awesome -->
<script defer src="//use.fontawesome.com/releases/v5.0.8/js/all.js"></script>

<!-- dialogs -->
<script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap3-dialog/1.34.7/js/bootstrap-dialog.min.js"></script>

<!-- Locals -->
<!--- <script src="/node_modules/propellerkit/dist/js/propeller.js"></script> --->
<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angularjs-slider/dist/rzslider.js"></script>
<cfelse>
  <script src="/node_modules/angularjs-slider/dist/rzslider.min.js"></script>
</cfif>

<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angular-tooltips/dist/angular-tooltips.js"></script>
<cfelse>
  <script src="/node_modules/angular-tooltips/dist/angular-tooltips.min.js"></script>
</cfif>

<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angular-sanitize/angular-sanitize.js"></script>
<cfelse>
  <script src="/node_modules/angular-sanitize/angular-sanitize.min.js"></script>
</cfif>

<cfif getEnvironment() is 'development'>
  <script src="/node_modules/angular-cookies/angular-cookies.js"></script>
<cfelse>
  <script src="/node_modules/angular-cookies/angular-cookies.min.js"></script>
</cfif>

<!-- date handling -->
<script src="/node_modules/moment/min/moment.min.js" type="text/javascript"></script>

<!-- fullpage animation -->
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

<!-- calendar --> 
<script src="/node_modules/angular-ui-calendar/src/calendar.js" type="text/javascript"></script>
<cfif getEnvironment() is 'development'>
  <script src="/node_modules/fullcalendar/dist/fullcalendar.js" type="text/javascript"></script>
  <script src="/node_modules/fullcalendar/dist/gcal.js" type="text/javascript"></script>
<cfelse>
  <script src="/node_modules/fullcalendar/dist/fullcalendar.min.js" type="text/javascript"></script>
  <script src="/node_modules/fullcalendar/dist/gcal.min.js" type="text/javascript"></script>
</cfif>

<!-- graphing -->
<script src="/node_modules/highcharts/highstock.js" type="text/javascript"></script>

<!-- payment gateway/fraud detection -->
<script src="https://js.stripe.com/v3/"></script>

<script>
  var ddApp = angular.module('ddApp', ['ngSanitize', 'ngCookies', 'ui.calendar', 'ui.bootstrap', '720kb.tooltips', 'ui.toggle', 'rzModule']);
</script>

<cfoutput>#scrollUp#</cfoutput>

<!-- last but not least, our own logic! -->
<script src="/assets/js/dd-controller.js"></script>