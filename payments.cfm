<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset totalSum = 0>
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

   </head>

   <body>
      <section class="box-content-rewards">
         <cfoutput>

         <h1 class="title-baker">
           Delegators Payments
         </h1>                
  
         <!--- Check if all data were fetched from TzScan --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            <cfif #settings.status# EQ true>

               <cfset reload = false>

               <!--- Get delegators payments from local database ---> 
               <cfinvoke component="components.database" method="getDelegatorsPayments" returnVariable="delegatorsPayments">

               <!--- Get last paid cycle --->
               <cfquery name="cycles_paid" dbtype="query">
                  select max(cycle) as last_paid_cycle
                  from delegatorsPayments
               </cfquery>
 
               <cfif #delegatorsPayments.recordCount# GT 0>
                  <cfform name="form" action="payments.cfm" method="post">
                     <table class="table table-taps-rewards">
                     <thead class="head-table-taps">
                        <tr>
                           <th style="text-align:center;" scope="col">Cycle</th>
                           <th style="text-align:center;" scope="col">Address</th>
                           <th style="text-align:center;" scope="col">Date</th>
                           <th style="text-align:center;" scope="col">Result</th>
                           <th style="text-align:center;" scope="col">Total</th>
                        </tr>
                     </thead>

                     <tbody>

		        <cfloop from="1" to="#delegatorsPayments.recordCount#" index="i"> 
		           <tr>
		              <td align="center" >#delegatorsPayments.cycle[i]#</td>
		              <td align="center" >#delegatorsPayments.address[i]#</td>
		              <td align="center" >#DateFormat(delegatorsPayments.date[i], 'MM/DD/YYYY')#</td>
		              <td align="center" >#delegatorsPayments.result[i]#</td>
		              <td align="center" >#LSNumberFormat(delegatorsPayments.total[i], '999,999,999,999.99')#&nbsp;#application.tz#</td>
                              <cfset totalSum = totalSum + #delegatorsPayments.total[i]#>
		             
		           </tr>
		        </cfloop>
                        <tr>
                           <td></td>
                           <td align="left">Total Sum</td>
                           <td></td>
                           <td align="center"></td>
		           <td align="center" >#LSNumberFormat(totalSum, '999,999,999,999.99')#&nbsp;#application.tz#</td>
                        </tr>
                        <tr>
                           <td></td>
                           <td></td>
                           <td></td>
                           <td align="center" valign="middle"><image src="imgs/pdf.jpg" style="cursor:pointer;" width="45" valign="middle" onclick="javascript:window.open('report_delegate_payments.cfm?myCycle=#cycles_paid.last_paid_cycle#');"><br><span style="font-size:small;">Last paid</span></td>
                           <td align="center" valign="middle"><image src="imgs/pdf.jpg" style="cursor:pointer;" width="45" valign="middle" onclick="javascript:window.open('report_delegate_payments.cfm');"><br><span style="font-size:small;">All cycles</span></td>
                        </tr>
		        <cfinput name="address" type="hidden" value="">
		        <cfinput name="fee" type="hidden" value="">
 		        <cfinput name="saveit" type="hidden" value="0"> 
		     </table>
		  </cfform>

               <cfelse>
                  <br>
                  Until now, no delegators payments have been registered on local database.<br>
                  Please wait until the next cycle for this information to be available.
               </cfif>  
                    
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
