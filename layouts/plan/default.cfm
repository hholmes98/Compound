<!--- layouts/plan/default --->
<cfparam name="rc.message" default="#ArrayNew(1)#">

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

// http://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/plotoptions/series-animation-easing/
Math.easeOutBounce = function (pos) {
    if ((pos) < (1 / 2.75)) {
        return (7.5625 * pos * pos);
    }
    if (pos < (2 / 2.75)) {
        return (7.5625 * (pos -= (1.5 / 2.75)) * pos + 0.75);
    }
    if (pos < (2.5 / 2.75)) {
        return (7.5625 * (pos -= (2.25 / 2.75)) * pos + 0.9375);
    }
    return (7.5625 * (pos -= (2.625 / 2.75)) * pos + 0.984375);
};

// take an arbitrary fixed index, and return a color. allows color syncing across disparate arrays. supports an array of any length
function getColor(index) {

  // highcharts 3.x
  var masterColors3 = ['#2f7ed8', '#0d233a', '#8bbc21', '#910000', '#1aadce', '#492970', '#f28f43', '#77a1e5', '#c42525', '#a6c96a'];

  // highcharts 2.x
  var masterColors2 = ['#4572A7', '#AA4643', '#89A54E', '#80699B', '#3D96AE', '#DB843D', '#92A8CD', '#A47D7C', '#B5CA92'];

  // highcarts default
  var masterColors = ["#7cb5ec", "#434348", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#2b908f", "#f45b5b", "#91e8e1"];

  var all = masterColors.concat(masterColors2.concat(masterColors3));

  return ( all[ index % all.length ] );

}

// Angular Controller
ddApp.controller( 'ddCtrl' , function ( $scope , $http  ) {

  /* Calendar */
  var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  var date = new Date();
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();

  // Calendar: for the calendar init
  $scope.schedule = [];
  $scope.events   = [];

  // Calendar: alert on eventClick
  $scope.alertOnEventClick = function( date, jsEvent, view ){
      $scope.alertMessage = date.title;
  };
  
  // Calendar: config object
  $scope.uiConfig = {
    calendar:{
      eventClick: $scope.alertOnEventClick,
    }
  };  

  // FIXME : Plan, Calendar, and Chart init() should all be promise-chained
  // Intended Step 2
  // Calendar: main()
  $http.get( 'index.cfm/plan/events/<cfoutput>#session.auth.user.getUser_id()#</cfoutput>' ).success( function( data ) { 

    for(var i=0; i< data.length; i++){
      $scope.events.push({
        title:data[i].title,
        start:new Date(data[i].start)
      });
    };

    $scope.schedule.push($scope.events);

  });
  
  /* Chart */

  /*
    format is:
    
    [
      {
        id: 'id_1',
        name: 'name of card',
        data:
        [
          100.00, 75.00, 50.00, 25.00, 10.00, 5.00, 2.50, 1.00  // balance at the end of each month
        ],
      },
      {
        id: 'id_2',
        name: 'name of card 2',
        data:
        [
          100.00, 75.00, 50.00, 25.00, 10.00, 5.00, 2.50, 1.00  // balance at the end of each month
        ],
      },
      ...
      {
        id: 'milestone_1',
        type: 'flags',
        data:
        [
        ],
        onSeries: 'id_1',  // the id of the data that just ended - ran out of data[]
        shape: 'circlepin',
        width: 16
      }
    ]

  */

  // Chart: main()
  // Intended Step 3
  // FIXME: this should be $http.jsonp(), whitelist the URL: https://docs.angularjs.org/api/ng/service/$http#jsonp
  $http.get( 'index.cfm/plan/sched/<cfoutput>#session.auth.user.getUser_Id()#</cfoutput>' ).success( function( result ) {

    var wins = [];

    for (var i=0; i<result.length;i++) {

      // inject id
      result[i]['id'] = 'id_' + i;

      // inject color
      result[i]['color'] = getColor(i);

      // if this card has elements...
      if ( result[i].data.length > 0 ) {

        // ..it needs one more element to indicate $0.00
        result[i].data.push(0);

        // ..and it needs a partner series to display a milestone flag
        var win = {
          id: 'milestone_' + i,
          type: 'flags',      
          shape: 'squarepin',
          width: 82,
          onSeries: 'id_' + i,
          tooltip: {
            pointFormatter: function() {
              return this.text;
            }
          },
          data: []
        };

        payOffDate = Date.UTC(y,m,1) + ( (30 * 24 * 3600 * 1000) * (result[i].data.length-1) ); // fixme: couldn't i use the actual plan's payoff date, and convert this, since it is going to change for certain folks, based on their pay periods?
        dateReadable = new Date(payOffDate);

        win.data.push({
          color: getColor(i),
          x: payOffDate,
          title: 'CHECKPOINT!!',
          text: (result[i].name + ' paid off in: <b>' + monthNames[dateReadable.getMonth()] + ' of ' + dateReadable.getFullYear() + '</b>' )
        });

        wins.push(win);

      }

    }

    // cat the two arrays together
    result = result.concat(wins);

    Highcharts.stockChart('milestones', {

      title: {
        text: 'Payoff Milestones'
      },

      chart: {
        type: 'spline'
      },

      rangeSelector: {
        enabled: false
      },

      // this is the visual display of the spline graph, and will only visibly show a smaller, selected range of the full timeline
      xAxis: {
        type: 'datetime',
        ordinal: false,
        min: Date.UTC(y,m,1),     // note: initial range start (today)
        max: Date.UTC(y,m+4,1),    // TODO: calculate this range to be 1/5th of the complete timeline (so that the initial selection 1/5th of the navigator bar)
        //tickInterval: 30 * 24 * 3600 * 1000 // a tick every month
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

      tooltip: {
        split: true,
        distance: 70, // undocumented, distance in pixels away from the point (calculated either + or -, based on best positioning of cursor)
        padding: 5
      },

      plotOptions: {
        series: {
          pointStart: Date.UTC(y,m,1), // we begin plotting on the 1st of the current month
          pointIntervalUnit: 'month',  // every point along the x axis represents 1 month
          tooltip: {
            pointFormatter: function() {
              return '<span style="color:' + this.color + '">\u25CF</span> ' + this.series.name + '\'s Balance: <b>' + formatter.format(this.y) + '</b><br/>';
            }
          },
          animation: {
            duration: 6200,
            //easing: 'easeOutBounce'
          }
        }
      },

      series: result

      /*
      REF 1 (adding something on the end): http://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/point/datalabels/
      REF 2 (a 2nd series of flags): http://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/stock/demo/flags-general/
      REF 3 (multiple series, loaded asynchronously): http://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/stock/demo/compare/
      REF 4 (diff flags on diff series): http://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/stock/demo/flags-placement/
      */

    });

  });

  // Intended Step 1
  // Plan : main()
  // FIXME: separate global handler that verifies person is logged in / redirects them if fails, from plan/events/milestones init.
  $http({
      method: 'GET',
      url: 'index.cfm/plan/<cfoutput>#session.auth.user.getUser_Id()#</cfoutput>' 
  }).then( function onSuccess( response ) {
  
    if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
      throw 'TIMEOUT';
    }

    $scope.plan = response.data;

    // make an array 'keylist' of the keys in the order received (eg. 0:"10",1:"9",2:"8",3:"6",4:"2")
    $scope.keylist = Object.keys($scope.plan).sort(function(a, b){return b-a});

    for (card in $scope.keylist) {
      if ( $scope.plan[$scope.keylist[card]].is_emergency ) {
        $scope.selected = $scope.keylist[card];
      }
    }

  }).catch ( function onError( response ) {

    //failure
    window.location.href = 'index.cfm/login';

  });  

}); // controller
</script>
</html>