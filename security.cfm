<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset change="no">
<cfset passdw="">
<cfset passdw2="">
<cfset current="">
<cfset resultChange=false>

<cfif #isDefined('form.change')#>
   <cfset change="#form.change#">
</cfif>
<cfif #isDefined('form.passdw')#>
   <cfset passdw="#form.passdw#">
</cfif>
<cfif #isDefined('form.passdw2')#>
   <cfset passdw2="#form.passdw2#">
</cfif>
<cfif #isDefined('form.current')#>
   <cfset current="#form.current#">
</cfif>

<cfif change EQ "yes">
   <cfinvoke component="components.database" method="changePassdw" user="#application.user#" bakerId="#application.bakerId#" current="#current#" passdw="#passdw#" passdw2="#passdw2#" returnVariable="resultChange">
<cfelse>
   <cfset resultChange=false>
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

	      if (document.getElementById('idCurrent').value == '')
	      {
	         return false;
	      }
	      
	      if (document.getElementById('idPassdw').value != document.getElementById('idPassdw2').value)
	      {
	         return false;
	      }

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
           Security
         </h1>                
  
         <h4>Here you can change your login credentials</h4>

         <!--- Check if there is a saved configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            Type the current password once and then the new password twice and hit CHANGE button.
            After that, system will log out and password will be updated.<br>
            <br>
            <cfform name="form" method="post" action="security.cfm">
               <table>
                  <tr>
                     <td>
                        <label>
	                   <span class="text-input-taps">Current Password</span>
	                   <input type="password" id="idCurrent" name="current" class="input-taps" size="50" placeholder="Type your current password" value="" />
	                </label>
                     </td>
                  </tr>
                  <tr>
                     <td>
                        <label>
	                   <span class="text-input-taps">New Password</span>
	                   <input type="password" id="idPassdw" name="passdw" class="input-taps" size="50" placeholder="Type your new password" value="" />
	                </label>
                     </td>
                  </tr>
                  <tr>
                     <td>
                        <label>
	                   <span class="text-input-taps">Repeat New Password</span>
	                   <input type="password" id="idPassdw2" name="passdw2" class="input-taps" size="50" placeholder="Repeat your new password" value="" />
	                </label>
                     </td>
                  </tr>
                  <tr><td><input type="text" class="required" id="idError" size="50" value="All fields are mandatory and the new passwords must be equal" readonly style="visibility:hidden;"></td></tr>                  
                  <tr><td><input type="text" class="required" id="idAuthError" size="50" value="Wrong password" readonly style="visibility:<cfif #change# EQ "yes" and #resultChange# EQ false>visible;<cfelse>hidden;</cfif>"></td></tr>
                  <tr>
                     <td align="left">
                        <button type="button" class="botao-taps" onClick="if (validate()) { hideError(); document.form.change.value='yes';document.form.submit(); } else { hideError(); showError(); }">CHANGE</button>
                     </td>
                     <cfinput name="change" id="change" type="hidden" value="no">
                  </tr>

               </table>
            </cfform>
            
		 <cfif #resultChange# EQ true>
		    <cfset change="no">
		    <script language="javascript">
		       var a = document.createElement('a');
		       a.href='logout.cfm';
		       a.target = '_parent';
		       document.body.appendChild(a);
		       a.click();
		    </script>
		</cfif>

         <cfelseif #resultChange# EQ false>
            <br>
            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>
         </cfif>

      </cfoutput>
   </div>
</section>
</body>
</html>
