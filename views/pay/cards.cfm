<!-- views/pay/cards -->
<cfparam name="pageStart" default="1" />

<div class="pan-page pan-page-<cfoutput>#pageStart#</cfoutput>">
  <div class="container">
    <div class="page-header">
      <h1>Pay Bills</h1>
      <h3>Pick a card. Any card.</h3>
    </div>
    <div class="panel panel-default form-horizontal">
      <div class="panel-body tab-pane" id="card-list">
        <table class="table table-striped table-bordered table-valign-middle">
          <tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist | orderBy:'null':false:cardLabelCompare">
            <td>
              <cfoutput><button class="btn button btn-default" ng-click="selectCard(key,#Evaluate(pageStart+1)#);">{{cards[key].label}}</button></cfoutput>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</div>

<div class="pan-page pan-page-<cfoutput>#Evaluate(pageStart+1)#</cfoutput>">
  <div class="container"> 
    <div class="panel panel-default form-horizontal">
      <div class="panel-body tab-pane">
        <div>
          <span>
            <h3>Confirm & Pay:</h3>
            <h2 shadow-text="{{card.label}}"><cfoutput>{{card.label}}</cfoutput></h2>
          </span>
        </div>

        <table class="table table-striped table-bordered table-valign-middle">
          <tr class="align-top">
            <td colspan="2" align="center">
              <h3>If your balance is:</h3>
            </td>
          </tr> 
          <tr ng-form name="balanceForm" class="align-top">
            <td>
              <div class="form-group-lg">
                <div class="input-group">
                  <div class="input-group-addon">$</div>
                  <input type="text" class="form-control" ng-model="card.balance" dollar-input />
                </div>
              </div>
            </td>
            <td>
              <button class="btn button btn-default" ng-class="{'btn-success': !balanceForm.$pristine }" ng-disabled="balanceForm.$pristine" ng-click="recalculateCard(card);balanceForm.$setPristine(true);payForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span><span class="btn-label"> Save</span></button>
            </td>
          </tr>
          <tr class="align-top">
            <td colspan="2" align="center">
              <h3>...and your minimum payment is:</h3>
            </td>
          </tr> 
          <tr ng-form name="payForm" class="align-top">
            <td>
              <div class="form-group-lg">
                <div class="input-group">
                  <div class="input-group-addon">$</div>
                  <input type="text" class="form-control" ng-model="card.min_payment" dollar-input />
                </div>
              </div>
            </td>
            <td>
              <button class="btn button btn-default" ng-class="{'btn-success': !payForm.$pristine }" ng-disabled="payForm.$pristine" ng-click="recalculateCard(card);payForm.$setPristine(true);balanceForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span><span class="btn-label"> Save</span></button>
            </td>
          </tr>
          <tr class="align-top">
            <td colspan="2" align="center">
              <h3>...then today, you'll make a payment of:</h3>
            </td>
          </tr>
          <tr class="align-top" ng-model="card">
            <td colspan="2" align="center">
              <span class="dollar-large">{{(card.calculated_payment|currency) || "Thinking..."}}</span>
            </td>
          </tr>
        </table>

        <div align="center">
          <span align="center">
            <cfoutput><button class="btn button btn-default" ng-click="returnToList(#pageStart#)"><span class="glyphicon glyphicon-circle-arrow-left"></span> Done / Return to Cards</button></cfoutput>
          </span>
        </div>

      </div>
    </div>
  </div>
</div>