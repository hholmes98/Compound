<!-- views/common/nav/footer -->
<cfsilent>
  <cfparam name="get_started" default="inner" />
  <cfif get_started is 'home'>
    <cfsavecontent variable="scrollUp">
      <script>
      $(document).ready( function() {

        $('#returnTop').on('click', function() {
          $('html,body').animate({
            scrollTop: 0
          }, 'slow');
        });

      });
      </script>
    </cfsavecontent>
    <cfhtmlhead text="#scrollUp#">
  </cfif>
</cfsilent>
<section dir="ltr" class="footer">
  <div class="section-inner">
    <cfoutput>
    <h3>#application.locale[session.auth.locale]['name']#</h3>
    <h3>#application.locale[session.auth.locale]['motto']#</h3>
    </cfoutput>
    <cfif get_started is 'home'>
      <button class="btn btn-default" id="returnTop"> Get started</button>
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
      <div class="top-buffer">
        &nbsp;
      </div>
      <div id="colophon" class="top-buffer">
        &copy; 2018 <a href="https://firehosefountain.com" target="_blank">Firehose Fountain, LLC</a>, all rights reserved.<br/>
        Debt Decimator, the stylized calculator logo, and all content herein are trademarks  of Firehose Fountain.<br/>
        <a href="https://www.youtube.com/watch?v=Xe1TZaElTAs" target="_blank">Built with love, Internet style</a> | <a href="javascript:void(0)" ng-click="skin=(skin==1?2:1);updateSkin(skin)"><i class="fas fa-sun"></i><i class="fas fa-moon"></i></a>
      </div>
    </footer>
  </div>
</section>