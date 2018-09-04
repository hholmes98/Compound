<!--- login/mkt1 --->
<cfoutput>
<div class="col-md-4 col-md-offset-2">

  <div class="panel-heading">
    <div class="panel-title">
      <h2 shadow-text="#rc.mktgTitle#">#rc.mktgTitle#</h2>
    </div>
  </div>

  <div class="main-login main-center">
    <p><strong>#rc.mktgBody#</strong></p>

    <ol>
      <li>Load your debt.
      <li>Specify a budget.
      <li>Use #application.app_name# to track payments while you pay bills.
      <li>Make the recommended payment on each card.
    </ol>

    <p><em>It's as simple as that!</em></p>

    <p>Not sure? <a href="#buildUrl('main.demo')#"><strong>Give the demo a test run!</strong></a></p>

    <br/>
  </div>

</div>
</cfoutput>