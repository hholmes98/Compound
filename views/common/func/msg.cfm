<!-- views/common/func/msg -->
<cfparam name="rc.message" default="#ArrayNew(1)#" />
<cfparam name="alert_class" default="alert-success" />
<cfparam name="pad_top" default="true" />
<cfparam name="pad_bottom" default="false" />

<!--- display any messages to the user --->
<cfif not ArrayIsEmpty(rc.message)>

  <cfif pad_top>
    <div class="row">
      <br/>
    </div>
  </cfif>

  <div class="row">
    <cfoutput>

    <div class="col-md-2"></div>

    <div class="col-md-8">
      <div class="alert #alert_class# alert-dismissible fade in" role="alert">
      <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <cfloop array="#rc.message#" index="msg">
          <p>#msg#</p>
        </cfloop>
      </div>
    </div>

    <div class="col-md-2"></div>

    </cfoutput>
  </div>

  <cfif pad_bottom>
    <div class="row">
      <br/>
    </div>
  </cfif>

</cfif>