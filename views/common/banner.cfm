<!-- views/common/banner.cfm -->
<cfif (session.auth.IsLoggedIn AND session.auth.user.getAccount_Type().getAccount_Type_Id() EQ 1) OR (!session.auth.isLoggedIn)>
<div id="top-banner">
  
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- DD_Responsive -->
<ins class="adsbygoogle responsive_ad"
     style="display:inline-block;"
     data-ad-client="ca-pub-6215660586764867"
     data-ad-slot="9656584127"  
     ></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
  
</div>
</cfif>