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
        <button class="btn button btn-default btn-tile" ng-click="panTo(2)"><span class="glyphicon glyphicon-money"></span><br/><br/> PAY bills</button>
      </span>
      <span align="center">
        <button class="btn button btn-default btn-tile" ng-click="navigateTo('#buildUrl('main')#')"><span class="glyphicon glyphicon-cog"></span><br/><br/> UPDATE budget</button>
      </span>
      <span align="right">
        <button class="btn button btn-default btn-tile" ng-click="navigateTo('#buildUrl('plan')#')"><span class="glyphicon glyphicon-stats"></span><br/><br/> SEE my future</button>
      </span>
    </div>
    </cfoutput>
  </div>
</div>

<cfoutput>#view('pay/cards')#</cfoutput>