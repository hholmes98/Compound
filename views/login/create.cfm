<!--- create.cfm --->

	<div class="page-header">
		<h2 shadow-text="Get Started!">Get Started!</h1>
	</div>

	<div class="panel panel-default form-horizontal">

	<cfoutput>
	<cfform name="account" id="account" action="#buildURL('login.new')#" method="post">
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
			<cfinput id="name" type="text" class="form-control" name="name" placeholder="Enter a Nickname" required="yes" message="Please enter a nickname for this account" />
		</div>
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
			<cfinput id="email" type="text" class="form-control" name="email" placeholder="Enter Your Email Address" required="yes" message="Please enter your email address" />
		</div>
		<button class="btn button btn-default" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Decimate Some Debt!</button>
	</cfform>
	<button class="btn button btn-default" onClick="location.href='#buildUrl('login.default')#';"><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button>
	</cfoutput>

	</div>