<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfprocessingdirective suppresswhitespace = true>

<cfset CrLf="#chr(13)##chr(10)#">
<cfset isSaving="0">
<cfset isTesting="0">
<cfset saveResult=false>
<cfset baker="">
<cfset fee="">
<cfset freq="">
<cfset user="">
<cfset passdw="">
<cfset passdw2="">
<cfset luceePort="">
<cfset tezosClientPath="">
<cfset tezosNodeAlias="">
<cfset tezosBaseDir="">
<cfset optFunding="native">

<cfset executeResult="">
<cfset executeError="">
<cfset textAreaContent="">

<cfif #isDefined('form.baker')#>
   <cfset baker="#form.baker#">
</cfif>
<cfif #isDefined('form.fee')#>
   <cfset fee="#form.fee#">
</cfif>
<cfif #isDefined('form.freq')#>
   <cfset freq="#form.freq#">
</cfif>
<cfif #isDefined('form.isSaving')#>
   <cfset isSaving="#form.isSaving#">
</cfif>
<cfif #isDefined('form.isTesting')#>
   <cfset isTesting="#form.isTesting#">
</cfif>
<cfif #isDefined('form.user')#>
   <cfset user="#form.user#">
</cfif>
<cfif #isDefined('form.passdw')#>
   <cfset passdw="#form.passdw#">
</cfif>
<cfif #isDefined('form.passdw2')#>
   <cfset passdw2="#form.passdw2#">
</cfif>
<cfif #isDefined('form.luceePort')#>
   <cfset luceePort="#form.luceePort#">
<cfelse>
   <cfset luceePort="#application.port#">
</cfif>
<cfif #isDefined('form.tezosClientPath')#>
   <cfset tezosClientPath="#form.tezosClientPath#">
</cfif>
<cfif #isDefined('form.tezosNodeAlias')#>
   <cfset tezosNodeAlias="#form.tezosNodeAlias#">
</cfif>
<cfif #isDefined('form.tezosBaseDir')#>
   <cfset tezosBaseDir="#form.tezosBaseDir#">
</cfif>
<cfif #isDefined('form.optFunding')#>
   <cfset optFunding="#form.optFunding#">
</cfif>

<!--- Verify if there is already a congifured baker setup --->
<cfinvoke component="components.database" method="getSettings" returnVariable="settings">

<cfif (#settings.recordCount# EQ 0) and (#isSaving# EQ "1")>

   <!--- There is no configuration saved on settings and user is trying to save one --->

   <cfset validation = "ok">

   <!--- After-submit validation --->
   <cfif #baker# EQ "" or #fee# EQ "" or #freq# EQ "" or #user# EQ "" or #passdw# EQ "" or #passdw2# EQ "" or #luceePort# EQ "">
      <cfset validation = "emptyFields">
   </cfif>
   <cfif #optFunding# EQ "node" and (#tezosClientPath# EQ "" or #tezosNodeAlias# EQ "" or #tezosBaseDir# EQ "")>
      <cfset validation = "emptyFields">
   </cfif>
   <cfif #isNumeric(fee)# EQ false or #isNumeric(freq)# EQ false or #isNumeric(luceePort)# EQ false>
      <cfset validation = "nonNumericFields">
   </cfif>

   <cfif #validation# EQ "ok">

      <!--- Force mode upon condition --->
      <cfif #optFunding# EQ "native">
         <cfset op_mode_force = #application.mode_no#>
      <cfelse>
         <cfset op_mode_force = #application.mode_try#>
      </cfif>

	   <!--- Save settings --->
	   <cfinvoke component="components.database" method="saveSettings" baker="#baker#" fee="#fee#" freq="#freq#"   
		     user="#user#"
		     passdw="#passdw#"
		     passdw2="#passdw2#"
		     applicationPort="#luceePort#"
		     clientPath="#tezosClientPath#"
		     nodeAlias="#tezosNodeAlias#"
                     baseDir="#tezosBaseDir#"
                     mode="#op_mode_force#"
                     fundsOrigin="#optFunding#"
		     returnVariable="saveResult" />
    
           <cfif #saveResult# EQ true>

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

	      <body onload="parent.scrollTo(0, 0);">
	         <section class="box-content">
	         <div  style="width:650px;">
	         <cfoutput>

		    <!--- Create scheduled task to fetch tzscan from time to time --->
		    <cfinvoke component="components.taps" method="createScheduledTask" returnVariable="createTaskResult" port="#luceePort#">
		 
		    <cfif #createTaskResult# EQ true>
                       <h2>Congratulations!</h2>
		       TAPS was configured successfully.<br>
                       <br>
         	       <div style="text-align: justify;text-justify: inter-word;">
                  	Please note that TAPS will run according to the specified mode on STATUS.
                        It begins set to "Simulation", which means that it will NOT make real payments,
                        but will do all administrative operations nevertheless.<br>
                        <br>
                        Take a tour through the menu options and when you feel secure, change STATUS to "On".<br>
                        <br> 
                        TAPS works by querying TzScan.io API from time to time (60 minutes is recommended).
                        Then it extracts information about Rewards status for the configured baker ID
                        and its delegators. All data is stored in a local database, and can then be checked
                        through the menu options.<br>
                        <br>
                        When TAPS detects a cycle change, it will start a procedure to make the rewards
                        payments to the delegators, according to its shares. All payments made are registered
                        in local database, so can be checked anytime.<br>
                        <br>
                        Thank you for trying TAPS.<br>
                       </div>
		    <cfelse>

		       <!--- Something went wrong in scheduled task creation --->
		       <cfinvoke component="components.database" method="removeSettings" bakerId="#baker#" returnVariable="resultRemove">

		       There was an error while configuring TAPS.<br>
		       Could not create scheduled task to fetch TzScan.
		    </cfif>
	      
	         </cfoutput>
	      </div>
	      </section>
	      </body>
              </html>
           <cfelse>
              There was an error while trying to save configuration.
           </cfif>

   <cfelse>

      <!--- Post-validation was not ok --->
   
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

	   <body onload="parent.scrollTo(0, 0);">
	   <section class="box-content">
	   <div  style="width:650px;">
	   <cfoutput>
              <br><br><br><br>
  	      Detected empty fields or with wrong type.
 	      Please go back and try again.
	      
	   </cfoutput>
	   </div>
	   </section>
	   </body>
         </html>

   </cfif>

<cfelseif #isSaving# EQ "0">

   <!--- User is NOT trying to save configuration --->

   <cfif (#settings.recordCount# GT 0)>

      <!--- If there is already saved data on settings --->

      <cfset baker="#application.bakerId#">
      <cfset fee="#application.fee#">
      <cfset freq="#application.freq#">
      <cfset user="#settings.user_name#">
      <cfset passdw="XXXXXXXXXX">
      <cfset passdw2="XXXXXXXXXX">
      <cfset luceePort="#settings.application_port#">
      <cfset tezosClientPath="#settings.client_path#">
      <cfset tezosNodeAlias="#settings.node_alias#">
      <cfset tezosBaseDir="#settings.base_dir#">
   </cfif>

   <!--- If user hit TEST button, to test Tezos-node client --->
   <cfif #isTesting# EQ "1" and #optFunding# EQ "node">
      <cftry>
         <cfset transferCmd = "#tezosClientPath#/tezos-client --base-dir #tezosBaseDir#/.tezos-client transfer 1 from #tezosNodeAlias# to #baker#">
         <cfset argumentsCmd = "--fee 0.05 --dry-run">
         <cfexecute
            name = "#transferCmd#"
            arguments = "#argumentsCmd#"
            terminateontimeout = false
            timeout = "300"
            variable = "executeResult"
            errorVariable = "error">
         </cfexecute>
         <cfset executeResult = "Simulation (nothing was transfered):#crlf##crlf##executeResult#">

      <cfcatch>
         <cfset executeError="Could not execute Tezos-client transfer test.#crlf#Please check if Tezos client is installed, verify base-dir,#crlf#alias and path information.#crlf##crlf#TAPS failed to run the following command:#CrLf##CrLf##transferCmd#&nbsp;#argumentsCmd#">
      </cfcatch>
      </cftry>

   <cfelseif #optFunding# EQ "native">
      <cfset executeError = "">   
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

           function resizeIframe(obj)
           {
              obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
           }

           function isNumeric(n)
           {
              return !isNaN(parseFloat(n)) && isFinite(n);
           }

	   function validate()
	   {
	      hideReqFields();

	      if (document.getElementById('idBaker').value == '')
	      {
	         return 'idBaker_req';
	      }

	      if (document.getElementById('idFee').value == '')
	      {
	         return 'idFee_req';
	      }
	      
	      if (document.getElementById('idFreq').value == '')
	      {
	         return 'idFreq_req';
	      }

	      if (document.getElementById('idUser').value == '')
	      {
	         return 'idUser_req';
	      }

	      if (document.getElementById('idPassdw').value == '')
	      {
	         return 'idPassdw_req';
	      }

	      if (document.getElementById('idPassdw2').value == '')
	      {
	         return 'idPassdw2_req';
	      }

	      if (document.getElementById('idPassdw').value != document.getElementById('idPassdw2').value)
	      {
	         return 'idPassdw_neq';
	      }

	      if (document.getElementById('idLuceePort').value == '')
	      {
	         return 'idLuceePort_req';
	      }

              if ((document.getElementById('idOptNative').checked == false)&&(document.getElementById('idOptNode').checked == false))
              {
	         return 'idOptFunding_req';
              }

              if (document.getElementById('idOptNode').checked == true && document.getElementById('idTezosBaseDir').value == '')
	      {
	         return 'idTezosBaseDir_req';
	      }

	      if (document.getElementById('idOptNode').checked == true && document.getElementById('idTezosNodeAlias').value == '')
	      {
		return 'idTezosNodeAlias_req';
	      }

              if (document.getElementById('idOptNode').checked == true &&  document.getElementById('idTezosClientPath').value == '')
	      {
	         return 'idTezosClientPath_req';
	      }

              // Validate field types.

	      if ( ! isNumeric(document.getElementById('idFee').value) )
	      {
	         return 'idFee_type';
	      }
	      
	      if (! isNumeric(document.getElementById('idFreq').value) )
	      {
	         return 'idFreq_type';
	      }

	      if (document.getElementById('idFreq').value < 10)
	      {
	         return 'idFreq_min';
	      }

	      if (! isNumeric(document.getElementById('idLuceePort').value) )
	      {
	         return 'idLuceePort_type';
	      }

              if ((document.getElementById('idBaker').value.substr(0,2) != 'tz') || (document.getElementById('idBaker').value.length < 30))
	      {
	         return 'idBaker_invalid';
	      }
	      return true;
	   }

	   function showRequiredField(field)
	   {
	      var inputFieldName = field.substring(0, field.indexOf('_'));
	      var sufix = field.substring( field.indexOf('_') + 1, field.length );

              if (sufix == 'type')
              {
                 document.getElementById(inputFieldName + '_req').value=' Must be numeric';
              }
              else if (sufix == 'req')
              {
                 document.getElementById(inputFieldName + '_req').value=' Required';
              }
              else if (sufix == 'neq')
              {
                 document.getElementById(inputFieldName + '_req').value=' Passwords must match';
              }
              else if (sufix == 'test')
              {
                 document.getElementById(inputFieldName + '_req').value=' Required to run';
              }
              else if (sufix == 'invalid')
              {
                 document.getElementById(inputFieldName + '_req').value=' Invalid implicit address';
              }
              else if (sufix == 'min')
              {
                 document.getElementById(inputFieldName + '_req').value=' Minimum is 10 minutes';
              }

              if (inputFieldName + '_req')
              {
   	         document.getElementById(inputFieldName + '_req').style.visibility = "visible";
	         document.getElementById(inputFieldName + '_req').focus();
              }

	      document.getElementById(inputFieldName).focus();
	   }

	   function hideReqFields()
	   {
	      document.getElementById('idBaker_req').style.visibility = "hidden";
	      document.getElementById('idFee_req').style.visibility = "hidden";
	      document.getElementById('idFreq_req').style.visibility = "hidden";
	      document.getElementById('idUser_req').style.visibility = "hidden";
	      document.getElementById('idPassdw_req').style.visibility = "hidden";
	      document.getElementById('idPassdw2_req').style.visibility = "hidden";
	      document.getElementById('idLuceePort_req').style.visibility = "hidden";
	      document.getElementById('idOptFunding_req').style.visibility = "hidden";

              if (document.getElementById('idTezosNodeAlias_req'))
              {
	         document.getElementById('idTezosNodeAlias_req').style.visibility = "hidden";
              }

	      if (document.getElementById('idTezosBaseDir_req'))
              {
                 document.getElementById('idTezosBaseDir_req').style.visibility = "hidden";
              }

              if (document.getElementById('idTezosClientPath_req'))
              {
	         document.getElementById('idTezosClientPath_req').style.visibility = "hidden";
              }

	   }

           function showNodeDetails()
           {
              document.getElementById('idBtnSave').style.visibility = 'hidden';
              $("#idNodeDetails").find("input,button,textarea,select").removeAttr('disabled');
              $("#idNodeDetails").find("input,button,select").removeAttr('readonly');
              $("#idNodeDetails").show();
              document.getElementById('idNodeDetails').style.visibility = 'visible';
              resizeIframe(parent.document.getElementById('idIframeMain'));
              document.activeElement.blur();
           }

           function showNodeDetailsDisabled()
           {
              $("#idNodeDetails").find("input,button,textarea,select").attr("disabled", "disabled");
              $("#idNodeDetails").find("input,button,textarea,select").attr("readonly", "readonly");
              $("#idNodeDetails").show();
              document.getElementById('idNodeDetails').style.visibility = 'visible';
              resizeIframe(parent.document.getElementById('idIframeMain'));
           }

           function hideNodeDetails()
           {
              $("#idNodeDetails").hide();

              // Clean node related fields.
              document.getElementById('idTezosBaseDir').value = '';
	      document.getElementById('idTezosNodeAlias').value = '';
              document.getElementById('idTezosClientPath').value = '';

              $('textarea').val('Please, click Test button to simulate a 1 XTZ transfer.');
              $("#idNodeDetails").find("input,button,textarea,select").attr("disabled", "disabled");
              $("#idNodeDetails").find("input,button,textarea,select").attr("readonly", "readonly");
              document.activeElement.blur();
              document.getElementById('idBtnSave').style.visibility = 'visible';
              document.getElementById('idBtnSave').focus();
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
	   }
	</style>

   </head>

   <body>
   <section class="box-content">
   <div  style="width:650px;">
   <cfoutput>

      <h1>Setup</h1>
      <br>

      <cfform name="form" action="setup.cfm" method="post">
      <table>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Baker ID</span><input type="text" class="required" id="idBaker_req" value="&nbsp;Required" readonly>
	       <cfif #len(baker)# GT 0 and #isTesting# NEQ "1">
	          <input type="text" id="idBaker" name="baker" class="input-taps" size="50" placeholder="Node's baking tz address" value="#baker#" readonly />
	       <cfelse>
	          <input type="text" id="idBaker" name="baker" class="input-taps" size="50" placeholder="Node's baking tz address" value="#baker#">
	       </cfif>     
	   </label>
	</td>
	<td></td>
      </tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Default Rewards fee (%)</span><input type="text" class="required" id="idFee_req" value="&nbsp;Required" readonly>
	       <cfif #len(fee)# GT 0 and #isTesting# NEQ "1">
	          <input type="text" id="idFee" name="fee" class="input-taps" size="50" placeholder="00.00" value="#fee#" maxlength="5" readonly>
	       <cfelse>
	          <input type="text" id="idFee" name="fee" class="input-taps" size="50" placeholder="00.00" value="#fee#" maxlength="5">         
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Update frequency (minutes)</span><input type="text" class="required" id="idFreq_req" value="&nbsp;Required" readonly>
	       <cfif #len(freq)# GT 0 and #isTesting# NEQ "1">
	          <cfinput type="text" id="idFreq" name="freq" class="input-taps" size="50" placeholder="(recommended 60)" value="#freq#" readonly>
	       <cfelse>
	          <cfinput type="text" id="idFreq" name="freq" class="input-taps" size="50" placeholder="(recommended 60)" value="#freq#">
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>

      <tr><td>&nbsp;</td></tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">User</span><input type="text" class="required" id="idUser_req" value="&nbsp;Required" readonly>
	          <cfif #len(user)# GT 0 and #isTesting# NEQ "1">
	             <cfinput type="text" id="idUser" name="user" class="input-taps" size="50" placeholder="Type login username" value="#user#" readonly>
	          <cfelse>
	            <cfinput type="text" id="idUser" name="user" class="input-taps" size="50" placeholder="Type login username" value="#user#">
	          </cfif>
	    </label>
	 </td>   
	 <td></td>
      </tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Password</span><input type="text" class="required" id="idPassdw_req" value="&nbsp;Required" readonly>
	       <cfif #len(passdw)# GT 0 and #settings.recordCount# GT 0 and #isTesting# NEQ "1">
	          <cfinput type="password" id="idPassdw" name="passdw" class="input-taps" size="50" placeholder="Type login password" value="#passdw#" readonly>
	       <cfelse>
	          <cfinput type="password" id="idPassdw" name="passdw" class="input-taps" size="50" placeholder="Type login password" value="#passdw#">
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Repeat password</span><input type="text" class="required" id="idPassdw2_req" value="&nbsp;Required" readonly>
	       <cfif #len(passdw2)# GT 0 and #settings.recordCount# GT 0 and #isTesting# NEQ "1">
	          <cfinput type="password" id="idPassdw2" name="passdw2" class="input-taps" size="50" placeholder="Repeat login password" value="#passdw2#" readonly>
	       <cfelse>
	          <cfinput type="password" id="idPassdw2" name="passdw2" class="input-taps" size="50" placeholder="Repeat login password" value="#passdw2#">
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Lucee Server Port</span><input type="text" class="required" id="idLuceePort_req" value="&nbsp;Required" readonly>
	       <cfif #len(luceePort)# GT 0 and #settings.recordCount# GT 0 and #isTesting# NEQ "1">
	          <cfinput type="text" id="idLuceePort" name="luceePort" class="input-taps" size="50" placeholder="(Default 8888)" value="#luceePort#" readonly>
	       <cfelse>
	          <cfinput type="text" id="idLuceePort" name="luceePort" class="input-taps" size="50" placeholder="(Default 8888)" value="#luceePort#">
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>

      <tr><td>&nbsp;</td></tr>

      <tr>
         <td>
            <cfif #settings.recordCount# GT 0 and #isTesting# NEQ "1">
      
               <!--- If there is already a saved configuration, we will show only the result of the radio buttons selection --->

               <span class="text-input-taps">When distributing rewards to delegators, use resources from:</span><br>
               <cfinput type="text" id="idFunding" name="funding" class="input-taps" style="text-transform : capitalize;" size="50" value="#settings.funds_origin#" readonly>

            <cfelse>

               <!--- Otherwise, we will show the radio buttons, so the user can choose --->

               <div class="radio">

                  <span class="text-input-taps">When distributing rewards to delegators, use resources from:</span><br><input type="text" class="required" id="idOptFunding_req" value="&nbsp;Required" readonly><br>
                  
                  <cfif #optFunding# EQ "native">

                     <!--- User has previously chosen to use the native wallet, so check this option --->                   

                     <label><cfinput type="radio" id="idOptNative" name="optFunding" value="native" checked onClick="hideNodeDetails();">&nbsp;TAPS native wallet</label><br>
                     <label><cfinput type="radio" id="idOptNode" name="optFunding" value="node" onClick="showNodeDetails();">&nbsp;Node resources</label>

                  <cfelseif #optFunding# EQ "node">

                     <!--- User has previously chosen to use Tezos-client funds transfer, so check this option  --->

                     <label><cfinput type="radio" id="idOptNative" name="optFunding" value="native" onClick="hideNodeDetails();">&nbsp;TAPS native wallet</label><br>
                     <label><cfinput type="radio" id="idOptNode" name="optFunding" value="node" checked onClick="showNodeDetails();">&nbsp;Node resources</label>
 
                  <cfelse>

                     <!--- There is no radio buttons checked --->

                     <label><cfinput type="radio" id="idOptNative" name="optFunding" value="native" onClick="hideNodeDetails();">&nbsp;TAPS native wallet</label><br>
                     <label><cfinput type="radio" id="idOptNode" name="optFunding" value="node" onClick="showNodeDetails();">&nbsp;Node resources</label>

                  </cfif>

               </div>

            </cfif>
         </td>
      </tr>

      <tr><td>&nbsp;</td></tr>
      </table>

      <table id="idNodeDetails" style="visibility:<cfif #optFunding# EQ 'native'>collapse;<cfelse>visible;</cfif>">
      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Tezos base-dir</span><input type="text" class="required" id="idTezosBaseDir_req" value="&nbsp;Required" readonly>
	       <cfif #len(tezosBaseDir)# GT 0 and #isTesting# NEQ "1">
	          <cfinput type="text" id="idTezosBaseDir" name="tezosBaseDir" class="input-taps" size="50"  placeholder="Path to your Tezos base dir (e.g. /home/user)" value="#tezosBaseDir#" readonly>
	       <cfelse>
	          <cfinput type="text" id="idTezosBaseDir" name="tezosBaseDir" class="input-taps" size="50"  placeholder="Path to your Tezos base dir (e.g. /home/user)" value="#tezosBaseDir#">
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>

      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Tezos-node alias</span><input type="text" class="required" id="idTezosNodeAlias_req" value="&nbsp;Required" readonly>
	       <cfif #len(tezosNodeAlias)# GT 0 and #isTesting# NEQ "1">
	          <cfinput type="text" id="idTezosNodeAlias" name="tezosNodeAlias" class="input-taps" size="50"  placeholder="Type your Tezos node address alias" value="#tezosNodeAlias#" readonly>
	       <cfelse>
	          <cfinput type="text" id="idTezosNodeAlias" name="tezosNodeAlias" class="input-taps" size="50"  placeholder="Type your Tezos node address alias" value="#tezosNodeAlias#">
	       </cfif>
	    </label>
	 </td>
	 <td></td>
      </tr>
      <tr>
	 <td>
	    <label>
	       <span class="text-input-taps">Full path to Tezos-client binary</span><input type="text" class="required" id="idTezosClientPath_req" value="&nbsp;Required" readonly>
	       <cfif #len(tezosClientPath)# GT 0 and #isTesting# NEQ "1">
 	          <cfinput type="text" id="idTezosClientPath" name="tezosClientPath" class="input-taps" size="50"  placeholder="Full path to Tezos-client (e.g. /home/user/tezos)" value="#tezosClientPath#" readonly>&nbsp;
   	          <button type="button" id="idButtonTest" class="botao-taps" disabled style="visibility:<cfif #len(baker)# GT 0 and #isTesting# NEQ '1'>hidden;<cfelse>visible;</cfif>">Test</button>
	       <cfelse>
	          <cfinput type="text" id="idTezosClientPath" name="tezosClientPath" class="input-taps" size="50"  placeholder="Full path to Tezos-client (e.g. /home/user/tezos)" value="#tezosClientPath#">&nbsp;
   	          <button type="button" class="botao-taps" onClick="javascript: var result = validate(); if (result == true){ hideReqFields(); document.getElementById('idIsSaving').value='0';document.getElementById('idIsTesting').value='1';document.form.submit(); } else { showRequiredField(result); }">Test</button>
	       </cfif>
	    </label>
	 <td></td>
	 </td>
      </tr>

      <tr>
         <td>
            <!--- Define what the textArea contents will be, according to the test operation result --->
            <cfif #isSaving# EQ "0" and #isTesting# EQ "1" and #len(executeError)# GT 0>

               <!--- User is testing transfer command execution and got an error --->

               <cfset textAreaContent="TAPS was unable to run transfer command below: #CrLf##tezosClientPath#/tezos-client --base-dir #tezosBaseDir#/.tezos-client transfer 1 from #tezosNodeAlias# to #baker# --fee 0.05 --dry-run">

            <cfelseif #isSaving# EQ "0" and #len(baker)# EQ 0>

               <!--- User is seeing the SETUP page for the first time, not doing test, neither saving --->

               <cfset textAreaContent="Please, click Test button to simulate a 1 XTZ transfer.">

            <cfelseif #isTesting# NEQ "1" and #settings.recordCount# GT 0>

               <!--- User has saved the configuration successfully --->

               <cfif #settings.funds_origin# EQ "node">
                  <script language="javascript">showNodeDetailsDisabled();</script>
                  <cfset textAreaContent="TAPS has been configured successfully.">
               <cfelse>
                  <!--- Check if there is a native wallet configured --->
                  <cfif #len(settings.wallet_hash)# GT 0>
                     <cfset textAreaContent="TAPS has been configured successfully.">
                  <cfelse>
                     <cfset textAreaContent="TAPS has been configured successfully, but is lacking a native wallet. Please select WALLET menu option and create one. Otherwise, TAPS will not be able to work properly.">
                  </cfif>
               </cfif>

            <cfelseif #isSaving# EQ "0" and #isTesting# EQ "1" and #len(executeError)# EQ 0>

               <!--- User has tested the configuration successfully --->

               <cfset textAreaContent="Successfully ran transfer command below: #CrLf##tezosClientPath#/tezos-client --base-dir #tezosBaseDir#/.tezos-client transfer 1 from #tezosNodeAlias# to #baker# --fee 0.05 --dry-run">

            </cfif>

           <cfif #isSaving# EQ "0" and #isTesting# EQ "1">

            <input type="text" class="required" id="idTextArea_req" value="&nbsp;Required to run" readonly>
            <textarea id="idTextArea" cols="50" rows="5" style="padding-left:10px;padding-top:10px;" readonly>#textAreaContent#</textarea>
            </cfif>

           <!--- Show checkmarks - success or failure --->
           <cfif #isSaving# EQ "0" and #isTesting# EQ "1" and #len(executeError)# GT 0>

              <!--- User is testing transfer execution and got an error --->

              <image src="imgs/check_error.png" id="idCheckFail" width="32" height="32" style="margin-bottom:20px;margin-left:10px;" />

           <cfelseif #isSaving# EQ "0" and #isTesting# EQ "1" and #len(executeError)# EQ 0>

              <!--- User is testing transfer and result is OK --->

              <image src="imgs/check_ok.png" id="idCheckOk" width="32" height="32" style="marginbottom:20px;margin-left:10px;" />

           </cfif>

           <cfinput type="hidden" name="execError" id="idExecError" value="#executeError#" />
         </td>
      </tr>
      </table>
      <tr><td>&nbsp;</td></tr>

      <cfif #settings.recordcount# GT 0 and #isTesting# NEQ "1">
         <textarea id="idTextArea" cols="50" rows="5" style="padding-left:10px;padding-top:10px;" readonly>#textAreaContent#</textarea>
      </cfif>

      <tr>
	 <cfif (#optFunding# EQ "native" and #settings.recordcount# EQ 0) or (#optFunding# EQ "node" and #isSaving# EQ "0" and #isTesting# EQ "1" and #len(executeError)# EQ 0)>

            <!--- User is not saving, IS testing and had success executing transfer command --->
            <!--- OR user has selected to use native wallet as the origin of funds --->

	    <td align="left">
	       <br><button type="button" id="idBtnSave" style="visibility:visible;" class="botao-taps" onClick="javascript: var result = validate(); if (result == true){ hideReqFields(); document.getElementById('idIsTesting').value='0';document.getElementById('idIsSaving').value='1';document.form.submit(); } else { showRequiredField(result); }">Save</button></td>
            </td>
         <cfelse>
            <td></td>
 	 </cfif>
	 <cfinput name="isSaving" id="idIsSaving" type="hidden" value="0">
         <cfinput name="isTesting" id="idIsTesting" type="hidden" value="0">
      </tr>
      </table>     
      </cfform>

    </cfoutput>
    </div>
    </section>

    <cfif #len(baker)# GT 0 and #isTesting# EQ "1">
       <script language="javascript">
          document.getElementById('idTextArea').focus();
       </script>
    </cfif>

   </body>
</html>

</cfif>

</cfprocessingdirective>

