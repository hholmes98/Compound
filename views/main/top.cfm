<!--- // views/main/top --->

<cfoutput query="rc.codes">
#rc.fantabulous.getHTML( cardName="temp" & rc.codes.currentRow, cardClass="temp" & rc.codes.currentRow, hash=rc.codes.code[rc.codes.currentRow] )#
<br/>
<br/>
</cfoutput>