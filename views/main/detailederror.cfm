<!-- views/main/error -->
<cfheader statuscode="500" />
<cfset tagCount = 1 />

<cfsavecontent variable="thisTagContext">
  <p><b>Tag Context</b></p>

  <ol>
  <cfloop array="#request.exception.tagcontext#" item="tag">
    <li><cfdump var=#tag#></li>

    <cfif tagCount == 1>
      <cfset offender = tag />
    </cfif>
    <cfset tagCount++ />
  </cfloop>
  </ol>
</cfsavecontent>

<cfoutput>
  <font style="font-size:30px;">ERROR: #request.exception.message#</font><br/>
  <font style="font-size:24px;">DETAIL: #request.exception.detail#</font>

  <br/>
  <br/>

  <strong>Stack Trace:</strong><br/>
  <textarea cols="80" rows="10">#request.exception.stacktrace#</textarea>

  <br/>
  <br/>

  <p>
    <b>Start at:</b>
    <ul>
      <li>Line: <b>#offender.line#</b></li>
      <li>Template: <b>#offender.template#</b></li>
      <li>Code: <pre>#offender.codePrintHTML#</pre></li>
    </ul>
  </p>

  <br/>
  <br/>

  #thisTagContext#
</cfoutput>

<hr>

<cfdump var=#request#>