<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>

<!--- Get the pending rewards cycle that is registered in current local database --->
<cfinvoke component="components.database" method="getLocalPendingRewardsCycle" returnVariable="localPendingRewardsCycle">

<cfset totalSum = 0>
<cfset totalRewards = 0>
<cfset totalActual = 0>

<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
      <meta http-equiv="cache-control" content="no-cache">

      <!-- CSS Bootstrap-->
      <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"> 
      <!-- CSS Page-->
      <link rel="stylesheet" type="text/css" href="css/estilo.css">

      <script src="js/jquery-3.2.1.min.js"></script>

    <script language="javascript">
     function sendForm(field)
     {
        document.form.address.value = field.id;
        document.form.fee.value = field.value;
        document.form.saveit.value = '1';

        document.form.submit();
      }
    </script>
   </head>

   <body>
      <section class="box-content-rewards">
         <cfoutput>

      <h1>Delegators</h1>
      <h4>(in rewards-pending cycle #localPendingRewardsCycle#)</h4>

         <!--- Check if all data were fetched --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
          <cfif #settings.mode# NEQ "off">
            <cfif #settings.status# EQ true>

               <cfset reload = false>

               <!--- Get baker's rewards and store them in memory cache ---> 
               <cfinvoke component="components.tezosGateway" method="getRewards" bakerID="#application.bakerId#" returnVariable="rewards">

               <!--- Get the current network pending rewards cycle ---> 
               <cfinvoke component="components.tezosGateway" method="getNetworkPendingRewardsCycle" returnVariable="networkPendingRewardsCycle" 
                         rewards="#rewards#">

               <!--- Get baker's delegators (and shares) for the last pending cycle (plus previous and next cycle) and store them in memory cache --->
               <cfinvoke component="components.tezosGateway" method="getDelegators" bakerID="#application.bakerId#"                     
                         fromCycle="#networkPendingRewardsCycle#" toCycle="#networkPendingRewardsCycle#" returnVariable="delegators">

                     <cfif #delegators.recordCount# GT 0>
                        <cfform name="form" action="delegators.cfm" method="post">
               	           <table class="table table-taps-alt">
                             <thead class="head-table-taps">
                                <tr>
                                   <th style="text-align:center;" scope="col"></th>
                                   <th style="text-align:center;" scope="col">Delegator</th>
                                   <th style="text-align:center;" scope="col">Balance</th>
                                   <th style="text-align:center;" scope="col">Share</th>
                                   <th style="text-align:center;" scope="col">Rewards</th>
                                   <th style="text-align:center;" scope="col">Fee</th>
                                   <th style="text-align:center;" scope="col">Actual</th>
                                </tr>
                              </thead>

                              <tbody>

                              <cfloop from="1" to="#delegators.recordCount#" index="i"> 
                                 <tr>
                                    <td align="center">#i#</td>
               		            <td align="left">#delegators.address[i]#</td>
               		            <td align="center">#LSNumberFormat((delegators.balance[i]) / application.militez, '999,999,999,999.00')#&nbsp;#application.tz#</td>
                       		    <td align="center">#numberFormat(delegators.share[i], '999.99')#%</td>
                       		    <td align="center">#delegators.rewards[i]#&nbsp;#application.tz#</td>

                                    <!--- Get delegator fee and calculate actual rewards --->
                                    <cfinvoke component="components.database" method="getDelegatorFee" address="#delegators.address[i]#" returnVariable="fee">

                                    <td align="center">#fee#%</td>
                                    <cfset actual=#LSNumberFormat(int(delegators.rewards[i] * ((100 - fee) / 100) * 100) / 100, '999,999,999,999.99')#>
                                    <td align="center">#actual#&nbsp;#application.tz#</td>
                                    <cfset totalSum = totalSum + #(delegators.balance[i] / application.militez)#>
                                    <cfset totalRewards = totalRewards + #delegators.rewards[i]#>
                                    <cfset totalActual = totalActual + #actual#>
                                 </tr>
                              </cfloop>

                              <tr>
                                 <td align="left" >Total</td>
                                 <td align="left"></td>
                                 <td align="center" >#LSNumberFormat(totalSum, '999,999,999,999.99')#&nbsp;#application.tz#</td>
                                 <td align="center" ></td>
               	 	         <td align="center" >#LSNumberFormat(totalRewards, '999,999,999,999.99')#&nbsp;#application.tz#</td>
                                 <td align="center">#LSNumberFormat((totalRewards - totalActual), '999,999,999,999.99')#&nbsp;#application.tz#</td>
                                 <td align="center">#LSNumberFormat(totalActual, '999,999,999,999.99')#&nbsp;#application.tz#</td>
                              </tr>

                              <cfinput name="address" type="hidden" value="">
                              <cfinput name="fee" type="hidden" value="">
                              <cfinput name="saveit" type="hidden" value="0">

                             </tbody>
                          </table>
                       </cfform>

                    <cfelse>
                       Until now, no delegators have been registered on local database.<br>
                       Please wait until the next cycle for this information to be available.
                    </cfif>

                 <cfelse>
                    <br><br><br><br><br>
                    <table width="100%">
                       <tr><td align="center"><img src="imgs/spin.gif" width="50" height="50"><br></td></tr>
                       <tr style="line-height:30px;text-align:center;"><td align="center">Fetching... Please wait</td></tr>
                    </table>
                 </cfif>

               <cfelse>
                  <br>
                  TAPS status is set to OFF.<br>
                  Please go to menu option STATUS and choose another option.<br>
               </cfif>     

            <cfelse>
               <br>
               There is no configuration saved on settings.<br>
               Please go to SETUP first.<br>
            </cfif>
  
      </cfoutput>
</section>

<cfif #reload# EQ true>
   <!---  Reload page until fetch completed --->
   <script language="javascript">
      setTimeout(function(){ location.reload(); }, 5000);
   </script>
</cfif>

</body>
</html>


