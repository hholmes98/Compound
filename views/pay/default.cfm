<!-- views/pay/default -->

<div class="top-screen-quarter-buffer"></div>

<div class="pan-page pan-page-1 slide" data-anchor="choose">
  <div class="container">

    <div class="page-header">
      <h1><cfoutput>What shall we do, #session.auth.user.getName()#?</cfoutput></h1>
    </div>

    <cfoutput>
    <div align="center">
      <span align="left">
        
        <button class="btn button btn-default btn-tile" ng-disable="loadingBills==true" onClick="location.hash='##list/cards'">
          <i class="fas fas-large fa-dollar-sign"></i>
          <br/><br/> PAY my<br/>bills
        </button>
      </span>
      <span align="center">
        
        <button class="btn button btn-default btn-tile" ng-disable="loadingBills==true" ng-click="navigateTo('#buildUrl('manage.budget')#')">
          <i class="fas fas-large fa-chart-pie"></i>
          <br/><br/> UPDATE my<br/>budget
        </button>
      </span>
      <span align="right">
        
        <button class="btn button btn-default btn-tile" ng-disable="loadingBills==true" ng-click="navigateTo('#buildUrl('calculate.future')#')">
          <svg class="icon-dd-calculator icon-large">
            <use xlink:href="/assets/img/icons.svg##icon-dd-calculator"></use>
          </svg>
          <br/><br/> CALCULATE my<br/>payoff
        </button>
      </span>
    </div>
    </cfoutput>

  </div>
</div>

<cfoutput>#view('pay/cards')#</cfoutput>