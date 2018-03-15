<!-- views/plan/default -->

<div class="page-header">
  <h1>Calculate Your Future</h1>
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
  <ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="active"><a href="#plan" aria-controls="plan" role="tab" data-toggle="tab"><i class="fas fa-eye"></i> This Month (At A Glance)</a></li>
    <li role="presentation"><a href="#schedule" ng-click="renderCalendar('eventCalendar')" aria-controls="schedule" role="tab" data-toggle="tab"><i class="fas fa-calendar-alt"></i> Schedule By Month</a></li>
    <li role="presentation"><a href="#journey" aria-controls="journey" role="tab" data-toggle="tab"><i class="fas fa-chart-area"></i> Future Milestones</a></li>
  </ul>

  <div class="tab-content">

    <!--- tab 1

    List out the cards, and display the calculated payment for each card. 

    --->
    <div role="tabpanel" class="panel-body tab-pane active" id="plan">
      <span>
        <h3>For This Month</h3>
        <cfoutput><h2 shadow-text="#MonthAsString(Month(Now()))# #Year(Now())#">#MonthAsString(Month(Now()))# #Year(Now())#</h2></cfoutput>
      </span>
      <table class="table table-striped table-bordered table-valign-middle">
        <thead>
          <tr>
            <th class="col-md-6">For This Card</th>
            <th class="col-md-4">Pay This Amount</th>
          </tr>
        </thead>
        <tbody>
          <tr class="align-top" ng-form name="myForm" ng-repeat="card in keylist | orderBy:'null':false:cardLabelCompare">
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

    <!--- tab 2

    Render the current month, color coded by the pay frequency, and show the X calculated amounts that are being
    paid per selection (so if twice a month, show the calculated $$ for 1st half and the calculated $$ for 2nd half)

    --->
    <div role="tabpanel" class="panel-body tab-pane" id="schedule">
      <!-- using https://github.com/angular-ui/ui-calendar -->
      <div class="alert-success calAlert" ng-show="alertMessage != undefined && alertMessage != ''">
        <h4>{{alertMessage}}</h4>
      </div>
      <div ui-calendar="uiConfig.calendar" id="eventCalendar" class="span8 calendar" ng-model="schedule"></div>
    </div>

    <!--- tab 3

    Show a line graph of dates traveling into the future for the next year, and draw vertical dashed lines at various milestones
    (where certain cards are paid off) to convey a sense of progression, regardless of debt load.

    --->
    <div role="tabpanel" class="panel-body tab-pane" id="journey">
      <div id="milestones"></div>
    </div>

  </div><!-- /tab-content -->

</div><!-- /panel -->