<cfhttp method="GET"
	      charset="utf-8"
              url="https://api6.tzscan.io/v3/operations/tz1gfipKzYrNRT14oSNQJMCdRRsUtcbZoKsd?type=Delegation&p=0&number=50"
              result="fetchedOperationsNumber"
              proxyServer="proxy.rio.rj.gov.br"  
              proxyport="8080">


<cfset arrayDelegators=#deserializeJson(fetchedOperationsNumber.filecontent)#>

<cfdump var="#arrayDelegators#">

