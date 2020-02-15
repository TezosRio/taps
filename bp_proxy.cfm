<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfoutput>

<cfset result="">

<cfif isDefined("url.status")>

   <cfinvoke component="components.database"
             method="saveBondPoolSettings" 
             returnVariable="result"
             status="#url.status#">
   #result#

<cfelseif isDefined("url.repay") and isDefined("url.cycle")>

   <!--- User has asked to do repay of rewards --->
   <cfif #url.repay# EQ true>
      <cfif #url.cycle# NEQ "">
         
         <cfinvoke component="components.tezosGateway" method="getDelegators" bakerID="#application.bakerId#"
                   fromCycle="#url.cycle - 1#" toCycle="#url.cycle + 1#" returnVariable="myDelegators">

         <!--- Pay rewards again (distribute rewards) --->
         <cfinvoke component="components.taps" method="distributeRewards"
                   localPendingRewardsCycle="#url.cycle#"
                   networkPendingRewardsCycle="#url.cycle + 1#"
                   delegators="#myDelegators#">


      </cfif>
   </cfif>

<cfelseif isDefined("url.settings")>

   <!--- User has asked to save settings --->
   <cfif #url.settings# EQ true>
      <cfif #isDefined("url.proxy_server")# AND
            #isDefined("url.proxy_port")# AND
            #isDefined("url.provider")# AND 
            #isDefined("url.payment_retries")# AND 
            #isDefined("url.gas_limit")# AND 
            #isDefined("url.storage_limit")# AND 
            #isDefined("url.num_blocks_wait")# AND 
            #isDefined("url.block_explorer")# AND 
            #isDefined("url.min_between_retries")# AND 
            #isDefined("url.transaction_fee")# AND
            #isDefined("url.default_fee")# AND
            #isDefined("url.update_freq")# AND
            #isDefined("url.lucee_port")#>
         
         <cfinvoke component="components.database" method="updateSettings"
           bakerID="#application.bakerId#"
           proxy_server="#url.proxy_server#" 
           proxy_port="#url.proxy_port#" 
           provider="#url.provider#"  
           payment_retries="#url.payment_retries#"  
           gas_limit="#url.gas_limit#"  
           storage_limit="#url.storage_limit#"  
           num_blocks_wait="#url.num_blocks_wait#"  
           block_explorer="#url.block_explorer#"  
           min_between_retries="#url.min_between_retries#"  
           transaction_fee="#url.transaction_fee#"
           default_fee="#url.default_fee#"
           update_freq="#url.update_freq#"
           lucee_port="#url.lucee_port#"
           returnVariable="result">

	 <cfset application.proxyServer = "#url.proxy_server#">
	 <cfset application.proxyPort = #url.proxy_port#>
	 <cfset application.provider = "#url.provider#">
	 <cfset application.paymentRetries = #url.payment_retries#>
	 <cfset application.gasLimit = #url.gas_limit#>
	 <cfset application.storageLimit = #url.storage_limit#>
	 <cfset application.numberOfBlocksToWait = #url.num_blocks_wait#>
	 <cfset application.blockExplorer = "#url.block_explorer#">
	 <cfset application.minutesBetweenTries = #url.min_between_retries#>
	 <cfset application.tz_default_operation_fee = "#url.transaction_fee#">
         <cfset application.fee="#url.default_fee#">
         <cfset application.freq="#url.update_freq#">
         <cfset application.port="#url.lucee_port#">



         #result#
      </cfif>
   </cfif>

<cfelse>

   <cfinvoke component="components.database"
             method="bondPoolMemberProxy" 
             returnVariable="result"
             address="#url.address#"
             name="#url.name#"
             amount="#url.amount#"
             fee="#url.fee#"
             ismanager="#url.ismanager#" 
             operation="#url.operation#">
   #result#
</cfif>
</cfoutput>

