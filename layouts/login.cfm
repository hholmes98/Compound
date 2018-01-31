<!--- login.cfm :: all login.* actions use this --->
<cfparam name="rc.message" default="#ArrayNew(1)#">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html ng-app="ddApp" xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#application.app_name#</cfoutput></title>

	<link href="https://fonts.googleapis.com/css?family=Ultra" rel="stylesheet">
    <link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
	<link href="/assets/css/dd.css" rel="stylesheet" />

	<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0" />

	<script> 
	window.onload = function(){ 
	setTimeout(function() { 
	var ad = document.querySelector("ins.adsbygoogle");
	if (ad && ad.innerHTML.replace(/\s/g, "").length == 0) {
	    ad.style.cssText = 'display:block !important'; 
	    ad.parentNode.innerHTML += '<div style="padding:5px; background-color:#171717; border:1px solid #fff; margin:5px 5px 10px 5px; display:inline-block; text-align:left">You appear to be blocking our ads with an Ad Blocker. <cfoutput>#application.locale[application.default_locale]['name']#</cfoutput> depends on these ads to help cover our high server costs. Please add *.<cfoutput>#application.site_domain#</cfoutput> to your ad blocker\'s whitelist or consider upgrading to a paid account.</div>';
	}
	}, 1000);
	};
	</script>
</head>
<body ng-controller="ddCtrl">

<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
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
</nav>

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
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-112744491-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-112744491-1');
</script>
</body>
</html>