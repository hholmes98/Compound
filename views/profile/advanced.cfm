<cfsilent>
  <cfscript>
  function isCanceled( struct o ) {
    
    if ( StructKeyExists( arguments.o.subscription, 'status' ) ) {

      if (o.subscription.status == 'canceled' || o.subscription.status == 'past_due' || (o.subscription.cancel_at_period_end)) {
        return true;
      } else {
        return false;
      }

    } else {

      // this should never happen
      Throw( message="Missing Stripe Data", detail="The currently logged-in user (#session.auth.user.getUser_Id()#) is set as a paid account, but is missing their stripe_subscription_id information in the user bean." );

    }
  }
  </cfscript>
</cfsilent>

<!-- views/profile/advanced -->
<h2 shadow-text="Account Information">Account Information</h2>

<!-- User Information -->
<div class="strike">
  <span><h3>User Information</h3></span>
</div>

<div class="row">
  <div class="col-xs-6">Username</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <strong><cfoutput>#session.auth.user.getName()#</cfoutput></strong>
    </span>
  </div>
</div>

<div class="row">
  <div class="col-xs-6">E-mail address</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <strong><cfoutput>#session.auth.user.getEmail()#</cfoutput></strong>
    </span>
  </div>
</div>

<!-- Account Status -->
<div class="strike">
  <span><h3>Account Status</h3></span>
</div>

<div class="row">
  <div class="col-xs-6">Account type</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <cfoutput>
        <cfif session.auth.user.getAccount_Type_Id() == 1>
          <strong>Free</strong> <button class="btn button btn-default" onClick="location.href='#buildUrl('profile.upgrade')#';"> <i class="fas fa-shopping-cart" tooltip="Paid accounts disable advertisements!"></i> Upgrade to paid</button>
        <cfelse>
          <strong>Paid</strong> 
          <cfif Len(rc.subscription)>
            <cfif !isCanceled( rc )>
              <button class="btn button btn-link" ng-click="cancelConfirm('#buildUrl('profile.cancelSub')#')"> <i class="fas fa-times-circle"></i> Cancel subscription</button>
            </cfif>
          </cfif>
        </cfif>
      </cfoutput>
    </span>
  </div>
</div>

<div class="row">
  <div class="col-xs-6">Plan</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <strong>
        <cfif session.auth.user.getAccount_Type_Id() == 1>
          <cfoutput><a href="#buildUrl('main.pricing')#">Penny-Pincher</a></cfoutput>
        <cfelse>
          <cfoutput>#application.stripe_plans[session.auth.user.getAccount_Type_Id()]["nickname"]#</cfoutput>
        </cfif>
      </strong>
    </span>
  </div>
</div>

<div class="row">
  <div class="col-xs-6">Payment status</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <strong>
      <cfif session.auth.user.getAccount_Type_Id() == 1>
        ~
      <cfelse>
        <cfif Len(rc.subscription)>
          <cfoutput>#rc.payment_status#</cfoutput>
          <cfif isCanceled( rc )>
            <cfoutput><button class="btn button btn-default" onClick="location.href='#buildUrl('profile.resubscribe')#';"> <i class="fas fa-shopping-cart"></i> Resubscribe</button></cfoutput>
          </cfif>
        <cfelse>
          Lifetime Sub
        </cfif>
      </cfif>
      </strong>
    </span>
  </div>
</div>

<div class="row">
  <div class="col-xs-6">Paid features expire on</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <cfif session.auth.user.getAccount_Type_Id() == 1>
        ~
      <cfelse>
        <cfif Len(rc.subscription)>
          <cfif isCanceled( rc )>
            <cfoutput>
              <font color="red"><strong>#DateFormat(rc.subscription.current_period_end,"mm/dd/yyyy")#</strong></font>
            </cfoutput>
          <cfelse>
            ~
          </cfif>
        <cfelse>
          <strong>Never</strong>
        </cfif>
      </cfif>
    </span>
  </div>
</div>

<!--- if no card info is present, and the user is on a free account, just hide the entire billing interface - showing it
just confuses users --->
<cfif !(StructIsEmpty(rc.card) AND session.auth.user.getAccount_Type_Id() == 1)>

<!-- Billing -->
  <div class="strike">
    <span><h3>Billing Information</h3></span>
  </div>

  <form id="profileForm">

  <div class="row">
    <div class="col-xs-4">Card info</div>
    <div class="col-xs-8">

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

  </form>

</cfif>

      <!---<tr>
        <td>Coupon</td>
        <td>You don't have an active coupon.</td>
        <td><cfoutput><button class="btn button btn-default" onClick="location.href='#buildUrl('profile.coupon')#';"><span class="glyphicon glyphicon-gift"></span> Redeem a coupon</button></cfoutput></td>
      </tr>
      --->
      <!---
      <tr>
        <td>Extra Info (?)</td>
        <td>You have not added any additional information to your receipts.</td>
        <td><button class="btn button btn-default"><span class="glyphicon glyphicon-plus"></span> Add Information</button></td>
      </tr>
      --->

<!--- if no card info is present, and the user is on a free account, just hide the entire payment history inteface - showing it
just confuses users --->
<cfif !(StructIsEmpty(rc.card) AND session.auth.user.getAccount_Type_Id() == 1)>

  <!-- Payment History -->
  <div class="strike">
    <span><h3>Payment History</h3></span>
  </div>

  <cfif ArrayLen(rc.invoices)>
  <div class="table"> 
    <table class="table table-striped">
      <thead>
        <tr>
          <th>&nbsp;</th>
          <th>ID</th>
          <th>Date</th>
          <th>Payment Method</th>
          <th>Amount</th>
          <th>Receipt</th>
        </tr>
      </thead>
      <cfloop array="#rc.invoices#" item="invoice">
      <tbody>
        <cfoutput>
        <tr>
          <td><span class="glyphicon glyphicon-ok"></span></td>
          <td>#invoice.number#</td>
          <td>#DateFormat(invoice.date, "yyyy-mm-dd")#</td>
          <td><i class="fas fa-credit-card"></i> #rc.card.brand# ending in #rc.card.last4#</td>
          <td>$#Evaluate(invoice.total/100)#</td>
          <td><a href="#invoice.invoice_pdf#"><span class="glyphicon glyphicon-floppy-save"></span></a></td>
        </tr>
        </cfoutput>

        <!--- <tr class="warning text-muted">
          <td><span class="glyphicon glyphicon-remove"></span></td>
          <td>67118Z70</td>
          <td>2017-10-24</td>
          <td><span class="glyphicon glyphicon-credit-card"></span> American Express ending in 2003</td>
          <td>$1.99</td>
          <td>&nbsp;</td>
        </tr> --->
      </tbody>
      </cfloop>
    </table>
  </div>
  <cfelse>
    No history yet! (Your receipts will show here)
  </cfif>

</cfif>
