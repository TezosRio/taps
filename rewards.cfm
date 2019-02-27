<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>

<!--- Get the pending rewards cycle that is registered in current local database --->
<cfinvoke component="components.database" method="getLocalPendingRewardsCycle" returnVariable="localPendingRewardsCycle">

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
         var reload = true;
      </script>

   </head>

   <body>
      <section class="box-content-rewards">
         <cfoutput>
     
         <h1 class="title-baker">
            Rewards
         </h1>                

         <!--- Check if all data were fetched from TzScan --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            <cfif #settings.status# EQ true>

               <cfset reload = false>

               <!--- Get baker's rewards from TzScan and store them in memory cache ---> 
               <cfinvoke component="components.tzscan" method="getRewards" bakerID="#application.bakerId#" returnVariable="rewards">

                  <table class="table table-taps-rewards">
                     <thead class="head-table-taps">
                        <tr>
                           <th style="text-align:center;" scope="col">Cycle Number</th>
                           <th style="text-align:center;" scope="col">Rewards Status</th>
                        </tr>
                     </thead>

                     <tbody>

        	       <cfloop from="#rewards.recordCount#" to="1" step="-1" index="i">  
	                 <tr>
	                    <td align="center" style="background-color:<cfif #rewards.status[i]# EQ "rewards_delivered">##dff0d8<cfelseif #rewards.status[i]# EQ "rewards_pending"><cfif #rewards.cycle[i]# NEQ #localPendingRewardsCycle#>##fcf8e3<cfelse>##fcc3c3</cfif><cfelseif #rewards.status[i]# EQ "cycle_in_progress">##d9edf7<cfelseif #rewards.status[i]# EQ "cycle_pending">##f0f0f0</cfif>">#rewards.cycle[i]#</td>
	                    <td align="center" style="background-color:<cfif #rewards.status[i]# EQ "rewards_delivered">##dff0d8<cfelseif #rewards.status[i]# EQ "rewards_pending"><cfif #rewards.cycle[i]# NEQ #localPendingRewardsCycle#>##fcf8e3<cfelse>##fcc3c3</cfif><cfelseif #rewards.status[i]# EQ "cycle_in_progress">##d9edf7<cfelseif #rewards.status[i]# EQ "cycle_pending">##f0f0f0</cfif>">#rewards.status[i]#</td>
	                </tr>
	              </cfloop>
                     </tbody>
	           </table>

            <cfelse>
               <br><br><br><br><br><br>
               <table width="100%">
                  <tr><td align="center"><img src="imgs/spin.gif" width="50" height="50"><br></td></tr>
                  <tr style="line-height:30px;text-align:center;"><td align="center">Fetching... Please wait</td></tr>
               </table>
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

