<cfset user="">
<cfset passdw="">
<cfset ok="">
<cfset wrongLogin = false>
<cfset dbError = false>

<cfif #isDefined('form.user')#>
   <cfset user="#form.user#">
</cfif>
<cfif #isDefined('form.passdw')#>
   <cfset passdw="#form.passdw#">
</cfif>
<cfif #isDefined('form.ok')#>
   <cfset ok="#form.ok#">
</cfif>

<cfif #ok# EQ "1">

   <cfinvoke component="components.taps" method="authenticate" returnVariable="result" user="#user#" passdw="#passdw#">

   <cfif #result# EQ true>
      <!--- Do login --->
      <cflogin idleTimeout="1800">
         <cfloginUser 
            name = "#user#"
            password = "#passdw#"
            roles="any">
      </cflogin>

      <cfset wrongLogin = false>

      <!--- System Health-check --->
      <cfinvoke component="components.taps" method="healthCheck"  />

      <!--- Opens the TAPS user native wallet, if configured --->
      <cfset session.myWallet = "">
      <cftry>
      <cfthread action="run" name="thread_open_wallet">
	      <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

	      <cfif #settings.recordCount# GT 0>
		 <cfif #len(settings.wallet_hash)# GT 0 and #len(settings.wallet_salt)# GT 0>
		    <!--- User has configured TAPS successfully and also has created a native wallet --->

		    <!--- Decrypt passphrase from the local database with user password --->
		    <cfset passphrase = decrypt('#settings.phrase#', '#passdw#')>

		    <!--- Authenticate the owner of wallet with passphrase --->
		    <cfinvoke component="components.database" method="authWallet" bakerId="#application.bakerId#" passdw="#passphrase#" returnVariable="authResult">
		    <cfif #authResult# EQ true>
		       <!--- Get TezosJ_SDK TezosWallet class --->
		       <cfset session.tezosJ = createObject("java", "milfont.com.tezosj.model.TezosWallet", "./#application.TezosJ_SDK_location#")>
		       <!--- Instantiate the wallet with the user passphrase --->   
		       <cfset strPath = ExpandPath( "./" ) />
		       <cfset session.myWallet = session.tezosJ.init(true, "#strPath#/wallet/wallet.taps", "#passphrase#")>
                       
                       <!--- Change RPC provider --->
                       <cfset session.myWallet.setProvider("https://tezos-prod.cryptonomic-infra.tech")>		       
		       
		       <cfset session.totalAvailable = "#session.myWallet.getBalance()#">
		    </cfif>
		 </cfif>
	      </cfif>
      </cfthread> 
      <cfcatch>
      </cfcatch>
      </cftry>

      <!--- Redirect to main menu ---> 
      <cflocation url="menu.cfm">

   <cfelseif #result# EQ false>
      <cfset wrongLogin = true>

   <cfelse>
      <cfset dbError = true>
   </cfif>

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


        <script language="javascript">
           function validate()
           {

              if (document.getElementById('idUser').value == '')
              {
                 return 'userReqId';
              }
              
              if (document.getElementById('idpassdw').value == '')
              {
                 return 'passdwReqId';
              }

              return true;
           }

           function showRequiredField(field)
           {
              document.getElementById(field).style.visibility = "visible";
           }

           function hideReqFields()
           {
              document.getElementById('userReqId').style.visibility = "hidden";
              document.getElementById('passdwReqId').style.visibility = "hidden";
           }

        </script>

	<style>
         .center_div
         {
            margin: auto;
            width: 50%;
            height:0px;
            padding: 40px;
            position: relative;
            top:50%;
            transform: perspective(1px) translateY(50%);
         }

         tr
         {
            border: hidden;
         }
        </style>

   </head>

   <body onLoad="document.form.user.focus();">
   
   <cfoutput>

   <script language="javascript">hideReqFields();</script>

   <div class="center_div">

      <cfform name="form" action="index.cfm" method="post">
      <table class="table table-taps" style="width: 300px;">

      <tr>
        <td><img src="imgs/taps_logo_dourada.png"<td>
      </tr>

      <cfif #dbError# EQ false>
	      <tr>
		 <td>
		    <label>
		       <span class="text-input-taps">Username</span><span style="color:red;visibility:hidden;" id="userReqId">&nbsp;Required</span>
		       <cfinput type="text" id="idUser" name="user" class="input-taps" size="30" placeholder="User login" value="">
		    </label>
		 </td>
	      </tr>

	      <tr>
		 <td>
		    <label>
		       <span class="text-input-taps">Password</span><span style="color:red;visibility:hidden;" id="passdwReqId">&nbsp;Required</span>
		       <cfinput type="password" id="idpassdw" name="passdw" class="input-taps" size="30" placeholder="Type your password" maxlength="50" value="">
		       <cfinput type="text" id="idVersion" name="version" style="font-size: small;text-align:right;width:100%;background-color:white;border:none;color:##888888;" value="v#application.version#" readonly disabled>
		    </label>
		    </td>
	      </tr>
	      <tr>
		 <td align="right" colspan="2">
		    <span style="color:red;visibility:<cfif #wrongLogin#>visible<cfelse>hidden</cfif>;" id="wrongLoginId">Wrong username or password&nbsp;&nbsp;&nbsp;&nbsp;</span>
		    <button type="button" name="btnSubmit" value="Login" class="botao-taps" onClick="javascript: var result = validate(); if (result == true){ hideReqFields(); document.getElementById('ok').value='1';document.form.submit(); } else { showRequiredField(result); }">Login</button>
		    <cfinput name="ok" id="ok" type="hidden" value="0">
		 </td>
	      </tr>

      <cfelse>
         </table>
         <table style="width:600px;">
         <tr style="width:500px;">
            <td colspan="2">
               TAPS requires H2 database Lucee extension, that was not detected.<br>
               Please download H2 extension from <a href="https://download.lucee.org/" target="_blank" style="text-decoration:underline;">Lucee download page</a>, then<br>
               copy the ".LEX" file to /lucee-server/deploy of running Lucee<br>installation and try again.<br>
            </td>
         </tr>
      </cfif>
      </table>
      </cfform>

   </cfoutput>
   
   </body>
</html>

