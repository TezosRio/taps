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
         SELECT baker_id, default_fee, update_freq, user_name, pass_hash, application_port, client_path, node_alias, status, mode, hash_salt, base_dir, wallet_hash, wallet_salt, phrase, app_phrase, funds_origin
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

      <!--- Check if table is empty (if it is first time use) --->
      <cfquery name="local_delegators_fee" datasource="ds_taps">
         SELECT count(*) as total FROM delegatorsFee
      </cfquery>
      <cfif #local_delegators_fee.total# EQ 0>
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
      </cfif>
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

      <!--- Create in-memory cached database-table --->
      <cfset var queryFees = queryNew("timestamp,baker_id,address,fee","varchar,varchar,varchar,varchar")>

      <!--- Get the pending rewards cycle that is registered in current local database --->
      <cfset localPendingRewardsCycle=getLocalPendingRewardsCycle()>

      <!--- First, get delegators query --->
      <cfinvoke component="components.tzscan" method="getAlternative" bakerID="#application.bakerId#" returnVariable="delegators">

      <cfloop query="delegators">

         <!--- Second, get data from local delegatorsFee --->
         <cfquery name="get_local_delegators_fees" datasource="ds_taps">
            SELECT baker_id, address, fee
            FROM delegatorsFee
            WHERE baker_id = '#delegators.baker_id#'
            AND   address = '#delegators.address#'
         </cfquery>

         <cfset QueryAddRow(queryFees, 1)>
         <cfset QuerySetCell(queryFees, "timestamp", javacast("string", "#delegators.timestamp#"))>
         <cfset QuerySetCell(queryFees, "baker_id", javacast("string", "#delegators.baker_id#"))> 
         <cfset QuerySetCell(queryFees, "address", javacast("string", "#delegators.address#"))> 
         
         <cfif #get_local_delegators_fees.recordcount# GT 0>
            <cfset QuerySetCell(queryFees, "fee", javacast("string", "#get_local_delegators_fees.fee#"))> 
         <cfelse>
            <cfset QuerySetCell(queryFees, "fee", javacast("string", ""))>
         </cfif>
         
      </cfloop>
   
      <!--- Order by the delegators' balance, from the highest to the lowest --->
      <cfquery name="delegators_fee_ordered" dbtype="query" cachedWithin="#oneMinute#">
         SELECT df.baker_id, df.address, df.fee
         FROM queryFees df, delegators d
         WHERE df.baker_id = d.baker_id
         AND   df.address = d.address
         -- AND   d.address <> df.baker_id
         ORDER BY d.timestamp
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
      
         <!--- Check if delegator exists --->
         <cfquery name="checkDelegator" datasource="ds_taps">
            SELECT fee
            FROM delegatorsFee
            WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
            AND   address = <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">
         </cfquery>

         <cfif #checkDelegator.recordCount# GT 0>
      
            <!--- Clear caches, as we are updating information --->
            <cfobjectcache action = "clear" />

            <cfquery name="local_save_delegators_fee" datasource="ds_taps">
               UPDATE delegatorsFee
               SET fee = <cfqueryparam value="#arguments.fee#" sqltype="CF_SQL_DECIMAL" maxlength="6">
               WHERE baker_id = <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">
               AND   address = <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">
            </cfquery>
            <cfset result = true>

         <cfelse>   

            <!--- Clear caches --->
            <cfobjectcache action = "clear" />

            <cfquery name="local_insert_delegators_fee" datasource="ds_taps">
               INSERT INTO delegatorsFee (baker_id, address, fee)
               VALUES
               (
                  <cfqueryparam value="#arguments.bakerId#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
                  <cfqueryparam value="#arguments.address#" sqltype="CF_SQL_VARCHAR" maxlength="50">,
                  <cfqueryparam value="#arguments.fee#" sqltype="CF_SQL_DECIMAL" maxlength="6">
               )
            </cfquery>
            <cfset result = true>
         
         </cfif>  
            
            
      <cfcatch>
         <cfset result = false>
      </cfcatch>
      </cftry>

      <cfreturn result>
   </cffunction>

   <!--- Return a list of delegators' payments from the local database --->
   <cffunction name="getDelegatorsPayments" returnType="query">

      <cfquery name="get_local_delegators_payments" datasource="ds_taps">
         SELECT baker_id, cycle, date, address, result, total
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


</cfcomponent>

