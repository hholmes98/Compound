<!-- views/login/reset -->
<div class="row">

  <div class="col-md-4 col-md-offset-4">

    <div class="panel-heading">
     <div class="panel-title">
        <h2 shadow-text="Password Reset">Password Reset</h2>
      </div>
    </div>

    <div class="main-login main-center">
      <cfform id="account" name="account" class="form-horizontal" method="POST" action="#buildUrl('login.resetConfirm')#">

        <div class="form-group">
          <label for="email" class="control-label">E-mail address:</label>
          <div>
            <div class="input-group">
              <span class="input-group-addon"><i class="fa fa-envelope fa" aria-hidden="true"></i></span>
              <cfinput type="text" class="form-control" name="email" id="email" placeholder="eg. richierich@themanor.com" required="true" message="We'll need your e-mail address below in order to reset your password." />
            </div>
          </div>
        </div>

        <div class="form-group">
          <button class="btn button btn-primary btn-block" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Request a Password Reset</button>
        </div>

      </cfform>

      <div class="form-group sub-main-center" align="center">
      </div>

    </div>

  </div>

  <div class="col-md-4"></div>

</div>