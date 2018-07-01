<!--- model/views/upgradeSub --->
<cfsilent>
  <cfif rc.upgrade == 'upgrade'>
    <cfset title = "Upgrade Subscription" />
  <cfelse>
    <cfset title = "Resubscribe" />
  </cfif>
</cfsilent>

<cfoutput><h2 shadow-text="#title#">#title#</h2></cfoutput>

<div class="form-row">&nbsp;</div>

<div class="row">
  <div class="col-xs-4">Card info</div>
  <div class="col-xs-8">
    <span>

      <!-- read-only -->
      <span ng-show="!editingCard">
        <cfif NOT StructIsEmpty(rc.card)>
          <i class="fas fa-credit-card"></i>
          <cfoutput>
            <strong>#rc.card.brand# #rc.asterisks##rc.card.last4#</strong>
            Expiration: <strong>#rc.card.exp_month#/#rc.card.exp_year#</strong>
          </cfoutput>
          <button class="btn button btn-default" ng-click="editingCard=true;"><span class="glyphicon glyphicon-credit-card"></span> Update payment method</button>
        <cfelse>
          (no payment specified)
          <button class="btn button btn-default" ng-click="editingCard=true;"><span class="glyphicon glyphicon-credit-card"></span> Add payment method</button>
        </cfif>
      </span>

      <!-- editing -->
      <span ng-show="editingCard">
        <form name="paymentInfoForm" stripe-form>
        <div>
          <span>
            <div id="card-element">
            <!-- A Stripe Element will be inserted here. -->
            </div>
            <button class="btn button btn-link" type="button" ng-click="editingCard=false;"> <i class="fas fa-times-circle"></i> Cancel</button>
            <button class="btn button btn-default" ng-click="submitCard()"> <i class="fas fa-check"></i> Save Payment Info</button>
          </span>
        </div>
        <div>
          <!-- used to display element errors. -->
          <span id="card-errors" class="text-danger" role="alert"></span>
        </div>
        </form>
      </span>

    </span>
  </div>
</div>

<form action="<cfoutput>#buildUrl('profile.paymentComplete')#</cfoutput>" method="POST" id="paymentForm">

  <cfif rc.upgrade == 'upgrade'>
    <div class="row">
      <label for="sub-selection">
        Plan choice
      </label>
    </div>
    <div id="plan-element">
      <select class="form-control" name="stripe_plan_id">
        <cfloop from="2" to="4" index="i">
          <cfoutput><option value="#application.stripe_plans[i].id#">#application.stripe_plans[i].nickname#</option></cfoutput>
        </cfloop>
      </select>
    </div>
  <cfelse>
    You are about to resubscribe to a paid plan: #plan#.
    <cfoutput><input type="hidden" name="stripe_plan_id" value="#rc.subscription.items.data[rc.subscription.items.total_count].plan.id#"></cfoutput>
  </cfif>

  <div class="row">&nbsp;</div>

  <div class="row pull-right">
    <div class="col-xs-3">
      <button type="button" class="btn button btn-link" onClick="history.back()"> Go back</button>
    </div>
    <div class="col-xs-3 col-xs-offset-1">
      <button class="btn button btn-default btn-success" form="paymentForm"><i class="fas fa-check"></i> Confirm Purchase</button>
    </div>
  </div>

</form>