<!-- views/login/create.cfm -->
<div class="row">

  <div class="col-md-4 col-md-offset-4">

    <div class="panel-heading">
     <div class="panel-title">
        <h2 shadow-text="Create an Account">Create an Account</h2>
      </div>
    </div>

    <div class="main-login main-center">
      <cfform id="account" name="account" class="form-horizontal" method="POST" action="#buildUrl('login.new')#">

        <div class="form-group">
          <label for="name" class="control-label">Enter a nickname:</label>
          <div>
            <div class="input-group">
              <span class="input-group-addon"><i class="fas fa-user" aria-hidden="true"></i></span>
              <cfinput type="text" class="form-control" name="name" id="name" placeholder="eg. WarrenBuffet1930" required="true" message="You forgot to give yourself a nickname! (We suggest 'RichMoneyPennybags')" />
            </div>
          </div>
        </div>

        <div class="form-group">
          <label for="email" class="control-label">Enter your e-mail address:</label>
          <div>
            <div class="input-group">
              <span class="input-group-addon"><i class="fa fa-envelope fa" aria-hidden="true"></i></span>
              <cfinput type="text" class="form-control" name="email" id="email" placeholder="eg. omaha-dude@berkhathaway.com" required="true" message="Don't forget your e-mail address! (We'll help with your e-mail settings inside)" />
            </div>
          </div>
        </div>

        <div class="form-group">
          <button class="btn button btn-primary btn-block" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Start Decimating Debt!</button>
        </div>

      </cfform>

      <div class="form-group sub-main-center" align="center">
        <cfoutput><button class="btn button btn-default btn-sm" onClick="location.href='#buildUrl('login.default')#';"></cfoutput><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button>
      </div>

    </div>

  </div>

  <div class="col-md-4"></div>

</div>