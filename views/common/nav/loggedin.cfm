<!-- views/common/nav/loggedin.cfm -->
<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <span class="navbar-brand">
       <cfoutput><a href="#buildUrl(application.auth_start_page)#">#application.app_name#</a></cfoutput>
      </span>
    </div>

    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
        <li<cfif REQUEST.section is 'pay'> class="active"</cfif>><cfoutput><a href="#buildUrl('pay.cards')#"><i class="fas fa-dollar-sign"></i></span><cfif REQUEST.section is 'pay'> <span class="sr-only">(current)</span></cfif></a></cfoutput></li>
        <li<cfif REQUEST.section is 'main'> class="active"</cfif>><cfoutput><a href="#buildUrl('main')#"><i class="fas fa-chart-pie"></i><cfif REQUEST.section is 'main'> <span class="sr-only">(current)</span></cfif></a></cfoutput></li>
        <li<cfif REQUEST.section is 'plan'> class="active"</cfif>><cfoutput><a href="#buildUrl('plan')#"></cfoutput><i class="fas fa-calculator"></i><cfif REQUEST.section is 'plan'> <span class="sr-only">(current)</span></cfif></a></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li<cfif REQUEST.section is 'profile'> class="active"</cfif>><cfoutput><a href="#buildUrl('profile.basic')#"><i class="fas fa-user"></i><cfif REQUEST.section is 'profile'> <span class="sr-only">(current)</span></cfif></a></cfoutput></li>
      </ul>
    </div>
  </div>
</nav>