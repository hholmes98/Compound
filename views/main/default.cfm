<!-- views/main/default -->
<cfsilent>
  <cfscript>
  /**
   * Returns the 2 character english text ordinal for numbers.
   * 
   * @param num      Number you wish to return the ordinal for. (Required)
   * @return Returns a string. 
   * @author Mark Andrachek (hallow@webmages.com) 
   * @version 1, November 5, 2003 
   */
  function GetOrdinal(num) {
    // if the right 2 digits are 11, 12, or 13, set num to them.
    // Otherwise we just want the digit in the one's place.
    var two=Right(num,2);
    var ordinal="";
    switch(two) {
         case "11": 
         case "12": 
         case "13": { num = two; break; }
         default: { num = Right(num,1); break; }
    }

    // 1st, 2nd, 3rd, everything else is "th"
    switch(num) {
         case "1": { ordinal = "st"; break; }
         case "2": { ordinal = "nd"; break; }
         case "3": { ordinal = "rd"; break; }
         default: { ordinal = "th"; break; }
    }

    // return the text.
    return ordinal;
  }
  </cfscript>

  <cfset get_started = 'home' />

  <cfset headArray = [
    'Keep ''em coming!',
    'Need more debt!',
    'You''re killing it! (and by "it" we mean "debt")',
    'Give us your cards!',
    'Somebody set you up the debt!'
  ] />

  <cfset messageArray = [
    'The average balance a person carries on a credit card is: $5,047. Let''s get that down to $0.',
    'Families with debt carry an average balance of: $15,654. It''s time to chip that away.',
    'People born between ''80-''84 carry approx. $5,689 more credit card debt than their parents, and $8,156 more than their grandparents.',
    'Credit card debt increased by nearly 8% in 2017. Let''s reverse that trend. Starting right now.',
    'But starting today, you''re paying it off. For great justice.'
  ] />
</cfsilent>

<div class="section fp-auto-height">

<form class="form-horizontal" name="entry" id="entry" method="post" action="<cfoutput>#buildUrl('main.calculate')#</cfoutput>">

<cfoutput>
<div id="page1" class="slide">

  <div class="container">

    <div class="col-md-12 main-login main-center" align="center">

      <div class="row">

        <div class="panel-heading">
          <div class="panel-title">
            <h1>#application.locale[session.auth.locale]['name']#</h1>
            <h3>Your Debt Payoff Assistant</h3>
          </div>
        </div>
        <font style="font-size: 30px; font-weight: 700;">
          <div class="header">
            <span>Tell us your debt.</span> <span>We'll tell you the rest.</span>
          </div>
          <div>
            Every payment.
          </div>
          <div>
            Every date.
          </div>
          <div>
            Until you're free.
          </div>
        </font>

      </div>

      <cfif !rc.demo_open>
        <div class="row" ng-show="!try">

          <div class="col-md-2"></div>
          <div class="col-md-8">
            <hr>
            <span>
              <button type="button" class="btn button btn-primary" ng-click="try=true" onClick="location.hash='##try/0'">
                <svg class="icon-dd-calculator">
                  <use xlink:href="/assets/img/icons.svg##icon-dd-calculator"></use>
                </svg> Try it now!
              </button>
            </span>
          </div>
          <div class="col-md-2"></div>

        </div>
      </cfif>

      <div class="row" ng-show="<cfif rc.demo_open>true<cfelse>try</cfif>">

        <div class="col-md-2"></div>
        <div class="col-md-8">

          <hr>

          <span class="help-block" id="budget-help-block"><strong>First:</strong> How much can you <b>afford</b>, each month, to apply towards <em>all</em> of your outstanding debt?</span>
          <div class="form-group form-group-lg">
            <label class="sr-only" for="budget">Monthly budget allocated to debt payoff (in dollars)</label>
            <div class="input-group">
              <div class="input-group-addon">$</div>
              <input class="form-control" type="text" id="budget" placeholder="(eg. 250.00)" name="budget" />
              <div class="input-group-addon"> per month.</div>
            </div>
          </div>
          <span>
            <button type="button" class="btn button btn-primary btn-more" ng-click="verifyBudget()"><span class="glyphicon glyphicon-circle-arrow-right"></span> Next: Enter Some Debt</button>
          </span>

        </div>
        <div class="col-md-2"></div>

      </div><!-- // row -->

      <div class="row top-buffer bottom-buffer">

        <div class="col-md-2"></div>
        <div class="col-md-8">
          <button type="button" class="btn button btn-link" ng-click="navigateTo('#buildUrl('login.default')#')"><span class="glyphicon glyphicon-exclamation-sign"></span> I already have an account</button>
        </div>
        <div class="col-md-2"></div>

      </div>

    </div><!-- // main-center -->

  </div><!-- // container -->

</div><!-- // page1 -->
</cfoutput>

<!-- the template for each card uses the 2nd page -->
<cfloop from="2" to="6" index="p">
<cfoutput>
<div id="page#p#" class="slide">

  <div class="container">

    <div class="card-content col-sm-12 main-login main-center" align="center">

      <div class="row">

        <div class="col-sm-2"></div>
        <div class="col-sm-8">

        <cfif p EQ 2>
          <h3>Debt.</h3>
        <cfelse>
          <h3>#headArray[p-1]#</h3>
        </cfif>

        <p>
        <cfif p EQ 2>
          A loan you owe the bank. A balance lingering on a credit card.<br/>
          We call them <font style="color:##D2691E;"><strong>cards</strong></font>, but it's all the same to the calculator.<br/>
          Just tell us how much you owe. We'll take it from here.
        <cfelse>
          <p>#messageArray[p-1]#</p>
        </cfif>
        </p>

        </div>
        <div class="col-sm-2"></div>

      </div>

      <div class="row">

        <div class="col-sm-2"></div>
        <div class="col-sm-8">

          <hr>

          <span class="help-block" id="credit-card-balance-help#Evaluate(p-1)#"><cfif p EQ 6><b>Last:</b><cfelse><b>Next:</b></cfif> Enter the remaining balance on one of your <font style="color:##D2691E;"><strong>cards</strong></font>.<br/><br/></span>
          <div class="form-group" align="left">
            <label for="credit-card-balance#Evaluate(p-1)#" class="col-sm-3 control-label">Balance:</label>
            <div class="col-sm-7">
              <div class="input-group">
                <span class="input-group-addon">$</span>
                <input class="form-control credit-card-balance" type="text" placeholder="(eg. 3,275.22)" name="credit-card-balance#Evaluate(p-1)#">
              </div>
            </div>
            <a href="javascript:void(0)" uib-tooltip-html="'Where do I specify interest rate? Due date? Minimum payment?<br/><br/>This demo uses defaults, but a full account will let you change all of that (and more)!'"><i class="far fa-question-circle"></i></a>
          </div>
          <input type="hidden" name="credit-card-label#Evaluate(p-1)#" value="The #Evaluate(p-1)##getOrdinal(Evaluate(p-1))# card">
          <!--- <div class="form-group" align="left">
            <label for="credit-card-label#Evaluate(p-1)#" class="col-sm-3 control-label">Give it a name:</label>
            <div class="col-sm-7">
              <input class="form-control credit-card-label" type="text" placeholder="(eg. WF checking atm card)" name="credit-card-label#Evaluate(p-1)#">
            </div>
          </div> --->
          <div class="form-group" align="left">
            <div class="col-sm-offset-3 col-sm-7">
              <cfif p LT 6>
                <button type="button" class="btn button btn-default btn-sm btn-more" ng-click="verifyCard(#Evaluate(p-1)#)"><span class="glyphicon glyphicon-plus"></span> Enter More Debt</button>
              </cfif>
            </div>
          </div>
          <br/>

        </div>
        <div class="col-sm-2"></div>

      </div><!-- // row -->

      <div class="row top-buffer bottom-buffer" align="center">

        <button type="button" class="btn button btn-primary btn-submit bottom-buffer" form="entry">
          <svg class="icon-dd-calculator">
            <use xlink:href="/assets/img/icons.svg##icon-dd-calculator"></use>
          </svg> Calculate the payoff
        </button>

      </div><!-- // row -->

    </div>

  </div>

</div>
</cfoutput>
</cfloop>

</form>

</div><!-- // section -->

<div class="about">

  <section dir="ltr" class="spreadsheetplus">
    <div class="section-inner">
      <div class="text">
        <h3>Spreadsheet + bill reminders = DEBT FREEDOM!</h3>
        <p>Take the power of a credit card spreadsheet and add it to the convenience of a bill management app. The result? Debt Decimator: a tool that not only <b>reminds you when to pay</b>, but tells you <b>how much to pay on each debt</b>.</p>
      </div>
      <span class="splash-icon spreadsheetplus-icon"></span>
    </div>
  </section>

  <section dir="ltr" class="hotcard">
    <div class="section-inner">
      <span class="splash-icon hotcard-icon"></span>
      <div class="text-other">
        <h3>Light your debt on fire.</h3>
        <p>No more guessing or "following your hunch" - the math is done for you. Debt Decimator's <b>hot card</b> tells you what card you should be currently paying off.</p>
      </div>
    </div>
  </section>

  <section dir="ltr" class="finishline">
    <div class="section-inner">
      <div class="text">
        <h3>A finish line you can pinpoint.</h3>
        <p>Finally, peace-of-mind and a plan for your debt-free future. Debt Decimator's payoff visualization allows you to <b>see the date every single debt will be paid off</b>, and the exact moment you'll live debt free.</p>
      </div>
      <span class="splash-icon finishline-icon"></span>
    </div>
  </section>

  <section dir="ltr" class="desktop-mobile">
    <div class="section-inner">
      <span class="splash-icon desktop-mobile-icon"></span>
      <div class="text-other">
        <h3>Access anywhere, via any device.</h3>
        <p>No need to download any apps. Debt Decimator's mobile compatibility allows you to <b>access via desktop or smartphone</b>, whichever you prefer.</p>
      </div>
    </div>
  </section>

  <section dir="ltr" class="security">
    <div class="section-inner">
      <div class="text">
        <h3>Your privacy, by design.</h3>
        <p>Works to reduce your your online risk. Debt Decimator's "Privacy First" design <b>doesn't connect to your bank accounts</b>, and <b>doesn't ask for information that isn't needed</b> to perform its calculations.</p>
      </div>
      <span class="splash-icon security-icon"></span>
    </div>
  </section>

  <cfoutput>#view('common/nav/footer')#</cfoutput>

</div>