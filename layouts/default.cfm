<cfsilent><cfparam name="rc.cache" default=0 /></cfsilent><cfif rc.cache><cfcache action="optimal" 
      directory="C:\Workspace\development\ddcache" 
      timespan="#CreateTimeSpan( 1, 0, 0, 0 )#" 
      idletime="#CreateTimeSpan( 0, 12, 0, 0 )#"
      key="#getSectionAndItem()#"><cfinclude template="/includes/chunks/shell.cfm" /></cfcache><!-- layouts/default.cfm:1 --><cfelse><cfinclude template="/includes/chunks/shell.cfm" /><!-- layouts/default.cfm:0 --></cfif>