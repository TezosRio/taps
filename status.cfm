<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset statusValue="">
<cfset updateResult="">

<cfif isDefined("form.statusValue")>
   <cfset statusValue="#form.statusValue#">
<cfelse>
   <cfset statusValue="">
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
	   function validate()
	   {
              var selectedOption = document.getElementById('idStatus').value;

              if (selectedOption == '0')
              {
                 if (confirm('Do you really want to turn OFF?'))
	            return true;
              }
              else if (selectedOption == '1')
              {
                 if (confirm('Configure taps to SIMULATION mode?'))
	            return true;
              }
              else if (selectedOption == '2')
              {
                 if (confirm('This will turn taps ON and do real rewards payments. Are you sure?'))
	            return true;
              }

              return false;
	   }
      </script>

	<style>
           a, a:active, a:focus, a:hover, input, input:focus { outline: none; !important; }

           .nooutline, .nooutline:focus { outline: none; !important; }
	</style>

   </head>

   <body>
      <section class="box-content-rewards">
      <div  style="width:550px;">
         <cfoutput>

         <h1 class="title-baker">
           Status
         </h1>                

         <br>

         <!--- Get settings from configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings"> 

         <cfif #settings.recordCount# GT 0>

            <cfif #statusValue# EQ "">
               <cfinvoke component="components.database" method="getStatusValue" description="#settings.mode#" returnVariable="statusValue">
            <cfelse>        
               <!--- Save the new status mode --->
               <cfinvoke component="components.database" method="setStatusMode" bakerId="#application.bakerId#" statusValue="#statusValue#" returnVariable="updateResult">
            </cfif>

            <div style="text-align: justify;text-justify: inter-word;">
            TAPS starts in <span style="font-weight:bold;">Simulation</span> mode, which means it will fetch information from TzScan
            in a frequent basis, but it will NOT make real rewards payments to delegators.
            If mode is set to <span style="font-weight:bold;">Off</span>, it will not fetch TzScan at all.
            When TAPS is set to <span style="font-weight:bold;">On</span>, it will fetch TzScan in a frequent basis an when it detects
            a cycle change, it will make REAL rewards payments to delegators, according to their shares,
            based on information obtained from the Tezos blockchain.<br><br>
            </div>

            <br>
            <cfform name="form" action="status.cfm" method="post">
               <table>
                  <tr style="outline:none; !important;">
                     <td align="right">
                        <label><span class="text-input-taps" style="color:black;" onClick="document.getElementById('idStatus').value='#application.mode_no#';">Off</span></label>
                     </td>
                     <td style="outline:none; !important;"><input type="range" id="idStatus" name="statusValue" min="0" max="2" value="#statusValue#" step="1" style="width:300px;outline: none; !important;" class="nooutline"></td>
                     <td align="left">
                        <label>&nbsp;<span class="text-input-taps" style="color:red;" onClick="document.getElementById('idStatus').value='#application.mode_yes#';">On</span></label>
                     </td>
                     <td>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <button type="button" class="botao-taps" onClick="if (validate()) { document.form.submit(); }">SAVE</button>
                     </td>
                  </tr>
                  <tr>
                     <td align="left" colspan="3">
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label><span class="text-input-taps" style="color:green;" onClick="document.getElementById('idStatus').value='#application.mode_try#';">Simulation</span></label>
                     </td>
                  </tr>
               </table>
            </cfform>

            <br><br>

            <cfif #updateResult# EQ "true">
               <script language="javascript">alert('Status updated successfully');</script>
            <cfelseif #updateResult# EQ "false">
               <script language="javascript">alert('Could not update status, please try again');</script>
            </cfif>

         <cfelse>

            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>

         </cfif>

      </cfoutput>
   </div>
</section>
</body>
</html>
