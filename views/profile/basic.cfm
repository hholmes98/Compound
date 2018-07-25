<cfparam name="COOKIE['dd-skin']" default="1" />

<!-- views/profile/basic -->
<h2 shadow-text="User Settings">User Settings</h2>

<!-- Preferences -->
<div class="strike">
  <span><h3>Preferences</h3></span>
</div>

<div class="row">
  <div class="col-xs-6">Theme</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <select class="form-control" name="skin" ng-model="skin" ng-change="updateSkin(skin)">
        <cfloop from="1" to="#ArrayLen(application.skins)#" index="s">
          <cfoutput><option value="#s#"<cfif COOKIE['dd-skin'] is s> selected</cfif>>#application.skins[s].name#</option></cfoutput>
        </cfloop>
      </select>
    </span>
  </div>
</div>

<div class="row">
  <div class="col-xs-6">Advertisements</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <strong><cfif session.auth.user.getAccount_Type().getAccount_Type_Id() GT 1>Disabled<cfelse>Enabled</cfif></strong>
    </span>
  </div>
</div>

<cfif session.auth.user.getAccount_Type_Id() EQ 1>
  <!-- Upgrade to Paid -->
  <div class="row">
    <div class="col-xs-6"></div>
    <div class="col-xs-6">
      <span class="pull-right">
        <input type="button" class="btn button btn-default btn-primary col-xs-12" value="Upgrade to paid" tooltip="Paid accounts disable advertisements!" />
      </span>
    </div>
  </div>

  <!-- Coupon Codes -->
  <div class="strike">
    <span><h3>Coupon Codes</h3></span>
  </div>

  <cfform name="couponForm" id="couponForm" action="#buildURL('profile.coupon')#" method="post">
  <div class="row">
    <div class="col-xs-12">
      <div class="input-group">
        <span class="input-group-addon"><i class="glyphicon glyphicon-tag"></i></span>
        <cfinput id="coupon" type="text" class="form-control" name="coupon" placeholder="Enter a coupon code (NYI)" />
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-xs-12">
      <button class="btn button btn-default col-xs-12" form="disableMeForNowForm"><span class="glyphicon glyphicon-check"></span> Redeem Coupon (NYI)</button>
    </div>
  </div>
  </cfform>

</cfif>

<!-- E-mail -->
<div class="strike">
  <span><h3>E-mail</h3></span>
</div>

<div class="row">
  <div class="col-xs-6">Notifications</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <toggle class="pull-right" id="email_reminders" name="email_reminders" ng-model="preferences.email_reminders" ng-change="savePreferences(preferences)">
    </span>
  </div>
</div>

<div class="row">
&nbsp;
</div>

<div class="row">
  <div class="col-xs-6">Bill reminder frequency</div>
  <div class="col-xs-6">
    <span class="pull-right">
      <select<cfif session.auth.user.getAccount_Type_Id() LT 2> disabled tooltip="Upgrade to customize when you receive reminders!"</cfif> class="form-control" name="email_frequency" ng-model="preferences.email_frequency" ng-change="savePreferences(preferences);" convert-to-number>
        <option value="0">None</option>
        <option value="1"<cfif session.auth.user.getAccount_Type_Id() LT 2> selected</cfif>>1 a month</option><!-- this is the default -->
        <cfif session.auth.user.getPreferences().getPay_Frequency() GT 0><option value="2">On pay schedule</option><!-- don't show this option if "its complicated" --></cfif>
        <cfif session.auth.user.getAccount_Type_Id() EQ 4><option value="3">Card due dates</option><!-- gray this option until the user fills out due dates --></cfif>
      </select>
    </span>
  </div>
</div>

<!-- Security -->
<div class="strike">
  <span><h3>Security</h3></span>
</div>

<cfform name="account" id="account" action="#buildURL('login.updateConfirm')#" method="post">
<div class="row">
  <div class="col-xs-12">
    <div class="input-group">
      <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
      <cfinput id="password" type="password" class="form-control" name="new_password" placeholder="Enter a new password" required="yes" message="Please enter a new password." />
    </div>
  </div>
</div>
<div class="row">
  <div class="col-xs-12">
    <button class="btn button btn-default col-xs-12" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Update password</button>
  </div>
</div>
</cfform>

<!-- Privacy -->
<div class="strike">
  <span><h3>Privacy</h3></span>
</div>

<div class="row">
  <div class="col-xs-12">
    <cfoutput><button class="btn button btn-default col-xs-12" onClick="location.href='#buildUrl('preferences.export')#';"><i class="fas fa-cloud-download-alt"></i> Export your data</button></cfoutput>
  </div>
</div>
