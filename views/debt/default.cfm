<form name="entry" id="entry" method="post" action="<cfoutput>#buildUrl('debt.calculate')#</cfoutput>">

<!--- debt/default.cfm --->
<div id="page1" class="pan-page pan-page-1">

	<div class="container">

		<div class="page-header">
		  <span align="center"><h1><cfoutput>#application.locale[application.default_locale]['name']#</cfoutput></h1></span>
		</div>

		<cfoutput>

		<div align="center">

			<p>
				<h3>Enter your credit card debt. We'll tell you the rest.<br/>
				<br/>
				Every payment.<br/>
				<br/>
				Every date.<br/>
				<br/>
				Until you're free.</h3>
			</p>

			<br/>
			<br/>

			<table class="table table-bordered table-valign-middle">
				<tbody>
				<tr>
					<td>Let's get started: How much do you have to pay off debt each month?</td>
					<td>
						<div class="input-group">
							<span class="input-group-addon">$</span>
							<input class="form-control" type="text" placeholder="(eg. 250.00)" name="budget">
						</div>
					</td>
				</tr>
				<tr>
					<td></td>
					<td><button type="button" class="btn button btn-default btn-more"><span class="glyphicon glyphicon-circle-arrow-right"></span> Next: Enter A Card</button><br/></td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" align="center"><button type="button" class="btn button btn-default btn-login" onClick="navigateTo('#buildUrl('login.default')#')"><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button></td>
				</tr>
				</tbody>
			</table>

		</div>

		</cfoutput>

	</div>

</div>

<!-- the template for each card uses the 2nd page -->
<div id="page2" class="pan-page page-page-2">

	<div class="container">

		<cfoutput>

		<div class="card-content" align="center">

			<h3>Give us your cards!</h3>

			<table class="table table-bordered table-valign-middle">
				<tbody>
				<tr>
					<td>Enter the remaining balance on one of your cards:</td>
					<td>
						<div class="input-group">
							<span class="input-group-addon">$</span>
							<input class="form-control credit-card-balance" type="text" placeholder="(eg. 3,275.22)" name="credit-card-balance1">
						</div>
					</td>
				</tr>
				<tr>
					<td>Give it a name:</td>
					<td>
						<div class="input-group">
							<input class="form-control credit-card-label" type="text" placeholder="(eg. WF checking atm card)" name="credit-card-label1">
						</div>
					</td>
				</tr>
				<tr>
					<td></td>
					<td><button type="button" class="btn button btn-default btn-more"><span class="glyphicon glyphicon-plus"></span> Enter Another Card</button><br/></td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" align="center"><button type="button" class="btn button btn-default btn-submit" form="entry"><span class="glyphicon glyphicon-stats"></span> Show Me The Plan</button></td>
				</tr>
				</tbody>
			</table>

		</div>

		</cfoutput>

	</div>

</div>




<!--- <div id="page2" class="pan-page page-page-2">

	<div class="container">

		<div class="page-header">
		  <h1>Enter Another Card</h1>
		</div>
		
		<div class="panel panel-default form-horizontal">

			<cfoutput>

			<div align="center">

				<p>Enter your credit card debt. We'll tell you the rest. Every payment. Every date. Until you're free.</p>

				Enter a balance on one of your cards:
				<input type="text" class="credit-card-balance" name="credit-card-balance2">

				Give it a name:
				<input type="text" class="credit-card-label" name="credit-card-label2">

				...and then:
				<button type="button" id="add-another" class="btn button btn-default btn-more"><span class="glyphicon glyphicon-plus"></span> Enter Another Card</button><br/>
				Or<br/>
				<button class="btn button btn-default btn-submit" form="entry"><span class="glyphicon glyphicon-stats"></span> Show Me The Plan</button>

			</div>
			
			</cfoutput>
		
		</div>

	</div>

</div> --->




</form>