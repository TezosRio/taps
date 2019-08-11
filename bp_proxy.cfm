<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>

<cfoutput>
<cfinvoke component="components.database" method="bondPoolMemberProxy" returnVariable="result"
          address="#url.address#" name="#url.name#" amount="#url.amount#" operation="#url.operation#">

</cfoutput>

