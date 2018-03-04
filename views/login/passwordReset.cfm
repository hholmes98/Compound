<!-- views/login/passwordReset -->
<div class="page-header">
  <h1>Password Reset</h1>
</div>

<div class="panel panel-default form-horizontal">
<cfoutput>

<cfform name="account" id="account" action="#buildURL('login.resetConfirm')#" method="post">
  <div class="input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
    <cfinput id="email" type="text" class="form-control" name="email" placeholder="Enter Your Email Address" required="yes" message="Please enter your email address" />
  </div>

  <button class="btn button btn-default" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Request Reset</button>
</cfform>

</cfoutput>
</div>