<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfscript>
   setLocale("English (us)");
</cfscript>

<cfset hasWallet = false>
<cfset passphrase = "">
<cfset mnemonicWords = "">
<cfset tezosJ = "">
<cfset isCreating = false>
<cfset isImporting = false>
<cfset save = false>
<cfset passdw = "">
<cfset wrongLogin = "">

<cfif isDefined('form.isCreating')>
   <cfset isCreating = #form.isCreating#>
<cfelse>
   <cfset isCreating = false>
</cfif>
<cfif isDefined('form.isImporting')>
   <cfset isImporting = #form.isImporting#>
<cfelse>
   <cfset isImporting = false>
</cfif>
<cfif isDefined('form.passphrase')>
   <cfset passphrase = #trim(form.passphrase)#>
<cfelse>
   <cfset passphrase = "">
</cfif>
<cfif isDefined('form.save')>
   <cfset save = #form.save#>
<cfelse>
   <cfset save = false>
</cfif>
<cfif isDefined('form.passdw')>
   <cfset passdw = #trim(form.passdw)#>
<cfelse>
   <cfset passdw = "">
</cfif>
<cfif isDefined('form.mnemonic')>
   <cfset mnemonicWords = #trim(form.mnemonic)#>
<cfelse>
   <cfset mnemonicWords = "">
</cfif>

<cfif #len(passphrase)# GT 0 and #save# EQ false and #isImporting# EQ false and #len(session.myWallet)# EQ 0>
   <!--- Check if user password is right --->
   <cfinvoke component="components.taps" method="authenticate" user="#getAuthUser()#" passdw="#passdw#" returnVariable="authResult" />

   <cfif #authResult# EQ true>
      <cfset wrongLogin = "">

      <!--- Create a new, fresh native wallet and get its mnemonic words  --->

      <!--- Get TezosJ_SDK TezosWallet class --->
      <cfset tezosJ = createObject("java", "milfont.com.tezosj.model.TezosWallet", "./#application.TezosJ_SDK_location#")>

      <!--- Store TezosJ in session --->
      <cfset session.tezosJ = #tezosJ#>

      <!--- Instantiate a new wallet with the user passphrase --->
      <cfset myWallet = session.tezosJ.init("#passphrase#")>
      
      <!--- Change RPC provider --->
      <cfset myWallet.setProvider("#application.provider#")>           

      <!--- Give an alias to the wallet --->
      <cfset r = myWallet.setAlias("TAPS")>

      <!--- Get Mnemonic words --->
      <cfset mnemonicWords = "#myWallet.getMnemonicwords()#">   

      <!--- Saves the wallet in advance, so we don't have to pass sensitive information through html form submit --->
      <cfset strPath = ExpandPath( "./" ) />
      <cfif Not DirectoryExists("#strPath#/wallet")>
         <cfdirectory action = "create" directory="#strPath#/wallet" />
      </cfif>
      <cfset saveResult = myWallet.save('#strPath#/wallet/wallet.taps')>
   <cfelse>
      <cfset wrongLogin = "true">
   </cfif>
</cfif>

<cfif #len(passphrase)# GT 0 and #len(mnemonicWords)# GT 0 and #isImporting# EQ true and #len(session.myWallet)# EQ 0>

   <!--- User is importing a previously created wallet --->
   <!--- Check if user password is right --->
   <cfinvoke component="components.taps" method="authenticate" user="#getAuthUser()#" passdw="#passdw#" returnVariable="authResult" />

   <cfif #authResult# EQ true>
      <cfset wrongLogin = "">

      <!--- Restore the native wallet from its mnemonic words and passphrase  --->

      <!--- Get TezosJ_SDK TezosWallet class --->
      <cfset tezosJ = createObject("java", "milfont.com.tezosj.model.TezosWallet", "./#application.TezosJ_SDK_location#")>

      <!--- Store TezosJ in session --->
      <cfset session.tezosJ = #tezosJ#>

      <!--- Instantiate a new wallet with the user passphrase and mnemonic words --->
      <cfset session.myWallet = session.tezosJ.init("#mnemonicWords#", "#passphrase#")>

      <!--- Change RPC provider --->
      <cfset session.myWallet.setProvider("#application.provider#")>

      <!--- Saves the wallet in advance, so we don't have to pass sensitive information through html form submit --->
      <cfset strPath = ExpandPath( "./" ) />
      <cfif Not DirectoryExists("#strPath#/wallet")>
         <cfdirectory action = "create" directory="#strPath#/wallet" />
      </cfif>
      <cfset saveResult = session.myWallet.save('#strPath#/wallet/wallet.taps')>

      <!--- Register the wallet hashed passphrase in the local database --->
      <cfinvoke component="components.database" method="saveWallet" bakerId="#application.bakerId#" passphrase="#passphrase#" passdw="#passdw#" returnVariable="resultSaveWallet">

   <cfelse>
      <cfset wrongLogin = "true">
   </cfif>
</cfif>

<!--- If user confirmed by clicking NEXT button, then we will load the previosuly saved wallet --->
<cfif #save# EQ true and #len(session.myWallet)# EQ 0>
   <!--- Register the wallet hashed passphrase in the local database --->
   <cfinvoke component="components.database" method="saveWallet" bakerId="#application.bakerId#" passphrase="#passphrase#" passdw="#passdw#" returnVariable="resultSaveWallet">

   <cfif #resultSaveWallet# EQ true>
      <!--- Instantiate a new wallet (from media) with the user passphrase and mnemonic words --->   
      <cfset strPath = ExpandPath( "./" ) />
      <cfset session.myWallet = session.tezosJ.init(true, "#strPath#/wallet/wallet.taps", "#passphrase#")>

   <cfelse>
      <cfset tezosJ = "">
      <cfset myWallet = "">
   </cfif>
</cfif>

<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
      <meta http-equiv="cache-control" content="no-cache">

      <script src="js/angular.min.js"></script>

      <!-- CSS Bootstrap-->
      <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css"> 
      <!-- CSS Page-->
      <link rel="stylesheet" type="text/css" href="css/estilo.css">

      <script src="js/jquery-3.2.1.min.js"></script>


      <script language="javascript">
           function copyToClipboard(id)
           {
              var copyText = document.getElementById(id);
              copyText.select();
              document.execCommand("copy");
              alert(copyText.value + " copied to clipboard");
           }

           function validateCreate()
           {
              if (document.getElementById('idPassdw').value == '')
              {
                 return 'idPassdw_req';
              }

              if (document.getElementById('idPassphrase').value == '')
              {
                 return 'idPassphrase_req';
              }

              return true;
           }

           function validateImport()
           {
              if (document.getElementById('idPassdw').value == '')
              {
                 return 'idPassdw_req';
              }

              if (document.getElementById('idPassphrase').value == '')
              {
                 return 'idPassphrase_req';
              }

              if (document.getElementById('idMnemonic').value == '')
              {
                 return 'idMnemonic_req';
              }

              if (document.getElementById('idMnemonic').value.match(/\S+/g).length < 15)
              {
                 return 'idMnemonic_req';
              }

              return true;
           }


	   function validateNext()
	   {

              if (!confirm('Did you really write down the passphrase and mnemonic words and now wish to continue to next step?'))
	         return false;
              
              document.getElementById('idMnemonic').value='';
              document.form.save.value=true;
              document.form.submit();
	   }

           function hideButtonNext()
           {
              if (document.getElementById('idNext'))
              {
                 document.getElementById('idNext').disabled = true; 
                 document.getElementById('idNext').style.visibility='hidden';
              }
           }

	   function showRequiredField(field)
	   {
	      var inputFieldName = field.substring(0, field.indexOf('_'));
	      var sufix = field.substring( field.indexOf('_') + 1, field.length );

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
	      document.getElementById('idPassphrase_req').style.visibility = "hidden";
	      document.getElementById('idPassdw_req').style.visibility = "hidden";
              if (document.getElementById('idMnemonic_req'))
                 document.getElementById('idMnemonic_req').style.visibility = "hidden";

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

   <body ng-app="TAPSApp">
      <section class="box-content-rewards">
      <div  style="width:550px;">
         <cfoutput>

         <h1 class="title-baker">
           Wallet
         </h1>                

         <!--- Get settings --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">

         <cfif #settings.recordCount# GT 0>
            <cfif #len(session.myWallet)# GT 0>
               <!--- User has configured TAPS successfully and also created a native wallet --->
               <cfset hasWallet = true>
            <cfelse>
               <cfset hasWallet = false>
            </cfif>

		 <!--- Change what it will display, according to if has wallet or not --->
		 <cfif #hasWallet# EQ false>

		    <cfform name="form" action="wallet.cfm" method="post">

		       <cfif #isCreating# EQ false and #isImporting# EQ false and #settings.funds_origin# EQ "native">
		          <br><br><br><br><br><br>
		          <center>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp
		             <button type="button" class="botao-taps" style="width:300px;" onClick="document.getElementById('idCreating').value=true;document.form.submit();">CREATE NEW WALLET</button>
		          </center>
                          <br>
		          <center>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp
		             <button type="button" class="botao-taps" style="width:300px;" onClick="document.getElementById('idImporting').value=true;document.form.submit();">IMPORT WALLET</button>
		          </center>
		       <cfelseif #isCreating# EQ true and #isImporting# EQ false>
		          WARNING: Write down in a piece of paper all information displayed on this page
		          (passphrase and mnemonic words) and store it in a safe place. It will be required
		          in order to access your wallet and move your funds in the future.<br>
		          <br>

		          <table>
		             <tr>
		                <td>
		                   <label>
                                      <cfif #len(wrongLogin)# EQ 0>
                                         <cfset reqFieldContents = "&nbsp;Required">
                                         <cfset reqVisibility = "hidden">
                                      <cfelse>
                                         <cfset reqFieldContents = "Wrong password">
                                         <cfset reqVisibility = "visible">
                                      </cfif> 
			              <span class="text-input-taps">TAPS Login password</span><input type="text" class="required" id="idPassdw_req" value="#reqFieldContents#" readonly style="visibility: #reqVisibility#;">
			              <input type="password" id="idPassdw" name="passdw" class="input-taps" size="50" placeholder="Type your TAPS login password" value="#passdw#" />
			           </label>
		                </td>
		             </tr>
		             <tr>
		                <td>
		                   <label>
			              <span class="text-input-taps">Wallet passphrase</span><input type="text" class="required" id="idPassphrase_req" value="&nbsp;Required" readonly>
			              <input type="text" id="idPassphrase" name="passphrase" class="input-taps" size="50" placeholder="Type a passphrase" value="#passphrase#" onChange="hideButtonNext();" onKeyDown="hideButtonNext();" />
			           </label>
		                </td>
		             </tr>
		             <tr>
		                <td>
		                   <button type="button" id="idCreate" class="botao-taps" onClick="javascript: var result = validateCreate(); if (result == true){ hideReqFields(); document.getElementById('idCreating').value=true; document.form.submit(); } else { showRequiredField(result); }">CREATE NEW WALLET</button>
		                </td>
		             </tr>
		             <tr><td>&nbsp;</td></tr>
		             <tr>
		                <td>
		                   <label>
			              <span class="text-input-taps">Mnemonic words</span>
		                      <textarea name="mnemonic" id="idMnemonic" cols="50" rows="3" style="padding-left:10px;padding-top:10px;" readonly>#mnemonicWords#</textarea>
			           </label>                   
		                </td>
		             </tr> 
		             <tr>
		                <td>
		                   <label>
		                      <cfif #len(mnemonicWords)# GT 0>
		                         <button type="button" id="idNext" class="botao-taps" onClick="validateNext();">NEXT</button>
		                      </cfif>
			           </label>                   
		                </td>
		             </tr> 

		          </table>

		       <cfelseif #isImporting# EQ true and #isCreating# EQ false>
                          Please enter your previously created wallet details: TAPS login password, passphrase,
                          and mnemonic words, separated by spaces.
		          <br>

		          <table>
		             <tr>
		                <td>
		                   <label>
                                      <cfif #len(wrongLogin)# EQ 0>
                                         <cfset reqFieldContents = "&nbsp;Required">
                                         <cfset reqVisibility = "hidden">
                                      <cfelse>
                                         <cfset reqFieldContents = "Wrong password">
                                         <cfset reqVisibility = "visible">
                                      </cfif> 
			              <span class="text-input-taps">TAPS Login password</span><input type="text" class="required" id="idPassdw_req" value="#reqFieldContents#" readonly style="visibility: #reqVisibility#;">
			              <input type="password" id="idPassdw" name="passdw" class="input-taps" size="50" placeholder="Type your TAPS login password" value="#passdw#" />
			           </label>
		                </td>
		             </tr>
		             <tr>
		                <td>
		                   <label>
			              <span class="text-input-taps">Wallet passphrase</span><input type="text" class="required" id="idPassphrase_req" value="&nbsp;Required" readonly>
			              <input type="text" id="idPassphrase" name="passphrase" class="input-taps" size="50" placeholder="Type a passphrase" value="" />
			           </label>
		                </td>
		             </tr>
		             <tr><td>&nbsp;</td></tr>
		             <tr>
		                <td>
		                   <label>
			              <span class="text-input-taps">Mnemonic words</span><input type="text" class="required" id="idMnemonic_req" value="&nbsp;Required" readonly style="visibility:hidden;">
		                      <textarea name="mnemonic" id="idMnemonic" cols="50" rows="3" style="padding-left:10px;padding-top:10px;"></textarea>
			           </label>                   
		                </td>
		             </tr> 
		             <tr>
		                <td>
		                   <label>
		                      <button type="button" id="idImport" class="botao-taps"  onClick="javascript: var result = validateImport(); if (result == true){ hideReqFields(); document.getElementById('idImporting').value=true; document.form.submit(); } else { showRequiredField(result); }">IMPORT WALLET</button>
			           </label>
                                   &nbsp;&nbsp; Total word count: &nbsp; <span id="display_count">0</span> words.                   
		                </td>
		             </tr> 

		          </table>


			<script>

			$(document).ready(function() {
			  $("##idMnemonic").on('keyup', function() {
			    var words = this.value.match(/\S+/g).length;

			    if (words > 15)
			    {
			      var trimmed = $(this).val().split(/\s+/, 15).join(" ");
			      $(this).val(trimmed + " ");
			    }
			    else
			    {
			      $('##display_count').text(words);
			      $('##word_left').text(15-words);
			    }
			  });
			});

			</script>


                       <cfelseif #settings.funds_origin# EQ "node">
                          <br><br><br>
                          TAPS has been configured to run with node resources.
		       </cfif>

		       <cfinput name="isCreating" id="idCreating" type="hidden" value="false">
		       <cfinput name="isImporting" id="idImporting" type="hidden" value="false">
		       <cfinput name="save" id="idSave" type="hidden" value="false">
		    </cfform>

		 <cfelse>

		    <cfif #len(session.myWallet)# GT 0>
		       <cfform name="form" action="wallet.cfm" method="post">
		       <table>
		          <tr><td>&nbsp;</td></tr>
		          <tr>
		             <td>
                                <span class="text-input-taps">Address</span><br>
                                <div class="input-group add-on" style="width:480px;">
                                   <input type="text" id="idAddress" name="address" class="input-taps form-control" size="45" value="#session.myWallet.getPublicKeyHash()#" readonly >
                                   <div class="input-group-btn">
                                      <button style="background:none;border:none;margin-top:-2px;outline:none;" id="idCopyToClipboard" onClick="javascript:copyToClipboard('idAddress');"><img src="./imgs/clipboard.png" style="cursor:pointer;border:hidden;"></button>
                                   </div>
                                </div>
		             </td>
		          </tr>
		          <tr><td>&nbsp;</td></tr>
		          <tr>
		             <td>
		                <label>
			           <span class="text-input-taps">Balance</span>
                                   <div ng-controller="MainController">
                                      <input type="text" id="idBalance" name="balance" class="input-taps" style="text-align:center;font-size:32px;height:100px;width:475px;" size="50" value="{{balance}}" readonly />
                                   </div>

			        </label>
		             </td>
		          </tr>
		          <tr><td>&nbsp;</td></tr>
		          <tr>
		             <td>
		                <button type="button" class="botao-taps" onClick="document.location.href='send_funds.cfm';">SEND</button>
		                &nbsp;&nbsp;<button type="button" class="botao-taps" onClick="document.location.href='receive_funds.cfm';">RECEIVE</button>
		             </td>
		          </tr> 
		        
		       </table>
		       </cfform>

		    <cfelse>
		       Could not load the configured wallet.
		    </cfif>

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

         $http.get('http://127.0.0.1:#application.port#/taps/getBalance.cfm').success(function(data, status, headers, config)
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
