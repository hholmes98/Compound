<!-- layouts/profile -->
<body>
<cfoutput>#view('common/nav/loggedin')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div class="container">
  <cfoutput>
    #view('common/func/msg')#

    <h1>Profile</h1>

    #body#
  </cfoutput>
</div>

</body>