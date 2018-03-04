<!-- views/debt/default -->
<form class="form-horizontal" name="entry" id="entry" method="post" action="<cfoutput>#buildUrl('debt.calculate')#</cfoutput>">

<div id="page1" class="pan-page pan-page-1">

  <div class="container">

    <div class="page-header">
      <span align="center"><h1><cfoutput>#application.locale[application.default_locale]['name']#</cfoutput></h1></span>
    </div>

    <cfoutput>

    <div align="center">

      <p>
        <h3>Tell us your debt. We'll tell you the rest.<br/>
        <br/>
        Every payment.<br/>
        <br/>
        Every date.<br/>
        <br/>
        Until you're free.</h3>
      </p>

      <br/>

      <table class="table table-bordered table-responsive table-valign-middle">
        <tbody>
        <tr>
          <td><strong>First:</strong> How much can you <b>afford</b>, each month, to apply towards <em>all</em> of your outstanding debt?</td>
        </tr>
        <tr>
          <td>
            <div class="input-group">
              <div class="input-group-addon">I'll commit</div>
              <div class="input-group-addon">$</div>
              <input class="form-control" type="text" placeholder="(eg. 250.00)" name="budget" />
              <div class="input-group-addon">a month to decimating my debt.</div>
            </div>
          </td>
        </tr>
        <tr>
          <td align="center"><button type="button" class="btn button btn-primary btn-more"><span class="glyphicon glyphicon-circle-arrow-right"></span> Next: Enter Some Debt</button><br/></td>
        </tr>
        <tr>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td align="center"><button type="button" class="btn button btn-default btn-sm btn-login" ng-click="navigateTo('#buildUrl('login.default')#')"><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button></td>
        </tr>
        </tbody>
      </table>

    </div>

    </cfoutput>

  </div>

</div>

<!-- the template for each card uses the 2nd page -->
<div id="page2" class="pan-page page-page-2">

  <div class="container">

    <cfoutput>

    <div class="card-content">

      <div align="center">
        <h3>
          Debt.<br/><br/>
          A loan you owe the bank. A balance lingering on a credit card.<br/>
          We call them <font style="color:gold;">cards</font>, but it's all the same.<br/>
          Just tell us how much you owe. We'll take it from here.
        </h3>
      </div>

      <br/>

      <div class="form-group">
        <label for="credit-card-balance1" class="col-md-8 control-label"><b>Next:</b> Enter the remaining balance on one of your credit cards/debts:</label>
        <div class="col-md-4">
          <div class="input-group">
            <span class="input-group-addon">$</span>
            <input class="form-control credit-card-balance" type="text" placeholder="(eg. 3,275.22)" name="credit-card-balance1">
          </div>
        </div>
      </div>
      <div class="form-group">
        <label for="credit-card-label1" class="col-md-8 control-label">Give it a name:</label>
        <div class="col-md-4">
            <input class="form-control credit-card-label" type="text" placeholder="(eg. WF checking atm card)" name="credit-card-label1">
        </div>
      </div>
      <div class="form-group">
        <div class="col-md-offset-8 col-sm-4">
          <button type="button" class="btn button btn-default btn-sm btn-more"><span class="glyphicon glyphicon-plus"></span> Enter More Debt</button>
        </div>
      </div>

      <br/>
      <br/>

      <div align="center">
        <button type="button" class="btn button btn-primary btn-submit" form="entry"><span class="glyphicon glyphicon-stats"></span> Show Me The Plan</button>
      </div>

    </div>

    </cfoutput>

  </div>

</div>

</form>

<div class="about">

  <section dir="ltr" class="focus">
    <div class="section-inner">
      <div class="text">
        <h3>Focus</h3>
        <p>Financial applications love throwing the kitchen sink at you. We do one thing and one thing well: make
  it <b>easy to track your debts</b>, and figure out <b>the fastest possible way to pay them off</b>. That's
  all you need! Why complicate things?</p>
      </div>
      <span class="splash-icon focus-icon"></span>
    </div>
  </section>
  <section dir="ltr" class="security">
    <div class="section-inner">
      <span class="splash-icon security-icon"></span>
      <div class="text-other">
        <h3>Security</h3>
        <p>Other systems often require a connection to all of your banking institutions. In some cases, those banks
  ask for additional fees, <em>just to connect!</em> This is about paying off debt, not accruing more.
  With us, <b>no bank connections are required,</b> and <b>no credit card numbers stored</b>.
  Under the hood, it's just a list of balances...we don't ask for your personal financial information, and we don't believe
  you should have to fork it over.</p>
      </div>
    </div>
  </section>
  <section dir="ltr" class="fear">
    <div class="section-inner">
      <div class="text">
        <h3>No scary stuff</h3>
        <p>No machine learning. No AI. No blockchain. No bitcoin. No hooking up to your bank and charging you hidden fees.
  No secret surveillance listening in over your phone. Just a simple app doing basic math for you -- <b>math based entirely
  on the world's respected minds in economics and money management.</b> <a href="http://6dollarshirts.com/rocket-surgery" target="_blank">This isn't rocket surgery</a>, so there won't be any rise of the
  machines on our watch! To those buzzwords we say...no thanks!</p>
      </div>
      <span class="splash-icon fear-icon"></span>
    </div>
  </section>
  <section dir="ltr" class="privacy">
    <div class="section-inner">
      <span class="splash-icon privacy-icon"></span>
      <div class="text-other">
        <h3>Your data is yours and nobody else's</h3>
        <p>We value your freedom to choose a competitor. If you don't like us or find something better, we give you a
  single button to access all your data. That's it! It's yours!...<em>as it should be</em>. We'd be sorry to lose
  you, but <b>we care more about <em>your</em> success than our own.</b></p>
      </div>
    </div>
  </section>
  <section dir="ltr" class="support">
    <div class="section-inner">
      <div class="text">
        <h3>Support</h3>
        <p>Paying off debt <em>is hard</em>. It requires discipline over a long period of time.
  Everyone's financial situation is different and it is tough to talk about. We understand that. Ours is a 
  community of shared ideals. No one should be excluded from help or support because of a lack of funds. This
  is why <b>our base functionality is 100% free</b>, <b>support is one click away</b>, and we provide the means for
  <b>others to donate/gift subscriptions to our users</b>.</p>
      </div>
      <span class="splash-icon support-icon"></span>
    </div>
  </section>
  <section dir="ltr" class="footer">
    <div class="section-inner">
      <h3>Decimate your debt.</h3>
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