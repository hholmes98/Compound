<!-- views/main/pricing -->
<cfsilent>
  <cfsavecontent variable="headContent">
    <link href="/assets/css/pricing.css" type="text/css" rel="stylesheet" />
  </cfsavecontent>
  <cfhtmlhead text="#headContent#">
</cfsilent>

<div id="generic_price_table">

  <section>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          <div class="price-heading clearfix">
            <h1>Priced For You</h1>
            <h3>Decimate your debt without decimating your wallet</h3>
          </div>
        </div>

      </div>
    </div>

    <div class="container">
      <div class="row">

        <!-- 1st pricing -->
        <div class="col-md-3">
          <div class="generic_content clearfix">
            <div class="generic_head_price clearfix">
              <div class="generic_head_content clearfix">
                <div class="head_bg"></div>
                <div class="head">
                  <span style="font-size:24px;">Penny-Pincher</span>
                </div>
              </div>
              <div class="generic_price_tag clearfix">
                <span class="price">
                  <!--- <span class="sign">$</span> --->
                  <span class="currency">FREE</span>
                  <!--- <span class="cent"></span> --->
                  <!--- <span class="month">/MON</span> --->
                </span>
              </div>
            </div>
            <div class="generic_feature_list">
              <ul>
                <!--- 1. Advertisements ---><li>Ads: shown</li>
                <!--- 2. No. of cards support ---><li>No. of cards: <span>unlimited</span></li>
                <!--- 3. Control over payoff strategy due dates ---><li>Payoff: calculated</li>
                <!--- 4. Control over reminders ---><li>Reminders: monthly</li>
                <!--- 5. How cards are prioritized during strategy calculation ---><li>Card priority: calculated</li>
                <!--- 6. 0% APR card support ---><li>0% APR support: none</li>
                <!--- 7. Support ---><li> Support: via Community</li>
                <!--- 8. BETA access ---><li> ~ </li>
              </ul>
            </div>
            <div class="generic_price_btn clearfix">
              <cfoutput><a href="#buildUrl('login.create')#">Sign up</a></cfoutput>
            </div>
          </div>
        </div>

        <!-- 2nd pricing -->
        <div class="col-md-3">
          <div class="generic_content clearfix">
            <div class="generic_head_price clearfix">
              <div class="generic_head_content clearfix">
                <div class="head_bg"></div>
                <div class="head">
                  <span>Ad Blocker</span>
                </div>
              </div>
              <div class="generic_price_tag clearfix">
                <span class="price">
                  <span class="sign">$</span>
                  <span class="currency">2</span>
                  <span class="cent">.99</span>
                  <span class="month">/MON</span>
                </span>
              </div>
            </div>
            <div class="generic_feature_list">
              <ul>
                <!--- 1. Advertisements ---><li>Ads:<span> disabled</span></li>
                <!--- 2. No. of cards support ---><li>No. of cards: <span>unlimited</span></li>
                <!--- 3. Control over payoff strategy due dates ---><li>Payoff: calculated</li>
                <!--- 4. Control over reminders ---><li>Reminders: monthly</li>
                <!--- 5. How cards are prioritized during strategy calculation ---><li>Card priority: calculated</li>
                <!--- 6. 0% APR card support ---><li>0% APR support: none</li>
                <!--- 7. Support ---><li> Support: via Community </li>
                <!--- 8. BETA access ---><li> ~ </li>
              </ul>
            </div>
            <div class="generic_price_btn clearfix">
              <cfoutput><a href="#buildUrl( action = 'login.create', queryString = { "at_id" = 2 } )#">Sign up</a></cfoutput>
            </div>
          </div>
        </div>

        <!-- 3rd pricing -->
        <div class="col-md-3">
          <div class="generic_content active clearfix">
            <div class="generic_head_price clearfix">
              <div class="generic_head_content clearfix">
                <div class="head_bg"></div>
                <div class="head">
                  <span>Budgeter</span>
                </div>
              </div>
              <div class="generic_price_tag clearfix">
                <span class="price">
                  <span class="sign">$</span>
                  <span class="currency">5</span>
                  <span class="cent">.99</span>
                  <span class="month">/MON</span>
                </span>
              </div>
            </div>
            <div class="generic_feature_list">
              <ul>
                <!--- 1. Advertisements ---><li>Ads:<span> disabled</span></li>
                <!--- 2. No. of cards support ---><li>No. of cards: <span>unlimited</span></li>
                <!--- 3. Control over payoff strategy due dates ---><li>Payoff: <span>customizable</span></li>
                <!--- 4. Control over reminders ---><li>Reminders: <span>customizable</span></li>
                <!--- 5. How cards are prioritized during strategy calculation ---><li>Card priority: calculated</li>
                <!--- 6. 0% APR card support ---><li>0% APR support: none</li>
                <!--- 7. Support ---><li> Support: via Community </li>
                <!--- 8. BETA access ---><li> ~ </li>
              </ul>
            </div>
            <div class="generic_price_btn clearfix">
              <cfoutput><a href="#buildUrl( action = 'login.create', queryString = { "at_id" = 3 } )#">Sign up</a></cfoutput>
            </div>
          </div>
        </div>

        <!-- 4th pricing -->
        <div class="col-md-3">
          <div class="generic_content clearfix">
            <div class="generic_head_price clearfix">
              <div class="generic_head_content clearfix">
                <div class="head_bg"></div>
                <div class="head">
                  <span>Life Hacker</span>
                </div>
              </div>
              <div class="generic_price_tag clearfix">
                <span class="price">
                  <span class="sign">$</span>
                  <span class="currency">14</span>
                  <span class="cent">.99</span>
                  <span class="month">/MON</span>
                </span>
              </div>
            </div>
            <div class="generic_feature_list">
              <ul>
                <!--- 1. Advertisements ---><li>Ads:<span> disabled</span></li>
                <!--- 2. No. of cards support ---><li>No. of cards: <span>unlimited</span></li>
                <!--- 3. Control over payoff strategy due dates ---><li>Payoff: <span>customizable</span></li>
                <!--- 4. Control over reminders ---><li>Reminders: <span>customizable</span></li>
                <!--- 5. How cards are prioritized during strategy calculation ---><li>Card priority: <span>customizable</span></li>
                <!--- 6. 0% APR card support ---><li> 0% APR support: <span>enabled</span> </li>
                <!--- 7. Support ---><li> Support: <span>Premiere</span></li>
                <!--- 8. BETA access ---><li> <span><strong>BETA access:</strong> granted</span></li>
              </ul>
            </div>
            <div class="generic_price_btn clearfix">
              <cfoutput><a href="#buildUrl( action = 'login.create', queryString = { "at_id" = 4 } )#">Sign up</a></cfoutput>
            </div>
          </div>
        </div>

      </div><!-- // row -->
    </div><!-- // container -->

  </section>

</div>

<div>

  <div>
    <br><br>&nbsp;
  </div>

  <section>

    <div class="container">
      <div class="row">

        <div class="col-md-12">
          Pay for the features you want. Cancel any time. Switch between differerent plans. You can even go from free to paid and back to free
          again. Your account data remains intact, regardless of plan, and you can export your data anytime you want.
        </div>

      </div>
    </div>

    <div>
      &nbsp;<br><br><br>
    </div>

  </section>

  <cfoutput>#view('common/nav/footer')#</cfoutput>

</div>