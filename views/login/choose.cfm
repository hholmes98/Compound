<!-- views/login/choose -->
<!--- <div class="page-header">
  <h2 shadow-text="Choose a New Password">Choose a New Password</h2>
</div>

<div class="panel panel-default form-horizontal">
<cfoutput>

<cfform name="account" id="account" action="#buildURL('login.changeConfirm')#" method="post">
  
  
  <button class="btn button btn-default" form="account"><span class="glyphicon glyphicon-check"></span> Save Changes</button>
</cfform>

</cfoutput>
</div> --->


<div class="row">

  <div class="col-md-4 col-md-offset-4">

    <div class="panel-heading">
     <div class="panel-title">
        <h2 shadow-text="Choose a new password">Choose a new password</h2>
      </div>
    </div>

    <div class="main-login main-center">
      <cfform id="change" name="change" class="form-horizontal" method="POST" action="#buildUrl('login.changeConfirm')#">
        <cfoutput><input type="hidden" name="q" value="#rc.q#"></cfoutput>

        <div class="form-group">
          <label for="password" class="control-label">Enter the new password below:</label>
          <div>
            <div class="input-group">
              <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
              <cfinput id="password" type="password" class="form-control" name="new_password" placeholder="Enter a New Password" required="yes" message="Please enter a new password." />
            </div>
          </div>
        </div>

        <div class="form-group">
          <button class="btn button btn-primary btn-block" form="change"><span class="glyphicon glyphicon-check"></span> Save new password</button>
        </div>

      </cfform>

      <div class="form-group sub-main-center" align="center">
      </div>

    </div>

  </div>

  <div class="col-md-4"></div>

</div>