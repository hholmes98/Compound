<!-- views/login/default -->

<!--- old
<div class="page-header">
  <h1>Login</h1>
</div>

<div class="panel panel-default form-horizontal">
<cfoutput>

<cfform name="login" id="login" action="#buildURL('login.login')#" method="post">
  <div class="input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
    <cfinput id="email" type="text" class="form-control" name="email" placeholder="Email Address" required="yes" message="Please enter your email address" />
  </div>

  <div class="input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
    <cfinput id="password" type="password" class="form-control" name="password" placeholder="Password" required="yes" message="Please enter your password" />
  </div>

  <button class="btn button btn-default" form="login"><span class="glyphicon glyphicon-log-in"></span> Login</button>
</cfform>

<button class="btn button btn-default" onClick="location.href='#buildUrl('login.create')#';"><span class="glyphicon glyphicon-exclamation-sign"></span> I don't have an account yet</button><br/>
<button class="btn button btn-default" onClick="location.href='#buildUrl('login.passwordReset')#';"><span class="glyphicon glyphicon-question-sign"></span> I forgot my password</button>

</cfoutput>
</div>
--->

<div class="row">

  <div class="col-md-4"></div>

  <div class="col-md-4">

        <div class="panel-heading">
         <div class="panel-title">
            <h2 shadow-text="Sign In">Sign In</h2>
          </div>
        </div>

        <div class="main-login main-center">
          <cfform id="login" name="login" class="form-horizontal" method="POST" action="#buildUrl('login.login')#">

            <div class="form-group">
              <label for="email" class="control-label">Email Address</label>
              <div>
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-envelope fa" aria-hidden="true"></i></span>
                  <cfinput type="text" class="form-control" name="email" id="email" placeholder="Enter your Email Address" required="true" />
                </div>
              </div>
            </div>

            <div class="form-group">
              <label for="password" class="control-label">Password</label>
              <div>
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-lock fa-lg" aria-hidden="true"></i></span>
                  <cfinput type="password" class="form-control" name="password" id="password"  placeholder="Enter your Password" required="true" />
                </div>
              </div>
            </div>

            <div class="form-group">
              <button class="btn button btn-primary btn-block" form="login"><span class="glyphicon glyphicon-log-in"></span> Sign In</button>
            </div>

            <div class="login-register">
              <small>Don't have an account? <strong><cfoutput><a href="#buildUrl('login.create')#">Create one</a></cfoutput></strong></small>
            </div>

            <div class="form-group sub-main-center" align="center">
              <cfoutput><button class="btn button btn-default btn-sm" onClick="location.href='#buildUrl('login.passwordReset')#';"></cfoutput><span class="glyphicon glyphicon-question-sign"></span> I forgot my password</button>
            </div>

          </cfform>
        </div>

<!---
  <cfform class="form-horizontal" name="login" id="login" action="#buildUrl('login.login')#" method="POST">

    <h2 shadow-text="Sign In">Sign In</h2>

    <div>&nbsp;</div>
    <div class="form-group">
    <div class="input-group">
      <label for="email" class="sr-only">Email Address</label>
      <cfinput name="email" type="text" id="email" class="form-control margin-bottom" placeholder="Email Address" required="true" autofocus message="Please enter your email address" />
      <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
    </div>

    <div>&nbsp;</div>
    <div class="input-group">
      <label for="inputPassword" class="sr-only">Password</label>
      <cfinput type="password" id="password" class="form-control margin-bottom" name="password" placeholder="Password" required="true" message="Please enter your password" />
      <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
    </div>

    <div>&nbsp;</div>
    <button class="btn button btn-primary btn-block" form="login"><span class="glyphicon glyphicon-log-in"></span> Sign In</button>
  </cfform>


  <div>&nbsp;</div>
  <div align="center">
    <small>Don't have an account? <strong><cfoutput><a href="#buildUrl('login.create')#">Create one</a></cfoutput></strong></small>
  </div>

  <div>&nbsp;</div>
  <div align="center">
    <cfoutput><button class="btn button btn-default btn-sm" onClick="location.href='#buildUrl('login.passwordReset')#';"></cfoutput><span class="glyphicon glyphicon-question-sign"></span> I forgot my password</button>
  </div>

--->
  </div>

  <div class="col-md-4"></div>

</div>