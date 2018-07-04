<!-- views/common/nav/footer -->
<cfsilent>
  <cfparam name="get_started" default="inner" />
</cfsilent>
<section dir="ltr" class="footer">
  <div class="section-inner">
    <cfoutput>
    <h3>#application.locale[session.auth.locale]['name']#</h3>
    <h3>#application.locale[session.auth.locale]['motto']#</h3>
    </cfoutput>
    <cfif get_started is 'home'>
      <button class="btn btn-default" onClick="location.hash='#try'"> Get started</button>
    <cfelse>
      <cfoutput><button class="btn btn-default" onClick="location.href='#buildUrl('main')#'"> Get started</button></cfoutput>
    </cfif>
    <footer id="footer-sitemap">
      <div class="footer-container">
        <div class="sitemap">
          <div class="footer-column"></div>
          <div class="footer-column"></div>
          <div class="footer-column"></div>
        </div>
        <div class="footer-language-options">
          <h3>Site Language</h3>
          <ul>
            <li>English</li>
            <li>Spanish</li>
          </ul>
        </div>
      </div>
    </footer>
  </div>
</section>