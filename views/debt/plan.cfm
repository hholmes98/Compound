<!-- views/debt/plan.cfm -->
<!--- this mirrors plan.default, but shows to anonymous/non-auth'd users --->

  <div class="container">

    <div class="page-header">
      <h1>A Debt-Free Future</h1>
      <h3>Your path is now clear.</h3>
    </div>

    <div class="panel panel-default form-horizontal">

      <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active"><a href="#plan" aria-controls="plan" role="tab" data-toggle="tab">Today</a></li>
        <!---
        if you make any tab *other* than the calendar tab active by default, the calendar won't render until "today" is
          clicked.

          there are online workarounds for this, so be aware you may need to leverage one.
          --->
        <li role="presentation"><a href="#journey" aria-controls="journey" role="tab" data-toggle="tab">Tomorrow</a></li>
      </ul>

      <div class="tab-content">

        <!-- tab 1 

        List out the cards, and display the calculated payment for each card.
        -->
        <div role="tabpanel" class="panel-body tab-pane active" id="plan" data-ng-init="getTempPlan()">
          <span>
            <h3>A Plan For Every Month</h3>
            <p>
              Every month, we'll give you a detailed plan of what you pay and when. For this month <strong>(<cfoutput>#MonthAsString(Month(Now()))# of #Year(Now())#</cfoutput>)</strong>
              we've taken your budget of <strong>$<cfoutput>#session.tmp.preferences.budget#</cfoutput></strong> and split the payments so that you'll see the fastest payoff.
            </p>
            <p>
              ...and every time you refer to your plan while paying your bills, if the balance and/or minimum payment change, <strong>your plan will
              update in real-time</strong>, ensuring your have the absolute best plan possible every second of the way...right down to the last cent.
            </p>
            <div id="sellit" align="center" class="nav nav-pills">
              <cfoutput><button class="btn button btn-default" href="##journey" aria-controls="journey" role="tab" data-toggle="tab"><span class="glyphicon glyphicon-circle-arrow-right"></span> See The Future</button></cfoutput>
            </div>
            <br/>
          </span>
          <table class="table table-striped table-bordered table-valign-middle">
            <thead>
            <tr>
              <th class="col-md-6">For This Card</th>
              <th class="col-md-4">Pay This Amount</th>           
            </tr>
            </thead>          
            <tbody>
              
            <tr class="align-top" ng-form name="myForm" ng-repeat="card in keylist">
              <td>
                {{plan[card].label}}
              </td>
              <td>
                {{plan[card].calculated_payment | currency}}
              </td>
            </tr>       
            </tbody>
          </table>
        </div>

        <!-- tab 2

        Show a line graph of dates traveling into the future for the next year, and draw vertical dashed lines at various milestones
        (where certain cards are paid off) to convey a sense of progression, regardless of debt load.

         -->
        <div role="tabpanel" class="panel-body tab-pane" id="journey" data-ng-init="getTempSchedule()">

          <span>
            <h3>A Finish Line You Can Pinpoint</h3>
            <p>
              The worst part of credit card debt is never knowing where it ends. Not knowing ends <strong><em>today</em></strong>.
            </p>
            <p>
              Your plan comes with a visual graph that shows you the date you'll be debt free,
              marked with CHECKPOINTS as each card is paid off. And, when your plan updates, so too, does this
              visual path to the finish line.
            </p>
            <div id="sold" align="center">
              <cfoutput><button class="btn button btn-default" onClick="location.href='#buildUrl('debt.create')#';"><span class="glyphicon glyphicon-floppy-disk"></span> Save Plan</button></cfoutput>
            </div>
            <br/>
          </span>

          <div id="milestones"></div>
          
        </div>

      </div>

    </div>

  </div>