<!--- login.cfm :: all login.* actions use this --->
<cfparam name="rc.message" default="#arrayNew(1)#">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html ng-app="ddApp" xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#application.app_name#</cfoutput></title>
	
    <link href="/bootstrap/css/bootstrap.css" rel="stylesheet">	
	
</head>
<body ng-controller="ddCtrl">
<nav class="navbar navbar-inverse navbar-static-top" role="navigation">
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
</html>