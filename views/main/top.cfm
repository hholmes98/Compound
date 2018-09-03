<!--- // views/main/top --->
<div class="top-buffer">

  <section>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          <div align="center">
            <h1>Give These Cards Some Credit</h1>
            <h3>The most popular card designs, so say the users of <cfoutput>#application.locale[session.auth.locale]['name']#</cfoutput></h3>
          </div>
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

    <cfoutput query="rc.codes">
    <div class="container">

      <div class="row">
        <div class="col-md-12">
          <hr>
        </div>
      </div>

      <div class="row">

        <div class="col-md-12">
          #rc.fantabulous.getHTML( cardName="temp" & rc.codes.currentRow, cardClass="temp" & rc.codes.currentRow, hash=rc.codes.code[rc.codes.currentRow] )#<br>
          <b>Code:</b> <span class="code">#LCase(rc.codes.code[rc.codes.currentRow])#</span>
          <br/>
          <br/>
        </div>

      </div>

    </div>
    </cfoutput>

  </section>

</div>