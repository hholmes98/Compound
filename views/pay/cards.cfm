<!-- views/pay/cards -->
<cfparam name="pageStart" default="1" />

<div class="pan-page pan-page-<cfoutput>#pageStart#</cfoutput>">
  <div class="container">
    <div class="page-header">
      <h1>Pay Your Bills</h1>
      <h3>Pick a card. Any card.</h3>
      <p>
        Get your recommended payment for any card. If the balance and/or minimumn payment have changed, you can update them
        on-the-fly and your recommended payment will be re-calculated instantly.
      </p>
    </div>
    <div class="form-horizontal">
      <div id="card-list">
        <table class="table table-striped table-bordered table-valign-middle">
          <thead>
            <tr>
              <th colspan="2" align="center">
                <span style="font-weight:400;">Cards to Show:</span>
                <toggle id="show_all" name="show_all" ng-model="showAllCards" on="All" off="Payment Due" onstyle="btn-default" offstyle="btn-primary btn-sm"></toggle>
              </th>
            </tr>
            <tr>
              <th><a href="javascript:void(0)" ng-click="reverseSort=(orderByField!='label')?false:!reverseSort;orderByField='label'">Card <span ng-show="orderByField=='label'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
              <th><a href="javascript:void(0)" ng-click="reverseSort=(orderByField!='pay_date')?false:!reverseSort;orderByField='pay_date'">Pay On <span ng-show="orderByField=='pay_date'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
            </tr>
          </thead>
          <tbody>
            <tr class="align-top" ng-form name="myForm" ng-repeat="card in cards | cardSorter:orderByField:reverseSort | noPaymentFilter:showAllCards">
              <td>
                <cfoutput><button class="btn button btn-default btn-block" ng-click="selectCard(card,#Evaluate(pageStart+1)#);">{{card.label}}</button></cfoutput>
              </td>
              <td>{{card.pay_date | prettyPayDateFilter | date: 'MMM d' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<div class="pan-page pan-page-<cfoutput>#Evaluate(pageStart+1)#</cfoutput>">
  <div class="container"> 

    <div class="row">
      <div class="col-md-12">

          <h2 shadow-text="{{card.label}}"><cfoutput>{{card.label}}</cfoutput></h2>

      </div>
    </div>

    <div class="row">
      <div class="col-md-6">

        <form name="cardBalanceForm" id="cardBalanceForm" class="form-inline">
        <div class="form-group" ng-form name="balanceForm" ng-class="{'has-error': balanceForm.$invalid }">
          <label for="balance">Current Balance</label>
          <div class="input-group">
            <div class="input-group-addon">$</div>
            <input type="text" id="balance" class="form-control" ng-model="card.balance" dollar-input />
          </div>
          <span ng-show="balanceForm.$invalid" id="balanceHelpBlock" class="help-block">Must be a valid dollar amount.</span>
        </div>
        <button class="btn button btn-default" ng-class="{'btn-success': !balanceForm.$pristine }" ng-disabled="balanceForm.$pristine||balanceForm.$invalid" ng-click="recalculateCard(card);balanceForm.$setPristine(true);payForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span><span class="btn-label"> Update</span></button>
        </form>

      </div>

      <div class="col-md-6">

        <form name="cardPaymentForm" id="cardPaymentForm" class="form-inline">
        <div class="form-group" ng-form name="payForm" ng-class="{'has-error': payForm.$invalid }">
          <label for="min_payment">Current Min. Payment</label>
          <div class="input-group">
            <div class="input-group-addon">$</div>
            <input type="text" id="min_payment" class="form-control" ng-model="card.min_payment" dollar-input />
          </div>
          <span ng-show="payForm.$invalid" id="minPaymentHelpBlock" class="help-block">Must be a valid dollar amount.</span>
        </div>
        <button class="btn button btn-default" ng-class="{'btn-success': !payForm.$pristine }" ng-disabled="payForm.$pristine||balanceForm.$invalid" ng-click="recalculateCard(card);balanceForm.$setPristine(true);payForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span><span class="btn-label"> Update</span></button>
        </form>

      </div>

    </div>

    <div class="row">
      <div class="col-md-12" align="center">

        <h3>Recommended Payment:</h3>
        <span class="dollar-large" ng-model="card">{{(card.calculated_payment|currency) || "Thinking..."}}</span>
        <br/><br/>
        <span>
            <cfoutput><button class="btn button btn-default" ng-click="returnToList(#pageStart#);payForm.$setPristine(true);balanceForm.$setPristine(true)"><span class="glyphicon glyphicon-circle-arrow-left"></span> Done / Return to Cards</button></cfoutput>
        </span>

      </div>
    </div>

  </div><!-- // container -->
</div><!-- // pan-page -->