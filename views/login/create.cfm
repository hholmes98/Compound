<!--- create.cfm --->

	<div class="page-header">
	  <h1>Create an Account</h1>
	</div>

	<div class="panel panel-default form-horizontal">


<cfoutput>
	<cfform name="login" id="login" action="#buildURL('login.new')#" method="post">
		<table cellpadding="0" cellspacing="0">
			<tr>
				<th colspan="2">Your Info</th>
			</tr>
			<tr>
				<td><strong><label for="email" class="label">Name This Account:</label></strong></td>
				<td><cfinput type="text" name="name" id="name" size="50" maxlength="100" required="yes" message="Please enter a nickname for this account" /></td>
			</tr>
			<tr>
				<td><strong><label for="email" class="label">Enter Your Email Address:</label></strong></td>
				<td><cfinput type="text" name="email" id="email" size="50" maxlength="100" required="yes" message="Please enter your email address" /></td>
			</tr>
		</table>
		<input type="submit" value="Create">
	</cfform>
	<a href="#buildUrl('login.default')#">I already have an account</a>
</cfoutput>

	</div>