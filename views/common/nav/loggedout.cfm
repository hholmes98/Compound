<!-- views/common/nav/loggedout.cfm -->
<cfoutput>
<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar dd-icon-bar"></span>
        <span class="icon-bar dd-icon-bar"></span>
        <span class="icon-bar dd-icon-bar"></span>
      </button>
      <span class="navbar-brand">
        <cfif ( application.allow_new_users )>
          <img style="display:inline-block;margin-right:4px;position:relative;top:-2px;" src="assets/img/dd-logo-white-trans-24x24.png" width="24" height="24">
          <a href="#buildUrl(application.start_page)#">#application.app_name#<cfif application.app_show_version> (#application.app_version#)</cfif></a>
        </cfif>
      </span>
    </div>

    <div class="collapse navbar-collapse">
      <cfif ( application.allow_new_users )>
      <ul class="nav navbar-nav">
        <li class="dropdown">
          <a href="##" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fas fa-info-circle"></i> <span class="nav-label">About</span> <span class="caret"></span></a>
          <ul class="dropdown-menu">
            <li<cfif REQUEST.item is 'about'> class="active"</cfif>><a href="#buildUrl('main.about')#" role="menuitem"><i class="fas fa-question-circle"></i> What is #application.app_name#?</span></a></li>
            <li<cfif REQUEST.item is 'contact'> class="active"</cfif>><a href="#buildUrl('main.contact')#"><i class="fas fa-envelope"></i> Contact us</a></li>
          </ul>
        </li>
        <li<cfif REQUEST.item is 'features'> class="active"</cfif>><a href="#buildUrl('main.features')#" role="menuitem"><i class="fas fa-sliders-h"></i> Features</a></li>
        <li<cfif REQUEST.item is 'pricing'> class="active"</cfif>><a href="#buildUrl('main.pricing')#"><i class="fas fa-bolt"></i> Powerups</a></li>
      </ul>
      </cfif>
      <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
          <a href="##" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fas fa-bullhorn"></i> <span class="nav-label">What's New?</span> <span class="caret"></span></a>
          <ul class="dropdown-menu">
            <li><a href="https://blog.#application.site_domain#" role="menuitem"><i class="far fa-newspaper"></i> <span class="nav-label">News</span></a></li>
            <li><a href="https://forum.#application.site_domain#" role="menuitem"><i class="fab fa-discourse"></i> <span class="nav-label">Discussion</span></a></li>
            <cfif ( application.allow_new_users )>
              <li><a href="#buildUrl('main.top')#"><i class="fas fa-trophy"></i> <span class="nav-label">Top Cards</span></a></li>
            </cfif>
          </ul>
        </li>
        <li<cfif REQUEST.section is 'login'> class="active"</cfif>><a href="#buildUrl('login')#" role="menuitem"><i class="fas fa-lock"></i> Sign In</a></li>
      </ul>
    </div>
  </div>
</nav>
</cfoutput>