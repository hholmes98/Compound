<!-- layouts/login.cfm :: all login.* actions use this -->
<body>
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-W3L6CM2"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

<cfoutput>#view('common/nav/loggedout')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div class="container"> 
  <cfoutput>
    #view('common/func/msg')#

    #body#
  </cfoutput>
</div>

</body>