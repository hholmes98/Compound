<!-- layouts/pay :: for all pay.* actions -->
<body ng-controller="ddPay">
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-KQKHT7L"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

<cfoutput>#view('common/nav/loggedin')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div id="pan-main">

  <div class="section fp-auto-height">

  <cfoutput>
    #view('common/func/msg')#

    #body#
  </cfoutput>

  </div>

</div>

<!--- this remains in template to bridge cf/js --->
<script>
  function CF_getUserID() {
    return <cfoutput>#session.auth.user.getUser_Id()#</cfoutput>;
  }
</script>

<cfoutput>#view('common/func/scripts')#</cfoutput>

</body>