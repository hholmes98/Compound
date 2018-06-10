<!-- views/pay/default -->
<cfset pageStart = 2 />

<div class="pan-page pan-page-1">
  <div class="container">
    <div class="page-header">
      <h1><cfoutput>What shall we do, #session.auth.user.getName()#?</cfoutput></h1>
    </div>
    <cfoutput>
    <div align="center">
      <span align="left">
        <button class="btn button btn-default btn-tile" ng-click="panTo(2)"><i class="fas fas-large fa-dollar-sign"></i></span><br/><br/> PAY my<br/>bills</button>
      </span>
      <span align="center">
        <button class="btn button btn-default btn-tile" ng-click="navigateTo('#buildUrl('manage.budget')#')"><i class="fas fas-large fa-chart-pie"></i><br/><br/> UPDATE my<br/>budget</button>
      </span>
      <span align="right">
        <button class="btn button btn-default btn-tile" ng-click="navigateTo('#buildUrl('calculate.future')#')"><i class="fas fas-large fa-calculator"></i><br/><br/> CALCULATE my<br/>payoff</button>
      </span>
    </div>
    </cfoutput>
  </div>
</div>

<cfoutput>#view('pay/cards')#</cfoutput>