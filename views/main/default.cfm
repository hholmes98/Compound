<!-- views/main/default -->
<cfsilent>
  <cfscript>
  /**
   * Returns the 2 character english text ordinal for numbers.
   * 
   * @param num      Number you wish to return the ordinal for. (Required)
   * @return Returns a string. 
   * @author Mark Andrachek (hallow@webmages.com) 
   * @version 1, November 5, 2003 
   */
  function GetOrdinal(num) {
    // if the right 2 digits are 11, 12, or 13, set num to them.
    // Otherwise we just want the digit in the one's place.
    var two=Right(num,2);
    var ordinal="";
    switch(two) {
         case "11": 
         case "12": 
         case "13": { num = two; break; }
         default: { num = Right(num,1); break; }
    }

    // 1st, 2nd, 3rd, everything else is "th"
    switch(num) {
         case "1": { ordinal = "st"; break; }
         case "2": { ordinal = "nd"; break; }
         case "3": { ordinal = "rd"; break; }
         default: { ordinal = "th"; break; }
    }

    // return the text.
    return ordinal;
  }
  </cfscript>

  <cfset get_started = 'home' />

  <cfset headArray = [
    'Keep ''em coming!',
    'Need more debt!',
    'You''re killing it! (and by "it" we mean "debt")',
    'Give us your cards!',
    'Somebody set you up the debt!'
  ] />

  <cfset messageArray = [
    'The average balance a person carries on a credit card is: $5,047. Let''s get that down to $0.',
    'Families with debt carry an average balance of: $15,654. It''s time to chip that away.',
    'People born between ''80-''84 carry approx. $5,689 more credit card debt than their parents, and $8,156 more than their grandparents.',
    'Credit card debt increased by nearly 8% in 2017. Let''s reverse that trend. Starting right now.',
    'But starting today, you''re paying it off. For great justice.'
  ] />
</cfsilent>

<div class="section fp-auto-height">

<form class="form-horizontal" name="entry" id="entry" method="post" action="<cfoutput>#buildUrl('main.calculate')#</cfoutput>">

<cfoutput>
<div id="page1" class="slide">

  <div class="container">

    <div class="col-md-12 main-login main-center" align="center">

      <div class="row">

        <div class="panel-heading">
          <div class="panel-title">
            <h1>#application.locale[session.auth.locale]['name']#</h1>
            <h3>The Credit Card Calculator</h3>
          </div>
        </div>
        <font style="font-size: 30px; font-weight: 700;">
          <div class="header">
            <span>Tell us your debt.</span> <span>We'll tell you the rest.</span>
          </div>
          <div>
            Every payment.
          </div>
          <div>
            Every date.
          </div>
          <div>
            Until you're free.
          </div>
        </font>

      </div>

      <div class="row" ng-show="!try">

        <div class="col-md-2"></div>
        <div class="col-md-8">

          <hr>

          <span>
            <button type="button" class="btn button btn-primary" ng-click="try=true" onClick="location.hash='##try/0'"><i class="fas fa-calculator"></i> Try it now!</button>
          </span>
        </div>
        <div class="col-md-2"></div>

      </div>

      <div class="row" ng-show="try">

        <div class="col-md-2"></div>
        <div class="col-md-8">

          <hr>

          <span class="help-block" id="budget-help-block"><strong>First:</strong> How much can you <b>afford</b>, each month, to apply towards <em>all</em> of your outstanding debt?</span>
          <div class="form-group form-group-lg">
            <label class="sr-only" for="budget">Monthly budget allocated to debt payoff (in dollars)</label>
            <div class="input-group">
              <div class="input-group-addon">$</div>
              <input class="form-control" type="text" id="budget" placeholder="(eg. 250.00)" name="budget" />
              <div class="input-group-addon"> per month.</div>
            </div>
          </div>
          <span>
            <button type="button" class="btn button btn-primary btn-more" ng-click="verifyBudget()"><span class="glyphicon glyphicon-circle-arrow-right"></span> Next: Enter Some Debt</button>
          </span>

        </div>
        <div class="col-md-2"></div>

      </div><!-- // row -->

      <div class="row top-buffer bottom-buffer">

        <div class="col-md-2"></div>
        <div class="col-md-8">
          <button type="button" class="btn button btn-link" ng-click="navigateTo('#buildUrl('login.default')#')"><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button>
        </div>
        <div class="col-md-2"></div>

      </div>

    </div><!-- // main-center -->

  </div><!-- // container -->

</div><!-- // page1 -->
</cfoutput>

<!-- the template for each card uses the 2nd page -->
<cfloop from="2" to="6" index="p">
<cfoutput>
<div id="page#p#" class="slide">

  <div class="container">

    <div class="card-content col-sm-12 main-login main-center" align="center">

      <div class="row">

        <div class="col-sm-2"></div>
        <div class="col-sm-8">

        <cfif p EQ 2>
          <h3>Debt.</h3>
        <cfelse>
          <h3>#headArray[p-1]#</h3>
        </cfif>

        <p>
        <cfif p EQ 2>
          A loan you owe the bank. A balance lingering on a credit card.<br/>
          We call them <font style="color:##D2691E;"><strong>cards</strong></font>, but it's all the same to the calculator.<br/>
          Just tell us how much you owe. We'll take it from here.
        <cfelse>
          <p>#messageArray[p-1]#</p>
        </cfif>
        </p>

        </div>
        <div class="col-sm-2"></div>

      </div>

      <div class="row">

        <div class="col-sm-2"></div>
        <div class="col-sm-8">

          <hr>

          <span class="help-block" id="credit-card-balance-help#Evaluate(p-1)#"><cfif p EQ 6><b>Last:</b><cfelse><b>Next:</b></cfif> Enter the remaining balance on one of your <font style="color:##D2691E;"><strong>cards</strong></font>.<br/><br/></span>
          <div class="form-group" align="left">
            <label for="credit-card-balance#Evaluate(p-1)#" class="col-sm-3 control-label">Balance:</label>
            <div class="col-sm-7">
              <div class="input-group">
                <span class="input-group-addon">$</span>
                <input class="form-control credit-card-balance" type="text" placeholder="(eg. 3,275.22)" name="credit-card-balance#Evaluate(p-1)#">
              </div>
            </div>
          </div>
          <input type="hidden" name="credit-card-label#Evaluate(p-1)#" value="The #Evaluate(p-1)##getOrdinal(Evaluate(p-1))# card">
          <!--- <div class="form-group" align="left">
            <label for="credit-card-label#Evaluate(p-1)#" class="col-sm-3 control-label">Give it a name:</label>
            <div class="col-sm-7">
              <input class="form-control credit-card-label" type="text" placeholder="(eg. WF checking atm card)" name="credit-card-label#Evaluate(p-1)#">
            </div>
          </div> --->
          <div class="form-group" align="left">
            <div class="col-sm-offset-3 col-sm-7">
              <cfif p LT 6>
                <button type="button" class="btn button btn-default btn-sm btn-more" ng-click="verifyCard(#Evaluate(p-1)#)"><span class="glyphicon glyphicon-plus"></span> Enter More Debt</button>
              </cfif>
            </div>
          </div>
          <br/>

        </div>
        <div class="col-sm-2"></div>

      </div><!-- // row -->

      <div class="row top-buffer bottom-buffer" align="center">

        <button type="button" class="btn button btn-primary btn-submit bottom-buffer" form="entry"><i class="fas fa-calculator"></i> Show Me The Plan</button>

      </div><!-- // row -->

    </div>

  </div>

</div>
</cfoutput>
</cfloop>

</form>

</div><!-- // section -->

<div class="about">

  <section dir="ltr" class="focus">
    <div class="section-inner">
      <div class="text">
        <h3>Keepin' it real (simple).</h3>
        <p>Financial applications love throwing the kitchen sink at you. You have one problem, we have one solution: <b>take your debt and calculate the fastest payoff</b>. That's
  all you need! Why complicate things?</p>
      </div>
      <span class="splash-icon focus-icon"></span>
    </div>
  </section>
  <section dir="ltr" class="security">
    <div class="section-inner">
      <span class="splash-icon security-icon"></span>
      <div class="text-other">
        <h3>We're on a need-to-know basis.</h3>
        <p>Other systems often require a connection to all of your banking institutions (and in some cases, those banks
  ask for additional fees...<em>just to connect!</em> ) With us, <b>no bank connections are required,</b> and <b>no credit card numbers stored</b>.
  Under the hood, it's just a list of balances...we don't ask for your personal financial information, and we don't believe
  you should have to fork it over.</p>
      </div>
    </div>
  </section>
  <section dir="ltr" class="fear">
    <div class="section-inner">
      <div class="text">
        <h3>Doing what's <strike>good for business</strike> right for you.</h3>
        <p>No machine learning. No AI. No blockchain. No bitcoin. No hooking up to your bank and charging you hidden fees.
  No smartphone GPS tracking your location. <b>We're a calculator that does the math for you...<em>and that's it.</em></b> There won't be any rise of the
  machines on our watch! We believe in ethical technology, so to those buzzwords we say...no thanks!</p>
      </div>
      <span class="splash-icon fear-icon"></span>
    </div>
  </section>
  <section dir="ltr" class="privacy">
    <div class="section-inner">
      <span class="splash-icon privacy-icon"></span>
      <div class="text-other">
        <h3>Your data is yours and nobody else's.</h3>
        <p>We value your freedom to choose a competitor. If you don't like us or find something better, we give you a
  single button to access all your data. That's it! It's yours!...<em>as it should be</em>. We'd be sorry to lose
  you, but <b>we care more about <em>your</em> success than our own.</b></p>
      </div>
    </div>
  </section>
  <section dir="ltr" class="support">
    <div class="section-inner">
      <div class="text">
        <h3>We're built by people like you.</h3>
        <p>Paying off debt <em>is hard</em>. It requires discipline over a long period of time. It's tough to ask for help.<br/><br/>We know.<br/><br/>
        No one should be excluded because of shame or a lack of funds. This is why <b>our base functionality is 100% free</b>, <b>support is one click away</b>, and we provide the means for
  <b>others to donate/gift subscriptions to our users</b>.</p>
      </div>
      <span class="splash-icon support-icon"></span>
    </div>
  </section>

  <cfoutput>#view('common/nav/footer')#</cfoutput>

</div>