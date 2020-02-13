<!---

   Component : tezosGateway.cfc
   Author    : Tezos.Rio
   Date      : 10/25/2019
   Usage     : This component is used as an entry-point to communicate with the underlying
               Tezos node using RPC API.
   
--->


<cfcomponent name="tezosGateway">

   <!--- Constants --->

   <cfset tezosConstants = #deserializeJson(getConstants())#>   
   <cfset blocksPerCycle = #tezosConstants.blocks_per_cycle#>
   <cfset preservedCycles = #tezosConstants.preserved_cycles#>
   <cfset oneHour = #createTimeSpan(0,1,0,0)#>
   <cfset fourMinutes = 240> <!--- In seconds --->
   <cfset fiftySeconds = 50>
   <cfset militez = 1000000>

   <!--- Methods ---> 

   <!--- Method to get Tezos HEAD information --->
   <cffunction name="getHead">
      <cfset var tezosHead = "">

      <!--- Gets the Tezos HEAD information from RPC API --->
      <cfhttp url="#application.provider#/chains/main/blocks/head/metadata" method="get" result="result" charset="utf-8"
              proxyServer="#application.proxyServer#"  
              proxyport="#application.proxyPort#" /> 

      <!--- Parse the received JSON  --->
      <cfset tezosHead = #result.filecontent#>

      <cfreturn tezosHead>
   </cffunction>

   <!--- Method to get Tezos CONSTANTS information --->
   <cffunction name="getConstants">
      <cfset var tezosConstants = "">

      <!--- Gets the Tezos Constants information from RPC API --->
      <cfhttp url="#application.provider#/chains/main/blocks/head/context/constants" method="get" result="result" charset="utf-8"
              proxyServer="#application.proxyServer#"
              proxyport="#application.proxyPort#" /> 

      <!--- Parse the received JSON  --->
      <cfset tezosConstants = #result.filecontent#>

      <cfreturn tezosConstants>
   </cffunction>


   <!--- Method to get current CYCLE number --->
   <cffunction name="getCurrentCycleNumber">
      <cfset var currentCycle = "">

      <!--- Gets Tezos HEAD and parse the JSON received --->
      <cfset tezosHead = #deserializeJSON(getHead())#>

      <!--- Gets the information we are interested in --->
      <cfset currentCycle = #tezosHead.level.cycle#>

      <cfreturn currentCycle>
   </cffunction>


   <!--- Method to get the last BLOCK number of a CYCLE --->
   <cffunction name="getCycleLastBlockNumber">
      <cfargument name="cycle" required="true" type="string" />
      
      <cfset var lastBlockNumber = "">

      <!--- Calculates the last BLOCK number for the given CYCLE --->
      <cfset lastBlockNumber = (#arguments.cycle# + 1) * #blocksPerCycle# >

      <cfreturn lastBlockNumber>
   </cffunction>

   <!--- Method to get a list of a baker's delegators --->
   <cffunction name="getBakerDelegators">
      <cfargument name="bakerID" required="true" type="string" />

      <cfset var delegators = "">

      <!--- Gets the baker's delegators from RPC API --->
      <cfhttp url="#application.provider#/chains/main/blocks/head/context/delegates/#bakerID#/delegated_contracts" method="get" result="result" charset="utf-8"
              proxyServer="#application.proxyServer#"  
              proxyport="#application.proxyPort#" /> 

      <!--- Parse the received JSON  --->
      <cfset delegators = #result.filecontent#>

      <cfreturn delegators>
   </cffunction>

<!--- 

   Method to get a list of a baker's rewards
   <cffunction name="getBakerRewards">
      <cfargument name="bakerID" required="true" type="string" />
      <cfargument name="cycle" required="true" type="string" />

      <cfset var rewards = "">
      <cfset var level = "">
      <cfset var usedSnapshot = "">
      <cfset var blockHash = "">

      Calculates the level to find out the snapshot for the cycle 
      <cfset level = #arguments.cycle * blocksPerCycle + 1# >

      Grab the RollSnapShot value from RPC API 
      <cfhttp url="#application.provider#/chains/main/blocks/#level#/context/raw/json/cycle/#arguments.cycle#"
              method="get"
              result="result"
              charset="utf-8"
              proxyServer="#application.proxyServer#"  
              proxyport="#application.proxyPort#" /> 

      Parse the received JSON  
      <cfset usedSnapshot = #deserializeJson(result.filecontent).roll_snapshot#>

      Calculates the block hash for that snapshot 
      <cfset blockHash = #((arguments.cycle - preservedCycles - 2) * blocksPerCycle) + (usedSnapshot + 1) * 256#>

      Gets the baker's staking balance from RPC API 
      <cfhttp url="#application.provider#/chains/main/blocks/#blockHash#/context/delegates/#arguments.bakerID#/staking_balance"
              method="get"
              result="totalStaking"
              charset="utf-8"
              proxyServer="#application.proxyServer#"  
              proxyport="#application.proxyPort#" />

      Gets the delegator's staking balance from RPC API 
      <cfset delegatorAddress="">
      <cfhttp url="#application.provider#/chains/main/blocks/#blockHash#/context/raw/json/contracts/index/#delegatorAddress#/frozen_balance/#arguments.cycle#/"
              method="get"
              result="stakingBalance"
              charset="utf-8"
              proxyServer="#application.proxyServer#"  
              proxyport="#application.proxyPort#" />

      <cfreturn stakingBalance>
   </cffunction>

--->

   <!--- Method to get the rewards from a given baker --->
   <cffunction name="getRewards" returntype="query">
      <cfargument name="bakerID" required="true" type="string" />

      <cfset var rewards = "">
      <cfset var fetchedRewards = "">

      <!--- v1.0.21 --->
      <cfinvoke component="components.tezosGateway" method="doHttpRequest" url="https://mystique.tzkt.io/v3/rewards_split_cycles/#arguments.bakerID#" returnVariable="fetchedRewards">

      <!---  Parse JSON --->
      <cfset rewards = #deserializeJson(fetchedRewards)# >

      <!--- Create in-memory cached database-table --->
      <cfset queryRewards = queryNew("baker_id,cycle,status","varchar,integer,varchar")>

      <cfloop collection="#rewards#" item="key">
         <cfset QueryAddRow(queryRewards, 1)> 
         <cfset QuerySetCell(queryRewards, "baker_id", javacast("string", "#arguments.bakerID#"))> 
         <cfset QuerySetCell(queryRewards, "cycle", javacast("integer", "#rewards[key].cycle#"))>
         <cfset QuerySetCell(queryRewards, "status", javacast("string", "#rewards[key].status.status#"))> 
      </cfloop>

      <cfreturn #queryRewards#>
   </cffunction>

   <!--- Method to get the delegators from a given baker until a specified cycle --->
   <cffunction name="getDelegators" returntype="query">
      <cfargument name="bakerID" required="true" type="string" />
      <cfargument name="fromCycle" required="false" type="number" />
      <cfargument name="toCycle" required="false" type="number" />

      <cfset var delegators = "">

      <!--- Create in-memory cached database-table --->
      <cfset queryDelegators = queryNew("baker_id,cycle,delegate_staking_balance,address,balance,share,rewards",
                                "varchar,integer,numeric,varchar,numeric,numeric,numeric")>

      <!--- Get rewards info to obtain known cycles to loop --->
      <cfset rewardsInfo = getRewards("#arguments.bakerID#")>

      <cfloop query="#rewardsInfo#">

         <!--- Gets only information for the specified cycle range --->
         <cfif ( len(#arguments.fromCycle#) EQ 0 and len(#arguments.toCycle#) EQ 0 ) or (#rewardsInfo.cycle# LTE #arguments.toCycle# and #rewardsInfo.cycle# GTE #arguments.fromCycle#)>
                 <cfset delegatorsPerPage = 50>


			 <!--- Get list of delegators from RPC API --->

                         <!--- v1.0.21 --->
                         <cfinvoke component="components.tezosGateway" method="doHttpRequest"
                           url="https://mystique.tzkt.io/v3/rewards_split/#arguments.bakerID#?cycle=#rewardsInfo.cycle#"
                           returnVariable="fetchedDelegators">
		      
			 <!---  Parse JSON --->
			 <cfset delegators = deserializeJson(#fetchedDelegators#)>
                         <cfset stakingBalance=#delegators.delegate_staking_balance#>
			 <cfset arrayDelegators=#delegators.delegators_balance#>
			 <cfset qtdDelegators=#ArrayLen(arrayDelegators)#>
			 <cfset totalStakingBalance = #delegators.delegate_staking_balance#>                         

                         <cftry>
		            <cfset blocksRewards = #delegators.blocks_rewards#>
                         <cfcatch>
   		            <cfset blocksRewards = 0>   
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset endorsementsRewards = #delegators.endorsements_rewards#>
                         <cfcatch>
		            <cfset endorsementsRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset fees = #delegators.fees#>
                         <cfcatch>
		            <cfset fees = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset futureBlocksRewards = #delegators.future_blocks_rewards#>
                         <cfcatch>
		            <cfset futureBlocksRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset futureEndorsementsRewards = #delegators.future_endorsements_rewards#>
                         <cfcatch>
		            <cfset futureEndorsementsRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset gainFromDenounciation = #delegators.gain_from_denounciation#>	
                         <cfcatch>
  		            <cfset gainFromDenounciation = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset revelationRewards = #delegators.revelation_rewards#>
                         <cfcatch>
		            <cfset revelationRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostDepositsFromDenounciation =  #delegators.lost_deposit_from_denounciation#>	
                         <cfcatch>
		            <cfset lostDepositsFromDenounciation =  0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostRewardsDenounciation = #delegators.lost_rewards_denounciation#>	
                         <cfcatch>
		            <cfset lostRewardsDenounciation = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostFeesDenounciation = #delegators.lost_fees_denounciation#>	
                         <cfcatch>
		            <cfset lostFeesDenounciation = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostRevelationRewards =  #delegators.lost_revelation_rewards#>	
                         <cfcatch>
		            <cfset lostRevelationRewards =  0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostRevelationFees = #delegators.lost_revelation_fees#>
                         <cfcatch>
		            <cfset lostRevelationFees = 0>
                         </cfcatch>
                         </cftry>

	   <cfset totalRewards = (#blocksRewards# + #endorsementsRewards# + #fees# + #futureBlocksRewards# + #futureEndorsementsRewards# + #gainFromDenounciation# + #revelationRewards#) - (#lostDepositsFromDenounciation# + #lostRewardsDenounciation# + #lostFeesDenounciation# + #lostRevelationRewards# + #lostRevelationFees#) / militez >

			 <cfloop from="1" to="#qtdDelegators#" index="key">
                            <cfif #arrayDelegators[key].balance# GT 0>
	 		            <cfset share = #((arrayDelegators[key].balance / totalStakingBalance)) * 100#> 
				    <cfset delegator_reward = (totalRewards * share) / 100>

					    <cfset QueryAddRow(queryDelegators, 1)> 
					    <cfset QuerySetCell(queryDelegators, "baker_id", javacast("string", "#arguments.bakerID#"))> 
					    <cfset QuerySetCell(queryDelegators, "cycle", javacast("integer", "#rewardsInfo.cycle#"))>
					    <cfset QuerySetCell(queryDelegators, "delegate_staking_balance", javacast("long", "#stakingBalance#"))>  
					    <cfset QuerySetCell(queryDelegators, "address", javacast("string", "#arrayDelegators[key].account.tz#"))> 
					    <cfset QuerySetCell(queryDelegators, "balance", javacast("long", "#arrayDelegators[key].balance#"))> 
					    <cfset QuerySetCell(queryDelegators, "share", javacast("string", "#share#"))> 
					    <cfset QuerySetCell(queryDelegators, "rewards", javacast("long", "#LSNumberFormat(delegator_reward, '999999999999.999999')#"))> 
                            </cfif>		
			 </cfloop>

            </cfif>
      </cfloop>

      <cfreturn #queryDelegators#>
   </cffunction>

   <!--- Method to get the current pending rewards cycle from RPC API in-memory cache --->
   <cffunction name="getNetworkPendingRewardsCycle" returnType="number">
      <cfargument name="rewards" required="true" type="query" />

      <cfset var networkPendingRewardCycle = "">

      <!--- Query to get the current network pending rewards cycle --->
      <cfquery name="rewards_info" dbtype="query">
         SELECT MIN(cycle) as networkPendingRewardsCycle FROM arguments.rewards
         WHERE LOWER(STATUS) = <cfqueryparam value="rewards_pending" sqltype="CF_SQL_VARCHAR" maxlength="30">
         <!--- v1.0.23 --->
         OR LOWER(STATUS) = <cfqueryparam value="cycle_pending" sqltype="CF_SQL_VARCHAR" maxlength="30">
      </cfquery>

      <!--- Parse the received JSON  --->
      <cfset networkPendingRewardCycle = #rewards_info.networkPendingRewardsCycle#>

      <cfreturn networkPendingRewardCycle>
   </cffunction>

   <!--- Get the current network delivered rewards cycle --->
   <!--- Note: although it seems we are querying the database, we are here actually getting from network cache --->
   <!--- that is stored in memory as a database table --->
   <cffunction name="getLastRewardsDeliveryCycle" returnType="number">
      <cfargument name="rewards" required="true" type="query" />

      <!--- Query to get the current network delivered rewards cycle --->
      <cfquery name="check_network_delivered_cycle" dbtype="query">
        SELECT MAX(cycle) as networkDeliveredRewardsCycle FROM arguments.rewards
        WHERE LOWER(STATUS) = <cfqueryparam value="rewards_delivered" sqltype="CF_SQL_VARCHAR" maxlength="30">
     </cfquery>

      <cfreturn check_network_delivered_cycle.networkDeliveredRewardsCycle>
   </cffunction>


   <!--- v1.0.21 --->

   <!--- Do http request using alternative ways, to prevent failure --->
   <cffunction name="doHttpRequest" returnType="string">
      <cfset var responseText="">

      <cfargument name="url" required="true" type="string" />

      <cftry>
         <!--- Do request with Linux curl command --->
         <cfexecute variable="responseText"
                    errorvariable="error"
                    timeout="#fourMinutes#"
                    name="curl #arguments.url#">
         </cfexecute>

      <cfcatch>

         <cftry>
            <!--- Do request with Linux wget command --->
            <cfexecute variable="responseText"
                       errorvariable="error"
                       timeout="#fourMinutes#"
                       name="wget -qO- #arguments.url#">
            </cfexecute>

         <cfcatch>
         
            <!--- Do request with Lucee cfhttp --->
            <cfhttp method="GET" charset="utf-8"
                 url="#arguments.url#"
                 result="result"
                 proxyServer="#application.proxyServer#"  
                 proxyport="#application.proxyPort#"
                 timeout="#fourMinutes#" />

             <cfset responseText = "#result.filecontent#">

         </cfcatch>
         </cftry>

      </cfcatch>
      </cftry>

      <cfreturn responseText>
   </cffunction>

   <!--- v1.0.3 --->

   <!--- Get total baker rewards in a cycle --->
   <cffunction name="getBakersRewardsInCycle" returnType="string">
      <cfset var totalRewards = 0>

      <cfargument name="bakerId" required="true" type="string" />
      <cfargument name="cycle" required="true" type="string" />

      <cftry>
	<cfinvoke component="components.tezosGateway" method="doHttpRequest"
	url="https://mystique.tzkt.io/v3/rewards_split/#arguments.bakerID#?cycle=#arguments.cycle#"
	returnVariable="rewardsInfo">

	<cfset rewardsDetails = deserializeJson(rewardsInfo)>

	 <cftry>
	    <cfset blocksRewards = #rewardsDetails.blocks_rewards#>
	 <cfcatch>
	    <cfset blocksRewards = 0>   
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset endorsementsRewards = #rewardsDetails.endorsements_rewards#>
	 <cfcatch>
	    <cfset endorsementsRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset fees = #rewardsDetails.fees#>
	 <cfcatch>
	    <cfset fees = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset futureBlocksRewards = #rewardsDetails.future_blocks_rewards#>
	 <cfcatch>
	    <cfset futureBlocksRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset futureEndorsementsRewards = #rewardsDetails.future_endorsements_rewards#>
	 <cfcatch>
	    <cfset futureEndorsementsRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset gainFromDenounciation = #rewardsDetails.gain_from_denounciation#>	
	 <cfcatch>
	    <cfset gainFromDenounciation = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset revelationRewards = #rewardsDetails.revelation_rewards#>
	 <cfcatch>
	    <cfset revelationRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostDepositsFromDenounciation =  #rewardsDetails.lost_deposit_from_denounciation#>	
	 <cfcatch>
	    <cfset lostDepositsFromDenounciation =  0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostRewardsDenounciation = #rewardsDetails.lost_rewards_denounciation#>	
	 <cfcatch>
	    <cfset lostRewardsDenounciation = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostFeesDenounciation = #rewardsDetails.lost_fees_denounciation#>	
	 <cfcatch>
	    <cfset lostFeesDenounciation = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostRevelationRewards =  #rewardsDetails.lost_revelation_rewards#>	
	 <cfcatch>
	    <cfset lostRevelationRewards =  0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostRevelationFees = #rewardsDetails.lost_revelation_fees#>
	 <cfcatch>
	    <cfset lostRevelationFees = 0>
	 </cfcatch>
	 </cftry>

	<cfset totalRewards =( (#blocksRewards# + #endorsementsRewards# + #fees# + #futureBlocksRewards# + #futureEndorsementsRewards# + #gainFromDenounciation# + #revelationRewards#) - (#lostDepositsFromDenounciation# + #lostRewardsDenounciation# + #lostFeesDenounciation# + #lostRevelationRewards# + #lostRevelationFees#) ) / militez >

      <cfcatch>
      </cfcatch>
      </cftry>

      <cfreturn totalRewards>
   </cffunction>
   
</cfcomponent>
