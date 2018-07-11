<cfsilent>
  <cfscript>
  function canShowAds() {
    var showAds = true; // we always show adverts, unless...

    // ...a section specifically shouldn't
    if ( ListFindNoCase( 'login', getSection() ) )
      showAds = false;

    // ...a logged in user has a paid account
    if ( session.auth.isLoggedIn ) {
      if ( session.auth.user.getAccount_Type().getAccount_Type_Id() > 1 )
        showAds = false;
    }

    return showAds;
  }
  </cfscript>

  <cfif canShowAds()>
    <cfsavecontent variable="jsBlocker">
    <script>
    window.onload = function() {
      setTimeout(function() {
        var ad = document.querySelector("ins.adsbygoogle");
        if (ad && ad.innerHTML.replace(/\s/g, "").length == 0) {
          ad.style.cssText = 'display:block !important'; 
          ad.parentNode.innerHTML += '<div style="padding:5px; background-color:#171717; border:1px solid #fff; margin:5px 5px 10px 5px; display:inline-block; text-align:left; position: absolute; top: 0px; left: 0px;"><cfoutput>#application.ad_blocker#</cfoutput></div>';
        }
      }, 1000);
    };
    </script>
    </cfsavecontent>
    <cfhtmlhead text="#jsBlocker#" />
  </cfif>
</cfsilent>

<!-- views/common/banner.cfm -->
<cfif canShowAds()>
<div id="top-banner">
  
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- DD_Responsive -->
<ins class="adsbygoogle DD-Jackson"
     style="display:inline-block;"
     data-ad-client="ca-pub-6158111396863200"
     data-ad-slot="5857880855"
     ></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
  
</div>
</cfif>