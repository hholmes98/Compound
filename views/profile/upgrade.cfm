<!-- model/views/upgrade -->
<cfsilent>
  <cfif rc.upgrade == 'upgrade'>
    <cfset title = "Upgrade Subscription" />
  <cfelse>
    <cfset title = "Resubscribe" />
  </cfif>

  <!--- the plan_id prepopulation priority is as follows:
  1. if at_id is present(Len), it takes priority
  2. if rc.subscription.items is present, the current most plan it takes priority
  3. if neither 1 nor 2 are specified, the cheapest plan (2) is preselected --->
  <cfset selected_plan_id = 2 />
  <cfif StructKeyExists( rc.subscription, 'items' )>
    <cfset selected_plan_id = rc.subscription.items.data[rc.subscription.items.total_count].plan.id />
  </cfif>
  <cfif (Len(rc.at_id)) AND (IsNumeric(rc.at_id)) and (rc.at_id GT 1) AND (rc.at_id LTE ArrayLen(application.stripe_plans))>
    <cfset selected_plan_id = rc.at_id />
  </cfif>
</cfsilent>

<cfoutput><h2 shadow-text="#title#">#title#</h2></cfoutput>

<form class="form-inline" action="<cfoutput>#buildUrl('profile.paymentComplete')#</cfoutput>" method="POST" id="paymentForm">

<cfif StructKeyExists( rc.subscription, 'items' )>
  <div class="row top-buffer">
    <div class="col-xs-2"></div>
    <div class="col-xs-8" align="center">
      You are about to resubscribe to a paid plan: <strong><cfoutput>#rc.subscription.items.data[rc.subscription.items.total_count].plan.nickname#</cfoutput></strong>.
    </div>
    <div class="col-xs-2"></div>
  </div>
</cfif>

<div class="row bottom-buffer">
  <div class="col-xs-2"></div>
  <div class="col-xs-8" align="center">
    Confirm the information below, or you are free to change it.
  </div>
  <div class="col-xs-2"></div>
</div>

<div class="row bottom-buffer">
  <div class="col-xs-4">
    <label for="sub-selection">
      Plan choice
    </label>
  </div>
  <div class="col-md-offset-5 col-xs-3">
    <select class="form-control" name="stripe_plan_id">
      <cfloop from="2" to="4" index="i">
        <cfoutput><option value="#application.stripe_plans[i].id#"<cfif i EQ selected_plan_id> selected</cfif>>#application.stripe_plans[i].nickname#</option></cfoutput>
      </cfloop>
    </select>
    <cfoutput><a href="#buildUrl('main.pricing')#" tooltip="Ack! Show me the plans again!"><i class="far fa-question-circle"></i></a></cfoutput>
  </div>
</div>

<div class="row bottom-buffer">
  <div class="col-xs-4">Card info</div>
  <div class="col-md-offset-3 col-xs-5">

    <!-- read-only -->
    <span ng-show="!editingCard">
      <div id="payment" name="payment" ng-bind-html="paymentInfo">
        <!--- <cfif NOT StructIsEmpty(rc.card)>
          <i class="fas fa-credit-card"></i>
          <cfoutput>
          <strong>#rc.card.brand# #rc.asterisks##rc.card.last4#</strong>
          Expiration: <strong>#rc.card.exp_month#/#rc.card.exp_year#</strong>
          </cfoutput>
        <cfelse>
          (no payment specified)
        </cfif> --->
      </div>
    </span>

    <!-- editing -->
    <span ng-show="editingCard">
      <ng-form name="paymentInfoForm" stripe-form>

      <div>
        <span>
          <div id="card-element">
          <!-- A Stripe Element will be inserted here. -->
          </div>
          <button class="btn button btn-link" type="button" ng-click="editingCard=false;"> <i class="fas fa-times-circle"></i> Cancel</button>
          <button class="btn button btn-default" type="button" ng-click="submitCard()"> <i class="fas fa-check"></i> Save Payment Info</button>
        </span>
      </div>

      <div>
        <!-- used to display element errors. -->
        <span id="card-errors" class="text-danger" role="alert"></span>
      </div>

      </ng-form>
    </span>

  </div>
</div>

<div class="row bottom-buffer pull-right">
  <div class="col-xs-3">
    <span ng-show="!editingCard">
    <cfif NOT StructIsEmpty(rc.card)>
      <button class="btn button btn-default" type="button" ng-click="editingCard=true;"><span class="glyphicon glyphicon-credit-card"></span> Update payment method</button>
    <cfelse>
      <button class="btn button btn-default" type="button" ng-click="editingCard=true;"><span class="glyphicon glyphicon-credit-card"></span> Add payment method</button>
    </cfif>
    </span>
  </div>
</div>

<div class="row bottom-buffer">&nbsp;</div>

<div class="row bottom-buffer">&nbsp;</div>

<div class="row bottom-buffer">
  <div class="col-xs-4"></div>
  <div class="col-xs-4">
    <button type="button" class="btn button btn-link" onClick="history.back()"> Go back</button>
    &nbsp;
    <!-- fixme: when submitted, set to disabled -->
    <button class="btn button btn-default btn-success" ng-disabled="paymentInfo=='(no payment specified)';" onClick="this.form.submit();this.disabled=true;this.value='Processing...';this.innerHTML='Processing...';" form="paymentForm"><i class="fas fa-check"></i> Confirm Purchase</button>
  </div>
  <div class="col-xs-4"></div>
</div>

</form>