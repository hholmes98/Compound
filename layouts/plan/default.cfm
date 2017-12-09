<!--- layouts/plan/default --->
<cfparam name="rc.message" default="#arrayNew(1)#">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html ng-app="ddApp" xmlns="http://www.w3.org/1999/xhtml">
<head>
	
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#application.app_name#</cfoutput></title>

	<!-- styles -->	
  <link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
  <link href="/node_modules/fullcalendar/dist/fullcalendar.css" rel="stylesheet">

  <!-- scripts -->
	<script src="/jquery/js/jquery-1.7.2.min.js" type="text/javascript"></script>
  <script src="/bootstrap/js/bootstrap.js"></script>

	<script src="/angular/angular.min.js" type="text/javascript"></script>
  <script src="/angular/ui-bootstrap-tpls-0.13.0.min.js"></script>

	<script src="/node_modules/moment/min/moment.min.js" type="text/javascript"></script>

	<!-- calendar -->	
	<script type="text/javascript" src="/node_modules/angular-ui-calendar/src/calendar.js"></script>
	<script type="text/javascript" src="/node_modules/fullcalendar/dist/fullcalendar.min.js"></script>
	<script type="text/javascript" src="/node_modules/fullcalendar/dist/gcal.js"></script>

	<!-- graphing -->
	<script type="text/javascript" src="/node_modules/highcharts/highstock.js"></script>

	<script>
	var ddApp = angular.module('ddApp', ['ui.calendar', 'ui.bootstrap']);
	</script>
	
</head>
<body>
<nav class="navbar navbar-inverse navbar-static-top" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <span class="navbar-brand">
	     <cfoutput>#application.app_name#</cfoutput>
      </span>
    </div>

    <div class="collapse navbar-collapse" id="bs-esample-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li><cfoutput><a href="#buildUrl('main')#">Update</a></cfoutput></li>
        <li class="active"><cfoutput><a href="#buildUrl('plan')#"></cfoutput>Plan <span class="sr-only">(current)</span></a></li>
        <li><cfoutput><a href="#buildUrl('pay')#">Pay</a></cfoutput></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li><cfoutput><a href="#buildUrl('login.logout')#"></cfoutput>Logout</a></li>
      </ul>
    </div>
  </div>
</nav>

<div class="container">	
		<cfoutput>
			<!--- display any messages to the user --->
			<cfif not arrayIsEmpty(rc.message)>
				<cfloop array="#rc.message#" index="msg">
					<p>#msg#</p>
				</cfloop>
			</cfif>

			#body#
		</cfoutput>
</div>

</body>
<script>
// https://stackoverflow.com/questions/149055/how-can-i-format-numbers-as-dollars-currency-string-in-javascript
var formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 2, /* this might not be necessary */
});

ddApp.controller( 'ddCtrl' , function ( $scope , $http  ) {

	/* Calendar */
 	  var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();

    // for the calendar init
    $scope.eventSources = [];
    $scope.events = [];

    $http.get( 'index.cfm/plan/events/<cfoutput>#session.auth.user.getUser_id()#</cfoutput>' ).success( function( data ) { 

      for(var i=0; i< data.length; i++){
        $scope.events.push({
          title:data[i].title,
          start:new Date(data[i].start)    
        });
      };

      $scope.eventSources.push($scope.events);

    });
 
    
  $scope.changeTo = 'Hungarian';
    
  /*
    $scope.calEventsExt = {
       color: '#f00',
       textColor: 'yellow',
       events: [ 
          {type:'party',title: 'Lunch',start: new Date(y, m, d, 12, 0),end: new Date(y, m, d, 14, 0),allDay: false},
          {type:'party',title: 'Lunch 2',start: new Date(y, m, d, 12, 0),end: new Date(y, m, d, 14, 0),allDay: false},
          {type:'party',title: 'Click for Google',start: new Date(y, m, 28),end: new Date(y, m, 29),url: 'http://google.com/'}
        ]
    };
    */
    
    /* alert on eventClick */
    $scope.alertOnEventClick = function( date, jsEvent, view ){
        $scope.alertMessage = (date.title + ' was clicked ');
    };
    
    /* alert on Drop */
    /*
     $scope.alertOnDrop = function(event, delta, revertFunc, jsEvent, ui, view){
       $scope.alertMessage = ('Event Droped to make dayDelta ' + delta);
    };
    */
   
    /* alert on Resize */
    /*
    $scope.alertOnResize = function(event, delta, revertFunc, jsEvent, ui, view ){
       $scope.alertMessage = ('Event Resized to make dayDelta ' + delta);
    };
    */
    
    /* add and removes an event source of choice */
    /*
    $scope.addRemoveEventSource = function(sources,source) {
      var canAdd = 0;
      angular.forEach(sources,function(value, key){
        if(sources[key] === source){
          sources.splice(key,1);
          canAdd = 1;
        }
      });
      if(canAdd === 0){
        sources.push(source);
      }
    };
    */
    
    /* add custom event*/
    /*
    $scope.addEvent = function() {
      $scope.events.push({
        title: 'Open Sesame',
        start: new Date(y, m, 28),
        end: new Date(y, m, 29),
        className: ['openSesame']
      });
    };
    */
    
    /* remove event */
    /*
    $scope.remove = function(index) {
      $scope.events.splice(index,1);
    };
    *?
    
    /* Change View */
    /*
    $scope.changeView = function(view,calendar) {
      uiCalendarConfig.calendars[calendar].fullCalendar('changeView',view);
    };
    */
    
    /* Change View */
    /*
    $scope.renderCalender = function(calendar) {
      if(uiCalendarConfig.calendars[calendar]){
        uiCalendarConfig.calendars[calendar].fullCalendar('render');
      }
    };
    */
    
    /* Render Tooltip */
    /*
    $scope.eventRender = function( event, element, view ) { 
        element.attr({'tooltip': event.title,
                     'tooltip-append-to-body': true});
        //$compile(element)($scope);
    };
    */
    
    /* config object */
    $scope.uiConfig = {
      calendar:{
        eventClick: $scope.alertOnEventClick,
      }
    };
 
    /*
    $scope.changeLang = function() {
      if($scope.changeTo === 'Hungarian'){
        $scope.uiConfig.calendar.dayNames = ["Vasárnap", "Hétfő", "Kedd", "Szerda", "Csütörtök", "Péntek", "Szombat"];
        $scope.uiConfig.calendar.dayNamesShort = ["Vas", "Hét", "Kedd", "Sze", "Csüt", "Pén", "Szo"];
        $scope.changeTo= 'English';
      } else {
        $scope.uiConfig.calendar.dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        $scope.uiConfig.calendar.dayNamesShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        $scope.changeTo = 'Hungarian';
      }
    };
    */
    
    /* event sources array*/
    //$scope.eventSources = [$scope.events, $scope.eventSource, $scope.eventsF];
    
    //$scope.eventSources2 = [$scope.calEventsExt, $scope.eventsF, $scope.events];

    /********
    charting
    ********/

      $http.get( 'index.cfm/plan/sched/<cfoutput>#session.auth.user.getUser_Id()#</cfoutput>' ).success( function( data ) { 

        $scope.schedule = data;

        $scope.milestones = Highcharts.stockChart('milestones', {

          title: {
            text: 'Payoff Milestones'
          },

          rangeSelector: {
            enabled: false
          },

          // this is the visual display of the spline graph, and will only visibly show a smaller, selected range of the full timeline
          xAxis: {
            type: 'datetime',
            ordinal: false,
            min: Date.UTC(y,m,1), // note: initial range start (today)
            max: Date.UTC(y,m+4,1)   // TODO: calculate this range to be 1/5th of the complete timeline (so that the initial selection 1/5th of the navigator bar)
          },

          // this start and end should be equal-to-or-longer than the visual display of the spline (set above in xAxis)
          navigator: {
            xAxis: {
              type: 'datetime',
              ordinal: false,
              min: Date.UTC(y,m,1), // full range start (today)
              tickInterval: 2 * 30 * 24 * 3600 * 1000 // a tick every 2 month
            }
          },

          yAxis: {
            type: 'linear',
            min: 0
          },

          plotOptions: {
            series: {
              pointStart: Date.UTC(y,m,1), // we begin plotting on the 1st of the current month
              pointIntervalUnit: 'month',  // every point along the x axis represents 1 month
              tooltip: {
                pointFormatter: function() {
                  return '<span style="color:' + this.color + '">\u25CF</span> ' + this.series.name + '\'s Balance: <b>' + formatter.format(this.y) + '</b><br/>';
                }
              }
            }
          },

          series : $scope.schedule

        });

      });


    /*******
    main
    ********/

    /* PC : Note to future self
	if you make any tab *other* than the calendar tab active by default, the calendar won't render until "today" is
	clicked.

	there are online workarounds for this, so be aware you may need to leverage one.
    */

    /*
  $http.get( 'index.cfm/plan/' ).success( function( data ) { 

		$scope.cards = data;

		// make an array 'keylist' of the keys in the order received (eg. 0:"10",1:"9",2:"8",3:"6",4:"2")
		$scope.keylist = Object.keys($scope.cards).sort(function(a, b){return b-a});

		for (key in $scope.keylist) {
			if ( $scope.cards[$scope.keylist[key]].is_emergency ) {
				$scope.selected = $scope.keylist[key];
			}
		}

		// chain into the preferences load
		$http.get( 'index.cfm/prefs/' ).success( function ( data ) {

			$scope.preferences = data;

		});

	});
  */

  $http({
    method: 'GET',
    url: 'index.cfm/plan/<cfoutput>#session.auth.user.getUser_Id()#</cfoutput>' 
  }).then( function onSuccess( response ) {
    
    if ( response.data.toString().indexOf('DOCTYPE') != -1) {
      throw 'TIMEOUT';
    }

    $scope.cards = response.data;

    // make an array 'keylist' of the keys in the order received (eg. 0:"10",1:"9",2:"8",3:"6",4:"2")
    $scope.keylist = Object.keys($scope.cards).sort(function(a, b){return b-a});

    for (key in $scope.keylist) {
      if ( $scope.cards[$scope.keylist[key]].is_emergency ) {
        $scope.selected = $scope.keylist[key];
      }
    }

    // chain into the preferences load
    $http.get( 'index.cfm/prefs/uid/<cfoutput>#session.auth.user.getUser_Id()#</cfoutput>' ).success( function ( data ) {

      $scope.preferences = data;

    });

  }).catch ( function onError( response ) {
    //failure
    window.location.href = 'index.cfm/login';

  });  

});

</script>
</html>