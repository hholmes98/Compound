<!-- layouts/main.cfm :: all main.* actions use this -->
<body ng-controller="ddMain">
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-KQKHT7L"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

<cfoutput>#view('common/nav/loggedout')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<cfoutput>
  #view('common/func/msg')#

  #body#
</cfoutput>


<!-- needs to run at </body> -->
<script src="/assets/js/dd-controller.js"></script>

</body>