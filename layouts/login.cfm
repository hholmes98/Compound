<!-- layouts/login.cfm :: all login.* actions use this -->
<body>
<cfoutput>#view('common/nav/loggedout')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div class="container"> 
  <cfoutput>
    #view('common/func/msg')#

    #body#
  </cfoutput>
</div>

</body>