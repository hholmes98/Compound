<!DOCTYPE html>
<html ng-app="ddApp" lang="<cfoutput>#ListFirst(session.auth.locale,"-")#</cfoutput>">
<head>
  <cfsilent>
    <cfparam name="COOKIE['dd-skin']" default="1" />
    <cfparam name="rc.title" default="#application.app_name# - #application.app_short_description#" />
    <cfparam name="rc.pageTitle" default="" />
    <cfparam name="rc.pageDescription" default="#application.locale[session.auth.locale]['description']#" />
    <cfparam name="rc.robots" default="noarchive" />
  </cfsilent>
  <!-- layouts/default -->
  <base href="/">
  <cfoutput>
    <meta charset="utf-8" />

    <title><cfif Len(rc.pageTitle)>#rc.pageTitle# | </cfif>#rc.title#</title>

    <link rel="shortcut icon" href="#request.abs_url#/favicon.ico" />
    <link rel="icon" href="#request.abs_url#/assets/img/#application.skins[COOKIE["dd-skin"]].favicon#" /><!--- TODO: make sure this is 192x192 --->
    <link rel="apple-touch-icon" href="#request.abs_url#/assets/img/#application.skins[COOKIE["dd-skin"]].favicon#" />
    <link rel="canonical" href="#request.abs_url##request._fw1.CgiPathInfo#" />

    <meta name="language" content="#ListFirst(session.auth.locale,"-")#">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="#rc.robots#" />
    <meta name="description" content="#rc.pageDescription#" />
    <meta name="theme-color" content="#application.skins[COOKIE["dd-skin"]].themeColor#" />

    <meta property="og:title" content="<cfif len(rc.pageTitle)>#rc.pageTitle#<cfelse>#rc.title#</cfif>" />
    <meta property="og:locale" content="#session.auth.locale#" />
    <meta property="og:description" content="#rc.pageDescription#" />
    <meta property="og:url" content="#request.abs_url##request._fw1.CgiPathInfo#" />
    <meta property="og:site_name" content="#rc.title#" />
    <meta property="og:image" content="#request.abs_url#/assets/img/#application.skins[COOKIE["dd-skin"]].favicon#" />

    <script type="application/ld+json">
    {
      "@context": "http://schema.org",
      "@type": "Organization",
      "name": "#application.app_name#",
      "url": "#request.abs_url#",
      "logo": "<cfoutput>#request.abs_url#/assets/img/#application.skins[COOKIE["dd-skin"]].favicon#</cfoutput>",
      "sameAs": [
        #ListQualify(ArrayToList(application.sameas),'"')#
      ],
      "contactPoint": [{
        "@type": "ContactPoint",
        "email": "#application.admin_email#",
        "contactType": "sales & support",
        "url": "#request.abs_url#"
      }]
    }
    </script>
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:site" content="#application.twitter.nick#" />
    <meta name="twitter:image" content="#request.abs_url#/assets/img/#application.twitter.image#" />

    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0" />
  </cfoutput>

  <!-- Google Tag Manager -->
  <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
  new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
  j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
  'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  })(window,document,'script','dataLayer','GTM-KQKHT7L');
  </script>
  <!-- End Google Tag Manager -->

  <!-- Global site tag (gtag.js) - Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=UA-120544683-1"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'UA-120544683-1');
    <cfif StructKeyExists( session, 'auth' ) && session.auth.isLoggedIn>
    gtag('set', {'user_id': '<cfoutput>#Hash(session.auth.user.getUser_Id())#</cfoutput>'}); // Set the user ID using signed-in user_id.
    </cfif>
  </script>

  <style>
  [ng\:cloak],
  [ng-cloak],
  [data-ng-cloak],
  [x-ng-cloak],
  .ng-cloak,
  .x-ng-cloak {
    display: none !important;
  }
  </style>

  <!-- styles -->
  <cfinclude template="/includes/styles/styles.cfm">

  <!-- scripts -->
  <cfinclude template="/includes/scripts/scripts.cfm">

  <script>
  function CF_restErrorHandler( e ) {
    <cfif getEnvironment() == "development">
    alert(e);
    console.log(e);
    <cfelse>
    // by default, we throw the user back to the login page.
    window.location.href = '/index.cfm/login.oops';
    </cfif>
  }

  function CF_getTheme( i ) {
    switch(i.toString()) {
      case "1":
        return '<cfoutput>#REQUEST.abs_url#/assets/css/#application.skins[1].path#</cfoutput>';
        break;
      case "2":
        return '<cfoutput>#REQUEST.abs_url#/assets/css/#application.skins[2].path#</cfoutput>';
        break;
    }
  }
  </script>
</head>

<cfoutput>#body#</cfoutput>

</html>