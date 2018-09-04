<!-- views/login/create.cfm -->
<cfsilent>
  <cfparam name="rc.marketingContent" default="" />
</cfsilent>
<div class="row">

  <cfif Len(rc.marketingContent)>
    <cfoutput>#rc.marketingContent#</cfoutput>
  </cfif>

  <div class="col-md-4<cfif !Len(rc.marketingContent)> col-md-offset-4</cfif>">

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

        <!-- paid account creation -->
        <cfif rc.account_type_id GT 1>

          <div class="form-group">
            <label for="email" class="control-label">Choose a plan:</label>
            <div>
              <select class="form-control" name="stripe_plan_id">
                <cfloop from="2" to="4" index="i">
                  <cfoutput><option value="#application.stripe_plans[i].id#"<cfif i == rc.account_type_id> selected</cfif>>#application.stripe_plans[i].nickname#</option></cfoutput>
                </cfloop>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label for="card-element" class="control-label">
              Enter your payment info:
            </label>
            <div id="card-element">
              <!-- A Stripe Element will be inserted here. -->
            </div>
            <!-- used to display element errors. -->
            <span id="card-errors" class="text-danger" role="alert"></span>
          </div>

        </cfif>

        <div class="form-group">
          <button class="btn button btn-primary btn-block" form="account"><span class="glyphicon glyphicon-circle-arrow-right"></span> Start Decimating Debt!</button>
        </div>

        <cfif rc.account_type_id GT 1>
          <div class="login-register" align="center">
            <small>Uh, where's the <strong><cfoutput><a href="#buildUrl('login.create')#">free version?</a></cfoutput></strong></small>
          </div>
        </cfif>

      </cfform>

      <div class="form-group sub-main-center" align="center">
        <cfoutput><button class="btn button btn-default btn-sm" onClick="location.href='#buildUrl('login.default')#';"></cfoutput><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button>
      </div>

    </div>

  </div>

  <div class="<cfif !Len(rc.marketingContent)>col-md-4<cfelse>col-md-2</cfif>"></div>

</div>

<cfif rc.account_type_id GT 1>
<script>
  // step1: set up stripe elements
  var stripe = Stripe('<cfoutput>#application.stripe_public_key#</cfoutput>');
  var elements = stripe.elements();
  var style = {
    base: {
      // add your base input styles here. eg.
      fontSize: '16px',
      color: "#32325d",
    }
  };

  // step2: create your payment form
  // create an instance of the card Element
  var card = elements.create('card', {style: style});

  // add an instance of the card Element into the 'card-element' div.
  card.mount('#card-element');

  // listen for the change event to alert user to errors
  card.addEventListener('change', function(event){
    var displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  // step3: create a token to securely transmit card info
  var form = document.getElementById('account');
  form.addEventListener('submit', function(event){
    event.preventDefault();

    stripe.createToken(card).then(function(result){
      if (result.error) {
        // inform the customer there was an error
        var errorElement = document.getElementById('card-errors');
        errorElement.textContent = result.error.message;
      } else {
        // send the token to the server
        stripeTokenHandler(result.token);
      }
    });
  });

  // step4: submit the token and the rest of the form to your server
  function stripeTokenHandler(token) {
    // insert the token id into the form so it gets submitted to the server
    var form = document.getElementById('paymentForm');
    var hiddenInput = document.createElement('input');
    hiddenInput.setAttribute('type','hidden');
    hiddenInput.setAttribute('name','stripeToken');
    hiddenInput.setAttribute('value', token.id);
    form.appendChild(hiddenInput);

    // submit the form
    form.submit();
  }
</script>
</cfif>