<!-- views/cards/manage -->
<div class="page-header">
  <h1>Update Your Budget</h1>
  <h3>This is where you decimate your debt.</h3>
</div>

<p>
  Configure and customize your plan below. Click each tab to reveal the details you can personalize.
</p>

<br/>

<div class="panel panel-default form-horizontal">

  <ul class="nav nav-tabs">
    <li ng-class="{'active': cardManagerTab==true}"><a ng-click="cardManagerTab=true;emergencyTab=false;budgetTab=false;paycheckFrequencyTab=false" href="javascript:void(0)" aria-controls="card-manager"><i class="far fa-credit-card"></i> Manage Credit Cards</a></li>
    <li ng-class="{'active': emergencyTab==true}"><a ng-click="cardManagerTab=false;emergencyTab=true;budgetTab=false;paycheckFrequencyTab=false" href="javascript:void(0)" aria-controls="emergency"><i class="fas fa-exclamation-triangle"></i> Select Emergency Card</a></li>
    <li ng-class="{'active': budgetTab==true}"><a ng-click="cardManagerTab=false;emergencyTab=false;budgetTab=true;paycheckFrequencyTab=false" href="javascript:void(0)" aria-controls="budget"><i class="fas fa-money-bill-alt"></i> Set Budget</a></li>
    <li ng-class="{'active': paycheckFrequencyTab==true}"><a ng-click="cardManagerTab=false;emergencyTab=false;budgetTab=false;paycheckFrequencyTab=true" href="javascript:void(0)" aria-controls="paycheck-frequency"><i class="fas fa-redo-alt"></i> Specify Paycheck Frequency</a></li>
  </ul>

  <div class="tab-content">

    <!-- tab 1 -->
    <div ng-show="cardManagerTab" id="card-manager" class="panel-body">
      <div><!--- class="table table-striped table-bordered table-valign-middle" --->

        <div class="row panel-header">
          <div class="col-md-12">
            <h3>These are your cards. There are many like them. But these ones are yours.</h3>
            <p>
              Update your entire budget here. Change any card's name, balance, interest rate or minimum payment.
              Click 'Add a new card' to for more debt. Click 'Delete' to remove the entire card from your profile.
              While changing info, click 'Reset' if you need to start over.
            </p>
          </div>
        </div>

        <div class="row panel-header">
          <div class="col-md-2"><button uib-tooltip="Cards can also be loans!" type="button" class="btn button btn-default" ng-click="newCard(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>)"><span class="glyphicon glyphicon-plus"></span> Add a new card</button></div>
          <div class="col-md-4 col-md-offset-2"><strong>Debt Load:</strong> <font style="color:red">{{totalDebtLoad | currency}}</font></div>
          <div class="col-md-4"><strong>Monthly Payments:</strong> {{totalMinPayment | currency}}</div>
        </div>

        <div class="row panel-header col-names">
          <div class="col-md-4"><a href="javascript:void(0)" ng-click="sortBy('label', false)">Card <span ng-show="orderByField=='label'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></div>
          <div class="col-md-2"><a href="javascript:void(0)" ng-click="sortBy('balance', true)">Balance <span ng-show="orderByField=='balance'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></div>
          <div class="col-md-2"><a href="javascript:void(0)" ng-click="sortBy('interest_rate', true)">Interest Rate <span ng-show="orderByField=='interest_rate'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></div>
          <div class="col-md-2"><a href="javascript:void(0)" ng-click="sortBy('min_payment', true)">Min. Payment <span ng-show="orderByField=='min_payment'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></div>
          <div class="col-md-2"></div>
        </div>

        <div class="row align-top panel-body" ng-form name="cardsForm" ng-repeat="card in cards track by $index"><!--- we take [| cardSorter:orderByField:reverseSort] off this so that it doesn't hop around while editing --->
          <ng-form name="innerForm">
            <input type="hidden" ng-model="card.id">
            <input type="hidden" ng-model="card.is_emergency">
            <div class="col-md-4" ng-class="{'has-error': innerForm.label.$invalid }">
              <input type="text" name="label" class="form-control" ng-model="card.label" ng-required="true">
              <span ng-show="innerForm.label.$invalid" class="help-block">Must name this card.</span>
            </div>
            <div class="col-md-2">
              <div class="input-group" ng-class="{'has-error': innerForm.balance.$invalid }">
                <span class="input-group-addon">$</span>
                <input type="text" name="balance" class="form-control" ng-model="card.balance" dollar-input>
              </div>
              <span ng-show="innerForm.balance.$invalid" class="help-block">Must be a valid dollar amount.</span>
            </div>
            <div class="col-md-2">
              <div class="input-group" ng-class="{'has-error': innerForm.interest_rate.$invalid }">
                <input type="text" name="interest_rate" class="form-control" ng-model="card.interest_rate" interest-rate-input>
                <span class="input-group-addon">%</span>
              </div>
              <span ng-show="innerForm.interest_rate.$invalid" class="help-block">Must be a valid interest rate.</span>
            </div>
            <div class="col-md-2">
              <div class="input-group" ng-class="{'has-error': innerForm.min_payment.$invalid }">
                <span class="input-group-addon">$</span>
                <input type="text" name="min_payment" class="form-control" ng-model="card.min_payment" dollar-input>
              </div>
              <span ng-show="innerForm.min_payment.$invalid" class="help-block">Must be a valid dollar amount.</span>
            </div>
            <div class="col-md-2">
              <button class="btn button btn-default" ng-class="{'btn-success': !cardsForm.$pristine }" ng-disabled="cardsForm.$pristine || cardsForm.$invalid" ng-click="saveCard(card);calculateAll();cardsForm.$setPristine(true)" ><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
              <button class="btn button btn-default" ng-class="{'btn-warning': !cardsForm.$pristine }" ng-disabled="cardsForm.$pristine" ng-click="resetCard(card);cardsForm.$setPristine(true)" ><span class="glyphicon glyphicon-refresh"></span> Reset</button>
              <button class="btn button btn-default" ng-click="deleteCard($index);cardsForm.$setPristine(true)"><span class="glyphicon glyphicon-remove"></span> Delete</button>
            </div>
          </ng-form>
        </div><!--- //row --->

      </div><!--- // table --->
    </div><!--- // tab1 --->

    <!-- tab 2 -->
    <div ng-show="emergencyTab" id="emergency" class="panel-body">
      <div><!--- // class="table table-striped table-bordered table-valign-middle" --->

        <div class="row panel-header">
          <div class="col-md-12"><h3>Money's Too Tight to Mention</h3>
            <p>Your emergency card is the one card that you'll lean on when you have an unexpected medical bill, car trouble, etc.
              - It must be usable anywhere (so don't pick a Gas card!)</br>
              - Casual shopping is not an emergency! (think: food, shelter, safety)</br>
            </p>
          </div>
        </div>

        <form name="emergencyForm">
        <div class="row panel-body align-top form-inline" >
          <div class="form-group col-md-4">
            <label for="emergency_card" class="control-label">I'll select:</label>
            <select type="select" class="form-control" ng-model="selected" ng-options="card as card.label for card in cards track by card.card_id"></select>
          </div>
          <div class="col-md-6">
            for emergencies.
          </div>
          <div class="col-md-2">
            <button class="btn button btn-default" form="emergencyForm" ng-class="{'btn-success': !emergencyForm.$pristine }" ng-disabled="emergencyForm.$pristine" ng-click="setAsEmergency(selected);emergencyForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
          </div>
        </div>
        </form>

      </div><!--- // table --->
    </div><!--- // tab2 --->


    <!-- tab 3 -->
    <div ng-show="budgetTab" id="budget" class="panel-body">
      <div><!---  class="table table-striped table-bordered table-valign-middle" --->

        <div class="row panel-header">
          <div class="col-md-12"><h3>Everything Counts in Large Amounts</h3>
            <p>
              How much have you budgeted to pay off debt each month? Enter the dollar and cent value below.<br/>
              <br/>
              Make it count! The more, the better...but make sure <i>you continue to live within your means!</i>
            </p>
          </div>
        </div>

        <div class="row panel-body align-top form-inline" ng-form name="cardsForm3">
          <div class="form-group col-md-4">
            <label for="budget" class="control-label">I'll commit</label>
            <div class="input-group">
              <div class="input-group-addon">$</div>
              <input type="text" class="form-control" name="budget" ng-model="preferences.budget" dollar-input />
            </div>
          </div>
          <div class="col-md-6">
            a month to decimating my debt.
          </div>
          <div class="col-md-2">
            <button class="btn button btn-default" ng-class="{'btn-success': !cardsForm3.$pristine }" ng-disabled="cardsForm3.$pristine" ng-click="setBudget(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>, preferences.budget);cardsForm3.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
          </div>
        </div>

      </div><!--- // table --->
    </div>

    <!-- tab 4 -->
    <div ng-show="paycheckFrequencyTab" id="paycheck-frequency" class="panel-body">
      <div><!--- class="table table-striped table-bordered table-valign-middle" --->

        <div class="row panel-header">
          <div class="col-md-12"><h3>What's The Frequency, <cfoutput>#session.auth.user.getName()#</cfoutput>?</h3>
            <p>
              In order to determine what you'll pay and when, the frequency of your income is key. It's not ok to pay off 
              debt <i>but also go hungry at the same time</i>. Based on what you tell us here, we'll calculate the smartest
              pay schedule that doesn't cripple your day-to-day life.
            </p>
          </div>
        </div>

        <div class="row panel-body align-top form-inline" ng-form name="frequencyForm">
          <div class="form-group col-md-7">
            <label for="pay_frequency" class="control-label">My income arrives:</label>
            <div class="input-group">
              <select class="form-control" name="pay_frequency" ng-model="preferences.pay_frequency" convert-to-number>
                <option value="1">Once a month (12 paychecks per year)
                <option value="2">Twice a month (24 paychecks per year)
                <option value="3">Every two weeks (26 paychecks per year)
                <option value="0">It's complicated (can't or don't want to say)
              </select>
            </div>
          </div>
          <div class="col-md-2 col-md-offset-3">
            <button class="btn button btn-default" ng-class="{'btn-success': !frequencyForm.$pristine }" ng-disabled="frequencyForm.$pristine" ng-click="setPayFrequency(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>,preferences.pay_frequency);frequencyForm.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
          </div>
        </div>

      </div> <!--- //table --->
    </div><!--- //tab4 --->

  </div><!-- /tab-content -->

</div><!-- /panel -->