<!-- views/main/plan.cfm -->
<cfsilent>
  <cfif StructIsEmpty( session.tmp.preferences )>
    <!--- someone tried to go directly this page, send 'em back --->
    <cflocation url="/" addtoken="false" />
  </cfif>
  <cfparam name="rc.anotherCalcURL" default="#buildUrl('main.demo')#" />
</cfsilent>

<!--- this mirrors plan.default, but shows to anonymous/non-auth'd users --->

  <div class="container">

    <div class="page-header">
      <h1>A Debt-Free Future</h1>
      <h3>Your path is now clear.</h3>
    </div>

    <div class="row">

      <div class="col-lg-6 col-md-6 col-sm-12 col-xs-12 bottom-buffer" align="center">
        <cfoutput>
          <button class="btn button btn-default btn-lg" onClick="location.href='#rc.anotherCalcURL#';">
            <svg class="icon-dd-calculator">
              <use xlink:href="/assets/img/icons.svg##icon-dd-calculator"></use>
            </svg> Run Another Calculation
          </button>
        </cfoutput>
      </div>

      <div class="col-lg-6 col-md-6 col-sm-12 col-xs-12 bottom-buffer" align="center">
        <cfoutput>
          <button class="btn button btn-primary btn-lg" onClick="location.href='#buildUrl('main.create')#';">
            <i class="fas fa-save"></i> Save Plan
          </button>
        </cfoutput>
      </div>

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

          <table class="table table-striped table-bordered table-valign-middle">
            <thead>
            <tr>
              <th colspan="2">
                <h3>A Plan For Every Month</h3>
                <p>
                  Every month, we'll give you a detailed plan of what you pay and when. For this month <strong>(<cfoutput>#MonthAsString(Month(Now()))# of #Year(Now())#</cfoutput>)</strong>
                  we've taken your budget of <strong>$<cfoutput>#session.tmp.preferences.budget#</cfoutput></strong> and split the payments so that you'll see the fastest payoff.
                </p>
                <p>
                  ...and every time you refer to your plan while paying your bills, if the balance and/or minimum payment change, <strong>your plan will
                  update in real-time</strong>, ensuring your have the absolute best plan possible every second of the way...right down to the last cent.
                </p>
              </th>
            </tr>
            <tr>
              <th class="col-md-6">For This Card</th>
              <th class="col-md-4">Pay This Amount</th>
            </tr>
            </thead>
            <tbody>

            <tr class="align-top" ng-form name="myForm" ng-repeat="card in plan">
              <td>
                <span ng-show="card.is_hot==1" tooltip-enable="card.is_hot==1" uib-tooltip-html="'YOW!! Don\'t touch! This is a <font color=\'#db8f00\'><b>hot card</b></font> and is being paid off at maximum velocity!'"><i class="fas fa-fire fire-flame"></i> </span>
                {{card.label}}
              </td>
              <td>
                <span ng-bind-html="card.calculated_payment|calculatedPaymentFilter" tooltip-enable="{{card.calculated_payment < 0}}" uib-tooltip-html="'<cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> recommends you do not make a payment on this card this month. Instead, call the company to request a deferral.<br><br>If you need help with this, <a href=\'<cfoutput>#application.static_urls.call#</cfoutput>\'>follow this guide</a>.'" />
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

          <table class="table table-striped table-bordered table-valign-middle">
            <thead>
              <tr>
                <th>
                  <h3>A Finish Line You Can Pinpoint</h3>
                  <p>
                    The worst part of credit card debt is never knowing where it ends. Not knowing ends <strong><em>today</em></strong>.
                  </p>
                  <p>
                    Your plan comes with a visual graph that shows you the date you'll be debt free, along with every single
                    date you'll DECIMATE DEBT on each card. And when you update your cards each month, this plan and path to the finish line updates as well.
                  </p>
                </th>
              </tr>
            </thead>
          </table>

          <div id="milestones"></div>

          <table class="table table-striped table-bordered table-valign-middle">
            <thead>
              <tr>
                <th>
                  <div id="sold" align="center">
                    <cfoutput><button class="btn button btn-primary btn-lg" onClick="location.href='#buildUrl('main.create')#';"><span class="glyphicon glyphicon-floppy-disk"></span> Save Plan</button></cfoutput>
                  </div>
                </th>
              </tr>
            </thead>
          </table>

        </div>

      </div>

    </div>

  </div>