<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html ng-app="ddApp" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <!-- layouts/default -->
  <base href="/">

  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title><cfoutput>#application.app_name#</cfoutput></title>

  <!-- Google Tag Manager -->
  <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
  new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
  j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
  'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  })(window,document,'script','dataLayer','GTM-KQKHT7L');</script>
  <!-- End Google Tag Manager -->

  <!-- Global site tag (gtag.js) - Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=UA-120544683-1"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'UA-120544683-1');
    <cfif StructKeyExists( session, 'auth' ) && session.auth.isLoggedIn>
    gtag('set', {'user_id': '<cfoutput>#session.auth.user.getUser_Id()#</cfoutput>'}); // Set the user ID using signed-in user_id.
    </cfif>
  </script>

  <!-- styles -->
  <cfinclude template="/includes/styles/styles.cfm">

  <!-- scripts -->
  <cfinclude template="/includes/scripts/scripts.cfm">

  <script>
  var ddApp = angular.module('ddApp', ['ngSanitize', 'ngCookies', 'ui.calendar', 'ui.bootstrap', '720kb.tooltips', 'ui.toggle']);
  </script>

  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0" />

  <script> 
  window.onload = function() {
    setTimeout(function() {
      var ad = document.querySelector("ins.adsbygoogle");
      if (ad && ad.innerHTML.replace(/\s/g, "").length == 0) {
        ad.style.cssText = 'display:block !important'; 
        ad.parentNode.innerHTML += '<div style="padding:5px; background-color:#171717; border:1px solid #fff; margin:5px 5px 10px 5px; display:inline-block; text-align:left; position: absolute; top: 0px; left: 0px;"><cfoutput>#application.ad_blocker#</cfoutput></div>';
      }
    }, 1000);
  };

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
    switch(i) {
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