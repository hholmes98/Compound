<!-- layouts/debt.cfm :: all debt.* actions use this -->
<body ng-controller="ddDebt">
<cfoutput>#view('common/nav/loggedout')#</cfoutput>
<cfoutput>#view('common/banner')#</cfoutput>

<div id="pan-main" class="pan-perspective">
  <cfoutput>
    #view('common/func/msg')#

    #body#
  </cfoutput>
</div>

<!-- needs to run at </body> -->
<script src="/assets/js/dd-animatePage.js"></script>
<script src="/assets/js/dd-bb.js"></script>
<script src="/assets/js/dd-controller.js"></script>

</body>