<!-- views/profile/basic -->
<h2 shadow-text="User Settings">User Settings</h2>
<div role="form">
  <cfoutput>
  <span>
    <button class="btn button btn-default" onClick="location.href='#buildUrl('profile.advanced')#';"><span class="glyphicon glyphicon-credit-card"></span> Account Information</button>
    <button class="btn button btn-default pull-right" onClick="location.href='#buildUrl('login.logout')#';"> Logout</button>
  </span>
  </cfoutput>
</div>

<!-- Account Settings -->
<div class="strike">
  <span><h3>Account Type</h3></span>
</div>

<p>
  Type of Account: <cfoutput><strong>#session.auth.user.getAccount_Type().getName()#</strong></cfoutput> 

  <cfif session.auth.user.getAccount_Type_Id() EQ 1>
  <input type="button" value="Upgrade to Paid" />
  <p>
    <input type="text" name="coupon" hint="Enter coupon code" /><input type="button" value="Redeem Coupon Code" />
  </p>
  </cfif>
</p>

<!-- Disable Ads -->
<div class="strike">
  <span><h3>Advertisements</h3></span>
</div>

<div>
  <p>
    Ads are: <strong><cfif session.auth.user.getAccount_Type().getAccount_Type_Id() GT 1>Disabled<cfelse>Enabled</cfif></strong> 
  </p>

  <cfif session.auth.user.getAccount_Type().getAccount_Type_Id() EQ 1>
  <input type="button" value="Upgrade to Paid to Disable Ads!" />
  <p>
    <input type="text" name="coupon" hint="Enter coupon code" /><input type="button" value="Redeem Coupon Code" />
  </p>
  </cfif>
</div>

<!-- Email Settings -->
<div class="strike">
  <span><h3>Email Alerts</h3></span>
</div>

<div>
  <p>Email Alerts are:</p>

  <toggle id="email_reminders" name="email_reminders" ng-model="preferences.email_reminders" ng-change="savePreferences(preferences)">
</div>

<!-- Security Settings -->
<div class="strike">
  <span><h3>Security</h3></span>
</div>

<p>
  <cfoutput>
  <cfform name="account" id="account" action="#buildURL('login.updateConfirm')#" method="post">
    <div class="input-group">
      <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
      <cfinput id="password" type="password" class="form-control" name="new_password" placeholder="Enter a new password" required="yes" message="Please enter a new password." />
    </div>
    <button class="btn button btn-default" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Update Password</button>
  </cfform>
  </cfoutput>
</p>

<!-- Card Due Dates -->
<div class="strike">
  <span><h3>Card Due Dates</h3></span>
</div>

<p>
  Specify the due date of every card. Providing this info will <b>customize your email reminders</b> and generate an <b>improved pay schedule</b> for each month.
</p>

(NYI)

<!-- Reminders -->
<div class="strike">
  <span><h3>Reminders</h3></span>
</div>

<p>
Remind me to pay my bills: <select class="form-control" name="email_frequency" ng-model="preferences.email_frequency" ng-change="savePreferences(preferences);" convert-to-number>
  <option value="0">Never! (No Notifications)</option>
  <option value="1">Once a month (Light Notification)</option><!-- this is the default -->
  <option value="2">Matching my payment schedule (Medium Notification)</option><!-- don't show this option if "its complicated" -->
  <option value="3">On each card's due date (Heavy Notification)</option><!-- gray this option until the user fills out due dates -->
</select>
</p>

(NYI)

<!-- Privacy -->
<div class="strike">
  <span><h3>Privacy</h3></span>
</div>

<p>
  <input type="button" class="btn button btn-default" value="Export Your Data">
</p>

(NYI)