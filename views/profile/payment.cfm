<!--- card.cfm --->
<h1>Profile</h1>

<h2 shadow-text="Payment Details">Payment Details</h2>
<div role="form">
	<cfoutput>
		<span>
			<button class="btn button btn-default" onClick="location.href='#buildUrl('profile.basic')#';"><span class="glyphicon glyphicon-cog"></span> User Settings</button>
			<button class="btn button btn-default pull-right" onClick="location.href='#buildUrl('login.logout')#';"> Logout</button>
		</span>
	</cfoutput>
</div>

<div>
	<p>
	Pay with:
	</p>
	<div class="radio">
	  <label>
	    <input type="radio" name="pay-type" id="pay-type1" value="1" checked>
	    Credit Card
	  </label>
	</div>
	<div class="radio">
	  <label>
	    <input type="radio" name="pay-type" id="pay-type2" value="2">
	    PayPal Account
	  </label>
	</div>
</div>

<div>
	<span>
		<p>
			Credit card number
		</p>
		<span class="glyphicon glyphicon-credit-card"></span> 3*** ***** *2003 - <a href="#buildUrl('profile.card')#">Enter a new card</a>
	</span>
</div>

<div>
	<span>
		<p>
			Expiration
		</p>
		<select class="form-control" name="exp-month">
			<cfoutput>
				<cfloop from="1" to="12" index="i">
					<option value="#i#">#numberformat(i, '00')#
				</cfloop>
			</cfoutput>
		</select>
		<select class="form-control" name="exp-year">
			<cfoutput>
				<cfloop from="#Year(Now())#" to="#Evaluate(Year(Now())+10)#" index="i">
					<option value="#i#">#i#
				</cfloop>
			</cfoutput>
		</select>
	</span>
	
	<span>
		<p>
			CVV (?)
		</p>
		<input type="text" name="cvv" class="form-control" />
	</span>
</div>

<div>
	<span>
		<p>
			Country
		</p>
		<select name="country" class="form-control">
			<option value="United States of America">United States of America
		</select>
	</span>
	<span>
		<p>
			State
		</p>
		<select name="state" class="form-control">
			<option value="Colorado">Colorado
		</select>
	</span>	
</div>

<div>
	<span>
		<p>
			Postal Code
		</p>
		<input type="text" name="postal-code" class="form-control">
	</span>
</div>

<button class="btn button btn-default btn-success"> Update credit card</button>
<button class="btn button btn-default"> Cancel</button>

<div>
	<h5><small>Your next charge of x$ will process on #Month# 24, #Year#, for another month of service.</small></h5>
</div>