<!-- views/pay/cards -->

<!--- <div class="spacer" ng-cloak="!(loaded)"></div> --->

<div class="top-screen-quarter-buffer"></div>

<div class="pan-page pan-page-2 slide" data-anchor="cards" ng-cloak>
  <div class="container">

    <div class="page-header">
      <h1>Pay Your Bills</h1>
      <h3>Pick a card. Any card.</h3>
      <p>
        Get your recommended payment for any card. If the <strong>balance</strong> and/or <strong>minimum payment</strong> have changed, you can update them
        on-the-fly and your recommended payment will be recalculated instantly.
      </p>
    </div>

    <div class="form-horizontal">
      <div id="card-list">
        <table class="table table-striped table-bordered table-valign-middle">
          <thead>
            <tr>
              <th colspan="3" style="text-align:center;">
                <span style="font-weight:400;">Cards to Show:</span>
                <toggle id="show_all" name="show_all" ng-model="showAllCards" ng-change="showAllCards==!showAllCards;filterBy()" on="All" off="Payment Due" onstyle="btn-default" offstyle="btn-primary btn-sm"></toggle>
              </th>
            </tr>
            <tr>
              <th colspan="3" style="text-align:center;">
                <button class="btn button btn-default" uib-tooltip-html="'Previous Month'" ng-disabled="isToday()" ng-click="moveMonth(-1)"><i class="fas fa-caret-left"></i> <i class="fas fa-calendar-alt"></i></button>
                <span style="font-weight:400;">Payments for: </span>
                <span ng-bind-html="trackingMonth"></span>
                <button class="btn button btn-default" uib-tooltip-html="'Next Month'" ng-click="moveMonth(1)"> <i class="fas fa-calendar-alt"></i> <i class="fas fa-caret-right"></i></button>
              </th>
            </tr>
            <tr>
              <th><a href="javascript:void(0)" ng-click="sortBy('label', false)">Card <span ng-show="orderByField=='label'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
              <th><a href="javascript:void(0)" ng-click="sortBy('pay_date', true)">Pay On <span ng-show="orderByField=='pay_date'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
            </tr>
          </thead>
          <tbody>
            <tr class="align-top" ng-form name="billsForm" ng-repeat="card in cards track by $index"><!-- take this off so no jumpy  | cardSorter:orderByField:reverseSort | noPaymentFilter:pay_dates:showAllCards -->
              <td align="center">
                <cfoutput><button ng-class="{'btn button btn-default btn-block btn-fire': card.is_hot, 'btn button btn-default btn-block': !card.is_hot}" ng-click="selectCard(card)">{{card.label}}</button></cfoutput>
              </td>
              <td>
                <span ng-show="card.actual_payment!=''" class="rubber">Paid</span>
                {{card.pay_date | prettyPayDateFilter | date: 'MMM d' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</div>

<div class="pan-page pan-page-3 slide" data-anchor="detail" ng-cloak>
  <div class="container">

    <div class="row">
      <div class="col-md-12">
          <div ng-class="{'ow-header ow-fire': selected.is_hot,'ow-header': !selected.is_hot}">Card Summary</div>
          <h2 shadow-text="{{selected.label}}"><cfoutput>{{selected.label}}</cfoutput></h2>
      </div>
    </div>

    <!-- ** NOT PAID VIEW ** -->
    <div ng-show="selected.actual_payment==''">

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
            <button class="btn button btn-default" ng-class="{'btn-success': !balanceForm.$pristine }" ng-disabled="balanceForm.$pristine||balanceForm.$invalid" ng-click="recalculateCard(selected);cardBalanceForm.$setPristine(true);cardPaymentForm.$setPristine(true)">
              <span class="glyphicon glyphicon-ok"></span>
              <span class="btn-label"> Update</span>
            </button>
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
            <button class="btn button btn-default" ng-class="{'btn-success': !payForm.$pristine }" ng-disabled="payForm.$pristine||balanceForm.$invalid" ng-click="recalculateCard(selected);cardPaymentForm.$setPristine(true);cardBalanceForm.$setPristine(true)">
              <span class="glyphicon glyphicon-ok"></span>
              <span class="btn-label"> Update</span>
            </button>
          </form>

        </div>

      </div><!-- // row -->

      <div class="row bottom-buffer">
        <div class="col-md-12" align="center">
          <h3>Recommended Payment:</h3>
        </div>
      </div>

      <!-- display the actual recommended amount (be nice if this sized up a bit when in mobile) -->
      <div class="row">
        <div class="col-md-5"></div>
        <div class="col-md-2">
          <span class="dollar-large" ng-model="selected">
            <div class="ow-data">
              <span uib-tooltip-html="'<cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> recommends you do not make a payment on this card this month. Instead, call the company to request a deferral. If you need help with this, <a href=\'<cfoutput>#application.static_urls.call#</cfoutput>\'>follow this guide</a>.'" tooltip-enable="{{selected.calculated_payment < 0}}" ng-bind-html="calculated_payment_text|calculatedPaymentFilter">
              </span>
            </div>
          </span>
        </div>
        <div class="col-md-5"></div>
      </div>

      <!-- loader animation (shown when loading) -->
      <div class="row">
        <div class="col-md-5"></div>
        <div class="col-md-2">
          <div ng-show="calculated_payment_text=='Thinking...'" class='loader'></div>
        </div>
        <div class="col-md-5"></div>
      </div>

      <!-- mark paid -->
      <div class="row bottom-buffer">
        <div class="col-md-12" align="center">
          <span class="col-md-2"></span>
          <span class="col-md-8">
            <cfoutput>
              <button class="btn button btn-default bottom-buffer" ng-show="!customAmount" ng-click="selected.actual_payment=selected.calculated_payment;makePayment()" ng-disabled="calculated_payment_text=='Thinking...'">
                <i class="fas fa-check"></i> Mark as Paid: {{selected.calculated_payment|currency}}
              </button>
              &nbsp;
              <button class="btn button btn-default bottom-buffer" ng-show="!customAmount" ng-disabled="calculated_payment_text=='Thinking...'" ng-click="customAmount=true">
                <i class="fas fa-check-circle"></i> Let Me Mark a Custom Amount
              </button>
              <span ng-show="customAmount">

                <form name="customAmountForm" id="customAmountForm" class="form-inline" ng-class="{'has-error': customAmountForm.$invalid }">
                  <input type="hidden" name="actual_payment" ng-model="selected.actual_payment" />
                  <div class="col-md-12">
                    <div class="input-group" ng-class="{'has-error': customAmountForm.actual_payment.$invalid }">
                      <span class="input-group-addon">$</span>
                      <input type="text" name="custom_payment" ng-model="custom_payment" class="form-control" dollar-input>
                    </div>

                    <span ng-show="customAmountForm.custom_payment.$invalid" ng-disabled="calculated_payment_text=='Thinking...'" class="help-block">Must be a valid dollar amount.</span>

                    <button class="btn button btn-link" type="button" ng-disabled="calculated_payment_text=='Thinking...'" ng-click="customAmount=false">
                      <i class="fas fa-times-circle"></i> Cancel
                    </button>

                    <button class="btn button btn-default" ng-click="selected.actual_payment=custom_payment;makePayment()" ng-disabled="(calculated_payment_text=='Thinking...'||customAmountForm.custom_payment.$invalid)">
                      <i class="fas fa-check"></i> Record Payment
                    </button>
                  </div>
                </form>

              </span>
            </cfoutput>
          </span>
          <span class="col-md-2"></span>
        </div>
      </div>

    </div><!-- // ** NOT-PAID ** -->

    <!--- ** PAID VIEW ** --->

    <div ng-show="selected.actual_payment!=''">

      <div class="row bottom-buffer">
        <div class="col-md-12" align="center">
          <h3>Recommended Payment:</h3>
        </div>
      </div>

      <!-- display the actual recommended amount (be nice if this sized up a bit when in mobile) -->
      <div class="row">
        <div class="col-md-5"></div>
        <div class="col-md-2">
          <span class="dollar-large" ng-model="selected">
            <div class="ow-data">
              <span uib-tooltip-html="'<cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> recommends you do not make a payment on this card this month. Instead, call the company to request a deferral. If you need help with this, <a href=\'<cfoutput>#application.static_urls.call#</cfoutput>\'>follow this guide</a>.'" tooltip-enable="{{selected.calculated_payment < 0}}" ng-bind-html="calculated_payment_text|calculatedPaymentFilter"></span>
            </div>
          </span>
        </div>
        <div class="col-md-5"></div>
      </div>

      <div class="row bottom-buffer">
        <div class="col-md-12" align="center">
          <h3>You Actually Paid:</h3>
        </div>
      </div>

      <!-- display the actual recommended amount (be nice if this sized up a bit when in mobile) -->
      <div class="row">
        <div class="col-md-5"></div>
        <div class="col-md-2">
          <span class="dollar-large" ng-model="selected">
            <div class="ow-data light">
              <span ng-bind-html="selected.actual_payment|calculatedPaymentFilter"></span>
            </div>
          </span>
        </div>
        <div class="col-md-5"></div>
      </div>
    </div>

    <!-- back to cards button -->
    <div class="row bottom-buffer">
      <div class="col-md-12" align="center">
        <span>
          <cfoutput>
            <button class="btn button btn-link" ng-disabled="calculated_payment_text=='Thinking...'" ng-click="returnToList(1);cardPaymentForm.$setPristine(true);cardBalanceForm.$setPristine(true)">
              <span class="glyphicon glyphicon-circle-arrow-left"></span> Return to Cards
            </button>
          </cfoutput>
        </span>
      </div>
    </div>

  </div><!-- // container -->
</div><!-- // pan-page -->