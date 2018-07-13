<!-- views/main/about -->

<div class="top-buffer">

  <section>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          <div align="center">
            <h1>What is <cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput>?</h1>
            <h3><cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> is a credit card calculator that looks at your debt,<br/>
            determines the fastest payoff, telling you what to pay and when.</h3>
          </div>
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          <div align="center">
            <h2 shadow-text="How does it work?">How does it work?</h2>
          </div>
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-8">
          <b>Load your debt.</b> Tell what your remaining balance is on every card you own. No need to hookup to any bank accounts, 
          no need to share any personal info. Just balances. That's all we need.
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-offset-4 col-md-8">
          <b>Give us a monthly budget.</b> How much can you afford, each month, to apply towards all of your outstanding debt, while
          still living within your means? $150? $300? There is no wrong answer, just tell us what works for you.
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-8">
          <b>Pull up <cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> while you pay bills.</b> When it's time to sit down and pay the bills, pull up <cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput>,
          either on your computer or smartphone.
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-offset-4 col-md-8">
          <b>Pay the recommended payment on each card.</b> Check the <em>balance</em> and <em>minimum payment</em> the bill asks for.
          Update them, if they're out-of-date. <cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> immediately tells you what your recommended payment should be for
          that bill.
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          <div align="center">
            <h2 shadow-text="It's as simple as that.">It's as simple as that.</h2>
          </div>
        </div>

      </div>
    </div>

  </section>

  <div>
    <br><br>
  </div>

  <cfoutput>#view('common/nav/footer')#</cfoutput>

</div>