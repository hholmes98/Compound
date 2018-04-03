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
  })(window,document,'script','dataLayer','GTM-W3L6CM2');</script>
  <!-- End Google Tag Manager -->

  <!-- styles -->
  <cfinclude template="/includes/styles/styles.cfm">

  <!-- scripts -->
  <cfinclude template="/includes/scripts/scripts.cfm">

  <script>
  var ddApp = angular.module('ddApp', ['ui.calendar', 'ui.bootstrap', '720kb.tooltips', 'ui.toggle']);
  </script>

  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0" />

  <script> 
  window.onload = function() {
    setTimeout(function() {
      var ad = document.querySelector("ins.adsbygoogle");
      if (ad && ad.innerHTML.replace(/\s/g, "").length == 0) {
        ad.style.cssText = 'display:block !important'; 
        ad.parentNode.innerHTML += '<div style="padding:5px; background-color:#171717; border:1px solid #fff; margin:5px 5px 10px 5px; display:inline-block; text-align:left">You appear to be blocking our ads with an Ad Blocker. <cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput> depends on these ads to help cover our high server costs. Please add *.<cfoutput>#application.site_domain#</cfoutput> to your ad blocker\'s whitelist or consider upgrading to a paid account.</div>';
      }
    }, 1000);
  };
  </script>

</head>

<cfoutput>#body#</cfoutput>

</html>