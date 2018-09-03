<!-- views/main/card (aliased to card.show) -->
<div class="top-buffer">

  <section>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          <div align="center">
            <h1>Featured Card</h1>
          </div>
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <div class="container">

      <div class="row">
        <div class="col-md-12">
          <hr>
        </div>
      </div>

      <div class="row">

        <cfif rc.card.getGenerated_Card_Id()>
          <cfoutput>
          <div class="col-md-12" id="card" align="center">
            #rc.fantabulous.getHTML( cardName="featured", hash=rc.card.getCode(), size="large", id="shell" )#
          </div>
          <div class="col-md-12">&nbsp;</div>
          <div class="col-md-12" align="center">
            <b>Code:</b> <span class="code">#ArrayToList(ReMatch(".{1,4}",UCase( rc.card.getCode() )),"-")#</span>
          </div>
          </cfoutput>
          <div class="col-md-12">&nbsp;</div>
          <div class="col-md-12" align="center">
            <button ng-click="snapCard()" class="btn btn-default"><i class="fas fa-cloud-download-alt"></i> Download</button>
          </div>
        <cfelse>
          Whoops! I couldn't find that card. Does it exist? (Maybe not!)
        </cfif>

      </div>

    </div>

  </section>

</div>