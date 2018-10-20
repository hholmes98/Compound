<!--- views/login/subscribe --->
<div class="row">

  <div class="col-md-4 col-md-offset-4">

  <div class="panel-heading">
    <div class="panel-title">
      <cfoutput><h2 shadow-text="#application.locale[session.auth.locale]['name']# is in Private Beta">#application.locale[session.auth.locale]['name']# is in Private Beta</h2></cfoutput>
    </div>
  </div>

  <div class="main-login main-center">

    <div>
      <p>
        Fill out the information below and we'll add you to the Debt Decimator mailing list, so you'll be the <strong>first</strong> to know when <strong>Debt Decimator launches!</strong>
      </p>
      <br/>
    </div>

    <!-- Begin Mailchimp Signup Form -->
    <div id="mc_embed_signup">
      <form action="https://debtdecimator.us19.list-manage.com/subscribe/post?u=712b3769ed72f9b19d5f43665&amp;id=e18cf25968" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" class="validate" target="_blank" novalidate>
        <div id="mc_embed_signup_scroll">
          <input type="text" value="" name="NAME" class="required name form-control" id="mce-NAME" placeholder="What should we call you?">
        </div>
        <br/>
        <div class="mc-field-group">
          <input type="email" value="" name="EMAIL" class="required email form-control" id="mce-EMAIL" placeholder="What's your email address?">
        </div>
        <div id="mce-responses" class="clear">
          <div class="response" id="mce-error-response" style="display:none"></div>
          <div class="response" id="mce-success-response" style="display:none"></div>
        </div>
        <!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
        <div style="position: absolute; left: -5000px;" aria-hidden="true">
          <input type="text" name="b_712b3769ed72f9b19d5f43665_e18cf25968" tabindex="-1" value="">
        </div>
        <br/>
        <div class="clear form-group sub-main-center">
          <button type="submit" name="subscribe" id="mc-embedded-subscribe" class="btn btn-default btn-lg">Subscribe</button>
        </div>
      </form>
    </div>
    <!--End mc_embed_signup-->

  </div>

</div>