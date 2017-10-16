<!--- views/plan/default
replaces /plan.html
 --->
	<div class="page-header">
	  <h1><cfoutput>#session.auth.user.getName()#'s Plan Of Attack</cfoutput></h1>
	</div>

	<div class="panel panel-default form-horizontal" ng-controller="ddCtrl">

		<ul class="nav nav-tabs" role="tablist">
			<li role="presentation"><a href="#card-manager" aria-controls="card-manager" role="tab" data-toggle="tab">Payments Per Card</a></li>
			<li role="presentation" class="active"><a href="#schedule" aria-controls="schedule" role="tab" data-toggle="tab">Schedule By Month</a></li>
			<li role="presentation"><a href="#milestones" aria-controls="milestones" role="tab" data-toggle="tab">Milestones</a></li>
		</ul>

		<div class="tab-content">

			<!-- tab 1 

			List out the cards, and display the calculated payment for each card.
			-->
			<div role="tabpanel" class="panel-body tab-pane" id="card-manager">
				<div align="center">
					<h2><cfoutput>For This Month (#MonthAsString(Month(Now()))# #Year(Now())#)</cfoutput></h2>
				</div>
				<table class="table table-striped table-bordered table-valign-middle">
					<thead>
					<tr>
						<th class="col-md-6">For This Card</th>
						<th class="col-md-4">Pay This Amount</th>						
					</tr>
					</thead>					
					<tbody>
						
					<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
						<td>
							{{cards[key].label}}
						</td>
						<td>
							{{cards[key].calculated_payment | currency}}
						</td>
					</tr>					
					</tbody>	
				</table>
			</div>

			<!-- tab 2

			Render the current month, color coded by the pay frequency, and show the X calculated amounts that are being
			paid per selection (so if twice a month, show the calculated $$ for 1st half and the calculated $$ for 2nd half)

			 -->
			<div role="tabpanel" class="panel-body tab-pane active" id="schedule">
				<!-- using https://github.com/angular-ui/ui-calendar -->
        <div class="alert-success calAlert" ng-show="alertMessage != undefined && alertMessage != ''">
          <h4>{{alertMessage}}</h4>
        </div>
				<div ui-calendar="uiConfig.calendar" class="span8 calendar" ng-model="eventSources"></div>
			</div>


			<!-- tab 3

			Show a line graph of dates traveling into the future for the next year, and draw vertical dashed lines at various milestones
			(where certain cards are paid off) to convey a sense of progression, regardless of debt load.

			 -->
			<div role="tabpanel" class="panel-body tab-pane" id="milestones">

				<div id="milestones"></div>
				
			</div>

			



		</div>
	</div>

