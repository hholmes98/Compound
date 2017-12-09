<!--- main/default.cfm --->

	<div class="page-header">
	  <h1>Decimate Your Debt</h1>
	</div>

	<div class="panel panel-default form-horizontal">
		<!--<div class="panel-heading">
			<h3 class="panel-title">Manage Your Credit Cards</h3>
		</div>-->

		<div id="top-banner">
		<!-- should be 99 tall
		border-bottom: 1px solid #555555;
		text-align: center;
		padding-top: 4px;
		padding-bottom: 4px;
		-->
		</div>

		<ul class="nav nav-tabs" role="tablist">
			<li role="presentation" class="active"><a href="#card-manager" aria-controls="card-manager" role="tab" data-toggle="tab">1. Manage Your Credit Cards</a></li>
			<li role="presentation"><a href="#emergency" aria-controls="emergency" role="tab" data-toggle="tab">2. Select Emergency Card</a></li>
			<li role="presentation"><a href="#budget" aria-controls="budget" role="tab" data-toggle="tab">3. Set Budget</a></li>
			<li role="presentation"><a href="#paycheck_frequency" aria-controls="paycheck_frequency" role="tab" data-toggle="tab">4. Specify Paycheck Frequency</a></li>
		</ul>

		<div class="tab-content">

			<!-- tab 1 -->
			<div role="tabpanel" class="panel-body tab-pane active" id="card-manager">				
				<p>
					<button tooltips tooltip-side="top right" tooltip-template="message goes here" type="button" class="btn button btn-default" ng-click="newCard(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>)"><span class="glyphicon glyphicon-plus"></span> Add a card</button>
				</p>
				<table class="table table-striped table-bordered table-valign-middle">
					<thead>
					<tr>
						<th class="col-md-4">Card</th>
						<th class="col-md-2">Balance</th>
						<th class="col-md-2">Interest Rate</th>
						<th class="col-md-2">Min. Payment</th>
						<th></th>
					</tr>
					</thead>					
					<tbody>
						
					<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
						<input type="hidden" ng-model="cards[key].id">
						<input type="hidden" ng-model="cards[key].is_emergency">
						<td>
							<input type="text" class="form-control" ng-model="cards[key].label">
						</td>
						<td>
							<input type="text" class="form-control" ng-model="cards[key].balance">
						</td>
						<td>
							<input type="text" class="form-control" ng-model="cards[key].interest_rate">
						</td>
						<td>
							<input type="text" class="form-control" ng-model="cards[key].min_payment">
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm.$pristine }" ng-disabled="myForm.$pristine" ng-click="saveCard(key, cards[key]);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm.$setPristine(true)" ><span class="glyphicon glyphicon-ok"></span> Save</button>
							<button class="btn button btn-default" ng-class="{'btn-warning': !myForm.$pristine }" ng-disabled="myForm.$pristine" ng-click="resetCard(key);myForm.$setPristine(true)" ><span class="glyphicon glyphicon-remove"></span> Cancel</button>
							<button class="btn button btn-default" ng-click="deleteCard(key);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);"><span class="glyphicon glyphicon-plus"></span> Delete</button>
						</td>
					</tr>					
					</tbody>	
				</table>
			</div>

			<!-- tab 2 -->
			<div role="tabpanel" class="panel-body tab-pane" id="emergency">
				<table class="table table-striped table-bordered table-valign-middle">
					<thead>
					<tr>
						<th>Cards</th>
						<th></th>
					</tr>
					</thead>
					<tbody>
					<tr class="align-top" ng-form name="myForm2">
						<td>
							<select type="select" style="background:#fff;" class="form-control" ng-model="selected" ng-options="key as cards[key].label for key in keylist">
							</select>
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm2.$pristine }" ng-disabled="myForm2.$pristine" ng-click="setAsEmergency(cards[selected].card_id,<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm2.$setPristine(true)"><span class="glyphicon glyphicon-save"></span> Select This Card</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>


			<!-- tab 3 -->
			<div role="tabpanel" class="panel-body tab-pane" id="budget">
				<table class="table table-striped table-bordered table-valign-middle">
					<thead>
					<tr>
						<th>How much have you budgeted to pay off debt each month?</th>
						<th></th>
					</tr>
					</thead>
					<tbody>
					<tr class="align-top" ng-form name="myForm3">
						<td>
							$<input type="text" ng-model="preferences.budget" />
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm3.$pristine }" ng-disabled="myForm3.$pristine" ng-click="setBudget(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>, preferences.budget);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm3.$setPristine(true)"><span class="glyphicon glyphicon-save"></span> Update Budget</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>

			<!-- tab 4 -->
			<div role="tabpanel" class="panel-body tab-pane" id="paycheck_frequency">
				<table class="table table-striped table-bordered table-valign-middle">
					<thead>
					<tr>
						<th>How frequently are you paid?</th>
						<th></th>
					</tr>
					</thead>
					<tbody>
					<tr class="align-top" ng-form name="myForm4">
						<td>I'm paid
							<select style="background:#fff;" ng-model="preferences.pay_frequency">
								<option value="1">Once a month (12 paychecks per year)
								<option value="2">Twice a month (24 paychecks per year)
								<option value="3">Every two Weeks (26 paychecks per year)
								<option value="0">It's complicated
							</select>
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm4.$pristine }" ng-disabled="myForm4.$pristine" ng-click="setPayFrequency(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>,preferences.pay_frequency);myForm4.$setPristine(true)"><span class="glyphicon glyphicon-save"></span> Confirm</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>



		</div>
	</div>
