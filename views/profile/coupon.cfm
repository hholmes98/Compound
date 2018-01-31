<!--- coupon.cfm --->
<h1>Redeem Coupon</h1>

<h2 shadow-text="Enter Coupon Code">Enter Coupon Code</h2>

<!--- <div role="form">
	<cfoutput>
		<span>
			<button class="btn button btn-default" onClick="location.href='#buildUrl('profile.basic')#';"><span class="glyphicon glyphicon-cog"></span> User Settings</button>
			<button class="btn button btn-default pull-right" onClick="location.href='#buildUrl('login.logout')#';"> Logout</button>
		</span>
	</cfoutput>
</div> --->

<div class="row">
	<div class="center-block" style="width:200px;">
		<span class="glyphicon glyphicon-large glyphicon-gift"></span>
		<input type="text" class="form-control" name="coupon-code">
		<button class="btn button btn-default btn-success"> Redeem</button>
	</div>
</div>

