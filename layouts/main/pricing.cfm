<!-- layouts/main/pricing.cfm -->
<cfsilent>
  <cfsavecontent variable="headContent">
    <link href="/assets/css/pricing.css" type="text/css" rel="stylesheet" />
  </cfsavecontent>
  <cfhtmlhead text="#headContent#">
</cfsilent>

<!-- we manually call the main/pricing view, as this entire sub-layout will be wrapped inside layouts/main.cfm.
  without this, FW/1 calls layouts/main/pricing, then defers to layouts/main.cfm, but never reaches views/pricing.cfm -->
<cfoutput>#view('main/pricing')#</cfoutput>
