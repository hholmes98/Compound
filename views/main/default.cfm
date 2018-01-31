<!--- main/default.cfm --->

	<div class="page-header">
	  <h1>Decimate Your Debt</h1>
	</div>

	<div class="panel panel-default form-horizontal">

		<ul class="nav nav-tabs" role="tablist">
			<li role="presentation" class="active"><a href="#card-manager" aria-controls="card-manager" role="tab" data-toggle="tab">1. Manage Your Credit Cards</a></li>
			<li role="presentation"><a href="#emergency" aria-controls="emergency" role="tab" data-toggle="tab">2. Select Emergency Card</a></li>
			<li role="presentation"><a href="#budget" aria-controls="budget" role="tab" data-toggle="tab">3. Set Budget</a></li>
			<li role="presentation"><a href="#paycheck_frequency" aria-controls="paycheck_frequency" role="tab" data-toggle="tab">4. Specify Paycheck Frequency</a></li>
		</ul>

		<div class="tab-content">

			<!-- tab 1 -->
			<div role="tabpanel" class="panel-body tab-pane active" id="card-manager">
				<table class="table table-striped table-bordered table-valign-middle">
					<thead>
					<tr>
						<th colspan="5">
							<h3>These are your cards. There are many like them. But these ones are yours.</h3>
						Update your entire budget here. Change any card's name, balance, interest rate or minimum payment. Click 'Add a new card' to for more debt. Click 'Delete' to remove the entire card from your profile. While changing info, click 'Reset' if you need to start over.</h2></th>
					</tr>
					<tr>
						<th colspan="5"><button tooltips tooltip-side="top right" tooltip-template="message goes here" type="button" class="btn button btn-default" ng-click="newCard(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>)"><span class="glyphicon glyphicon-plus"></span> Add a new card</button></th>
					</tr>
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
							<div class="input-group">
								<span class="input-group-addon">$</span>
								<input type="text" class="form-control" ng-model="cards[key].balance">
							</div>
						</td>
						<td>
							<div class="input-group">
								<input type="text" class="form-control" ng-model="cards[key].interest_rate">
								<span class="input-group-addon">%</span>
							</div>
						</td>
						<td>
							<div class="input-group">
								<span class="input-group-addon">$</span>
								<input type="text" class="form-control" ng-model="cards[key].min_payment">
							</div>
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm.$pristine }" ng-disabled="myForm.$pristine" ng-click="saveCard(key, cards[key]);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm.$setPristine(true)" ><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
							<button class="btn button btn-default" ng-class="{'btn-warning': !myForm.$pristine }" ng-disabled="myForm.$pristine" ng-click="resetCard(key);myForm.$setPristine(true)" ><span class="glyphicon glyphicon-refresh"></span> Reset</button>
							<button class="btn button btn-default" ng-click="deleteCard(key);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);"><span class="glyphicon glyphicon-remove"></span> Delete</button>
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
						<th colspan="2"><h3>When The Chips Are Down</h3>
							Your emergency card is the one card that you'll lean on when you have an unexpected medical bill, car trouble, etc.
							<ol>
								<li>It must be usable anywhere (so don't pick a Gas card!)</li>
								<li>Casual shopping is not an emergency! (think: food, shelter, safety)</li>
							</ol>
						</th>
					</tr>
					</thead>
					<tbody>
					<tr class="align-top" ng-form name="myForm2">
						<td>
							<select type="select" style="background:#fff;" class="form-control" ng-model="selected" ng-options="key as cards[key].label for key in keylist">
							</select>
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm2.$pristine }" ng-disabled="myForm2.$pristine" ng-click="setAsEmergency(cards[selected].card_id,<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm2.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Select This Card</button>
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
						<th colspan="2"><h3>Everything Counts in Large Amounts</h3>
						How much have you budgeted to pay off debt each month? Enter the dollar and cent value below.<br/><br/>
						Make it count! The more, the better...but make sure <i>you continue to live within your means!</i>
					</th>
					</tr>
					</thead>
					<tbody>
					<tr class="align-top" ng-form name="myForm3">
						<td>
							I'll commit $<input type="text" ng-model="preferences.budget" /> a month to decimate my debt.
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm3.$pristine }" ng-disabled="myForm3.$pristine" ng-click="setBudget(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>, preferences.budget);deletePlan(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm3.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
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
						<th colspan="2"><h3>What's The Frequency, <cfoutput>#session.auth.user.getName()#</cfoutput>?</h3>
							In order to determine what you'll pay and when, the frequency of your income is key. It's not ok to pay off debt <i>but also go hungry at the same time</i>.
							Based on what you tell us here, we'll calculate the smartest pay schedule that doesn't cripple your day-to-day life.
						</th>
					</tr>
					</thead>
					<tbody>
					<tr class="align-top" ng-form name="myForm4">
						<td>My income arrives:
							<select style="background:#fff;" ng-model="preferences.pay_frequency">
								<option value="1">Once a month (12 paychecks per year)
								<option value="2">Twice a month (24 paychecks per year)
								<option value="3">Every two weeks (26 paychecks per year)
								<option value="0">It's complicated (can't or don't want to say)
							</select>
						</td>
						<td>
							<button class="btn button btn-default" ng-class="{'btn-success': !myForm4.$pristine }" ng-disabled="myForm4.$pristine" ng-click="setPayFrequency(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>,preferences.pay_frequency);myForm4.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>



		</div>
	</div>
