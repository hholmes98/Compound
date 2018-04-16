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
       <cfoutput><a href="#buildUrl(application.start_page)#">#application.app_name#</a></cfoutput>
      </span>
    </div>

    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li><cfoutput><a href="#buildUrl('login')#"> Sign In</a></cfoutput></li>
      </ul>
    </div>
  </div>
</nav>