<!-- views/payment/confirmed -->
<cfsilent>
  <cfparam name="rc.c" default="" />
  <cfparam name="rc.u" default="" />

  <cfscript>
  function valueOfPlan(code) {
    switch(arguments.code) {
      case "2":
        return "2.99";
        break;
      case "3":
        return "5.99";
        break;
      case "4":
        return "14.99";
        break;
      default:
        return "0.00";
        break;
    }
  }
  </cfscript>

  <cfset v = iif(Len(rc.c),de(rc.c),de(rc.u)) />

  <cfsavecontent variable="googleTracking">
    <script>
      <cfoutput>
  gtag('event', 'purchase', {
    "transaction_id": "#CreateUUID()#",
    "affiliation": "(self)",
    "value": '#valueOfPlan(v)#',
    "currency": "USD",
    "tax": 0,
    "shipping": 0,
    "items": [
      {
        "id": "#application.stripe_plans[v].id#",
        "name": "#application.stripe_plans[v].nickname#",
        "list_name": "Search Results",
        "brand": "Debt Decimator",
        "category": "Paid Subscription",
        "variant": "Plan",
        "list_position": 1,
        "quantity": 1,
        "price": '#valueOfPlan(v)#'
      }
    ]
  });
      </cfoutput>
    </script>
  </cfsavecontent>
</cfsilent>

Payment Confirmed!

No more guessing what you should pay and when!

We'll take it from here!

<cfoutput>#googleTracking#</cfoutput>