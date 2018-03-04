<!-- layouts/pay :: for all main.* actions -->
<body ng-controller="ddPay">
<cfoutput>#view('common/nav/loggedin')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div id="pan-main" class="pan-perspective">
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