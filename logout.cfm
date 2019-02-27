<cfif not isUserLoggedIn()>
   <cflocation url="index.cfm">
</cfif>
<cfset session.myWallet="">
<cfset session.totalAvailable="">
<cfset session.tezosJ="">
<cfset structClear(session)>
<cfset structTemp = StructClear(session)>
<cfset session = structNew()>
<cflogout>
<cflocation url="index.cfm">

