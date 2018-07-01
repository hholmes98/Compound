<!-- views/common/nav/loggedout.cfm -->
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
        <cfoutput>
          <a href="#buildUrl(application.start_page)#">#application.app_name#<cfif application.app_show_version> (#application.app_version#)</cfif></a>
        </cfoutput>
      </span>
    </div>

    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <cfoutput>
          <li<cfif REQUEST.item is 'about'> class="active"</cfif>><a href="#buildUrl('main.about')#"><i class="fas fa-question-circle"></i> About</a></li>
          <li<cfif REQUEST.item is 'features'> class="active"</cfif>><a href="#buildUrl('main.features')#"><i class="fas fa-sliders-h"></i> Features</a></li>
          <li<cfif REQUEST.item is 'pricing'> class="active"</cfif>><a href="#buildUrl('main.pricing')#"><i class="fas fa-dollar-sign"></i> Pricing</a></li>
          <li<cfif REQUEST.section is 'login'> class="active"</cfif>><a href="#buildUrl('login')#"><i class="fas fa-lock"></i> Sign In</a></li>
        </cfoutput>
      </ul>
    </div>
  </div>
</nav>