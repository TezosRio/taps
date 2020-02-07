<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset destination = "">
<cfset amount = "">
<cfset postValidation = "">
<cfset sendIt = "false">
<cfset resultSend = "">
<cfset totalAvailable = "">


<cfif isDefined("form.destination")>
   <cfset destination = "#form.destination#">
<cfelse>
   <cfset destination = "">
</cfif>
<cfif isDefined("form.amount")>
   <cfset amount = "#form.amount#">
<cfelse>
   <cfset amount = "">
</cfif>
<cfif isDefined("form.sendIt")>
   <cfset sendIt = "#form.sendIt#">
<cfelse>
   <cfset sendIt = "false">
</cfif>
<cfif isDefined("session.totalAvailable")>
   <cfset totalAvailable = "#session.totalAvailable#">
<cfelse>
   <cfset totalAvailable = "">
</cfif>

<cfif #sendIt# EQ "true">
   <!--- After-submit validation --->
   <cfset postValidation = "ok">
   <cfif #destination# EQ "" or #amount# EQ "">
      <cfset postValidation = "There are required fields empty">
   </cfif>
   <cfif #isNumeric(amount)# EQ false>
      <cfset postValidation = "There are numeric fields with non-numeric values">
   </cfif>

   <cfif #postValidation# EQ "ok">
      <!--- All right to send funds --->     
      <cfset myWallet = "">
      <cfset passphrase = "">

      <cftry>
         <!--- Check if there is a saved configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            <!--- Decrypt passphrase from the local database with user password --->
	    <cfset passphrase = decrypt('#settings.app_phrase#', '#application.encSeed#')>
         </cfif>

         <!--- Get TezosJ_SDK TezosWallet class --->
         <cfset tezosJ = createObject("java", "milfont.com.tezosj.model.TezosWallet", "./#application.TezosJ_SDK_location#")>

         <!--- Authenticate the owner of wallet with passphrase --->
         <cfinvoke component="components.database" method="authWallet" bakerId="#application.bakerId#" passdw="#passphrase#" returnVariable="authResult">
         <cfif #authResult# EQ true>
            <!--- Instantiate a new wallet from previously saved file --->
            <cfset strPath = ExpandPath( "./" ) />
            <cfset myWallet = tezosJ.init(true, "#strPath#wallet/wallet.taps", "#passphrase#")>
            
            <!--- Change RPC provider --->
            <cfset myWallet.setProvider("#application.provider#")>           
            
            <cfset from = "#myWallet.getPublicKeyHash()#">

            <cfif #from# EQ #destination#>
               <cfset postValidation = "Source and destination address cannot be the same. Operation cancelled">
            <cfelse>
               <!--- Do send funds! --->
               <cfset resultSend = myWallet.send("#from#", "#destination#", #JavaCast("BigDecimal", amount)#, #JavaCast("BigDecimal", application.tz_default_operation_fee)#, "", "")>
            </cfif>
         <cfelse>
            <cfset resultSend = "Authentication failure. Could not open the wallet. Operation cancelled">
         </cfif>

      <cfcatch>
         <cfset resultSend = "There were errors. Operation cancelled">
      </cfcatch>
      </cftry>

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

      <script src="js/angular.min.js"></script>

      <script src="js/jquery-3.2.1.min.js"></script>

      <script language="javascript">
           function isNumeric(n)
           {
              return !isNaN(parseFloat(n)) && isFinite(n);
           }

           function validate()
           {
              if (document.getElementById('idDestination').value == '')
              {
                 return 'idDestination_req';
              }

              if ( (document.getElementById('idDestination').value.substr(0,2).toLowerCase() != 'tz') && (document.getElementById('idDestination').value.substr(0,2).toLowerCase() != 'kt') )
              {
                 return 'idDestination_inv';
              }

              if (document.getElementById('idAmount').value == '')
              {
                 return 'idAmount_req';
              }

              // Validate field types.

	      if ( ! isNumeric(document.getElementById('idAmount').value) )
	      {
	         return 'idAmount_type';
	      }

              var toAmount = document.getElementById('idAmount').value;
              var toAddress = document.getElementById('idDestination').value;

              if (!confirm('Confirm send of ' + toAmount + ' XTZ to ' + toAddress + '?'))
	         return false;


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
              if (sufix == 'inv')
              {
                 document.getElementById(inputFieldName + '_req').value=' Invalid destination address';
              }
              if (sufix == 'req')
              {
                 document.getElementById(inputFieldName + '_req').value=' Required';
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
	      document.getElementById('idDestination_req').style.visibility = "hidden";
	      document.getElementById('idAmount_req').style.visibility = "hidden";
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

   <body ng-app="TAPSApp">
      <section class="box-content-rewards">
      <div  style="width:550px;">
         <cfoutput>

         <h1 class="title-baker">
           Wallet
         </h1>
         <h4>Send funds</h4>
  
         <!--- Check if there is a saved configuration --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            This will send XTZ from your TAPS native wallet.<br>
            Check carefully all fields before proceeding.<br>
            <br>
            <cfform name="form" method="post" action="send_funds.cfm">
               <table>
                  <tr>
                     <td>
                        <label>
	                   <span class="text-input-taps">To address</span><input type="text" class="required" id="idDestination_req" value="&nbsp;Required" readonly><br>
	                   <input type="text" id="idDestination" name="destination" class="input-taps" size="50" placeholder="Type in destination address" value="#destination#" />
	                </label>
                     </td>
                  </tr>
                  <tr>
                     <td>
                        <label>
                           <div ng-controller="MainController">
	                      <span class="text-input-taps">Amount (available:&nbsp; {{balance}} )</span><input type="text" class="required" id="idAmount_req" value="&nbsp;Required" readonly><br>
	                      <input type="text" id="idAmount" name="amount" class="input-taps" size="50" placeholder="Type in amount to send" value="#amount#" />
                           </div>
	                </label>
                     </td>
                  </tr>
		  <tr><td>&nbsp;</td></tr>
		  <tr>
		     <td>
		        <button type="button" class="botao-taps" style="background-color:green;" onClick="javascript: var result = validate(); if (result == true) { hideReqFields(); document.getElementById('idSendIt').value='true'; document.form.submit(); } else { showRequiredField(result); }">CONFIRM</button>
		           &nbsp;&nbsp;<button type="button" class="botao-taps" onClick="jacascript: window.history.back();">CANCEL</button>
		     </td>
		  </tr>
               </table>
               <cfinput name="sendIt" id="idSendIt" type="hidden" value="false">
            </cfform>
            
            <cfif #sendIt# EQ "true" and (#len(resultSend)# GT 0 or #postValidation# NEQ "ok")>
               <cfset message="">
               <cfif #findNoCase("error", resultSend)# GT 0>
                  <cfset message="Sorry, funds could not be sent. There were errors. Operation was cancelled">
               <cfelseif #len(resultSend)# GT 0>
                  <cfset message="Operation successful. Please wait until blockchain confirmation">
               <cfelseif #postValidation# NEQ "ok">
                  <cfset message="#postValidation#">
               </cfif>
               <script language="javascript">
                  alert('#message#');
                  document.getElementById('idDestination').value='';
                  document.getElementById('idAmount').value='';
               </script>
            </cfif>
           
         <cfelse>
            <br>
            There is no configuration saved on settings.<br>
            Please go to SETUP first.<br>
         </cfif>

      </cfoutput>
   </div>
</section>

<!-- Controller -->
<cfoutput>
<script>

var app = angular.module("TAPSApp", []);

var MainController = function ($scope, $http, $interval)
    {
       $scope.balance = "Fetching...";

       $interval(function (i)
       {

         $http.get('http://127.0.0.1:8888/taps/getBalance.cfm').success(function(data, status, headers, config)
         {
  
            $scope.balance = data;

         }).error(function(data, status, headers, config)
         {
            // log error.
         });

       }, 5000);
    };

app.controller("MainController", ["$scope", "$http", "$interval", MainController]);


</script>
</cfoutput>


</body>
</html>
