<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>

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

        $(document).ready(function()
        {

            var cycle = $("#idCycle").val();


            $(".repay").click(function(){

               if (confirm('Are you sure to repeat all rewards payments for cycle ' + cycle  + '?\nThis cannot be undone!'))
               {
                  // Turn button inactive.
                  $("#btnRepay").attr("disabled", true);

                  // Calls Coldfusion method to save to local database.
                  $.get('bp_proxy.cfm?repay=true&cycle=' + cycle);

                  alert('Order to repeat payments was sent. Wait some minutes and check blockchain for results.');
               }
               else
               {
                  alert('Operation cancelled!');
               }
            });
        });

      </script>

   </head>

   <body>
      <section class="box-content-rewards">
         <cfoutput>
     
         <h1 class="title-baker">
            Advanced
         </h1>                

         <!--- Check if all data were fetched from TzScan --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            <cfif #settings.mode# NEQ "off">

               <cfif #settings.status# EQ true>
                  <!--- Get baker's rewards from TzScan and store them in memory cache ---> 
                  <cfinvoke component="components.tzscan" method="getRewards" bakerID="#application.bakerId#" returnVariable="rewards">

                  <!--- Get the current delivered reward cycle according to the network --->
                  <cfinvoke component="components.tzscan" method="getLastRewardsDeliveryCycle" rewards="#rewards#" 
                           returnVariable="lastRewardsDeliveryCycle">

		       <cfset reload = false>
                       
                       <br>
                       In this section there are tools to trigger advanced operations. Pay special attention and use it with great care.<br>
                       All actions will show a confirmation prompt after pressing the operation button, for safety.<br>
                       <br>
                       After use, wait at least 30 minutes and check blockchain for results.
                       <br>
                       <br>
                       <br>


                       <cfform name="form" action="advanced.cfm" method="post">
                          Repeat all payments for reward-delivered cycle (#lastRewardsDeliveryCycle#): &nbsp;&nbsp;
                          <input type="hidden" id="idCycle" value="#lastRewardsDeliveryCycle#">
                          <input type="button" class="repay" id="btnRepay" value="REPAY">
                       </cfform>




                <cfelse>
                   <br><br><br><br><br><br>
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

