<!--- passwordReset.cfm --->

	<div class="page-header">
		<h2 shadow-text="Choose a New Password">Choose a New Password</h2>
	</div>

	<div class="panel panel-default form-horizontal">

	<cfoutput>
	<cfform name="account" id="account" action="#buildURL('login.changeConfirm')#" method="post">
		<input type="hidden" name="q" value="#rc.q#">
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
			<cfinput id="password" type="password" class="form-control" name="new_password" placeholder="Enter a New Password" required="yes" message="Please enter a new password." />
		</div>
		<button class="btn button btn-default" form="account"><span class="glyphicon glyphicon-check"></span> Save Changes</button>
	</cfform>
	</cfoutput>

	</div>