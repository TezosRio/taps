<cfsilent>
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Headers" value="Origin, X-Requested-With, Content-Type, Accept">
<cfheader name="Access-Control-Allow-Methods"  value="GET, POST, OPTIONS">
<cfheader name="Access-Control-Allow-Credentials"  value="true">
<cfset balance = #session.myWallet.getBalance()#>
<cfset myBalance = serializeJson(#replace(balance, chr(34), "", "all")#)>
<cfcontent type="application/json; charset=utf-8">
</cfsilent><cfoutput>#replace(myBalance, chr(34), "", "all")#</cfoutput>
