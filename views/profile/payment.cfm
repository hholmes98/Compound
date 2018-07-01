<!-- views/profile/payment -->
<h2 shadow-text="Payment Details">Payment Details</h2>

<div class="form-row">&nbsp;</div>

<form action="<cfoutput>#buildUrl('profile.paymentComplete')#</cfoutput>" method="POST" id="paymentForm">

  <div class="row">
    <label for="card-element">
      Credit or debit card
    </label>
    <div id="card-element">
      <!-- A Stripe Element will be inserted here. -->
    </div>
    <!-- used to display element errors. -->
    <span id="card-errors" class="text-danger" role="alert"></span>
    <!--- <span class="glyphicon glyphicon-credit-card"></span> 3*** ***** *2003 - <a href="#buildUrl('profile.card')#">Enter a new card</a> --->
  </div>

  <div class="row">&nbsp;</div>

  <div class="row">
    <label for="sub-selection">
      Plan choice
    </label>
  </div>
  <div id="plan-element">
    <select class="form-control" name="stripe_plan_id">
      <cfloop from="2" to="4" index="i">
        <cfoutput><option value="#application.stripe_plans[i].id#">#application.stripe_plans[i].nickname#</option></cfoutput>
      </cfloop>
    </select>
  </div>

  <div class="row">&nbsp;</div>

  <div class="row pull-right">
    <div class="col-xs-3">
      <button type="button" class="btn button btn-link" onClick="history.back()"> Go back</button>
    </div>
    <div class="col-xs-3 col-xs-offset-1">
      <button class="btn button btn-default btn-success" form="paymentForm"><i class="fas fa-check"></i> Confirm Purchase</button>
    </div>
  </div>

</form>

<!--- <div>
  <h5><small>Your next charge of x$ will process on #Month# 24, #Year#, for another month of service.</small></h5>
</div> --->

<!-- https://stripe.com/docs/stripe-js/elements/quickstart#setup -->
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
  var form = document.getElementById('paymentForm');
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