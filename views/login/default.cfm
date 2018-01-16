<!-- views/login/default.cfm -->
	
	<div class="page-header">
		<h1>Login</h1>
	</div>

	<div class="panel panel-default form-horizontal">

	<cfoutput>
	<cfform name="login" id="login" action="#buildURL('login.login')#" method="post">
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
			<cfinput id="email" type="text" class="form-control" name="email" placeholder="Email Address" required="yes" message="Please enter your email address" />
		</div>
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
			<cfinput id="password" type="password" class="form-control" name="password" placeholder="Password" required="yes" message="Please enter your password" />
		</div>
		<button class="btn button btn-default" form="login"><span class="glyphicon glyphicon-log-in"></span> Login</button>
	</cfform>
	<button class="btn button btn-default" onClick="location.href='#buildUrl('login.create')#';"><span class="glyphicon glyphicon-exclamation-sign"></span> I don't have an account yet</button>
	</cfoutput>

	</div>
