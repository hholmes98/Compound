<!-- views/login/default -->
<div class="top-screen-buffer">

<div class="row">

  <div class="col-md-4 col-md-offset-4">

    <div class="panel-heading">
     <div class="panel-title">
        <h2 shadow-text="Sign In">Sign In</h2>
      </div>
    </div>

    <div class="main-login main-center">
      <cfform id="login" name="login" class="form-horizontal" method="POST" action="#buildUrl('login.login')#">

        <div class="form-group">
          <label for="email" class="control-label">E-mail address:</label>
          <div>
            <div class="input-group">
              <span class="input-group-addon"><i class="fa fa-envelope fa" aria-hidden="true"></i></span>
              <cfinput type="text" class="form-control" name="email" id="email" placeholder="Enter your e-mail address" required="true" message="You forgot your e-mail address!" />
            </div>
          </div>
        </div>

        <div class="form-group">
          <label for="password" class="control-label">Password:</label>
          <div>
            <div class="input-group">
              <span class="input-group-addon"><i class="fa fa-lock fa-lg" aria-hidden="true"></i></span>
              <cfinput type="password" class="form-control" name="password" id="password" placeholder="Enter your password" required="true" message="You forgot to enter your password!" />
            </div>
          </div>
        </div>

        <div class="form-group">
          <button class="btn button btn-primary btn-block" form="login"><span class="glyphicon glyphicon-log-in"></span> Sign In</button>
        </div>

        <div class="login-register">
          <small>Don't have an account? <strong><cfoutput><a href="#buildUrl('login.create')#">Create one</a></cfoutput></strong></small>
        </div>

      </cfform>

      <div class="form-group sub-main-center" align="center">
        <cfoutput><button class="btn button btn-default btn-sm" onClick="location.href='#buildUrl('login.reset')#';"></cfoutput><span class="glyphicon glyphicon-question-sign"></span> I forgot my password</button>
      </div>

    </div>

  </div>

  <div class="col-md-4"></div>

</div>

</div>