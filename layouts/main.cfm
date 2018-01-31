<!--- main.cfm :: for all main.* actions--->
<cfparam name="rc.message" default="#arrayNew(1)#">

<DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html ng-app="ddApp" xmlns="http://www.w3.org/1999/xhtml">
<head>

	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#application.app_name#</cfoutput></title>

	<!-- styles -->
	<link href="https://fonts.googleapis.com/css?family=Ultra" rel="stylesheet">
	<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="/assets/css/dd.css" />

	<link href="https://fonts.googleapis.com/css?family=Ultra" rel="stylesheet">

	<!-- scripts -->
	<script src="/jquery/js/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="/bootstrap/js/bootstrap.js"></script>

	<script src="/angular/angular.min.js" type="text/javascript"></script>

	<script src="/node_modules/angular-tooltips/lib/angular-tooltips.js"></script>

	<script src="/node_modules/moment/min/moment.min.js" type="text/javascript"></script>

	<script>
	var ddApp = angular.module('ddApp', ['720kb.tooltips']);
	</script>

	<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0" />

</head>
<body ng-controller="ddCtrl">
<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
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
        <li class="active"><cfoutput><a href="#buildUrl('main')#"><span class="glyphicon glyphicon-cog"></span> <span class="sr-only">(current)</span></a></cfoutput></li>
        <li><cfoutput><a href="#buildUrl('plan')#"></cfoutput><span class="glyphicon glyphicon-stats"></span></a></li>
        <li><cfoutput><a href="#buildUrl('pay')#"><span class="glyphicon glyphicon-money"></span></a></cfoutput></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li><cfoutput><a href="#buildUrl('profile.basic')#"><span class="glyphicon glyphicon-user"></span></a></cfoutput></li>
      </ul>
    </div>
  </div>
</nav>

<cfif session.auth.user.getAccount_Type_Id() EQ 1>
<div id="top-banner">
	
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- DD_Responsive -->
<ins class="adsbygoogle responsive_ad"
     style="display:inline-block;"
     data-ad-client="ca-pub-6215660586764867"
     data-ad-slot="9656584127"  
     ></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
	
</div>
</cfif>

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

ddApp.controller( 'ddCtrl' , function ( $scope, $http ) {

	$http({
		method: 'GET',
		url: 'index.cfm/card/user_id/<cfoutput>#session.auth.user.getUser_id()#</cfoutput>' 
	}).then( function onSuccess( response ) {
		
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
		$http.get( 'index.cfm/prefs/uid/<cfoutput>#session.auth.user.getUser_id()#</cfoutput>' ).success( function ( data ) {

			$scope.preferences = data;

		});

	}).catch ( function onError( response ) {
		//failure
		window.location.href = 'index.cfm/login';

	});

	$scope.saveCard = function( key, data ) { 

		console.log($scope.cards);

		$http({
			method: 'POST',
			url: 'index.cfm/card/',
			data: $.param( data ),
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			} // set the headers so angular passing info as form data (not request payload)
		}).success( function( data ){

			// FIXME: not clean. on update this is wasteful, could be dangerous later.
			$scope.cards[key].card_id = data;

		});

		console.log($scope.cards);

	};

	$scope.deletePlan = function( user_id ) {

		// purge the plan cache whenever a card
		$http({
			method: 'DELETE',
			url: 'index.cfm/plan/' + user_id,
		}).success( function( data ) {

			// do whatever you need to do on the client to flag the cache is purged/nonexistent

		});

	}

	$scope.setAsEmergency = function( eid, uid ) { 

		$http({
			method: 'POST',
			url: 'index.cfm/card/eid/' + eid + '/uid/' + uid,
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			} // set the headers so angular passing info as form data (not request payload)
		}).success( function( data ) {

			// actually set the card
			$scope.cards[eid].is_emergency = 1;

		});

	};

	$scope.deleteCard = function( card_id ) { 
		
		$http({
			method: 'DELETE',
			url: 'index.cfm/card/' + card_id
		}).success( function( data ) {

			delete $scope.cards[ card_id ];

			//for modern browsers ( > IE8 )

			$scope.keylist.splice( $scope.keylist.indexOf(card_id), 1 );

		});

	};

	$scope.newCard = function( uid ) { 

		console.log($scope.cards);

		console.log($scope.keylist);

		if ( $scope.keylist.length ) {
			var newid = parseInt( $scope.keylist[0] ) + 1;
		}
		else var newid = parseInt(1);

		$scope.cards[ newid ] = { "user_id":uid, "card_id":0, "label":"", "is_emergency":0 };

		$scope.keylist.unshift( newid );

		console.log($scope.keylist);

	};

 
	$scope.resetCard = function( eid ) {

		$http.get( 'index.cfm/card/' + eid ).success( function( data ) { 

			if ( data.card_id == 0 ) {
				delete $scope.cards[ eid ];

				// for modern browsers ( > IE8)

				$scope.keylist.splice( $scope.keylist.indexOf(eid), 1 );

			}

			else $scope.cards[ eid ] = data;

		} );

	}

	$scope.setBudget = function( id, val ) { 

		$http({
			method: 'POST',
			url: 'index.cfm/prefs/budget/' + val + '/uid/' + id,
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			} // set the headers so angular passing info as form data (not request payload)
		}).success( function( data ) {

			// actually set the budget
			$scope.preferences.budget = val;

		});

	};

	$scope.setPayFrequency = function( id, freq ) { 

		$http({
			method: 'POST',
			url: 'index.cfm/prefs/freq/' + freq + '/uid/' + id,
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			} // set the headers so angular passing info as form data (not request payload)
		}).success( function( data ) {

			// actually set the pay frequency
			$scope.preferences.pay_frequency = freq;

		});

	};

});

</script>
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-112744491-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-112744491-1');
</script>
</html>
