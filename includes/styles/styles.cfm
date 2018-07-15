<cfparam name="COOKIE['dd-skin']" default="1" />

<!--- styles.cfm --->
  <link href="//fonts.googleapis.com/css?family=Nunito:400,600,700,900|Ultra|Days+One|Slabo+13px|Oswald:400,600|Allerta+Stencil" rel="stylesheet" />
  <!--- <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"> --->
  <link href="/node_modules/bootstrap/dist/css/bootstrap.css" rel="stylesheet" /> 

  <!--- http://www.bootstraptoggle.com/ --->
  <link href="//ziscloud.github.io/angular-bootstrap-toggle/css/angular-bootstrap-toggle.min.css" rel="stylesheet" />

  <link href="//cdnjs.cloudflare.com/ajax/libs/bootstrap3-dialog/1.34.7/css/bootstrap-dialog.min.css" rel="stylesheet" />

  <link href="/node_modules/propellerkit/dist/css/propeller.css" rel="stylesheet" />
  <link href="/node_modules/angularjs-slider/dist/rzslider.css" rel="stylesheet" />

  <link href="/node_modules/fullpage.js/dist/fullpage.css" rel="stylesheet" />
  <link href="/node_modules/fullcalendar/dist/fullcalendar.css" rel="stylesheet" />
  <link href="/node_modules/angular-tooltips/dist/angular-tooltips.css" rel="stylesheet" />

  <link id="skin" href="/assets/css/<cfoutput>#application.skins[COOKIE["dd-skin"]].path#</cfoutput>" type="text/css" rel="stylesheet" />