<!-- views/common/func/msg -->
<cfparam name="rc.message" default="#ArrayNew(1)#">

<!--- display any messages to the user --->
<cfif not ArrayIsEmpty(rc.message)>
  <cfloop array="#rc.message#" index="msg">
    <cfoutput><p>#msg#</p></cfoutput>
  </cfloop>
</cfif>