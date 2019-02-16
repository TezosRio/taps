<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset reset="no">
<cfset passdw="">
<cfset passdw2="">
<cfset resultReset=false>

<cfif #isDefined('form.reset')#>
   <cfset reset="#form.reset#">
</cfif>
<cfif #isDefined('form.passdw')#>
   <cfset passdw="#form.passdw#">
</cfif>
<cfif #isDefined('form.passdw2')#>
   <cfset passdw2="#form.passdw2#">
</cfif>

<cfif reset EQ "yes">
   <cfinvoke component="components.taps" method="resetTaps" user="#application.user#" passdw="#passdw#" passdw2="#passdw2#" returnVariable="resultReset">
<cfelse>
   <cfset resultReset=false>
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

	      if (document.getElementById('idPassdw').value == '')
	      {
	         return false;
	      }

	      if (document.getElementById('idPassdw2').value == '')
	      {
	         return false;
	      }
	      
	      if (document.getElementById('idPassdw').value != document.getElementById('idPassdw2').value)
	      {
	         return false;
	      }

              if (!confirm('This will do a factory reset and erase all data. Do you really want to RESET taps?'))
	         return false;


	      return true;
	   }

	   function showError()
	   {
	      document.getElementById('idError').style.visibility = "visible";
	      document.getElementById('idPassdw').focus();
	   }

	   function hideError()
	   {
	      document.getElementById('idError').style.visibility = "hidden";
	      document.getElementById('idAuthError').style.visibility = "hidden";
	   }

      </script>

	<style>
	   .required
	   {
	      align:right;
	      color:red;
	      visibility:hidden;
	      border:hidden;
	      cursor:default;
              vertical-align: top;
              line-height: 20px;
              padding-bottom: 15px;
	   }
	</style>

   </head>

   <body>
      <section class="box-content-rewards">
      <div  style="width:550px;">
         <cfoutput>

         <h1 class="title-baker">
           Reset TAPS
         </h1>                
  
         <!--- Check if there is a saved configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            This will erase all data stored on TAPS system.<br>
            This operation is similar to a factory reset.<br>
            <br>
            To proceed, type your password twice and hit RESET button.<br>
            After that, system will log out and user/password will be restored to defaults.<br>
            <br>
            <cfform name="form" method="post" action="reset.cfm">
               <table>
                  <tr>
                     <td>
                        <label>
	                   <span class="text-input-taps">Password</span>
	                   <input type="password" id="idPassdw" name="passdw" class="input-taps" size="50" placeholder="Type your password" value="" />
	                </label>
                     </td>
                  </tr>
                  <tr>
                     <td>
                        <label>
	                   <span class="text-input-taps">Repeat Password</span>
	                   <input type="password" id="idPassdw2" name="passdw2" class="input-taps" size="50" placeholder="Repeat your password" value="" />
	                </label>
                     </td>
                  </tr>
                  <tr><td><input type="text" class="required" id="idError" size="50" value="Passwords are mandatory and must be equal" readonly style="visibility:hidden;"></td></tr>
                  <cfif #reset# EQ "yes" and #resultReset# EQ false>
                    <tr><td><input type="text" class="required" id="idAuthError" size="50" value="Wrong password" readonly style="visibility:visible;"></td></tr>
                  <cfelse>
                     <tr><td><input type="text" class="required" id="idAuthError" size="50" value="Wrong password" readonly style="visibility:hidden;"></td></tr>
                  </cfif>
           
                  <tr>
                     <td align="left">
                        <button type="button" class="botao-taps" onClick="if (validate()) { hideError(); document.form.reset.value='yes';document.form.submit(); } else { hideError(); showError(); }">RESET</button>
                     </td>
                     <cfinput name="reset" id="reset" type="hidden" value="no">
                  </tr>

               </table>
            </cfform>
            
           
         <cfelseif #resultReset# EQ false>
            <br>
            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>
         <cfelseif #resultReset# EQ true>
            <cfset reset="no">
            <script language="javascript">
               var a = document.createElement('a');
               a.href='logout.cfm';
               a.target = '_parent';
               document.body.appendChild(a);
               a.click();
            </script>
         </cfif>

      </cfoutput>
   </div>
</section>
</body>
</html>
