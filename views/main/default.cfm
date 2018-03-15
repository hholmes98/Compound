<!-- views/main/default -->

<div class="page-header">
  <h1>Update Your Budget</h1>
  <h3>This is where you decimate your debt.</h3>
</div>

<p>
  Configure and customize your plan below. Click each tab to reveal the details you can personalize.
</p>

<br/>

<div class="panel panel-default form-horizontal">

  <ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="active"><a href="#card-manager" aria-controls="card-manager" role="tab" data-toggle="tab">Manage Your Credit Cards</a></li>
    <li role="presentation"><a href="#emergency" aria-controls="emergency" role="tab" data-toggle="tab">Select Emergency Card</a></li>
    <li role="presentation"><a href="#budget" aria-controls="budget" role="tab" data-toggle="tab">Set Budget</a></li>
    <li role="presentation"><a href="#paycheck_frequency" aria-controls="paycheck_frequency" role="tab" data-toggle="tab">Specify Paycheck Frequency</a></li>
  </ul>

  <div class="tab-content">

    <!-- tab 1 -->
    <div role="tabpanel" class="panel-body tab-pane active" id="card-manager">
      <table class="table table-striped table-bordered table-valign-middle">
        <thead>
        <tr>
          <th colspan="5">
            <h3>These are your cards. There are many like them. But these ones are yours.</h3>
            <p>
              Update your entire budget here. Change any card's name, balance, interest rate or minimum payment.
              Click 'Add a new card' to for more debt. Click 'Delete' to remove the entire card from your profile.
              While changing info, click 'Reset' if you need to start over.
            </p>
          </th>
        </tr>
        <tr>
          <th colspan="5"><button tooltip="Cards can also be loans!" type="button" class="btn button btn-default" ng-click="newCard(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>)"><span class="glyphicon glyphicon-plus"></span> Add a new card</button></th>
        </tr>
        <tr>
          <th class="col-md-4"><a href="javascript:void(0)" ng-click="orderByField='label';reverseSort = !reverseSort">Card <span ng-show="orderByField=='label'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
          <th class="col-md-2"><a href="javascript:void(0)" ng-click="orderByField='balance';reverseSort = !reverseSort">Balance <span ng-show="orderByField=='balance'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
          <th class="col-md-2"><a href="javascript:void(0)" ng-click="orderByField='interest_rate';reverseSort = !reverseSort">Interest Rate <span ng-show="orderByField=='interest_rate'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
          <th class="col-md-2"><a href="javascript:void(0)" ng-click="orderByField='min_payment';reverseSort = !reverseSort">Min. Payment <span ng-show="orderByField=='min_payment'"><span ng-show="!reverseSort"><i class="fas fa-angle-up"></i></span><span ng-show="reverseSort"><i class="fas fa-angle-down"></i></span></span></a></th>
          <th></th>
        </tr>
        </thead>
        <tbody>
        <tr class="align-top" ng-form name="myForm" ng-repeat="key in keylist | orderBy:'null':reverseSort:cardLabelCompare">
          <input type="hidden" ng-model="cards[key].id">
          <input type="hidden" ng-model="cards[key].is_emergency">
          <td>
            <input type="text" class="form-control" ng-model="cards[key].label">
          </td>
          <td>
            <div class="input-group">
              <span class="input-group-addon">$</span>
              <input type="text" class="form-control" ng-model="cards[key].balance" dollar-input>
            </div>
          </td>
          <td>
            <div class="input-group">
              <input type="text" class="form-control" ng-model="cards[key].interest_rate" interest-rate-input>
              <span class="input-group-addon">%</span>
            </div>
          </td>
          <td>
            <div class="input-group">
              <span class="input-group-addon">$</span>
              <input type="text" class="form-control" ng-model="cards[key].min_payment" dollar-input>
            </div>
          </td>
          <td>
            <button class="btn button btn-default" ng-class="{'btn-success': !myForm.$pristine }" ng-disabled="myForm.$pristine" ng-click="saveCard(key, cards[key]);myForm.$setPristine(true)" ><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
            <button class="btn button btn-default" ng-class="{'btn-warning': !myForm.$pristine }" ng-disabled="myForm.$pristine" ng-click="resetCard(key);myForm.$setPristine(true)" ><span class="glyphicon glyphicon-refresh"></span> Reset</button>
            <button class="btn button btn-default" ng-click="deleteCard(key);"><span class="glyphicon glyphicon-remove"></span> Delete</button>
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
            <p>Your emergency card is the one card that you'll lean on when you have an unexpected medical bill, car trouble, etc.
              <ol>
                <li>It must be usable anywhere (so don't pick a Gas card!)</li>
                <li>Casual shopping is not an emergency! (think: food, shelter, safety)</li>
              </ol>
            </p>
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
            <button class="btn button btn-default" ng-class="{'btn-success': !myForm2.$pristine }" ng-disabled="myForm2.$pristine" ng-click="setAsEmergency(cards[selected].card_id,<cfoutput>#session.auth.user.getUser_id()#</cfoutput>);myForm2.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Select This Card</button>
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
            <p>
              How much have you budgeted to pay off debt each month? Enter the dollar and cent value below.<br/>
              <br/>
              Make it count! The more, the better...but make sure <i>you continue to live within your means!</i>
            </p>
          </th>
        </tr>
        </thead>
        <tbody>
        <tr class="align-top" ng-form name="myForm3">
          <td>
            <div class="input-group">
              <div class="input-group-addon">I'll commit</div>
              <div class="input-group-addon">$</div>
              <input type="text" class="form-control" id="budget" ng-model="preferences.budget" />
              <div class="input-group-addon">a month to decimating my debt.</div>
            </div>
          </td>
          <td>
            <button class="btn button btn-default" ng-class="{'btn-success': !myForm3.$pristine }" ng-disabled="myForm3.$pristine" ng-click="setBudget(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>, preferences.budget);myForm3.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
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
            <p>
              In order to determine what you'll pay and when, the frequency of your income is key. It's not ok to pay off 
              debt <i>but also go hungry at the same time</i>. Based on what you tell us here, we'll calculate the smartest
              pay schedule that doesn't cripple your day-to-day life.
            </p>
          </th>
        </tr>
        </thead>
        <tbody>
        <tr class="align-top" ng-form name="myForm4">
          <td>
            <div class="input-group">
              <div class="input-group-addon">My income arrives:</div>
                <select style="background:#fff;" ng-model="preferences.pay_frequency" class="form-control" convert-to-number>
                  <option value="1">Once a month (12 paychecks per year)
                  <option value="2">Twice a month (24 paychecks per year)
                  <option value="3">Every two weeks (26 paychecks per year)
                  <option value="0">It's complicated (can't or don't want to say)
                </select>
              </div>
          </td>
          <td>
            <button class="btn button btn-default" ng-class="{'btn-success': !myForm4.$pristine }" ng-disabled="myForm4.$pristine" ng-click="setPayFrequency(<cfoutput>#session.auth.user.getUser_id()#</cfoutput>,preferences.pay_frequency);myForm4.$setPristine(true)"><span class="glyphicon glyphicon-ok"></span> Save Changes</button>
          </td>
        </tr>
        </tbody>
      </table>
    </div>

  </div><!-- /tab-content -->

</div><!-- /panel -->