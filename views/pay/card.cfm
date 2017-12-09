<!--- views/pay/card --->

<div class="pan-page pan-page-3">

	<div class="panel panel-default form-horizontal" ng-controller="ddCtrl">

		<div class="panel-body tab-pane" id="card-manager">
			
			<div align="center">
				<h2><cfoutput>{{cards[key].label}}</cfoutput></h2>
			</div>
			
			<table class="table table-striped table-bordered table-valign-middle">
				
				<!--<thead>
				<tr>
					<th class="col-md-6">Pay If</th>
				</tr>
				</thead>-->

				<tbody>
				
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						If Your Balance Is:
					</td>
				</tr>	
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						{{cards[key].balance}}
					</td>
				</tr>
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						And Your Minimum Payment is:
					</td>
				</tr>	
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						{{cards[key].min_payment}}
					</td>
				</tr>
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						Today, You Pay:
					</td>
				</tr>
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						{{cards[key].calculated_payment}}
					</td>
				</tr>

				</tbody>	

			</table>

			Choice?
			<button class="btn button btn-default"><span class="glyphicon glyphicon-save"></span> Change Info</button>

			Or
			<button class="btn button btn-default"><span class="glyphicon glyphicon-save"></span> Done With This Card</button>

		</div>
		
	</div>

</div>