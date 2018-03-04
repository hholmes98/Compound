<!-- views/profile/advanced -->
<h2 shadow-text="Account Information">Account Information</h2>
<div role="form">
  <cfoutput>
  <span>
    <button class="btn button btn-default" onClick="location.href='#buildUrl('profile.basic')#';"><span class="glyphicon glyphicon-cog"></span> User Settings</button>
    <button class="btn button btn-default pull-right" onClick="location.href='#buildUrl('login.logout')#';"> Logout</button>
  </span>
  </cfoutput>
</div>

<!-- Billing -->
<div class="strike">
  <span><h3>Billing</h3></span>
</div>

Coming Soon (NYI)

<!---
<div class="table"> 
  <table class="table table-bordered">
    <tbody>
      <tr>
        <td>Plan</td>
        <td><cfoutput><strong>#session.auth.user.getAccount_Type().getName()#</strong></cfoutput></td>
        <td></td>
      </tr>
      <tr>
        <td>Payment</td>
        <td><span class="glyphicon glyphicon-credit-card"></span> <strong>American Express 3*** ***** *2003</strong> Expiration: <strong>10/2021</strong></td>
        <td><cfoutput><button class="btn button btn-default" onClick="location.href='#buildUrl('profile.payment')#';"><span class="glyphicon glyphicon-credit-card"></span> Update payment method</button></cfoutput></td>
      </tr>
      <tr>
        <td>Coupon</td>
        <td>You don't have an active coupon.</td>
        <td><cfoutput><button class="btn button btn-default" onClick="location.href='#buildUrl('profile.coupon')#';"><span class="glyphicon glyphicon-gift"></span> Redeem a coupon</button></cfoutput></td>
      </tr>
      <!---
      <tr>
        <td>Extra Info (?)</td>
        <td>You have not added any additional information to your receipts.</td>
        <td><button class="btn button btn-default"><span class="glyphicon glyphicon-plus"></span> Add Information</button></td>
      </tr>
      --->
    </tbody>
  </table>
</div>

<!-- Payment History -->
<div class="strike">
  <span><h3>Payment History</h3></span>
</div>

<div class="table"> 
  <table class="table table-striped">
    <thead>
      <tr>
        <th>&nbsp;</th>
        <th>ID</th>
        <th>Date</th>
        <th>Payment Method</th>
        <th>Amount</th>
        <th>Receipt</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><span class="glyphicon glyphicon-ok"></span></td>
        <td>67118Z72</td>
        <td>2017-12-24</td>
        <td><span class="glyphicon glyphicon-credit-card"></span> American Express ending in 2003</td>
        <td>$1.99</td>
        <td><a href="#buildUrl('receipt.download')#"><span class="glyphicon glyphicon-floppy-save"></span></a></td>
      </tr>
      <tr>
        <td><span class="glyphicon glyphicon-ok"></span></td>
        <td>67118Z71</td>
        <td>2017-11-24</td>
        <td><span class="glyphicon glyphicon-credit-card"></span> American Express ending in 2003</td>
        <td>$1.99</td>
        <td><a href="#buildUrl('receipt.download')#"><span class="glyphicon glyphicon-floppy-save"></span></a></td>
      </tr>
      <tr>
        <td><span class="glyphicon glyphicon-ok"></span></td>
        <td>67118Z70</td>
        <td>2017-10-24</td>
        <td><span class="glyphicon glyphicon-credit-card"></span> American Express ending in 2003</td>
        <td>$1.99</td>
        <td><a href="#buildUrl('receipt.download')#"><span class="glyphicon glyphicon-floppy-save"></span></a></td>
      </tr>
      <tr class="warning text-muted">
        <td><span class="glyphicon glyphicon-remove"></span></td>
        <td>67118Z70</td>
        <td>2017-10-24</td>
        <td><span class="glyphicon glyphicon-credit-card"></span> American Express ending in 2003</td>
        <td>$1.99</td>
        <td>&nbsp;</td>
      </tr>
    </tbody>
  </table>
</div>
--->