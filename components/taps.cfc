<!---

   Component : taps.cfc
   Author    : Luiz Milfont
   Date      : 01/24/2019
   Usage     : This component is used to perfome business-tied operations.
   
--->


<cfcomponent name="taps">

   <!--- Constants --->
   <cfset rewardsDelivered="rewards_delivered">
   <cfset rewardsPending="rewards_pending">
   <cfset twentyFourHours = 86400> <!--- In seconds --->
   <cfset tenMinutes = 600> <!--- In seconds --->
   <cfset fiftySeconds = 50>
   <cfset twoMinutes = 120000> <!--- In miliseconds --->
   <cfset threeMinutes = 180000> <!--- In miliseconds --->
   <cfset tenMinutesMili = 600000> <!--- In miliseconds --->

   <!--- Methods ---> 

   <!--- This is the TAPS core routine. It distributes the share of the rewards to the delegators  --->
   <!--- Some information is stored in the local database in the process, so it is possible to check them later --->
   <!--- Log files with the results from transactions are also written, in the folder taps/logs --->
   <!--- When operating in Simulation mode, everything will be recorded, but payments will not be made for real --->
   <cffunction name="distributeRewards">
      <cfargument name="localPendingRewardsCycle" required="true" type="number" />
      <cfargument name="networkPendingRewardsCycle" required="true" type="number" />
      <cfargument name="delegators" required="true" type="query" />

      <cfset var paymentDate = #dateFormat(now(),'mm-dd-yyyy')#>
      <cfset var settings = "">
      <cfset var operationMode = "">
      <cfset var operationResultOutput = "">
      <cfset var strPath = "">
      <cfset var myWallet = "">
      <cfset var from = "">
      <cfset var TezosJ = "">
      <cfset var passphrase = "">
      <cfset var defaultFee = 0>
      <cfset var transactionHash = "">
      <cfset var blockchainConfirmed = false>
      <cfset var tries = 1>
      <cfset var logOutput = "">

      <!--- Override Lucee Administrator settings for request timeout --->
      <cfsetting requestTimeout = #twentyFourHours#>

      <!--- If we got here, it's because the Tezos blockchain has just delivered rewards for this cycle --->      
      <!--- So, we must update the local database payments table with date and status (rewards_delivered) for this cycle --->     
      <cfquery name="update_local" datasource="ds_taps">   
          UPDATE payments SET
             DATE = parsedatetime(<cfqueryparam value="#paymentDate#" sqltype="CF_SQL_VARCHAR" maxlength="20">, 'MM-dd-yyyy'),
             RESULT = '#rewardsDelivered#'
             WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
             AND CYCLE = <cfqueryparam value="#arguments.localPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">
      </cfquery>

      <!--- We must also insert a new line with status rewards_pending for the next cycle --->
      <!--- Unless there is already a line with that information (it may happen in some ocasions) --->
      <cfquery name="check_pending" datasource="ds_taps">   
         SELECT BAKER_ID FROM payments
         WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         AND   CYCLE = <cfqueryparam value="#arguments.networkPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">
      </cfquery>
      <cfif #check_pending.recordcount# EQ 0> <!--- There is no line yet, so insert a new one --->
         <cfquery name="save_local_pending" datasource="ds_taps">   
            INSERT INTO payments (BAKER_ID, CYCLE, DATE, RESULT, TOTAL)
   	    VALUES
	    (
	       <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
               <cfqueryparam value="#arguments.networkPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">,
	       parsedatetime(<cfqueryparam value="#paymentDate#" sqltype="CF_SQL_VARCHAR" maxlength="20">, 'MM-dd-yyyy'),
              '#rewardsPending#',
	      0
            )
         </cfquery>
      </cfif>
     
      <!--- Create the logs folder, if it does not exist yet --->
      <cfset strPath = ExpandPath( "./" ) />
      <cfif Not DirectoryExists("#strPath#/logs")>
         <cfdirectory action = "create" directory="#strPath#/logs" />
      </cfif>

      <!--- Get information about which mode TAPS is working in (Simulation or On) --->
      <cfinvoke component="components.database" method="getSettings" returnVariable="settings">
      <cfif #settings.recordCount# GT 0>
         <cfset operationMode = #settings.mode#>
         <cfset defaultFee = #settings.default_fee#>
      <cfelse>
         <cfset operationMode = "#application.mode_desc_try#">
      </cfif>

      <!--- Decide what will be the operation result output for log purposes, according to the configured mode --->
      <cfif #operationMode# EQ "#application.mode_desc_try#">
         <cfset operationResultOutput="simulated">
      <cfelseif #operationMode# EQ "#application.mode_desc_yes#">
         <cfset operationResultOutput="not available">
      <cfelse> <!--- fallback is simulation mode --->
         <cfset operationResultOutput="simulated"> 
      </cfif>


      <!--- Instantiate TezosJ_SDK_plainJava and open the wallet --->
      <cfset strPath = ExpandPath( "./" ) />

      <!--- Get TezosJ_SDK TezosWallet class --->
      <cfset tezosJ = createObject("java", "milfont.com.tezosj.model.TezosWallet", "#strPath#/#application.TezosJ_SDK_location#")>

      <!--- Decrypt passphrase from the local database with app password --->
      <cfset passphrase = decrypt('#settings.app_phrase#', '#application.encSeed#')>

      <!--- Authenticate the owner of wallet with passphrase --->
      <cfinvoke component="components.database" method="authWallet" bakerId="#application.bakerId#" passdw="#passphrase#" returnVariable="authResult">
      <cfif #authResult# EQ true>
         <!--- Instantiate a new wallet from previously saved file --->
         <cfset myWallet = tezosJ.init(true, "#strPath#/wallet/wallet.taps", "#passphrase#")>
               
         <!--- Change RPC provider --->
         <cfset myWallet.setProvider("#application.provider#")>
         <cfset from = "#myWallet.getPublicKeyHash()#">
      </cfif>


   <!--- Main rewards distribution loop --->
   <!--- Will try to pay until there is a blockchain confirmation OR the number of tries reaches limit --->
   <cftry>
   <cfloop condition="(#blockchainConfirmed# EQ false) AND (#tries# LTE #application.paymentRetries#)">

      <!--- Create/Clear new log files --->
      <cffile file="../logs/payments_#arguments.localPendingRewardsCycle#.log" action="write" output="" nameConflict="overwrite" mode="777">
      <cffile file="../logs/last_error_#arguments.localPendingRewardsCycle#.log" action="write" output="" nameConflict="overwrite" mode="777">
      <cffile file="../logs/batch_result_#arguments.localPendingRewardsCycle#.log" action="write" output="" nameConflict="overwrite" mode="777">
      <cffile file="../logs/bondPool_transactions_#arguments.localPendingRewardsCycle#.log" action="write" output="" nameConflict="overwrite" mode="777">

      <!--- Initiate totalPaid variable with zero --->
      <cfset totalPaid = 0>

      <!--- Clear table delegatorsPayments for the current cycle --->
      <cfquery name="save_local_pending" datasource="ds_taps">   
         DELETE FROM delegatorsPayments
         WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         AND   CYCLE = <cfqueryparam value="#arguments.localPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">
      </cfquery>

     <!--- Initialize/Clear TezosJ_SDK Transaction Batch --->
     <cfset void = myWallet.clearTransactionBatch()>

      <!--- Inner rewards distribution loop --->
      <!--- Loop through delegators and mount a collection (batch) of transactions that will be sent later --->  
      <cfloop query="#arguments.delegators#">
         <!--- We always keep 3 cycles of rewards information in the local database, so we have to get only the rewards --->
         <!--- corresponding to the pending_rewards cycle --->
         <cfif #arguments.delegators.cycle# EQ #arguments.localPendingRewardsCycle#> <!--- Filter for the current cycle --->
               <!--- Initialize individual delegator's payment value with zero --->
               <cfset paymentValue = 0>

               <!--- Calculate indivudual delegator's payment considering custom fee --->
               <cfquery name="local_get_fee" datasource="ds_taps">
                  SELECT FEE FROM delegatorsFee
                  WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
                  AND   ADDRESS  = <cfqueryparam value="#delegators.address#" sqltype="CF_SQL_VARCHAR" maxlength="50"> 
               </cfquery>

               <!--- If there is a fee stored in the local database for this delegator, use it. Otherwise, use default fee --->
               <cfif #local_get_fee.recordCount# GT 0>
                  <cfset paymentValue = #((arguments.delegators.rewards / application.militez) * ((100 - local_get_fee.fee) / 100) * 100) / 100#>
               <cfelse>
                  <cfset paymentValue = #((arguments.delegators.rewards / application.militez) * ((100 - defaultFee) / 100) * 100) / 100#>
               </cfif>
                      
               <!--- If operation mode is ON, then adds a transaction to the batch --->
               <cfif #operationMode# EQ "#application.mode_desc_yes#">

                  <!--- Only consider a payment valid if value is higher than zero --->
                  <cfif #paymentValue# GT 0>

	                <!--- Add payment transaction information to transaction batch (for sending later) --->
	                <cfset void = myWallet.addTransactionToBatch("#from#", "#arguments.delegators.address#", #JavaCast("BigDecimal", paymentValue)#, #JavaCast("BigDecimal", application.tz_default_operation_fee)#)>

                        <!--- Define the message that will be saved in the log ---> 
                        <cfset logOutput = "Added send transaction: #paymentValue# tez from #from# to #arguments.delegators.address#"> 

                  <cfelse> <!--- Nothing to be paid, value is zero --->

                     <!--- Define the message that will be saved in the log ---> 
                     <cfset logOutput = "Ignored send to #arguments.delegators.address# as value is 0"> 

                  </cfif>


               <cfelse> <!--- Simulation mode --->

                  <!--- Only consider a payment valid if value is higher than zero --->
                  <cfif #paymentValue# GT 0>
                     <!--- Define the message that will be saved in the log ---> 
                     <cfset logOutput = "Simulated send #paymentValue# tez from #from# to #arguments.delegators.address#"> 
                  <cfelse> <!--- Nothing to be paid, value is zero --->
                     <!--- Define the message that will be saved in the log ---> 
                     <cfset logOutput = "Simulation ignored send to #arguments.delegators.address# as value is 0"> 
                  </cfif>

               </cfif>


               <cfoutput>
               <!--- Write log file with results in folder taps/logs --->
               <cffile file="../logs/payments_#arguments.localPendingRewardsCycle#.log" action="append" output="#logOutput#">

               <!--- Save the delegator payment information in the local database --->
               <cfquery name="save_local_pending" datasource="ds_taps">   
		    INSERT INTO delegatorsPayments (BAKER_ID, CYCLE, ADDRESS, DATE, RESULT, TOTAL, TRANSACTION_HASH)
		    VALUES
		    (
		        <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
                        <cfqueryparam value="#arguments.localPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">,
                        <cfqueryparam value="#arguments.delegators.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
        		parsedatetime(<cfqueryparam value="#paymentDate#" sqltype="CF_SQL_VARCHAR" maxlength="20">, 'MM-dd-yyyy'),
                        '#operationResultOutput#',
                        <cfqueryparam value="#paymentValue#" sqltype="CF_SQL_NUMERIC" maxlength="50">,
                        <cfqueryparam value="#transactionHash#" sqltype="CF_SQL_VARCHAR" maxlength="70">
		    )
		</cfquery>

                <!--- Accumulate the total paid --->
                <cfset totalPaid = totalPaid + #paymentValue#>
                </cfoutput>

         </cfif> <!--- Filter for the current cycle --->
      </cfloop> <!--- Loop through delegators --->


      <!--- At this point we've got an entire collection (batch) of transactions ready to send --->

      <!--- If Taps operation mode is set to ON, then we will send transaction batch for real, otherwise we won't --->
      <cfif #operationMode# EQ "#application.mode_desc_yes#">

         <cftry>
            <!--- Send transaction batch to Tezos blockchain, using funds from native wallet, with TezosJ_SDK_plainJava library --->
            <cfset resultJson = myWallet.flushTransactionBatch("#application.gasLimit#", "#application.storageLimit#")>

            <!--- Extract transaction hash from result --->
            <cfset resultStruct = #deserializeJson(resultJson)#>
            <cfset transactionHash = "#replace(resultStruct.result, chr(34), '', 'all')#">

            <cfif (#findNoCase("error", transactionHash)# GT 0) OR (#len(transactionHash)# LT 40) OR (#len(transactionHash)# GT 60)>
               <cfthrow message = "#transactionHash#">
            </cfif>

            <!--- Wait for and check if batch transaction was confirmed in Tezos blockchain --->
            <cfset blockchainConfirmed = myWallet.waitForAndCheckResult("#transactionHash#", #application.numberOfBlocksToWait#)>
         <cfcatch>
            <cfset blockchainConfirmed = false>

            <!--- Save to log the error information --->
            <cffile file="../logs/last_error_#arguments.localPendingRewardsCycle#.log" action="append" output="#cfcatch.message# #cfcatch.detail#">

         </cfcatch>
         </cftry>
      </cfif>

      <!--- If there the transaction failed in Tezos blockchain, wait some minutes and try again --->
      <cfif #blockchainConfirmed# EQ false>
         <!--- Waits some minutes until next try --->
         <cfsleep time = "#(application.minutesBetweenTries * 60) * 1000#"> 

         <!--- Updates the number of payment tries --->
         <cfset tries = tries + 1>
      </cfif>

    </cfloop> <!--- Tries to pay until there is a blockchain confirmation OR reached maximum number of times --->
    <cfcatch>
       <cfset blockchainConfirmed = false>

      <!--- Save to log the error information --->
      <cffile file="../logs/last_error_#arguments.localPendingRewardsCycle#.log" action="append" output="#cfcatch.message# #cfcatch.detail#">

    </cfcatch>
    </cftry>
   

    <!--- If Taps operation mode is set to ON... --->
    <cfif #operationMode# EQ "#application.mode_desc_yes#">

       <!--- Save to log the information of blockchain confirmation of the sent transaction batch --->
       <cffile file="../logs/batch_result_#arguments.localPendingRewardsCycle#.log" action="append" output="Applied: #blockchainConfirmed# Hash: #transactionHash#">
      
       <!--- Then, update the payments result, total and transaction hash, in the local database --->
       <cfquery name="update_local" datasource="ds_taps">   
             UPDATE payments SET
                <cfif #blockchainConfirmed# EQ true>RESULT = 'paid'<cfelse>RESULT = 'errors'</cfif>,
                TOTAL = #totalPaid#,
                <cfif #len(transactionHash)# GT 45 AND #len(transactionHash)# LT 60>TRANSACTION_HASH = <cfqueryparam value="#transactionHash#" sqltype="CF_SQL_VARCHAR" maxlength="70"><cfelse>TRANSACTION_HASH = ''</cfif>
             WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
             AND CYCLE = <cfqueryparam value="#arguments.localPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">
             AND DATE = parsedatetime(<cfqueryparam value="#paymentDate#" sqltype="CF_SQL_VARCHAR" maxlength="20">, 'MM-dd-yyyy')
        </cfquery>

        <!--- Update the delegatorsPayments result and hash, in the local database --->
        <cfquery name="update_local_delegatorsPayments" datasource="ds_taps">   
             UPDATE delegatorsPayments SET
                <cfif #blockchainConfirmed# EQ true>RESULT = 'applied'<cfelse>RESULT = 'failed'</cfif>,
                <cfif #len(transactionHash)# GT 45 AND #len(transactionHash)# LT 60>TRANSACTION_HASH = <cfqueryparam value="#transactionHash#" sqltype="CF_SQL_VARCHAR" maxlength="70"><cfelse>TRANSACTION_HASH = ''</cfif>
             WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
             AND CYCLE = <cfqueryparam value="#arguments.localPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">
             AND DATE = parsedatetime(<cfqueryparam value="#paymentDate#" sqltype="CF_SQL_VARCHAR" maxlength="20">, 'MM-dd-yyyy')
        </cfquery>
    <cfelse>
       <!--- Save to log the information that there were no transactions, as we are simulating --->
       <cffile file="../logs/batch_result_#arguments.localPendingRewardsCycle#.log" action="append" output="Simulation only. No transactions were sent to Tezos blockchain.">
    </cfif>

       <!--- v1.0.3 BONDPOOLERS PAYMENT --->

       <!--- Bondpoolers payment will only be done if delegators payments were successfull, so check it --->
       <cfif #blockchainConfirmed# EQ true>

       <!--- Check if configuration is set to do bondpoolers payment --->
       <cfinvoke component="components.database" method="getBondPoolSettings" returnVariable="bondPoolSettings">

       <cfif #bondPoolSettings.status# EQ true>
          
          <!--- Check if there is any bondpool member configured in local database --->
          <cfinvoke component="components.database" method="getBondPoolMembers" sortForPayment="true" returnVariable="members">
    
          <cfif #members.recordCount# GT 0>

             <!--- Check if delegators got paid, otherwise abort (as it would distribute all rewards to bondpoolers) --->
	     <cfif #totalPaid# GT 0>

               <!--- Wait for operation to finish safely before going into another one --->
               <cfsleep time = "#threeMinutes#">
	     
	       <cfset var totalCycleRewards = 0>
	       <cfset var totalDelegatorRewardsPaid = 0>
	       <cfset var poolRewardsTotal = 0>
	       <cfset var totalBond = 0>
	       <cfset var bond = 0>
	       <cfset var members = "">
	       <cfset var memberShare = 0>
	       <cfset var memberRewardsBeforeFee = 0>
	       <cfset var admFee = 0>
	       <cfset var memberRewardsPayment = 0>
	       <cfset var totalAdmFees = 0>
	       <cfset var poolAdministrator = 0>

	       <!--- Get total cycle rewards --->
	       <cfinvoke component="components.tezosGateway"
		         method="getBakersRewardsInCycle"
		         bakerId="#application.bakerId#" cycle="#arguments.localPendingRewardsCycle#"
		         returnVariable="totalCycleRewards">

	       <!--- Get total paid to delegators --->
	       <cfset totalDelegatorRewardsPaid = #totalPaid#>


	       <!--- Calculate Pool Rewards to distribute --->
	       <cfset poolRewardsTotal = #val(totalCycleRewards) - totalDelegatorRewardsPaid#>

	       <!--- Get total bond pool stake --->
	       <cfinvoke component="components.database" method="getTotalBondPoolStake" returnVariable="totalBond">       
	       <cfset bond = #val(totalBond)#>

	       <!--- Get list of bond pool members from local database --->
	       <cfinvoke component="components.database" method="getBondPoolMembers" sortForPayment="true" returnVariable="members">

	       <!--- Initialize TezosJ_SDK Transaction Batch --->
	       <cfset void = myWallet.clearTransactionBatch()>

	       <!--- Loop through list of bondpoolers from local database, ordered by total and isManager --->
	       <cfloop query="members">

		    <!--- Get member share --->
		    <cfset memberShare = #(members.amount / bond) * 100#>

		    <!--- Calculate member individual rewards according to its share (% over pool rewards) --->
		    <cfset memberRewardsBeforeFee = #(poolRewardsTotal * memberShare)/100#>

		    <!--- Calculate administrative fee --->
		    <cfset admFee = #memberRewardsBeforeFee * (members.adm_charge/100)#>

		    <!--- Subtract from the individual rewards the administrative fee --->
		    <cfset memberRewardsPayment =  #memberRewardsBeforeFee - admFee#>

		    <!--- Sum total administrative fee --->
		    <cfset totalAdmFees =  #totalAdmFees + admFee#>

                    <cfif #memberRewardsPayment# GT 0>
		       <!--- Add payment transaction information to transaction batch --->
		       <cfset void = myWallet.addTransactionToBatch("#from#", "#members.address#", #JavaCast("BigDecimal", memberRewardsPayment)#, #JavaCast("BigDecimal", application.tz_default_operation_fee)#) >
                    </cfif>

		    <!--- Identifies pool administrator --->
		    <cfif #members.is_manager# EQ true>
		       <cfset poolAdministrator = "#members.address#">

		       <!--- This is a guarantee that there can be only one pool manager --->
		       <cfbreak>
		    </cfif>

	       </cfloop>
	       
               <cfif #totalAdmFees# GT 0>
	          <!--- Add a transaction to pay administrative fees to the manager --->
	          <cfset void = myWallet.addTransactionToBatch("#from#", "#poolAdministrator#", #JavaCast("BigDecimal", totalAdmFees)#, #JavaCast("BigDecimal", application.tz_default_operation_fee)#) >
               </cfif>

	       <!--- If Taps operation mode is set to ON, then send transaction batch for real, otherwise, don't --->
	       <cfif #operationMode# EQ "#application.mode_desc_yes#">
		  <!--- Send transaction batch to Tezos blockchain, using funds from native wallet, with TezosJ_SDK_plainJava library --->
		  <cfset result = myWallet.flushTransactionBatch()>

   	          <!--- Wait for operation to finish safely --->
	          <cfsleep time = "#tenMinutesMili#">

	       <cfelse>
		  <cfset transactions = myWallet.getTransactionList()>
                  <cfset strPath = ExpandPath( "./" ) />
                  <cfif Not DirectoryExists("#strPath#/logs")>
                     <cfdirectory action = "create" directory="#strPath#/logs" />
                  </cfif>

		  <cfloop array="#transactions#" index="i">
		     <cffile file="../logs/bondPool_transactions_#arguments.localPendingRewardsCycle#.log" action="append" output="#i.getFrom()#, #i.getTo()#, #i.getAmount()#, #i.getFee()# ">
		  </cfloop>
	       </cfif>

             </cfif>
          </cfif>
       </cfif> <!--- Bondpool Settings status is true? --->
       </cfif> <!--- Delegators payments was successfull? --->
       <!--- v1.0.3 BONDPOOLERS PAYMENT --->



       <!--- "Close" the native wallet --->
       <cfset myWallet = "">
       <cfset TezosJ = "">

      <!--- Restore default Lucee Administrator settings for request timeout --->
      <cfsetting requestTimeout = #fiftySeconds#>

   </cffunction>


   <cffunction name="authenticate" returnType="any">
      <cfargument name="user" required="true" type="string" />
      <cfargument name="passdw" required="true" type="string" />

      <cfset var result = false>

      <cftry>
	      <!--- Verify if there is no user configured yet --->
	      <cfquery name="verify_configured_user" datasource="ds_taps">
		 SELECT pass_hash, hash_salt
		 FROM settings
	      </cfquery>

	      <!--- If there is a user and also a saved password hash --->
	      <cfif (#verify_configured_user.recordcount# GT 0) and (#len(verify_configured_user.pass_hash)# GT 0)>
		 <!--- Verify if the hash matches --->
		 <cfset salt = #verify_configured_user.hash_salt#>
		 <cfset hashedPassword = Hash(#arguments.passdw# & #salt#, "SHA-512") />

		 <cfif #verify_configured_user.pass_hash# EQ #hashedPassword#>
		    <cfset result = true>
		 </cfif>

	      <cfelse>
		 <cfif #arguments.user# eq "admin" and #arguments.passdw# EQ "admin">
		    <cfset result = true>
		 </cfif>
	      </cfif>

	      <cfif #result# EQ true>
		 <cfset application.user = "#arguments.user#">
	      </cfif>

      <cfcatch>
         <cfset result = "db_error">
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Create Scheduled task to query Tezos network from time to time --->
   <!--- This is the heart of TAPS. This is responsible to detect when a cycle changes --->
   <cffunction name="createScheduledTask" returnType="boolean">
      <cfargument name="port" required="true" type="number">

      <cfset var result = false>
      <cfset var settings = "">
      <cfset var interval = 0>

      <cftry>

         <!--- Get the user-configured fetch interval from local database --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">
        
         <cfif #settings.recordCount# GT 0>

            <!--- Convert to seconds --->
            <cfset interval = #settings.update_freq# * 60>

            <cfschedule
                  action = "update"
                  task = "fetchTzScan"
                  interval = "#interval#"
                  port = "#arguments.port#"
                  proxyServer="#application.proxyServer#"
                  proxyPort="#application.proxyPort#"
                  publish = "no"
                  startDate = "01/01/1970"
                  startTime = "00:00 AM"
                  url="http://127.0.0.1:#application.port#/taps/script_fetch.cfm"
                  operation="HTTPRequest" />

            <!--- After creating the scheduled task, we run it for the first time, to populate local database --->
            <cfschedule
                  action = "run"
                  task = "fetchTzScan" />
         
            <cfset result = true>
 
        <cfelse>
            <cfset result = false>
         </cfif>

      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- This method do a factory-reset on the system --->
   <!--- It will clear all data previously stored in local database. But will not delete the logs in folder taps/logs --->
   <!--- It will delete the scheduled task that fetches Tezos network --->
   <cffunction name="resetTaps" returnType="boolean">
      <cfargument name="user" required="true" type="string" />
      <cfargument name="passdw" required="true" type="string" />
      <cfargument name="passdw2" required="true" type="string" />

      <cfset var result = false>
      <cfset var authResult = false>

      <!--- Test if fields have value --->
      <cfif len(#arguments.user#) GT 0 and
            len(#arguments.passdw#) GT 0 and
            len(#arguments.passdw2#) GT 0>

	      <!--- Test if passwords match --->
	      <cfif #arguments.passdw# EQ #arguments.passdw2#>

		      <!--- Verify if pair user/passwd is able to authenticate --->
		      <cfset authResult = authenticate("#arguments.user#","#arguments.passdw#")>

                      <cfif #authResult# EQ true>
			      <cftry>
				 <!--- Delete Scheduled Task --->
				 <cfschedule
				     action = "delete"
				     task = "fetchTzScan" />
			  
				 <!--- Erase all table data --->
				 <cfquery name="reset_taps" datasource="ds_taps">
				    DELETE FROM settings;
				    DELETE FROM payments;
				    DELETE FROM delegatorsPayments;
				    DELETE FROM delegatorsFee;
                                    DELETE FROM bondPool;
                                    DELETE FROM bondPoolSettings;
				 </cfquery>

				 <!--- Delete all memory caches --->
				 <cfobjectcache action="CLEAR">

				 <!--- Clear application-specific variables --->
				 <cfset application.bakerId = "">
				 <cfset application.fee="">
				 <cfset application.freq="">
				 <cfset application.port=8888>
                                 <cfset application.user = "">

				 <cfset result = true>

			      <cfcatch>
				 <cfset result = false>
			      </cfcatch>
			      </cftry>

            <cfelse>
               <cfset result = false>
            </cfif>

         <cfelse>
            <cfset result = false>
         </cfif>

      <cfelse>
         <cfset result = false>
      </cfif>

      <cfreturn result>
   </cffunction>

   <!--- Pause Scheduled task to stop TAPS (mode off) --->
   <!--- This will PAUSE the scheduled-task, which means that TAPS will neither simulate nor make real payments --->
   <!--- It will just stop querying Tezos network --->
   <cffunction name="pauseScheduledTask" returnType="boolean">
      <cfargument name="port" required="true" type="number">

      <cfset var result = false>
      <cfset var settings = "">

      <cftry>

         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">
        
         <cfif #settings.recordCount# GT 0>

            <cfschedule
                  action = "pause"
                  task = "fetchTzScan" />
         
            <cfset result = true>
 
         <cfelse>
            <cfset result = false>
         </cfif>

      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Resume Scheduled task to run TAPS (mode simulation or on) --->
   <!--- This will make Tezos network fetches active again --->
   <cffunction name="resumeScheduledTask" returnType="boolean">
      <cfargument name="port" required="true" type="number">

      <cfset var result = false>
      <cfset var settings = "">

      <cftry>

         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">
        
         <cfif #settings.recordCount# GT 0>

            <cfschedule
                  action = "resume"
                  task = "fetchTzScan" />
         
            <cfset result = true>
 
         <cfelse>
            <cfset result = false>
         </cfif>

      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>


   <!--- Health-check: If TAPS is missing the scheduled-task, re-create it, based on user settings --->
   <cffunction name="healthCheck">
      <cfset var result = false>
      <cfset var settings = "">

      <cftry>
         <!--- Checks if there is a saved configuration. If true, it MUST exist a scheduled-task --->
         <cfinvoke component="components.database" method="getSettings" returnVariable="settings">
        
         <cfif #settings.recordCount# GT 0>
            <!--- Checks if there is a scheduled-task named "fetchTzScan" --->
            <cfschedule
               action = "list"
               returnVariable="myTasks" />

            <cfquery name="get_taps_task" dbtype="query">
               select task from myTasks
               where task = 'fetchTzScan'
            </cfquery>

            <cfif #get_taps_task.recordcount# EQ 0>
               <!--- If there is no scheduled-task named "fetchTzScan", then create it --->
               <cfset myTask = createScheduledTask("#application.port#")>

               <!--- After having re-created the scheduled-task, we need to set its status according to
                     the user configured status (Off, Simulation, or ON) --->
               <cfif #settings.mode# EQ "#application.mode_desc_no#"> <--- Off --->
                  <!--- Pause the scheduled-task --->
                  <cfset myTask = pauseScheduledTask("#application.port#")>
               <cfelse>
                  <!--- Resume the scheduled-task --->
                  <cfset myTask = ResumeScheduledTask("#application.port#")>
               </cfif>

            </cfif>
         </cfif>

         <!--- Check if table bondPool exists. If it doesn't, create it --->
         <cfinvoke component="components.database" method="checkBondPoolTables" returnVariable="checkResult">

         <!--- Check and correct to six decimals places on tables payments and delegatorsPayments --->
         <cfinvoke component="components.database" method="checkSixDecimals" returnVariable="checkDecimalsResult">

         <!--- Add TRANSACTION_HASH column to tables payments and delegatorsPayments --->
         <cfinvoke component="components.database" method="addTxHashFields" returnVariable="addTxHashColumnResult">

         <!--- Add addV120Fields to table settings --->
         <cfinvoke component="components.database" method="addV120Fields" returnVariable="addV120NewFields">

      <cfcatch>
      </cfcatch>
      </cftry>
   </cffunction>

</cfcomponent>

