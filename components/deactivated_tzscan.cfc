<!---

   Component : tzscan.cfc
   Author    : Tezos.Rio
   Date      : 05/01/2019
   Usage     : This component is used as an entry-point to communicate with TZSCAN.IO using its open REST/JSON API.
   
--->


<cfcomponent name="tzscan">

   <!--- Constants --->
   
   <cfset paymentFrequencyInCycles = 6>
   <cfset blocksPerCycle = 4096>
   <cfset oneHour = #createTimeSpan(0,1,0,0)#>
   <cfset fourMinutes = 240> <!--- In seconds --->
   <cfset fiftySeconds = 50>
   <cfset militez = 1000000>

   <!--- Methods ---> 

   <!--- Method to get Tezos HEAD information --->
   <cffunction name="getHead">
      <cfset var tezosHead = "">

      <!--- Gets the Tezos HEAD information from TZSCAN.IO API --->
      <cfhttp url="https://api6.tzscan.io/v3/head" method="get" result="result" charset="utf-8"
              proxyServer="#application.proxyServer#"  
              proxyport="#application.proxyPort#" /> 

      <!--- Parse the received JSON  --->
      <cfset tezosHead = #result.filecontent#>

      <cfreturn tezosHead>
   </cffunction>


   <!--- Method to get current CYCLE number --->
   <cffunction name="getCurrentCycleNumber">
      <cfset var currentCycle = "">

      <!--- Gets Tezos HEAD and parse the JSON received --->
      <cfset tezosHead = #deserializeJSON(getHead())#>

      <!--- Gets the information we are interested in (level, i.e.: current block) --->
      <cfset level = #tezosHead.level#>

      <!--- Calculates the CYCLE number from the level, given that 1 CYCLE has 4096 blocks --->
      <cfset currentCycle = int(#level# / #blocksPerCycle#)>

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


   <!--- Method to get the payment frequency in CYCLES --->
   <cffunction name="getPaymentFrequency">
      <cfreturn #paymentFrequencyInCycles#>
   </cffunction>

   <!--- Method to get the rewards from a given baker --->
   <cffunction name="getRewards" returntype="query">
      <cfargument name="bakerID" required="true" type="string" />

      <cfset var rewards = "">
      <cfset var fetchedRewards = "">

      <!--- v1.0.21 --->
      <cfinvoke component="components.tzscan" method="doHttpRequest" url="https://api6.tzscan.io/v3/rewards_split_cycles/#arguments.bakerID#" returnVariable="fetchedRewards">

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
                 <!--- Get the number of delegators in the cycle --->
                 <cfset totalDelegators = getNumberOfDelegatorInCycle("#arguments.bakerID#", #rewardsInfo.cycle#)>
                 <cfset delegatorsPerPage = 50>

                 <cfloop from="0" to="#int(totalDelegators / delegatorsPerPage)#" index="page">
			 <!--- Get list of delegators from tzscan --->

                         <!--- v1.0.21 --->
                         <cfinvoke component="components.tzscan" method="doHttpRequest"
                           url="https://api6.tzscan.io/v3/rewards_split/#arguments.bakerID#?p=#page#&number=#delegatorsPerPage#&cycle=#rewardsInfo.cycle#"
                           returnVariable="fetchedDelegators">
		      
			 <!---  Parse JSON --->
			 <cfset delegators = deserializeJson(#fetchedDelegators#)>
                         <cfset stakingBalance=#delegators.delegate_staking_balance#>
			 <cfset arrayDelegators=#delegators.delegators_balance#>
			 <cfset qtdDelegators=#ArrayLen(arrayDelegators)#>
			 <cfset totalStakingBalance = #delegators.delegate_staking_balance# / militez>                         

                         <cftry>
		            <cfset blocksRewards = #delegators.blocks_rewards# / militez>
                         <cfcatch>
   		            <cfset blocksRewards = 0>   
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset endorsementsRewards = #delegators.endorsements_rewards# / militez>
                         <cfcatch>
		            <cfset endorsementsRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset fees = #delegators.fees# / militez>
                         <cfcatch>
		            <cfset fees = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset futureBlocksRewards = #delegators.future_blocks_rewards# / militez>
                         <cfcatch>
		            <cfset futureBlocksRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset futureEndorsementsRewards = #delegators.future_endorsements_rewards# / militez>
                         <cfcatch>
		            <cfset futureEndorsementsRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset gainFromDenounciation = #delegators.gain_from_denounciation# / militez>	
                         <cfcatch>
  		            <cfset gainFromDenounciation = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset revelationRewards = #delegators.revelation_rewards# / militez>
                         <cfcatch>
		            <cfset revelationRewards = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostDepositsFromDenounciation =  #delegators.lost_deposit_from_denounciation# / militez>	
                         <cfcatch>
		            <cfset lostDepositsFromDenounciation =  0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostRewardsDenounciation = #delegators.lost_rewards_denounciation# / militez>	
                         <cfcatch>
		            <cfset lostRewardsDenounciation = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostFeesDenounciation = #delegators.lost_fees_denounciation# / militez>	
                         <cfcatch>
		            <cfset lostFeesDenounciation = 0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostRevelationRewards =  #delegators.lost_revelation_rewards# / militez>	
                         <cfcatch>
		            <cfset lostRevelationRewards =  0>
                         </cfcatch>
                         </cftry>

                         <cftry>
		            <cfset lostRevelationFees = #delegators.lost_revelation_fees# / militez>
                         <cfcatch>
		            <cfset lostRevelationFees = 0>
                         </cfcatch>
                         </cftry>

	   <cfset totalRewards = (#blocksRewards# + #endorsementsRewards# + #fees# + #futureBlocksRewards# + #futureEndorsementsRewards# + #gainFromDenounciation# + #revelationRewards#) - (#lostDepositsFromDenounciation# + #lostRewardsDenounciation# + #lostFeesDenounciation# + #lostRevelationRewards# + #lostRevelationFees#) >

			 <cfloop from="1" to="#qtdDelegators#" index="key">
                            <cfif #arrayDelegators[key].balance# GT 0>
	 		            <cfset share = #((arrayDelegators[key].balance / totalStakingBalance) / militez) * 100#> 
				    <cfset delegator_reward = (totalRewards * share) / 100>

					    <cfset QueryAddRow(queryDelegators, 1)> 
					    <cfset QuerySetCell(queryDelegators, "baker_id", javacast("string", "#arguments.bakerID#"))> 
					    <cfset QuerySetCell(queryDelegators, "cycle", javacast("integer", "#rewardsInfo.cycle#"))>
					    <cfset QuerySetCell(queryDelegators, "delegate_staking_balance", javacast("long", "#stakingBalance#"))>  
					    <cfset QuerySetCell(queryDelegators, "address", javacast("string", "#arrayDelegators[key].account.tz#"))> 
					    <cfset QuerySetCell(queryDelegators, "balance", javacast("string", "#arrayDelegators[key].balance#"))> 
					    <cfset QuerySetCell(queryDelegators, "share", javacast("string", "#share#"))> 
					    <cfset QuerySetCell(queryDelegators, "rewards", javacast("string", "#LSCurrencyFormat(delegator_reward,"none","en_US")#"))> 
                            </cfif>		
			 </cfloop>
              </cfloop>
            </cfif>
      </cfloop>

      <cfreturn #queryDelegators#>
   </cffunction>


   <!--- Method to get the number of delegators of a baker in a given cycle --->
   <cffunction name="getNumberOfDelegatorInCycle" returnType="number">

      <cfargument name="bakerID" required="true" type="string" />
      <cfargument name="cycle" required="true" type="number" />

      <cfset var numberOfDelegators = 0>

      <!--- Gets the information from TZSCAN.IO API --->

      <!--- v1.0.21 --->
      <cfinvoke component="components.tzscan" method="doHttpRequest"
        url="https://api6.tzscan.io/v3/nb_delegators/#arguments.bakerID#?cycle=#arguments.cycle#"
        returnVariable="resultDelegators">

      <!--- Parse the received JSON  --->
      <cfset numberOfDelegators = #val(resultDelegators.replaceAll('[^0-9\.]+','')) #>

      <cfreturn numberOfDelegators>
   </cffunction>


   <!--- Method to get the current pending rewards cycle from TzScan in-memory cache --->
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
                 cachedWithin="#oneHour#"
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
	<cfinvoke component="components.tzscan" method="doHttpRequest"
	url="https://api6.tzscan.io/v3/rewards_split/#arguments.bakerId#?p=0&number=0&cycle=#arguments.cycle#"
	returnVariable="rewardsInfo">

	<cfset rewardsDetails = deserializeJson(rewardsInfo)>

	 <cftry>
	    <cfset blocksRewards = #rewardsDetails.blocks_rewards# / militez>
	 <cfcatch>
	    <cfset blocksRewards = 0>   
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset endorsementsRewards = #rewardsDetails.endorsements_rewards# / militez>
	 <cfcatch>
	    <cfset endorsementsRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset fees = #rewardsDetails.fees# / militez>
	 <cfcatch>
	    <cfset fees = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset futureBlocksRewards = #rewardsDetails.future_blocks_rewards# / militez>
	 <cfcatch>
	    <cfset futureBlocksRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset futureEndorsementsRewards = #rewardsDetails.future_endorsements_rewards# / militez>
	 <cfcatch>
	    <cfset futureEndorsementsRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset gainFromDenounciation = #rewardsDetails.gain_from_denounciation# / militez>	
	 <cfcatch>
	    <cfset gainFromDenounciation = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset revelationRewards = #rewardsDetails.revelation_rewards# / militez>
	 <cfcatch>
	    <cfset revelationRewards = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostDepositsFromDenounciation =  #rewardsDetails.lost_deposit_from_denounciation# / militez>	
	 <cfcatch>
	    <cfset lostDepositsFromDenounciation =  0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostRewardsDenounciation = #rewardsDetails.lost_rewards_denounciation# / militez>	
	 <cfcatch>
	    <cfset lostRewardsDenounciation = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostFeesDenounciation = #rewardsDetails.lost_fees_denounciation# / militez>	
	 <cfcatch>
	    <cfset lostFeesDenounciation = 0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostRevelationRewards =  #rewardsDetails.lost_revelation_rewards# / militez>	
	 <cfcatch>
	    <cfset lostRevelationRewards =  0>
	 </cfcatch>
	 </cftry>

	 <cftry>
	    <cfset lostRevelationFees = #rewardsDetails.lost_revelation_fees# / militez>
	 <cfcatch>
	    <cfset lostRevelationFees = 0>
	 </cfcatch>
	 </cftry>

	<cfset totalRewards = (#blocksRewards# + #endorsementsRewards# + #fees# + #futureBlocksRewards# + #futureEndorsementsRewards# + #gainFromDenounciation# + #revelationRewards#) - (#lostDepositsFromDenounciation# + #lostRewardsDenounciation# + #lostFeesDenounciation# + #lostRevelationRewards# + #lostRevelationFees#) >

      <cfcatch>
      </cfcatch>
      </cftry>

      <cfreturn totalRewards>
   </cffunction>
   
</cfcomponent>
