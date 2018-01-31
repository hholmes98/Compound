<!--- layouts/profile.cfm --->
<cfparam name="rc.message" default="#ArrayNew(1)#">

<DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html ng-app="ddApp" xmlns="http://www.w3.org/1999/xhtml">
<head>

	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#application.app_name#</cfoutput></title>

	<!-- styles -->
	<link href="https://fonts.googleapis.com/css?family=Ultra" rel="stylesheet">
	<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">	
	<link href="/assets/css/dd.css" rel="stylesheet">  

	<!-- scripts -->
	<script src="/jquery/js/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="/bootstrap/js/bootstrap.js"></script>
	<script src="/angular/angular.min.js" type="text/javascript"></script>	
	<script src="/node_modules/angular-tooltips/lib/angular-tooltips.js"></script>
	<script src="/node_modules/moment/min/moment.min.js" type="text/javascript"></script>

	<script>
	var ddApp = angular.module('ddApp');
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
        <li><cfoutput><a href="#buildUrl('main')#"><span class="glyphicon glyphicon-cog"></span></a></cfoutput></li>
        <li><cfoutput><a href="#buildUrl('plan')#"></cfoutput><span class="glyphicon glyphicon-stats"></span></a></li>
        <li><cfoutput><a href="#buildUrl('pay')#"><span class="glyphicon glyphicon-money"></span></a></cfoutput></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li class="active"><cfoutput><a href="#buildUrl('profile.basic')#"><span class="glyphicon glyphicon-user"></span> <span class="sr-only">(current)</span></a></cfoutput></li>
      </ul>
    </div>
  </div>
</nav>

<cfif session.auth.user.getAccount_Type().getAccount_Type_Id() EQ 1>
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

    $('#email-alerts').bootstrapSwitch();

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
