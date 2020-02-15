<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>


<cfset fee = "">
<cfset freq = "">
<cfset luceePort = "#application.port#">
<cfset proxyServer = "">
<cfset proxyPort = "">
<cfset provider = "">
<cfset gasLimit = "">
<cfset storageLimit = "">
<cfset transactionFee = "">
<cfset blockExplorer = "">
<cfset numberOfBlocksToWait = "">
<cfset paymentRetries = "">
<cfset minutesBetweenRetries = "">

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
           function isNumeric(n)
           {
              return !isNaN(parseFloat(n)) && isFinite(n);
           }

	   function validate()
	   {
	      hideReqFields();

	      if (document.getElementById('idProvider').value == '')
	      {
	         return 'idProvider_req';
	      }

	      if (document.getElementById('idGasLimit').value == '')
	      {
	         return 'idGasLimit_req';
	      }

	      if (document.getElementById('idStorageLimit').value == '')
	      {
	         return 'idStorageLimit_req';
	      }

	      if (document.getElementById('idTransactionFee').value == '')
	      {
	         return 'idTransactionFee_req';
	      }

	      if (document.getElementById('idBlockExplorer').value == '')
	      {
	         return 'idBlockExplorer_req';
	      }

	      if (document.getElementById('idFee').value == '')
	      {
	         return 'idFee_req';
	      }

	      if (document.getElementById('idFreq').value == '')
	      {
	         return 'idFreq_req';
	      }

	      if (document.getElementById('idProxyPort').value == '')
	      {
	         return 'idProxyPort_req';
	      }

	      if (document.getElementById('idNumberOfBlocks').value == '')
	      {
	         return 'idNumberOfBlocks_req';
	      }

	      if (document.getElementById('idPaymentRetries').value == '')
	      {
	         return 'idPaymentRetries_req';
	      }

	      if (document.getElementById('idMinutesBetweenRetries').value == '')
	      {
	         return 'idMinutesBetweenRetries_req';
	      }

              // Validate field types.

	      if ( ! isNumeric(document.getElementById('idGasLimit').value) )
	      {
	         return 'idGasLimit_type';
	      }

	      if ( ! isNumeric(document.getElementById('idStorageLimit').value) )
	      {
	         return 'idStorageLimit_type';
	      }

	      if ( ! isNumeric(document.getElementById('idTransactionFee').value) )
	      {
	         return 'idTransactionFee_type';
	      }

	      if ( ! isNumeric(document.getElementById('idFee').value) )
	      {
	         return 'idFee_type';
	      }

	      if ( ! isNumeric(document.getElementById('idFreq').value) )
	      {
	         return 'idFreq_type';
	      }

	      if ( ! isNumeric(document.getElementById('idProxyPort').value) )
	      {
	         return 'idProxyPort_type';
	      }

	      if ( ! isNumeric(document.getElementById('idNumberOfBlocks').value) )
	      {
	         return 'idNumberOfBlocks_type';
	      }

	      if ( ! isNumeric(document.getElementById('idPaymentRetries').value) )
	      {
	         return 'idPaymentRetries_type';
	      }

	      if ( ! isNumeric(document.getElementById('idMinutesBetweenRetries').value) )
	      {
	         return 'idMinutesBetweenRetries_type';
	      }

              return true;
	   }

	   function hideReqFields()
	   {
              document.getElementById('idProvider_req').style.visibility = "hidden";
              document.getElementById('idStorageLimit_req').style.visibility = "hidden";
              document.getElementById('idGasLimit_req').style.visibility = "hidden";
              document.getElementById('idTransactionFee_req').style.visibility = "hidden";
              document.getElementById('idBlockExplorer_req').style.visibility = "hidden";
              document.getElementById('idFee_req').style.visibility = "hidden";
              document.getElementById('idFreq_req').style.visibility = "hidden";
              document.getElementById('idProxyPort_req').style.visibility = "hidden";
              document.getElementById('idNumberOfBlocks_req').style.visibility = "hidden";
              document.getElementById('idPaymentRetries_req').style.visibility = "hidden";
              document.getElementById('idMinutesBetweenRetries_req').style.visibility = "hidden";
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

           function updateSettings()
           {
	      var proxyServer = document.getElementById('idProxyServer').value;
	      var proxyPort = document.getElementById('idProxyPort').value;
	      var provider = document.getElementById('idProvider').value;
	      var paymentRetries = document.getElementById('idPaymentRetries').value;
	      var gasLimit = document.getElementById('idGasLimit').value;
	      var storageLimit = document.getElementById('idStorageLimit').value;
	      var numberOfBlocksToWait = document.getElementById('idNumberOfBlocks').value;
	      var blockExplorer = document.getElementById('idBlockExplorer').value;
	      var minutesBetweenTries = document.getElementById('idMinutesBetweenRetries').value;
	      var tz_default_operation_fee = document.getElementById('idTransactionFee').value;
	      var default_fee = document.getElementById('idFee').value;
	      var update_freq = document.getElementById('idFreq').value;
              var lucee_port = document.getElementById('idLuceePort').value;

              // Calls Coldfusion method to update local database.
              $.get('bp_proxy.cfm?settings=true' +
                    '&proxy_server=' + proxyServer +  
                    '&proxy_port=' + proxyPort +
                    '&provider=' + provider +
                    '&payment_retries=' + paymentRetries +
                    '&gas_limit=' + gasLimit +
                    '&storage_limit=' + storageLimit +
                    '&num_blocks_wait=' + numberOfBlocksToWait +
                    '&block_explorer=' + blockExplorer +
                    '&min_between_retries=' + minutesBetweenTries +
                    '&default_fee=' + default_fee +
                    '&update_freq=' + update_freq +
                    '&lucee_port=' + lucee_port +
                    '&transaction_fee=' + tz_default_operation_fee, function( data )
                        {
                          var result = data.trim();
                          if (result == 'true')
                          { alert('Settings updated successfully'); } else { alert( 'There was an error while trying to update settings' ); }
                        }
                    );
            }

      </script>

	<style>
           a, a:active, a:focus, a:hover, input, input:focus { outline: none; !important; }

           .nooutline, .nooutline:focus { outline: none; !important; }

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
      <section class="box-content-rewards">
      <div  style="width:550px;">
         <cfoutput>

         <h1 class="title-baker">
           Settings
         </h1>                

         <br>

         <!--- Get settings from configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings"> 

         <cfif #settings.recordCount# GT 0>

	   <cfset fee = "#settings.default_fee#">
	   <cfset freq = "#settings.update_freq#">
	   <cfset luceePort = "#application.port#">
 	   <cfset proxyServer = "#settings.proxy_server#">
	   <cfset proxyPort = "#settings.proxy_port#">
	   <cfset provider = "#settings.provider#">
	   <cfset gasLimit = "#settings.gas_limit#">
	   <cfset storageLimit = "#settings.storage_limit#">
	   <cfset transactionFee = "#settings.transaction_fee#">
	   <cfset blockExplorer = "#settings.block_explorer#">
	   <cfset numberOfBlocksToWait = "#settings.num_blocks_wait#">
	   <cfset paymentRetries = "#settings.payment_retries#">
	   <cfset minutesBetweenRetries = "#settings.min_between_retries#">
 

            <div style="text-align: justify;text-justify: inter-word;">
            Here you can ajust Taps configuration to build a custom experience and performance.
            </div>

            <br>

      <table style="width:700px;">
      <cfform>

      <tr style="font-weight:bold;color:black;line-height:50px;"><td>Tezos Related Settings</td></tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Tezos RPC Provider</span><input type="text" class="required" id="idProvider_req" value="&nbsp;Required" readonly>
		       <input type="text" id="idProvider" name="provider" class="input-taps" size="50" placeholder="(Default https://tezos-prod.cryptonomic-infra.tech)" value="#provider#" maxlength="70">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Gas Limit</span><input type="text" class="required" id="idGasLimit_req" value="&nbsp;Required" readonly>
		       <input type="text" id="idGasLimit" name="gasLimit" class="input-taps" size="50" placeholder="(Default 15400)" value="#gasLimit#" maxlength="10">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Storage Limit</span><input type="text" class="required" id="idStorageLimit_req" value="&nbsp;Required" readonly>
		       <input type="text" id="idStorageLimit" name="storageLimit" class="input-taps" size="50" placeholder="(Default 300)" value="#storageLimit#" maxlength="10">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Transaction Fee</span><input type="text" class="required" id="idTransactionFee_req" value="&nbsp;Required" readonly>
		       <input type="text" id="idTransactionFee" name="transactionFee" class="input-taps" size="50" placeholder="(Default 0.00294)" value="#transactionFee#" maxlength="10">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Block Explorer Transaction URL</span><input type="text" class="required" id="idBlockExplorer_req" value="&nbsp;Required" readonly>
		       <input type="text" id="idBlockExplorer" name="blockExplorer" class="input-taps" size="50" placeholder="(Default https://tezblock.io/transaction/)" value="#blockExplorer#" maxlength="70">
		    </label>
		 </td>
		 <td></td>
	      </tr>

      <tr style="font-weight:bold;color:black;line-height:50px;"><td>Baker configuration</td></tr>


	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Default Baker Rewards Fee (%)</span><input type="text" class="required" id="idFee_req" value="&nbsp;Required" readonly>
		       <input type="text" id="idFee" name="fee" class="input-taps" size="50" placeholder="00.00" value="#fee#" maxlength="5">         
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Update Frequency (minutes)</span><input type="text" class="required" id="idFreq_req" value="&nbsp;Required" readonly>
		       <cfinput type="text" id="idFreq" name="freq" class="input-taps" size="50" placeholder="(recommended 10)" value="#freq#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr style="display:none;">
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Lucee Server Port</span><input type="text" class="required" id="idLuceePort_req" value="&nbsp;Required" readonly>
		       <cfinput type="text" id="idLuceePort" name="luceePort" class="input-taps" size="50" placeholder="(Default 8888)" value="#luceePort#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Proxy Server</span><br>
		       <cfinput type="text" id="idProxyServer" name="proxyServer" class="input-taps" size="50" placeholder="(Default No Proxy)" value="#proxyServer#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Proxy Port</span><input type="text" class="required" id="idProxyPort_req" value="&nbsp;Required" readonly>
		       <cfinput type="text" id="idProxyPort" name="proxyPort" class="input-taps" size="50" placeholder="(Default 80)" value="#proxyPort#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

      <tr style="font-weight:bold;color:black;line-height:50px;"><td>Advanced Tweaking</td></tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Number of blocks to wait for blockchain confirmation</span><input type="text" class="required" id="idNumberOfBlocks_req" value="&nbsp;Required" readonly>
		       <cfinput type="text" id="idNumberOfBlocks" name="numberOfBlocks" class="input-taps" size="50" placeholder="(Default 5)" value="#numberOfBlocksToWait#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Number of payment retries after no confirmation</span><input type="text" class="required" id="idPaymentRetries_req" value="&nbsp;Required" readonly>
		       <cfinput type="text" id="idPaymentRetries" name="paymentRetries" class="input-taps" size="50" placeholder="(Default 1)" value="#paymentRetries#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

	      <tr>
		 <td style="padding-left: 20px;">
		    <label>
		       <span class="text-input-taps">Minutes to wait between each payment retry</span><input type="text" class="required" id="idMinutesBetweenRetries_req" value="&nbsp;Required" readonly>
		       <cfinput type="text" id="idMinutesBetweenRetries" name="minutesBetweenRetries" class="input-taps" size="50" placeholder="(Default 1)" value="#minutesBetweenRetries#">
		    </label>
		 </td>
		 <td></td>
	      </tr>

              <tr>
   	         <td style="padding-left: 20px;">
	            <br><button type="button" id="idBtnSave" style="visibility:visible;" class="botao-taps" onClick="javascript: var result = validate(); if (result == true){ hideReqFields(); updateSettings(); } else { showRequiredField(result); }">Save</button></td>
                 </td>
              </tr>

      </cfform>
      </table>


         <cfelse>

            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>

         </cfif>

      </cfoutput>
   </div>
</section>
</body>
</html>
