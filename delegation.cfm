<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfoutput>

<cfset result="">

<cfif isDefined("url.delegate")>

   <!--- User has asked to delegate --->
   <cfif #url.delegate# EQ true>
      <cfif #isDefined("url.delegator")#  AND
            #isDefined("url.delegate_to")#>

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

            <!--- Delegate  --->
            <cfset result = myWallet.delegate("#url.delegator#", "#url.delegate_to#", #JavaCast("BigDecimal", application.tz_default_operation_fee)#, "#application.gasLimit#", "#application.storageLimit#")>

            <!--- Extract transaction hash from result --->
            <cfset resultStruct = #deserializeJson(result)#>
            <cfset transactionHash = "#replace(resultStruct.result, chr(34), '', 'all')#">
            <cfif (#findNoCase("error", transactionHash)# GT 0) OR (#len(transactionHash)# LT 40) OR (#len(transactionHash)# GT 60)>
               #transactionHash#
            <cfelse>
               <!--- Save delegate information on local database --->
               <cfinvoke component="components.database" method="updateDelegate" bakerID="#application.bakerId#" delegate="#url.delegate_to#" returnVariable="result">
               true
            </cfif> 
                 
         <cfelse>
            false
         </cfif>

      <cfcatch>
         false
      </cfcatch>
      </cftry>

         
      </cfif>
   </cfif>

<cfelseif isDefined("url.undelegate")>

   <!--- User has asked to undelegate --->
   <cfif #url.undelegate# EQ true>
      <cfif #isDefined("url.delegator")#>

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

            <!--- Undelegate  --->
            <cfset result = myWallet.undelegate("#url.delegator#", #JavaCast("BigDecimal", application.tz_default_operation_fee)#)>

            <!--- Extract transaction hash from result --->
            <cfset resultStruct = #deserializeJson(result)#>
            <cfset transactionHash = "#replace(resultStruct.result, chr(34), '', 'all')#">
            <cfif (#findNoCase("error", transactionHash)# GT 0) OR (#len(transactionHash)# LT 40) OR (#len(transactionHash)# GT 60)>
               #transactionHash#
            <cfelse>
               <cfinvoke component="components.database" method="updateDelegate" bakerID="#application.bakerId#" delegate="" returnVariable="result">
               true
            </cfif> 

         <cfelse>
            false
         </cfif>

      <cfcatch>
         false
      </cfcatch>
      </cftry>

         
      </cfif>
   </cfif>

</cfif>
</cfoutput>

