<!---

   Component : database.cfc
   Author    : Luiz Milfont
   Date      : 01/12/2019
   Usage     : This component is used as an entry-point to communicate with the H2 database.
   
--->


<cfcomponent name="database">

   <!--- Constants --->
   <cfset oneMinute = #createTimeSpan(0,0,1,0)#>

   <!--- Methods ---> 

   <!--- Get configuration from local database --->
   <cffunction name="getSettings" returnType="query">
      <!--- Get settings from local database --->
      <cfquery name="getSettings" datasource="ds_taps">
         SELECT baker_id, default_fee, update_freq, user_name, pass_hash, application_port, client_path, node_alias, status, mode, hash_salt, base_dir, wallet_hash, wallet_salt, phrase, app_phrase, funds_origin, proxy_server, proxy_port, provider, gas_limit, storage_limit, transaction_fee, block_explorer, num_blocks_wait, payment_retries, min_between_retries
         FROM settings
      </cfquery>
      <cfif #getSettings.recordCount# GT 0>
         <cfset query = #getSettings#>

         <!--- Also, update application (global) settings variables --->
         <cfset application.bakerId = "#getSettings.baker_id#">
         <cfset application.fee="#getSettings.default_fee#">
         <cfset application.freq="#getSettings.update_freq#">
      </cfif>

      <cfreturn getSettings>
   </cffunction>


   <!--- Save settings configuration in local database --->
   <cffunction name="saveSettings">
      <cfargument name="baker" required="true" type="string">
      <cfargument name="fee" required="true" type="number">
      <cfargument name="freq" required="true" type="number">
      <cfargument name="user" required="true" type="string">
      <cfargument name="passdw" required="true" type="string">
      <cfargument name="passdw2" required="true" type="string">
      <cfargument name="applicationPort" required="true" type="number">
      <cfargument name="clientPath" required="true" type="string">
      <cfargument name="nodeAlias" required="true" type="string">
      <cfargument name="mode" required="true" type="number">
      <cfargument name="baseDir" required="true" type="string">
      <cfargument name="fundsOrigin" required="true" type="string">

      <cfset var result = false>
      <cfset var modeDescription = "">
      
      <!--- Test if all fields are filled --->
      <cfif len(#arguments.baker#) GT 0 and
            len(#arguments.fee# ) GT 0 and
            len(#arguments.freq#) GT 0 and
            len(#arguments.user#) GT 0 and
            len(#arguments.passdw#) GT 0 and
            len(#arguments.passdw2#) GT 0 and
            len(#arguments.applicationPort#) GT 0 and
            len(#arguments.mode#) GT 0 and
            len(#arguments.fundsOrigin#) GT 0 >

        <cfif (#optFunding# EQ "node" and
              (len(#arguments.clientPath#) GT 0 and
               len(#arguments.nodeAlias#) GT 0 and
               len(#arguments.baseDir#) GT 0))
               or
              (#optFunding# EQ "native" and
              (len(#arguments.clientPath#) EQ 0 and
               len(#arguments.nodeAlias#) EQ 0 and
               len(#arguments.baseDir#) EQ 0))>

		 <!--- Test if passwords match --->
		 <cfif #arguments.passdw# EQ #arguments.passdw2#>
	
		    <cftry>
			 <cfif #arguments.mode# EQ #application.mode_no#>
			    <cfset modeDescription = "off">
			 <cfelseif #arguments.mode# EQ #application.mode_try#>
			    <cfset modeDescription = "simulation">
			 <cfelseif #arguments.mode# EQ #application.mode_yes#>
			    <cfset modeDescription = "on">
			 <cfelse>
			    <cfset modeDescription = "simulation">
			 </cfif>  

			 <!--- Generate password hash --->
			 <cfset salt = Hash(GenerateSecretKey("AES"), "SHA-512") /> 
			 <cfset hashedPassword = Hash(#arguments.passdw# & #salt#, "SHA-512") />

			 <!--- Save settings --->
			 <cfquery name="delete_settings" datasource="ds_taps">
			    DELETE FROM settings;
			 </cfquery>

			 <cfquery name="save_settings" datasource="ds_taps">
			    INSERT INTO settings
			    (BAKER_ID, DEFAULT_FEE, UPDATE_FREQ, USER_NAME, PASS_HASH, APPLICATION_PORT, CLIENT_PATH, NODE_ALIAS, MODE, HASH_SALT, BASE_DIR, FUNDS_ORIGIN)
			    VALUES
			    (
			       <cfqueryparam value="#arguments.baker#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
			       <cfqueryparam value="#arguments.fee#" sqltype="CF_SQL_DECIMAL" maxlength="6">,
			       <cfqueryparam value="#arguments.freq#" sqltype="CF_SQL_NUMERIC" maxlength="50">,
			       <cfqueryparam value="#arguments.user#" sqltype="CF_SQL_VARCHAR" maxlength="100">,
			       <cfqueryparam value="#hashedPassword#" sqltype="CF_SQL_VARCHAR" maxlength="150">,
			       <cfqueryparam value="#arguments.applicationPort#" sqltype="CF_SQL_NUMERIC" maxlength="50">,
			       <cfqueryparam value="#arguments.clientPath#" sqltype="CF_SQL_VARCHAR" maxlength="200">,
			       <cfqueryparam value="#arguments.nodeAlias#" sqltype="CF_SQL_VARCHAR" maxlength="100">,
			       <cfqueryparam value="#modeDescription#" sqltype="CF_SQL_VARCHAR" maxlength="20">,
			       <cfqueryparam value="#salt#" sqltype="CF_SQL_VARCHAR" maxlength="150">,
		               <cfqueryparam value="#arguments.baseDir#" sqltype="CF_SQL_VARCHAR" maxlength="200">,
		               <cfqueryparam value="#arguments.fundsOrigin#" sqltype="CF_SQL_VARCHAR" maxlength="20">
			     )
			 </cfquery>
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

   <!--- Remove settings configuration in local database --->
   <cffunction name="removeSettings">
      <cfargument name="bakerId" required="true" type="string">

      <cfset var result = false>

      <cftry>
         <!--- Remove settings --->
         <cfquery name="remove" datasource="ds_taps">
            DELETE FROM settings
            WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">;
         </cfquery>
         <cfset result = true>

      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>


   <!--- Store default delegators' fee in the local database --->
   <cffunction name="storeDefaultDelegatorsFee">
      <cfargument name="delegators" required="true" type="query" />

      <!--- v1.0.24 - Removed condition test if table was empty ---> 

         <!--- Loop through delegators and save the configured fee % for everyone --->
         <cfloop query="#arguments.delegators#">
            <cftry>
            <cfquery name="local_save_delegators_fee" datasource="ds_taps">
               INSERT INTO delegatorsFee (BAKER_ID, ADDRESS, FEE)
               VALUES
               (
                  <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
                  <cfqueryparam value="#delegators.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
                  <cfqueryparam value="#application.fee#" sqltype="CF_SQL_NUMERIC" maxlength="50">
               )
            </cfquery>
            <cfcatch>
            </cfcatch>
            </cftry>
         </cfloop>

   </cffunction>

   <!--- Get the pending rewards cycle that is registered in current local database --->
   <cffunction name="getLocalPendingRewardsCycle" returnType="string">
      <cfset var localPendingRewardsCycle = "">

      <!--- Get pending rewards cycle from the local database --->
      <cfquery name="get_local_pending_rewards_cycle" datasource="ds_taps">
         SELECT cycle FROM payments
         WHERE LOWER(result) = 'rewards_pending'
      </cfquery>
      <cfif #get_local_pending_rewards_cycle.recordCount# GT 0>
         <cfset localPendingRewardsCycle = "#get_local_pending_rewards_cycle.cycle#">
      </cfif>
   
      <cfreturn localPendingRewardsCycle>
   </cffunction>


   <!--- Initialize local payments table. If it is empty, then create a new row--->
   <cffunction name="initPaymentsTable">
      <cfargument name="networkPendingRewardsCycle" required="true" type="string" />

      <!--- Get the local pending rewards cycle --->
      <cfset var localPendingRewardsCycle = getLocalPendingRewardsCycle()>

      <!--- Test to see if the local payments info table is empty. If true, then create a row --->     
      <cfif #len(localPendingRewardsCycle)# EQ 0>
         <!--- Initialize table payments --->
         <cfquery name="init_payments_table" datasource="ds_taps">
            INSERT INTO payments (BAKER_ID, CYCLE, DATE, RESULT, TOTAL)
            VALUES
            (
               <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
               <cfqueryparam value="#arguments.networkPendingRewardsCycle#" sqltype="CF_SQL_NUMERIC" maxlength="50">,
               parsedatetime(<cfqueryparam value="#dateFormat(now(),'mm-dd-yyyy')#" sqltype="CF_SQL_VARCHAR" maxlength="50">, 'MM-dd-yyyy'),
               'rewards_pending',
               0
            )
         </cfquery>  
      </cfif> 
   </cffunction>

   <!--- Return a list of delegators' fee from the local database --->
   <cffunction name="getDelegatorsFees" returnType="query">

      <!--- Get the pending rewards cycle that is registered in current local database --->
      <cfset localPendingRewardsCycle=getLocalPendingRewardsCycle()>

      <!--- First, get delegators query to do a join --->
      <!--- This Join is required to order the delegators fee list by their balance --->
      <cfinvoke component="components.tezosGateway" method="getDelegators" bakerID="#application.bakerId#"
                fromCycle="#localPendingRewardsCycle#" toCycle="#localPendingRewardsCycle#" returnVariable="delegators">       


      <!--- v1.0.24 --->   
      <!--- This is an integrity measure. If for some reason the local database got corrupted, here
            we rebuild the DelegatorsFee table ---> 
      <cfinvoke component="components.database" method="storeDefaultDelegatorsFee" delegators="#delegators#">


      <!--- Second, get data from local delegatorsFee --->
      <cfquery name="get_local_delegators_fees" datasource="ds_taps">
         SELECT baker_id, address, fee
         FROM delegatorsFee
      </cfquery>

      <!--- Now, do the join, so we can have the list ordered by the delegators' balance, from the highest to the lowest --->
      <cfquery name="delegators_fee_ordered" dbtype="query" cachedWithin="#oneMinute#">
         SELECT df.baker_id, df.address, df.fee
         FROM get_local_delegators_fees df, delegators d
         WHERE d.cycle = #localPendingRewardsCycle#
         AND   df.baker_id = d.baker_id
         AND   df.address = d.address
         ORDER BY d.balance DESC
      </cfquery>

      <cfreturn #delegators_fee_ordered#>
   </cffunction>

   <!--- Return the fee of a given delegator --->
   <cffunction name="getDelegatorFee" returnType="number">
      <cfargument name="address" required="true" type="string" />

      <cfset var fee = "">

      <cfquery name="get_local_delegator_fee" datasource="ds_taps">
         SELECT fee FROM delegatorsFee
         WHERE address = <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">
      </cfquery>

      <cfif #get_local_delegator_fee.recordcount# GT 0>
         <cfset fee = "#get_local_delegator_fee.fee#">
      <cfelse>
         <cfset fee = "#application.fee#">
      </cfif>

      <cfreturn fee >
   </cffunction>

   <!--- Save delegator fee to the local database --->
   <cffunction name="saveDelegatorFee">
      <cfargument name="bakerId" required="true" type="string" />
      <cfargument name="address" required="true" type="string" />
      <cfargument name="fee" required="true" type="number" />

      <cfset var result = false>

      <cftry>
         <!--- Clear caches, as we are updating information --->
         <cfobjectcache action = "clear" />

         <cfquery name="local_save_delegators_fee" datasource="ds_taps">
            UPDATE delegatorsFee
            SET fee = <cfqueryparam value="#arguments.fee#" sqltype="CF_SQL_NUMERIC" maxlength="50">
            WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
            AND   address = <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         </cfquery>
         <cfset result = true>
      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Return a list of delegators' payments from the local database --->
   <cffunction name="getDelegatorsPayments" returnType="query">

      <cfquery name="get_local_delegators_payments" datasource="ds_taps">
         SELECT baker_id, cycle, date, address, result, total, transaction_hash
         FROM delegatorsPayments
         ORDER BY BAKER_ID, CYCLE DESC, DATE DESC, RESULT, TOTAL DESC
      </cfquery>

      <cfreturn #get_local_delegators_payments#>
   </cffunction>

   <!--- Return a list of delegators from the local database --->
   <cffunction name="getDelegators" returnType="query">

      <cfquery name="get_local_delegators" datasource="ds_taps">
         SELECT baker_id,cycle,delegate_staking_balance,address,balance,share,rewards
         FROM delegators
         ORDER BY BAKER_ID, CYCLE, ADDRESS
      </cfquery>

      <cfreturn #get_local_delegators#>
   </cffunction>


   <!--- Set configuration status --->
   <cffunction name="setConfigStatus">
      <cfargument name="bakerId" required="true" type="string" />
      <cfargument name="status" required="true" type="boolean" />

      <cfset var result = false>

      <cftry>
         <cfquery name="set_status" datasource="ds_taps">
            UPDATE settings
            SET status = <cfqueryparam value="#arguments.status#" sqltype="CF_SQL_BOOLEAN">
            WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         </cfquery>
         <cfset result = true>
      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Update status mode in the local database --->
   <cffunction name="setStatusMode">
      <cfargument name="bakerId" required="true" type="string">
      <cfargument name="statusValue" required="true" type="number" />

      <cfset var result = false>
      <cfset var modeDesciption = "">

      <cftry>
         <cfif #arguments.statusValue# EQ #application.mode_no#>
            <cfset modeDescription = "off">
            <cfinvoke component="components.taps" method="pauseScheduledTask" port="#application.port#">
         <cfelseif #arguments.statusValue# EQ #application.mode_try#>
            <cfset modeDescription = "simulation">
            <cfinvoke component="components.taps" method="resumeScheduledTask" port="#application.port#">
         <cfelseif #arguments.statusValue# EQ #application.mode_yes#>
            <cfset modeDescription = "on">
            <cfinvoke component="components.taps" method="resumeScheduledTask" port="#application.port#">
         <cfelse>
            <cfset modeDescription = "simulation">
            <cfinvoke component="components.taps" method="resumeScheduledTask" port="#application.port#">
         </cfif>  

         <cfquery name="local_save_delegators_fee" datasource="ds_taps">
            UPDATE settings
            SET mode = <cfqueryparam value="#modeDescription#" sqltype="CF_SQL_VARCHAR" maxlength="20">
            WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         </cfquery>
         <cfset result = true>
      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Convert status description to value--->
   <cffunction name="getStatusValue" returnType="number">
      <cfargument name="description" required="true" type="string">

      <cfset var result="">

      <cfif #arguments.description# EQ #application.mode_desc_no#>
         <cfset result = "#application.mode_no#">
      <cfelseif #arguments.description# EQ #application.mode_desc_try#>
         <cfset result = "#application.mode_try#">
      <cfelseif #arguments.description# EQ #application.mode_desc_yes#>
         <cfset result = "#application.mode_yes#">
      <cfelse>
         <cfset result = "#application.mode_try#">
      </cfif>  

      <cfreturn result>
   </cffunction>

   <!--- Change user password --->
   <cffunction name="changePassdw">
      <cfargument name="user" required="true" type="string" />
      <cfargument name="bakerId" required="true" type="string" />
      <cfargument name="current" required="true" type="string" />
      <cfargument name="passdw" required="true" type="string" />
      <cfargument name="passdw2" required="true" type="string" />

      <cfset var result = false>
      <cfset var authResult = false>

      <!--- Test if fields have value --->
      <cfif len(#arguments.user#) GT 0 and
            len(#arguments.bakerId#) GT 0 and
            len(#arguments.current#) GT 0 and
            len(#arguments.passdw#) GT 0 and
            len(#arguments.passdw2#) GT 0>

	      <!--- Test if passwords match --->
	      <cfif #arguments.passdw# EQ #arguments.passdw2#>

		      <!--- Verify if pair user/passwd is able to authenticate --->
                      <cfinvoke component="components.taps" method="authenticate" user="#arguments.user#" passdw="#arguments.current#" returnVariable="authResult">

                      <cfif #authResult# EQ true>
                         <cftry>
           		    <!--- Generate password hash --->
		            <cfset salt = Hash(GenerateSecretKey("AES"), "SHA-512") /> 
		            <cfset hashedPassword = Hash(#arguments.passdw# & #salt#, "SHA-512") />
                            <cfquery name="upd_passdw" datasource="ds_taps">
                               UPDATE settings
                               SET pass_hash = <cfqueryparam value="#hashedPassword#" sqltype="CF_SQL_VARCHAR" maxlength="150">,
                                   hash_salt = <cfqueryparam value="#salt#" sqltype="CF_SQL_VARCHAR" maxlength="150">
                               WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
                            </cfquery>
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

   <!--- Save wallet passphrase hash --->
   <cffunction name="saveWallet">
      <cfargument name="bakerId" required="true" type="string" />
      <cfargument name="passphrase" required="true" type="string" />
      <cfargument name="passdw" required="true" type="string" />

      <cfset var result = false>
      <cfset var encPassphrase = "">
      <cfset var appPassphrase = "">

      <!--- Test if fields have value --->
      <cfif len(#arguments.bakerId#) GT 0 and
            len(#arguments.passphrase#) GT 0 and
            len(#arguments.passdw#) GT 0>

        <cftry>
           <!--- Generate passphrase hash --->
           <cfset walletSalt = Hash(GenerateSecretKey("AES"), "SHA-512") /> 
           <cfset walletHash = Hash(#passphrase# & #walletSalt#, "SHA-512") />

           <!--- Encrypt passphrase with user login password and store it for future use on wallet openning --->
           <cfset encPassphrase = encrypt('#arguments.passphrase#', '#arguments.passdw#')>

           <!--- Create a key for the application --->
           <cfset appPassphrase = encrypt('#arguments.passphrase#', '#application.encSeed#')>

           <cfquery name="upd_wallet" datasource="ds_taps">
              UPDATE settings
              SET wallet_hash = <cfqueryparam value="#walletHash#" sqltype="CF_SQL_VARCHAR" maxlength="150">,
                  wallet_salt = <cfqueryparam value="#walletSalt#" sqltype="CF_SQL_VARCHAR" maxlength="150">,
                  phrase = <cfqueryparam value="#encPassphrase#" sqltype="CF_SQL_VARCHAR" maxlength="150">,
                  app_phrase = <cfqueryparam value="#appPassphrase#" sqltype="CF_SQL_VARCHAR" maxlength="150">
              WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
           </cfquery>
           <cfset result = true>
        <cfcatch>
           <cfset result = false>
        </cfcatch>
        </cftry>

      <cfelse>
           <cfset result = false>
      </cfif>

      <cfreturn result>
   </cffunction>

   <!--- Authenticate owner of the wallet --->
   <cffunction name="authWallet" returnType="boolean">
      <cfargument name="bakerId" required="true" type="string" />
      <cfargument name="passdw" required="true" type="string" />

      <cfset var result = false>

      <cfif #len(arguments.bakerId)# GT 0 and #len(arguments.passdw)# GT 0>
         <!--- Get wallet passphrase hashes --->
         <cfquery name="load_wallet" datasource="ds_taps">
            SELECT wallet_hash, wallet_salt
            FROM settings
         </cfquery>
         <cfif #load_wallet.recordCount# EQ 0>
            <cfset result = false>
         <cfelse>
            <!--- Verify if the hash matches --->
            <cfset salt = #load_wallet.wallet_salt#>
            <cfset hashedPassword = Hash(#arguments.passdw# & #salt#, "SHA-512") />

            <cfif #load_wallet.wallet_hash# EQ #hashedPassword#>
              <cfset result = true>
            <cfelse>
              <cfset result = false>
            </cfif>
         </cfif>

      <cfelse>
         <cfset result = false>
      </cfif>

      <cfreturn result>
   </cffunction>

   <!--- v.1.0.3 --->

   <!--- Return bond pool total stake from the local database --->
   <cffunction name="getTotalBondPoolStake" returnType="string">

      <!--- Get data from local bondpool --->
      <cfquery name="get_total_stake" datasource="ds_taps">
         SELECT SUM(AMOUNT) TOTAL
         FROM bondPool
         WHERE BAKER_ID = '#application.bakerId#'
      </cfquery>

      <cfreturn #get_total_stake.total#>
   </cffunction>


   <!--- Return a list of bond pool members from the local database --->
   <cffunction name="getBondPoolMembers" returnType="query">
      <cfargument name="sortForPayment" required="false" type="boolean">

      <!--- Get data from local bondpool --->
      <cfquery name="get_local_bondpoolers" datasource="ds_taps">
         SELECT BAKER_ID, ADDRESS, AMOUNT, NAME, ADM_CHARGE, IS_MANAGER
         FROM bondPool
         WHERE BAKER_ID = '#application.bakerId#'
         <cfif #arguments.sortForPayment# EQ true>
            ORDER BY baker_id, IS_MANAGER, amount, name
         <cfelse>
            ORDER BY baker_id, name
         </cfif>
      </cfquery>

      <cfreturn #get_local_bondpoolers#>
   </cffunction>



   <!--- Add/delete/update bondpool member --->
   <cffunction name="bondPoolMemberProxy" returntype="boolean">
      <cfargument name="address" required="true" type="string" />
      <cfargument name="amount" required="false" type="string" />
      <cfargument name="name" required="false" type="string" />
      <cfargument name="fee" required="false" type="string" />
      <cfargument name="ismanager" required="false" type="string" />
      <cfargument name="operation" required="true" type="string" />

      <cfset var f_amount = #Replace(arguments.amount, ',', '', 'all')#>  
      <cfset var manager = "">
      <cfset var result=false>

      <cfif #findnocase("on", arguments.ismanager)# GT 0 OR
            #findnocase("yes", arguments.ismanager)# GT 0 OR
            #findnocase("true", arguments.ismanager)# GT 0>
         <cfset manager = true>
      <cfelse>
         <cfset manager = false>
      </cfif>

      <cftry>

         <cfset result=true>

         <cfif #manager#>
            <!--- Clear isManager field for all entries --->
            <cfquery name="clear_isManager" datasource="ds_taps">
               UPDATE bondPool
               SET is_manager = false
              WHERE baker_id = <cfqueryparam value="#application.bakerid#" sqltype="CF_SQL_VARCHAR" maxlength="50">
           </cfquery>
         </cfif>

      <cfif #operation# EQ "add">


         <cfquery name="add_bondpool_member" datasource="ds_taps">
            INSERT INTO bondPool (BAKER_ID, ADDRESS, AMOUNT, NAME, ADM_CHARGE, IS_MANAGER)
            VALUES
            (
               <cfqueryparam value="#application.bakerid#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
               <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
               <cfqueryparam value="#f_amount#" sqltype="CF_SQL_NUMERIC" maxlength="20">,
               <cfqueryparam value="#arguments.name#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
               <cfqueryparam value="#arguments.fee#" sqltype="CF_SQL_NUMERIC" maxlength="20">,
               <cfqueryparam value="#manager#" sqltype="CF_SQL_BOOLEAN" maxlength="5">
            )
         </cfquery>

      <cfelseif #operation# EQ "update">

         <cfquery name="update_bondpool_member" datasource="ds_taps">
            UPDATE bondPool
            SET amount = <cfqueryparam value="#f_amount#" sqltype="CF_SQL_NUMERIC" maxlength="20">,
                name = <cfqueryparam value="#arguments.name#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
                adm_charge = <cfqueryparam value="#arguments.fee#" sqltype="CF_SQL_NUMERIC" maxlength="20">,
                is_manager = <cfqueryparam value="#manager#" sqltype="CF_SQL_BOOLEAN" maxlength="5">
            WHERE baker_id = <cfqueryparam value="#application.bakerid#" sqltype="CF_SQL_VARCHAR" maxlength="50">
            AND address =  <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         </cfquery>

      <cfelseif #operation# EQ "delete">
         <cfquery name="delete_bondpool_member" datasource="ds_taps">
            DELETE FROM bondPool
            WHERE baker_id = <cfqueryparam value="#application.bakerid#" sqltype="CF_SQL_VARCHAR" maxlength="50">
            AND address =  <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">;
         </cfquery>
      </cfif>
   
      <cfcatch>
         <cfset result=false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Make sure that bondPool tables exists --->
   <cffunction name="checkBondPoolTables" returntype="string">
      <cfset var result = true>

	   <cftry>
	      <!--- Create table to control bondpool settings --->
	      <cfquery name="createTableBondPoolSettings" datasource="ds_taps">
	      	   CREATE TABLE bondPoolSettings
		   (
		      baker_id    VARCHAR(50)  NOT NULL,
		      status      BOOLEAN      NOT NULL
		   );
		   ALTER TABLE bondPoolSettings ADD PRIMARY KEY (baker_id);
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>

	   <cftry>
	      <!--- Create table to control bondpool --->
	      <cfquery name="createTableBondPool" datasource="ds_taps">
	      	   CREATE TABLE bondPool
		   (
		      baker_id    VARCHAR(50)  NOT NULL,
		      address     VARCHAR(50)  NOT NULL,
		      amount      DECIMAL(20,2) NOT NULL,
		      name        VARCHAR(50),
		      adm_charge  DECIMAL(20,2) NOT NULL,
		      is_manager  BOOLEAN
		   );
		   ALTER TABLE bondPool ADD PRIMARY KEY (baker_id, address);
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>
      <cfreturn result>
   </cffunction>

   <!--- Return bond pool total stake from the local database --->
   <cffunction name="getBondPoolSettings" returnType="query">
      <cfset var q = "">

      <!--- Get data from local bondpool --->
      <cfquery name="get_bondPool_settings" datasource="ds_taps">
         SELECT BAKER_ID, STATUS
         FROM bondPoolSettings
         WHERE BAKER_ID = '#application.bakerId#'
      </cfquery>

      <cfif #get_bondPool_settings.recordcount# EQ 0>
         <cfset q = queryNew("baker_id,status","varchar,varchar")>
         <cfset QueryAddRow(q, 1)> 
         <cfset QuerySetCell(q, "baker_id", javacast("string", "#application.bakerID#"))>
         <cfset QuerySetCell(q, "status", javacast("boolean", "false"))>
         <cfset get_bondPool_settings = q>
      </cfif>

      <cfreturn #get_bondPool_settings#>
   </cffunction>

   <!--- Return bond pool total stake from the local database --->
   <cffunction name="saveBondPoolSettings" returnType="boolean">
      <cfset var result = false>

      <cfargument name="status" required="true" type="boolean">

      <cfquery name="check_empty_table" datasource="ds_taps">
         SELECT BAKER_ID, STATUS
         FROM bondPoolSettings
         WHERE BAKER_ID = '#application.bakerId#'
      </cfquery>

      <cfif #check_empty_table.recordcount# EQ 0>
	 <cfquery name="save_settings" datasource="ds_taps">
	    INSERT INTO bondPoolSettings
	    (BAKER_ID, STATUS)
	    VALUES
	    (
	       <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
	       <cfqueryparam value="#arguments.status#" sqltype="CF_SQL_BOOLEAN" maxlength="10">
	     )
	 </cfquery>
	 <cfset result = true>
         
      <cfelse>
	 <cfquery name="save_settings" datasource="ds_taps">
	    UPDATE bondPoolSettings
	    SET STATUS = <cfqueryparam value="#arguments.status#" sqltype="CF_SQL_BOOLEAN" maxlength="10">
	    WHERE BAKER_ID = <cfqueryparam value="#application.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
	 </cfquery>
	 <cfset result = true>

      </cfif>

      <cfreturn result>
   </cffunction>

   <!--- Check six decimal places on tables payments and delegatorsPayments --->
   <cffunction name="checkSixDecimals" returntype="string">
      <cfset var result = true>

	   <cftry>
	      <cfquery name="checkPaymentsDecimals" datasource="ds_taps">
		   ALTER TABLE payments ALTER COLUMN total DECIMAL(20,6) NOT NULL;
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>

	   <cftry>
	      <cfquery name="checkDelegatorsPaymentsDecimals" datasource="ds_taps">
		   ALTER TABLE delegatorsPayments ALTER COLUMN total DECIMAL(20,6) NOT NULL;
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>
      <cfreturn result>
   </cffunction>

   <!--- Adds TRANSACTION_HASH fields to tables payments and delegatorsPayments --->
   <cffunction name="addTxHashFields" returntype="string">
      <cfset var result = true>

	   <cftry>
	      <cfquery name="addPaymentsTxHash" datasource="ds_taps">
		   ALTER TABLE payments ADD COLUMN TRANSACTION_HASH VARCHAR(70) NULL;
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>

	   <cftry>
	      <cfquery name="addDelegatorsPaymentsTxHash" datasource="ds_taps">
		   ALTER TABLE delegatorsPayments ADD COLUMN TRANSACTION_HASH VARCHAR(70) NULL;
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>
      <cfreturn result>
   </cffunction>

   <!--- Adds version 1.2.0 new fields to table settings --->
   <cffunction name="addV120Fields" returntype="string">
      <cfset var result = true>

	   <cftry>
	      <cfquery name="add1" datasource="ds_taps">
		   ALTER TABLE settings ADD COLUMN proxy_server VARCHAR(70) DEFAULT '' NULL;
		   ALTER TABLE settings ADD COLUMN proxy_port INTEGER DEFAULT #application.proxyPort# NOT NULL;
                   ALTER TABLE settings ADD COLUMN provider VARCHAR(70) DEFAULT '#application.provider#' NOT NULL;
		   ALTER TABLE settings ADD COLUMN gas_limit INTEGER DEFAULT #application.gasLimit# NOT NULL;
		   ALTER TABLE settings ADD COLUMN storage_limit INTEGER DEFAULT #application.storageLimit# NOT NULL;
		   ALTER TABLE settings ADD COLUMN transaction_fee DECIMAL(20,6) DEFAULT #application.tz_default_operation_fee# NOT NULL;
                   ALTER TABLE settings ADD COLUMN block_explorer VARCHAR(70) DEFAULT '#application.blockExplorer#' NOT NULL;
                   ALTER TABLE settings ADD COLUMN num_blocks_wait INTEGER DEFAULT #application.numberOfBlocksToWait# NOT NULL;
                   ALTER TABLE settings ADD COLUMN payment_retries INTEGER DEFAULT #application.paymentRetries# NOT NULL;
                   ALTER TABLE settings ADD COLUMN min_between_retries INTEGER DEFAULT #application.minutesBetweenTries# NOT NULL;
	      </cfquery>
	   <cfcatch type="any">
	      <cfset result = false>
	   </cfcatch>
	   </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Update settings configuration in local database --->
   <cffunction name="updateSettings">
      <cfargument name="bakerID" required="true" type="string">
      <cfargument name="proxy_server" required="true" type="string">
      <cfargument name="proxy_port" required="true" type="string">
      <cfargument name="provider" required="true" type="string">
      <cfargument name="payment_retries" required="true" type="string">
      <cfargument name="gas_limit" required="true" type="string">
      <cfargument name="storage_limit" required="true" type="string">
      <cfargument name="num_blocks_wait" required="true" type="string">
      <cfargument name="block_explorer" required="true" type="string">
      <cfargument name="min_between_retries" required="true" type="string">
      <cfargument name="transaction_fee" required="true" type="string">
      <cfargument name="default_fee" required="true" type="string">
      <cfargument name="update_freq" required="true" type="string">
      <cfargument name="lucee_port" required="true" type="string">

      <cfset var result = false>
      
      <!--- Test if all fields are filled --->
      <cfif len(#arguments.bakerID#) GT 0 and
            len(#arguments.proxy_port# ) GT 0 and
            len(#arguments.provider#) GT 0 and
            len(#arguments.payment_retries#) GT 0 and
            len(#arguments.gas_limit#) GT 0 and
            len(#arguments.storage_limit#) GT 0 and
            len(#arguments.num_blocks_wait#) GT 0 and
            len(#arguments.block_explorer#) GT 0 and
            len(#arguments.min_between_retries#) GT 0 and
            len(#arguments.transaction_fee#) GT 0 and
            len(#arguments.default_fee#) GT 0 and
            len(#arguments.update_freq#) GT 0 and
            len(#arguments.lucee_port#) GT 0 >


		<cftry>

		 <cfquery name="update_settings" datasource="ds_taps">
		    UPDATE settings SET
		       proxy_server = <cfqueryparam value="#arguments.proxy_server#" sqltype="CF_SQL_VARCHAR" maxlength="70">, 
                       proxy_port = <cfqueryparam value="#arguments.proxy_port#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       provider = <cfqueryparam value="#arguments.provider#" sqltype="CF_SQL_VARCHAR" maxlength="70">,
                       payment_retries = <cfqueryparam value="#arguments.payment_retries#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       gas_limit = <cfqueryparam value="#arguments.gas_limit#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       storage_limit = <cfqueryparam value="#arguments.storage_limit#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       num_blocks_wait = <cfqueryparam value="#arguments.num_blocks_wait#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       block_explorer = <cfqueryparam value="#arguments.block_explorer#" sqltype="CF_SQL_VARCHAR" maxlength="70">,
                       min_between_retries = <cfqueryparam value="#arguments.min_between_retries#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       transaction_fee = <cfqueryparam value="#arguments.transaction_fee#" sqltype="CF_SQL_DECIMAL" maxlength="10">,
                       default_fee = <cfqueryparam value="#arguments.default_fee#" sqltype="CF_SQL_DECIMAL" maxlength="10">,
                       update_freq = <cfqueryparam value="#arguments.update_freq#" sqltype="CF_SQL_NUMERIC" maxlength="10">,
                       application_port = <cfqueryparam value="#arguments.lucee_port#" sqltype="CF_SQL_NUMERIC" maxlength="10"> 
                    WHERE BAKER_ID = <cfqueryparam value="#arguments.bakerID#" sqltype="CF_SQL_VARCHAR" maxlength="50">
		 </cfquery>
		 <cfset result = true>

		<cfcatch>
		   <cfset result = false>
		</cfcatch>
		</cftry>

      <cfelse>
	 <cfset result = false>
      </cfif>

      <cfreturn result>
   </cffunction>


</cfcomponent>

