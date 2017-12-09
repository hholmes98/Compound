<!--- views/pay/choose --->

<div class="pan-page pan-page-2">

	<div class="page-header">
	  <h1>Select a Card to Pay</h1>
	</div>
	
	<div class="panel panel-default form-horizontal" ng-controller="ddCtrl">

		<div class="panel-body tab-pane" id="card-manager">
			<div align="center">
				<h2><cfoutput>#session.auth.user.getName()#'s Cards</cfoutput></h2>
			</div>
			<table class="table table-striped table-bordered table-valign-middle">
				<thead>
				<tr>
					<th class="col-md-6">Card Name</th>
					<!-- <th class="col-md-4">Pay This Amount</th> -->
				</tr>
				</thead>					
				<tbody>
					
				<tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist">
					<td>
						{{cards[key].label}}
					</td>
				</tr>					
				</tbody>	
			</table>
		</div>
	
	</div>		

</div>	
