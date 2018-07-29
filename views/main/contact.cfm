<!-- views/main/contact -->

<div class="top-buffer">

  <section>

    <div class="container">
      <div class="row">

        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
          <div align="center">
            <h1>Reach out</h1>
            <h3>Got more questions? We're here to help. Use the options below to contact us.</h3>
          </div>
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">
      <div class="row">

        <div align="center">
          <div class="col-lg-4 col-md-4 col-sm-12 col-xs-12">
            <button class="btn button btn-default btn-tile" onClick="window.open('mailto:<cfoutput>#application.admin_email#</cfoutput>','_blank')">
              <i class="fas fas-large fa-at"></i>
              <br/><br/> E-mail
            </button>
          </div>
          <div class="col-lg-4 col-md-4 col-sm-12 col-xs-12">
            <button class="btn button btn-default btn-tile" onClick="location.href='https://forum.<cfoutput>#application.site_domain#</cfoutput>'">
              <i class="fab fas-large fa-discourse"></i>
              <br/><br/> Discussion
            </button>
          </div>
          <div class="col-lg-4 col-md-4 col-sm-12 col-xs-12">
            <button class="btn button btn-default btn-tile" onClick="window.open('https://twitter.com/<cfoutput>#replace(application.twitter.nick,'@','')#</cfoutput>','_blank')">
              <i class="fab fas-large fa-twitter"></i>
              <br/><br/> Twitter
            </button>
          </div>
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

  </section>

  <div>
    <br><br>
  </div>

  <cfoutput>#view('common/nav/footer')#</cfoutput>

</div>