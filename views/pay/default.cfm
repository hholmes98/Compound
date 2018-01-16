<!--- pay/default.cfm --->

<!-- pay.default -->
<div class="pan-page pan-page-1">

	<div class="container">

		<div class="page-header">
		  <h1><cfoutput>What are we doing, #session.auth.user.getName()#?</cfoutput></h1>
		</div>

		<cfoutput>
		<div align="center">

			<span align="left">

				<button class="btn button btn-default" ng-click="panTo(2)"><span class="glyphicon glyphicon-money"></span> PAY bills</button>

			</span>

			<br/>
			<br/>

			<span align="right">

				<button class="btn button btn-default" ng-click="navigateTo('#buildUrl('main')#')"><span class="glyphicon glyphicon-cog"></span> UPDATE budget</button>

			</span>

			<br/>
			<br/>

			<span align="right">

				<button class="btn button btn-default" ng-click="navigateTo('#buildUrl('plan')#')"><span class="glyphicon glyphicon-stats"></span> SEE my future</button>

			</span>

		</div>
		</cfoutput>

	</div>

</div>

<!-- pay.choose -->
<div class="pan-page pan-page-2">

	<div class="container">

		<div class="page-header">
		  <h1>Select a Card to Pay</h1>
		</div>
		
		<div class="panel panel-default form-horizontal">

			<div class="panel-body tab-pane" id="card-list">
				<table class="table table-striped table-bordered table-valign-middle">
					<tbody>
						
					<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
						<td>
							<button class="btn button btn-default" ng-click="selectCard(key);">{{cards[key].label}}</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
		
		</div>

	</div>

</div>

<!-- pay.card -->
<div class="pan-page pan-page-3">

	<div class="container">	

		<div class="panel panel-default form-horizontal">

			<div class="panel-body tab-pane" id="card-pay" ng-form name="myForm4">
				
				<div>
					<span>
						<h3>Confirm & Pay:</h3>
						<h2 shadow-text="{{card.label}}"><cfoutput>{{card.label}}</cfoutput></h2>
					</span>
				</div>
				
				<table class="table table-striped table-bordered table-valign-middle">
					
					<tbody>
					
					<tr class="align-top">
						<td>
							If your {{card.label}} balance is...
						</td>
					</tr>	
					<tr class="align-top" ng-form name="myForm4">
						<td>
							$<input type="text" ng-model="card.balance" />
						</td>
					</tr>
					<tr class="align-top">
						<td>
							...and your minimum payment is
						</td>
					</tr>	
					<tr class="align-top" ng-form name="myForm4">
						<td>
							$<input type="text" ng-model="card.min_payment" />
						</td>
					</tr>
					<tr class="align-top">
						<td>
							...then today, you'll make a payment of:
						</td>
					</tr>
					<tr class="align-top" ng-form name="myForm4" ng-model="card">
						<td>
							${{card.calculated_payment}}
						</td>
					</tr>

					</tbody>

				</table>

				<div align="center">

					<span align="center">
						<button class="btn button btn-default" ng-click="recalculateCard(card);"><span class="glyphicon glyphicon-wrench"></span> Update & Recalculate</button>
					</span>

					<br/>
					<br/>

					<span align="center">
						<button class="btn button btn-default" ng-click="returnToList()"><span class="glyphicon glyphicon-circle-arrow-left"></span> Done / Return to Cards</button>
					</span>

				</div>

			</div>
			
		</div>

	</div>

</div>