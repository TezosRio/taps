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
         
         <cfinvoke component="components.tzscan" method="getDelegators" bakerID="#application.bakerId#"
                   fromCycle="#url.cycle - 1#" toCycle="#url.cycle + 1#" returnVariable="myDelegators">

         <!--- Pay rewards again (distribute rewards) --->
         <cfinvoke component="components.taps" method="distributeRewards"
                   localPendingRewardsCycle="#url.cycle#"
                   networkPendingRewardsCycle="#url.cycle + 1#"
                   delegators="#myDelegators#">


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

