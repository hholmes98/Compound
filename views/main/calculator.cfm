<!--- views/main/calculator --->
<cfsilent>

  <cfparam name="rc.mktgTitle" default="#rc.debtLabel# Payoff Calculator" />
  <cfparam name="rc.mktgBody" default="" />

  <cfswitch expression="#rc.debtLabel#">
    <cfcase value="Loan">
      <cfset rc.anotherCalcURL = "main.calculator" />
    </cfcase>
    <cfcase value="Debt">
      <cfset rc.anotherCalcURL = "debt.calculator" />
    </cfcase>
    <cfdefaultcase>
      <cfset rc.anotherCalcURL = "main.calculator" />
    </cfdefaultcase>
  </cfswitch>

  <cfscript>
  function capitalize( string word ) {
    var tmp = LCase(arguments.word);
    return UCase(Left(tmp,1)) & Mid(tmp,2,Len(tmp)-1);
  }
  </cfscript>
</cfsilent>

<div class="container">

<div class="row">
  <div class="col-md-12">
    <cfoutput>
    <h2 shadow-text="#rc.mktgTitle#">#rc.mktgTitle#</h2>
    <cfif Len(rc.mktgBody)><p>#rc.mktgBody#</p></cfif>
    <br/>
    <p>Enter your balance, interest rate, and monthly budget in the form below.<cfif !Len(rc.mktgBody)><br/><br/><cfelse> </cfif>Then, click 'Calculate', and we'll tell you how much your monthly payment will be, and the exact date you'll be debt free.</p>
    </cfoutput>
  </div>
</div>

<div class="row">

  <cfform class="form-horizontal" name="calculator" id="calculator" method="post" action="#buildUrl('main.calculate')#">
  <cfoutput>
    <input type="hidden" name="credit-card-label1" value="The first #LCase(rc.debtLabel)#" />
    <input type="hidden" name="anotherCalcURL" value="#buildUrl(rc.anotherCalcURL)#" />
  </cfoutput>

  <div class="col-md-4 main-login main-center">

    <div class="form-group">
      <label for="name" class="control-label"><cfoutput>#capitalize(rc.debtLabel)#</cfoutput> balance:</label>
      <div class="input-group">
        <span class="input-group-addon">$</span>
        <cfinput type="text" class="form-control" name="credit-card-balance1" id="credit-card-balance1" required="true" message="You must specify your #LCase(rc.debtLabel)#'s balance, which must be a number (dollars and cents)" validate="float" />
      </div>
    </div>

    <div class="form-group">
      <label for="name" class="control-label"><cfoutput>#capitalize(rc.debtLabel)#</cfoutput> interest rate:</label>
      <div class="input-group">
        <cfinput type="text" class="form-control" name="credit-card-interest-rate1" id="credit-card-interest-rate1" required="true" message="You must specify your #LCase(rc.debtLabel)#'s interest rate, which must be a decimal (eg. 23.99)" value="23.99" validate="float" />
        <span class="input-group-addon">%</span>
      </div>
    </div>

    <div class="form-group">
      <label for="name" class="control-label">Monthly budget:</label>
      <div class="input-group">
        <span class="input-group-addon">$</span>
        <cfinput type="text" class="form-control" name="budget" id="budget" required="true" message="You must specify your monthly budget, which must be a number (dollars and cents)" validate="float" />
      </div>
    </div>

    <div class="form-group">
      <button class="btn button btn-primary btn-block" form="calculator">Calculate</button>
    </div>

    <div>&nbsp;</div>

  </div>
  </cfform>

</div>

<br/>
<br/>

</div>


