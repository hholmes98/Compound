<!-- layouts/calculate :: for all calculate.* actions -->
<body ng-controller="ddCalculate">
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-KQKHT7L"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

<cfoutput>#view('common/nav/loggedin')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div class="container">
  <cfoutput>
    #view('common/func/msg')#

    #body#
  </cfoutput>
</div>

<!-- needs to run at </body> -->
<script src="/assets/js/dd-animatePage.js"></script>
<script src="/assets/js/dd-bb.js"></script>
<script src="/assets/js/dd-controller.js"></script>

<!--- this remains in template to bridge cf/js --->
<script>
  function CF_getUserID() {
    return <cfoutput>#session.auth.user.getUser_Id()#</cfoutput>;
  }
</script>

</body>