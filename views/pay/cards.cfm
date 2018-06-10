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
                <toggle id="show_all" name="show_all" ng-model="showAllCards" ng-change="showAllCards==!showAllCards;filterBy()" on="All" off="Payment Due" onstyle="btn-default" offstyle="btn-primary btn-sm"></toggle>
              </th>
            </tr>
            <tr>
              <th><a href="javascript:void(0)" ng-click="sortBy('label', false)">Card <span ng-show="orderByField=='label'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
              <th><a href="javascript:void(0)" ng-click="sortBy('pay_date', true)">Pay On <span ng-show="orderByField=='pay_date'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
            </tr>
          </thead>
          <tbody>
            <tr class="align-top" ng-form name="myForm" ng-repeat="card in cards track by $index"><!-- take this off so no jumpy  | cardSorter:orderByField:reverseSort | noPaymentFilter:pay_dates:showAllCards -->
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
          <div class="ow-header">Card Summary</div>
          <h2 shadow-text="{{selected.label}}"><cfoutput>{{selected.label}}</cfoutput></h2>
      </div>
    </div>

    <div class="row">
      <div class="col-md-6">

        <form name="cardBalanceForm" id="cardBalanceForm" class="form-inline">
        <div class="form-group" ng-form name="balanceForm" ng-class="{'has-error': balanceForm.$invalid }">
          <label for="balance">Current Balance</label>
          <div class="input-group">
            <div class="input-group-addon">$</div>
            <input type="text" id="balance" class="form-control" ng-model="selected.balance" dollar-input />
          </div>
          <span ng-show="balanceForm.$invalid" id="balanceHelpBlock" class="help-block">Must be a valid dollar amount.</span>
        </div>
        <button class="btn button btn-default" ng-class="{'btn-success': !balanceForm.$pristine }" ng-disabled="balanceForm.$pristine||balanceForm.$invalid" ng-click="recalculateCard(selected);cardBalanceForm.$setPristine(true);cardPaymentForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span><span class="btn-label"> Update</span></button>
        </form>

      </div>

      <div class="col-md-6">

        <form name="cardPaymentForm" id="cardPaymentForm" class="form-inline">
        <div class="form-group" ng-form name="payForm" ng-class="{'has-error': payForm.$invalid }">
          <label for="min_payment">Current Min. Payment</label>
          <div class="input-group">
            <div class="input-group-addon">$</div>
            <input type="text" id="min_payment" class="form-control" ng-model="selected.min_payment" dollar-input />
          </div>
          <span ng-show="payForm.$invalid" id="minPaymentHelpBlock" class="help-block">Must be a valid dollar amount.</span>
        </div>
        <button class="btn button btn-default" ng-class="{'btn-success': !payForm.$pristine }" ng-disabled="payForm.$pristine||balanceForm.$invalid" ng-click="recalculateCard(selected);cardPaymentForm.$setPristine(true);cardBalanceForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span><span class="btn-label"> Update</span></button>
        </form>

      </div>

    </div>

    <div class="row">
      <div class="col-md-12" align="center">
        <h3>Recommended Payment:</h3>
      </div>
    </div>

    <div class="row">
      <div class="col-md-4 col-md-offset-2">
        <span class="dollar-large" ng-model="selected">
          <div class="ow-data">
            <span uib-tooltip-html="'<cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> recommends you do not make a payment on this card this month. Instead, call the company to request a deferral. If you need help with this, <a href=\'<cfoutput>#application.static_urls.call#</cfoutput>\'>follow this guide</a>.'" tooltip-enable="{{selected.calculated_payment < 0}}" ng-bind-html="selected.calculated_payment|calculatedPaymentFilter" />
          </div>
        </span>
      </div>
      <div class="col-md-2">
        <div ng-show="selected.calculated_payment=='Thinking...'" class='loader'></div>
      </div>
      <div class="col-md-4">
      </div>
    </div>

    <div class="row">
      <div class="col-md-12" align="center">
        <span>
          <cfoutput><button class="btn button btn-default" ng-disabled="selected.calculated_payment=='Thinking...'" ng-click="returnToList(#pageStart#);cardPaymentForm.$setPristine(true);cardBalanceForm.$setPristine(true)"><span class="glyphicon glyphicon-circle-arrow-left"></span> Done / Return to Cards</button></cfoutput>
        </span>
      </div>
    </div>

  </div><!-- // container -->
</div><!-- // pan-page -->