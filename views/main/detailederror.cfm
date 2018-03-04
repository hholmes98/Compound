<!-- views/main/error -->
<cfheader statuscode="500" />

<cfoutput>
  <h3>#request.exception.message#</h3>

  <textarea cols="80" rows="10">#request.exception.stacktrace#</textarea>

  <p><b>Tag Context</b></p>

  <ol>
  <cfloop array="#request.exception.tagcontext#" item="tag">
    <li><cfdump var=#tag#></li>
  </cfloop>
  </ol>

</cfoutput>