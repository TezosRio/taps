<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>
<cfset structClear(session)>
<cfset structTemp = StructClear(session)>
<cfset session = structNew()>
<cflogout>
<cflocation url="index.cfm">

