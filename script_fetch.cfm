<!---

   Component : fetchTzScan.cfm
   Author    : Tezos.Rio
   Date      : 05/01/2019
   Usage     : This script is intended to fetch information from Tezos network and store in memory database SQL tables.
               This script is called as a scheduled task on Lucee administrator with a configured frequency in minutes,
               (default 60 minutes) to keep caches with updated information, and manage the payments that have been made.
               This script also detects and distributes rewards once they are delivered by the network.
--->

<cfset oneHour = #createTimeSpan(0,1,0,0)#>
<cfset fourMinutes = 240> <!--- In seconds --->
<cfset fiftySeconds = 50>


<!--- Override Lucee Administrator settings for request timeout --->
<cfsetting requestTimeout = #fourMinutes#>

<!--- Get user configuration from local database and also update application (global) settings variables --->
<cfinvoke component="components.database" method="getSettings" returnVariable="settings">

<!--- Get baker's rewards and store them in memory cache ---> 
<cfinvoke component="components.tezosGateway" method="getRewards" bakerID="#application.bakerId#" returnVariable="rewards">

<!--- Get the current network pending rewards cycle ---> 
<cfinvoke component="components.tezosGateway" method="getNetworkPendingRewardsCycle" returnVariable="networkPendingRewardsCycle" 
          rewards="#rewards#">

<!--- Get baker's delegators (and shares) for the last pending cycle (plus previous and next cycle) and store them 
      in memory cache ---> 
<cfinvoke component="components.tezosGateway" method="getDelegators" bakerID="#application.bakerId#" fromCycle="#networkPendingRewardsCycle - 1#" toCycle="#networkPendingRewardsCycle + 1#" returnVariable="delegators">

<!--- Store default delegators' fee (for each delegator) if the table delegatorsFee is empty --->
<cfinvoke component="components.database" method="storeDefaultDelegatorsFee" delegators="#delegators#">

<!--- Initialize payments table in the local database --->
<cfinvoke component="components.database" method="initPaymentsTable"
          networkPendingRewardsCycle="#networkPendingRewardsCycle#">

<!--- At this point, all needed setup configuration have been done. So, register that on settings table --->
<cfinvoke component="components.database" method="setConfigStatus" bakerId="#application.bakerId#" status="true">

<!--- Get the pending rewards cycle that is registered in current local database --->
<cfinvoke component="components.database" method="getLocalPendingRewardsCycle" returnVariable="localPendingRewardsCycle">

<!--- Compare network pending rewards cycle with local pending rewards cycle --->
<!--- If network pending reward is higher than local pending reward, then, probably, new rewards were delivered --->
<cfif #networkPendingRewardsCycle# GT #localPendingRewardsCycle#>

     <!---
     Pending cycle is higher then Pending cycle from local database.
     Lets check if rewards were delivered for the cycle registered (as pending) in local database...
     --->

     <!--- Get the current delivered reward cycle according to the network --->
     <cfinvoke component="components.tezosGateway" method="getLastRewardsDeliveryCycle" rewards="#rewards#" 
               returnVariable="lastRewardsDeliveryCycle">  

     <!--- If last rewards delivery cycle (according to the network) is equal to local database Pending delivery cycle --->
     <!--- it means that the rewards for that cycle have been delivered --->
     <cfif #lastRewardsDeliveryCycle# EQ #localPendingRewardsCycle#>
           
         <!---
         Blockchain has delivered fresh new baked XTZ!
         Lets distribute rewards to our delegators.
         --->

         <!--- Pay delegators (distribute rewards) --->
         <cfinvoke component="components.taps" method="distributeRewards"
                   localPendingRewardsCycle="#localPendingRewardsCycle#"
                   networkPendingRewardsCycle="#networkPendingRewardsCycle#"
                   delegators="#delegators#">


      <cfelse>
 
         <!---
         Cycle did not change yet, or something is wrong. Blockchain has NOT yet delivered rewards.
         --->

      </cfif>
</cfif>
<br>
Done!<br>
<br>

<!--- Restore default Lucee Administrator settings for request timeout --->
<cfsetting requestTimeout = #fiftySeconds#>

