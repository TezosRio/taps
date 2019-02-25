<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reload = true>

<cfset address="">
<cfset fee="">
<cfset saveIt="0">
<cfset updateFeeResult = false>

<cfif #isDefined('form.address')#>
   <cfset address="#form.address#">
</cfif>
<cfif #isDefined('form.fee')#>
   <cfset fee="#form.fee#">
</cfif>
<cfif #isDefined('form.saveit')#>
   <cfset saveIt="#form.saveit#">
</cfif>

<cfif #int(saveIt)# EQ "1">
   <!--- Save changed fee for specified address --->
   <cfinvoke component="components.database" method="saveDelegatorFee" bakerId="#application.bakerId#" address="#address#" fee="#fee#" returnVariable="updateFeeResult">
</cfif>

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

         <h1>Fees</h1>

         <!--- Check if all data were fetched from TzScan --->
         <!--- Get settings --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
           <cfif #settings.mode# NEQ "off">
            <cfif #settings.status# EQ true>

               <!--- Get baker's rewards from TzScan and store them in memory cache ---> 
               <cfinvoke component="components.database" method="getDelegatorsFees" returnVariable="fees">

               <cfset reload = false>

               <cfform name="form" action="fees.cfm" method="post">
                  <table class="table table-taps-fees">
                     <thead class="head-table-taps">
                     <tr>
                        <th style="text-align:center;" scope="col">Delegator</th>
                        <th style="text-align:center;" scope="col">Fee</th>
                        <th style="text-align:center;" scope="col"></th>
                        <th style="text-align:center;" scope="col">&nbsp;</th>
                     </tr>
                     </thead>

                     <tbody>
                        <cfloop from="1" to="#fees.recordCount#" index="i"> 
                           <tr>
                              <td align="left">
                                 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 #fees.address[i]#
                              </td>

                              <td align="center" >
                                 <cfinput name="fee_#i#" id="#fees.address[i]#" value="#fees.fee[i]#" type="text" size="5">
                              </td>
                              <td align="center" >
                                 <image src="imgs/save.png" style="cursor:pointer;" onclick="sendForm(document.getElementById('#fees.address[i]#'));" />
                              </td>
                              <td style="align:left;width:20px;color:green;visibility:<cfif (#updateFeeResult# EQ true and #fees.address[i]# EQ #address#)> visible<cfelse>hidden</cfif>;">Updated</td>
                           </tr>
                        </cfloop>

                        <cfinput name="address" type="hidden" value="">
                        <cfinput name="fee" type="hidden" value="">
                        <cfinput name="saveit" type="hidden" value="0">
                     </tbody>
                  </table>
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

