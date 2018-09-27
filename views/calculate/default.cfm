<!-- views/calculate/default -->

<div class="top-screen-quarter-buffer"></div>

<div class="page-header">
  <h1>Calculate Your Payoff</h1>
  <h3>Chin up. <cfoutput>#session.auth.user.getName()#</cfoutput>'s debt-free future is in sight. <em>Literally</em>.</h3>
</div>

<p>
  This is where the magic happens. The panel below contains your path to a debt-free future.
  <ul>
    <li><strong><i class="fas fa-eye"></i> This Month (At A Glance):</strong> What we recommend you should pay to each card, this month...for <strong>all</strong> your cards.</li>
    <li><strong><i class="fas fa-calendar-alt"></i> Schedule By Month:</strong> This shows you <em><strong>when</strong></em> you should make the payment for each specific card.</li>
    <li><strong><i class="fas fa-chart-area"></i> Future Milestones:</strong> A visual timeline that shows when each card is paid off, if you stick to your plan.</li>
  </ul>
</p>

<div class="panel panel-default form-horizontal">

  <!--- top tab nav --->
  <ul class="nav nav-tabs">
    <li ng-class="{'active': thisMonthTab==true}"><a ng-click="thisMonthTab=true;scheduleTab=false;milestoneTab=false" href="javascript:void(0)" aria-controls="plan"><i class="fas fa-eye"></i> This Month (At A Glance)</a></li>
    <li ng-class="{'active': scheduleTab==true}"><a ng-click="thisMonthTab=false;scheduleTab=true;milestoneTab=false;renderCalendar('eventCalendar')" href="javascript:void(0)" aria-controls="schedule"><i class="fas fa-calendar-alt"></i> Schedule By Month</a></li>
    <li ng-class="{'active': milestoneTab==true}"><a ng-click="thisMonthTab=false;scheduleTab=false;milestoneTab=true" href="javascript:void(0)" aria-controls="journey"><i class="fas fa-chart-area"></i> Future Milestones</a></li>
  </ul>

  <div class="tab-content">

    <!--- tab 1

    List out the cards, and display the calculated payment for each card. 

    --->
    <div id="plan" class="panel-body" ng-show="thisMonthTab">
      <div class="row panel-header">
        <div class="col-md-12">
          <h3>For This Month</h3>
          <cfoutput><h2 shadow-text="#MonthAsString(Month(Now()))# #Year(Now())#">#MonthAsString(Month(Now()))# #Year(Now())#</h2></cfoutput>
        </div>
      </div>
      <div class="row panel-header col-names"><!--- class="table table-striped table-bordered table-valign-middle" --->
        <div class="col-md-6">For This Card</div>
        <div class="col-md-6">Pay This Amount</div>
      </div>
      <div class="row panel-body" ng-form name="planForm" ng-repeat="card in cards | cardSorter:orderByField:reverseSort">
        <div class="col-md-6"><span ng-show="card.is_hot==1" tooltip-enable="card.is_hot==1" uib-tooltip-html="'YOW!! Don\'t touch! This is a <font color=\'#db8f00\'><b>hot card</b></font> and is being paid off at maximum velocity!'"><i class="fas fa-fire fire-flame"></i> </span>{{card.label}}</div>
        <div class="col-md-6"><span ng-bind-html="card.calculated_payment|calculatedPaymentFilter" tooltip-enable="{{card.calculated_payment < 0}}" uib-tooltip-html="'<cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> recommends you do not make a payment on this card this month. Instead, call the company to request a deferral.<br><br>If you need help with this, <a href=\'<cfoutput>#application.static_urls.call#</cfoutput>\'>follow this guide</a>.'" /></div>
      </div>
      </div>
    </div>

    <!--- tab 2

    Render the current month, color coded by the pay frequency, and show the X calculated amounts that are being
    paid per selection (so if twice a month, show the calculated $$ for 1st half and the calculated $$ for 2nd half)

    --->
    <div class="panel-body" id="schedule" ng-show="scheduleTab">
      <!-- using https://github.com/angular-ui/ui-calendar -->
      <div ng-if="!(schedule.length)">
        Loading...<div class="loader"></div>
      </div>
      <div class="alert-success calAlert" ng-show="alertMessage != undefined && alertMessage != ''">
        <h4>{{alertMessage}}</h4>
      </div>
      <div ui-calendar="uiConfig.calendar" id="eventCalendar" class="span8 calendar" ng-model="schedule"></div>
    </div>

    <!--- tab 3

    Show a line graph of dates traveling into the future for the next year, and draw vertical dashed lines at various milestones
    (where certain cards are paid off) to convey a sense of progression, regardless of debt load.

    --->
    <div class="panel-body" id="journey" ng-show="milestoneTab">
      <div id="milestones">
        Loading...<div class="loader"></div>
      </div>
    </div>

  </div><!-- /tab-content -->

</div><!-- /panel -->