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
        <i class="fas fa-band-aid"></i>
        <cfoutput><a href="#buildUrl(application.auth_start_page)#">#application.app_name#</a></cfoutput>
      </span>
    </div>

    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
        <li<cfif REQUEST.section is 'pay'> class="active"</cfif>><cfoutput><a href="#buildUrl('pay.cards')#"><i class="fas fa-dollar-sign"></i> <span class="nav-label">Pay Bills</span><cfif REQUEST.section is 'pay'> <span class="sr-only">(current)</span></cfif></a></cfoutput></li>
        <li<cfif REQUEST.section is 'main'> class="active"</cfif>><cfoutput><a href="#buildUrl('main')#"><i class="fas fa-chart-pie"></i> <span class="nav-label">Update Budget</span><cfif REQUEST.section is 'main'> <span class="sr-only">(current)</span></cfif></a></cfoutput></li>
        <li<cfif REQUEST.section is 'plan'> class="active"</cfif>><cfoutput><a href="#buildUrl('plan')#"></cfoutput><i class="fas fa-calculator"></i> <span class="nav-label">Calculate Payoff</span><cfif REQUEST.section is 'plan'> <span class="sr-only">(current)</span></cfif></a></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fas fa-bullhorn"></i> <span class="nav-label">What's New?</span> <span class="caret"></span></a>
          <ul class="dropdown-menu">
            <li><a href="http://blog.<cfoutput>#application.site_domain#</cfoutput>"><i class="far fa-newspaper"></i> <span class="nav-label">News</span></a></li>
            <li><a href="http://forum.<cfoutput>#application.site_domain#</cfoutput>"><i class="far fa-comments"></i> <span class="nav-label">Discussion</span></a></li>
          </ul>
        </li>
        <li class="dropdown<cfif REQUEST.section is 'profile'> active</cfif>">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fas fa-user"></i> <span class="nav-label">Profile</span> <span class="caret"></span></a>
          <ul class="dropdown-menu">
            <cfoutput>
            <li><a href="#buildUrl('profile.basic')#"><i class="fas fa-cog"></i> <span class="nav-label">User Settings</span></a></li>
            <li><a href="#buildUrl('profile.advanced')#"><span class="glyphicon glyphicon-credit-card"></span> <span class="nav-label">Account Info</span></a></li>
            <li><a href="#buildUrl('login.logout')#"><i class="fas fa-sign-out-alt"></i> <span class="nav-label">Sign out</span></a></li>
            </cfoutput>
          </ul>
        </li>
          
      </ul>
    </div>
  </div>
</nav>