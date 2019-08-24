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

