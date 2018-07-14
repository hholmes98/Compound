<!-- views/common/nav/loggedin.cfm -->
<cfoutput>
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
        <img style="display:inline-block;margin-right:4px;position:relative;top:-2px;" src="assets/img/dd-logo-white-trans-24x24.png" width="24" height="24">
        <a href="#buildUrl(application.auth_start_page)#">#application.app_name#<cfif application.app_show_version> (#application.app_version#)</cfif></a>
      </span>
    </div>

    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
        <li<cfif REQUEST.section is 'pay'> class="active"</cfif>><a href="#buildUrl('pay.bills')#"><i class="fas fa-dollar-sign"></i> <span class="nav-label">Pay Bills</span><cfif REQUEST.section is 'pay'> <span class="sr-only">(current)</span></cfif></a></li>
        <li<cfif REQUEST.section is 'deck'> class="active"</cfif>><a href="#buildUrl('manage.budget')#"><i class="fas fa-chart-pie"></i> <span class="nav-label">Update Budget</span><cfif REQUEST.section is 'main'> <span class="sr-only">(current)</span></cfif></a></li>
        <li<cfif REQUEST.section is 'calculate'> class="active"</cfif>><a href="#buildUrl('calculate.future')#"><svg class="icon-dd-calculator"><use xlink:href="/assets/img/icons.svg##icon-dd-calculator"></use></svg> <span class="nav-label">Calculate Payoff</span><cfif REQUEST.section is 'plan'> <span class="sr-only">(current)</span></cfif></a></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
          <a href="##" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fas fa-bullhorn"></i> <span class="nav-label">What's New?</span> <span class="caret"></span></a>
          <ul class="dropdown-menu">
            <li><a href="https://blog.#application.site_domain#"><i class="far fa-newspaper"></i> <span class="nav-label">News</span></a></li>
            <li><a href="https://forum.#application.site_domain#"><i class="far fa-comments"></i> <span class="nav-label">Discussion</span></a></li>
            <li><a href="#buildUrl('main.top')#"><i class="fas fa-trophy"></i> <span class="nav-label">Top Cards</span></a></li>
          </ul>
        </li>
        <li class="dropdown<cfif REQUEST.section is 'profile'> active</cfif>">
          <a href="##" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fas fa-user"></i> <span class="nav-label">Profile</span> <span class="caret"></span></a>
          <ul class="dropdown-menu">
            <li><a href="#buildUrl('profile.basic')#"><i class="fas fa-cog"></i> <span class="nav-label">User Settings</span></a></li>
            <li><a href="#buildUrl('profile.advanced')#"><i class="fas fa-credit-card"></i> <span class="nav-label">Account Info</span></a></li>
            <li><a href="#buildUrl('login.logout')#"><i class="fas fa-sign-out-alt"></i> <span class="nav-label">Sign out</span></a></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>
</cfoutput>