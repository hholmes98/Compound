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

function daysInMonth( month, year ) {
  return new Date(year, month, 0).getDate();
}

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
  style: 'decimal',
  minimumFractionDigits: 2
});

function round( value, precision ) {
  var multiplier = Math.pow( 10, precision || 0 );
  return Math.round(value * multiplier) / multiplier;
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

function fixDate( date ) {
  return new Date(date);
};


/*******************

common (directives)

*******************/

function stringToNumberLink( scope, element, attrs, ngModel ) {

  ngModel.$parsers.push(parser);
  ngModel.$formatters.push(formatter);

  // in to model
  function parser(val) {
    return val != null ? parseInt(val,10) : null;
  }

  // out to display
  function formatter(val) {

    if (val < 0) {
      console.warn("WARNING! stringToNumber formatted a negative integer as an empty string instead of displaying " + val + "!");
      return "";
    } else {
      return (val != null) ? '' + val : null;
    }
  }

}

// https://medium.com/made-by-munsters/build-a-text-date-input-with-ngmodel-parsers-and-formatters-5b1732e0ced4
function interestRateLink( scope, element, attributes, ngModel ) {

  ngModel.$parsers.push(parser);
  ngModel.$formatters.push(formatter);

  ngModel.$validators.interestRate = function(modelVal, viewVal) {

    var myVal = modelVal || viewVal;
    return /^[\d|,|.]+$/.test(myVal);

  };

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

function dollarLink( scope, element, attr, ngModel ) {

  ngModel.$parsers.push(parser);
  ngModel.$formatters.push(formatter);

  ngModel.$validators.dollarInput = function(modelVal, viewVal) {

    var myVal = viewVal; // we care about validating the view.
    return /^[\d|,|.]+$/.test(myVal);

  };

  // in to model
  function parser(val) {
    return val != null ? parseFloat(val.replace(/,/g,"")) : null;
  }

  // out to display
  function formatter(val) {
    return val != null ? currencyFormatter.format(val.toString().replace(/,/g,"")) : null; // always display 2 decimals, include .00
  }

}

function payDateLink( scope, element, attr, ngModel ) {

  ngModel.$formatters.push(formatter);

  // out to display
  function formatter(val) {
    return val != null ? fixDate(val) : null;
  }

}

function dateLink( scope, element, attr, ngModel ) {

  ngModel.$parsers.push(parser);
  ngModel.$formatters.push(formatter);

  // in to model
  function parser(val) {

    // reset validity (really?)
    ngModel.$setValidity('date', true);
    ngModel.$setValidity('min', true);

    if (val == null)
      return null;

    if (moment("1900-01-01","YYYY-MM-DD").isSame(val))
      return null;

    if (moment().isAfter(val)) {
      ngModel.$setValidity('date', true);
      ngModel.$setValidity('min', false);
    }

    return new Date(val);

  }

  // out to display
  function formatter(val) {

    // reset validity (really?)
    ngModel.$setValidity('date', true);
    ngModel.$setValidity('min', true);

    if (val == null)
      return null;

    if (moment("1900-01-01","YYYY-MM-DD").isSame(val))
      return null;

    if (moment().isAfter(val)) {
      ngModel.$setValidity('date', true);
      ngModel.$setValidity('min', false);
    }

    return fixDate(val);

  }

}

/*****************

the App

*****************/
ddApp

/****************

config

****************/
.config(['$uibTooltipProvider', function($uibTooltipProvider) {

  $uibTooltipProvider.setTriggers({
    'mouseenter': 'mouseleave',
    'click': 'click',
    'focus': 'blur',
    'never': 'mouseleave'
  });

  $uibTooltipProvider.options({
    'popupCloseDelay': 3000
  });

}])

/****************

directives

*****************/
.directive('convertToNumber', function() {
  return {
    require: 'ngModel',
    link: stringToNumberLink
  };
})
.directive('interestRateInput', function() {
  return {
    require: 'ngModel',
    link: interestRateLink
  };
})
.directive('dollarInput', function() {
  return {
    require: 'ngModel',
    link: dollarLink
  };
})
.directive('dateInput', function() {
  return {
    require: 'ngModel',
    link: dateLink
  }
})
.directive('stripeForm', function() {

  stripe = Stripe(CF_getPublicStripeKey());

  function stripeLink(scope, element, attrs) {

    scope.submitCard = submitCard;

    var elements = stripe.elements();

    var style = {
      base: {
        fontSize: '16px',
        color: "#32325d"
      }
    };

    var card = elements.create('card', {style: style});
    card.mount('#card-element');

    // Handle real-time validation errors from the card Element.
    card.on('change', function(event) {
      setOutcome(event);
    });

    // Form Submit Button Click
    function submitCard() {
      var errorElement = document.getElementById('card-errors');
      createToken();
    }

    // Send data directly to stripe server to create a token (uses stripe.js)
    function createToken() {
      stripe.createToken(card)
      .then(setOutcome);
    }

    // Common SetOutcome Function
    function setOutcome(result) {
      var errorElement = document.getElementById('card-errors');
      if (result.token) {
        // Use the token to create a charge or a customer
        stripeTokenHandler(result.token);
      } else if (result.error) {
        errorElement.textContent = result.error.message;
      } else {
        errorElement.textContent = '';
      }
    }

    // Response Handler callback to handle the response from Stripe server
    function stripeTokenHandler(token) {

      var data = {
        stripeToken: token.id
      };

      scope.updatePayment(data);

    }
  }

  // DIRECTIVE
  return {
    restrict: 'A',
    replace: true,
    link: stripeLink
  }
})

/***************

filters

***************/
.filter('calculatedPaymentFilter', function( $sce ) {

  return function(number) {
    if ( isNaN(number) )
      return number;
    else if ( number < 0 )
      return $sce.trustAsHtml("<span style='color:red;'>CALL<sup><i class='far fa-question-circle'></i></sup></span>");
    else
      return "$"+currencyFormatter.format(number);
  };

})
.filter('noPaymentFilter', function() {

  function zeroPayFilter( items, pick_list, all ) {

    var filtered = [];
    var picked = pick_list;

    angular.forEach( items, function( item, key, items ) {
      if ( !all ) {
        if ( Object.keys(picked).find(key=>key == item.card_id) ) {
          item.pay_date = picked[item.card_id];
          filtered.push( item );
        }
      } else {
        if ( Object.keys(picked).find(key=>key == item.card_id ) ) {
          item.pay_date = picked[item.card_id];
        }
        filtered.push( item );
      }
    });

    return filtered;

  }

  zeroPayFilter.$stateful = true;

  return zeroPayFilter;

})
.filter('prettyPayDateFilter', function() {

  return function(date) {
    if (date == undefined)
      return "-";
    else
      return new Date(date);
  }

})
/***************

sorters (filters)

***************/
.filter('cardSorter', function() {

  function CustomOrder( left, right, field ) {

    switch(field) {

      case 'pay_date':
        if ( left[field] > right[field] || left[field] == null )
          return 1;
        if ( left[field] < right[field] || right[field] == null )
          return -1;

        break;

      default:
        if ( left[field] > right[field] )
          return 1;
        if ( left[field] < right[field] )
          return -1;

        break;

    }

    return 0;
  }

  return function( items, field, reverse ) {

    var filtered = [];

    angular.forEach(items, function( item, key, items ) {
      filtered.push( item );
    });

    filtered.sort(function( card_a, card_b ) {
      return ( CustomOrder( card_a, card_b, field ) );
    });

    if ( reverse )
      filtered.reverse();

    return filtered;

  };

})

/***************

services

***************/
.factory('DDService', function( $http, $q ) {

  var service = {};

  // *******
  // CRUD
  // *******

  /* CARD */
  service.pGetCards = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/deck/list/user_id/' + key,
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        user_id: key,
        cards: response.data,
        chain: data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetCard = function( data ) {

    var key = deepGet(data,'card_id');
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/deck/detail/id/' + key,
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        card: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pSaveCard = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: '/index.cfm/deck/save',
      data: $.param( data ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST POST Error' );
      }

      deferred.resolve({
        card_id: response.data,
        chain: data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pDeleteCard = function( data ) {

    var key = deepGet(data,'card_id');
    var deferred = $q.defer();

    $http({
      method: 'DELETE',
      url: 'index.cfm/deck/delete/id/' + key
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST DELETE Error' );
      }

      deferred.resolve({
        data: 0,
        chain: data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  /* PLAN */
  service.pGetPlan = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/plans/first/user_id/' + key,
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        user_id: key,
        plan: response.data,
        chain: data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.error,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetTempPlan = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/main/list/'
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        plan: response.data,
        chain: data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.error,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pDeletePlans = function( data ) {

    var key = deepGet(data, 'user_id');
    var deferred = $q.defer();

    $http({
      method: 'DELETE',
      url: '/index.cfm/plans/purge/user_id/' + key,
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST DELETE Error' );
      }

      deferred.resolve({
        user_id: key,
        data: 0
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  /* EVENT */
  service.pGetEvents = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/events/list/user_id/' + key
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      deferred.resolve({
        user_id: key,
        chain: data,
        events: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetEvent = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/events/first/user_id/' + key
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        user_id: key,
        chain: data,
        event: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetSchedule = function ( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/events/schedule/user_id/' + key
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        user_id: key,
        chain: data,
        schedule: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetTempSchedule = function ( data ) {

    var deferred = $q.defer();

    $http({
      method: 'GET',
      url: '/index.cfm/main/journey/'
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        chain: data,
        schedule: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetJourney = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    // FIXME: this should be $http.jsonp(), whitelist the URL: https://docs.angularjs.org/api/ng/service/$http#jsonp
    $http({
      method: 'GET',
      url: '/index.cfm/events/journey/user_id/' + key
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        user_id: key,
        chain: data,
        journey: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pDeleteJourney = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
      method: 'DELETE',
      url: '/index.cfm/events/purge/user_id/' + key,
    })
    .then( function( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST DELETE Error' );
      }

      deferred.resolve({
        user_id: key,
        data: 0,
        chain: data
      });

    })
    .catch( function( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  /* PREFERENCES */
  service.pSetEmergency = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: 'index.cfm/deck/emergency',
      data: $.param( data ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      } // set the headers so angular passing info as form data (not request payload)
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST POST Error' );
      }

      deferred.resolve({
        user_id: data.user_id,
        chain: data,
        data: response.data
      });

    })
    .catch( function onError( result ) {

      deferred.reject({
        error: result.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pGetPreferences = function( data ) {

    var key = deepGet(data,'user_id');
    var deferred = $q.defer();

    $http({
        method: 'GET',
        url: '/index.cfm/preferences/get/user_id/' + key
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        preferences: response.data,
        user_id: key,
        chain: data
      });

    })
    .catch( function onError( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  service.pValidatePreferences = function( data ) {

    var deferred = $q.defer();

    if (data.budget >= data.total_min_payment) {
      deferred.resolve(data); // passthrough
    } else {

      BootstrapDialog.show({
          size: BootstrapDialog.SIZE_LARGE,
          type: BootstrapDialog.TYPE_WARNING,
          closable: false,
          closeByBackdrop: false,
          closeByKeyboard: false,
          title: 'A matter needs your immediate attention!!',
          message: 'You\'ve entered a budget ($'+ currencyFormatter.format(data.budget) +') that\'s smaller than the total of all your minimum payments. If you do this, your payoff schedule will be much longer than it needs to be!\n\n<b>Should we keep it like this?<\/b>',
          buttons: [{
              label: 'Yes, keep my budget at $' + currencyFormatter.format(data.budget),
              cssClass: 'btn-success pull-left',
              action: function( dialogItself ) {
                deferred.resolve( data );
                dialogItself.close();
              }
          }, {
              label: 'No, go back to what it was',
              cssClass: 'btn-danger',
              action: function( dialogItself ) {
                deferred.reject( data );
                dialogItself.close();
              }
          }]
      });

    }

    return deferred.promise;

  };

  service.pSetPreferences = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: '/index.cfm/preferences/save/',
      data: $.param( data ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      } // set the headers so angular passing info as form data (not request payload)
    })
    .then( function( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST POST Error' );
      }

      deferred.resolve({
        data: response.data,
        user_id: data.user_id,
        chain: data
      });

    })
    .catch( function( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  };

  /* userPurchase */
  service.pSavePaymentInfo = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: '/index.cfm/profile/savePaymentInfo',
      data: $.param( data ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
    .then( function(response) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST POST Error' );
      }

      deferred.resolve({
        data: response.data,
        user_id: CF_getUserID(), // don't do this, please. for the love of god.
        chain: data
      });

    })
    .catch( function( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  }

  /* cardPaid */
  service.pGetCardPayments = function( data ) {

    /* event_ids are too volatile, as they're purged on every update
    what is constant is the month and year for each event. Use those as
    the lookup */

    var key = deepGet(data,'user_id');
    var month = deepGet(data,'payment_for_month');
    var year = deepGet(data,'payment_for_year');

    var deferred = $q.defer();

    $http({
        method: 'GET',
        url: '/index.cfm/deck/getCardPayments/user_id/' + key + '/month/' + month + '/year/' + year
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        card_payments: response.data,
        user_id: key,
        chain: data
      });

    })
    .catch( function onError( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  }

  service.pGetCardPayment = function( data ) {

    var key = deepGet(data,'card_id');
    var month = deepGet(data,'payment_for_month');
    var year = deepGet(data,'payment_for_year');

    var deferred = $q.defer();

    $http({
        method: 'GET',
        url: '/index.cfm/deck/getCardPayments/card_id/' + key + '/month/' + month + '/year/' + year
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        card_payment: response.data,
        user_id: key,
        chain: data
      });

    })
    .catch( function onError( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  }

  service.pSaveCardPayment = function( data ) {

    var deferred = $q.defer();

    $http({
      method: 'POST',
      url: '/index.cfm/deck/saveCardPayment',
      data: $.param( data ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
    .then( function(response) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST POST Error' );
      }

      deferred.resolve({
        data: response.data,
        user_id: data.user_id,
        chain: data
      });

    })
    .catch( function( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  }

  service.pGenerateDesign = function( data ) {

    //var key = deepGet(data,'card_id');
    //var month = deepGet(data,'payment_for_month');
    //var year = deepGet(data,'payment_for_year');

    var dest_url = '/index.cfm/deck/getNewDesign';
    var deferred = $q.defer();
    var code = deepGet(data,'code');
    if (code != null && code != "")
      dest_url = dest_url + '/code/' + code;

    $http({
        method: 'GET',
        url: dest_url
    })
    .then( function onSuccess( response ) {

      if ( response.data.toString().indexOf('DOCTYPE') != -1 ) {
        throw new Error( 'REST Error' );
      }

      if ( response.data == -1 ) {
        throw new Error( 'REST GET Error' );
      }

      deferred.resolve({
        code: response.data.code,
        css: response.data.css,
        user_id: CF_getUserID(),
        chain: data
      });

    })
    .catch( function onError( e ) {

      deferred.reject({
        error: e.data,
        chain: data
      });

    });

    return deferred.promise;

  }

  // I dunno how i feel about this
  function deepGet(source, key) {

    // 1. look at any/all the keys of the base obj - eg. try to find source.key (data.user_id)
    var io = Object.keys(source);

    for (var iobj in io) {  // for all the keys in the source

      // is this key the same as the key we're looking for? (eg. 'user_id')
      if (io[iobj] == key) {
        if (source[io[iobj]] != null) { // does this key actually have a value in source? (eg. source.user_id)
          return source[io[iobj]];
        }
      } else {
        // if its not the key looking for, is this a key an object with its own keys, one of which matching?
        var ikeys = Object.keys(source[io[iobj]]);

        if (ikeys.length && source[io[iobj]][key] != null) { // eg. source.card.user_id
          return source[io[iobj]][key];
        }
      }

    }

    // 3. if nothing yet, is there a chain?
    if (source.chain != null) {

      return deepGet(source.chain, key);

    }

    // 4. nothing found
    return null;

  }

  return service;

})

/***************

controller/cards

***************/
.controller( 'ddDeck' , ['$http','$q','$scope','$filter','DDService', function($http, $q, $scope, $filter, DDService) {

  $scope.orderByField = 'label';
  $scope.reverseSort = false;
  $scope.totalDebtLoad = 0;
  $scope.totalMinPayment = 0;

  $scope.cardManagerTab = true;
  $scope.emergencyTab = false;
  $scope.budgetTab = false;
  $scope.pagecheckFrequencyTab = false;

  /*
  $scope.defaultSlider = {
    min: 0,
    options: {
      floor: 0,
      ceil: 1,
      precision: 2,
      step: 0.01,
      rightToLeft: true,
      onChange: function(sliderId, modelValue, highValue, pointerType) {
        sliderId.getForm().$setPristine(false);
      }
    }
  }*/

  // init-start
  DDService.pGetCards({user_id:CF_getUserID()})
  .then( function onSuccess( response ) {

    $scope.cards = $filter('cardSorter')(response.cards, $scope.orderByField, $scope.reverseSort);

    for (var card in $scope.cards) {
      $scope.cards[card]['className'] = 'card' + $scope.cards[card].card_id.toString() + ' small';
      //$scope.cards[card]['slider'] = $scope.defaultSlider;
      //$scope.cards[card]['slider']['options']['id'] = 'slider' + $scope.cards[card].card_id.toString();
    }

    //$scope.keylist = Object.keys($scope.cards).sort(function(a, b){return b-a;});
    

    $scope.calculateAll();

    console.log($scope.cards);
    //console.log($scope.keylist);

    DDService.pGetPreferences({user_id:CF_getUserID()})
    .then( function onSuccess( response ) {

      $scope.preferences = response.preferences;

    })
    .catch( function onError( result ) {

      CF_restErrorHandler( result );

    });

  })
  .catch ( function onError( result ) {

    CF_restErrorHandler( result );

  }); // init-end

  /************
     METHODS
  ************/

  $scope.sortBy = function(propertyName, initReverse) {
    if (propertyName != $scope.orderByField) {
      $scope.reverseSort = initReverse;
    } else {
      $scope.reverseSort = !($scope.reverseSort);
    }
    $scope.orderByField = propertyName;
    $scope.cards = $filter('cardSorter')($scope.cards, $scope.orderByField, $scope.reverseSort);
  }

  $scope.calculateAll = function () {

    $scope.totalDebtLoad = 0;
    $scope.totalMinPayment = 0;

    for (var card in $scope.cards) {

      $scope.totalDebtLoad += $scope.cards[card].balance;

      if ($scope.cards[card].balance > 0)
        $scope.totalMinPayment += $scope.cards[card].min_payment;

      if ( $scope.cards[card].is_emergency ) {
        $scope.selected = $scope.cards[card];
      }

    }

  };

  /**************

  saveCard

  **************/
  $scope.saveCard = function( data ) {

    // https://stackoverflow.com/questions/28250680/how-do-i-access-previous-promise-results-in-a-then-chain
    var one = DDService.pSaveCard( data );
    var two = one.then( function( resultOne ) {
      DDService.pDeletePlans( data );
    });
    var three = two.then( function( resultTwo ) {
      DDService.pDeleteJourney( data );
    });

    $q.all([one, two, three])
    .then( function( [resultOne, resultTwo, resultThree] ) {

      // really only needs to update when it is a brand new card; safe to update on key otherwise
      data.card_id = resultOne.card_id;

    })
    .catch( function onError( result ) {
      CF_restErrorHandler( result );
    });

    console.log( $scope.cards );

  };

  /**************

  setAsEmergency

  **************/
  $scope.setAsEmergency = function( data ) {

    DDService.pSetEmergency( data )
    .then( DDService.pDeletePlans )
    .then( DDService.pDeleteJourney )
    .then( function onSuccess( response ) {

      // update the is_emergency field on the cards themselves.
      Object.keys($scope.cards).forEach(function(id){
        $scope.cards[id].is_emergency = 0;
      });

      var idx = Object.keys($scope.cards).find(thisIndex => $scope.cards[thisIndex].card_id == data.card_id);

      $scope.cards[idx].is_emergency = 1;

    })
    .catch( function onError( result ) {
      CF_restErrorHandler( result );
    });

  };

  /***************

  setBudget

  ***************/
  $scope.setBudget = function( id, val ) {

    var data = {
      user_id: id,
      budget: val,
      total_min_payment: $scope.totalMinPayment
    };

    DDService.pValidatePreferences( data )
    .then( DDService.pSetPreferences )
    .then( DDService.pDeletePlans )
    .then( DDService.pDeleteJourney )
    .then( function onSuccess( response ) {

      // update budget in view
      $scope.preferences.budget = val;

    })
    .catch( function onError( e ) {

      DDService.pGetPreferences( e )
      .then( function onSuccess( response ) {

        $scope.preferences = response.preferences;

      })
      .catch( function onError( result ) {
        CF_restErrorHandler( result );
      });

    });

  };

  /*****************

  setPayFrequency

  *****************/
  $scope.setPayFrequency = function( id, freq ) {

    var data = {
      user_id: id,
      pay_frequency: freq
    };

    DDService.pSetPreferences( data )
    .then( DDService.pDeletePlans )
    .then( DDService.pDeleteJourney )
    .then( function onSuccess( response ) {

      // actually set the pay frequency
      $scope.preferences.pay_frequency = freq;

    })
    .catch( function onError( result ) {
      CF_restErrorHandler( result );
    });

  };

  /**************

  newCard

  **************/
  $scope.newCard = function( uid ) {

    var newid = 0;

    $scope.cards.unshift({ "user_id":uid, "card_id":0, "label":"", "is_emergency":0, "priority":0.00 });

    $('html,body').animate({
      scrollTop: jQuery('#top-form').offset().top
    }, 'slow');

    console.log( $scope.cards );
    //console.log( $scope.keylist );

  };

  /**************

  deleteCard

  **************/
  $scope.deleteCard = function( index ) {

    var in_data = {
      user_id: $scope.cards[index].user_id,
      card: $scope.cards[index]
    };

    // temp cards get no warning, just delete
    if ($scope.cards[index].card_id == 0) {

      $scope.cards.splice( index, 1 );

    } else {

      BootstrapDialog.show({
          size: BootstrapDialog.SIZE_LARGE,
          type: BootstrapDialog.TYPE_DANGER,
          closable: false,
          closeByBackdrop: false,
          closeByKeyboard: false,
          title: 'DANGER WILL ROBINSON!!',
          message: 'Are you absolutely sure you want to delete "' + $scope.cards[index].label + '"? Once deleted, there\'s no going back!! (But you could always re-enter it later).',
          buttons: [{
              label: 'Yes, delete the card.',
              cssClass: 'btn-success pull-left',
              action: function( dialogItself ) {

                DDService.pDeleteCard ( in_data )
                .then( DDService.pDeletePlans )
                .then( DDService.pDeleteJourney )
                .then( function onSuccess( response ) {

                  $scope.cards.splice( index, 1 );
                  //$scope.keylist.splice( $scope.keylist.indexOf(index), 1 );

                })
                .catch( function onError( result ){
                  CF_restErrorHandler( result );
                });

                dialogItself.close();
              }
          }, {
              label: 'No, I changed my mind.',
              cssClass: 'btn-danger',
              action: function( dialogItself ) {
                dialogItself.close();
              }
          }]
      });

    }

    console.log($scope.cards);
    //console.log($scope.keylist);

  };

  /****************

  resetCard

  ****************/
  $scope.resetCard = function( data ) {

    // if the card is new...
    if ( data.card_id == 0 ) {
      // ...just empty the fields
      data.label = '';
      data.interest_rate = '';
      data.balance = '';
      data.min_payment = '';

    // ...otherwise, grab the card's original values
    } else {

      DDService.pGetCard( data )
      .then( function onSuccess( response ) {

        var idx = Object.keys($scope.cards).find(thisCard => $scope.cards[thisCard].card_id == response.card.card_id);

        if (idx != "") {
          $scope.cards[idx] = response.card; 
        } else {
          throw new Error('fail to reset!');
        }

      })
      .catch( function onError( result ) {
        CF_restErrorHandler( result );
      });

    }

  };

  $scope.designCard = function( data ) {

    var $textAndPic = $('<div><div class="holder large" style="height:145px;"><div class="' + data.className + ' large"></div></div></div><div><div style="font-size:13px"><b>Current Code:</b> ' + data.code + '</div><input type="text" name="new_code" placeholder="Enter a new code" style="width:580px;" class="form-control top-buffer"></div>');

    var designModeEditor = new BootstrapDialog({
        size: BootstrapDialog.SIZE_LARGE,
        type: BootstrapDialog.TYPE_INFO,
        closable: false,
        closeByBackdrop: false,
        closeByKeyboard: false,
        title: 'WELCOME TO CARD DESIGN STUDIO<br>Editing: ' + data.label,
        message: $textAndPic,
        buttons: [{
            id: 'btn-generate',
            label: 'Surprise me.',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {

              var $generate = dialogItself.getButton('btn-generate');
              $generate.disable()

              var $try = dialogItself.getButton('btn-code');
              $try.disable()

              DDService.pGenerateDesign( {'code':'' } )
              .then( function onSuccess( response ) {

                var $newcode = response.code;
                var $newCss = response.css;
                var $newTextAndPic = $('<style>'+ $newCss + '</style><div><div class="holder large" style="height:145px;"><div class="temp large"></div></div></div><div><input type="text" name="new_code" width="64" class="form-control" value="' + $newcode + '" style="width:580px;"></div>');

                dialogItself.setMessage($newTextAndPic);

                // change the cancel button (if it needs changing)
                var $cancel = dialogItself.getButton('btn-goback');
                $cancel[0].innerText = "Revert";
                //var $cancel.setMessage('Revert');

                var $save = dialogItself.getButton('btn-save');
                $save.enable();

                var $generate = dialogItself.getButton('btn-generate');
                $generate.enable();

                var $try = dialogItself.getButton('btn-code');
                $try.enable();

              })
              .catch( function onError( result ) {
                CF_restErrorHandler( result );
              });

            }
        }, {
            id: 'btn-code',
            label: 'Try code.',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {

              var new_code = dialogItself.getModalBody().find('input').val();

              DDService.pGenerateDesign( {'code':new_code} )
              .then( function onSuccess( response ) {

                var $newCss = response.css;
                var $newTextAndPic = $('<style>' + $newCss + '</style><div><div class="holder large" style="height:145px;"><div class="temp large"></div></div></div><div><input type="text" name="new_code" width="64" class="form-control" value="' + new_code + '" style="width:580px;"></div>');

                dialogItself.setMessage($newTextAndPic);

                // change the cancel button (if it needs changing)
                var $cancel = dialogItself.getButton('btn-goback');
                $cancel[0].innerText = "Revert";

                var $save = dialogItself.getButton('btn-save');
                $save.enable(true);


              })
              .catch( function onError( result ) {
                CF_restErrorHandler( result );
              });

            }

        }, {
            id: 'btn-goback',
            label: 'Keep old design.',
            cssClass: 'btn-link',
            action: function( dialogItself ) {
              dialogItself.close();
            }

        },{
            id: 'btn-save',
            label: 'Save',
            cssClass: 'btn-success',
            action: function( dialogItself ) {
              var new_code = dialogItself.getModalBody().find('input').val();
              var key = Object.keys($scope.cards).find(thisIndex => $scope.cards[thisIndex].card_id == data.card_id);
              $scope.cards[key].code = new_code;
              DDService.pSaveCard( $scope.cards[key] )
              .then( function onSuccess( response ) {
                $('#cardStyleSheet').attr( "href", $('#cardStyleSheet').attr( "href" ) + (Math.random() * 10).toString() );
                dialogItself.close();
              })
              .catch( function onError( result ) {
                CF_restErrorHandler( result );
              });
              
            }
        }]
    });

    // fire the init
    designModeEditor.realize();

    // disable Save
    var save = designModeEditor.getButton('btn-save');
    save.disable()

    // open
    designModeEditor.open();

  }

}]) // controller-cards

/***************

controller/calculate

***************/
.controller( 'ddCalculate' , function ( $scope , $http, $timeout, DDService ) {

  /********/
  /* init */
  /********/
  $scope.orderByField = 'label';
  $scope.reverseSort = false;
  $scope.schedule = [];
  $scope.events   = [];

  $scope.thisMonthTab = true;
  $scope.scheduleTab = false;
  $scope.milestoneTab = false;

  $scope.all_cards = {};

  DDService.pGetCards({user_id:CF_getUserID()})
  .then( function onSucess( response ) {

    $scope.all_cards = response.cards;

    if ( Object.keys($scope.all_cards).length ) {

      /*********/
      /* main  */
      /*********/
      var in_data = { user_id:CF_getUserID() };

      /* since plan loads the main screen, we do it first */
      DDService.pGetPlan( in_data )
      .then( function onSuccess( response ) {

        // ********************
        // 1. Populate the Plan
        $scope.plan = response.plan;
        //$scope.keylist = Object.keys($scope.plan).sort(function(a, b){return b-a;});

        //$scope.selected = Object.keys($scope.plan).find(thisCard => thisCard.is_emergency == 1);

        /*
        for (var card in $scope.plan) {
          if ( card.is_emergency ) {

            $scope.selected = $scope.keylist[card];
          }
        }
        */

        $scope.cards = $scope.plan; // FIXME: you're duping this var, just to make the ordering work? Don't.

        /* ...then, we do the calendar and chart */
        DDService.pGetSchedule( in_data )
        .then( DDService.pGetJourney )
        .then( function onSuccess( response ) {

          // **************************************
          // 2. Populate the Schedule (-> Calendar)
          var result = response.chain.schedule;
          var i=0;

          for (i=0; i < result.length; i++) {
            $scope.events.push({
              title:result[i].title,
              start:new Date(result[i].start)
            });
          }

          $scope.schedule.push($scope.events);
          // NOTE: we no longer populate at this stage, because if calendar is hidden by default,
          // errors get thrown!! (see #601)

          // **************************************
          // 3. Populate the Journey (-> Highchart)
          var wins = [];
          result = response.journey;

          for (i=0; i<result.length;i++) {

            // inject id
            result[i].id = 'id_' + i;

            // inject color
            result[i].color = getColor(i);

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
                lineWidth: 2,
                data: []
              };

              var startMoment = moment(new Date(y,m,1));
              var endMoment = startMoment.add( result[i].data.length-1, 'months');

              win.data.push({
                color: getColor(i),
                x: endMoment.toDate(),
                title: 'CHECKPOINT!!',
                text: (result[i].name + ' paid off in: <b>' + endMoment.format('MMMM') + ' of ' + endMoment.format('YYYY') + '</b>' ),
              });

              wins.push(win);

            }

          }

          // cat the two arrays together
          result = result.concat(wins);

          Highcharts.SVGRenderer.prototype.symbols.doublearrow = function(x, y, w, h) {
            return [
              // right arrow
              'M', x + w / 2 + 1, y,
              'L', x + w / 2 + 1, y + h,
              x + w + w / 2 + 1, y + h / 2,
              'Z',
              // left arrow
              'M', x + w / 2 - 1, y,
              'L', x + w / 2 - 1, y + h,
              x - w / 2 - 1, y + h / 2,
              'Z'
            ];
          };

          if (Highcharts.VMLRenderer) {
            Highcharts.VMLRenderer.prototype.symbols.doublearrow = Highcharts.SVGRenderer.prototype.symbols.doublearrow;
          }

          Highcharts.stockChart('milestones', {

            //title: {
            //  text: 'Payoff Milestones'
            //},

            credits: {
              enabled: false
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
              height: 80,
              maskFill: 'rgba(131,145,120,0.6)', //'#839178',
              maskInside: false,
              outlineColor: '#000',
              outlineWidth: 1,
              xAxis: {
                type: 'datetime',
                ordinal: false,
                min: Date.UTC(y,m,1), // full range start (today)
                tickInterval: 2 * 30 * 24 * 3600 * 1000 // a tick every 2 month
              },
              handles: {
                symbols: ['doublearrow','doublearrow'],
                height: 20,
                width: 12,
                lineWidth: 1,
                backgroundColor: '#d2691e',
                borderColor: '#000'
              }
            },

            yAxis: {
              type: 'linear',
              min: 0,
            },

            tooltip: {
              split: true,
              distance: 70, // undocumented, distance in pixels away from the point (calculated either + or -, based on best positioning of cursor)
              padding: 5,
              pointFormatter: function() {
                return '<span style="color:' + this.color + '">\u25CF</span> ' + this.series.name + '\'s Balance: <b>$' + currencyFormatter.format(this.y) + '</b><br/>';
              }
            },

            plotOptions: {
              series: {
                pointStart: Date.UTC(y,m,1), // we begin plotting on the 1st of the current month
                pointIntervalUnit: 'month',  // every point along the x axis represents 1 month
                animation: {
                  duration: 6200,
                  //easing: 'easeOutBounce'
                },
                lineWidth: 4
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

        })
        .catch( function onError( result ) {

          CF_restErrorHandler( result );

        });

      })
      .catch( function onError( result ) {

        CF_restErrorHandler( result );

      });

    } else {

      BootstrapDialog.show({
        size: BootstrapDialog.SIZE_LARGE,
        type: BootstrapDialog.TYPE_INFO,
        closable: false,
        closeByBackdrop: false,
        closeByKeyboard: false,
        title: 'HEY!! NO PEEKING!!',
        message: 'Whoops!<br><br>This is the <b>"Calculate Your Future"</b> section, but we can\'t calculate it unless you supply us with some cards first.<br><br>Let\'s head over to <b>"Update Your Budget"</b> to get some cards loaded first!',
        buttons: [{
            id: 'btn-close',
            label: 'I understand. Take me to card management.',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {
              dialogItself.close();
              location.href="/index.cfm/manage/budget";
            }
        }]
      });

    }

  })
  .catch( function onError( result ) { 

      CF_restErrorHandler( result ); // pGetCards

  });


  /************
     METHODS
  ************/

  // Calendar: alert on eventClick
  $scope.alertOnEventClick = function( date, jsEvent, view ) {
    $scope.alertMessage = date.title + ' on ' + moment(date.start._d).format('dddd, MMMM Do');
  };

  // Calendar: hack to render
  $scope.eventAfterAllRender = function ( view ) {
    var h2Text = $('.fc-left h2').text();
    $('.fc-left h2').attr('shadow-text', h2Text);
  }

  $scope.renderCalendar = function( calendar ) {

    if (!$scope.schedule.length)
      return;
    else {
      calendarTag = $('#' + calendar);
      calendarTag.fullCalendar('render');
    }

  };

  // Calendar: config object
  $scope.uiConfig = {
    calendar:{
      eventClick: $scope.alertOnEventClick,
      eventAfterAllRender: $scope.eventAfterAllRender,
      timezone: 'UTC'
    }
  };

}) // controller/calculate

/******************

controller/pay

******************/
.controller( 'ddPay' , function ( $scope, $http, $q, $filter, DDService ) {

  $scope.orderByField = 'pay_date';
  $scope.reverseSort = false;
  $scope.showAllCards = false;
  $scope.loaded = false;
  $scope.customAmount = false;

  $scope.loadingBills = true;
  $scope.loadingPlan = true;

  $scope.all_cards = {};

  /*********/
  /* main  */
  /*********/
  DDService.pGetCards({user_id:CF_getUserID()})
  .then( function onSucess( response ) {

    $scope.all_cards = response.cards;

    if ( Object.keys($scope.all_cards).length ) {

      DDService.pGetEvent({user_id:CF_getUserID()})
      .then( function onSuccess( response ) {

        //success
        $scope.all_cards = response.event.plan.plan_deck.deck_cards; // overwrite the first test call
        $scope.event_cards = response.event.event_cards;
        $scope.cards = $filter('cardSorter')($scope.all_cards, $scope.orderByField, $scope.reverseSort);
        $scope.pay_dates = {};

        for (i = 0; i < Object.keys($scope.event_cards).length; i++ ) {
          var index =  Object.keys($scope.event_cards)[i];
          $scope.pay_dates[index] = $scope.event_cards[index].pay_date;
        }

        $scope.cards = $filter('noPaymentFilter')($scope.all_cards, $scope.pay_dates, $scope.showAllCards);
        $scope.selected = $scope.cards[Object.keys($scope.cards)[0]]; // by default, just pick the first one.

        // chain into actual payments]
        var in_data = {
          user_id: CF_getUserID(),
          payment_for_month: response.event.calculated_for_month,
          payment_for_year: response.event.calculated_for_year
        }
        
        DDService.pGetCardPayments( in_data )
        .then( function onSuccess( response ) {

          for (j = 0; j < Object.keys($scope.event_cards).length; j++ ) {
            var index =  Object.keys($scope.event_cards)[j];
            if ( response.card_payments.findIndex(x => x.card_id == $scope.event_cards[index].card_id) != -1 ) {
              var newIndex = $scope.cards.findIndex(y => y.card_id == $scope.event_cards[index].card_id)

              $scope.cards[newIndex]['actual_payment'] = response.card_payments.find(x => x.card_id == $scope.event_cards[index].card_id).actual_payment;
              $scope.cards[newIndex]['actually_paid_on'] = response.card_payments.find(x => x.card_id == $scope.event_cards[index].card_id).actually_paid_on;
            }
          }

          // chain into the preferences load
          DDService.pGetPreferences({user_id:CF_getUserID()})
          .then( function onSuccess( response ) {

            $scope.loaded = true;
            if ($scope.event_cards.length) {
              $scope.loadingBills = false;
              $scope.loadingPlan = false;
            }

            $('#pan-main').fullpage({
              licenseKey:'OPEN-SOURCE-GPLV3-LICENSE', //TODO: buy a license
              animateAnchor: false,
              controlArrows: false,
              scrollOverflow: true,
              scrollOverflowOptions: {
                scrollbars: false,
                bounce: false,
                momentum: false, // allegedly a good perf boost even with them hidden tho?
                fadeScrollbars: false,
                disableTouch: true
              },
              autoScrolling: false,
              verticalCentered: false,
              fitToSection: false,
              keyboardScrolling: false,
              anchors:['pay']
            });

            //disabling scrolling
            $.fn.fullpage.setAllowScrolling(false);
            //fullpage_api.setAllowScrolling(false); // no touch scrolling please

          })
          .catch( function onError( result ) { // pGetPreferences

            CF_restErrorHandler( result );

          });

        })
        .catch( function onError( result ) { // pGetCardPayments

          CF_restErrorHandler( result );

        });

      })
      .catch( function onError( result ) { // pGetEvent

          CF_restErrorHandler( result );

      });

    } else {

      BootstrapDialog.show({
        size: BootstrapDialog.SIZE_LARGE,
        type: BootstrapDialog.TYPE_INFO,
        closable: false,
        closeByBackdrop: false,
        closeByKeyboard: false,
        title: 'WELCOME TO DEBT DECIMATOR!',
        message: 'Let\'s get started!!<br><br>Since you haven\'t added any cards yet, there won\'t be much to look at behind the "Pay My Bills" or "Calculate My Future" buttons. Instead, let\'s head directly over to "Update My Budget" and start loading some cards!',
        buttons: [{
            id: 'btn-close',
            label: 'Excellent. Take me there.',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {
              dialogItself.close();
              location.href="/index.cfm/manage/budget";
            }
        }]
      });

    }

  })
  .catch( function onError( result ) { 

    CF_restErrorHandler( result ); // pGetCards

  });

  /***********
    METHODS
  ***********/

  $scope.sortBy = function(propertyName, initReverse) {
    if (propertyName != $scope.orderByField) {
      $scope.reverseSort = initReverse;
    } else {
      $scope.reverseSort = !($scope.reverseSort);
    }
    $scope.orderByField = propertyName;
    $scope.cards = $filter('cardSorter')($scope.cards, $scope.orderByField, $scope.reverseSort);
  }

  $scope.filterBy = function() {
    $scope.cards = $filter('noPaymentFilter')($scope.all_cards, $scope.pay_dates, $scope.showAllCards);
  }


  $scope.resetForm = function( forms ) {
    $scope.card = {};
  };

  // compatibility bridge between angular $location and fw/1 buildUrl()
  $scope.navigateTo = function( path ) {
    location.href = path;
  };

  $scope.selectCard = function( card ) {
    $scope.selected = card;
    location.hash = '#pay/summary';
  };

  $scope.returnToList = function( destIndex ) {
    location.hash = '#pay/cards';
  };

  $scope.recalculateCard = function( card ) {

    var key = Object.keys($scope.cards).find(thisIndex => $scope.cards[thisIndex].card_id == card.card_id);

    $scope.selected.calculated_payment = 'Thinking...'; // setting this to a non-number will trigger the || output filter on the display, which is 'Recalculating...'

    DDService.pSaveCard( card )
    .then( DDService.pGetCard )
    .then( DDService.pDeletePlans )
    .then( DDService.pDeleteJourney )
    .then( DDService.pGetPlan )
    .then( function( response ) {
      // just update the 1  card
      $scope.cards[key].calculated_payment = response.plan[$scope.selected.card_id].calculated_payment;
      $scope.selected.calculated_payment = $scope.cards[key].calculated_payment;
    });

  };

  $scope.makePayment = function() {

    var in_card = $scope.selected;
    var m = moment($scope.event_cards[$scope.selected.card_id].pay_date).month() + 1;
    var y = moment($scope.event_cards[$scope.selected.card_id].pay_date).year();

    var in_data = {
      card_id: in_card.card_id,
      user_id: in_card.user_id,
      actual_payment: in_card.actual_payment,
      payment_for_month: m,
      payment_for_year: y
    };

    DDService.pSaveCardPayment( in_data )
    .then( function( response ) {

      // TODO: message will be populated with real stats based on the user's performance.
      BootstrapDialog.show({
        size: BootstrapDialog.SIZE_LARGE,
        type: BootstrapDialog.TYPE_INFO,
        closable: false,
        closeByBackdrop: false,
        closeByKeyboard: false,
        title: 'PAYMENT RECORDED',
        message: 'SWEET!! You\'re nailing this!<br><br><b>BONUS:</b> You are now a part of the <b>96.67%</b> of customers that pay their debts! AWESOME!!',
        buttons: [{
            id: 'btn-close',
            label: 'Thanks!',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {
              $scope.returnToList(1);
              dialogItself.close();
            }
        }]
      });

    })
    .catch( function onError( result ) {

      CF_restErrorHandler( result );

    });

  }

}) // controller/pay

/*****************

controller/main

*****************/
.controller( 'ddMain', function ( $scope, $http, $q, $compile, DDService ) {

  $scope.try = false;

  angular.element(document).ready(function(){

    if ( $('#pan-main').length > 0 ) {

      $('#pan-main').fullpage({
        licenseKey:'OPEN-SOURCE-GPLV3-LICENSE', //TODO: buy a license
        autoScrolling: false,
        recordHistory: true,
        scrollHorizontally: true,
        verticalCentered: false,
        fitToSection: false,
        keyboardScrolling: false,
        animateAnchor: false,
        anchors:['try']
      });

      //methods
      $.fn.fullpage.setAllowScrolling(false);

      // setup the submit button
      $('#pan-main').on('click', '.btn-submit', function() {
        $('#entry').submit();
      });

    }

  });

  /***********
     METHODS
  ***********/

  $scope.verifyBudget = function() {

    if ( $('#budget').val() == "" || isNaN($('#budget').val()) || parseFloat($('#budget').val()) <= 0 ) {

      BootstrapDialog.show({
          size: BootstrapDialog.SIZE_LARGE,
          type: BootstrapDialog.TYPE_DANGER,
          closable: false,
          closeByBackdrop: false,
          closeByKeyboard: false,
          title: 'I NEED A BUDGET!',
          message: 'Enter a budget before moving forward!<br><br> This is the amount that you\'ll dedicate to paying down your credit cards every month. Be sure to pick a number that allows you to safely <b>live within your means!</b><br><br>For example, if you have $200 a month to spend on paying off bills, enter \'200.00\' in the field below.',
          buttons: [{
              id: 'btn-confirm',
              label: 'Got it',
              cssClass: 'btn-success pull-left',
              action: function( dialogItself ) {
                dialogItself.close();
              }
          }]
      });

    } else {

      location.hash = '#try/1';

    }

  }

  $scope.verifyCard = function( cardNum ) {

    var cc_balance = $('input[name=credit-card-balance' + (cardNum).toString() + ']');

    if ( cc_balance.val() == "" || isNaN(cc_balance.val()) || parseFloat(cc_balance.val()) <= 0 ) {

      BootstrapDialog.show({
          size: BootstrapDialog.SIZE_LARGE,
          type: BootstrapDialog.TYPE_DANGER,
          closable: false,
          closeByBackdrop: false,
          closeByKeyboard: false,
          title: 'THE UNIVERSE IS WITHOUT BALANCE!',
          message: 'Enter a balance on one of your credit cards below.<br><br>Just tell us what remains to be paid, and nothing else!',
          buttons: [{
              id: 'btn-confirm',
              label: 'I understand',
              cssClass: 'btn-success pull-left',
              action: function( dialogItself ) {
                dialogItself.close();
              }
          }]
      });

    } else {

      location.hash = '#try/' + (parseInt(cardNum)+1).toString();

    }

  }

  // compatibility bridge between angular $location and fw/1 buildUrl()
  $scope.navigateTo = function( path ) {
    location.href = path;
  };

  $scope.addAnother = function() {

    var newHed = [
      'Keep \'em coming!', 
      'Need more debt!', 
      'You\'re killing it! (and by "it" we mean "debt")', 
      'Give us your cards!', 
      'Somebody set you up the debt!'
    ];
    
    var newMsg = [
      'The average balance a person carries on a credit card is: $5,047. Let\'s get that down to $0.',
      'Families with debt carry an average balance of: $15,654. It\'s time to chip that away.',
      'People born between \'80-\'84 carry approx. $5,689 more credit card debt than their parents, and $8,156 more than their grandparents.',
      'Credit card debt increased by nearly 8% in 2017. Let\'s reverse that trend. Now.',
      'But starting today, you\'re paying it off. For great justice.'
    ];

    var $pan = $( '#pan-main > form' );

    if (!$pan.length) {
      $pan = $('#pan-main');
    }

    var $last_div = $('div[id^="page"]:last');
    var num = parseInt( $last_div.prop('id').match(/\d+/g), 10 ) + 1;

    var $div = $last_div.clone()
    
    // re-id it
    $div.prop('id','page' + num);

    // re-class it.
    $div.prop('class','pan-page pan-page-' + num);

    // attach data for panning
    $div.data( 'originalClassList', $div.attr( 'class' ) );

    // re-id the form fields
    $div.find('input').each( function(index) {

      var tClass = $(this).attr('class'); // the base field name is the class (the actual name already has a number)

      var fieldName = tClass.substring(tClass.indexOf('credit-card'));

      var newFieldId = fieldName + (num-1); // the fields are -1 of the page itself (eg. page-2 has fieldnames named credit-card-label1)

      // re-id it
      $(this).prop('id', newFieldId);

      // and then re-name it
      $(this).prop('name', newFieldId);

    });

    $div.find('.card-content h3').text(newHed[tRnd % newHed.length]);
    $div.find('.card-content p').text(newMsg[tRnd % newHed.length]);
    tRnd++;

    $pan.append( $div );

    return num;
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

    DDService.pGetTempSchedule({})
    .then( function onSuccess( response ) {

      var result = response.schedule;
      var wins = [];

      for ( var i = 0; i < result.length; i++ ) {

        // inject id
        result[i].id = 'id_' + i;

        // inject color
        result[i].color = getColor(i);

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
            text: (result[i].name + ' paid off on: <b>' + monthNames[dateReadable.getMonth()] + ' ' + dateReadable.getDate() + ', ' + dateReadable.getFullYear() + '</b>' )
          });

          wins.push(win);

        }

      }

      // cat the two arrays together
      if ( result.length )
        result = result.concat( wins );

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
            pointStart: Date.UTC( y, m, 1 ), // we begin plotting on the 1st of the current month
            pointIntervalUnit: 'month',  // every point along the x axis represents 1 month
            tooltip: {
              pointFormatter: function() {
                return '<span style="color:' + this.color + '">\u25CF</span> ' + this.series.name + '\'s Balance: <b>$' + currencyFormatter.format(this.y) + '</b><br/>';
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

    })
    .catch( function onError( result ){
      CF_restErrorHandler( result );
    });

  };

  // Intended Step 1
  // Plan : main()
  // FIXME: separate global handler that verifies person is logged in / redirects them if fails, from plan/events/milestones init.

  $scope.getTempPlan = function() {

    DDService.pGetTempPlan({})
    .then( function onSuccess( response ) {

      $scope.plan = response.plan;

    })
    .catch( function onError( result ) {

      CF_restErrorHandler( result );

    });

  };

}) // controller/main

/*****************

controller/profile

*****************/
.controller( 'ddProfile' , function ( $scope, $http, $q, $cookies, DDService ) {

  $scope.skin = $cookies.get( 'DD-SKIN' );
  $scope.editingCard = false;

  DDService.pGetPreferences({user_id:CF_getUserID()})
  .then( function onSuccess( result ) {

    $scope.preferences = result.preferences;

  })
  .catch( function onError( e ) {

    CF_restErrorHandler( e );

  });

  /***********
     METHODS
  ***********/

  $scope.savePreferences = function( data ) {

    DDService.pSetPreferences( data )
    .then( function onSuccess( response ) {

    })
    .catch( function onError( e ) {

      // load old values back into the model
      DDService.pGetPreferences( data )
      .then( function onSuccess( response ) {

        $scope.preferences = response.data;

      })
      .catch( function onError( result ) {

        CF_restErrorHandler( result );

      });

    });

    console.log( $scope.preferences );

  };

  $scope.updateSkin = function( sIndex ) {

    //var oldlink = document.getElementsByTagName( 'link' ).item( document.getElementsByTagName( 'link' ).length-1 );

    var newPath = CF_getTheme(sIndex).replace(/https?\:/,"");

    $('#skin').attr( "href", newPath );

    //var newlink = document.createElement( 'link' );
    //newlink.setAttribute( 'rel', 'stylesheet' );
    //newlink.setAttribute( 'type', 'text/css' );
    //newlink.setAttribute( 'href', newPath );

    //document.getElementsByTagName( 'head' ).item( 0 ).replaceChild( newlink, oldlink );

    var prefs = $cookies.get( 'DD-SKIN' );

    prefs = sIndex;

    $cookies.put( 'DD-SKIN', prefs );

  };

  $scope.cancelConfirm = function( cancel_url ) {

    BootstrapDialog.show({
        size: BootstrapDialog.SIZE_LARGE,
        type: BootstrapDialog.TYPE_DANGER,
        closable: false,
        closeByBackdrop: false,
        closeByKeyboard: false,
        title: 'YIKES!! YOU\'RE ABOUT TO LOSE FUNCTIONALITY!!',
        message: 'You\'re about to cancel your <b>paid subscription</b>. You can continue to use the site for free, but the following changes will occur:<\/br><\/br><ul><li>Ads return!<li>No 0% APR calculation support!<li>No customizable card priorities!</ul><br>Are you <b>sure</b> you want to do this?',
        buttons: [{
            id: 'btn-confirm',
            label: 'Yes, cancel my paid subscription.',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {

              var $this_button = this;
              $this_button.disable();

              var $other_button = dialogItself.getButton('btn-goback');
              $other_button.disable();

              dialogItself.setClosable(false);

              location.href = cancel_url;

            }
        }, {

            id: 'btn-goback',
            label: 'Stop! I changed my mind!',
            cssClass: 'btn-danger',
            action: function( dialogItself ) {
              dialogItself.close();
            }

        }]
    });

  }

  $scope.updatePayment = function( card ) {

    DDService.pSavePaymentInfo( card )
    .then( function onSuccess( result ) {

      BootstrapDialog.show({
        size: BootstrapDialog.SIZE_LARGE,
        type: BootstrapDialog.TYPE_INFO,
        closable: false,
        closeByBackdrop: false,
        closeByKeyboard: false,
        title: 'CARD UPDATED',
        message: 'You\'ve successfully updated your payment information.',
        buttons: [{
            id: 'btn-close',
            label: 'Thanks!',
            cssClass: 'btn-success pull-left',
            action: function( dialogItself ) {
              dialogItself.close();
            }
        }]
      });

      $scope.editingCard = false; // I'd prefer this happen on the action method above, but need to pass scope in somehow.

    })
    .catch( function onError( e ) {

      CF_restErrorHandler( e );

    });

  }

}); // controller/profile
