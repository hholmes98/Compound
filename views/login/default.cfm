<!-- views/login/default.cfm -->

	
	<div class="page-header">
	  <h1>Login</h1>
	</div>

	<div class="panel panel-default form-horizontal">


<cfoutput>
	<cfform name="login" id="login" action="#buildURL('login.login')#" method="post">
		<table cellpadding="0" cellspacing="0">
			<tr>
				<th colspan="2">Login</th>
			</tr>
			<tr>
				<td><strong><label for="email" class="label">Email:</label></strong></td>
				<td><cfinput type="text" name="email" id="email" size="50" maxlength="100" required="yes" message="Please enter your email address" /></td>
			</tr>
			<tr>
				<td><strong><label for="password" class="label">Password:</label></strong></td>
				<td><cfinput type="password" name="password" id="password" size="25" required="yes" message="Please enter your password" /></td>
			</tr>
		</table>
		<input type="submit" value="Login">
	</cfform>
	<a href="#buildUrl('login.create')#">I don't have an account yet</a>
</cfoutput>

	</div>
