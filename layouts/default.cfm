<cfsilent>
  <cfparam name="rc.cache" default=0 />
  <cfparam name="cachePath" default="C:\Workspace\development\ddcache">
  <cfif SERVER.os.name IS "Linux">
    <cfset cachePath = "/var/www/ddcache" />
  <cfelse>
  </cfif>
</cfsilent><cfif rc.cache AND getEnvironment() NEQ 'development'><cfcache action="optimal" 
      directory="#cachePath#" 
      timespan="#CreateTimeSpan( 1, 0, 0, 0 )#" 
      idletime="#CreateTimeSpan( 0, 12, 0, 0 )#"
      key="#getSectionAndItem()#"><cfinclude template="/includes/chunks/shell.cfm" /></cfcache><!-- layouts/default.cfm:1 --><cfelse><cfinclude template="/includes/chunks/shell.cfm" /><!-- layouts/default.cfm:0 --></cfif>