//dd-controller.js

/***************

globals

***************/

/* Calendar */
var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

/* Date vars for today */
var date = new Date();
var d = date.getDate();
var m = date.getMonth();
var y = date.getFullYear();

/***************

common functions

***************/

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

// https://stackoverflow.com/questions/149055/how-can-i-format-numbers-as-dollars-currency-string-in-javascript
var currencyFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 2, /* this might not be necessary */
});

function round( value, precision ) {
  var multiplier = Math.pow( 10, precision || 0 );
  return Math.round(value * multiplier) / multiplier;
}

// https://medium.com/made-by-munsters/build-a-text-date-input-with-ngmodel-parsers-and-formatters-5b1732e0ced4
function interestRateLink( scope, element, attributes, ngModel ) {

  ngModel.$parsers.push(parser);
  ngModel.$formatters.push(formatter);

  function parser(value) {

    // TODO: incoming values  should be checked for %ages greater than 30 or less than 0 (eg 0.1 = conveting to 0.001 interest = triggering validation)
    // if ( valid ) { // FIXME: do any validation
      value /= 100;
      // ngModel.$setValidity('interest_rate', true)  // FIXME: This will flag the field on the form
    //} else {
      //value = null;
      // ngModel.$setValidity('interest_rate', false)  // FIXME: This will flag the field on the form
    //}

    return value;

  }

  function formatter(value) {
    var ret = value * 100;  // converts the decimal (parsed) to a percentage (formatted)
    return round(ret, 2);   // round & display up to 2 decimal places
  }

}

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

/*****************

the App

*****************/
ddApp

/****************

directives

*****************/
.directive('convertToNumber', function() {
  return {
    require: 'ngModel',
    link: function(scope, element, attrs, ngModel) {
      ngModel.$parsers.push(function(val) {
        return val != null ? parseInt(val,10) : null;
      });
      ngModel.$formatters.push(function(val) {
        return val != null ? '' + val : null;
      });
    }
  };
})
.directive('interestRateInput', function() {
  return {
    require: 'ngModel',
    link: interestRateLink
  }
})
.directive('dollarInput', function() {
  return {
    require: 'ngModel',
    link: function(scope, element, attrs, ngModel) {
      ngModel.$parsers.push(function(val) {
        return val != null ? parseFloat(val) : null;
      });      
      ngModel.$formatters.push(function(val) {
        return val != null ? val.toFixed(2) : null; // always display 2 decimals, include .00
      });
    }
  }
})

/***************

services

***************/
.factory('DDService', function( $http, $q ) {

  var service = {};

  service.pGetCard = function( data ) {

    var key = data.card_id;
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/card/' + key,
    })
    .then( function( response ) {

      deferred.resolve( response.data );

    });

    return deferred.promise;

  }

  service.pSaveCard = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: '/index.cfm/card/',
      data: $.param( data ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      } // set the headers so angular passing info as form data (not request payload)
    })
    .then( function( response ) {

      deferred.resolve({
        card_id: response.data
      });

    });

    return deferred.promise;

  }

  service.pDeleteCard = function( data ) {

    var in_data = data;
    var key = data.card_id;
    var deferred = $q.defer();

    $http({
      method: 'DELETE',
      url: 'index.cfm/card/' + key
    })
    .then( function onSuccess( response ) {

      // FIXME: if you're going to pass data back to the chain, this should be a card (with the right user_id) that is blank
      // (because it was deleted, remember?!?)
      deferred.resolve( in_data );

    });

    return deferred.promise;

  }

  service.pGetPlan = function( data ) {

    var key = data.user_id;
    var deferred = $q.defer();

    $http.get( '/index.cfm/plan/' + key )
    .then( function( response ) {

      deferred.resolve( response.data );

    });

    return deferred.promise;

  }

  service.pDeletePlan = function( data ) {

    var key = data.user_id;
    var deferred = $q.defer();

    // purge the plan cache whenever a card
    $http({
      method: 'DELETE',
      url: '/index.cfm/plan/' + key,
    })
    .then( function( response ) {

      // do whatever you need to do on the client to flag the cache is purged/nonexistent
      deferred.resolve({
        user_id: key
      });

    });

    return deferred.promise;

  }

  service.pSetEmergency = function( data ) {

    var e_id = data.card_id;
    var u_id = data.user_id;  // FIXME: why is this needed? you can get user_id from card_id.
    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: 'index.cfm/card/eid/' + e_id + '/uid/' + u_id,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      } // set the headers so angular passing info as form data (not request payload)
    })
    .then( function onSuccess( response ) {

      // resolve the inc. data, since this REST method doesn't return enough data to chain
      deferred.resolve( data );

    });

    return deferred.promise;

  }

  service.pSetBudget = function( data ) {

    var bud = data.budget;
    var uid = data.user_id;
    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: 'index.cfm/prefs/budget/' + bud + '/uid/' + uid,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      } // set the headers so angular passing info as form data (not request payload)
    }).then( function onSuccess( response ) {

      // resolve the inc. data, since this REST method doesn't return enough data to chain
      deferred.resolve( data );

    });

    return deferred.promise;

  }

  return service;

})

/***************

controller/main

***************/
.controller( 'ddMain' , function ( $scope, $http, $q, DDService ) {

  // init-start
  $http({
    method: 'GET',
    url: 'index.cfm/card/user_id/' + CF_getUserID()
  })
  .then( function onSuccess( response ) {

    if ( response.data.toString().indexOf('DOCTYPE') != -1) {
      throw 'TIMEOUT';
    }

    //success
    $scope.cards = response.data;

    // make an array 'keylist' of the keys in the order received (eg. 0:"10",1:"9",2:"8",3:"6",4:"2")
    $scope.keylist = Object.keys($scope.cards).sort(function(a, b){return b-a});

    for (key in $scope.keylist) {
      if ( $scope.cards[$scope.keylist[key]].is_emergency ) {
        $scope.selected = $scope.keylist[key];
      }
    }

    // chain into the preferences load
    $http({ 
      method: 'GET',
      url: '/index.cfm/prefs/uid/' + CF_getUserID()
    })
    .then( function onSuccess( response ) {

      $scope.preferences = response.data;

    })
    .catch( function onError( response ) {

      //failure
      window.location.href = '/index.cfm/login';

    });

  })
  .catch ( function onError( response ) {

    //failure
    window.location.href = 'index.cfm/login';

  }); // init-end

  /**************

  saveCard

  **************/
  $scope.saveCard = function( key, data ) {

    // https://stackoverflow.com/questions/28250680/how-do-i-access-previous-promise-results-in-a-then-chain
    var one = DDService.pSaveCard( data );
    var two = one.then( function( resultOne ) {
      DDService.pDeletePlan( data );
    });

    $q.all([one, two])
    .then( function( [resultOne, resultTwo] ) {

      // really only needs to update when it is a brand new card; safe to update on key otherwise
      $scope.cards[key].card_id = resultOne.card_id;

    });

    console.log( $scope.cards );

  };

  /**************

  setAsEmergency

  **************/
  $scope.setAsEmergency = function( eid, uid ) {

    var data = {
      card_id: eid,
      user_id: uid
    };

    DDService.pSetEmergency( data )
    .then( DDService.pDeletePlan )
    .then( function onSuccess( response ) {

      // actually set the card
      $scope.cards[eid].is_emergency = 1;

    });

  };

  /***************

  setBudget

  ***************/
  $scope.setBudget = function( id, val ) {

    var data = {
      user_id: id,
      budget: val
    };

    DDService.pSetBudget( data )
    .then( DDService.pDeletePlan )
    .then( function onSuccess( response ) {

      // actually set the budget
      $scope.preferences.budget = val;

    });

  };

  /**************

  deleteCard

  **************/
  $scope.deleteCard = function( key ) {

    var in_data = { card_id:key }

    DDService.pGetCard( in_data )
    .then( DDService.pDeleteCard )
    .then( DDService.pDeletePlan )
    .then( function onSuccess( response ) {

      delete $scope.cards[key];
      //for modern browsers ( > IE8 )
      $scope.keylist.splice( $scope.keylist.indexOf(key), 1 );

    });

  };

  /**************

  newCard

  **************/
  $scope.newCard = function( uid ) { 

    if ( $scope.keylist.length ) {
      var newid = parseInt( $scope.keylist[0] ) + 1;
    }
    else 
      var newid = parseInt(1);

    $scope.cards[ newid ] = { "user_id":uid, "card_id":0, "label":"", "is_emergency":0 };

    $scope.keylist.unshift( newid );

    console.log( $scope.keylist );

  };

  /****************

  resetCard

  ****************/
  $scope.resetCard = function( eid ) {

    var data = {
      card_id: eid
    };

    DDService.pGetCard( data )
    .then( function onSuccess( response ) {

      if ( response.card_id == 0 ) {
        delete $scope.cards[ eid ];
        // for modern browsers ( > IE8)
        $scope.keylist.splice( $scope.keylist.indexOf(eid), 1 );
      } else
        $scope.cards[ eid ] = response;

    });

  }

  /*****************

  setPayFrequency

  *****************/
  $scope.setPayFrequency = function( id, freq ) { 

    $http({
      method: 'POST',
      url: 'index.cfm/prefs/freq/' + freq + '/uid/' + id,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      } // set the headers so angular passing info as form data (not request payload)
    }).then( function onSuccess( data ) {

      // actually set the pay frequency
      $scope.preferences.pay_frequency = freq;

    });

  };

  /******************

  cardLabelCompare

  ******************/

  // FIXME: duplicate!!
  $scope.cardLabelCompare = function( v1, v2 ) {
    if ( $scope.cards[$scope.keylist[v1.index]].label > $scope.cards[$scope.keylist[v2.index]].label )
      return 1;
    if ( $scope.cards[$scope.keylist[v1.index]].label < $scope.cards[$scope.keylist[v2.index]].label )
      return -1;

    return 0;
  }

}) // controller-main

/***************

controller/plan

***************/
.controller( 'ddPlan' , function ( $scope , $http  ) {

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
  $http({ 
    method: 'GET',
    url: 'index.cfm/plan/events/' + CF_getUserID()
  }).then( function onSuccess( response ) {

    var result = response.data;

    for(var i=0; i< result.length; i++){
      $scope.events.push({
        title:result[i].title,
        start:new Date(result[i].start)
      });
    };

    $scope.schedule.push($scope.events);

  }).catch( function onError( response ) {

    //failure

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
  $http({ 
    method: 'GET',
    url: 'index.cfm/plan/miles/' + CF_getUserID()
  })
  .then( function onSuccess( response ) {

    var wins = [];
    var result = response.data;

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

        // payOffDate = Today + ( ( 1 month ) * ( Num of Months Until Payoff, Minus 1 ) )
        // FIXME: This is still not calculated correctly.
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
              return '<span style="color:' + this.color + '">\u25CF</span> ' + this.series.name + '\'s Balance: <b>' + currencyFormatter.format(this.y) + '</b><br/>';
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

  }).catch ( function onError( response ) {
    
    //failure

  });

  // Intended Step 1
  // Plan : main()
  // FIXME: separate global handler that verifies person is logged in / redirects them if fails, from plan/events/milestones init.
  $http({
      method: 'GET',
      url: 'index.cfm/plan/' + CF_getUserID()
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

}) // controller/plan

/******************

controller/pay

******************/
.controller( 'ddPay' , function ( $scope, $http, $q, $location, DDService ) {

  $scope.fail = false;

  $http({
    method: 'GET',
    url: '/index.cfm/card/user_id/' + CF_getUserID()
  }).then( function onSuccess( response ) {
    
    if ( response.data.toString().indexOf('DOCTYPE') != -1) {
      throw 'TIMEOUT';
    }

    //success
    $scope.cards = response.data;

    // make an array 'keylist' of the keys in the order received (eg. 0:"10",1:"9",2:"8",3:"6",4:"2")
    $scope.keylist = Object.keys($scope.cards).sort( function(a, b) {
      return b-a
    });

    for (key in $scope.keylist) {
      if ( $scope.cards[$scope.keylist[key]].is_emergency ) {
        $scope.selected = $scope.keylist[key];
      }
    }

    // chain into the preferences load
    $http({ 
      method: 'GET',
      url: '/index.cfm/prefs/uid/' + CF_getUserID()
    }).then( function onSuccess( response ) {

      $scope.preferences = response.data;

    }).catch( function onError( response ) {

      //failure
      //window.location.href = '/index.cfm/login';

    });

  }).catch ( function onError( response ) {
    
    //failure
    //window.location.href = '/index.cfm/login';

  });

  // compatibility bridge between angular $location and fw/1 buildUrl()
  $scope.navigateTo = function( path ) {

    //$location.url( path ); // FIXME:this is angular pro-hash navigation
    location.href = path;

  }

  $scope.panTo = function( pageIndex ) {

    AnimatePage.panForward( pageIndex );
    addHistory('AnimatePage.panBack(' + (pageIndex-1).toString() + ');','#!/nb'+(pageIndex-1).toString());

  }

  $scope.selectCard = function( cid, destIndex ) {

    var user_id = $scope.cards[cid].user_id;

    DDService.pGetPlan( { user_id: user_id } )
    .then( function( result ) {

      $scope.plan = result;
      $scope.card = $scope.plan[cid];

      console.log( $scope.card );

      AnimatePage.panForward( destIndex );
      addHistory('AnimatePage.panBack(' + (destIndex-1).toString() + ');','#!/nb'+(destIndex-1).toString());

    });

  };

  $scope.returnToList = function( destIndex ) {

    AnimatePage.panBack( destIndex );
    addHistory('AnimatePage.panForward(' + (destIndex-1).toString() + ');','#!/nb'+(destIndex-1).toString());

  }

  $scope.recalculateCard = function( data ) {

    var key = data.card_id;

    $scope.card.calculated_payment = '-'; // setting this to a non-number will trigger the || output filter on the display, which is 'Recalculating...'

    DDService.pSaveCard( data )
    .then( DDService.pGetCard )
    .then( DDService.pDeletePlan )
    .then( DDService.pGetPlan )
    .then( function( result ) {
      $scope.plan = result;
      $scope.card = $scope.plan[key];
    });

  }

  // FIXME: this shouldn't be duplicated!
  $scope.cardLabelCompare = function( v1, v2 ) {
    if ( $scope.cards[$scope.keylist[v1.index]].label > $scope.cards[$scope.keylist[v2.index]].label )
      return 1;
    if ( $scope.cards[$scope.keylist[v1.index]].label < $scope.cards[$scope.keylist[v2.index]].label )
      return -1;

    return 0;
  }

}) // controller/pay

/*****************

controller/debt

*****************/
.controller( 'ddDebt' , function ( $scope, $http, $q, $location ) {

  $scope.fail = false;
  $scope.cardTotal = 1;

  $('#pan-main').on('click', '.btn-more', function() {
    $scope.buildAndPan(this);
  });

  $('#pan-main').on('click', '.btn-submit', function() {
    $('#entry').submit();
  });

  /*
  $('#pan-main').on('click', '.btn-login', function() {
    // FIXME: location.href='#buildUrl("login.default")#';
  });
  */

  $scope.buildAndPan = function() {
    $scope.cardTotal++;
    var cards = $scope.cardTotal;
    AnimatePage.panForward(cards);
    addHistory('AnimatePage.panBack(' + parseInt(cards-1) + ');','#!/nb'+(cards-1).toString());
    AnimatePage.addAnother();
  }

  // compatibility bridge between angular $location and fw/1 buildUrl()
  $scope.navigateTo = function( path ) {
    //$location.url( path ); // FIXME:this is angular pro-hash navigation
    location.href = path;
  }

  $scope.panTo = function( pageIndex ) {
    AnimatePage.panForward( pageIndex );
    addHistory('AnimatePage.panBack(' + pageIndex + ');','#!/nb'+pageIndex.toString());
  }

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

  $scope.getTempSchedule = function() {
    
    $http.get( '/index.cfm/debt/miles/' )
    .then( function onSuccess( response ) {

      var result = response.data;
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
      if (result.length)
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
                return '<span style="color:' + this.color + '">\u25CF</span> ' + this.series.name + '\'s Balance: <b>' + currencyFormatter.format(this.y) + '</b><br/>';
              }
            },
            animation: {
              duration: 6200,
              //easing: 'easeOutBounce'
            }
          }
        },

        series: result

      });

    });
  
  };

  

  // Intended Step 1
  // Plan : main()
  // FIXME: separate global handler that verifies person is logged in / redirects them if fails, from plan/events/milestones init.
  
  $scope.getTempPlan = function() {
    $http({
      method: 'GET',
      url: '/index.cfm/debt/list/'
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
    });

  };
  
}); // controller/debt