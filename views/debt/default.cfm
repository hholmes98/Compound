<!-- views/debt/default -->
<form class="form-horizontal" name="entry" id="entry" method="post" action="<cfoutput>#buildUrl('debt.calculate')#</cfoutput>">

<div id="page1" class="pan-page pan-page-1">

  <div class="container">

    <cfoutput>

    <div class="col-md-12" align="center">

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
          <button type="button" class="btn button btn-primary btn-more" ng-click="buildAndPan(1)"><span class="glyphicon glyphicon-circle-arrow-right"></span> Next: Enter Some Debt</button>
        </span>
        <span>
          <br/>
          <br/>
          <br/>
          <button type="button" class="btn button btn-default btn-sm btn-login" ng-click="navigateTo('#buildUrl('login.default')#')"><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button>
        </span>

      </div>
      <div class="col-md-2"></div>

    </div>

    </cfoutput>

  </div>

</div>

<!-- the template for each card uses the 2nd page -->
<div id="page2" class="pan-page page-page-2">

  <div class="container">

    <cfoutput>

    <div class="card-content col-sm-12" align="center">

      <h3>Debt.</h3>

      <p>
        A loan you owe the bank. A balance lingering on a credit card.<br/>
        We call them <font style="color:##D2691E;"><strong>cards</strong></font>, but it's all the same to the calculator.<br/>
        Just tell us how much you owe. We'll take it from here.
      </p>

      <div class="col-sm-2"></div>
      <div class="col-sm-8">

        <hr>

        <span class="help-block" id="credit-card-balance-help1"><b>Next:</b> Enter the remaining balance on one of your <font style="color:##D2691E;"><strong>cards</strong></font>.<br/><br/></span>
        <div class="form-group" align="left">
          <label for="credit-card-balance1" class="col-sm-3 control-label">Balance:</label>
          <div class="col-sm-7">
            <div class="input-group">
              <span class="input-group-addon">$</span>
              <input class="form-control credit-card-balance" type="text" placeholder="(eg. 3,275.22)" name="credit-card-balance1">
            </div>
          </div>
        </div>
        <div class="form-group" align="left">
          <label for="credit-card-label1" class="col-sm-3 control-label">Give it a name:</label>
          <div class="col-sm-7">
            <input class="form-control credit-card-label" type="text" placeholder="(eg. WF checking atm card)" name="credit-card-label1">
          </div>
        </div>
        <div class="form-group" align="left">
          <div class="col-sm-offset-3 col-sm-7">
            <button type="button" class="btn button btn-default btn-sm btn-more" ng-click="buildAndPan(2)"><span class="glyphicon glyphicon-plus"></span> Enter More Debt</button>
          </div>
        </div>
        <br/>
        <div align="center">
          <button type="button" class="btn button btn-primary btn-submit" form="entry"><i class="fas fa-calculator"></i> Show Me The Plan</button>
        </div>

      </div>
      <div class="col-sm-2"></div>

    </div>

    </cfoutput>

  </div>

</div>

</form>

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
  <section dir="ltr" class="footer">
    <div class="section-inner">
      <cfoutput>
      <h3>#application.locale[session.auth.locale]['name']#</h3>
      <h3>#application.locale[session.auth.locale]['motto']#</h3>
      </cfoutput>
      <button class="btn btn-default" id="returnTop"> Get Started</button>
      <footer id="footer-sitemap">
        <div class="footer-container">
          <div class="sitemap">
            <div class="footer-column"></div>
            <div class="footer-column"></div>
            <div class="footer-column"></div>
          </div>
          <div class="footer-language-options">
            <h3>Site Language</h3>
            <ul>
              <li>English</li>
              <li>Spanish</li>
            </ul>
          </div>
        </div>
      </footer>
    </div>
  </section>

</div>